# ServiceNow interface to Endevor

## Overview
Items in this folder are objects that serve as examples for interfacing Endevor with ServiceNow. This interface assumes that the automated activity begins in Endevor. 

## An Alternative not Covered Here

An alternative interface, not supported by items in this folder, begins with ServiceNow, and allows actions in ServiceNow to automate package actions in Endevor. See these sites for more details:

- [Endevor Package Integration with ServiceNow
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-5302c7d3780a)

- [Endevor Package Integration with ServiceNow, Part 2
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-part-2-e982e92b3214
)

## What is in this folder

For Endevor to query ServiceNow, there are several choices. They give you the opportunity to choose a method most compatible to your skills and site requirements. Two methods are located within sub-folders in this section.

- **COBOL+REXX+WebEnablementToolkit** - contains items that leverage [IBM's Web Enablement Toolkit](https://www.ibm.com/docs/en/zos/3.1.0?topic=languages-zos-client-web-enablement-toolkit), avoiding any dependencies on off-host and Open Source items.

- **COBOL+REXX+PythonOrGolang-Example** - contains items that depend on a simple Python or a GoLang member, instead of using the Web Enablement Toolkit.

Open each folder to find additional details for each approach. 

Processing starts with an Endevor action, such as an element Generate or a package create. Endevor then calls a COBOL exit. The COBOL examples collect exit block information from Endevor and pass it to a REXX subroutine. Rexx then calls the python code to query ServiceNow. The results of the query return as a JSON string, which is visible to both the Python and REXX.

REXX examples contain code that allows on-demand REXX tracing to be invoked - without modifying the REXX code. Simply allocate the name of the REXX program to DUMMY. For example, to engage the Trace for C1UEXTR2, then allocate C1UEXTR2 to DUMMY. There are two ways to do the allocation:

- In TSO forground, enter "TSO ALLLOC F(C1UEXTR2) DUMMY"
- In batch, include a JCL line  "//C1UEXTR2  DD DUMMY"
