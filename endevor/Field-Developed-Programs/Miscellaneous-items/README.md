# Miscellaneous-items

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information). 

## EXPLORE

You can execute "edit macros" in batch, such as ANL#VIEW and BTCHEDIT, but your JCL requires a large number of files be allocated to do so. A quick way to prepare your JCL, is to copy **EXPLORE** into your JCL library. Yes, that is right - your JCL library. Then execute it this way....

        Menu  Functions  Confirm  Utilities  Help                                    
    ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss 
    EDIT              YOURSITE.TEAM.JCL                     Row 0000172 of 0000424
    Command ===>                                                  Scroll ===> CSR 
            Name     Prompt       Size   Created          Changed          ID  
    EX ______ EXPLORE                 143  2020/04/01  2020/04/01 17:09:11 IBMUSER 
    _________ EXPORT                    4  2020/11/05  2021/03/05 11:46:24 IBMUSER  
    _________ FINDPROC                  4  2024/06/03  2024/06/03 16:58:39 IBMUSER  

When done, additional members will be placed into your JCL, so that the statements like these, can find what you need: 

    //   INCLUDE MEMBER=ZISPSLIB


## ANL#DRIV, ANL#VIEW and BTCHEDIT

These items support the use of a Rexx Edit macro  as an alternative to the Endevor Inventory Analyzer. Advantages for this REXX version:

- The REXX Edit macro can be easily tested on individual members of source. While viewing a member, enter ANL#VIEW on the command line.
- Some conditions can be more conveniently discovered in REXX. For example, using the Built-in SYSDSN command to test whether a member exists within a dataset, which might determine detailed attributes about the member name.
- OPTIONS output can be more easily produced from REXX.
- A user who is familiar with the REXX language does not need to learn the methods of the Inventory Analyzer.

## SCHEDULE, WAITTIL and WAITSECS

If you have a maintenance or test job for example, that you want to run after hours, you can use these - without having to wait around. Tailor the SCHEDULE job to specify when you want your job to run, and where to find the JCL. To schedule a job for the next day, you can increase the hour portion of the parameter. For example:
~~~
//   SET START='35:02:00'      <- HH:MM:SS
~~~
Then just submit the SCHEDULE job before you leave.

## INFO

This member reflects a standard adopted by Broadcom Services for large or complex REXX programs. With just 3 lines of code a REXX program can detect if its name is allocated, and dynamically turn on the Trace as it runs. Then each time you want to see the Trace, there is no reason to change the code and no risk that the trace is turned on for others. 

For example, if the name of a REXX program is MYREXXPG and it runs in batch, then include in the jobstep a statement like this one.

~~~
//MYREXXPG  DD DUMMY
~~~

## GTUNIQUE

Returns a unique 8-byte value,derived from the current date and time, down to a tenth of a second. You can use the returned value as a node of a dataset name, assured that the dataset does not exist, and can be retained for years, if necessary. Example call:  

    worknode = GTUNIQUE()  

## GTNXTSTG

Given the names of an Endevor Environent and StageId, returns the mapped next Environment and StageId. Example call:  

     NextEnv@StgId= GTNXTSTG('DEV' 'D')        

## GETJOBNR

Returns the Job Number (JobID) for the job currently running. Example call: 

    MyJobNumber =  GETJOBNR()  

## GETACCTC

Returns the Job Accounting code for the job currently running. Example call: 

    MyAccountingCode = GETACCTC()   

The routine is useful if your job submits another job, and needs to keep the accounting code the same for both jobs. 

## Endevor-Processor-Includes.md

This document offers steps to be taken to allow processors to reference "Include" members/elements.