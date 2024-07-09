# Broadcom ACF2 ACFB and ACFE REXX Scripts
ACFB and ACFE  – Provides an alternative to submitting batch jobs for long ACF2 command output, captures the output into a dynamically allocated temporary dataset, places the user into Browse (ACFB) or EDIT (ACFE) mode where the user is able to PF7/8 scroll, search, etc.   Both ACFB and ACFE will process any ACF2 commands, including multiple stacked ACF2 commands. This rexx is an example of the “art of the possible” in using the newer ACF2 ACFUNIX utility.

The challenge:  Provide more interactive interface with ACF2 and reduce the number of batch jobs submitted by an ACF2 professional on a daily basis while performing their required tasks/functions.

Background:  ACF2 command processing is done via the ACF interface, the ACF2 panels, or batch job processing.  ACFB and ACFE REXX scripts can reduce the number of batch jobs submitted for ACF2 commands that generate long output, allowing the ACF2 professional to have a direct interactive experience, processing the ACF2 command in realtime, capturing the output into a dynamically allocated dataset and placing the ACF2 processional into either Browse (ACFB) or Edit (ACFE) mode.  Once the output is displayed, they can use PF7/8 to scroll up/down as well as the TSO Find command or other TSO commands as desired including cut/paste into separate datasets, as desired.  Enabling Mainframe Cybersecurity Professionals (MCP) to do more with their limited daily time is a must.  TSO ACFB or TSO ACFE can be executed anywhere within TSO with the appropriate ACF2 commands used as arguments.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the ACFB.rexx.txt as ACFB and upload ACFE.rexx.txt as ACFE into your CLIST/REXX library.
2.	Execute:  TSO ACFB SHOW ALL, TSO ACFE SHOW ALL or any ACF2 command anywhere in TSO where there is enough room for the complete command.          
3.	Options/Examples: (ACFB OR ACFE could be used interchangably in examples below)
    a.	ACFB SHOW CLASMAP – this will execute the ACF2 SHOW CLASMAP command, placing output into temp dsn, allowing PF7/8 scrolling and searching.
    b.	ACFB 'MULT SET RULE ~ LIST SYS1' – this will execute the ACF2 command, placing output into temp dsn, allowing PF7/8 scrolling and searching.
  	c.  ACFB ACCESS DSN('SYS1.PARMLIB') - this will execute the ACF2 Access command, showing all rules granting access to SYS1.PARMLIB and all LIDs with access, placing the output  into a temp dsn and allow PF7/8 scrolling, searching, etc.
  	d. ACFB ACCESS RESOURCE('BPX.FILEATTR.APF') TYPE(FAC) CLASS(R)
  	e. ACFB LI LIKE(-)
  	f. ACFB 'MULT SET TERSE ~ LI LIKE(-)'

  	Format: 
      ACFB any ACF2 command
  	  ACFE any ACF2 command
  	  ACFE 'MULT acf2 command1 ~ acf2 command2 ~ acf2 command3 ~ acf2 command4'
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
