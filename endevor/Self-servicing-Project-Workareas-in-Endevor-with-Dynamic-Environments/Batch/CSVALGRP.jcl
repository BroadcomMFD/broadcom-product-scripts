//WALJO11E JOB (0000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//  RESTART=DEFINES,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//*--- Use CSV+TableTool to adjust Environment Definitions -----------
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
//*-------------------------------------------------------------------
//*  Output PSP.ENDV.TEAM.DEFINES(CSVALGRP)
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//STEP1    EXEC PGM=NDVRC1,
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0'
//   INCLUDE MEMBER=STEPLIB
//CSVIPT01 DD *
LIST PROCESSOR GROUP '*'
    FROM ENVIRONMENT 'DEV%*' SYSTEM '*'
         TYPE COBBAT  STAGE '*'
    OPTIONS NOSEARCH
    TO   FILE 'CSVEXTR'
    .
//CSVEXTR  DD DSN=&&CSVFILE,
//      DCB=(RECFM=VB,LRECL=4092,BLKSIZE=4096,DSORG=PS),
//      DISP=(NEW,PASS),
//      SPACE=(TRK,(5,1),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//*---- Show CSV output -----------------------------------------------
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*---- Build SCL for selected entries --------------------------------
//*--------------------------------------------------------------------
//BILDSCL  EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//   INCLUDE MEMBER=CSIQCLS0  <- where is ENBPIU00
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,PASS)
//MODEL    DD * <- painted output
* Apply override when processor is GCOBL
*  prev change - &UPDT_USRID &UPDT_DATE &UPDT_TIME
   DEFINE PROCESSOR GROUP '&PROC_GRP_NAME'
       TO ENVIRONMENT '&ENV_NAME'
          SYSTEM '&SYS_NAME'
          TYPE '&TYPE_NAME'
          STAGE NUMBER &STG_#
       DELETE PROCESSOR NAME IS 'DELETE'
           ALLOW FOREGROUND EXECUTION
       .
   DEFINE PROCESSOR SYMBOL
       TO ENVIRONMENT '&ENV_NAME'
          SYSTEM '&SYS_NAME'
          TYPE '&TYPE_NAME'
          STAGE NUMBER &STG_#
          PROCESSOR GROUP '&PROC_GRP_NAME'
          PROCESSOR TYPE = GENERATE
       SYMBOL ZLBATN='SHARE.ENDV.PRCS.SYS01.TEST.&C1STAGE..LOADB'
       SYMBOL ZLISTN='SHARE.ENDV.PRCS.SYS01.TEST.&C1STAGE..LIST'
   .
//OPTIONS  DD * <- specific instructions are here
If PROC_NAME /= 'GCOBL   ' then $SkipRow = 'Y'
If PROC_TYPE /= 'GEN'      then $SkipRow = 'Y'
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//TBLOUT   DD DISP=SHR,DSN=PSP.ENDV.TEAM.DEFINES(CSVALGRP)
//SYSTSIN  DD DUMMY
//*-------------------------------------------------------------------*
//*--- Execute the DEFINE Scl ----------------------------------------*
//*-------------------------------------------------------------------*
//DEFINES  EXEC PGM=NDVRC1,PARM='ENBE1000',COND=(0,LE)
//ENESCLIN DD DISP=SHR,DSN=PSP.ENDV.TEAM.DEFINES(CSVALGRP)
//C1MSGS1   DD  SYSOUT=*
//C1MSGS2   DD  SYSOUT=*     SYSDE32.NDVR.TEAM.DEFINES
//   INCLUDE MEMBER=STEPLIB
//SYSTERM   DD  SYSOUT=*
//SYSABEND  DD  SYSOUT=*
