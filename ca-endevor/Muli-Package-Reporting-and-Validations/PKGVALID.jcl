//WALJO11P JOB (0000),
//         CLASS=A,MSGCLASS=X,REGION=4M,
//         NOTIFY=&SYSUID
//*==================================================================*
//*- To Report Multiple package Component Validations     -------
//*-- JCL:  SYSDE32.NDVR.TEAM.JCL(PKGVALID)   ------------------------
//*-- Update SET statements as needed, and list the packages  --------
//*-- to be validated together in the TABLE input in STEP1    --------
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL.CSV)
//*==================================================================*
//   EXPORT SYMLIST=(*)           <- make JCL symbols available
//*---
//   SET EXPORTDS='SYSDE32.NDVR.TEAM.EXPORTS'
//   SET ENVIRON=DEV
//*-------------------------------------------------------------------
//*   STEP 1 -- For each Package prefix, build EXPORT SCL
//*-------------------------------------------------------------------
//STEP1     EXEC PGM=IRXJCL,           <- Build EXPORT statements
//         PARM='ENBPIU00 A'
//TABLE    DD * <- List selected Packages/Package-Prefixes
* Package---------    -----Comment-------------------------------
  2#WJQJ4003906276    (Sandbox  ACTP0001) contains CLUELESS/GLUELESS
  2#WJSK1700940165    (Sandbox  ACTP0003)
  2#WKHK1207983231    (Sandbox  ACTP0005)
//MODEL1   DD *,SYMBOLS=JCLONLY
  EXPORT PACKAGE '&Package'
    TO DSNAME '&EXPORTDS'
            MEMBER '&SCLmbr'
   .
//MODEL2   DD *,SYMBOLS=JCLONLY
  SCAN#SCL  &EXPORTDS.(&SCLmbr)
//MODEL3   DD *
  Row4Package.&Package   = &RowNumber
  Package4Row.&RowNumber = '&Package'
//*--
//   INCLUDE MEMBER=SYSEXEC
//*--
//OPTIONS  DD *
   $NumberModelsAndTblouts= 3 ; /* Number of MODEL inputs */
   RowNumber = Right($row#,4,'0')
   SCLmbr = 'SCL#' || RowNumber
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//TBLOUT1  DD DSN=&&EXPORTS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//TBLOUT2  DD DSN=&&SCAN#SCL,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//TBLOUT3  DD DSN=&&PKGIDS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//**
//*---------------------------------------------------------------------
//*  PRINT RESULTS
//*---------------------------------------------------------------------
//SHOWME1   EXEC PGM=IEBGENER,COND=(0,LE)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&EXPORTS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*==================================================================*
//*   STGID#1 - EXECUTE CSV UTILITY
//*---  Collect Rexx stem array data for conversion of ----------------
//*---  Endevor Stage# to StageId                      ----------------
//*-------------------------------------------------------------------
//STGID#1   EXEC PGM=NDVRC1,REGION=4M, <- Endevor Stg# -> Stgid 1/2
//         PARM='BC1PCSV0'
//STEPLIB  DD  DISP=SHR,DSN=SYSDE32.NDVR.R1801.CSIQAUTU    SCMM@LIB
//         DD  DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQAUTH   SCMM@LIB
//         DD  DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQAUTU   SCMM@LIB
//         DD  DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQLOAD   SCMM@LIB
//CONLIB   DD  DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQLOAD   SCMM@LIB
//BSTIPT01 DD *
LIST STAGE '*' FROM ENVIRONMENT '*'
   TO DDNAME 'EXTRACTS'
   OPTIONS   RETURN ALL.
//EXTRACTS DD DSN=&&EXTRACTS,
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),
//      DISP=(NEW,PASS),UNIT=VIO,
//      SPACE=(TRK,(5,1),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//*--- Reformat CSV data ----------------------------------------------
//*--------------------------------------------------------------------
//STGID#2   EXEC PGM=IRXJCL,           <- Endevor Stg# -> Stgid 2/2
//          PARM='ENBPIU00 A',COND=(4,LT)
//   INCLUDE MEMBER=CSIQCLS0
//TABLE    DD  DSN=&&EXTRACTS,DISP=(OLD,DELETE)
//MODEL    DD *  <- All kinds of Stage info
  Location.&$row#   = '&ENV_NAME &STG_#'
  StageID.&ENV_NAME.&STG_#  = '&STG_ID'
  Stage_#.&ENV_NAME.&STG_ID = '&STG_#'
  NextMap.&ENV_NAME.&STG_#  = '&NEXT_ENV.&NEXT_STG_#'
//OPTIONS  DD *
* ENV_NAME STG_NAME STG_ID STG_# ENTRY_STG NEXT_ENV NEXT_STG_#
  $Table_Type = "CSV"
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUT   DD DSN=&&STAGEIDS,
//      DCB=(RECFM=FB,LRECL=080,BLKSIZE=8000,DSORG=PS),
//      DISP=(NEW,PASS),UNIT=VIO,
//      SPACE=(TRK,(1,1),RLSE)
//*--------------------------------------------------------------------
//*---  Keep Rexx stem array data for conversion of    ----------------
//*---  Endevor Stage# to StageId                      ----------------
//*--------------------------------------------------------------------
//STGSHOW   EXEC PGM=IEBGENER,         <- Show    Stg# -> Stgid
//          REGION=1024K
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&STAGEIDS,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*
//*-------------------------------------------------------------------
//*   CLEAR  -- Delete former EXPORT Dataset if found
//*-------------------------------------------------------------------
//CLEAR     EXEC PGM=IEFBR14           <- Remove old EXPORTS dataset
//EXPORTS  DD DSN=&EXPORTDS,
//         DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=32720),
//         DISP=(MOD,DELETE),DSNTYPE=LIBRARY,VOL=SER=TSOB32,
//         UNIT=3390,SPACE=(CYL,(10,10,10))
//*
//*-------------------------------------------------------------------
//ALLOC     EXEC PGM=IEFBR14           <- Alloc  new EXPORTS dataset
//EXPORTS  DD DSN=&EXPORTDS,
//         DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=32720),
//         DISP=(NEW,CATLG,KEEP),DSNTYPE=LIBRARY,VOL=SER=TSOB32,
//         UNIT=3390,SPACE=(CYL,(10,10,10))
//*---------------------------------------------------------------------
//*   STEP 2 -- EXPORT package SCL into PDS members
//*---------------------------------------------------------------------
//STEP2     EXEC PGM=NDVRC1,           <- Export Package SCLs
//         PARM=ENBP1000,
//         DYNAMNBR=1500
//*---------  your Steplib ....
//   INCLUDE MEMBER=STEPLIB
//*---------
//ENPSCLIN DD DSN=&&EXPORTS,DISP=(OLD,DELETE)
//C1MSGS1  DD SYSOUT=*
//C1MSGS2  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYMDUMP  DD DUMMY
//JCLOUT   DD DUMMY
//*---------------------------------------------------------------------
//*   STEP 3 -- SCAN Package SCLs - reformat into a Table   format.
//*---------------------------------------------------------------------
//SCAN#SCL  EXEC PGM=IKJEFT1B          <- Scan+Format Exported SCL
//SYSEXEC   DD DISP=SHR,DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
//SYSTSPRT  DD SYSOUT=*
//SYSTSIN   DD DSN=&&SCAN#SCL,DISP=(OLD,DELETE)
//SCAN#SCL  DD DUMMY
//RESULTS  DD DSN=&&SCLRSLTS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=100,BLKSIZE=32000),
//         DISP=(MOD,PASS),
//         UNIT=3390,SPACE=(CYL,(01,05),RLSE)
//*-------------------------------------------------------------------
//*  PRINT RESULTS
//*-------------------------------------------------------------------
//SHOWME2   EXEC PGM=IEBGENER,COND=(5,LE)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&SCLRSLTS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*   STEP 4 -- Build ACM Queries
//*---------------------------------------------------------------------
//STEP4     EXEC PGM=IRXJCL,           <- Build ACM Queries SCL
//         PARM='ENBPIU00 A'
//TABLE    DD DSN=&SCLRSLTS,DISP=(OLD,PASS)
//POSITION  DD *   <- Positions of Package SCL actions
   Count       5 10
   C1Action    9 21
   C1Envmnt   23 30
   C1Stage    32 32
   C1System   34 41
   C1Subsys   43 50
   C1ElType   52 59
   C1Element  61 91
//MODEL     DD *   <- MODEL FOR OUTPUT TO BE PRODUCED
     LIST USED COMPONENTS FOR
        ELEMENT  &C1Element
        ENVIRONMENT &C1Envmnt
        SYSTEM   &C1System  SUBSYSTEM  &C1Subsys
        TYPE     &C1ElType  STAGE NUMBER  2
     OPTIONS
  .
//OPTIONS   DD *
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  If Count = '000000' then $SkipRow = 'Y'
  C1Element = Strip(C1Element)
  C1Element = Strip(C1Element,'T',"'")
//   INCLUDE MEMBER=SYSEXEC
//SYSTSPRT  DD SYSOUT=*
//TBLOUT   DD DSN=&&ACMQRYS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(5,15),RLSE)
//*-------------------------------------------------------------------*
//*     ACMQuery in Batch                                             *
//*-------------------------------------------------------------------*
//STEP5     EXEC PGM=NDVRC1,           <- Run   ACM Queries
//          PARM='BC1PACMQ',REGION=4096K
//   INCLUDE MEMBER=STEPLIB
//ACMSCLIN DD DSN=&&ACMQRYS,DISP=(OLD,DELETE)
//ACMMSGS1 DD SYSOUT=*
//ACMMSGS2 DD SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*ACMOUT   DD SYSOUT=*
//ACMOUT   DD DSN=&&ACMOUT,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=100),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(CYL,(1,05),RLSE)
//*-------------------------------------------------------------------
//*  PRINT ACMQuery results
//*-------------------------------------------------------------------
//SHOWME3   EXEC PGM=IEBGENER,COND=(5,LE)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&ACMOUT,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*-------------------------------------------------------------------
//*-- Compare PAckaged Elements with ACMQuery results ----------------
//*--   Indicate in RC if any elements are missing from package(s)----
//*-------------------------------------------------------------------
//VALIDATE  EXEC PGM=IKJEFT1B,         <- Build Report
//          PARM='PKGVAL#2 &ENVIRON'
//PKGIDS    DD DSN=&&PKGIDS,DISP=(OLD,DELETE)   <- package ID info
//STAGEIDS  DD DSN=&&STAGEIDS,DISP=(OLD,DELETE) <- STG# to STGID
//SCL       DD DSN=&&SCLRSLTS,DISP=(OLD,PASS) <- Packaged SCL
//ACMQ      DD DSN=&&ACMOUT,DISP=(OLD,DELETE) <- ACMQuery results
//SYSEXEC   DD DISP=SHR,DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
//SYSTSPRT  DD SYSOUT=*
//SYSTSIN   DD DUMMY
//*PKGVAL#2  DD DUMMY           <- Turn Trace on/off
//PKGVAL#2  DD DUMMY           <- Turn Trace on/off
//RESULTS   DD SYSOUT=*
//*-------------------------------------------------------------------
//*-------------------------------------------------------------------
