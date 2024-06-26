//IBMUSERE JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
// EXPORT SYMLIST=(*)
//*-------------------------------------------------------------------
//* Create a new Dynamic Environment from an existing Environment
//* Use SET variables to name new and old Environment data
//*   JCL: PSP.ENDV.TEAM.JCL(DEFINENV)
//*-------------------------------------------------------------------
//    SET NEWENV=DEV02
//    SET NEWSTG1=DEV02A
//    SET NEWSTG2=DEV02B
//*--
//    SET LIKENV=DEV01      <- Built from DEV and adjusted
//*-------------------------------------------------------------------*
//*   STEP 1 -- EXECUTE CSV UTILITY to Build SCL for LIKE enironement
//*-------------------------------------------------------------------*
//ALLOC    EXEC PGM=IDCAMS                  <-Define new MCFs
//SYSIN    DD *,SYMBOLS=JCLONLY
  DEFINE CLUSTER (NAME('SHARE.ENDV.CTLG.&NEWSTG1..MCF')          -
         MODEL('SHARE.ENDV.CTLG.DEVQE.MCF') )
  DEFINE CLUSTER (NAME('SHARE.ENDV.CTLG.&NEWSTG2..MCF')          -
         MODEL('SHARE.ENDV.CTLG.DEVINT.MCF') )
  SET LASTCC=0
  SET MAXCC=0
//SYSPRINT   DD SYSOUT=*
//AMSDUMP    DD SYSOUT=*
//*-------------------------------------------------------------------*
//*   STEP 2 -- EXECUTE Endevor Batch Administration to Define Environ
//*-------------------------------------------------------------------*
//ADMIN    EXEC PGM=NDVRC1,PARM='ENBE1000', <-Batch Admin DEFINE NEWENV
//         COND=(4,LT)
//ENESCLIN  DD  *,SYMBOLS=JCLONLY
DEFINE ENVIRONMENT '&NEWENV'
      TITLE 'DEVELOPMENT Dynamic &NEWENV'
      LIKE  '&LIKENV'
      STage ONE MCF 'SHARE.ENDV.CTLG.&NEWSTG1..MCF'
      STage ONE TITLE '&NEWSTG1'
      STage ONE NAME  '&NEWSTG1'
      STage ONE ID    '1'
      STage TWO MCF 'SHARE.ENDV.CTLG.&NEWSTG2..MCF'
      STage TWO TITLE '&NEWSTG2'
      STage TWO NAME  '&NEWSTG2'
      STage TWO ID    '2'
      .
CLONE SYSTEM *
      FROM ENVIRONMENT &LIKENV
      TO ENVIRONMENT &NEWENV
      INCLUDE SUBSYSTEMS
      INCLUDE TYPES
   .
//C1MSGS1   DD  SYSOUT=*
//C1MSGS2   DD  SYSOUT=*
//   INCLUDE MEMBER=STEPLIB       <- Endevor Steplib+CONLIB etc
//SYSTERM   DD  SYSOUT=*
//SYSABEND  DD  SYSOUT=*
//*
//*-------------------------------------------------------------------*
