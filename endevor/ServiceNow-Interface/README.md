# ServiceNow interface to Endevor

Items in this folder show example Endevor exit code that interfaces with ServiceNow.

Example exit code includes:
- Exit 2. Before element action exit code to validate a CCID value with ServiceNow
- Exit 7. Package exit code to validate (a portion of) a package namee with ServiceNow.

In both cases, exit program flow starts with Endevor, which calls an example COBOL exit. The COBOL examples show how you can collect exit block information and pass it to a REXX subroutine. Rexx then calls the same example python code.

COBOL Copybooks NOTIFYDS  and PKGXBLKS 

All REXX examples contain code that allows the REXX trace to be automatically invoked. Simply allocate the name of the REXX program to DUMMY. For example, to engage the Trace for C1UEXTR2, then allocate C1UEXTR2 to DUMMY. There are two ways to do the allocation:

- In TSO forground, enter "TSO ALLLOC F(C1UEXTR2) DUMMY"
- In batch, include a JCL line  "//C1UEXTR2  DD DUMMY"
