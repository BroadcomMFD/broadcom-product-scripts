# COBOL+REXX+Python-Example

## What is in this folder
Items in this folder are example Endevor objects for interfacing with ServiceNow. This interface assumes that the automated activity begins in Endevor. 


As a first step, you might want to test your python access to ServiceNow. You can use the BatchQuery.jcl and BatchQuery.rex items. Place the rexx program into a library named YOURSITE.NDVR.TEAM.REXX(SNOWQERY), for example. Place the Python onto a USS directory, matching the directory location in the REXX, and then submit the JCL.  

Other items in this folder are Endevor exit code examples that query ServiceNow. Endevor functions listed below, each use a COBOL exit, a REXX subroutine and a Python subroutine. Functions include:
- **Exit 2**. Before element action exit code to validate a CCID value with ServiceNow (C1UEXT02 / C1UEXTR2 / ServiceNow.py)
- **Exit 7**. Package exit code to validate (a portion of) a package namee with ServiceNow. (C1UEXT07 / C1UEXTR7 / ServiceNow.py)

REXX examples contain code that allows on-demand REXX tracing to be invoked - without modifying the REXX code. Simply allocate the name of the REXX program to DUMMY. For example, to engage the Trace for C1UEXTR2, then allocate C1UEXTR2 to DUMMY. There are two ways to do the allocation:

- In TSO forground, enter "TSO ALLLOC F(C1UEXTR2) DUMMY"
- In batch, include a JCL line  "//C1UEXTR2  DD DUMMY"

