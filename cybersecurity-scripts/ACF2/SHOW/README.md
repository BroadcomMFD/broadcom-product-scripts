# Broadcom ACF2 SHOW REXX Script
SHOW – reduces the amount of typing for a very common function. This REXX takes the argument in, executes the ACF2 SHOW subcommand based upon the input, then places the output into a dynamically named temp dataset, and places the user into either ISPF browse or edit mode.  Instead of submiting a batch job to obtain a long output of SHOW subcommand, use the SHOW rexx script for a more interactive experience and reduce required time from listing to viewing output.  This rexx is an example of the “art of the possible” in using the newer ACF2 ACFUNIX utility.

The challenge:  Reduce the sheer volume professionals must type daily while performing their required tasks/functions.

Background:  ACF2 SHOW subcommand can be used via execute ACF, then once in ACF, issue the SHOW subcommand, and the output is displayed with no means to scroll or search within the records displayed.  Enabling Mainframe Cybersecurity Professionals (MCP) to do more with their limited time daily is a must.  SHOW provides the ability to quickly and interactively obtain the SHOW subcommand output, place the output into a temp dataset, place the cybersecurity professional into Browse, and allow them to scroll (PF7/8) or search as desired. TSO  SHOW can be executed anywhere within TSO.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the SHOW.rexx.txt as SHOW into your CLIST/REXX library.
2.	Execute:  TSO SHOW ALL or any SHOW argument anywhere in TSO.
3.	Options:
    a.	SHOW ALL – this will execute the ACF2 LI lid command
    b.	SHOW CLasmap - Displays the internal (ACF2-defined) and external (site-defined) CLASMAP records.
    c.	SHOW SAFDEF - Displays the SAFDEF records that are defined on your system.
    d.	SHOW PSwsopts - Displays the ACF2 system options that are related to password and password phrase policy.
    e.  See all SHOW subcommand options at:  [ACF2 Show subcommand Techdocs](https://techdocs.broadcom.com/us/en/ca-mainframe-software/security/ca-acf2-for-z-os/16-0/command-reference/acf-subcommands/show-subcommand-all-other-settings.html)
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.

