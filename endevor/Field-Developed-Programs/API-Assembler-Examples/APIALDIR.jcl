//IBMUSERA JOB (55800000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//*---EXECUTE API PROGRAM TO ADD/UPDATE                ---------------*
//*-------------------------------------------------------------------*
//STEP1    EXEC PGM=NDVRC1,
// PARM='APIALDIRFINAPS03  LOADLIBT'
//*PARM='APIALDIR----+--|-1----+--|-1----+----2----+----3
//*PARM='APIALDIR.MBR ---->DDNAME  >'
//SELECTN  DD DISP=SHR,DSN=IBMUSER.ENDEVOR.SELECTN(C1DEFLTS)
//STEPLIB  DD DISP=SHR,DSN=CAPRD.SIQ126S1.AUTHLIB
//         DD DISP=SHR,DSN=CAPRD.SIQ126S1.CONLIB
//CONLIB   DD DISP=SHR,DSN=CAPRD.SIQ126S1.CONLIB
//LOADLIBT DD DISP=SHR,DSN=CAPRD.NDVR.SMPLTEST.LOADLIB
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//BSTERR   DD  SYSOUT=*
//BSTAPI   DD  SYSOUT=*
//APIMSGS  DD  SYSOUT=*
//APIMSGX DD   DSN=&&APIMSGS,DISP=(MOD,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//APILIST DD   DSN=&&APILIST,DISP=(MOD,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=VB,LRECL=4096,BLKSIZE=0)
//*---------------------------------------------------
//STEP2    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APIMSGS,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*
//*
//*  PRINT EXTRACTED ELEMENT
//STEP3    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APILIST,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*
