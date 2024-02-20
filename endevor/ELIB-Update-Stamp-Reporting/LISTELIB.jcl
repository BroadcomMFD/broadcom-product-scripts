//WALJO11E JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//  EXPORT SYMLIST=(*)
//*--                       / Search Libraries with this prefix
//   SET HLQ=CADEMO.ENDV.PRCS.EMERQE
//   SET HLQ=SHARE.ENDV.ELIB
//   SET HLQ=CADEMO.ENDV
//   SET ELIBS='.BASE .DELT .LIST'      <- text that implies ELIB
//   SET THRESHLD=500      <- Report DSNS GE this STAMP value
//   SET CSIQCLS0=SHARE.NDVRSCM.R19.CSIQCLS0       <- Where is ENBPIU00
//**=================================================================**
//LISTDSNS EXEC PGM=IDCAMS      <- List datasets with ELIBS hlq
//SYSIN    DD  *,SYMBOLS=JCLONLY
 LISTCAT LEVEL('&HLQ') ALL
//STEPLIB  DD DISP=SHR,DSN=SYS1.LINKLIB   <- Confirm or remove
//AMSDUMP  DD SYSOUT=*
//SYSPRINT  DD DSN=&&LISTCAT,DISP=(,PASS),
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,
//     LRECL=120,RECFM=FB,BLKSIZE=0
//**=================================================================**
//SCANDSNS EXEC PGM=IKJEFT1B,   <- Scan + report Elibs over threshold
//         PARM='ENBPIU00 A '
//TABLE     DD DSN=&&LISTCAT,DISP=(OLD,DELETE)
//POSITION  DD *                <- Usable fields in IDCAM's SYSPRINT
  WhatKind 2 8
  Dataset 18 61
  AVGLRECL_lit 38 45
  inpAvgLrecl  58 63
//OPTIONS   DD *,SYMBOLS=JCLONLY   <- Rexx snippet for Table Tool
  $Table_Type = "positions"
  IF $row# < 1 THEN $SkipRow = 'Y'
  If AVGLRECL_lit = "AVGLRECL" then  AvgLrecl = Strip(inpAvgLrecl)
  If WhatKind /= 'CLUSTER' & WhatKind /= 'NONVSAM' then $SkipRow = 'Y'
  If WhatKind  = 'CLUSTER' & AvgLrecl /= '4088'    then $SkipRow = 'Y'
**//Examine Dataset to determine whether it is an Elib  \\
  wanted = 'N'; srchStrings = '&ELIBS'
*    loop thru your listed values for the JCL variable 'ELIBS'
  Do w# = 1 to Words(srchStrings); +
     srchTxt = Word(srchStrings,w#); +
     if Pos(srchTxt,Dataset) > 0 then wanted = 'Y'; +
  End
  If wanted = 'N' then $SkipRow = 'Y'
**\\Examine Dataset to determine whether it is an Elibs //
**- Get physical attributes of Dataset
  X = LISTDSI("'"Dataset"'" DIRECTORY RECALL SMSINFO)
  If SYSDSORG ='DA' then Say Dataset SYSLRECL SYSDSORG
**- DSORG must be DA or VS for Elibs -
  If SYSDSORG/='DA' & SYSDSORG/='VS'  THEN $SkipRow = 'Y'
  If SYSDSORG ='DA' & SYSLRECL/= 4096 THEN $SkipRow = 'Y'
  ThisDSORG = Right(SYSDSORG,3)
  ThisRECFM = Right(SYSRECFM,3)
**- Call BC1PNLIB with the INQUIRE request (in SYSIN)
  CALL BPXWDYN 'ALLOC DD(ELIBOLD) DA('Dataset') SHR REUSE'
  CALL BC1PNLIB ;  callRC= RC
  Say 'BC1PNLIB RC for' Dataset 'is' callRC;
**- If BC1PNLIB gets a high RC, then Dataset is not ELIB - skip it
  If callRC > 4 then $SkipRow= 'Y';
**- Scan the SYSPRINT output for "LAST UPDATE STAMP:" value
  cmd =  "EXECIO * DISKR SYSPRINT (Stem sys. Finis"; cmd
  Stamp# = 0
  Do sy# = 1 to sys.0 ; +
     record = sys.sy# ; +
     If Pos("LAST UPDATE STAMP:",record) =0 then Iterate; +
     Stamp# = Word(Substr(record,30),1); +
     Drop sys. ; Leave; +
  End
**- If "LAST UPDATE STAMP:" value < THRESHDL, then do not report it
  If Stamp# < &THRESHLD then $SkipRow= 'Y'
  Dataset = Left(Dataset,44)
//MODEL     DD *  /- Format of reported findinds
&Dataset &WhatKind &ThisDSORG &ThisRECFM &Stamp#
//SYSIN      DD *  <- Input for BC1PNLIB
INQUIRE   DDNAME = ELIBOLD .
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//SYSTSIN   DD DUMMY
//SYSTSPRT  DD SYSOUT=*
//*  / Your Endevor Steplib and CONLIB (if any) \
//STEPLIB  DD DISP=SHR,DSN=SHARE.NDVRSCM.R19.CSIQAUTU
//         DD DISP=SHR,DSN=SHARE.NDVRSCM.R19.CSIQAUTH
//         DD DISP=SHR,DSN=SHARE.NDVRSCM.R19.CSIQLOAD
//CONLIB   DD DISP=SHR,DSN=SHARE.NDVRSCM.R19.CSIQLOAD
//*  \ Your Endevor Steplib and CONLIB (if any) /
//SYSPRINT  DD DSN=&&SYSPRINT,DISP=(,PASS),
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,
//     LRECL=120,RECFM=FB,BLKSIZE=0
//BSTERR     DD SYSOUT=*
//SYSUDUMP   DD SYSOUT=*
//TBLOUT     DD SYSOUT=*   <- Reported output is sent here
