//WALJO11E JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//  EXPORT SYMLIST=(*)
//*--                       / Search Libraries with this prefix
//   SET HLQ=SHARE.ENDV.ELIB
//   SET HLQ=CADEMO.ENDV
//   SET ELIBS='.BASE .DELT .LIST .ELIB'  <- text that implies ELIB
//   SET THRESHLD=0        <- Report DSNS GE this STAMP value
//   SET CSIQCLS0=SHARE.NDVRSCM.R19.CSIQCLS0       <- Where is ENBPIU00
//   SET SYSEXEC=PSP.ENDV.TEAM.REXX                <- Where is ELIBSCAN
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
//         PARM='ENBPIU00 PARMLIST'
//TABLE     DD DSN=&&LISTCAT,DISP=(OLD,DELETE)
//PARMLIST  DD *                <- Usable fields in IDCAM's SYSPRINT
  NOTHING   NOTHING  DEFAULTS  0
  NOTHING   NOTHING  SCANNING  A
  MODEL     REPORT   REPORTNG  1
//POSITION  DD *                <- Usable fields in IDCAM's SYSPRINT
  record        1 70             CLUSTER  or NONVSAM
  whatKind      2 8              CLUSTER  or NONVSAM
  CLUSTER_lit   9 15             "CLUSTER"
  Dataset      18 61             Dataset name
  AVGLRECL_lit 38 45             "AVGLRECL"
  AvgLRECL     58 63             Average LRECL for CLUSTER
//DEFAULTS  DD *,SYMBOLS=JCLONLY   <- Setting initial + Default values
  $Table_Type = "positions"
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  srchStrings = '&ELIBS'
  ELIB_List   = ''
//SCANNING  DD *                   <- Collect ELIB names and LRECLs
  If AVGLRECL_lit = "AVGLRECL" then, +
     Do; AvgLrecl = Strip(AvgLrecl,'L','-'); +
     If AvgLrecl /= '4088' then, +
        Do; whereDsn = Wordpos(thisDataset,ELIB_List); +
        If whereDSN>0 then ELIB_List=Delword(ELIB_LIST,whereDSN,1); +
        End; +
     End
  If whatKind /= 'CLUSTER' & whatKind /= 'NONVSAM' then $SkipRow = 'Y'
  thisDataset = Dataset
*
  If Words(srchStrings) = 0 then wanted = 'Y' ELSE wanted = 'N';
* ** loop thru your listed values for the JCL variable 'ELIBS'
  Do w# = 1 to Words(srchStrings); +
     srchTxt = Word(srchStrings,w#); +
     if Pos(srchTxt,Dataset) > 0 then wanted = 'Y'; +
  End
  If wanted = 'N' then $SkipRow = 'Y'
  If whatKind = 'CLUSTER' then ELIB_List = ELIB_List Dataset;
*** Get physical attributes of BDAM datasets
  If whatKind = 'NONVSAM' then, +
     Do; X = LISTDSI("'"Dataset"'" DIRECTORY RECALL SMSINFO); +
     If SYSLRECL = 4096 & SYSDSORG = 'DA' then, +
        ELIB_List = ELIB_List Dataset; +
     End;
//REPORTNG  DD *,SYMBOLS=JCLONLY   <- Run BC1PNLIB for listed ELIBs
  Do w# = 1 to Words(ELIB_List); +
     Dataset = Word(ELIB_List,w#); +
     Say 'Processing' Dataset ; +
     Stamp# = ELIBSCAN(Dataset); +
     Dataset = Left(Dataset,44); +
     If Stamp# >= &THRESHLD then x = BuildFromMODEL(MODEL); +
  End;
  $SkipRow= 'Y'
//MODEL     DD *  /- Format of reported findinds
&Dataset &Stamp#
//SYSIN      DD *  <- Input for BC1PNLIB
INQUIRE   DDNAME = ELIBOLD .
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&SYSEXEC
//*ELIBSCAN  DD DUMMY     <- Turn on/off Trace
//SYSTSIN   DD DUMMY
//NOTHING   DD DUMMY
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
//REPORT     DD SYSOUT=*   <- Reported output is sent here
