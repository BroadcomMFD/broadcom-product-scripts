# Copyright © 2021 Broadcom

import subprocess
import logging
import time
from tempfile import NamedTemporaryFile
import os

# this whole file needs to be reworked to use subprocess.call to be more platform agnostic
# also, this is a command injection risk since we just template strings that are controlled by outside input
# and could be manipulated into executing commands that are not expected...
# use the subprocess.call(args) function with each command token as an individual list item
# this will be more work, but much safer overall

ANYELEM = '*'
ANYTYPE = '*'
SIGNOUT_IGNORE = 'ignore'
SIGNOUT_OVERRIDE = 'override'
SIGNOUT_NO = 'nosign'
SIGNOUT_MODE = SIGNOUT_IGNORE


def create_sandbox(sandbox_name, context, stage_num='1'):
    tmpoutput = tmpfile(context, 'addsandbox', sandbox_name, 'SANDBOX')
    zowe = zowe_executable(context)
    cmd = [zowe, 'endevor', 'add', 'element', sandbox_name.upper(),
           "--endevor-profile", context.zowe('profile'),
           "--env", context.zowe('env'),
           '--sys', context.zowe('system_name'),
           '--sub', context.zowe('sandbox_subsystem'),
           '--type', 'SANDBOX',
           '--ccid', context.zowe('ccid'),
           '--comment', 'create sandbox',
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', context.zowe('region'),
           '--ff', 'resources/sandbox.txt']

    proc = run_cmd(cmd)

    tmpoutput = tmpfile(context, 'gensandbox', sandbox_name, 'SANDBOX')
    cmd = [zowe, "endevor", 'generate', 'element', sandbox_name.upper(),
           '--endevor-profile', context.zowe('profile'),
           '--env', context.zowe('env'),
           '--sys', context.zowe('system_name'),
           '--sub', context.zowe('sandbox_subsystem'),
           '--sn', stage_num,
           '--type', 'SANDBOX',
           '--ccid', context.zowe('ccid'),
           '--comment', 'generate sandbox',
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', context.zowe('region')]

    proc = run_cmd(cmd)


def delete_sandbox(sandbox_name, context):
    """Ensures a sandbox is empty and then deletes it"""

    sandbox_name = sandbox_name.upper()
    elems = list_element_full(ANYELEM, ANYTYPE,
                              context.zowe('profile'),
                              context.zowe('env'),
                              context.zowe('system_name'),
                              sandbox_name,
                              context.zowe('region'),
                              context.zowe('output_dir'),
                              executable_path=context.zowe('executable_path'),
                              search=False,
                              stagenum='2')
    if len(elems) > 0:
        raise Exception("stage 2 is not empty contains elems: %s", elems)

    elems = list_element_full(ANYELEM, ANYTYPE,
                              context.zowe('profile'),
                              context.zowe('env'),
                              context.zowe('system_name'),
                              sandbox_name,
                              context.zowe('region'),
                              context.zowe('output_dir'),
                              executable_path=context.zowe('executable_path'),
                              search=False,
                              stagenum='1')

    if len(elems) > 0:
        raise Exception("stage 1 is not empty contains elems: %s", elems)

    tmpoutput = tmpfile(context, 'delsandbox', sandbox_name, 'SANDBOX')
    zowe = zowe_executable(context)

    cmd = [zowe, 'endevor', 'delete', 'element', sandbox_name,
           "--endevor-profile", context.zowe('profile'),
           "--env", context.zowe('env'),
           '--sys', context.zowe('system_name'),
           '--sub', context.zowe('sandbox_subsystem'),
           '--sn', '1',
           '--type', 'SANDBOX',
           '--ccid', context.zowe('ccid'),
           '--comment', 'create sandbox',
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', context.zowe('region')]

    proc = run_cmd(cmd)


def empty_sandbox(sandbox_name, context):
    """Removes all the elements from the given sandbox"""

    sandbox_name = sandbox_name.upper()

    empty_stage(sandbox_name, '2', context)
    empty_stage(sandbox_name, '1', context)


def empty_stage(sandbox_name, stagenum, context):
    """Removes all the elements from the given sandbox stage"""
    elems = list_element_full(ANYELEM, ANYTYPE,
                              context.zowe('profile'),
                              context.zowe('env'),
                              context.zowe('system_name'),
                              sandbox_name,
                              context.zowe('region'),
                              context.zowe('output_dir'),
                              search=False,
                              executable_path=context.zowe('executable_path'),
                              stagenum=stagenum)
    if len(elems) > 0:
        deleteelement_full(ANYELEM, ANYTYPE,
                           context.zowe('profile'),
                           context.zowe('env'),
                           context.zowe('system_name'),
                           sandbox_name,
                           context.zowe('region'),
                           context.zowe('ccid'),
                           context.zowe('comment'),
                           context.zowe('output_dir'),
                           executable_path=context.zowe('executable_path'),
                           stagenum=stagenum)


def deleteelement(elementname, elemtype, stage_num, context):
    """Deletes the element(s) of the type(s) from the specified Endevor stage"""
    return deleteelement_full(elementname, elemtype,
                              context.zowe('profile'),
                              context.zowe('env'),
                              context.zowe('system_name'),
                              context.zowe('subsystem'),
                              context.zowe('region'),
                              context.zowe('ccid'),
                              context.zowe('comment'),
                              context.zowe('output_dir'),
                              executable_path=context.zowe('executable_path'),
                              stagenum=stage_num)


def deleteelement_full(elementname, elemtype, profile, env, sys, subsystem, region,
                       ccid, comment, output_dir,
                       executable_path='zowe', stagenum='1'):
    """Deletes the element(s) of the type(s) from the specified Endevor stage using all parameters"""
    if elemtype == "COBDB2":
        elemtype = "COBPGM"

    logging.info('deleting %s/%s/%s/%s/%s:%s', env, sys, subsystem, stagenum, elementname, elemtype)

    tmpoutput = tmpfile_to(output_dir, 'delelem', elementname, elemtype)
    zowe = executable_path
    cmd = [zowe, "endevor", 'delete', 'element', elementname,
           '--endevor-profile', profile,
           '--env', env,
           '--sys', sys,
           '--sn', stagenum,
           '--sub', subsystem,
           '--type', elemtype,
           '--ccid', ccid,
           '--comment', comment,
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', region]
    logging.debug("cmd=%s", ' '.join(cmd))

    proc = run_cmd(cmd)


def addelement(elementname, elemtype, elempath, context):
    if elemtype == "SANDBOX":
        raise Exception("use createsandbox to create/generate a sandbox")
    elif elemtype == "COBDB2":
        elemtype = "COBPGM"

    tmpoutput = tmpfile(context, 'addelem', elementname, elemtype)
    zowe = zowe_executable(context)
    cmd = [zowe, "endevor", 'add', 'element', elementname,
           "--endevor-profile", context.zowe('profile'),
           "--env", context.zowe('env'),
           '--sys', context.zowe('system_name'),
           '--sub', context.zowe('subsystem'),
           '--type', elemtype,
           '--ccid', context.zowe('ccid'),
           '--comment', 'create %s:%s' % (elementname, elemtype),
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', context.zowe('region'),
           '--ff', str(elempath)]

    proc = run_cmd(cmd)


def update_element(elementname, elemtype, elempath, context):
    return update_element_full(elementname, elemtype, elempath,
                               context.zowe('profile'),
                               context.zowe('env'),
                               context.zowe('system_name'),
                               context.zowe('subsystem'),
                               context.zowe('region'),
                               context.zowe('ccid'),
                               context.zowe('comment'),
                               context.zowe('output_dir'),
                               executable_path=context.zowe('executable_path'),
                               override_signout=True if context.zowe('signout_mode') == SIGNOUT_OVERRIDE else False)


def update_element_full(elementname, elemtype, elempath, profile, env, sys, subsystem, region,
                        ccid, comment, output_dir,
                        executable_path='zowe', override_signout=False):
    if elemtype == "COBDB2":
        elemtype = "COBPGM"

    tmpoutput = tmpfile_to(output_dir, 'updtelem', elementname, elemtype)
    zowe = executable_path
    cmd = [zowe, "endevor", 'update', 'element', elementname,
           "--endevor-profile", profile,
           "--env", env,
           '--sys', sys,
           '--sub', subsystem,
           '--type', elemtype,
           '--ccid', ccid,
           '--comment', comment,
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '-i', region,
           '--ff', str(elempath)]

    if override_signout:
        cmd.append('--os')

    proc = run_cmd(cmd)
    if '*NO ELEMENT SOURCE CHANGES DETECTED*' in proc.stdout:
        print("no changes for %s" % elementname)
        return False
    return True


def generate_element(elementname, elemtype, procgroup, context):
    return generate_element_full(elementname, elemtype, procgroup,
                                 context.zowe('profile'),
                                 context.zowe('env'),
                                 context.zowe('system_name'),
                                 context.zowe('subsystem'),
                                 context.zowe('region'),
                                 context.zowe('ccid'),
                                 context.zowe('comment'),
                                 context.zowe('output_dir'),
                                 executable_path=context.zowe('executable_path'))


def generate_element_full(elementname, elemtype, procgroup, profile, env, sys, subsystem, region,
                          ccid, comment, output_dir,
                          executable_path='zowe', stagenum='1'):
    if elemtype == "SANDBOX":
        raise Exception("use createsandbox to create/generate a sandbox")
    elif elemtype == "COBDB2":
        elemtype = "COBPGM"

    logging.info('generating %s:%s PG=%s', elementname, elemtype, procgroup)
    tmpoutput = tmpfile_to(output_dir, 'genelem', elementname, elemtype)
    zowe = executable_path
    cmd = [zowe, "endevor", 'generate', 'element', elementname,
           '--endevor-profile', profile,
           '--env', env,
           '--sys', sys,
           '--sn', stagenum,
           '--sub', subsystem,
           '--type', elemtype,
           '--ccid', ccid,
           '--comment', comment,
           '--sm', 'true',
           '--fn', tmpoutput.name,
           '--pg', procgroup,
           '-i', region]
    logging.debug("cmd=%s", ' '.join(cmd))

    proc = run_cmd(cmd)


# this function is useful if you just want the content of an element and not have to worry about sign-outs and
# things like that
def download_content(elementname, elemtype, destination, context,
                     view_sandbox=None, search_map=False):
    cache_time = None
    if context.zowe('download_cache')['enabled']:
        cache_time = context.zowe('download_cache')['max_age']
    return download_content_full(elementname, elemtype, destination,
                                 context.zowe('profile'),
                                 context.zowe('env'),
                                 context.zowe('system_name'),
                                 view_sandbox if view_sandbox else context.zowe('subsystem'),
                                 context.zowe('region'),
                                 context.zowe('ccid'),
                                 context.zowe('comment'),
                                 context.zowe('output_dir'),
                                 executable_path=context.zowe('executable_path'),
                                 search=search_map,
                                 cachetime=cache_time)


def download_content_full(elementname, elemtype, destination, profile, env, sys, subsystem, region,
                          ccid, comment, output_dir,
                          executable_path='zowe', stagenum='1', search=False, cachetime=None):

    if cachetime is None or not os.path.exists(destination) or \
            check_file_older_than(destination, int(time.time()) - cachetime):
        tmpoutput = tmpfile_to(output_dir, 'download', elementname, elemtype)
        cmd = [executable_path, "endevor", 'view', 'element', elementname,
               '--endevor-profile', profile,
               '--env', env,
               '--sys', sys,
               '--sub', subsystem,
               '--type', elemtype,
               '--ccid', ccid,
               '--search', 'true' if search else 'false',
               '--comment', comment,
               '--sm', 'true',
               '--tf', str(destination),
               '-i', region,
               '--fn', tmpoutput.name,
               # this is needed even with search=true ¯\_(ツ)_/¯
               '--sn', stagenum]

        proc = run_cmd(cmd)
    else:
        logging.info("skipping download of %s", destination)
        pass


def check_file_older_than(path, time_in_s):
    return int(os.path.getmtime(path)) < time_in_s


# this retrieves an element from endevor and writes it to a file in the current directory named {elementname}
# this will result in the element being signed out to you if you don't already have it signed out
def retrieve_element(elementname, elemtype, context):
    retrieve_element_full(elementname, elemtype,
                          context.zowe('profile'),
                          context.zowe('env'),
                          context.zowe('system_name'),
                          context.zowe('subsystem'),
                          context.zowe('region'),
                          context.zowe('ccid'),
                          context.zowe('output_dir'),
                          executable_path=context.zowe('executable_path'),
                          signoutmode=context.zowe('signout_mode'))


def retrieve_element_full(elementname, elemtype, profile, env, sys, subsystem, region, ccid, output_dir,
                          executable_path='zowe', search=False, stagenum='1', signoutmode=SIGNOUT_IGNORE):
    tmpoutput = tmpfile_to(output_dir, 'retrelem', elementname, elemtype)
    cmd = [executable_path, "endevor", 'retrieve', 'element', elementname,
           '--endevor-profile', profile,
           '--env', env,
           '--sys', sys,
           '--sub', subsystem,
           '--type', elemtype,
           '--ccid', ccid,
           '--search', 'true' if search else 'false',
           '--comment', 'retrieve element',
           '--sm', 'true',
           '--sn', stagenum,
           '--tf', elementname,
           '-i', region,
           '--fn', tmpoutput.name]

    if signoutmode == SIGNOUT_OVERRIDE:
        cmd.append('--os')
    elif signoutmode == SIGNOUT_NO:
        cmd.append('--nsign')

    proc = run_cmd(cmd)


# this will list where the element exists in the Endevor map...multiple results are possible, so handle
# that case in calling code, if necessary
def list_element(elementname, elemtype, context):
    return list_element_full(elementname, elemtype,
                             context.zowe('profile'),
                             context.zowe('env'), context.zowe('system_name'), context.zowe('subsystem'),
                             context.zowe('region'),
                             context.zowe('output_dir'),
                             executable_path=context.zowe('executable_path'),
                             search=True)


# this will list where the element exists in the Endevor map...multiple results are possible, so handle
# that case in calling code, if necessary
def list_element_full(elementname, elemtype, profile, env, system_name, subsystem, region, output_dir,
                      executable_path='zowe', search=True, stagenum='1'):
    tmpoutput = tmpfile_to(output_dir, 'listelem', elementname, elemtype)
    cmd = [executable_path, "endevor", 'list', 'elements', elementname,
           '--endevor-profile', profile,
           '--env', env,
           '--sys', system_name,
           '--sub', subsystem,
           '--type', elemtype,
           '--search', 'true' if search else 'false',
           '--sm', 'true',
           '-i', region,
           '--fn', tmpoutput.name,
           # this is needed even with search=true ¯\_(ツ)_/¯
           '--sn', stagenum]

    proc = run_cmd(cmd)
    logging.debug('processing ENDV listelement output')
    elems = []
    bad_output = False
    for line in proc.stdout.split('\n'):
        logging.debug("LISTOUTPUT: %s", line)
        if line == '':
            logging.debug("skipping empty line")
        elif 'no matching element found' in line.lower():
            logging.debug("no elements found")
            break
        else:
            tokens = line.split()
            if len(tokens) == 6:
                ename, etype, env, stage, sys, subsys = tokens
                elemdict = {'name': ename, 'type': etype, 'env': env, 'stage': stage, 'system': sys, 'subsystem': subsys}
                logging.debug('found element %s', elemdict)
                elems.append(elemdict)
            else:
                logging.debug("unexpected output from list command")
                bad_output = bad_output | True

    if bad_output:
        logging.warning("unexpected output from the list command. run with DEBUG logging for more details")

    return elems


def zowe_executable(context):
    return context.zowe('executable_path') if context.zowe('executable_path') else "zowe"


def tmpfile(context, action, ename, etype):
    return tmpfile_to(context.zowe('output_dir'), action, ename, etype)


def tmpfile_to(output_dir, action, ename, etype):
    if ename == '*':
        ename = 'all'
    if etype == '*':
        etype = 'all'
    return NamedTemporaryFile(dir=output_dir,
                              prefix='%s_%s_%s' % (ename, etype, action),
                              suffix='.txt',
                              delete=False)


def run_cmd(cmd, capture=True, check=True):
    return subprocess.run(cmd, capture_output=capture, encoding='UTF-8', check=check)
