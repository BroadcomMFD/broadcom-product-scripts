//*-------------------------------------------------------------------
//*---Checks to see if a file is empty. 
//*   Tells you in SYSTSPRT how many records are found 
//*   Gives RC=5 if file is empty. Otherwise RC=0
//*-----This example is testing the ddname SELECTED 
//*-------------------------------------------------------------------
//FINDANY  EXEC PGM=IRXJCL, PARM='ENBPIU00 1'   
//OPTIONS  DD *    - see if SELECTED (ddname)  is empty
  cmd = 'EXECIO * DISKR SELECTED (Stem selct. Finis'
  Say cmd; cmd;
  Say selct.0 'members are selected'
  If selct.0 < 1 then Exit(5)
  Exit(0)
//SELECTED DD DSN=&&SELECTED,DISP=(OLD,PASS)
//SYSEXEC  DD DISP=SHR,DSN=<your-CSIQCLS0>
//SYSTSPRT DD SYSOUT=*