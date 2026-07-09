REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > PDAandRetro.moveout
ECHO These are rex/CSIQCLS0 : @SITE Notify PDA RETRO WhereIam Window >> PDAandRetro.moveout
ECHO These are ispfmsg/CSIQMENU : RETR01 >> PDAandRetro.moveout
ECHO These are pnl/CSIQPENU : RETROPOP RETRSHOW >> PDAandRetro.moveout
ECHO ./  ADD  NAME=@SITE                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\@SITE.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=Notify                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\Notify.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=PDA                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\PDA.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=RETR01                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\RETR01.ispfmsg   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=RETRO                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\RETRO.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=RETROPOP                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\RETROPOP.pnl   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=RETRSHOW                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\RETRSHOW.pnl   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=WhereIam                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\WhereIam.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
ECHO ./  ADD  NAME=Window                >> PDAandRetro.moveout
TYPE ISPF-tools-for-Quick-Edit-and-Endevor\Window.rex   >> PDAandRetro.moveout
ECHO.          >> PDAandRetro.moveout
REM
