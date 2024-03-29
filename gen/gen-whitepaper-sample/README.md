# Gen DevOps Story Sample Scripts

## Overview

As part of our commitment to integration between Gen and standard DevOps tools, we are providing sample code
alongside a [white paper](https://community.broadcom.com/mainframesoftware/communities/community-home/digestviewer/viewthread?GroupId=1513&MessageKey=7a3ba595-6432-48aa-93f4-f18206875d72&CommunityKey=4182c217-4789-4997-8f22-87de25983f6e&tab=digestviewer) describing a streamlined Gen developer workflow. These scripts are intended to illustrate the
integration opportunities that are already present with your Gen installation. There are no requirements to install
new Gen components to utilize functionality in these scripts.

You will need to have an Endevor SCM installation, and you must be able to access the installation through the [Endevor SCM plugin for Zowe CLI](https://www.npmjs.com/package/@broadcom/endevor-for-zowe-cli). The details of setting this up will not be detailed here, and you should consult with
your Endevor administrator, or the Endevor product documentation for details on what is required to install and
configuration those components.

## Looking for help?

If you are having any trouble getting started with the scripts or running them, please
[create an issue](https://github.com/BroadcomMFD/zowe-cli-broadcom-product-scripts/issues) in this project.

## Set up

### Python

You must have a valid Python 3 installation on the machine where the scripts execute. You can find instructions for how
to install Python on your platform of choice by visiting [Python downloads](https://www.python.org/downloads). There are also many resources
available online that detail how to install Python on different platforms.

Once Python is installed, you must download the PyYAML module using pip (<code>pip install PyYAML</code>). This can
either be done on a global level, or utilizing a [virtual environment](https://docs.python.org/3/library/venv.html).

### Zowe

You must have a valid installation of the Zowe CLI. The recommended approach is to use a supported environment, like [CA
Brightside](https://www.broadcom.com/products/mainframe/application-development/brightside). This takes out much of the
guesswork and trial-and-error that can sometimes accompany installing and configuring open source tools.

However, the only requirements for the scripts to run correctly are to have a valid [Zowe CLI](https://www.npmjs.com/package/@zowe/cli) with the [Endevor SCM for
Zowe CLI plugin](https://www.npmjs.com/package/@broadcom/endevor-for-zowe-cli) installed and correctly configured.

## Configuration

### Zowe Profiles

You must create a profile of type endevor-profile that points to the Endevor web service configured for your
environment. The types of information required for an endevor-profile are things like host, port, protocol, etc. Be sure
to remember the name because it is a required configuration parameter for the Python scripts.

### Python scripts

The Python scripts currently require a configuration file in YAML format. There is a sample YAML configuration script
provided in the <code>resources</code> directory. You should make a copy of the sample.yml file and tailor the values to
match your environment and preferences. The config file has inline comments describing the function of the variables,
but many of them are self-explanatory.

## Running the scripts

How you run the scripts will depend on the platform that you choose. The scripts are meant to be invoked from a CLI, but
you can use whatever terminal application you desire on your platform. To view the usage help for the scripts you can
execute one of the following commands from your terminal:
<code>./process-remote-file.py --help</code> on *nix platforms and <code>python3 process-remote-file.py --help</code>
on Windows.

The usage help details all the available command-line arguments and what values are appropriate. Before running the
scripts, make sure you take a look at the usage help.
