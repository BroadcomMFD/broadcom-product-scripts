# Broadcom TSS CHECKSTC REXX Scripts
CHECKSTC REXX provides the capability to interactively identify defined Started Tasks without valid ACIDs on the system.  Additionally, the REXX will build all the TSS commands to remove those STC entries with invalid ACIDs (ACIDs not defined to TSS on that specific system). This REXX is an example of the “art of the possible” in using REXX with TSS. 

The challenge:  Provide an automated method for reviewing the STC Table and identifying STC entries defined with invalid ACIDs.

Background:  Reviewing and validating the STC Table is a completely manual process. Depending on how many STC table entries are on your system, this could save you hours of manual labor when validating STC entries to current defined ACIDs.    

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the CHECKSTC.rexx.txt as CHECKSTC into your CLIST/REXX library.
2.	Execute:  TSO CHECKSTC    (please be patient, as CHECKSTC does take a couple of minutes to run, depending upon the number of entries defined in the STC Table.)          
3.	Once completed, review the output.  If ready to clean up those STC entries with undefined ACIDs, copy your TSS batch JCL to the top and submit.   
 
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
