# Copyright © 2021 Broadcom

from .zowe_util import *
from pathlib import Path
from .element_util import get_template_dir, get_download_dir


# Get all the programs content and write to COBPGM folder
# Check the boundaries of :split to esplit when type=CBL and capture the program
def writecobol_pgm(cobol_lines, directives_dict, context):
    """Parses the type=CBL content from the remote file and writes it to a file based on the member name"""
    lines_by_member_dict = {}
    for content_idx, content_line in enumerate(cobol_lines):
        if content_line.find("type=CBL") > 0 and content_line.startswith(":split"):
            mn = content_line.split('=')[1]
            membername = mn.split()[0]
            current_line_idx = content_idx
            cobol_code = []

            while True:
                current_line_idx = current_line_idx+1
                k = cobol_lines[current_line_idx]
                if k.startswith(":esplit."):
                    break
                else:
                    cobol_code.append(k)

            lines_by_member_dict[membername] = cobol_code

    download_dir = get_download_dir(context)
    template_dir = get_template_dir(context)
    cobdb2_path = template_dir / Path('COBDB2')
    cobpgm_path = template_dir / Path('COBPGM')

    sql_skeleton_elem = context.vals['zowe']['sql_skeleton']
    sql_skeleton_file = download_dir / Path("ISPS") / sql_skeleton_elem
    # retrieve the element from the Endevor
    download_content(sql_skeleton_elem, 'ISPS', sql_skeleton_file, context, search_map=True)
    sqlskel_lines = sql_skeleton_file.read_text().split('\n')
    # run through the dictionary of programs
    # form the individual members
    spaces = "       "
    for name_key, cobol_lines in lines_by_member_dict.items():
        name = str(name_key.strip())
        if name in directives_dict:
            sqlval = directives_dict[name]['sql']
        else:
            raise Exception('no value in ICM for ' + name)

        if sqlval:
            cobfile_path = cobdb2_path / name
        else:
            cobfile_path = cobpgm_path / name

        with open(cobfile_path, 'w') as cobfile:
            if sqlval:
                for line in sqlskel_lines:
                    cobfile.write(spaces)
                    cobfile.write(line)
                    cobfile.write('\n')
            for line_with_newline in cobol_lines:
                cobfile.write(line_with_newline)
