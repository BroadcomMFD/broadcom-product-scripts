# Miscellaneous-items

These are miscellaneous tools collected by Broadcom Services members and used in supporting Endevor.

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


## Endevor-Processor-Includes.md

This document offers steps to be taken to allow processors to reference "Include" members/elements.