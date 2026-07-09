REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > ACMBuild.moveout
ECHO These items come from the Endevor GitHub at >> ACMBuild.moveout
ECHO https://github.com/BroadcomMFD/broadcom-product-scripts >> ACMBuild.moveout
ECHO ------------------------------------------------------- >> ACMBuild.moveout
ECHO These are jcl          : ACM#LOD1 ACM#LOD2 ACM#COPY >> ACMBuild.moveout
ECHO These are skl/CSIQSENU : ACM#LOD3 >> ACMBuild.moveout
ECHO These are rex/CSIQCLS0 : ACM#MERG ACM#REX1 ACM#REX2 >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#LOD1                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#LOD1.jcl   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#LOD2                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#LOD2.jcl   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#LOD3                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#LOD3.skl   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#MERG                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#MERG.rex   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#REX1                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#REX1.rex   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#REX2                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#REX2.rex   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
ECHO ./  ADD  NAME=ACM#COPY                >> ACMBuild.moveout
TYPE ACM-build-without-Generates\ACM#COPY.jcl   >> ACMBuild.moveout
ECHO.          >> ACMBuild.moveout
REM
