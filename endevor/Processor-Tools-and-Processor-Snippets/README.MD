# Processor-Tools-and-Processor-Snippets

Endevor processor utilities and example (snippets) of Endevor processor code are found at this location. 

## VALUECHK

This processor utility complements the use of CONPARMX within your processors. The input instructions for CONPARMX are typically called PARMS or OPTIONS, and may be extended to contain statements that are processed by VALUECHK, and not CONPARMX. Statements of this kind adhere to a format such as:

>keyword= '_value_'

where keyword can be any word or variable name, and _value_ is its assigned value. For example:

>Compiler = 'NewVersion'    
>MQSeries = 'Y'

A VALUECHK step in a processor reflects in its return code whether a statement can be found in the OPTIONS indicating that a keyword is assigned to a _value_. Processor steps can use the return codes from VALUECHK steps to determine whether an element requires certain processing choices, such as Compiler and MQseries.

## Processor-Step-To-Check

These items show "Extended Rexx" abilities of Table Tool to execute REXX statements within a step, without having to create separate members for REXX code.

## Dynamic-SYSLIB

Items in this folder provide for a "Dyanamic SYSLIB" feature. Developement efforts conducted in parallel might need to share inputs, and these items provide for that kind of sharing. 

For example, a January release being developed in one sandbox (or environment) might be underway at the same time as a March release in another sandbox (or envieonment). This feature allows the March release to include libraries for the January release in its own SYSLIB concatenations. The result is that testing of the March release simulates the January release being in production - before the January release is Moved to production.





