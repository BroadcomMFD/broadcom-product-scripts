# COBOL+REXX+WebEnablementToolki

## Overview


Open each folder to find additional details for each approach.

Other items in this folder are Endevor exit code examples that query ServiceNow. Endevor functions listed below, each use a COBOL exit, a REXX subroutine and a Python subroutine. Functions include:
- **C1X2CUST.cob**. Before element action exit code to validate a CCID value with ServiceNow 
- **C1X7CUST.cob**. Package exit code to validate (a portion of) a package namee with ServiceNow. 

Processing starts with an Endevor action, such as an element Generate or a package create. Endevor then calls a COBOL exit. The COBOL examples collect exit block information from Endevor and pass it to a REXX subroutine. Rexx then calls the python code to query ServiceNow. The results of the query return as a JSON string, which is visible to both the Python and REXX.


**SNOWCustomer.rex** is to be placed in the REXX library identified in the COBOL exit program. It uses BPXBATCH to call *CUST_ndvrsnow.rex** on USS.

> cmd  = 'SH /u/users/ibmuser/rexx/CUST_ndvrsnow.rexx'                            


**CUST_ndvrsnow.rex** is to be placed onto a USS directory.