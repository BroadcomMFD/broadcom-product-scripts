# Broadcom ACF2 AE REXX Script
AE – Viewing/Editing/Updating ACF2 Dataset and Resource Rulesets quickly and interactively.

The challenge:  Use the ACF2 utilities and REXX to create an interactive, quick capability that decompiles the ruleset into a temporary dataset, places the ACF2 cybersecurity professional into ISPF Edit, and provides the ability to review, scroll, search, or change the ruleset as desired.  The REXX checks for any changes made when you press PF3 or Exit; if changed, the REXX will then compile and store, and present the results back to the screen for review.  If successful, when the ACF2 cybersecurity professional presses PF3 or Exit, the REXX will then issue the appropriate REBUILD or RELOAD command as needed.

Background:  ACF2 professionals often list out the complete ruleset before issuing RECKEY commands, or they decompile the rules into a PDS, edit the PDS making the change, and then manually issue more ACF2 commands to recompile/store the updated ruleset and then issue an F ACF2,rebuild/reload command.  The process is manually intensive with multiple commands having to be all typed out and entered.  

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the AE.rexx.txt as AE into your CLIST/REXX library.
2.	Upload the XACF750.txt, a required ISPF Macro, into your CLIST/REXX library.
3.	Execute:  TSO AE D $key to edit a dataset ruleset.
4.	Execute:  TSO AE R class $key to edit a resource ruleset.  

Examples:  
1. TSO AE D SYS1    - This would allow you to immediately edit the SYS1 dataset ruleset, review, search, or modify as desired.
2. TSO AE R FAC BPX - This would immediately decompile the ruleset into a temp dataset and place you into ISPF Edit mode, allowing you to edit or review any existing resource rulesets.

If you have edited the displayed content, when you are done and PRESS PF3 or Exit, the REXX will compile and store the updated ruleset, providing back to you with the results of that step for your review.  After your review, Press PF3 or Exit and the REXX will issue the appropriate F ACF2,rebuild/reload command for you. 
   
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
