# Broadcom ACF2 REXX Script for Roles

ALR – ACF2 List Roles - A single-line command to list defined ACF2 Roles quickly and interactively.  You can list all defined Roles, a single Role,or a range of Roles.
AR - ACF2 Add Role - A single-line command to insert a Role within ACF2 with LIDs or without LIDs
CR - ACF2 Change Role - A single-line command to make changes to Roles, adding new LIDs or removing LIDs from a Role.

The challenge:  Simplify management and provide REXX examples to be more efficient.

# Using
Sample scripts for each product are located in the directory that shares its name. If you cannot find a particular use case, [please open an issue](https://github.com/BroadcomMFD/broadcom-product-scripts/issues/new).

What to do:   
1.  Upload the ALR.rexx.txt as ALR into your CLIST/REXX library.
2.  Upload the AR.rexx.txt as AR into your CLIST/REXX library.
3.  Upload the CR.rexx.txt as CR into your CLIST/REXX library.

Syntax:
ALR:
1. TSO ALR - this will list all defined Roles, placing output into a temp dataset, allowing you to scroll, find/search, review the output. PF3 would exit and cleanup the temp dataset.
2. TSO ALR SYSPROG - this would list only the single Role called SYSPROG, placing the output into temp dataset, etc.
3. TSO ALR LIKE(S-) this would like all Role that start with the letter S, placing the output into temp dataset, etc.

AR:
1. TSO AR TEST0001 - this would insert a new ACF2 Role called TEST0001 without any LIDs being included.
2. TSO AR TEST0001 lid1 lid2 lid3 lid4 - this would insert a new Role called TEST0001 and include the four logonIDs specified.
Note:  TSO AR also issues the F ACF2,NEWXREF,TYPE(ROL) command for you.

CR: 
1.	TSO CR cmd role lid1 lid2 lid3 - where "cmd" is an A - ADD or a D - Delete, and where "role" is the Role you desire to change.
Add LID to a Role using CR: TSO CR A TEST0001 ABC1234 - this would add the LID ABC1234 to the Role TEST0001
Delete LID from a Role using CR:  TSO CR D TEST0001 ABC1234 - this would delete the LID ABC1234 from the Role TEST0001
Note:  TSO AR also issues the F ACF2,NEWXREF,TYPE(ROL) command for you.  

   
  	
# Contributing
**We are not accepting third-party contributions at this time. If you are interested in contributing, please contact Steven.Hosie@Broadcom.com & Vijay.Gundu@Broadcom.com & Rose.Sakach@Broadcom.com or Adam.Wolfe@Broadcom.com to discuss.**

It is the responsibility of the original contributor to resolve vulnerabilities identified by Dependabot within their contributions.
