# Copyright © 2021 Broadcom

from pathlib import Path
from .element_util import get_template_dir


def write_csd_def(lnkmod_files, pstep_dict, directory, context):

    csd_path = get_template_dir(context) / Path(directory) / "CSDDEF"

    with open(csd_path, 'w') as csd_file:

        # Delete the group if present
        csd_file.write(context.vals['csd']['deletegroup'] + '\n\n')

        # Write all the program definitions
        for file in lnkmod_files:
            csd_file.write(context.vals['csd']['lnkmod'].format(filename=file))

        # Write all the transactions definitions
        for name, tx in pstep_dict.items():
            csd_file.write(context.vals['csd']['pstep'].format(dlgtran=tx['dlgtran'], member=tx['member']))

        # Add the group to the list in CICS
        csd_file.write(context.vals['csd']['group'])
