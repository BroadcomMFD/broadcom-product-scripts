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
//*------           / where are INCLUDES: STEPLIB,CSIQCLS0,SYSEXEC
//   SET EXPORTDS='SYSDE32.NDVR.TEAM.EXPORTS'
//   SET ENVIRON=DEV        <-From Env
//   SET STAGE#=2           <-From Stage number
//*------                     starting point for listed packages.
//   SET CIRCLRC=5          <-RC when finding circular references
//   SET PROMSTGS='NONE'    <-'NONE' / One or more Env.Stg values
//*------                     separated by commas to substitute with
//*------                     ENVIRON.STAGE# when found
//   SET PATHINIT='DEV.2'   <-Env.Stg values mapping to ENVIRON.STAGE#
//*------                     can be space or comma delimited.
//*-------------------------------------------------------------------
//*@ PKGLIST1 - For each Package prefix, build LIST PACKAGE SCL.
//*-------------------------------------------------------------------
//PKGLIST1  EXEC PGM=IRXJCL,           <- Build LIST PACKAGE SCL
//          PARM='ENBPIU00 A'             for listed pkg prefixes
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//TABLE    DD * <- List selected Packages/Package-Prefixes
* Package---------    -----Comment-------------------------------
  D#WKYL5451187354    (Sandbox  ACTP0005)
  D#WKYL5657683637    (Sandbox  ACTP0004) -> FINAPC01/JUNKCOPY/PG000054
  D#WKYL5919699963    (Sandbox  ACTP0002) contains COB TEST*
  D#WKYM0242257206    (Sandbox  ACTP0003)
  D#WKYM2606593342    (Sandbox  ACTP0001)
  D#WKYO0226831512    (Sandbox  ACTP0007)   depends on ACTP0004
  D#WKYO2326944798    (Sandbox  ACTP0007)   depends on previous
  FINA#WLFP1016782     Promotion package
  SHIP#W%%O*           Admin packages
  FINA#WL%P*           Actp004
//MODEL    DD *
    LIST PACKAGE SCL
         TO FILE CSVEXTR
         FROM PACKAGE '&Package' .
//OPTIONS  DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUT   DD DSN=&&LISTPKGS,   <- List Package SCL
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//*---------------------------------------------------------------------
//*@ SHOWME1A - Show downstream commands etc
//*---------------------------------------------------------------------
//SHOWME1A  EXEC PGM=IEBGENER,         <- Show CSV LIST commands
//          COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD *
****  Content from DSN=&&LISTPKGS****
//         DD DSN=&&LISTPKGS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*
//*-------------------------------------------------------------------
//*@ PKGLIST2 - EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//PKGLIST2  EXEC PGM=NDVRC1,REGION=4M, <- CSV for PKG SCL
//          PARM='BC1PCSV0',
//          COND=(4,LT)
//   INCLUDE MEMBER=STEPLIB            <- Endevor STEPLIB+CONLIB
//BSTIPT01 DD DSN=&&LISTPKGS,DISP=(OLD,DELETE)
//CSVEXTR  DD DSN=&&CSVFILE,
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(TRK,(5,1),RLSE),UNIT=3390
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//*@ PKGLIST3 - format commands for Pkgs with SCL  --------------------
//*--------------------------------------------------------------------
//PKGLIST3  EXEC PGM=IRXJCL,           <- Creates formatted commands
//          PARM='ENBPIU00 A ',           for Pkgs with SCL
//          COND=(4,LT)
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)
//OPTIONS  DD *
   $QuietMessages = 'Y'         /* Bypass messages Y/N        */
   IF PKG_ID = lastPKG_ID then $SkipRow = 'Y'
   IF PKG_ID = 'PKG ID'   then $SkipRow = 'Y'
   lastPKG_ID = PKG_ID
   $NumberModelsAndTblouts= 4 ; /* Number of MODEL inputs */
   RowNumber = Right($row#,4,'0')
   SCLmbr = 'SCL#' || RowNumber
//MODEL1   DD *,SYMBOLS=JCLONLY
  EXPORT PACKAGE '&PKG_ID'
    TO DSNAME '&EXPORTDS'
            MEMBER '&SCLmbr'
   .
//MODEL2   DD *,SYMBOLS=JCLONLY
  SCAN#SCL  &EXPORTDS.(&SCLmbr)
//MODEL3   DD *
  Row4Package.&PKG_ID    = &RowNumber
  Package4Row.&RowNumber = '&PKG_ID'
//MODEL4   DD *
  LIST PACKAGE ACTION FROM PACKAGE '&PKG_ID'
       TO FILE PKGHIST
       OPTIONS PROMOTION HISTORY .
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUT1  DD DSN=&&EXPORTS,    <- Export SCL
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//TBLOUT2  DD DSN=&&SCAN#SCL,   <- SCAN#SCL command for each Pkg
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//TBLOUT3  DD DSN=&&PKGIDS,     <- Package<->Row# info
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//TBLOUT4  DD DSN=&&CSVALPKG,   <- LIST PACKAGE ... for CSV Calls
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//**
//*---------------------------------------------------------------------
//*@ SHOWME1B - Show downstream commands etc
//*---------------------------------------------------------------------
//SHOWME1B  EXEC PGM=IEBGENER,         <- Show formatted commands
//          COND=(4,LT)                   and Rexx stem array data
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD *
****  Content from DSN=&&EXPORTS ****
//         DD DSN=&&EXPORTS,DISP=(OLD,PASS)
//         DD *
****  Content from DSN=&&SCAN#SCL****
//         DD DSN=&&SCAN#SCL,DISP=(OLD,PASS)
//         DD *
****  Content from DSN=&&PKGIDS  ****
//         DD DSN=&&PKGIDS,DISP=(OLD,PASS)
//         DD *
****  Content from DSN=&&CSVALPKG****
//         DD DSN=&&CSVALPKG,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*
//*==================================================================*
//*@ STGINFO1 - EXECUTE CSV UTILITY
//*---  Collect Rexx stem array data for conversion of ----------------
//*---  Endevor Stage# to StageId                      ----------------
//*-------------------------------------------------------------------
//STGINFO1  EXEC PGM=NDVRC1,REGION=4M, <- Endevor Stg# -> Stgid 1/2
//          PARM='BC1PCSV0',              CSV for stage information
//          COND=(4,LT)                   Also, CSV for Pkg info
//   INCLUDE MEMBER=STEPLIB            <- Endevor STEPLIB+CONLIB
//BSTIPT01 DD *
LIST STAGE '*' FROM ENVIRONMENT '*'
   TO DDNAME 'EXTRACTS'
   OPTIONS   RETURN ALL.
//         DD DSN=&&CSVALPKG,DISP=(OLD,PASS)
//EXTRACTS DD DSN=&&EXTRACTS,   <- CSV Stage information
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),
//      DISP=(NEW,PASS),UNIT=VIO,
//      SPACE=(TRK,(5,1),RLSE)
//PKGHIST  DD DSN=&&PKGHIST,    <- CSV package action + history
//      DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000,DSORG=PS),
//      DISP=(NEW,PASS),UNIT=3390,
//      SPACE=(CYL,(5,1),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//*@ STGINFO2 - Reformat CSV data for Stage info
//*---  Keep Rexx stem array data for conversion of    ----------------
//*---  Endevor Stage# to StageId                      ----------------
//*--------------------------------------------------------------------
//STGINFO2  EXEC PGM=IRXJCL,           <- Endevor Stg# -> Stgid 2/2
//          PARM='ENBPIU00 A',            format CSV stage info
//          COND=(4,LT)
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//TABLE    DD  DSN=&&EXTRACTS,DISP=(OLD,DELETE)
//MODEL    DD *  <- All kinds of Stage info
  Location.&$row#   = '&ENV_NAME &STG_#'
  StageID.&ENV_NAME.&STG_#  = '&STG_ID'
  Stage_#.&ENV_NAME.&STG_ID = '&STG_#'
  NextMap.&ENV_NAME.&STG_#  = '&NEXT_ENV.&NEXT_STG_#'
//OPTIONS  DD *
* ENV_NAME STG_NAME STG_ID STG_# ENTRY_STG NEXT_ENV NEXT_STG_#
  $Table_Type = "CSV"
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUT   DD DSN=&&STAGEIDS,
//      DCB=(RECFM=FB,LRECL=080,BLKSIZE=8000,DSORG=PS),
//      DISP=(NEW,PASS),UNIT=VIO,
//      SPACE=(TRK,(1,1),RLSE)
//*--------------------------------------------------------------------
//*@ STGSHOW  - Show stage-related stem array data
//*---  Endevor Stage# to StageId                      ----------------
//*--------------------------------------------------------------------
//STGSHOW   EXEC PGM=IEBGENER,         <- Show    Stg# -> Stgid
//          COND=(4,LT)
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1    DD DSN=&&STAGEIDS,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN     DD DUMMY                              CONTROL STATEMENTS
//SYSUDUMP  DD SYSOUT=*
//*
//*-------------------------------------------------------------------
//*@ CLEAR   -- Delete former EXPORT Dataset if found
//*-------------------------------------------------------------------
//CLEAR     EXEC PGM=IEFBR14,          <- Remove old EXPORTS dataset
//          COND=(4,LT)
//EXPORTS  DD DSN=&EXPORTDS,
//         DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=32720),
//         DISP=(MOD,DELETE),DSNTYPE=LIBRARY,VOL=SER=TSOB32,
//         UNIT=3390,SPACE=(CYL,(10,10,10))
//*
//*-------------------------------------------------------------------
//*@ ALLOC   -- Alocate  new  EXPORT Dataset
//*-------------------------------------------------------------------
//ALLOC     EXEC PGM=IEFBR14,          <- Alloc  new EXPORTS dataset
//          COND=(4,LT)
//EXPORTS  DD DSN=&EXPORTDS,
//         DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=32720),
//         DISP=(NEW,CATLG,KEEP),DSNTYPE=LIBRARY,VOL=SER=TSOB32,
//         UNIT=3390,SPACE=(CYL,(10,10,10))
//*---------------------------------------------------------------------
//*@ PKGSCL1 -- EXPORT package SCL into PDS members
//*---------------------------------------------------------------------
//PKGSCL1   EXEC PGM=NDVRC1,           <- Export Package SCLs
//          PARM=ENBP1000,
//          COND=(4,LT)
//*---------  your Steplib ....
//   INCLUDE MEMBER=STEPLIB            <- Endevor STEPLIB+CONLIB
//*---------
//ENPSCLIN DD DSN=&&EXPORTS,DISP=(OLD,DELETE)
//C1MSGS1  DD SYSOUT=*
//C1MSGS2  DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYMDUMP  DD DUMMY
//JCLOUT   DD DUMMY
//*---------------------------------------------------------------------
//*@ PKGSCL2 -- Capture historical SCL for Promotion Packages
//*---------------------------------------------------------------------
//PKGSCL2   EXEC PGM=IRXJCL,           <- Promo pkg SCL update 1/2
//          PARM='ENBPIU00 PARMLIST',
//          COND=(4,LT)
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//TABLE    DD DSN=&&PKGHIST,           <- CSV package action + history
//            DISP=(OLD,DELETE)
//PARMLIST DD *               <- Default Model
  NOTHING  NOTHING  CHKEMPTY  0
  NOTHING  NOTHING  STAGEIDS  0
  NOTHING  NOTHING  PKGIDS    0
  MODELDF  TBLOUT   OPTIONS   A
//CHKEMPTY DD *               <- Default Model
  Say 'CHKEMPTY'
  "EXECIO 3 DISKR TABLE (Stem csv. Finis"
  say 'csv.0=' csv.0
  If csv.0 < 2 then Exit
//STAGEIDS DD DSN=&&STAGEIDS,DISP=(OLD,PASS)
//PKGIDS   DD DSN=&&PKGIDS,DISP=(OLD,PASS)
//MODELMBR DD *               <- Default Model
./   ADD  NAME=&SCLmbr
* &PKG_ID SCL created in PKGSCL2 of the PKGVALID job
//MODELDF  DD *               <- Default Model
  &ELM_ACT ELEMENT &ELM_@S@
    FROM ENVIRONMENT &ENV_NAME_@S@ STAGE &STG_ID_@S@
         SYSTEM  &SYS_NAME_@S@ SUBSYSTEM &SBS_NAME_@S@
         TYPE &TYPE_NAME_@S@ .
//MODELTR  DD *               <- Transfer Model
  TRANSFER ELEMENT &ELM_@S@
    FROM ENVIRONMENT &ENV_NAME_@S@ STAGE &STG_ID_@S@
         SYSTEM  &SYS_NAME_@S@ SUBSYSTEM &SBS_NAME_@S@
         TYPE &TYPE_NAME_@S@
    TO   ENVIRONMENT &ENV_NAME_@T@ STAGE &STG_ID_@T@
         SYSTEM  &SYS_NAME_@T@ SUBSYSTEM &SBS_NAME_@T@
         TYPE &TYPE_NAME_@T@ .
//OPTIONS  DD *,SYMBOLS=JCLONLY
* ENV_NAME STG_NAME STG_ID STG_# ENTRY_STG NEXT_ENV NEXT_STG_#
  $Table_Type = "CSV"
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  STG_num_@S@ = Stage_#.ENV_NAME_@S@.STG_ID_@S@
  Say ENV_NAME_@S@ STG_ID_@S@ STG_num_@S@
  If ENV_NAME_@S@ /= '&ENVIRON' then $SkipRow = 'Y'
  If STG_num_@S@  /= '&STAGE#'  then $SkipRow = 'Y'
  Member = Row4Package.PKG_ID
  RowNumber = Right(Member,4,'0')
  SCLmbr = 'SCL#' || RowNumber
  If PKG_ID /= lastPKG_ID then x = BuildFromMODEL(MODELMBR)
  lastPKG_ID = PKG_ID
  MODEL = 'MODELDF'
  If Substr(ELM_ACT,1,4) = 'TRAN' then MODEL = 'MODELTR'
  $my_rc = 2
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUT   DD DSN=&&IEBUPDT,    <- IEBUPD cmds for Pkg SCL
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(1,5),RLSE)
//*---------------------------------------------------------------------
//*@ PKGSCL3  - Save Appropriate version of SCL for Promotion pkgs.
//*---------------------------------------------------------------------
//PKGSCL3   EXEC PGM=IEBUPDTE,         <- Promo pkg SCL update 2/2
//          PARM=NEW,
//          COND=((2,NE,PKGSCL2),(4,LT))
//SYSIN    DD DSN=&&IEBUPDT,DISP=(OLD,DELETE) <-IEBUPD cmds for Pkg SCL
//SYSUT1   DD DUMMY
//SYSUT2   DD DSN=&EXPORTDS,DISP=SHR
//SYSPRINT DD SYSOUT=*
//*---------------------------------------------------------------------
//*@ SCAN#SCL - SCAN Package SCLs - reformat into a Table   format.
//*---------------------------------------------------------------------
//SCAN#SCL  EXEC PGM=IKJEFT1B,         <- Scan+Format Exported SCL
//          COND=(4,LT)                   Convert into usable REXX
//   INCLUDE MEMBER=SYSEXEC            <- my Rexx library
//SYSTSPRT  DD SYSOUT=*
//SYSTSIN   DD DSN=&&SCAN#SCL,DISP=(OLD,DELETE)
//*SCAN#SCL  DD DUMMY    <- Turn Trace on/off
//RESULTS  DD DSN=&&SCLRSLTS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=100,BLKSIZE=32000),
//         DISP=(MOD,PASS),
//         UNIT=3390,SPACE=(CYL,(01,05),RLSE)
//*-------------------------------------------------------------------
//*@ SCANSHOW - Show intermediate results
//*-------------------------------------------------------------------
//SCANSHOW  EXEC PGM=IEBGENER,         <- Show Scan results
//          COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&SCLRSLTS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*---------------------------------------------------------------------
//*@ ACMQ#1  -- Build ACM Queries
//*---------------------------------------------------------------------
//ACMQ#1    EXEC PGM=IRXJCL,           <- Build ACM Queries SCL
//          PARM='ENBPIU00 PARMLIST',     for all packaged elements
//          COND=(4,LT)
//TABLE    DD DSN=&SCLRSLTS,DISP=(OLD,PASS)
//PARMLIST  DD *   <- Order of processing
  NOTHING   NOTHING  STAGEIDS  0
  MODEL     TBLOUT   OPTIONS   A
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
        TYPE     &C1ElType  STAGE NUMBER &C1Stgnum
     OPTIONS
  .
//STAGEIDS DD DSN=&&STAGEIDS,DISP=(OLD,PASS)
//OPTIONS  DD *  <-ACM uses stage numbers. Convert from Stageids.
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  If Count = '000000' then $SkipRow = 'Y'
  C1Element = Strip(C1Element)
  C1Element = Strip(C1Element,'T',"'")
  Env = Strip(C1Envmnt)
  C1Stgnum = Stage_#.Env.C1Stage
* Say 'Converted' Env C1Stage 'to' Env C1Stgnum
//   INCLUDE MEMBER=CSIQCLS0           <- where is ENBPIU00
//SYSTSPRT  DD SYSOUT=*
//TBLOUT   DD DSN=&&ACMQRYS,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(TRK,(5,15),RLSE)
//*-------------------------------------------------------------------
//*@ ACMQSHO1 - Show  ACM Queries
//*-------------------------------------------------------------------
//ACMQSHO1  EXEC PGM=IEBGENER,         <- Show  ACMQ SCL
//          COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&ACMQRYS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*
//*-------------------------------------------------------------------*
//*@ ACMQ#2   - Run   ACM Queries
//*-------------------------------------------------------------------*
//ACMQ#2    EXEC PGM=NDVRC1,           <- Run   ACM Queries
//          PARM='BC1PACMQ',              for all packaged elements
//          COND=(4,LT)
//   INCLUDE MEMBER=STEPLIB            <- Endevor STEPLIB+CONLIB
//ACMSCLIN DD DSN=&&ACMQRYS,DISP=(OLD,DELETE)
//ACMMSGS1 DD SYSOUT=*
//ACMMSGS2 DD SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//ACMOUT   DD DSN=&&ACMOUT,
//         DCB=(DSORG=PS,RECFM=FB,LRECL=100),
//         DISP=(NEW,PASS),UNIT=3390,
//         SPACE=(CYL,(1,05),RLSE)
//*-------------------------------------------------------------------
//*@ ACMQSHO2 - Show  ACM Query results
//*-------------------------------------------------------------------
//ACMQSHO2  EXEC PGM=IEBGENER,         <- Show ACMQ results
//          COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&ACMOUT,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//*-------------------------------------------------------------------
//*@ VALIDATE - Run final report.
//*-- Compare Packaged Elements with ACMQuery results ----------------
//*--   Indicate in RC if any elements are missing from package(s)----
//*-------------------------------------------------------------------
//VALIDATE  EXEC PGM=IKJEFT1B,         <- Build Report
//    COND=(4,LT),
//    PARM='PKGVAL#2 &ENVIRON &STAGE# &CIRCLRC &PROMSTGS &PATHINIT'
//PKGIDS    DD DSN=&&PKGIDS,DISP=(OLD,DELETE)   <- package ID info
//STAGEIDS  DD DSN=&&STAGEIDS,DISP=(OLD,DELETE) <- STG# to STGID
//SCL       DD DSN=&&SCLRSLTS,DISP=(OLD,PASS) <- Packaged SCL
//ACMQ      DD DSN=&&ACMOUT,DISP=(OLD,DELETE) <- ACMQuery results
//   INCLUDE MEMBER=SYSEXEC            <- my Rexx library
//SYSTSPRT  DD SYSOUT=*
//SYSTSIN   DD DUMMY
//*PKGVAL#2  DD DUMMY           <- Turn Trace on/off
//RESULTS   DD SYSOUT=*         <- Final Report output
//PKGORDER  DD SYSOUT=*         <- Delete this line if unwanted
//*-------------------------------------------------------------------
//*-------------------------------------------------------------------
