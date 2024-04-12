//IBMUSER1 JOB (55800000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
// SET SYSEXEC=CAPRD.NDVR.PROD.CATSNDVR.CEXEC
//*--------------------------------------------------------------
//*- To Report and delete very old elements from Test -----------
//*--------------------------------------------------------------
//*--------------------------------------------------------------------*
//*   STEP 1 -- Execute CSV Utility to locate inventory
//*--------------------------------------------------------------------*
//STEP1    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//STEPLIB  DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTU
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTH
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD
//BSTIPT01 DD *
LIST ELEMENT '*'
     FROM ENVIRONMENT  SMPLTEST  SYSTEM  '*' SUBSYSTEM '*'
          TYPE  '*'
          STAGE NUMBER '*'
     DATA BASIC
     TO DDNAME 'CSVOUTPT'
     OPTIONS NOSEARCH   RETURN FIRST .
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//CSVOUTPT DD DSN=&&CSVFILE,
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(CYL,(5,5),RLSE)
//*--------------------------------------------------------------------
//*   SHOWME -- Show the API call  results
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K,COND=(4,EQ,STEP1)
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*
//TAILOR EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)
//OPTIONS  DD *
  DaysAgo = 240         /* Number of days for cutoff */
  BaseDate = DATE('B')  /* Today in Base format */
  UpdateDate = Substr(UPDT_DATE,1,4) || Substr(UPDT_DATE,6,2)
  UpdateDate = UpdateDate || Substr(UPDT_DATE,9,2)
  If DATATYPE(UpdateDate) /= 'NUM' then $SkipRow = 'Y'
  BaseOld  = DATE(B,UpdateDate,S)  /* Convert Upd date to Base fmt */
  ElementAge = BaseDate - BaseOld  /* Determine how many days ago  */
  If TYPE_NAME /= 'JAVA' & ElementAge < DaysAgo then $SkipRow = 'Y'
//SYSEXEC DD DSN=&SYSEXEC,DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//MODEL    DD  *
** &FULL_ELM_NAME &SYS_NAME &SBS_NAME &TYPE_NAME &SIGNOUT_ID
*    &UPDT_DATE &UPDT_TIME (&ElementAge Days ago)
  DELETE ELEMENT &FULL_ELM_NAME
         FROM ENVIRONMENT &ENV_NAME
              SYSTEM &SYS_NAME SUBSYSTEM &SBS_NAME
              TYPE &TYPE_NAME STAGE &STG_ID .
//TBLOUT    DD SYSOUT=*
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DUMMY
//TBLOUT   DD SYSOUT=*
//*-------------------------------------------------------------------
