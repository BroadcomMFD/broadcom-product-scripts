//*--------------------------------------------------------------------*
//*-Generate Processor for JCL elements                          ------*
//*      to Automated Testing of the JCL Element.                ------*
//*--------------------------------------------------------------------*
//*  -- Using the Production JCL image,                          ------*
//*  -- Tailor and submit the JCL element.                       ------*
//*  -- Wait for the submitted job to finish.                    ------*
//*  -- Collect the job outputs.                                 ------*
//*  -- Then compare the outputs with former outputs or Baseline ------*
//*--------------------------------------------------------------------*
//*  -- This processor must run in batch.                        ------*
//*--------------------------------------------------------------------*
//GTESTING PROC AAAAAA=,
//    HLQ='NDV.MOTM.ESCMSNDV.SHRD.D&C1STGNUM.',   Endevor Datasets HLQ
//    EXPINC=N,
//    LISTLIB='&HLQ..LISTLIB',                    Listing lib
//    MONITOR=COMPONENTS,
//    OPTIONS='&HLQ..OPTIONS',                    OPTIONS dataset name
//    OUTLIB='&HLQ..JCL',                         output JCL lib
//    RESLTHLQ='PUBLIC.&C1ELEMENT',               perhaps C1userid...
//    SHOWME='Y',       Show diagnostics & intermediate results Y/N
//    SYSEXEC1=CATSNDVR.NDVR.EMER.CSIQCLS0,       1 of 2 Rexx libraries
//    SYSEXEC2=CATSNDVR.NDVR.PROD.CSIQCLS0,       2 of 2 Rexx libraries
//    SYSOUT=,
//    WAITS=15,                                   Default # wait loops
//    WAITSECS=3,                                 Default wait seconds
//    WRKUNIT=3390,
//    ZZZZZZZ=                              the end
//*-------------------------------------------------------------------*
//*********************************************************************
//*-- GET production JCL image.                                       *
//*********************************************************************
//CONWRITE EXEC PGM=CONWRITE,COND=(4,LT),MAXRC=0,          GTESTING
// PARM='EXPINCL(&EXPINC)'
//ELMOUT   DD DSN=&&ELMOUT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=0),
//            MONITOR=&MONITOR
//**********************************************************************
//*   ALLOCATE Temporary Datasets                                      *
//**********************************************************************
//INIT     EXEC PGM=BC1PDSIN,MAXRC=0                       GTESTING
//C1INIT01 DD DSN=&&OPTIONE,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920)
//C1INIT02 DD DSN=&&SUPERC,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//*-------------------------------------------------------------------*
//**  Get element specific OPTIONS ele for JCL     (If one EXISTS)   **
//*-------------------------------------------------------------------*
//GET#OPTE EXEC PGM=IEBUPDTE,COND=(4,LT),MAXRC=4           GTESTING
//SYSPRINT DD DUMMY
//SYSIN    DD  *
./  REPRO NEW=PS,NAME=&C1ELEMENT
//SYSUT1   DD DISP=SHR,DSN=&OPTIONS,
//            MONITOR=COMPONENTS,ALLOC=LMAP
//SYSUT2   DD DSN=&&OPTIONE,DISP=(OLD,PASS)
//EXAMPLES DD * <- These are examples OPTIONS to be fetched
  JCL.FindTxt.1 = 'WALJO11.'
  JCL.Replace.1 = 'PUBLIC.'

  JCL.FindTxt.2 = 'CLASS=B'
  JCL.Replace.2 = 'CLASS=A'

  JCL.FindTxt.3 = 'CAIPRODD.NDVR'
  JCL.Replace.3 = 'SYSDE32.NDVR.TEAM'

  JCL.FindTxt.4 = 'SECONDS=12'
  JCL.Replace.4 = 'SECONDS=04'
  JCL.REPLACE.<ddname>.<stepname> = 'Jcl-statements>'
  JCL.REPLACE.STEPLIB.      = 'WALJO11.LOADLIB' <-Replace all STEPLIBS
  JCL.REPLACE.STEPLIB.STEP1 = 'WALJO11.LOADLIB' <-Replace   1 STEPLIB
//*-------------------------------------------------------------------*
//*-- In the parameter string, enter:                          -------*
//*--  o TEST#JOB - the name of the REXX driver                -------*
//*--  o &C1ELEMENT - the element name                         -------*
//*--  o &C1STAGE  - the stage name. Optionally can be a       -------*
//*                  Deploy to Test Target name                -------*
//*--  o <number> of wait loops for the processor to wait      -------*
//*--             for the submitted job                        -------*
//*--  o <number> of seconds to sleep after each loop when     -------*
//*--             the submitted job is found still running     -------*
//*--  o HLQ - for the outputs to be written to when the job   -------*
//*--          is completed, and then used in comparison.      -------*
//*-------------------------------------------------------------------*
//*--     Waits and WaitSecs can be overriden in the OPTIONS   -------*
//*--      (RC=0 means no tests to submit)                     -------*
//*--      (RC=1 means   Successful test submitted)            -------*
//*--      (RC=8 means UnSuccessful test submitted)            -------*
//*-------------------------------------------------------------------*
//SUBMITST EXEC PGM=IKJEFT1B,   < execute the REXX driver  GTESTING
//  PARM='TEST#JOB &C1ELEMENT &C1STAGE &WAITS &WAITSECS &RESLTHLQ'
//* Can use OPTIONS to override WaitLoops and LoopSeconds
//OLDJCL   DD DSN=&&ELMOUT,DISP=(OLD,DELETE)
//NEWJCL   DD DSN=&OUTLIB(&C1ELEMENT),
//            DISP=SHR,MONITOR=COMPONENTS,FOOTPRNT=CREATE
//OPTIONS  DD DSN=&&OPTIONE,DISP=(OLD,PASS)
//VARIABLE DD *   <- Optionally provide more substitution variables
* Endevor   variable examples
  C1ELEMENT    = '&C1ELEMENT'
  C1ENVMNT     = '&C1ENVMNT'
  C1SYSTEM     = '&C1SYSTEM'
  C1SUBSYS     = '&C1SUBSYS'
  C1ELTYPE     = '&C1ELTYPE'
  C1STAGE      = '&C1STAGE'
* Processor variable examples
  CSIQCLS0='CATSNDVR.NDVR.EMER.CSIQCLS0'
  LOADBTCH='&HLQ..LOADLIB'
  LOADCICS='&HLQ..LOADONL'
  HLQ='NDV.MOTM.ESCMSNDV.SHRD.D&C1STGNUM.'
* Site Symbol variable examples
  #OCLIST###@1= 'CATSNDVR.NDVR.EMER.CSIQCLS0'
  #OCLIST###@2= 'CATSNDVR.NDVR.PROD.CSIQCLS0'
  #BASEPRFX=  'MOTM.&C1SY..&C1SU..&C1EN(1,1)&C1S#.'
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1
//         DD DISP=SHR,DSN=&SYSEXEC2
//SYSTSPRT DD DSN=&&SYSTSPRT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//SYSTSIN  DD DUMMY
//RELATE   DD DSN=&&RELATE,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920)
//SYSIN  DD * <- Input for SuperC
CMPSECT START  TOP 'JESYSMSG-End'
//OUTDD    DD DSN=&&SUPERC,DISP=(OLD,PASS)  <- SuperC comparison here
//*-------------------------------------------------------------------*
//*---- Relate the job outputs to the JCL element  -------------------*
//*-------------------------------------------------------------------*
//RELATE   EXEC PGM=CONRELE,                               GTESTING
//         COND=(1,NE,SUBMITST)
//NDVRIPT  DD DSN=&&RELATE,DISP=(OLD,DELETE)
//*-------------------------------------------------------------------*
//*******************************************************************
//*     STORE THE LISTINGS IF:   LISTLIB=LISTING LIBRARY NAME       *
//*******************************************************************
//STORLIST EXEC PGM=CONLIST,MAXRC=0,PARM=STORE,COND=EVEN   GTESTING
//C1LLIBO  DD DSN=&LISTLIB,DISP=SHR,
//            MONITOR=&MONITOR
//C1BANNER DD UNIT=&WRKUNIT,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FBA,LRECL=121,BLKSIZE=0)
//LIST01   DD DSN=&&SYSTSPRT,DISP=(OLD,PASS)
//LIST02   DD DSN=&&SUPERC,DISP=(OLD,PASS)
//*******************************************************************
//*     PRINT THE LISTINGS IF:   LISTLIB=NO                         *
//*******************************************************************
//PRNTLIST EXEC PGM=CONLIST,MAXRC=0,PARM=PRINT,COND=EVEN   GTESTING
//*          EXECIF=(&LISTLIB,EQ,NO)
//C1BANNER DD UNIT=&WRKUNIT,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FBA,LRECL=121,BLKSIZE=0,DSORG=PS)
//C1PRINT  DD SYSOUT=*,
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//LIST01   DD DSN=&&SYSTSPRT,DISP=(OLD,DELETE)
//LIST02   DD DSN=&&SUPERC,DISP=(OLD,DELETE)
//**
//*******************************************************************
//*     If Autotesting then this JCL might need others to follow:   *
//*******************************************************************
//*---------------------
//  IF (RC < 4) AND (GET#OPTE.RC = 0) THEN
-INC AUTOTEST    Submit AutomatedTest if specified
//  ENDIF
//*---------------------
