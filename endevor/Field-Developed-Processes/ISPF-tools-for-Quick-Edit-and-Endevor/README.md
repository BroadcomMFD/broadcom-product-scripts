# ISPF tools for Quick-Edit and Endevor

This collection of mainframe tools is dependent upon IBM's ISPF. The items can only be used on the mainframe by users of Quick-Edit and Endevor. Although these tools are not available to  VS Code or Zowe users, some provide a user experience similar to one from a modern tool.

Use the extension on each item to determine where the item needs to reside.

- rex items must reside in a Rexx library, typically a SYSEXEC, SYSPROC or CSIQCLS0 library
- pnl items must reside in an ISPF panel library, typically an ISPPLIB or a CSIQPENU library
- skl items must reside in an ISPF skeleton library, typically an ISPSLIB or a CSIQSENU library
- msg items must reside in an ISPF message library, typically an ISPMLIB or a CSIQMENU library

Items listed together run together.

## Package PACKAGEP PKGESELS and PKGESEL2

These items can be referenced from either Quick-Edit or Endevor. They offer a way to create an Endevor package on one screen from a list of elements. While viewing an element list, enter "TSO PACKAGE" on the command line, and in one screen the items listed will be placed into a new package. Upon exiting the screen, a job is submitted to CAST and optionally EXECUTE the package. This tool can easily be modified to create packages using your naming standard, and to enforce rules that must be followed at your site. 
APIALPKG is an optional API program that can be used with the Package tool. It allows a user to create a new package by copying the content of another package. In this case, from any Quick-Edit or Endevor screen that shows a package name, enter "TSO PACKAGE" on the command line and move the cursor to the input package name before pressing 'Enter'. 

## PDA NOTIFY @SITE and WhereIam

These members belong to a feature known as the "Parallel Development Alert". They can be used only by Quick-Edit users, and provide notifications to developers that their edited element is encountering parallel development. Notifications appear as note lines within the edit session, reflecting the locations, userids and CCIDs for each element found outside of production. NOTIFY can be used by individual users to turn on or off the feature. The @SITE member is necessary only if you have multiple Endevor images and different life cycles. Each Endevor image will need its own version of @SITE, renamed to match the SYSNAME where Endevor is running. If you have only one Endevor image, or multiple Endevors with matching Environments and stages, then the @SITE and WhereIam members are not required for you. Either within PDA or within each renamed @SITE member there must be search instructions such as this example:

           PDAMaplist = ,        /* required only for PDA  */
              " SMPLTEST/T-SMPLTEST/Q ",
              " SMPLPROD/E-SMPLPROD/E "         

## RETRO RETROPOP RETRSHOW

These items can be used only from Quick-Edit where the PDA is active. The user can examine a PDA message, enter "TSO RETRO" on the command line, and use the cursor to point to a Note line that reflects another element to invoke an assisted PDM execution.

## PKGMAINT and PMAINTPN 

These items offer Quick-Edit and Endevor users a fast method for managing package actions. While displaying a list of packages, enter "TSO PKGMAINT" on the command line to enable a batch COMMIT/RESET/DELETE action for all the listed packages. 

## ENDIEIM1 and ENDIEIM1-the-ISPF-Edit-Service-Initial-Macro

ENDIEIM1 acts as an "Initial Edit Macro" for Quick-Edit sessions. Items whose names begin with "ENDIEIM1", including content in the **ISPF-tools-for-Quick-Edit-and-Endevor** folder, empower Quick-Edit to bypass its normal edit session, and to initiate exception processing.

## FINDLOOP and FINDWRD1

Together these can be used with Batch Administration SCL for creating new definitions or updating existing definitions. While in View or Edit and excluding some or all lines, FINDLOOP can be used to expose complete statements. Every line from the 'DEFINE' to the statement-closing period is exposed.

For example, while editing a batch administration SCL member, try these commands:
~~~
X ALL
f all "GENERATE PROCESSOR NAME IS '*NOPROC*'"
FINDLOOP
~~~

When done, you can Delete all excluded lines (ie DEL ALL X), change and save the results as a member for further Batch Admin processing.
FINDWRD1 is a subroutine to FINDLOOP.

## JCLCOMMT

This edit macro can be executed on Endevor processors, JCL, PROCs and Skeletons in a JCL format. While editing in Quick-Edit, enter JCLCOMMT on the command line. Lines containing an EXEC statement are then commented.

## PTBROWSE and PTEDIT

While editing a processor (or JCL) where a dataset name is found, enter the name of either of these on the command line, move the cursor to the first character of the dataset name, and press Enter. You will then be Browsing or Editing the dataset.

## QEXPAND and QEXPANDW

These two items can be used in Quick-Edit during an edit session as an "expand includes" utility. By entering "QEXPAND" on the command line, and moving the cursor to a COPY, ++INCLUDE, or -INC statement, the user invokes the tool to copy the content of the member referenced on the line into the edit session as NOTE lines.

The image below for example, shows an include member named **SETSTMTS** expanded within a processor that references it.

~~~
GCOBOL     + TO: ADMIN/1/CATSNDVR/ENDEVOR/PROCESS       COLUMNS0000100072
Command ===>                                                Scroll ===>CSR 
000001//*******************************************************************   
000002//**                                                               **   
000003//**    COBOL COMPILE AND LINK-EDIT PROCESSOR                           
000004//**                                                               **   
000005//*******************************************************************   
000006//GCOBOLJJ PROC AAAX='',                                                
- - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 12 Line(s) not Displayed 
000019       ++INCLUDE SETSTMTS    Standard processor includes                
=NOTE=       FROM: SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.INCLUDE(SETSTMTS)          
=NOTE=//*   Top of SETSTMTS                                                   
=NOTE=//             CIICOMP='SYS1.COB2COMP',                                 
=NOTE=//*            CIILIB='SYS1.COB2LIB',                                   
=NOTE=//             CIILIB='IGY.SIGYCOMP',                                   
=NOTE=//             CLECOMP='IGY.SIGYCOMP',                                  
=NOTE=//             CLELKED='CEE.SCEELKED',                                  
=NOTE=//             CLERUN='CEE.SCEERUN',                                    
=NOTE=//             CSIQCLS0='NDVR.R1801.CSIQCLS0',                 
=NOTE=//             CSYSLIB='&HLQ..COPYBOOK',                                
=NOTE=//             EXPINC=N,                                                
~~~