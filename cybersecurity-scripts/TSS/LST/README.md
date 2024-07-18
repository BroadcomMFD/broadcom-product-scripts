# Broadcom TSS LST REXX Scripts
LST REXX script provides the capability to interactively use TSS commands, reduce typing for very common TSS LIST command, capture the output, and display the output in a temporary dataset, allowing PF7/8 scrolling. LST places the user into ISPF Browse mode to view. This REXX is an example of the “art of the possible” in using REXX with TSS. 

The challenge is to have more interactive capability with TSS commands, reduce the amount of typing, and reduce the need to submit many batch jobs to generate longer TSS command output.  DD Name and Dataset Name are dynamically generated to allow nested list commands regardless if in split screen mode or not.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the LST.rexx.txt as LST into your CLIST/REXX library.
3.	Execute: LST acid where "acid" is any ACID or table defined in TSS, placing the output into a temporary dataset, allowing PF7/8 scrolling or searching.  PF3 to exit.
    LST acid will issue TSS LIST(acid)DATA(ALL)
  	LST STC will list the STC Table
  	LST RDT will list the RDT Table
    Options:
  	    LST acid PROF will issue TSS LIST(acid)DATA(ALL,PROFILE)
  	    LST acid PASS will issue TSS LIST(acid)DATA(ALL,PASSWORD)
4.  This can be used anywhere in TSO:  TSO LST acid 
