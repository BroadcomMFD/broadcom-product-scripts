REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > PackageAutomation.moveout
ECHO These are rex/CSIQCLS0 : @site BILDTGGR PKGESHIP PKGEXECT PULLTGGR TBLUNLOD UPDTTGGR WHERE@M1 WHEREIAM >> PackageAutomation.moveout
ECHO These are asm          : C1UEXSHP APIALSUM APIALDST >> PackageAutomation.moveout
ECHO These are cob          : C1UEXSHP C1UEXT07 >> PackageAutomation.moveout
ECHO These are skl/CSIQSENU : PKG#MODL SHIP#FTP SHIPLOCL SHIPMODL >> PackageAutomation.moveout
ECHO These are tbl          : PKGEEXEC SHIPRULE >> PackageAutomation.moveout
ECHO These are jcl          : SWEEPJOB >> PackageAutomation.moveout
ECHO These are txt          : TRIGGER >> PackageAutomation.moveout
ECHO ./  ADD  NAME=@site                >> PackageAutomation.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\@site.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=BILDTGGR                >> PackageAutomation.moveout
TYPE Package-Automation\BILDTGGR.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=C1UEXSHP                >> PackageAutomation.moveout
TYPE Package-Automation\C1UEXSHP.asm   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=C1UEXSHP                >> PackageAutomation.moveout
TYPE Package-Automation\C1UEXSHP.cob   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=C1UEXT07                >> PackageAutomation.moveout
TYPE Package-Automation\C1UEXT07.cob   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=PKG#MODL                >> PackageAutomation.moveout
TYPE Package-Automation\PKG#MODL.skl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=PKGEEXEC                >> PackageAutomation.moveout
TYPE Package-Automation\PKGEEXEC.tbl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=PKGESHIP                >> PackageAutomation.moveout
TYPE Package-Automation\PKGESHIP.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=PKGEXECT                >> PackageAutomation.moveout
TYPE Package-Automation\PKGEXECT.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=PULLTGGR                >> PackageAutomation.moveout
TYPE Package-Automation\PULLTGGR.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=SHIP#FTP                >> PackageAutomation.moveout
TYPE Package-Automation\SHIP#FTP.skl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=SHIPLOCL                >> PackageAutomation.moveout
TYPE Package-Automation\SHIPLOCL.skl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=SHIPMODL                >> PackageAutomation.moveout
TYPE Package-Automation\SHIPMODL.skl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=SHIPRULE                >> PackageAutomation.moveout
TYPE Package-Automation\SHIPRULE.tbl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=SWEEPJOB                >> PackageAutomation.moveout
TYPE Package-Automation\SWEEPJOB.jcl   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=TBLUNLOD                >> PackageAutomation.moveout
TYPE Package-Automation\TBLUNLOD.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=TRIGGER                >> PackageAutomation.moveout
TYPE Package-Automation\TRIGGER.txt   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=UPDTTGGR                >> PackageAutomation.moveout
TYPE Package-Automation\UPDTTGGR.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=WHERE@M1                >> PackageAutomation.moveout
TYPE Package-Automation\WHERE@M1.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=WHEREIAM                >> PackageAutomation.moveout
TYPE Package-Automation\WHEREIAM.rex   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=APIALSUM                >> PackageAutomation.moveout
TYPE API-Assembler-Examples\APIALSUM.asm   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
ECHO ./  ADD  NAME=APIALDST                >> PackageAutomation.moveout
TYPE API-Assembler-Examples\APIALDST.asm   >> PackageAutomation.moveout
ECHO.          >> PackageAutomation.moveout
REM
