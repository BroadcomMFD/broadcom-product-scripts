REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > ServiceNow.moveout
ECHO These items come from the Endevor GitHub at >> ServiceNow.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> ServiceNow.moveout
ECHO ------------------------------------------------------- >> ServiceNow.moveout
ECHO These are cob          : C1UEXT02 C1UEXTT7 SNINCQRY C1X2CUST C1X7CUST >> ServiceNow.moveout
ECHO These are rex/CSIQCLS0 : C1UEXTR2 C1UEXTR7 SNOWQERY NDVRSNOW SNOWCUST >> ServiceNow.moveout
ECHO These are jcl          : SNOW@JCL >> ServiceNow.moveout
ECHO These are txt          : CIUU23 CIUU71 >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1UEXT02                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\C1UEXT02.cob   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1UEXTR2                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\C1UEXTR2.rex   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1UEXTR7                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\C1UEXTR7.rex   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1UEXTT7                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\C1UEXTT7.cob   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=SERVICPY                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\ServiceNow.py   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=SNINCQRY                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\ServiceNowSubroutineQuery.cob   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=SNOW@JCL                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\BatchQuery.jcl   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=SNOWQERY                >> ServiceNow.moveout
TYPE COBOL+REXX+Python-Example\BatchQuery.rex   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1X2CUST                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\C1X2CUST.cob   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=C1X7CUST                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\C1X7CUST.cob   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=CIUU23                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\CIUU23.txt   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=CIUU71                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\CIUU71.txt   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=NDVRSNOW                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\Customer_ndvrsnow.rex   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
ECHO ./  ADD  NAME=SNOWCUST                >> ServiceNow.moveout
TYPE COBOL+REXX+WebEnablementToolkit\SNOWCustomer.rex   >> ServiceNow.moveout
ECHO.          >> ServiceNow.moveout
REM
