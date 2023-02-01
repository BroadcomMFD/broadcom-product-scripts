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
//    HLQ='SYSDE32.NDVR.&C1ENVMNT..&C1SY..&C1SU.',
//*   INCLUDE='-INC &C1ELEMENT',
//    INCLUDE='       ++INCLUDE &C1ELEMENT',
//    EXPINC=N,
//    LISTLIB='&HLQ..LISTLIB',                    Listing lib
//    MONITOR=COMPONENTS,
//    OPTIONS='&HLQ..OPTIONS',                    OPTIONS dataset name
//    OUTLIB='&HLQ..JCL',                         output JCL lib
//    RESLTHLQ='PUBLIC.&C1ELEMENT',               perhaps C1userid...
//    SHOWME='Y',       Show diagnostics & intermediate results Y/N
//    SYSEXEC1=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX,
//    SYSEXEC2=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM2.CLSTREXX,
//    SYSOUT=*,
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
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,15)),
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=24000)
//C1INIT02 DD DSN=&&SUPERC,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//*-------------------------------------------------------------------*
//**  Get element specific OPTIONS ele for JCL     (If one EXISTS)   **
//*------                                                            **
//**  (You can use IEBUPDTE for this step if LRECL=80 for OPTIONS    **
//**    Otherwise, on the Defaults table use                         **
//**                  LIBENV=PV or LIBENV=LB
//**               on the ENCOPTBL table use                         **
//**                  ENHOPT MSGSEVERITY_ENBX043=W                   **
//**     then use ENBX1000 on this step                           )  **
//*-------------------------------------------------------------------*
//GET#OPTE EXEC PGM=CONAPI,PARM='ENBX1000',
//              COND=(4,LT),MAXRC=4
//ENXIN    DD *  / Fetch the OPTIONs for the Element
&INCLUDE         <- Panv or Libr Include
//*-INC &C1ELEMENT                   <- Libr version (-INC in col 1)
//*      ++INCLUDE &C1ELEMENT        <- Panv version (++   in col 8)
//ENXINC00 DD DISP=SHR,DSN=&OPTIONS,
//            MONITOR=COMPONENTS,ALLOC=LMAP
//ENXMSGS1 DD SYSOUT=*               EXECUTION REPORT
//ENXMSGS2 DD SYSOUT=*               SUMMARY REPORT
//C1TPDD01 DD UNIT=&WRKUNIT,SPACE=(CYL,3),
//            DCB=(RECFM=VB,LRECL=260)
//C1TPDD02 DD UNIT=&WRKUNIT,SPACE=(CYL,5),
//            DCB=(RECFM=VB,LRECL=260)
//C1TPLSIN DD UNIT=&WRKUNIT,SPACE=(CYL,3),
//            DCB=(RECFM=FB,LRECL=80)
//C1TPLSOU DD SYSOUT=*
//C1PLMSGS DD SYSOUT=*
//ENXOUT   DD DSN=&&OPTIONE,DISP=(OLD,PASS)
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
//  PARM='TEST#JOB &C1ELEMENT &C1STAGE &WAITS &WAITSECS &RESLTHLQ',
//              COND=(4,LT),MAXRC=4
//* Can use OPTIONS to override WaitLoops and LoopSeconds
//* Writes NEWTXT even if no OPTIONS are found
//*EST#JOB DD DUMMY    < turn TEST#JOB Trace on/off
//*XTRPLCE DD DUMMY    < turn TXTRPLCE Trace on/off
//*PTVALDT DD DUMMY    < turn OPTVALDT Trace on/off
//*AML2REX DD DUMMY    < turn YAML2REX Trace on/off
//OLDTXT   DD DSN=&&ELMOUT,DISP=(OLD,DELETE)
//NEWTXT   DD DSN=&OUTLIB(&C1ELEMENT),
//            DISP=SHR,MONITOR=COMPONENTS,FOOTPRNT=CREATE
//OPTIONS  DD DSN=&&OPTIONE,DISP=(OLD,PASS)
//VARIABLE DD *   <- Optionally provide more substitution variables
* Format:        variable-name = 'value'
* A variable-name can be existing Endevor/processor/Site Symbol
*                 variable names, or or any valid (rexx) name
*   variable-names preceded with an '&' can be included in the
*                  Replace and Insertx text strings of your OPTIONS

* values must be quoted by single or double quotes, and may
*                 contain mixtures of other variables.

  C1ELEMENT    = '&C1ELEMENT'
  C1ENVMNT     = '&C1ENVMNT'
  C1SYSTEM     = '&C1SYSTEM'
  C1SUBSYS     = '&C1SUBSYS'
  C1ELTYPE     = '&C1ELTYPE'
  C1STAGE      = '&C1STAGE'
  C1STGNUM     = '&C1STGNUM'
  CSIQCLS0='&#HLQ..EMER.CSIQCLS0'
  #OCLIST###@1= '&#OREXX####@1'
  #OCLIST###@2= '&#OREXX####@2'
  MyDSNPrefix='MOTM.&C1SY..&C1SU..&C1EN(1,1)&C1S#.'
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1
//         DD DISP=SHR,DSN=&SYSEXEC2
//SYSTSPRT DD SYSOUT=*
//SYSTSPRX DD DSN=&&SYSTSPRT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//ERRORS   DD SYSOUT=*   <- if any errors are found
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
//*--------------------------------------------------------------------
//* AUTOTEST - a processor include                         ------------
//*- Determine whether this element has an expected        ------------
//*- AutomatedTest@<C1stage> reference for testing         ------------
//*-   RC=0 means no testing found. RC=1 means yes         ------------
//*- Apply RELATE commands for element to testing JCL      ------------
//*--------------------------------------------------------------------
//AUTOTST1 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST',       AUTOTEST
//              MAXRC=4
//TABLE    DD DSN=&&OPTIONE,DISP=(OLD,PASS) <- Required in processor
//PARMLIST DD *         <- List of inputs/outputs/Options
NOTHING  NOTHING  OPTIONS  0
MODELSCL TBLOUT   OPTIONS1 A
MODELREL RELATES  OPTIONS2 A
//OPTIONS  DD *         <- Set Defaults
  $Table_Type = "positions"
  $my_rc = 0    /* Assume RC=0 until proven otherwise */
  $index = 0
//POSITION DD *         <- Must parse each OPTION statement
  Option   1 80
//OPTIONS1 DD *         <- Parse each OPTION statement
* Split the option statement using "=" character
  PARSE VAR Option keyword "=" myValue
  sa= 'AutomatedTest@&C1STAGE..'
  go = Abbrev(keyword,'AutomatedTest@&C1STAGE..')
  If go /= 1 then $SkipRow = 'Y'
  $index = $index + 1
*
  myValue = Strip(Strip(Strip(myValue),"B",'"'))
  AutomatedTest = Strip(Strip(Strip(myValue),"B","'"))
  If WordPos('ELEMENT',AutomatedTest) = 0 then, +
     AutomatedTest = 'ELEMENT' AutomatedTest ; +
  $my_rc =1;
//MODELSCL DD *         <- Build Generate wi Copyback SCL
* AutoTest spawed for element &C1ELEMENT in:
*   Env=&C1ENVMNT Sys=&C1SY Sub=&C1SU Typ= &C1TY
 SET FROM ENVIRONMENT '&C1ENVMNT' STAGE '&C1STGID'
          SYSTEM '&C1SYSTEM' SUBSYSTEM '&C1SUBSYS'
          TYPE 'JCL'.
 SET OPTIONS COPYBACK SEARCH
          PROCESSOR GROUP = AUTOTEST
          CCID '&C1CCID'
          COMMENT '&C1COMMENT'.
 GENERATE
  &AutomatedTest .
//OPTIONS2 DD *         <- Build Relates
* Split the option statement using "=" character
  PARSE VAR Option keyword "=" myValue
  go = Abbrev(keyword,'AutomatedTest@&C1STAGE..')
  If go /= 1 then $SkipRow = 'Y'
  $index = $index + 1
*
  myValue = Strip(Strip(Strip(myValue),"B",'"'))
  AutomatedTest = Strip(Strip(Strip(myValue),"B","'"))
  If WordPos('ELEMENT',AutomatedTest) = 0 then, +
     RelateElement = Word(AutomatedTest,1) ; +
  Else, +
     RelateElement = Word(AutomatedTest,where + 1);
*
  RelateSystem = '&C1SYSTEM'
  where = Wordpos('SYSTEM',AutomatedTest)
  If where > 0 then RelateSystem = Word(AutomatedTest,where + 1);
*
  RelateSubsys = '&C1SUBSYS'
  where = Wordpos('SUBSYSTEM',AutomatedTest)
  If where > 0 then RelateSubsys = Word(AutomatedTest,where + 1);
*
  RelateType   = 'JCL'
//MODELREL DD *         <- Format for Relates  ...
RELATE ELEMENT &RelateElement
       LOCATION
       ENVIRONMENT = &C1ENVMNT
       SYSTEM      = &RelateSystem
       SUBSYSTEM   = &RelateSubsys
       TYPE        = &RelateType
       STAGE       = &C1STGID
       INPUT VALIDATE.
//NOTHING  DD DUMMY
//TBLOUT   DD  DSN=&&GENERSCL,
//             UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//RELATES  DD  DSN=&&RELATES,
//             UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//SYSTSPRT DD SYSOUT=&SYSOUT
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1
//         DD DISP=SHR,DSN=&SYSEXEC2
//*-------------------------------------------------------------------
//*--- Execute JCL element for Batch Testing --------------------------*
//*--------------------------------------------------------------------*
//AUTOTST2 EXEC PGM=C1BM3000,PARM='TESTDD1,C1MSGS1J',      AUTOTEST
//              COND=(1,NE,AUTOTST1),
//              MAXRC=4
//TESTDD1  DD  DSN=&&GENERSCL,DISP=(OLD,DELETE)
//C1MSGS1J DD  SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*
//*-------------------------------------------------------------------
//*--- Execute JCL element for Batch Testing --------------------------*
//*--------------------------------------------------------------------*
//RELATES  EXEC PGM=CONRELE,                               AUTOTEST
//              COND=(1,NE,AUTOTST1),
//              EXECIF=(&C1ACTION,EQ,GENERATE)
//NDVRIPT  DD   DSN=&&RELATES,DISP=(OLD,DELETE)
//*-------------------------------------------------------------------
//  ENDIF
//*---------------------
