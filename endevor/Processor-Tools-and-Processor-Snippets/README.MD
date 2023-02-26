# Processor-Tools-and-Processor-Snippets

Endevor processor utilities and example (snippets) of Endevor processor code are found at this location. 

## VALUECHK

This processor utility complements the use of CONPARMX within your processors. The input instructions for CONPARMX are typically called PARMS or OPTIONS, and may be extended to contain statements that are processed by VALUECHK, and not CONPARMX. Statements of this kind adhere to a format such as:

>keyword= '_value_'

where keyword can be any word or variable name, and _value_ is its assigned value. For example:

>Compiler = 'NewVersion'    
>MQSeries = 'Y'

A VALUECHK step in a processor reflects in its return code whether a statement can be found in the OPTIONS indicating that a keyword is assigned to a _value_. Processors can use the return codes from VALUECHK steps to determine whether an element requires certain processing choices, such as Compiler and MQseries.

## Processor-Step-To-Check

These items show "Extended Rexx" abilities of Table Tool to execute statements within a processor step, without having to create separate members for REXX code.

