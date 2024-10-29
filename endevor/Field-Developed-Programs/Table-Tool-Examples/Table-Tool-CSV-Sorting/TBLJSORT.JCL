//IBMUSER JOB (0000),'Your-NAme',CLASS=A,PRTY=6,
//  MSGCLASS=X,USER=&SYSUID,REGION=7M,NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//*- Two Examples for Generating and Sorting ENDEVOR CSV data, -------*
//*- and then using Table Tool on the Sorted data.             -------*
//*-------------------------------------------------------------------*
// JCLLIB  ORDER=(Library-For-Includes)
//  EXPORT SYMLIST=(*)
//*----
//  SET REXXLIB='Your.REXX.LIB'
//  SET CSIQCLS0='Your.CSIQCLS0'
//*----
//  SET C1ENVMNT='DEV'
//  SET C1SYSTEM='FINANCE'
//*----
//  SET PACKAGE='TEST*'
//*-------------------------------------------------------------------*
//*--- USE CSV TO COLLECT ELEMENT INFORMATION                ---------*
//*-------------------------------------------------------------------*
//ELM#CSV  EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//*--
//   INCLUDE MEMBER=STEPLIB
//*--
//BSTIPT01 DD *,SYMBOLS=JCLONLY
LIST ELEMENT
'*'
     FROM ENVIRONMENT  &C1ENVMNT SYSTEM &C1SYSTEM SUBSYSTEM '*'
          TYPE  '*'
          STAGE NUMBER '*'
     TO DDNAME 'TABLE'
     OPTIONS NOSEARCH   RETURN FIRST PATH PHYSICAL .
//TABLE    DD DSN=&&EXTRACT1,
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(5,5),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*
//*==================================================================*
//*--- Sort a CSV File (for Table Tool extracting/reporting)----------*
//*---  (saves Heading in SORTOUT)                          ----------*
//*-------------------------------------------------------------------*
//TBL#SORT EXEC PGM=IRXJCL,PARM=TBL#SORT
//SORTIN   DD  DSN=&&EXTRACT1,DISP=(OLD,PASS)
//SORTOUT  DD  DSN=&&EXTRACT2,DISP=(NEW,PASS),  **Heading ***
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      SPACE=(CYL,(5,5),RLSE)
//SORTPARM DD * / variable A/D |(for Ascending/Descending) *example*
  UPDT_DATE  D
  UPDT_TIME  D
  LAST_ACT_COMMENT  A
  ELM_NAME   A
//SYSEXEC  DD DISP=SHR,DSN=&REXXLIB
//SYSTSPRT DD SYSOUT=*
//SHOWME   DD SYSOUT=*
//SYSIN    DD DSN=&&SYSIN,DISP=(NEW,PASS),
//            UNIT=SYSDA,SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=32000)
//*-------------------------------------------------------------------*
//DOSORT   EXEC PGM=SORT
//SYSIN    DD DSN=&&SYSIN,DISP=(OLD,DELETE)
//SORTIN   DD  DSN=&&EXTRACT1,DISP=(OLD,DELETE)
//SORTOUT  DD  DSN=&&EXTRACT2,DISP=(MOD,PASS),   **Append to heading**
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      SPACE=(CYL,(5,5),RLSE)
//SYSOUT   DD SYSOUT=A
//*-------------------------------------------------------------------*
//*-- SHOW RESULTS USING TABLE TOOL  ---------------------------------*
//*--------------------------------------------------------------------
//ELREPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 A',COND=(4,LE)
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//*--
//TABLE    DD  DSN=&&EXTRACT2,DISP=(OLD,DELETE)
//MODEL    DD *
 &UPDT_DATE &UPDT_TIME &LAST_ACT_COMMENT &ELM_NAME &LAST_ACT_USRID
//OPTIONS  DD *
  $Table_Type = "CSV"
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  ELM_NAME = Left(ELM_NAME,08)
  UPDT_TIME = Left(UPDT_TIME,5)
  SBS_NAME = Left(SBS_NAME,8)
  LAST_ACT_COMMENT  = Left(LAST_ACT_COMMENT,30)
//TBLOUT   DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//*==================================================================*
//*== Second Example:  Sorting and reporting Package CSV data =======*
//*==================================================================*
//*-------------------------------------------------------------------
//*   Report Package element actions for selected packages
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//PKG#01   EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//   INCLUDE MEMBER=STEPLIB
//BSTIPT01 DD *,SYMBOLS=JCLONLY
    LIST PACKAGE ID '&PACKAGE'
         TO FILE CSVEXTR  .
//CSVEXTR  DD DSN=&&CSVFILE,
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      DISP=(NEW,PASS),
//      SPACE=(TRK,(5,1),RLSE),UNIT=3390
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*-------------------------------------------------------------------*
//*--- Sort a CSV File (for Table Tool extracting/reporting)----------*
//*-------------------------------------------------------------------*
//PKG#02   EXEC PGM=IRXJCL,PARM=TBL#SORT
//SORTIN   DD DSN=&&CSVFILE,DISP=(OLD,PASS)
//SORTOUT  DD DSN=&&CSVFIL2,
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(CYL,(5,1),RLSE),UNIT=3390
//SORTPARM DD * / variable A/D |(for Ascending/Descending) *example*
 DESCRIPTION  A
 PKG_ID    A
 SCL_DATE  D
 SCL_TIME  D
 UPDT_DATE A
 UPDT_TIME A
//SYSEXEC  DD DISP=SHR,DSN=&REXXLIB
//SYSTSPRT DD SYSOUT=*
//SHOWME   DD SYSOUT=*
//SYSIN    DD DSN=&&SYSIN,DISP=(NEW,PASS),
//            UNIT=SYSDA,SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=32000)
//*-------------------------------------------------------------------*
//PKG#03   EXEC PGM=SORT
//SYSIN    DD DSN=&&SYSIN,DISP=(OLD,DELETE)
//SORTIN   DD DSN=&&CSVFILE,DISP=(OLD,DELETE)
//SORTOUT  DD DSN=&&CSVFIL2,DISP=(MOD,PASS)
//SYSOUT   DD SYSOUT=A
//*-------------------------------------------------------------------*
//*-- Show RESULTS ---------------------------------------------------*
//*--------------------------------------------------------------------
//PKG#04   EXEC PGM=IRXJCL,PARM='ENBPIU00 A '
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//TABLE    DD  DSN=&&CSVFIL2,DISP=(OLD,DELETE)
//OPTIONS  DD *
DESCRIPTION = Left(DESCRIPTION,20)
PKG_ID      = Left(PKG_ID,16)
//MODEL    DD *
PKG: &DESCRIPTION &PKG_ID &SCL_DATE &SCL_TIME
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD SYSOUT=*
