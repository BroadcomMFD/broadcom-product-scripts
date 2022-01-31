# Copyright © 2021 Broadcom

import os
from pathlib import Path
from .zowe_util import *


def smart_process_elem(ename, etype, epath, eprocgroup, context, do_generate=True):
    """ Check the current state of the given element and try to 'do the right thing' to get the content
        uploaded to Endevor and to make sure the element is generated (if necessary)
    """
    elem_in_place = is_elem_in_target_subsystem(ename, etype, context.zowe('subsystem'), context)
    dryrun = context.vals['dry_run']

    if elem_in_place is None:
        if dryrun:
            logging.info("dry-run: add %s as %s:%s", epath, ename, etype)
        else:
            addelement(ename, etype, epath, context)
        if do_generate:
            if dryrun:
                logging.info("dry-run: generate %s:%s using PG %s", ename, etype, eprocgroup)
            else:
                generate_element(ename, etype, eprocgroup, context)
    else:
        if not elem_in_place:
            if dryrun:
                logging.info("dry-run: retrieve %s:%s", ename, etype)
            else:
                retrieve_element(ename, etype, context)
        if dryrun:
            logging.info("dry-run: update %s at %s:%s", epath, ename, etype)
            if do_generate:
                logging.info("dry-run: generate %s:%s using PG %s", ename, etype, eprocgroup)
        else:
            if update_element(ename, etype, epath, context):
                if do_generate:
                    generate_element(ename, etype, eprocgroup, context)
                logging.info("content updated for %s:%s", ename, etype)
            else:
                logging.info("no changes detected for %s:%s", ename, etype)


def procgroup_for_type(elemtype, context):
    if elemtype == 'COBPGM':
        procgroup = context.zowe('cobol_pg')
    elif elemtype == 'COBDB2':
        procgroup = context.zowe('coboldb2_pg')
    elif elemtype == 'LNK':
        procgroup = context.zowe('linkPG')
    else:
        procgroup = context.zowe('noprocPG')

    return procgroup


def endv_elem_type_for_type(etype):
    endvtype = etype
    if etype == 'COBDB2':
        endvtype = 'COBPGM'
    return endvtype


def elem_gener(context, *dirs):
    for elemdir, tmpl_path in [(d, get_template_dir(context) / Path(d)) for d in dirs]:
        for f in os.listdir(tmpl_path):
            if (tmpl_path / f).suffix != '.txt':
                yield (
                    f,
                    endv_elem_type_for_type(elemdir),
                    (tmpl_path / f),
                    procgroup_for_type(elemdir, context),
                    context)


def elems_in(context, *dirs):
    tmpl_paths = [(d, get_template_dir(context) / Path(d)) for d in dirs]
    elems = []
    for elemdir, tmpl_path in tmpl_paths:
        for fil in os.listdir(tmpl_path):
            if (tmpl_path / fil).suffix != '.txt':
                elems.append((fil,
                              endv_elem_type_for_type(elemdir),
                              (tmpl_path / fil),
                              procgroup_for_type(elemdir, context),
                              context))
    return elems


def elem_exists(elemname, elemtype, context):
    return True if list_element(elemname, elemtype, context) is not None else False


def is_elem_in_target_subsystem(elemname, elemtype, target_subsystem, context):
    elem_in_map = list_element(elemname, elemtype, context)
    if len(elem_in_map) == 0:
        return None
    for elem in elem_in_map:
        if elem['subsystem'] == target_subsystem and elem['stage'] == '1':
            return True

    return False


# Generate the elements in the endevor subsystem
def generate_all_elements_of_type(etype, context):
    if context.vals['dry_run']:
        logging.info("dry-run: generating all %s type elems", etype)
    else:
        generate_element('*', etype, procgroup_for_type(etype, context), context)


# Generate the elements in the endevor subsystem
def generate_all_elements_in_dir(directory, pg, context):
    crpath = os.path.abspath(os.getcwd())
    os.chdir(directory)
    list_of_files = os.listdir(directory)
    for file in list_of_files:
        if file.endswith(".txt"):
            os.remove(file)
        else:
            generate_element(file, directory, pg, context)
    os.chdir(crpath)


def get_download_dir(context):
    return Path(context.vals['processing']['download']['output_dir'])


def get_template_dir(context):
    return Path(context.vals['processing']['template']['output_dir'])


def get_diff_dir(context):
    return Path(context.vals['processing']['diff']['output_dir'])
