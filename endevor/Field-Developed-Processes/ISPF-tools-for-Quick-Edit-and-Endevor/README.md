# ISPF tools for Quick-Edit and Endevor

This collection of mainframe tools is dependent upon IBM's ISPF. The items can only be used on the mainframe by users of Quick-Edit and Endevor. Although these tools are not available to  VS Code or Zowe users, some provide a user  experience similar to one from a modern tools.

Use the extension on each item to determine where the item needs to reside.

- rex items must reside in a Rexx library, typically a SYSEXEC, SYSPROC or CSIQCLS0 library
- pnl items must reside in an ISPF panel library, typically a ISPPLIB or a CSIQPENU library
- skl items must reside in an ISPF skeleton library, typically a ISPSLIB or a CSIQSENU library
- msg items must reside in an ISPF message library, typically a ISPMLIB or a CSIQMENU library

## Content Summary

This list is presented in an order of perceived value and popularity. Items listed together run together.

- Package PACKAGEP PKGESELS and PKGESEL2. These items can be referenced from either Quick-Edit or Endevor. They offer a way to create an Endevor package on one screen from a list of elements. While viewing an element list, enter "TSO PACKAGE" on the command line, and in one screen the items listed will be placed into a new package. Upon exiting the screen, a job is submitted to CAST and optionally EXECUTE the package. This tool can easily be modified to create packages using your naming standard, and to enforce rules that must be followed at your site. 
APIALPKG is an optional API program that can be used with the Package tool. It allows a user to create a new package by copying the content of another package. In this case, from any Quick-Edit or Endevor screen that shows a package name, enter "TSO PACKAGE" on the command line and move the cursor to the input package name before pressing 'Enter'. 

- PDA NOTIFY @SITE and WhereIam. These members belong to a featured known as the "Parallel Development Alert". They can be used only by Quick-Edit users, and provide notifications to developers that their edited element is encountering parallel development. Notifications appear as note lines within the edit session, reflecting the locations, userids and CCIDs for each element found outside of production. NOTIFY can be used by individual users to turn on or off the feature. The @SITE member is necessary only if you have multiple Endevor images and different life cycles. Each Endevor image will need its own version of @SITE, renamed to match the SYSNAME where Endevor is running. If you have only one Endevor image, or multiple Endevors with matching Environments and stages, then the @SITE and WhereIam members are not required for you. Either within PDA or within each renamed @SITE member there must be search instructions such as this example:

           PDAMaplist = ,        /* required only for PDA  */
              " SMPLTEST/T-SMPLTEST/Q ",
              " SMPLPROD/E-SMPLPROD/E "                

- RETRO RETROPOP RETRSHOW. These items can be used only from Quick-Edit where the PDA is active. The user can examine a PDA message, enter "TSO RETRO" on the command line, and use the cursor to point to a Note line that reflects another element to invoke an assisted PDM execution.
- PKGMAINT and PMAINTPN. These items offer Quick-Edit and Endevor users a fast method for managing package actions. While displaying a list of packages, enter "TSO PKGMAINT" on the command line to enable a batch COMMIT/RESET/DELETE action for all the listed packages. 
- QEXPAND and QEXPANDW. These two items can be used in Quick-Edit during an edit session as an "expand includes" utility. By entering "QEXPAND" on the command line, and moving the cursor to a COPY, ++INCLUDE, or -INC statement, the user invokes the tool to copy the content of the member referenced on the line into the edit session as NOTE lines.
- Items in the ENDIEIM1-the-ISPF-Edit-Service-Initial-Macro folder empower Quick-Edit to bypass its normal edit session, and to initiate other processing