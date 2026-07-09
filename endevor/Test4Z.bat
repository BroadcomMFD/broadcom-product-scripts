REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > Test4Z.moveout
ECHO These items come from the Endevor GitHub at >> Test4Z.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> Test4Z.moveout
ECHO ------------------------------------------------------- >> Test4Z.moveout
ECHO These are rex/CSIQCLS0 : Moveout NDUSRXTP NDUSRXTR NDUSRXTU NDUSRXTZ >> Test4Z.moveout
ECHO These are pnl/CSIQPENU : NDUSRPTP NDUSRPTR NDUSRPTU NDUSRPTZ >> Test4Z.moveout
ECHO These are prc          : T4ZJNKNO T4ZOPTNS T4ZRPLAY T4ZRPLA2 T4ZUNIT T4ZVARBS >> Test4Z.moveout
ECHO These are skl/CSIQSENU : T4ZRCORD T4ZREPLA T4ZUTEST >> Test4Z.moveout
ECHO These are jcl          : ZTPQHELO ZTP1HELO >> Test4Z.moveout
ECHO ./  ADD  NAME=Moveout                >> Test4Z.moveout
TYPE Field-Developed-Programs\ISPF-tools-for-Quick-Edit-and-Endevor\Moveout.rex   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRPTP                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRPTP.pnl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRPTR                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRPTR.pnl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRPTU                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRPTU.pnl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRPTZ                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRPTZ.pnl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRXTP                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRXTP.rex   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRXTR                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRXTR.rex   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRXTU                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRXTU.rex   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=NDUSRXTZ                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\NDUSRXTZ.rex   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZJNKNO                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZJNKNO.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZOPTNS                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZOPTNS.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZRCORD                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\T4ZRCORD.skl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZREPLA                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\T4ZREPLA.skl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZUTEST                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\T4ZUTEST.skl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=ZTPQHELO                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\ZTPQHELO.jcl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=ZTP1HELO                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\Quick-Edit-User-Extension-Points\ZTP1HELO.jcl   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZRPLAY                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZRPLAY.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZRPLA2                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZRPLA2.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZUNIT                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZUNIT.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
ECHO ./  ADD  NAME=T4ZVARBS                >> Test4Z.moveout
TYPE Automated-Test-Facility-Using-Test4Z\T4ZVARBS.prc   >> Test4Z.moveout
ECHO.          >> Test4Z.moveout
REM
