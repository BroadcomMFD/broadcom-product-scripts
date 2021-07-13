# Copyright © 2021 Broadcom

import argparse
import yaml
import getpass
from sys import stdin


class Context:
    """A base class to parse config and hold all the context info for our scripts"""

    def __init__(self, initial_values=None):
        if initial_values is None:
            initial_values = {}
        self.config_defaults = {
            'zowe': {
                'system_name': "SAMPMDL",
                'sandbox_input': "sandbox.txt",
                'profile': "endevortest",
                'subsystem': "$UNDEF",
                'ccid': "ENDVTEST",
                'region': "WEBSMFSO",
                'sql_skeleton': "SMPCBSQL",
                'dynamic_isps': "SMPCDYNC",
                'cobol_pg': "LEMBXC5",
                'coboldb2_pg': "LEMB2C5",
                'linkPG': "L2",
                'noprocPG': "*NOPROC*"
            },
            'inputfiles': {
                'dialogrmtfile': "MENU.rmt",
                'cascadermtfile': "CASCADE.rmt"
            }
        }
        self.parser = None
        self.vals = {**self.config_defaults, **initial_values}

    def merge_params(self, override_dict):
        self.vals = {**self.vals, **override_dict}

    def get(self, key):
        return self.vals[key]

    def prepare_argparser(self):
        self.parser = argparse.ArgumentParser(description='default argparser')
        return self.parser

    def post_process(self):
        if 'executable_path' not in self.vals['zowe']:
            self.vals['zowe']['executable_path'] = 'zowe'

    def gather_params(self, prompt_pass=True):

        if self.parser is None:
            self.prepare_argparser()

        args = self.parser.parse_args()

        if args.config:
            with open(args.config) as yamlfile:
                appconfig = yaml.load(yamlfile, Loader=yaml.SafeLoader)
                self.merge_params(appconfig)

        self.merge_params(vars(args))

        self.gather_params_internal(args)

        if prompt_pass and self.vals['zowe_prompt_pass']:
            self.vals['zowe']['pass'] = getpass.getpass() if stdin.isatty() else input()

        if self.vals.get('zowe_user'):
            self.vals['zowe']['user'] = self.vals.get('zowe_user')

        if 'ccidval' in self.vals['zowe'] and self.vals['zowe']['ccidval']:
            self.vals['zowe']['ccid'] = self.vals['zowe']['ccidval']

        if args.ccid:
            self.vals['zowe']['ccid'] = args.ccid

        if 'comment' not in self.vals['zowe'] or not self.vals['zowe']['comment']:
            self.vals['zowe']['comment'] = args.comment

        self.post_process()
        # we don't really need the parser after this and without it we don't run into pickle problems
        self.parser = None

    def gather_params_internal(self, args):
        pass

    def zowe(self, key):
        return self.vals['zowe'].get(key)


class IcmParserContext(Context):
    """Class that parses config and acts a central context for all configuration data for the ICM processing script"""

    def prepare_argparser(self):
        self.parser = argparse.ArgumentParser(description='update Gen COBOL files in Endevor')
        self.parser.add_argument('-c', '--config', help='path to YAML config file', default='resources/sample.yml')
        self.parser.add_argument('--rmt-dialogmgr', dest='dialogmgr', help='the path to the dialog manager remote file')
        self.parser.add_argument('--rmt-cascade', dest='cascade', help='the path to the RI triggers remote file')
        self.parser.add_argument('-l', '--log', help='set the log level DEBUG|INFO|WARNING|ERROR', default='INFO')
        self.parser.add_argument('--log-file', help='the name of the file to log to or STDOUT to log to STDOUT',
                                 default='run.log')

        self.parser.add_argument('--zowe-user', help='the username for zowe cli, if needed', dest='zowe_user')
        self.parser.add_argument('--prompt-pass', help='script should prompt for zowe password',
                                 dest="zowe_prompt_pass", action="store_true")

        self.parser.add_argument('-n', '--dry-run', help='go through all processing, but no permanent changes',
                                 action='store_true', default=False)

        upload_group = self.parser.add_mutually_exclusive_group(required=False)
        upload_group.add_argument('-s', '--no-upload', help='skip uploading files to Endevor',
                                  dest='do_upload', action='store_false')
        upload_group.add_argument('-u', '--upload', help='proceed with upload to Endevor',
                                  dest='do_upload', action='store_true')

        diff_group = self.parser.add_mutually_exclusive_group(required=False)
        diff_group.add_argument('-k', '--no-diff', help='skip semantic diff',
                                  dest='do_diff', action='store_false')
        diff_group.add_argument('-d', '--diff', help='proceed with semantic diff',
                                  dest='do_diff', action='store_true')

        self.parser.add_argument('-i', '--ccid', help='CCID to use for all Endevor commands', default=None)
        self.parser.add_argument('-m', '--comment', help='comment to use for all Endevor commands',
                                 default='No Comment')

        self.parser.set_defaults(do_upload=True, do_diff=False, zowe_prompt_pass=False)
        return self.parser

    def gather_params_internal(self, args):
        if args.dialogmgr:
            self.vals['inputfiles']['dialogrmtfile'] = args.dialogmgr
        if args.cascade:
            self.vals['inputfiles']['cascadermtfile'] = args.cascade

    def post_process(self):
        super().post_process()

        padding = self.vals['linkedit']['pad_each_with'] if 'pad_each_with' in self.vals['linkedit'] else None
        if padding:
            for key in self.vals['linkedit']:
                if key != 'pad_each_with':
                    self.vals['linkedit'][key] = padding + self.vals['linkedit'][key]


class SandboxContext(Context):
    """Class that parses config and acts a central context for all configuration data for the sandbox script"""
    def prepare_argparser(self):
        self.parser = argparse.ArgumentParser(description='manage sandboxes in Endevor')

        self.parser.add_argument("sandbox", help="the name of the sandbox to create")

        action_group = self.parser.add_argument_group("action", "which type of action to perform (only use one)")
        action_group.add_argument('-cr', '--create',
                                  help='create a new sandbox',
                                  dest='command',
                                  action='store_const', const='create')
        action_group.add_argument('-dl', '--delete',
                                  help='remove all elements from and then delete a sandbox',
                                  dest='command',
                                  action='store_const', const='delete')
        action_group.add_argument('-e', '--empty',
                                  help='remove all elements from a sandbox (stage 1,2)',
                                  dest='command',
                                  action='store_const', const='empty')

        self.parser.add_argument('-l', '--log', help='set the log level DEBUG|INFO|WARNING|ERROR', default='INFO')
        self.parser.add_argument('--log-file', help='the name of the file to log to or STDOUT to log to STDOUT',
                                 default='run.log')
        self.parser.add_argument('-c', '--config', help='path to YAML config file', default='resources/sample.yml')
        self.parser.add_argument('--zowe-user', help='the username for zowe cli, if needed', dest='zowe_user')
        self.parser.add_argument('--prompt-pass', help='script should prompt for zowe password',
                                 dest="zowe_prompt_pass", action="store_true")
        self.parser.add_argument('-i', '--ccid', help='CCID to use for all Endevor commands', default=None)
        self.parser.add_argument('-m', '--comment', help='comment to use for all Endevor commands',
                                 default='No Comment')

        self.parser.set_defaults(zowe_prompt_pass=False, command='create')
        return self.parser
