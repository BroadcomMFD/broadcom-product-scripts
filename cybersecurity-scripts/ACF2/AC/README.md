# Broadcom ACF2 SHOW REXX Script
AC – reduces the amount of typing for a very common function. This REXX takes the argument in, executes the ACF2 ACCESS subcommand based upon the input , then places the output into a dynamically named temp dataset, and places the user into either ISPF browse or edit mode.  Instead of submiting a batch job to obtain a long output of SHOW subcommand, use the SHOW rexx script for a more interactive experience and reduce required time from listing to viewing output.  This rexx is an example of the “art of the possible” in using the newer ACF2 ACFUNIX utility.

The challenge:  Reduce the sheer volume professionals must type daily while performing their required tasks/functions.

Background:  ACF2 ACCESS subcommand can be used via execute ACF, then once in ACF, issue the ACCESS subcommand, and the output is displayed with no means to scoll or search within the records displayed.  Enabling Mainframe Cybersecurity Professionals (MCP) to do more with their limited time daily is a must.  LI provides the ability to quickly list a LID, place the output into a temp dataset, place the cybersecurity professional into Browse, and allow them to scroll or search as desired. TSO ALI lid can be executed anywhere within TSO.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the AC.rexx.txt as AC into your CLIST/REXX library.
2.	Execute:  TSO AC DSN('SYS1.PARMLIB') or any ACF2 ACCESS command anywhere in TSO like: TSO AC RESOURCE('BPX.FILEATTR.APF') TYPE(FAC) CLASS(R)  
3.	Options:
    a.	AC DSN('SYS1.PARMLIB') – this will execute the ACF2 ACCESS subcommand:  ACCESS DSN('SYS1.PARMLIB'), placing output into temp dsn, allowing PF7/8 scrolling and searching.
    b.	Another example - AC RESOURCE('BPX.FILEATTR.APF') TYPE(FAC) CLASS(R)  

  	Format: 
    AC   DSNAME('DSNAME')                    
         RESOURCE('RESOURCE')                
         TYPE(TYPE) CLASS(CLASS) SYSID(SYSID)
    
    c.  See all ACF2 ACCESS subcommand options at:  [ACF2 ACCESS subcommand Techdocs](https://techdocs.broadcom.com/us/en/ca-mainframe-software/security/ca-acf2-for-z-os/16-0/command-reference/acf-subcommands/access-subcommand.html)
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.

