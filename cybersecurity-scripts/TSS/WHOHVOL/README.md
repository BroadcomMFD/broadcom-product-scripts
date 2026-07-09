# Broadcom TSS WHOHVOL REXX Script
WHOHVOL REXX can interactively identify, using a single command, who has access to all owned VOLUME resources within TSS. This REXX is an example of the “art of the possible” in using REXX with TSS. 

The challenge:  Provide a simpler method for reviewing who has VOLUME resource access based on all volume resources owned.

Background:  Previously, to review all Volume access, the mainframe cybersecurity professional needed to manually perform the following steps: (1) List all volume ownership - TSS WHOOWNS VOL(*), (2) Manually build all of the TSS WHOHAS VOLUME(xxxxxx) commands, and (3) Submit as a batch job and review the output.  TSO WHOHVOL performs those steps interactively and provides the resulting report into a temporary dataset, placing the professional into edit mode and allowing for them to copy/paste/create or process as desired.    

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the WHOHVOL.rexx.txt as WHOHVOL into your CLIST/REXX library.
2.	Execute:  TSO WHOHVOL          
3.	WHOHVOL only takes a few seconds to complete and produce the report for your review.   
 
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
