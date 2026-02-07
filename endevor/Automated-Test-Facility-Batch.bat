REM   In Windows, execute this command file to collect items
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > Automated-Test-Facility-Batch.moveout
ECHO These items come from the Endevor GitHub at >> Automated-Test-Facility-Batch.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> Automated-Test-Facility-Batch.moveout
ECHO ------------------------------------------------------- >> Automated-Test-Facility-Batch.moveout
ECHO These are JCL          : AUTOTEST GET#OPTE GTESTING >> Automated-Test-Facility-Batch.moveout
ECHO These are rex/CSIQCLS0 : COBOPTS JCLOPTS SUBMITST >> Automated-Test-Facility-Batch.moveout
ECHO These are REX          : TEST#JOB WAITFILE >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=AUTOTEST                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\AUTOTEST.JCL   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=COBOPTS                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\"Example COBOL element OPTIONS.rex"   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=JCLOPTS                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\"Example JCL element OPTIONS.rex"   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=GET#OPTE                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\GET#OPTE.JCL   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=GTESTING                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\GTESTING.JCL   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=SUBMITST                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\SUBMITST.rex   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=TEST#JOB                >> Automated-Test-Facility-Batch.moveout
TYPE Automated-Test-Facility-for-Batch-Applications\TEST#JOB.REX   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
ECHO ./  ADD  NAME=WAITFILE                >> Automated-Test-Facility-Batch.moveout
TYPE Field-Developed-Programs\Miscellaneous-items\WAITFILE.REX   >> Automated-Test-Facility-Batch.moveout
ECHO.          >> Automated-Test-Facility-Batch.moveout
REM
