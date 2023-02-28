//VIT902B JOB (111400000),                                              JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//*   Report TYPE definition information
//*   VIT902.JCL.CSV(CSVALTYP)
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//STEP1    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//STEPLIB  DD DISP=SHR,DSN=CAIEDUC.NDVR.V181.CSIQAUTU
//         DD DISP=SHR,DSN=CAIEDUC.NDVR.V181.CSIQAUTH
//         DD DISP=SHR,DSN=CAIEDUC.NDVR.V181.CSIQLOAD
//CONLIB   DD DISP=SHR,DSN=CAIEDUC.NDVR.V181.CSIQLOAD
//BSTIPT01 DD *
LIST TYPE '*'
     FROM ENVIRONMENT '*' STAGE '*'
          SYSTEM 'FINANCE'
     TO DDNAME 'EXTRACTS'
     OPTIONS   RETURN ALL.
//EXTRACTS DD DSN=&&EXTRACTS,
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),
//      DISP=(NEW,PASS),
//      SPACE=(CYL,(5,10),RLSE)
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
//SBS#RPT EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//TABLE    DD  DSN=&&EXTRACTS,DISP=(OLD,DELETE)
//SYSEXEC  DD DISP=SHR,DSN=CAIEDUC.NDVR.V181.CSIQCLS0
//MODEL    DD  *    < Format TYPE information for TBLOUT
  &ENV_NAME &SYS_NAME &TYPE_NAME
       &UPDT_DATE &UPDT_TIME &UPDT_USRID
//NOTHING  DD DUMMY                               CONTROL STATEMENTS
//OPTIONS  DD *                                   CONTROL STATEMENTS
  TITLE = Strip(Translate(TITLE,"'",'"'))
  If STG_# /= '1' then $SkipRow = 'Y'
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD SYSOUT=*
//*--------------------------------------------------------------------
