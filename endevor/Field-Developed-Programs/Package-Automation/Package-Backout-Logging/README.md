# Package Backout/Backin Logging

This folder contains items you can use to write a log for all packaged BackedIn or BackOut members. 

When a Package or selected elements are Backout or BackedIn, a log is written to contain a record of members affected. Here is an example:

    *Element  Status---- Package--------- ServiceNow Userid-- Date---  Time-
    WAITTILL BACKED-IN  UTIL#ZJKN3113635 CHG0000012 IBMUSER   20251101 16:55
    PGMDV2NS BACKED-IN  FINA#ZJ5O0838994 CHG0000012 IBMUSER   20251101 17:08
    PG000002 BACKED-IN  FINA#ZJ5O0838994 CHG0000012 IBMUSER   20251101 17:08
    PG000003 BACKED-IN  FINA#ZJ5O0838994 CHG0000012 IBMUSER   20251101 17:08
    PG000043 BACKED-IN  FINA#ZJ5O0838994 CHG0000017 IBMUSER   20251101 17:24
    PG000053 BACKED-IN  FINA#ZJ5O0838994 CHG0000017 IBMUSER   20251101 17:24
    TSTCOB   BACKED-IN  FINA#ZJ5O0838994 CHG0000017 IBMUSER   20251101 17:24
    WAITTILL BACKED-OUT UTIL#ZJKN3113635 CHG0000017 IBMUSER   20251101 17:25
    WAITTILL BACKED-IN  UTIL#ZJKN3113635 CHG0000017 IBMUSER   20251101 17:48
    WAITTILL BACKED-OUT UTIL#ZJKN3113635 CHG0000017 IBMUSER   20251101 17:55
    WAITTILL BACKED-IN  UTIL#ZJKN3113635 CHG0000025 IBMUSER   20251101 18:51

You must enter the name of the file within the BKOUTLOG.rex program. Records will be appended to the file for each BackOut and BackIn action. You can copy the heading from this example and place it at the top of your file if you choose.

- BKOUTLOG.rex - Called by C1UEXTR7 for BackOut/BackIn actions
- C1SP6000.pnl - ISPF panel for BackOut/BackIn actions
- CIUU03.ispfmsg
- SHIPRUNS.skl - Job skeleton to search for needed package shipments after  BackOut/BackIn actions

Existing items modifed for this solution include:
- C1UEXT07.cob - includes code for BackOut/BackIn actions
- C1UEXTR7.rex - includes code for BackOut/BackIn actions

SERVINOW.rex is part of the ServiceNow folder found [here](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/ServiceNow-Interface/COBOL%2BREXX%2BPythonOrGoLang-Example/SERVINOW.rex). If you are not required to validate BackOut and BackIn actions, then you can remove references to SERVINOW. 



All items that provide integration between Endevor and ServiceNow can be found in the [ServiceNow](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/ServiceNow-Interface) folder.
