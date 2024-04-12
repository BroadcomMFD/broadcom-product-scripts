//IBMUSERI JOB (301000000),'EXAMPL2A',CLASS=B,PRTY=6,
//  MSGCLASS=3,REGION=7M,NOTIFY=&SYSUID
/*JOBPARM  SYSAFF=*
//*--------------------------------------------------------------
// JCLLIB  ORDER=(IBMUSER.JCL.CSV)
//*-------------------------------------------------------------------
//*   CONVERT ENVIRONMENT INFO INTO REXX STEM ARRAY DATA
//*   VIT902.JCL.CSV(CSVALENV)
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//STEP1    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//   INCLUDE MEMBER=STEPLIB
//BSTIPT01 DD *
LIST ENVIRONMENT
'*'
TO DDNAME 'EXTRACTS'
OPTIONS   RETURN ALL.
//EXTRACTS DD DSN=&&EXTRACTS,
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),
//      DISP=(NEW,PASS),
//      SPACE=(CYL,(5,1),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&EXTRACTS,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//ENV#RPT EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//TABLE    DD  DSN=&&EXTRACTS,DISP=(OLD,DELETE)
//PARMLIST DD  *
NOTHING  TBLOUT  OPTIONS0 0
MODEL    TBLOUT  OPTIONS  A
LISTENVS TBLOUT  NOTHING  1
//   INCLUDE MEMBER=SYSEXEC
//MODEL    DD  *    < BUILD REXX COMMANDS THAT TELL THE STORY
ENV_TITLE.&ENV_NAME = '&TITLE'
//LISTENVS DD  *    < BUILD REXX COMMANDS THAT TELL THE STORY
LISTENVS = '&LISTENVS'
//NOTHING  DD DUMMY                               CONTROL STATEMENTS
//OPTIONS0 DD *                                   CONTROL STATEMENTS
LISTENVS = ''
//OPTIONS  DD *                                   CONTROL STATEMENTS
TITLE = STRIP(TRANSLATE(TITLE,"'",'"'))
IF WORDPOS(ENV_NAME,LISTENVS) = 0 THEN, +
LISTENVS = STRIP(LISTENVS) ENV_NAME
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD SYSOUT=*
//*-------------------------------------------------------------------
