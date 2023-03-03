# Exit-Examples

This folder contains example exits that can be easily employed and supported at your site.

Several of the exits are "stubs" - meaning that they are virtually static, needing only a line changed to name a REXX library. They contain no logic and merely collect pertinent information from Endevor to pass to a REXX subroutine.

In each case the REXX operates on fields in the exit blocks using variable names that are documented in the COBOL sections of Broadcom's techdocs documentation. REXX variable names however have underscores instead of the dash character used by COBOL. For example, the field documented as PECB-PACKAGE-ID in techdocs, is seen as PECB_PACKAGE_ID in the REXX subroutine.
