REM   In Windows, execute this command file to collect members for the Parallel Development Alert and RETRO
@ECHO OFF
ECHO.   > BLANKS.hdr
ECHO ./  ADD  NAME=@README                                        > PDAandRetro.hdr  
ECHO PDA and NOTIFY are REXX MEMBERS                             >> PDAandRetro.hdr
ECHO     RETR01 is an ISPMLIB (Message) member                   >> PDAandRetro.hdr
ECHO     all others are ISPPLIB (PAnel) members                  >> PDAandRetro.hdr
ECHO ./  ADD  NAME=PDA                                            > PDA.hdr	
ECHO ./  ADD  NAME=NOTIFY                                         > NOTIFY.hdr	
ECHO ./  ADD  NAME=RETRO                                          > RETRO.hdr	
ECHO ./  ADD  NAME=RETRSHOW                                       > RETRSHOW.hdr
ECHO ./  ADD  NAME=RETROPOP                                       > RETROPOP.hdr
ECHO ./  ADD  NAME=RETRO01                                        > RETRO01.hdr
copy PDA.hdr + PDA.rex + BLANKS.hdr PDA.hdr
copy Notify.hdr + Notify.rex + BLANKS.hdr Notify.hdr
copy RETRO.hdr + RETRO.rex + BLANKS.hdr  RETRO.hdr
copy RETRSHOW.hdr + RETRSHOW.pnl + BLANKS.hdr  RETRSHOW.hdr
copy RETROPOP.hdr + RETROPOP.pnl + BLANKS.hdr  RETROPOP.hdr
copy RETRO01.hdr + RETR01.ispfmsg + BLANKS.hdr  RETRO01.hdr
copy PDAandRetro.hdr+PDA.hdr+NOTIFY.hdr+RETRSHOW.hdr+RETROPOP.hdr+RETRO01.hdr PDAandRetro.moveout     
REM
del *.hdr
REM PAUSE


