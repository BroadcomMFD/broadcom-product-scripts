# ISPF tools for Quick-Edit and Endevor

This collection of mainframe tools is dependent upon IBM's ISPF. The items can only be used on the mainframe by users of Quick-Edit and Endevor. Although these tools are not available to  VS Code or Zowe users, some provide a user experience similar to one from a modern tool.

Use the extension on each item to determine where the item needs to reside.

- rex items must reside in a REXX library, typically a SYSEXEC, SYSPROC or CSIQCLS0 library
- pnl items must reside in an ISPF panel library, typically an ISPPLIB or a CSIQPENU library
- skl items must reside in an ISPF skeleton library, typically an ISPSLIB or a CSIQSENU library
- msg items must reside in an ISPF message library, typically an ISPMLIB or a CSIQMENU library

Items listed together run together.

## PACKAGE PACKAGEP PKGESELS and PKGESEL2

These items can be referenced from either Quick-Edit or Endevor. They offer a way to create an Endevor package using only one screen while viewing a list of elements. Just  enter "TSO PACKAGE" on the command line, and the elements listed will be placed into a new package. You can choose whether MOVE, GENERATE or DELETE actions are to be performed on all listed elements. Then a job is submitted to CAST and optionally EXECUTE the package. This tool can easily be modified to create packages using your naming standard, and to enforce rules that must be followed at your site. 
APIALPKG is an optional API program that can be used with the Package tool. It allows a user to create a new package by copying the content of an existing package. In this case, from any Quick-Edit or Endevor screen that shows a package name, enter "TSO PACKAGE" on the command line, move the cursor to the first character of the package name, and press 'Enter'. 

## PDA NOTIFY @SITE and WHEREIAM

These members belong to a feature known as the "Parallel Development Alert". They can be used only by Quick-Edit users, and provide notifications to developers that the edited element is in parallel development. Notifications appear as note lines and indicate the locations, userids and CCIDs for each element found.  NOTIFY can be used to turn on or off the notifications for a single user. The @SITE member is necessary only if you have multiple Endevor images and different life cycles. Each Endevor image will need its own version of @SITE, renamed to match the SYSNAME where Endevor is running. If you have only one Endevor image, or multiple Endevors with matching Environments and stages, then the @SITE and WhereIam members are not required for you. Either within PDA or within each renamed @SITE member there must be search instructions such as this example:

           PDAMaplist = ,        /* required only for PDA  */
              " SMPLTEST/T-SMPLTEST/Q ",
              " SMPLPROD/E-SMPLPROD/E "         

Two detail lines are shown in the example above. Each detail line shows an environment-stage starting location and an environment-stage ending location. The locations indicate where the PDA will search for elements in parallel development. As many detail lines as necessary can be coded.

## RETRO RETROPOP RETRSHOW

These items can be used only from Quick-Edit where the PDA is active. The user can enter "TSO RETRO" on the command line, and use the cursor to point to a PDA Note line that shows another element. Then, an assisted PDM execution will be invoked.

## PKGMAINT and PMAINTPN

These items offer Quick-Edit and Endevor users a fast method for managing packages. While displaying a list of packages, enter "TSO PKGMAINT" on the command line. From the panel displayed is prepared and submitted a job to COMMIT/RESET/DELETE the packages listed.

## ENDIEIM1 and ENDIEIM1-the-ISPF-Edit-Service-Initial-Macro

ENDIEIM1 acts as an "Initial Edit Macro" for Quick-Edit sessions. Items whose names begin with "ENDIEIM1", including the **ENDIEIM1-the-ISPF-Edit-Service-Initial-Macro** folder content, empower Quick-Edit to bypass its normal edit session, and to initiate exception processing.

## FINDLOOP and FINDWRD1

Together these can be used with Batch Administration SCL for creating new definitions or updating existing definitions. While in View or Edit and excluding some or all lines, FINDLOOP can be used to expose complete statements. Every line from the 'DEFINE' to the statement-closing period is exposed.

For example, while editing a batch administration SCL member, try these commands:
~~~
X ALL
f all "GENERATE PROCESSOR NAME IS '*NOPROC*'"
FINDLOOP
~~~

When done, complete SCL statements that contain your searched value will be displayed. You can Delete all excluded lines (ie DEL ALL X), change and save the results as a member for further Batch Admin processing.
FINDWRD1 is a subroutine to FINDLOOP.

## JCLCOMMT

This edit macro can be executed from Quick-Edit on Endevor processors, JCL, PROCs and Skeletons in a JCL format. Enter JCLCOMMT on the command line, and lines containing an EXEC statement are then commented with the element name.

## PTBROWSE and PTEDIT

While editing a processor (or JCL) where a dataset name is found, enter the name of either of these on the command line, move the cursor to the first character of the dataset name, and press Enter. You will then be Browsing or Editing the dataset.

## QEXPAND and QEXPANDW

These two items can be used in Quick-Edit as an "expand includes" utility. After you enter "QEXPAND" on the command line, and move the cursor to a "COPY", "++INCLUDE", or "-INC" statement, and press Enter, the content of the referenced member is copied into the edit session as NOTE lines.

The image below for example, shows an include member named **SETSTMTS** expanded from a "++INCLUDE" statement within a processor.

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

Some simple tailoring of QEXPANDW is likely required. See references to INCLUDE_LIBRARY_LIST within the REXX member.