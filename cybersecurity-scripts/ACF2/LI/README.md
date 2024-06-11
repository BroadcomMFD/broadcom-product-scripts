# Broadcom ACF2 LI Script
LI – reduces the amount of typing for a very common function. This REXX takes the argument in, executes the ACF2 LIST command based upon the input including any LIST LIKE, then places the outputinto a dynamically named temp dataset, and places the user into either ISPF browse or edit mode.  Instead of submitted that batch job to obtain a long listing or any listing, use LI for a more interactive experience and reduce required time from listing to viewing output.  This rexx is an example of the “art of the possible” in using the newer ACF2 ACFUNIX utility.

The challenge:  Reduce the sheer volume professionals must type daily while performing their required tasks/functions.

Background:  ACF2 command to list a LID is to execute ACF, then once in ACF, issue the LI lid command, and the output is displayed with no means to scoll or search within the record.  Enabling Mainframe Cybersecurity Professionals (MCP) to do more with their limited time daily is a must.  LI provides the ability to quickly list a LID, place the output into a temp dataset, place the cybersecurity professional into Browse, and allow them to scroll or search as desired. TSO ALI lid can be executed anywhere within TSO.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the LI as LI into your CLIST/REXX library.
2.	Execute:  TSO LI lid anywhere in TSO.
3.	Options:
    a.	LI lid – this will execute the ACF2 LI lid command
    b.	LI LIKE(ABC-) will list all ABC* LIDs
    c.	LI lid T – this would do SET TERSE and then execute the ACF2 LI lid Command - listing the LID and  the name assigned.
    d.	LI LIKE(ABC-) T this would SET TERSE and then execute the ACF2 LI LIKE(ABC-) command.  This will list the LIDs prefixed with ACB* and all name assigned to each LID.
    e.  LI LIKE(-) T will list all LIDs and the name field associated with each LID in a dynamically named temp dataset, placing you into ISPF Browse or edit for review.


# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.

