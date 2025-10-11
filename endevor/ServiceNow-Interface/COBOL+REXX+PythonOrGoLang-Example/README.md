# ServiceNow interface to Endevor

## Overview
Items in this folder are example Endevor objects for interfacing with ServiceNow. This interface assumes that the manual activity that triggers automated actions begins in Endevor, Quick-Edit, Code4Z or zowe. 

Processing starts with an Endevor action, such as an element Generate or a package create. Endevor calls one of the COBOL exits. The COBOL exit collects Endevor exit block information and passes it to a REXX subroutine. Rexx then calls the python code or GoLang code to query ServiceNow. The results of the query return as a JSON string, visible to both the Python or GoLang and REXX.

Details for Endevor Exit actions can be found [here](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/reference/api-and-user-exits-reference/exits-reference.html).     
Note that Endevor supports "exits that are written in either assembler or in high-level languages such as COBOL". The exits provided in this folder are written in COBOL, but there is no requirement for implementers or users to have knowledge of COBOL. All processing logic for this solution is coded in the Rexx, and the Python or Golang subroutines.

## Where to start
If you have not yet loaded the Python "requests" package, make that be your first step. If you are not sure whether the "requests" package is installed, you can use this step to find out.

If you have already installed the "request" package and it is found in the search path, then comment out the sys.path line in the python. For example:

        # Name the directory where the 'requests' are found
        # sys.path.append('/usslocation/forpython/uptoNotIncludingrequests')

Test your python or GoLang access to ServiceNow. For example, copy the Python code into a USS directory and using OMVS, issue a command like this one: 

    python Servicenow.py CHG1234567

Resulting messages will tell you whether you have successfully connected.

## Installing the "requests" package

If you know that the python "request" package has not been installed, or if you receive a message indicating that it cannot be found, then execute these steps:

- On USS issue this command:

        python -m pip install requests                   
- Within the python code enter the name of the uss directory that contains the "requests" folder, for example:

        sys.path.append('/usslocation/forpython/uptoNotIncludingrequests')

## Other items in the Folder

Other items in this folder are Endevor exit code examples that query ServiceNow. Endevor functions listed below, each use a COBOL exit, a REXX subroutine and a Python subroutine. Functions include:
- **Exit 2**. Before element action exit code to validate a CCID value with ServiceNow. 
- **Exit 7**. Package exit code to validate (a portion of) a package namee with ServiceNow. 
- **C1UEXTR2** and **C1UEXTR7** are Rexx subroutines to the COBOL exit programs. The C1UEXTR2 module is coded to not call the SERVINOW subroutine when the requested CCID already exists on an element. So for example, Update and MOVE actions might find the requested CCID value already on the element and bypass the validation.    
- **SERVINOW** is a REXX subroutine to both C1UEXTR2 and C1UEXTR7 and is the member that calls the Python code to validate a 10-byte value with ServiceNow.


REXX examples contain code that allows on-demand REXX tracing to be invoked - without modifying the REXX code. The examples allow you to limit the tracing to a list of userids. You can create your own list of userids or eliminate it altogether. Then, simply allocate the name of the REXX program to DUMMY. For example, to engage the Trace for C1UEXTR2, then allocate C1UEXTR2 to DUMMY. There are two ways to do the allocation:

- In TSO forground, enter "TSO ALLLOC F(C1UEXTR2) DUMMY"
- In batch, include a JCL line  "//C1UEXTR2  DD DUMMY"
