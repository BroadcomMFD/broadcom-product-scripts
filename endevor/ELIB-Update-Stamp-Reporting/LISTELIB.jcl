//WALJO11E JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//  EXPORT SYMLIST=(*)
//*--                       / Search Libraries with this prefix
//   SET HLQ=SHARE.ENDV.ELIB
//   SET HLQ=CADEMO.ENDV
//   SET ELIBS='.BASE .DELT .LIST .ELIB'  <- text that implies ELIB
//   SET THRESHLD=350      <- Report DSNS GE this STAMP value
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
  MODEL     REPORT   REPORTRX  A
//POSITION  DD *                <- Usable fields in IDCAM's SYSPRINT
  whatKind      2 8              CLUSTER  or NONVSAM
  Dataset      18 61             Dataset name
//DEFAULTS  DD *,SYMBOLS=JCLONLY   <- Setting initial + Default values
  $Table_Type = "positions"
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  srchStrings = '&ELIBS'
  Threshold   = &THRESHLD
//REPORTRX  DD *                   <- Scan for ELIB data and report
  If whatKind /= 'CLUSTER' & whatKind /= 'NONVSAM' then $SkipRow = 'Y'
  thisDataset = Dataset
  wanted = 'N'
  If Words(srchStrings) = 0 then wanted = 'Y'
* ** loop thru your listed values for the JCL variable 'ELIBS'
  Do w# = 1 to Words(srchStrings); +
     srchTxt = Word(srchStrings,w#); +
     if Pos(srchTxt,Dataset) > 0 then wanted = 'Y'; +
  End
* Say 'Processing' Dataset wanted
  If wanted = 'N' then $SkipRow = 'Y'
  Stamp# = ELIBSCAN(Dataset);
* Say 'Processed ' Dataset Stamp#
  Dataset = Left(Dataset,44);
  If Stamp# < Threshold then $SkipRow = 'Y'
//MODEL     DD *  /- Format of reported findinds
&Dataset &whatKind &Stamp#
//SYSIN      DD *  <- Input for BC1PNLIB
INQUIRE   DDNAME = ELIBOLD .
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&SYSEXEC
//ELIBSCAN  DD DUMMY     <- Turn on/off additional messages
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
//BSTERR     DD DUMMY                /  SYSOUT=*
//SYSUDUMP   DD SYSOUT=*
//REPORT     DD SYSOUT=*   <- Reported output is sent here
