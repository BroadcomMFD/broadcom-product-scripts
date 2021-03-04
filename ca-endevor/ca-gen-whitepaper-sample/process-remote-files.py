#!/usr/bin/env python3
# Copyright © 2021 Broadcom
import logging
import sys
import time
import shutil
from subprocess import CalledProcessError

from helpers.parms import IcmParserContext
from helpers.write_cobol import writecobol_pgm
from helpers.write_cics_csd import write_csd_def
from helpers.write_sidedeck import write_sidedeck
from helpers.write_linkage_elements import write_linkage_elements, write_dialog_module
from helpers.write_bind_element import write_bind_element
from helpers.element_util import *
from helpers.icmparser import parse_section_data, build_bind_card_dict, get_linked_members_for_standard


# Create target directory & all intermediate directories LNK/LNKINC/LOAD etc
def recreate_dir(dirname, delete_first=True):
    if delete_first and os.path.exists(dirname):
        shutil.rmtree(dirname)    # Delete the directory
    os.makedirs(dirname, exist_ok=True)


# Main Where the execution starts, won't execute if this script is "imported" in another script
if __name__ == "__main__":
    try:
        context = IcmParserContext()
        context.gather_params()

        numeric_log_level = getattr(logging, context.vals["log"].upper(), None)
        if not isinstance(numeric_log_level, int):
            raise ValueError('invalid log level: %s' % context.vals['log'])
        if context.vals['log_file'] == 'STDOUT':
            logging.basicConfig(level=numeric_log_level, stream=sys.stdout)
        else:
            logging.basicConfig(filename=context.vals['log-file'], level=numeric_log_level, stream=sys.stdout)

        start = time.time()
        print("Executing.....")
        icm_content = []
        cascade_content = []
        dialogmgr_content = []
        # future: refactor this out with better parsing, but have reduced this from 5-6 things to 1
        elem_tracker = {
            'dyn_ri_modules': set()
        }

        template_dir = get_template_dir(context)
        download_dir = get_download_dir(context)
        diff_dir = get_diff_dir(context)

        # Read the RMT files and get the content to a LIST
        logging.debug('reading DialogMgr rmt file')
        # Capture all the Directives into the file
        remote_file_path = Path(context.vals['inputfiles']['dialogrmtfile'])
        if remote_file_path.exists():
            with open(remote_file_path, 'r') as f:
                end_of_execdef = False
                for line in f.readlines():
                    if line not in ['\n', '\r\n']:
                        if not end_of_execdef:
                            icm_content.append(line.strip())
                        dialogmgr_content.append(line)
                    elif line.startswith(":eexecdef."):
                        end_of_execdef = True
        else:
            logging.error("no remote file for dialog mgr at %s", remote_file_path)
            raise Exception("must have valid dialog manager remote file to begin processing")

        # CASCADE RMT
        if 'cascadermtfile' in context.vals['inputfiles']:
            cascade_path = Path(context.vals['inputfiles']['cascadermtfile'])
            if cascade_path.exists():
                logging.debug("reading CASCADE (RI Triggers) rmt file")
                with open(cascade_path, 'r') as f:
                    for line in f.readlines():
                        if line not in ['\n', '\r\n']:
                            cascade_content.append(line)
            else:
                logging.info("no RI triggers file was found at %s", cascade_path)
        else:
            logging.info("no RI trigger file configured")

        # Call the functions for each of the Directives in the remote file
        all_directives = parse_section_data(icm_content)

        icm_execunit_dict = dict(filter(lambda e: e[1]['section'] == 'execunit', all_directives.items())).popitem()[1]
        icm_pstep_dict = dict(filter(lambda e: e[1]['section'] == 'pstep', all_directives.items()))
        icm_screen_dict = dict(filter(lambda e: e[1]['section'] == 'screen', all_directives.items()))
        icm_acblk_dict = dict(filter(lambda e: e[1]['section'] == 'acblk', all_directives.items()))
        icm_std_acblk_dict = dict(filter(lambda e: e[1]['abtype'] == 'STANDARD', icm_acblk_dict.items()))
        icm_dynamic_module_dict = dict(filter(lambda e: e[1]['link'] == 'DYNAMIC', all_directives.items()))
        icm_static_object_dict = dict(filter(lambda e: e[1]['link'] == 'STATIC' and e[1]['section'] != 'execunit',
                                             all_directives.items()))
        icm_load_module_dict = {**icm_execunit_dict, **icm_dynamic_module_dict}

        bind_card_dict = build_bind_card_dict(all_directives)

        logging.info('creating directories for output')
        # Create directories for templated content and for downloaded content
        elem_dirs = ["LNKINC", "LNK", "SIDEDECK", "COBPGM", "COBDB2", "SAMPS", "PARMS"]
        for d in elem_dirs:
            recreate_dir(template_dir / d)
            recreate_dir(diff_dir / d)

        if context.zowe('output_dir'):
            recreate_dir(context.zowe('output_dir'))

        recreate_dir(download_dir / "ISPS", delete_first=False)

        # Form the dictionary of Cascades for Action blocks
        dependency_graph = get_linked_members_for_standard(icm_acblk_dict)

        logging.info("writing out PSTEPs")
        # Print psteps
        write_linkage_elements(icm_pstep_dict, dependency_graph, "pstep", template_dir, elem_tracker, context)

        logging.info("writing out SCREENs")
        # Print Screens
        write_linkage_elements(icm_screen_dict, dependency_graph, "screen", template_dir, elem_tracker, context)

        logging.info("writing out ACTION BLOCKS")
        # Print Actionblocks
        write_linkage_elements(icm_std_acblk_dict, dependency_graph, "acblk", template_dir, elem_tracker, context)

        logging.info("writing out DIALOG MGR")
        # Write dialog module
        write_dialog_module(icm_execunit_dict['member'], template_dir, icm_static_object_dict,
                            icm_dynamic_module_dict, elem_tracker, context)

        logging.info("writing out SIDEDECKs")
        # Write the Sidedeck for all the members
        write_sidedeck(icm_execunit_dict, icm_dynamic_module_dict, download_dir, template_dir, context)

        # Write Cobol programs
        writecobol_pgm(dialogmgr_content, all_directives, context)
        writecobol_pgm(cascade_content, icm_acblk_dict, context)

        # Write CSD Definitions for each load module
        write_csd_def(icm_load_module_dict, icm_pstep_dict, "SAMPS", context)

        if context.vals['processing']['db2_bind']['create']:
            write_bind_element(all_directives, icm_execunit_dict, bind_card_dict, template_dir, context)

        # this is a portion of the code that need to see some overhauling so that we
        # properly add/update elements depending on whether they are new, or existing elements
        # we can use the logic from the original Powershell scripts that worked all of these things out

        # if the user wants to diff their changes with what's in Endevor now, we download the content for each
        # file that we template (if it exists)...can hook in logic here to do diffs or prompt the user or
        # whatever logic that needs to go in here
        if context.vals['do_diff']:
            for tup in elem_gener(context, 'SIDEDECK', 'LNKINC', 'LNK', 'COBPGM', 'COBDB2', 'SAMPS'):
                if len(tup) == 6:
                    (elem, _, _, _, elem_type, _) = tup
                    if elem_type == "COBPGM":
                        if elem_exists(elem, elem_type, context):
                            logging.info("downloading existing element %s:%s to compare", elem, elem_type)
                            download_content(elem, elem_type, diff_dir / elem_type / elem, context)
                            # future: add logic to do a semantic diff (not exact diff) to see if any material
                            # changes were made in the generated code (i.e. more than just a timestamp update)
                        else:
                            logging.debug("no element to compare with %s:%s", elem, elem_type)

        # Add all the LNK/LNKINC/SIDEDECK elements to Endevor
        if context.vals['do_upload'] or context.vals['dry_run']:
            # multiprocessing needs some work for logging to work correctly...commenting out some example code
            # num_executors = context.vals['processing']['zowe_pool_size']
            # elemtuples = elems_in(context, 'COBPGM', 'COBDB2')
            # with mp.Pool(num_executors) as pool:
            #     pool.starmap(smart_process_elem, elemtuples)

            # this processing element logic could be refactored to generate SCL to do the Endevor operations that
            # we need to do instead of doing then serially using a Zowe API call per operation...this could increase
            # overall throughput
            #
            # Existing process loop logic:
            # go through each file in our template directories and process it...we do the generate all at once
            # after adding/updating things...this is something that could be refactored to be done in SCL or
            # even in batch using the available APIs in Zowe and the Endevor plugin
            for d in ['COBPGM', 'COBDB2', 'SIDEDECK', 'LNKINC', 'LNK', 'SAMPS', 'PARMS']:
                for file in os.listdir(template_dir / d):
                    if (template_dir / Path(d) / file).suffix != '.txt':
                        endevor_type = endv_elem_type_for_type(d)
                        smart_process_elem(
                            file,
                            endevor_type,
                            template_dir / Path(d) / file,
                            procgroup_for_type(d, context),
                            context,
                            do_generate=endevor_type == 'COBPGM')
            # COBOL elements are generated one-at-a-time at this point because we have a single COBPGM type for
            # COBOL elements with SQL and without, but each uses a different processor group
            generate_all_elements_of_type('PARMS', context)
            generate_all_elements_of_type('SIDEDECK', context)
            generate_all_elements_of_type('LNKINC', context)
            generate_all_elements_of_type('LNK', context)
            # if your GENERATE processor is configured, generating the CSDDEF should result in the appropriate modules
            # being copied into the CICSRPL dataset for that stage
            generate_all_elements_of_type('SAMPS', context)

        # Calculate the end time
        end = time.time()

        print("Execution Ended in : ", (end - start), "Seconds")
        print("process complete")
    except CalledProcessError as cpe:
        logging.error('problem invoking command rc=%s, stdout/stderr to follow', cpe.returncode)
        if cpe.stdout:
            logging.error("stdout:\n%s", cpe.stdout)
        if cpe.stderr:
            logging.error("stderr:\n%s", cpe.stderr)
