REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO.   > BLANKS.hdr
ECHO ./  ADD  NAME=@README                     > PackageBuilder.moveout
ECHO These are rex/CSIQCLS0 : Moveout Package PKGELES PkgMaint >> PackageBuilder.moveout
ECHO These are pnl/CSIQPENU : PACKAGEP PKGESEL2 PKGESELS PMAINTPN >> PackageBuilder.moveout
ECHO These are ispfmsg/CSIQMENU : CIUU02 >> PackageBuilder.moveout
ECHO ./  ADD  NAME=Moveout                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\Moveout.rex   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=Package                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\Package.rex   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PKGELES                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\Package.rex   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PACKAGEP                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PACKAGEP.pnl   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PKGESEL2                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PKGESEL2.pnl   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PKGESELS                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PKGESELS.pnl   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PkgMaint                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PkgMaint.rex   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=PMAINTPN                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PMAINTPN.pnl   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
ECHO ./  ADD  NAME=CIUU02                >> PackageBuilder.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\CIUU02.ispfmsg   >> PackageBuilder.moveout
ECHO.          >> PackageBuilder.moveout
REM
