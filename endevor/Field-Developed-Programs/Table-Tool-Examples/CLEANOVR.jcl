//WALJO11O JOB (0000),'Dan Walther',CLASS=A,MSGCLASS=Z,MSGLEVEL=(1,1),
//         NOTIFY=&SYSUID,REGION=0M
//*-------------------------------------------------------------------*
//*--Report processor group Overrides --------------------------------*
//*-------------------------------------------------------------------*
//*  Output:  SYSDE32.NDVR.TEAM.DEFINES(CLEANOVR)
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL)
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY
//STEP1    EXEC PGM=NDVRC1,
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0' (EXEC FROM NON-AUTH LIB)
//   INCLUDE MEMBER=STEPLIB     <- Endevor STEPLIB+CONLIB
//CSVIPT01 DD *
  LIST PROCESSOR GROUP '*'
     FROM ENVIRONMENT '*'    SYSTEM '*'  TYPE '*'  STAGE '*'
     OPTIONS NOSEARCH
     TO   FILE 'APIEXTR' .
//APIEXTR  DD DSN=&&APIEXTR,
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=18000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(10,10),RLSE)
//CSVMSGS1 DD SYSOUT=*
//C1MSGSA  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*---------------------------------------------------------------------
//STEP2 EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//TABLE    DD DSN=&&APIEXTR,DISP=(OLD,PASS)
//OPTIONS  DD  *
  If Substr(SYM_OVRD,1,1) = ' '   then $SkipRow = 'Y'
  asterisk = ' '
  If PROC_GRP_NAME = 'DONTUSE1'   then asterisk = '*'
//MODEL    DD *
*Now: &UPDT_USRID on &UPDT_DATE / &SYM_OVRD ='&SYM_OVRD_VALUE'
&asterisk  DELETE PROCESSOR SYMBOL
&asterisk    FROM ENVIRONMENT '&ENV_NAME'
&asterisk      SYSTEM '&SYS_NAME' TYPE '&TYPE_NAME' STAGE ID &STG_ID
&asterisk      PROCESSOR GROUP &PROC_GRP_NAME PROCESSOR TYPE &PROC_TYPE
&asterisk      SYMBOL = (&SYM_OVRD)
&asterisk      .
//   INCLUDE MEMBER=CSIQCLS0    <- Endevor CSIQCLS0
//SYSTSPRT DD  SYSOUT=*
//SYSPRINT DD SYSOUT=*
//TBLOUT   DD DISP=SHR,DSN=SYSDE32.NDVR.TEAM.DEFINES(CLEANOVR)
//*---------------------------------------------------------------------
