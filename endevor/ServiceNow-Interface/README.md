# ServiceNow interface to Endevor

Items in this folder show example Endevor exit code that interfaces with ServiceNow. This interface assumes that the automated activity begins in Endevor. These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

An alternative interface begins with ServiceNow, and allows actions in ServiceNow to automate package actions in Endevor. See these sites for more details:

- [Endevor Package Integration with ServiceNow
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-5302c7d3780a)

- [Endevor Package Integration with ServiceNow, Part 2
](https://medium.com/modern-mainframe/endevor-package-integration-with-servicenow-part-2-e982e92b3214
)

This folder contains Endevor exit code examples that causes Endevor activity to reach out to ServiceNow. Each function uses a COBOL exit, a REXX subroutine and a Python subroutine. Functions include:
- Exit 2. Before element action exit code to validate a CCID value with ServiceNow (C1UEXT02 / C1UEXTR2 / ServiceNow.py)
- Exit 7. Package exit code to validate (a portion of) a package namee with ServiceNow. (C1UEXT07 / C1UEXTR7 / ServiceNow.py)

Processing starts with an Endevor action. Endevor then calls an example COBOL exit. The COBOL examples show how you can collect exit block information and pass it to a REXX subroutine. Rexx then calls the same example python code.

Both REXX examples contain code that allows on-demand REXX tracing to be automatically invoked. Simply allocate the name of the REXX program to DUMMY. For example, to engage the Trace for C1UEXTR2, then allocate C1UEXTR2 to DUMMY. There are two ways to do the allocation:

- In TSO forground, enter "TSO ALLLOC F(C1UEXTR2) DUMMY"
- In batch, include a JCL line  "//C1UEXTR2  DD DUMMY"
