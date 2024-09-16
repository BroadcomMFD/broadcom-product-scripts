REM   In Windows, execute this command file to collect all Package
@ECHO OFF
ECHO ./  ADD  NAME=@README                     > ShippingSBOM.moveout
These items come from the Endevor GitHub at
  https://github.com/BroadcomMFD/broadcom-product-scripts
ECHO These are asm          : C1LSTBKO >> ShippingSBOM.moveout
ECHO These are rex/CSIQCLS0 : CMPNTGEN MODAHJOB >> ShippingSBOM.moveout
ECHO These are skl/CSIQSENU : #NFTPRCN #PSNFTP1 #PSNFTP6 #PSNFTPE #PSNFTPJ #PSNFTPP #PSNFTPS #PSXCOME #PSXCOMP #PSXCOMS #RJ0 #RJFCPY1 #RJFCPY2 #RJICPY1 #RJICPY2 #RJICPYL #RJICPYU #RJNDVRA #RJNDVRA #RJNDVRB #RJNDVRS C1BMXCOM C1BMXEOJ C1BMXFTP C1BMXHCN C1BMXIN C1BMXJOB C1BMXLIB C1BMXLOC C1BMXNDM C1BMXRCN C1BMXSBD HASHSBOM SCMM@REX >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1LSTBKO                >> ShippingSBOM.moveout
TYPE ASM\C1LSTBKO.asm   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=CMPNTGEN                >> ShippingSBOM.moveout
TYPE REXX\CMPNTGEN.rex   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=MODAHJOB                >> ShippingSBOM.moveout
TYPE REXX\MODAHJOB.rex   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#NFTPRCN                >> ShippingSBOM.moveout
TYPE ISPS\#NFTPRCN.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTP1                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTP1.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTP6                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTP6.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTPE                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTPE.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTPJ                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTPJ.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTPP                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTPP.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSNFTPS                >> ShippingSBOM.moveout
TYPE ISPS\#PSNFTPS.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSXCOME                >> ShippingSBOM.moveout
TYPE ISPS\#PSXCOME.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSXCOMP                >> ShippingSBOM.moveout
TYPE ISPS\#PSXCOMP.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#PSXCOMS                >> ShippingSBOM.moveout
TYPE ISPS\#PSXCOMS.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJ0                >> ShippingSBOM.moveout
TYPE ISPS\#RJ0.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJFCPY1                >> ShippingSBOM.moveout
TYPE ISPS\#RJFCPY1.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJFCPY2                >> ShippingSBOM.moveout
TYPE ISPS\#RJFCPY2.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJICPY1                >> ShippingSBOM.moveout
TYPE ISPS\#RJICPY1.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJICPY2                >> ShippingSBOM.moveout
TYPE ISPS\#RJICPY2.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJICPYL                >> ShippingSBOM.moveout
TYPE ISPS\#RJICPYL.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJICPYU                >> ShippingSBOM.moveout
TYPE ISPS\#RJICPYU.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJNDVRA                >> ShippingSBOM.moveout
TYPE ISPS\#RJNDVRA.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJNDVRA                >> ShippingSBOM.moveout
TYPE ISPS\#RJNDVRA.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJNDVRB                >> ShippingSBOM.moveout
TYPE ISPS\#RJNDVRB.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=#RJNDVRS                >> ShippingSBOM.moveout
TYPE ISPS\#RJNDVRS.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXCOM                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXCOM.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXEOJ                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXEOJ.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXFTP                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXFTP.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXHCN                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXHCN.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXIN                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXIN.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXJOB                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXJOB.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXLIB                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXLIB.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXLOC                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXLOC.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXNDM                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXNDM.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXRCN                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXRCN.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=C1BMXSBD                >> ShippingSBOM.moveout
TYPE ISPS\C1BMXSBD.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=HASHSBOM                >> ShippingSBOM.moveout
TYPE ISPS\HASHSBOM.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
ECHO ./  ADD  NAME=SCMM@REX                >> ShippingSBOM.moveout
TYPE ISPS\SCMM@REX.skl   >> ShippingSBOM.moveout
ECHO.          >> ShippingSBOM.moveout
REM
