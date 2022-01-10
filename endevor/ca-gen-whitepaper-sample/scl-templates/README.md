# CA Gen DevOps Story Sample SCL Templates

## Overview

Before you can effectively utilize Endevor SCM to build your CA Gen applications, your environment must be configured
correctly to compile and link COBOL programs, generally, and CA Gen programs, specifically. This is a process that is
normally completed by an administrator, and your environment may already have the appropriate processor groups configured
and working. Some of these SCL templates are meant to be tailored to your environment and were created based on the R&D
environment at Broadcom.

## Set up

Gen expects the Endevor system to consist of DEV/QA/PRD environments, as well as a PROCESSOR environment.
Element types required in DEV/QA/PRD are COBPGM, ISPS, LNK, LNKINC, PARMS, SAMPS, SANDBOX and SIDEDECK.
There are two types of elements used:
Templates - are element type ISPS and PARMS. You must make these SCL templates available in your Endevor PRD environment.
Processors - are new or modified Endevor processors. Most are the regular processors used by Endevor.

The SCL provided is very straight forward and should be familiar to a Endevor SCM administrator that has configured a
processor group for COBOL (COBPGM) elements previously.

## More details

The Gen generated COBOL code become COBPGM elements. If the Gen generated code contains EXEC SQL statements, the scripts
add 2 CBL SQL statements to the COBPGM element to direct the COBOL Compiler to invoke the DB2 Coprocessor. These elements
produce DBRMs that are added to the DBRMLIB and later used to create Packages and Plans. The CBL SQL Version parameter
can be used to make the DBRMs unique.

ISPS elements are templates used by the scripts to Link-Edit the Gen code.

PARMS contain the Compiler and Link-Edit parms in member $$$$DFLT. It also contains elements with the SQL statements used 
to BIND the DBRMs.


The PROCESSORs used are as provided by Endevor for regular processing with the following modifications:

Processors GSANDBOX and DSANDBOX need an additional library called &PHX..CICSRPL allocated/deleted. This library is of
type LIBRARY (PDSE).

Processor GCOB5 is used to invoke the COBOL Compiler. It is a modification of GCOB but it invokes the COBOL V5 Compiler.
It includes SYSMDECK and SYSUT1-15 allocations so it can also be used to invoke the COBOL V6.X Compiler by changing the
Compiler Library name.
The Processor Group uses Symbolic Overrides in the Move Action processor MPDSMBR for OUTLIB1-3 to OBJLIB, DBRMLIB and
LISTLIB so that the content of these libraries is Move to the next Stage.

Processor GLNK2 is used to invoke the Link-Edit/Binder. It is a modified GLNK processor that includes a step to invoke
DB2 to BIND the DBRMs produced by the Coprocessor into packages/plans.

Processor MVCSDUP is used to copy the executable DLL to library &PHX..CICSRPL that can be included in the CICS RPL
concatenation. This same processor uses info provided in the scripts to create a batch job that executes the DFHCSDUP
utility to define CSD resources.
