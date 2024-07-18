# Broadcom TSS TS and TSE REXX Scripts
TS and TSE REXX scripts provide the capability to interactively use TSS commands, capture the output, and display the output in a temporary dataset, allowing PF7/8 scrolling. TS places the user in ISPF Browse mode to view, while TSE places the user in ISPF Edit mode. This REXX is an example of the “art of the possible” in using REXX with TSS. 

The challenge is to have more interactive capability with TSS commands and reduce the need to submit many batch jobs to generate longer TSS command output.  TS and TSE also allow nested lists or nest TSS commands regardless if in split screen mode or not by dynamically generating both the DD Name and the dataset name used for the output.   

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the TS.rexx.txt as TS into your CLIST/REXX library.
2.	Upload the TSE.rexx.txt as TSE into your CLIST/REXX library.
3.	Execute: Any TSS command, just use TS or TSE instead of TSS.
    TSO TS cmd where "cmd" is any TSS command such as:
    TSO TS MODIFY
  	TSO TS LIST(STC)
  	TSO TS WHOHAS DSN(SYS1.)
5.  FOR TSE, same examples as #3, any TSS command will provide the same output, just placing the user into Edit mode.  Some have reasons to copy/paste the output, edit or otherwise as needed. 
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
