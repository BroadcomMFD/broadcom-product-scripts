# Web Viewer 14 - Administrator Tools

This directory contains several examples CLI scripts designed for use by Web Viewer 14
administrators.

## Software Requirements

All the included scripts have been designed to be compatible with the following platforms:

- Linux
- Windows using Git Bash.
  Tested with Git for Windows 2.43.0: https://git-scm.com/download/win
- macOS with GNU Bash 5, GNU date, and GNU grep installed.
  These prerequisites can be installed for example using Homebrew, see:
    - https://formulae.brew.sh/formula/bash
    - https://formulae.brew.sh/formula/coreutils
    - https://formulae.brew.sh/formula/grep

Additionally, Zowe CLI and the View plug-in are required for the following scripts:

- `check-servers.sh`
- `find-small-reports.sh`

## Configuration

The example scripts are designed to act upon any number of Web Viewer 14 instances in your
deployment. Before executing any script you must define them in the `servers.txt` file.
The file contains embedded help describing its syntax along with examples.

## Scripts Overview

To get detailed usage help for each script run them with the `--help` argument.

### Check Servers

The `check-servers.sh` script allows you to quickly query the current status of all the
servers in your deployment and lists the following status information for each:
- current product version
- sysplex and lpar name
- started task name and jobid

Optionally the script can also list all the currently defined repositories for each online server.

### Set Login Notifications

The `set-login-notifications.sh` script allows you to easily update the login notification, that is
displayed to users during login, across all the servers in your deployment.

You can include any of the following in the notification content:

- One or more static texts, formatted using [Markdown](https://commonmark.org/help/).
- A dynamically generated directory of all servers with hyperlinks. The directory can also contain
  basic server status information (online/offline).
- Timestamp with the last update time.

Examples of some static content are available in the [examples](examples) directory.

### Find Small Reports

The `find-small-reports.sh` script allows you to search for reports that are shorter, in number of
lines, than a specified threshold. This can be useful in identifying unused business report jobs
that only contain headers/footers and could be decomissioned.
