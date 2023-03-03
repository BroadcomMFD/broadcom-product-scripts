# Miscellaneous-items

These are miscellaneous tools collected by Broadcom Services members and used in supporting Endevor.

## ANL#DRIV, ANL#VIEW and BTCHEDIT

These items support the use of a Rexx Edit macro  as an alternative to the Endevor Inventory Analyzer. Advantages for this REXX version:

- The REXX Edit macro can be easily tested on individual members of source. While viewing a member, enter ANL#VIEW on the command line.
- Some conditions can be more conveniently discovered in REXX. For example, using the Built-in SYSDSN command to test whether a member exists within a dataset, which might determine detailed attributes about the member name.
- OPTIONS Output more can easily be produced from REXX.
- A user who is familiar with the REXX language does not need to learn the methods of the Inventory Analyzer.


## FINDLOOP and FINDWRD1

Together these can be used with Batch Administration SCL for creating new definitions or updating existing definitions. While in View or Edit and excluding some or all lines, FINDLOOP can be used to expose complete statements. Every line from the 'DEFINE' to the statement-closing period is exposed.

For example, while editing a batch administration SCL member, try these commands:
~~~
X ALL
f all "GENERATE PROCESSOR NAME IS '*NOPROC*'"
FINDLOOP
~~~
FINDWRD1 is a subroutine to FINDLOOP.

## JCLCOMMT

This edit macro can be executed on Endevor processors, JCL, PROCs and Skeletons in a JCL format. While editing in Quick-Edit, enter JCLCOMMT on the command line. Lines containing an EXEC statement are then commented.

## PTBROWSE and PTEDIT

While editing a processor (or JCL) where a dataset name is found, enter the name of either of these on the command line, move the cursor to the first character of the dataset name, and press Enter. You will then be Browsing or Editing the dataset.

## ENDIEIM1

Within these two examples are features initiated by the Quick-Edit Startup command. ENDIEIM1 acts as an "Initial Edit Macro" for Quick-Edit sessions.

Find other ENDIEIM1 examples in the ISPF-tools-for-Quick-Edit-and-Endevor folder.
See also techdocs documentation for details.
