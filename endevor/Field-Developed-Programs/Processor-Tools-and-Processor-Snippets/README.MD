# Processor-Tools-and-Processor-Snippets

At this location are found Endevor processor utilities and snippets of example processor code. For the sake of highlighting and syntax checking, processors and processor snippets are given the .jcl extension.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

## VALUECHK

This processor utility complements the use of CONPARMX within your processors. The input instructions for CONPARMX are typically called PARMS or OPTIONS, and may be extended to contain statements that are processed by VALUECHK, and not CONPARMX. Statements of this kind adhere to a format such as:

>keyword= '_value_'

where keyword can be any word or variable name, and _value_ is its assigned value. For example:

>Compiler = 'NewVersion'

>MQSeries = 'Y'

A VALUECHK step in a processor reflects in its return code whether a statement can be found in the OPTIONS indicating that a keyword is assigned to a _value_. Processors can use the return codes from VALUECHK steps to determine whether an element requires certain processing choices, such as Compiler and MQseries.

The use of VALUECHK is typically easier for an Endevor Administrator to implement than a massive introduction of new processor groups across many environments, systems, and types. It also aids developers by allowing further reductions in the number or processor groups.

Unlike processor groups:

  - Changes to OPTIONS create deltas in Endevor. You have the "Who/What/When" information for each change, and can easily return to any earlier version if necessary
  - OPTIONS can be tagged with a CCID
  - OPTIONS can be placed into packages, subjected to reviews and backed out

## Processor-Step-To-Check...

These items show "Extended REXX" abilities of Table Tool to execute REXX statements within a processor step, without having to create separate members for the REXX code.

## DB2MASK#

A processor REXX program that simulates the DB2 Masking method for Binds, used by the former Endevor for DB2 product.

## GOPTIONS and ROPTIONS

A processor and its REXX parser that can perform syntax checking on OPTIONS elements.

## YAML2REX

 YAML2REX.rex is a utility that can convert (simple) YAML statements into usable REXX. You can allow YAML files to become data for your automated processing.  Use the YAML2REX.jcl member to see what the conversion does to your YAML files.

Practical applications using REXX converted from YAML can be found in the **Dyname-Syslib** members, and others on this GitHub.

## Dynamic-Syslib

Items in this folder support the sharing of input components across developer efforts/projects that are underway in parallel.

For example, development for a January release might be underway in one sandbox (or environment) at the same time as development for a March release in another sandbox (or environment). This feature allows the March release to include libraries from the January release within its own SYSLIB concatenations, before the January release is Moved to production.

## OPTVALDT, TXTRPLCE and JCLRPLCE

These are REXX subroutines which are used by other FDP solutions:
 - OPTVALDT processes OPTIONS statements to ensure values are numeric or properly quoted
 - TXTRPLCE is a generic Search and Replace utility
 - JCLRPLCE is like TXTRPLCE, but provides precise JCL change instructions, where jobcard and/or Stepname.DDname references point to specific locations within a JCL for changes and inserts.
