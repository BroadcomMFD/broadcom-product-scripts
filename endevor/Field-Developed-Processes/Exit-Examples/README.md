# Exit-Examples

This folder contains example exits that can be optionally employed in your Endevor.
Several of the exits are "stubs" - meaning that they contain no logic within them, other than to collect pertinent information to pass to a REXX subroutine. In each case the REXX is then operating on fields in the exit blocks which are documented in the COBOL sections of Broadcom's techdocs documentation. The REXX fields however have underscores in places of field names where COBOL uses the dash character. 

For example, the field documented as PECB-PACKAGE-ID in techdocs, is seen as PECB_PACKAGE_ID in the REXX subroutine.
