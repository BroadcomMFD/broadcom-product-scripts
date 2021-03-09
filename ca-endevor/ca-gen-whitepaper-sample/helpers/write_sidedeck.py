# Copyright © 2021 Broadcom

from .zowe_util import *
from pathlib import Path


def write_sidedeck(exec_unit, dynamic_directives, download_dir, template_dir, context):
    """Downloads sidedeck skeletons and writes out one per load module"""
    skelprofile = exec_unit['profile'][:1]
    skelenv = exec_unit['execenv'][:1]
    skeleton_st = "SMP" + skelenv + "B" + skelprofile + "SC"
    skeleton_dynamic = context.vals['zowe']['dynamic_isps']

    isps_download_dir = download_dir / Path('ISPS')
    sidedeck_folder = template_dir / Path('SIDEDECK/')

    skelfile_dynamic_download = isps_download_dir / skeleton_dynamic
    skelfile_static_download = isps_download_dir / skeleton_st

    # download the element content from Endevor
    logging.info("downloading dynamic skeleton (%s) from Endevor", skeleton_dynamic)
    download_content(
        skeleton_dynamic,
        'ISPS',
        skelfile_dynamic_download,
        context,
        search_map=True,
        view_sandbox=context.zowe('view_sandbox'))

    logging.info("downloading dynamic skeleton (%s) from Endevor", skeleton_st)
    download_content(
        skeleton_st,
        'ISPS',
        skelfile_static_download,
        context,
        search_map=True,
        view_sandbox=context.zowe('view_sandbox'))

    dynamic_skeletons = skelfile_dynamic_download.read_text()

    # we always write out the SIDEDECK for the dialog manager
    (sidedeck_folder / exec_unit['member']).write_text(skelfile_static_download.read_text())
    # we also need to write out a SIDEDECK element for each dynamic load module
    for dynamic_module in dynamic_directives.keys():
        (sidedeck_folder / dynamic_module).write_text(dynamic_skeletons)
