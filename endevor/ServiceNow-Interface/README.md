# ServiceNow interface to Endevor

## Overview
Items in this folder are objects that serve as examples for interfacing Endevor with ServiceNow. They assume that the automated activity begins in Endevor. 

## An Alternative not Covered Here

An alternative interface, not supported by items in this folder, begins with ServiceNow, and allows actions in ServiceNow to automate package actions in Endevor. See these sites for more details:

- [Endevor Package Integration with ServiceNow
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-5302c7d3780a)

- [Endevor Package Integration with ServiceNow, Part 2
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-part-2-e982e92b3214
)

## What is in this folder

For Endevor to query ServiceNow, there are at least two choices. They give you the opportunity to choose a method most compatible to your skills and site requirements. Two methods are located within sub-folders in this section.

- **COBOL+REXX+WebEnablementToolkit** - contains items that leverage [IBM's Web Enablement Toolkit](https://www.ibm.com/docs/en/zos/3.2.0?topic=languages-zos-client-web-enablement-toolkit), avoiding any dependencies for off-host and Open Source items.

- **COBOL+REXX+PythonOrGolang-Example** - contains items that depend use a simple Python or a GoLang member on USS, instead of using the Web Enablement Toolkit.

Open each folder to find additional details.  

The processing begins with an Endevor action, such as generating an element or creating a package. These actions trigger an Endevor-engaged COBOL exit. The COBOL examples gather exit block information from Endevor and transmit it to a REXX subroutine. The COBOL exits are expected to remain static. Ultimately, REXX, Python, or GoLang will perform the query to ServiceNow. The query's response is a JSON string, which can then be further examined as required.
