//IBMUSER# JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//* Delete a Dynamic Environment (when no elements exist)
//*   (environment and MCF's are deleted)
//*   JCL: PSP.ENDV.TEAM.JCL(DELETENS)
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
// EXPORT SYMLIST=(*)
//*--
//    SET NEWENV=DEV02
//    SET NEWSTG1=DEV02A
//    SET NEWSTG2=DEV02B
//*-------------------------------------------------------------------*
//*   STEP 1 -- EXECUTE CSV UTILITY to Build SCL for LIKE enironement
//*-------------------------------------------------------------------*
//STEP01   EXEC PGM=NDVRC1,PARM='ENBE1000', <-Batch Admin DEFINE NEWENV
//         COND=(4,LT)
//ENESCLIN  DD  *,SYMBOLS=JCLONLY  <- This one is used when Submitted
  DELETE ENVIRONMENT '&NEWENV' .
//C1MSGS1   DD  SYSOUT=*
//C1MSGS2   DD  SYSOUT=*     SYSMD32.NDVR.TEAM.DEFINES
//   INCLUDE MEMBER=STEPLIB
//SYSTERM   DD  SYSOUT=*
//SYSABEND  DD  SYSOUT=*
//*
//*-------------------------------------------------------------------*
//*   STEP 1 -- EXECUTE CSV UTILITY to Build SCL for LIKE enironement
//*-------------------------------------------------------------------*
//DELEVSAM EXEC PGM=IDCAMS                  <-Define new MCFs
//SYSIN    DD *,SYMBOLS=JCLONLY
  DELETE 'SHARE.ENDV.CTLG.&NEWSTG1..MCF' PURGE
  DELETE 'SHARE.ENDV.CTLG.&NEWSTG2..MCF' PURGE
  SET LASTCC=0
  SET MAXCC=0
//SYSPRINT   DD SYSOUT=*
//AMSDUMP    DD SYSOUT=*
//*-------------------------------------------------------------------*
