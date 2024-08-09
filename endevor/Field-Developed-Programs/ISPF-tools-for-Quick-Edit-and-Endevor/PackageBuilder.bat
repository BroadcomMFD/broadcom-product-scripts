REM   In Windows, execute this command file to collect all Package Builder members for an upload
@ECHO OFF
ECHO.   > BLANKS.hdr
ECHO ./  ADD  NAME=@README                                        > PackageBuilder.hdr  
ECHO The members named PACKAGE and PKGELES are REXX              >> PackageBuilder.hdr
ECHO     CIUU02 is an ISPMLIB member (message)                   >> PackageBuilder.hdr
ECHO     all others are ISPPLIB members (Panels)                 >> PackageBuilder.hdr
ECHO ./  ADD  NAME=PACKAGE                                        > PACKAGE.hdr	
ECHO ./  ADD  NAME=PKGELES                                        > PKGELES.hdr	
ECHO ./  ADD  NAME=PACKAGEP                                       > PACKAGEP.hdr
ECHO ./  ADD  NAME=PKGESELS                                       > PKGESELS.hdr
ECHO ./  ADD  NAME=PKGESEL2                                       > PKGESEL2.hdr
ECHO ./  ADD  NAME=CIUU02                                         > CIUU02.hdr	
copy PACKAGE.hdr + Package.rex + BLANKS.hdr PACKAGE.hdr
copy PKGELES.hdr + Package.rex + BLANKS.hdr PKGELES.hdr
copy PACKAGEP.hdr + PACKAGEP.pnl + BLANKS.hdr  PACKAGEP.hdr
copy PKGESELS.hdr + PKGESELS.pnl + BLANKS.hdr  PKGESELS.hdr
copy PKGESEL2.hdr + PKGESEL2.pnl + BLANKS.hdr  PKGESEL2.hdr
copy CIUU02.hdr + CIUU02.ispfmsg + BLANKS.hdr CIUU02.hdr
copy PackageBuilder.hdr+PACKAGE.hdr+PKGELES.hdr+PACKAGEP.hdr+PKGESELS.hdr+PKGESEL2.hdr+CIUU02.hdr PackageBuilder.moveout
REM
del *.hdr
REM PAUSE


