# Miscellaneous-items

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

## GETJOBNM 

A modified Shareware program that has a wide range of usage. Information about a running job can be written in a REXX format, to be used again with TableTool (or othere REXX processing. See the [Automated-Test-Facility-Using-Test4Z](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Automated-Test-Facility-Using-Test4Z) as an example. 

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

## Endevor-Processor-Includes.md

This document offers steps to be taken to allow processors to reference "Include" members/elements.