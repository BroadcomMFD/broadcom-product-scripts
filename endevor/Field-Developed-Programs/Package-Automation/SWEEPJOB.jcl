//IBMUSERS JOB (0000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-----------------------------------------------------------------*   JOB02096
//* SWEEP PACKAGE DATABASE AND ESTABLISH RUNJCL FOR PACKAGES THAT   *   JOB02096
//* ARE APPROVED AND MEET SUBMIT TIMES                              *   JOB02096
//*-----------------------------------------------------------------*
//  SET SUBMITDS=IBMUSER.PULLTGGR         <- Work  datasets
//  SET MODELDSN=CAPRD.ENDV.SHIP.MODELS   <- Where Shipping MODELS
//  SET SYSSEXEC=CAPRD.ENDV.SHIP.REXX     <- Where is PULLTGGR
//*-----------------------------------------------------------------*
//SWEEP    EXEC PGM=NDVRC1,PARM='ENBP1000',REGION=0M
//STEPLIB  DD DISP=SHR,DSN=CAPRD.END##.CSIQAUTU
//         DD DISP=SHR,DSN=CAPRD.END##.CSIQAUTH
//         DD DISP=SHR,DSN=CAPRD.END##.CSIQLOAD
//CONLIB   DD DISP=SHR,DSN=CAPRD.END##.CSIQLOAD
//ENPSCLIN DD *
 SUBMIT PACKAGE *
 JOBCARD DDNAME JCLIN
    TO INTERNAL READER DDNAME JCLOUT
    OPTION WHERE PACKAGE STATUS IS APPROVED
           INCREMENT JOBNAME
           JCL PROCEDURE NAME IS ENDEVOR
 .
//JCLOUT   DD   SYSOUT=(A,INTRDR),DCB=(BLKSIZE=80,LRECL=80,RECFM=F)
//JCLIN    DD  DATA,DLM=@@
//SWEEP#01 JOB (0000),                                                  JOB00219
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//    JCLLIB ORDER=(CAPRD.END##.CSIQJCL)
//**------------------------------------------------------------------*
@@
//C1MSGS1  DD   SYSOUT=*
//C1MSGS2  DD   SYSOUT=*
//SYSABEND DD   SYSOUT=*
//SYSPRINT DD   SYSOUT=*
//SYSTERM  DD   SYSOUT=*
//*-------------------------------------------------------------------*
//*  Run the step below to Sweep Package Shipments.                  -*
//*-------------------------------------------------------------------*
//SHIPMENT EXEC PGM=IKJEFT1B,COND=(4,LE),
//   PARM=('PULLTGGR &SUBMITDS',
//         ' &MODELDSN')
//STEPLIB  DD DISP=SHR,DSN=CAPRD.END##.CSIQAUTU
//         DD DISP=SHR,DSN=CAPRD.END##.CSIQAUTH
//         DD DISP=SHR,DSN=CAPRD.END##.CSIQLOAD
//CONLIB   DD DISP=SHR,DSN=CAPRD.END##.CSIQLOAD
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//*  Trigger file is dynamically allocated
//SUBFAILS DD SYSOUT=*
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC
//SYSTSIN  DD DUMMY
//*-------------------------------------------------------------------*
