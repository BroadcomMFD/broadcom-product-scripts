# Exit-Examples

This folder contains example exits that can be easily employed and supported at your site.

Several of the exits are "stubs" - meaning that they are virtually static, needing only a line changed to name a REXX library. They contain no logic and merely collect pertinent information from Endevor to pass to a REXX subroutine.

In each case the REXX operates on fields in the exit blocks using variable names that are documented in the COBOL sections of Broadcom's techdocs documentation. REXX variable names however have underscores instead of the dash character used by COBOL. For example, the field documented as PECB-PACKAGE-ID in techdocs, is seen as PECB_PACKAGE_ID in the REXX subroutine.

References to ispf messages can be removed from the code if you prefer, or to use them find them in the **ISPF-tools-for-Quick-Edit-and-Endevor** folder.

The **C1UEXT02 Reuse CCID and Comment.cob** member offers an exit that can re-use CCID and Comment values, waiving the requirement for them with each software change. Only the first sortware change requires them, and if left blank on subsequent changes the values entered the first time are used again.

See additional examples of Endevor exits in the **Package-Automation** folder.