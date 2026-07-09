# Broadcom Cleanup Interactive ETCL REXX Script
ETCL – ETCL – Provides the ability to interactively obtain Cleanup reports in real-time without submitting JCL. This REXX takes the argument in, dynamically allocates all required datasets, executes the calls to the Cleanup program with the provided inputs, places the output into a dynamically allocated dataset, places the security professional into edit mode within the output dataset, allows PF7/8 scrolling as well as searching within the output.  Additionally, when there is a "SUMMARY" report, it will be attached to the bottom of the output provided.  The REXX and panels are provided as an example of the "Art of the possible" and added value for our CLEANUP clients.

The challenge:  Many times, as a Mainframe Cybersecurity Professional, you may have the need to create a Cleanup report for a specific resource rule quickly you are working to clean up to validate when that rule was last used.  If it has not been used since you made the last changes, there is no need to run the Audit/SMF reporting process that would show you who last used the resource rule in question.  Additionally, at times, the professional may need to simply create a Cleanup report to review the last access/usage, or many other use cases may exist where having the ability to interactively generate a cleanup report without having to edit JCL, submit a batch job, wait for the job to complete and then view the output would reduce the cycle time and help with time efficiency.

Background:  Historically the CLEANUP solution was only used via JCL and batch job submission.  Enabling Mainframe Cybersecurity Professionals (MCP) to do more with their limited time daily is a must.  

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the ETCL.rexx.txt as ETCL into your CLIST/REXX library.
2.  Upload ETCL.panels.txt as ETCL into your "Panels" library
3.  Upload ETCLHP01.panels.txt as ETCLHP01 into your "Panels" library
4.  Find and edit the ALTLIB dataset to your CLIST/REXX library dataset name.
5.  Find and Edit the LIBDEF dataset to your PANELS library dataset name.
6.  Find and follow "UPDATE INSTRUCTIONS HERE" and update the SYSID, link_listed and link library name for each system and SAVE.

7.	Execute:  TSO ETCL UNREF=ALL userid or TSO ETCL UNREF=010 userid 
    	Options:  (each of these examples will will create an CLEANUP report (just like in JCL), and places the output into temp dsn allowing PF7/8 scrolling and searching.)

      a.	ETCL UNREF=ALL - this will create an CLEANUP report (just like in JCL), and places the output into temp dsn allowing PF7/8 scrolling and searching.
      b.  ETCL REF=030 userid where "userid is an ACID (TSS), a LID (ACF2), or a userid (RACF).
      c.  ETCL UNREF=ALL INC(CLASS(USERID)NAME(*ALL*)) - this would create an interactive Cleanup report for the ALL Record in TSS.
      d.  ETCL UNREF=ALL INC(CLASS(USERID)NAME(*ALL*)) EXC(CLASS(VOLUME)) - this would create an interactive Cleanup report for the ALL record in TSS, excluding all VOLUME resources.
      d.  ETCL UNREF=ALL INC(CLASS(DSN)NAME(SYS1)) - this would create a Cleanup report showing usage of SYS1 ruleset and rules for ACF2
      e.  ETCL - this will bring up a panel where you can enter in the PARM, any INCLUDE, and any EXCLUDE input.  PF1 in the panel will present a help panel.
    
8.  See all CLEANUP Techdoc articles and options at:  [CLEANUP TECHDOCS](https://techdocs.broadcom.com/us/en/ca-mainframe-software/security/ca-cleanup/12-1.html.html)

# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.

