# Miscellaneous-items

These are other miscellaneous Endevor tools

## ANL#DRIV, ANL#VIEW and BTCHEDIT

These items use a Rexx Edit macro process as an alternative to the Endevor Inventory Analyzer. Advantages for this Rexx version:

- The Edit macro ANL#VIEW can be tested on individual members of source. While viewing a member, enter ANL#VIEW on the command line.
- Some conditions can be easier handled in REXX. For example, the REXX analysis might produce Emdevor SCL and OPTIONS content

## FINDLOOP and FINDWRD1

Together these can be used with Batch Administration SCL to expose complete statements, from 'DEFINE' to '.' .

For example, while editing a batch administration SCL member, try these commands:
~~~
X ALL
f all "GENERATE PROCESSOR NAME IS '*NOPROC*'"
FINDLOOP
~~~

## JCLCOMMT

This edit macro can be executed on Endevor processors, JCL, PROCs and some Skeletons. While editing one of these in Quick-Edit and enter JCLCOMMT on the command line. Lines containing an EXEC statement are then commented.

## PTBROWSE and PTEDIT

While editing a processor (or JCL) where a dataset name is found, enter the name of either of these on the command line, move the cursor to the first character of the dataset name, and press Enter. You will then be Browsing or Editing the dataset.

## ENDIEIM1

Provided are an example feature-rich version and a snippet to invoke JCLCHeck executions. ENDIEIM1 is the Quick-Edit "Session Startup" command.  See the techdocs documentation for details.
