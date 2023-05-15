//WALJO11P JOB (0000),'PKGEMNTR',CLASS=A,MSGCLASS=Z,MSGLEVEL=(1,1),
//         NOTIFY=&SYSUID,REGION=0M
//*--------------------------------------------------------------
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL)
//*--------------------------------------------------------------
//*- To Report Recent package activity with Shipment info -------
//*--------------------------------------------------------------
//   EXPORT SYMLIST=(*)           <- make JCL symbols available
//*---
//   SET STRTDATE=2018/01/01      <- Specify date or # Days ago
//   SET STRTDATE='280 DAYS AGO'  <- Specify date or # Days ago
//*---
//   SET STOPDATE=2029/12/30      <- Specify stop/end data
//*-------------------------------------------------------------------
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY to find APPROVED and EXEC packages
//*             Also identify any PROD packages which may have shipped
//*-------------------------------------------------------------------
//STEP1    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0' (EXEC FROM NON-AUTH LIB)
//*---------  your Steplib ....
//   INCLUDE MEMBER=STEPLIB
//*---------
//CSVIPT01 DD *
  LIST PACKAGE ID '*'
     WHERE STATUS = (EXECUTED)
           OPTIONS
           QUALIFIER QUOTE
           TO FILE APIEXTR .
//*   CSV LIST FILE DD STATEMENT              (DEFAULT IS APIEXTR)
//APIEXTR  DD DSN=&&APIPKGE,
//         DCB=(DSORG=PS,RECFM=VB,LRECL=4092),
//         DISP=(MOD,CATLG,DELETE),UNIT=3390,
//         SPACE=(CYL,(5,5),RLSE)
//*   EXECUTION MESSAGES (CSV LOG MESSAGES)
//CSVMSGS1 DD SYSOUT=*
//*   EXECUTION MESSAGES (API LOG MESSAGES)
//C1MSGSA  DD SYSOUT=*
//*   ERROR FILE
//BSTERR   DD SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*-------------------------------------------------------------------
//*  PRINT RESULTS
//*-------------------------------------------------------------------
//STEP2    EXEC PGM=IEBGENER,COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APIPKGE,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*  Identify Packages to monitor
//*   -Collect package related data
//*   -Build additional package CSV utility commands for shipment rqsts
//*-------------------------------------------------------------------
//STEP3    EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//TABLE    DD DSN=&&APIPKGE,DISP=(OLD,PASS)
//*--
//   INCLUDE MEMBER=SYSEXEC
//*--
//PARMLIST DD  *
  HEADING  TBLOUT1 SELECTS  1
  MODEL1   TBLOUT1 OPTIONS2 A
  MODEL2   TBLOUT2 OPTIONS2 A
//SELECTS  DD *
  $Table_Type = "CSV"
  myOptions = ' '
//OPTIONS2 DD *
 if $row# < 1 then $SkipRow='Y'
 PKG_ID  = Left(PKG_ID,16)
 CAST_USRID = Left(CAST_USRID,8)
 EXEC_USRID = Left(EXEC_USRID,8)
 If ShipCount > 1 then myOptions = 'NOTITLE'
//HEADING  DD *
*PKG_ID---------- CASTUser ExecDate-- ExecUser DESCRIPTION--------------
//MODEL1   DD *
 &PKG_ID &CAST_USRID &EXEC_END_DATE &EXEC_USRID &DESCRIPTION
//MODEL2   DD *
  LIST PACKAGE SHIP
    FROM PACKAGE '&PKG_ID'
    OPTIONS &myOptions
    TO FILE APISHIP .
//SYSPRINT DD SYSOUT=*
//NOTHING  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT1  DD DSN=&&PKGEINFO,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(5,5),RLSE)
//TBLOUT2  DD DSN=&&CSVALSHP,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(5,5),RLSE)
//*-------------------------------------------------------------------
//*   EXECUTE CSV UTILITY to capture package Shipment data
//*             for packages identified/selected in prev step
//*-------------------------------------------------------------------
//STEP4    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0' (EXEC FROM NON-AUTH LIB)
//*---------  your Steplib ....
//   INCLUDE MEMBER=STEPLIB
//*---------
//CSVIPT01 DD DSN=&&CSVALSHP,DISP=(OLD,DELETE)
//APISHIP  DD DSN=&&APISHIP,
//         DCB=(DSORG=PS,RECFM=VB,LRECL=4092),
//         DISP=(MOD,CATLG,DELETE),UNIT=3390,
//         SPACE=(CYL,(5,5),RLSE)
//*   EXECUTION MESSAGES (CSV LOG MESSAGES)
//CSVMSGS1 DD SYSOUT=*
//*   EXECUTION MESSAGES (API LOG MESSAGES)
//C1MSGSA  DD SYSOUT=*
//*   ERROR FILE
//BSTERR   DD SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*---------------------------------------------------------------------
//*  PRINT RESULTS
//STEP5    EXEC PGM=IEBGENER,COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APISHIP,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*--  Save Shipment info in a format for next step
//*---------------------------------------------------------------------
//STEP6    EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//TABLE    DD DSN=&&APISHIP,DISP=(OLD,DELETE)
//*--
//   INCLUDE MEMBER=SYSEXEC
//*--
//OPTIONS  DD *
  $Table_Type = "CSV"
//MODEL    DD *
  Shipment.&PKG_ID = "&DEST_ID &SUBMIT_DATE &RMT_JOB_NAME"
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&&SHIPDATA,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,1),RLSE)
//*---------------------------------------------------------------------
//*  PRINT RESULTS
//STEP6B   EXEC PGM=IEBGENER,COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&SHIPDATA,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*  PRINT RESULTS
//STEP6C   EXEC PGM=IEBGENER,COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&PKGEINFO,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*--  Write report from all collected data
//*---------------------------------------------------------------------
//STEP7    EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//*--
//   INCLUDE MEMBER=SYSEXEC
//*--
//TABLE    DD DSN=&&PKGEINFO,DISP=(OLD,DELETE)
//SYSTSPRT DD  SYSOUT=*
//PARMLIST DD  *
  NOTHING  NOTHING SETUP    0
  MODEL    REPORT  SHIPDATA 0
  HEADINGS REPORT  NOTHING  1
  MODEL    REPORT  DETAILS  A
//SETUP    DD *,SYMBOLS=JCLONLY     <- Permits JCL variables here
  Shipment. = ' '
  StartDate = '&STRTDATE'
  StopDate  = '&STOPDATE'
  today = DATE('S')
  TodaysDate =  +
    Substr(today,1,4)'/'||Substr(today,5,2)'/' || +
    Substr(today,7);
  If StopDate > TodaysDate then StopDate = TodaysDate ;
  If Words(StartDate) = 3 then, +
     Do; daysago = Word(StartDate,1) ; BaseDate = DATE('B'); +
     NumDate = BaseDate - daysago; NewDate = DATE(S,NumDate,B); +
     StartDate = +
       Substr(NewDate,1,4)'/'||Substr(NewDate,5,2)'/' || +
       Substr(NewDate,7); +
     End
//SHIPDATA DD DSN=&&SHIPDATA,DISP=(OLD,DELETE)
//MODELSEL DD  *
** Selection Date range &StrDte - &EndDte
//HEADINGS DD  *
  *** Report of Package Activity &StartDate thru &StopDate ******
*Package--------- ExecDate-- Destin-- ShipDate RemoteJob                ent--
//DETAILS  DD  *
  $StripData = 'N' ;
  Package = Left(PKG_ID,16)
*
  If ExecDate < StartDate then $SkipRow = 'Y'
  If ExecDate > StopDate then $SkipRow = 'Y'
*
  PKG_ID   = Strip(PKG_ID)
  pkgeShip = Shipment.PKG_ID
  Destin   = Left(Word(pkgeShip,1),8)
  ShipDate = Left(Word(pkgeShip,2),8)
  RemotJob = Word(pkgeShip,3)
  Say Package pkgeShip
//MODEL    DD *
 &Package &ExecDate &Destin &ShipDate &RemotJob
//NOTHING  DD DUMMY
//SYSPRINT DD SYSOUT=*
//REPORT   DD SYSOUT=*
//*---------------------------------------------------------------------
