# Broadcom TSS LISTNAME REXX Script
LISTNAME REXX provides the capability to list all ACIDS a specific profile is attached to or all ACIDs with a specific Group. The REXX then obtains the name assigned to each ACID and provides a complete list of ACIDs/Names in a single file output. It then places the user into ISPF Edit mode to allow them to copy/paste the data, create a dataset, scroll using PF7/8, search, etc. 

The challenge:  TSS does not currently provide any means to list all ACIDs and names assigned for a specific profile or group.  TSS LIST(profile_acid)DATA(ALL) or TSS LIST(profile_acid)DATA(ACIDS) will list all ACIDs that have the profile attached to them, but does not provide a list of ACIDs and who those are assigned to (names assigned), as often has been asked by Auditors or managers that want to validate the list of users with a specific profile granted to them.  Same for Group type ACIDs.   

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.	Upload the LISTNAME.rexx.txt as LISTNAME into your CLIST/REXX library.
2.	Execute:  TSO LISTNAME acid  (where ACID is the profile ACID or the group ACID you want the list of users/names to be provided)          
3.	Output is placed into a temporary dataset for you to review, etc.   
 
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
