//&PkgExecJobname JOB (&AltIDAcctCode),'SHIP &Destination',
//         MSGLEVEL=(1,1),CLASS=&AltIDJobClass,REGION=0M,MSGCLASS=A,
//         NOTIFY=&Notify^&Typrun
//***==============================================================* *
//***=====Remote Package Shipment via FTP==========================* *
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
//* ISPSLIB(SHIP#FTP)
//*-----------------------------------------------------
//*--------------------------------------------------------SHIP#FTP
//* MY DESTNAME = &Destination
//* MY FROMNODE = &SENDNODE
//* MY PACKAGE = &Package
//* MY VNBCPARM = C1BMX000,&Date8,&Time8
//*--------------------------------------------------------SHIP#FTP
//*-----------------------------------------------------
//***==============================================================* *
//NDVRSHIP EXEC PGM=NDVRC1,DYNAMNBR=1500,REGION=4096K,     SHIP#FTP
//         PARM='C1BMX000,&Date8,&Time8 SHIP &Userid '
//*
//*C1BMXTRC DD DISP=SHR,
//*          DSN=CAPRD.ENDV.TRACE.LOCAL
//*
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*
//* *--------------------------------------------* SHIP#FTP (CONT.)  *
//*
//C1BMXDET DD SYSOUT=*     ** SHIPMENT DETAIL REPORT  ****************
//C1BMXSUM DD SYSOUT=*     ** SHIPMENT SUMMARY REPORT ****************
//C1BMXSYN DD SYSOUT=*     ** INPUT LISTING AND SYNTAX ERROR REPORT **
//*
//* ******************************************************************
//* *  LOCAL TRANSFER COPY/RUN COMMAND DATASETS
//* *  LOCAL MODEL CONTROL CARD DATASET
//* ******************************************************************
//*
//C1BMXLCC DD DSN=&&XLCC,DISP=(NEW,PASS),SPACE=(TRK,(2,10)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*
//C1BMXLCM DD DISP=SHR,DSN=&MyOPT2Library
//         DD DISP=SHR,DSN=&MyOPTNLibrary
//*
//* ******************************************************************
//* * NETVIEW FTP "ADD TO TRANSMISSION QUEUE" DATASET AND INTERNAL RDR
//* * NETVIEW FTP MODEL CONTROL CARD DATASET //*
******************************************************************
//*
//C1BMXFTC DD DSN=&&XFTC,DISP=(NEW,PASS),SPACE=(TRK,(2,10)),
// DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
// UNIT=SYSALLDA
//C1BMXFTM DD DISP=SHR,DSN=&MyOPT2Library
//         DD DISP=SHR,DSN=&MyOPTNLibrary
//* * NETWORK DATA MOVER COPY/RUN COMMAND DATASETS
//* * NETWORK DATA MOVER MODEL CONTROL CARD DATASET
//* ******************************************************************
//C1BMXNWC DD DSN=&&XNWC,DISP=(NEW,PASS),SPACE=(TRK,(2,10)),
// DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
// UNIT=SYSALLDA
//C1BMXNWM DD DISP=SHR,DSN=&MyOPT2Library
//         DD DISP=SHR,DSN=&MyOPTNLibrary
//*
//C1BMXNWM DD DISP=SHR,DSN=&MyOPT2Library
//         DD DISP=SHR,DSN=&MyOPTNLibrary
//C1BMXRJC DD DISP=SHR,DSN=&MySEN2Library
//         DD DISP=SHR,DSN=&MySENULibrary
//*
//* ******************************************************************
//* *  SHIPMENT DATE/TIME READ BY INLINE HOST CONFIRMATION STEP
//* ******************************************************************
//*
//C1BMXDTM DD DSN=&&XDTM,DISP=(NEW,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*
//* ******************************************************************
//* *  HOST STAGING DATASET DELETION STATEMENTS (IDCAMS)
//* ******************************************************************
//*
//C1BMXDEL DD DSN=&&HDEL,DISP=(NEW,PASS),SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*
//* ******************************************************************
//* *  REMOTE JCL MODEL MEMBERS
//* ******************************************************************
//*
//C1BMXMDL DD DISP=SHR,DSN=&MyOPT2Library
//         DD DISP=SHR,DSN=&MyOPTNLibrary
//*
//* ******************************************************************
//* *  JCL SEGMENTS TO CREATE GROUP SYMBOLICS FOR MODELLING
//* ******************************************************************
//*
//C1BMXHJC DD DATA,DLM=##
//&Jobname JOB (55800000),'SHIP &Destination',
//         MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//         NOTIFY=&SYSUID TYPRUN=HOLD
//*-------------------------------------------------------------------*
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
//*-------------------------------------------------------------------*
//* ISPSLIB(SHIP#FTP)
//*--------------------------------------------------------SHIP#FTP
//* MY DESTNAME = &Destination
//* MY FROMNODE = &SENDNODE
//* MY PACKAGE = &Package
//* MY VNBCPARM = C1BMX000,&Date8,&Time8
//*--------------------------------------------------------SHIP#FTP
##
//*
//* *--------------------------------------------* SHIP#FTP (CONT.)  *
//*
//C1BMXHCN DD DATA,DLM=##
//* *--------------------------------------------------------------* *
//* *--------------------------------------------------------------* *
//*                                                        SHIP#FTP
//CONFGE12 EXEC PGM=NDVRC1,REGION=4096K,COND=(12,GT,$XM_STEP),
//   PARM='C1BMX000,&Date8,&Time8,CONF,HXMT,GE,0012,$DEST_ID'
//*                                                        SHIP#FTP
//C1BMXDTM DD DSN=&&XDTM,DISP=(MOD,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*                                                        SHIP#FTP
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//* *--------------------------------------------*         SHIP#FTP(CONT
//*                                                        SHIP#FTP
//CONFGE08 EXEC PGM=NDVRC1,REGION=4096K,COND=(08,NE,$XM_STEP),
//   PARM='C1BMX000,&Date8,&Time8,CONF,HXMT,GE,0008,$DEST_ID'
//*                                                        SHIP#FTP
//C1BMXDTM DD DSN=&&XDTM,DISP=(MOD,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*                                                        SHIP#FTP
//*                                                        SHIP#FTP
//CONFGE04 EXEC PGM=NDVRC1,REGION=4096K,COND=(04,NE,$XM_STEP),
//   PARM='C1BMX000,&Date8,&Time8,CONF,HXMT,EQ,0004,$DEST_ID'
//*                                                        SHIP#FTP
//C1BMXDTM DD DSN=&&XDTM,DISP=(MOD,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*                                                        SHIP#FTP
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*                                                        SHIP#FTP
//*                                                        SHIP#FTP
//CONFGE00 EXEC PGM=NDVRC1,REGION=4096K,COND=(00,NE,$XM_STEP),
//   PARM='C1BMX000,&Date8,&Time8,CONF,HXMT,EQ,0000,$DEST_ID'
//*                                                        SHIP#FTP
//C1BMXDTM DD DSN=&&XDTM,DISP=(MOD,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*                                                        SHIP#FTP
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*                                                        SHIP#FTP
//*                                                        SHIP#FTP
//CONFABND EXEC PGM=NDVRC1,REGION=4096K,COND=ONLY,         SHIP#FTP
//   PARM='C1BMX000,&Date8,&Time8,CONF,HXMT,AB,****,********'
//*                                                        SHIP#FTP
//C1BMXDTM DD DSN=&&XDTM,DISP=(MOD,PASS),SPACE=(TRK,(1,0)),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//            UNIT=SYSALLDA
//*                                                        SHIP#FTP
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*                                                        SHIP#FTP
//* *--------------------------------------------* ISPSLIB(SHIP#FTP) *
##
//*
//* *--------------------------------------------* C1BMXJOB (CONT.)  *
//*
//C1BMXRCN DD DATA,DLM=##
//*----PACKAGE SHIPMENT JOB #4 --------------------------  SHIP#FTP
//* *--Package Shipment Confirmation/Notification* ISPSLIB(SHIP#FTP) *
//*
//* *================================================================*
//* *  INSTREAM DATASET CONTAINING REMOTE CONFIRMATION JCL
//* *================================================================*
//WHATNTFY IF (RC > 7) THEN
//*
//CONFGT12 EXEC PGM=IEBGENER                               SHIP#FTP
//SYSUT1   DD DATA,DLM=$$              JOB SHIPPED BACK TO HOST
//&Jobname JOB (55800000),'SHIP &Destination',
//         MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//         NOTIFY=&SYSUID TYPRUN=HOLD
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
//* ISPSLIB(SHIP#FTP)
//*--------------------------------------------------------SHIP#FTP
//* MY DESTNAME = &Destination
//* MY FROMNODE = &SENDNODE
//* MY PACKAGE = &Package
//* MY VNBCPARM = C1BMX000,&Date8,&Time8
//*--------------------------------------------------------SHIP#FTP
//CONFCOPY EXEC PGM=NDVRC1,                                SHIP#FTP
//         PARM='C1BMX000,&Date8,&Time8,CONF,RCPY,EQ,0012,$DEST_ID'
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*--------------------------------------------------------SHIP#FTP
//NTFYTGGR EXEC PGM=IEFBR14,                               SHIP#FTP
//        PARM='UPDTTGGR &Destination 12 &VPHPKGID'
//STEPLIB  DD DISP=SHR,DSN=&MyAUTULibrary
//         DD DISP=SHR,DSN=&MyAUTHLibrary
//*        DD DISP=SHR,DSN=&MyLOADLibrary
//CONLIB   DD DISP=SHR,DSN=&MyLOADLibrary
//SYSEXEC DD DSN=&MyCLS0Library,DISP=SHR
//        DD DSN=&MyCLS2Library,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//*------------------------------------------------------- SHIP#FTP
//DELETES   EXEC PGM=IEFBR14  <- Dont delete               SHIP#FTP
//SYSPRINT   DD SYSOUT=*
//AMSDUMP    DD SYSOUT=*
//SYSIN    DD *
  DELETE '&HSTPFX.*' NONVSAM
//*------------------------------------------------------- SHIP#FTP
//* *--------------------------------------------* SHIP#FTP (CONT.)  *
$$
//SYSUT2   DD  DSN=WALJO11.REMOTE.D&Date6.T&Time6.NOTIFY,
//             DISP=(NEW,CATLG,KEEP),SPACE=(TRK,(1,0)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//             UNIT=SYSALLDA
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//* *--------------------------------------------* SHIP#FTP (CONT.)  *
//WHATNTFY ELSE
//*
//CONFGT00 EXEC PGM=IEBGENER                               SHIP#FTP
//SYSUT1   DD DATA,DLM=$$              JOB SHIPPED BACK TO HOST
//&Jobname JOB (55800000),'SHIP &Destination',
//         MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//         NOTIFY=&SYSUID TYPRUN=HOLD
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)
//* ISPSLIB(SHIP#FTP)
//*--------------------------------------------------------SHIP#FTP
//* MY DESTNAME = &Destination
//* MY FROMNODE = &SENDNODE
//* MY PACKAGE = &Package
//* MY VNBCPARM = C1BMX000,&Date8,&Time8
//*--------------------------------------------------------SHIP#FTP
//CONFCOPY EXEC PGM=NDVRC1,                                SHIP#FTP
//         PARM='C1BMX000,&Date8,&Time8,CONF,RCPY,EQ,0000,$DEST_ID'
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//   INCLUDE MEMBER=STEPLIB
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
//*--------------------------------------------------------SHIP#FTP
//NTFYTGGR EXEC PGM=IRXJCL,                                SHIP#FTP
//        PARM='UPDTTGGR &Destination / &VPHPKGID'
//STEPLIB  DD DISP=SHR,DSN=&MyAUTULibrary
//         DD DISP=SHR,DSN=&MyAUTHLibrary
//*        DD DISP=SHR,DSN=&MyLOADLibrary
//CONLIB   DD DISP=SHR,DSN=&MyLOADLibrary
//SYSEXEC DD DSN=&MyCLS0Library,DISP=SHR
//        DD DSN=&MyCLS2Library,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//*------------------------------------------------------- SHIP#FTP
//DELETES   EXEC PGM=IEFBR14  <- Dont delete               SHIP#FTP
//SYSPRINT   DD SYSOUT=*
//AMSDUMP    DD SYSOUT=*
//SYSIN    DD *
  DELETE '&HSTPFX.*' NONVSAM
//*------------------------------------------------------- SHIP#FTP
$$
//SYSUT2   DD  DSN=WALJO11.REMOTE.D&Date6.T&Time6.NOTIFY,
//             DISP=(NEW,CATLG,KEEP),SPACE=(TRK,(1,0)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),
//             UNIT=SYSALLDA
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//WHATNTFY ENDIF
//* *--------------------------------------------* SHIP#FTP (CONT.)  *
//FTPSUBMT EXEC PGM=FTP,REGION=2048K,TIME=800              SHIP#FTP
//NETRC    DD DISP=SHR,DSN=&SYSUID..ENDEVOR.NETRC(SHIPPING)
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSUDUMP  DD SYSOUT=Q
//OUTPUT   DD SYSOUT=*                                        SHIP#FTP
//SYSIN     DD *
 &MyHomeAddress
MODE B
EBCDIC
SITE FILETYPE=JES
PUT 'WALJO11.REMOTE.D&Date6.T&Time6.NOTIFY'
QUIT
//* *--------------------------------------------* C1BMXJOB (CONT.)  *
//REMODELT  EXEC PGM=IDCAMS,COND=(4,LT) <-Remote Delete    SHIP#FTP
//SYSPRINT  DD SYSOUT=*
//AMSDUMP   DD SYSOUT=*
//DELETEME  DD DSN=WALJO11.REMOTE.D&Date6.T&Time6.NOTIFY,
//          DISP=(SHR,DELETE)
//* DELETE '&&Rmteprefix.D&Date6.T&Time6.&Destination.*' NONVSAM
//SYSIN     DD *
##
//*
//* *--------------------------------------------* C1BMXJOB (CONT.)  *
//*
//C1BMXLIB DD DATA,DLM=##
//* ******************************************************************
//* *  STEPLIB, CONLIB, MESSAGE LOG AND ABEND DATASETS
//* ******************************************************************
//STEPLIB  DD DISP=SHR,DSN=&MyAUTULibrary
//         DD DISP=SHR,DSN=&MyAUTHLibrary
//*        DD DISP=SHR,DSN=&MyLOADLibrary
//CONLIB   DD DISP=SHR,DSN=&MyLOADLibrary
//*
//*********************************************************************
//*             ESI TRACE IN BATCH MODE                               *
//*********************************************************************
//*EN$TRESI DD SYSOUT=*
//*EN$TRALC DD SYSOUT=*
//*
//SYSUDUMP DD SYSOUT=*     *** DUMP TO SYSOUT *************************
//SYMDUMP  DD DUMMY
//C1BMXLOG DD SYSOUT=*     *** MESSAGES, ERRORS, RETURN CODES *********
##
//*
//* *--------------------------------------------* C1BMXJOB (CONT.)  *
//*
//* ******************************************************************
//* *  SHIP PACKAGE PKG-ID TO DESTINATION DEST-ID ( OPTION BACKOUT ) .
//* ******************************************************************
//*
//* THE FOLLOWING DD STATEMENT MUST BE THE *LAST* CARD IN THIS MEMBER.
//* ISPSLIB MEMBER C1BMXIN IS INCLUDED AFTER IT AS THE INSTREAM DATA.
//*
//C1BMXIN  DD *  *-------------------------------* ISPSLIB(SHIP#FTP) *
SHIP PAC '&Package' TO DEST &Destination OPT &ShipOutput .
//* *============================================* ISPSLIB(SHIP#FTP) *
//* *==============================================================* *
//* *==============================================================* *
//* *==============================================================* *
//* *==============================================================* *
//*================================================================
//*  Apply DB2 Masking (if necessary)
//*================================================================
//DB2MASK  EXEC PGM=IKJEFT1B,PARM='DB2MASK &Destination',
//            COND=(0,LE)                                 SHIP#FTP
//MASKING  DD *
  OwnerMask       = '&OwnerMask'
  QualifierMask   = '&QualifierMask'
  BindPackageMask = '&BindPackageMask'
  PathMask        = '&PathMask'
//SHIPREFS DD *
  AHREFDSN  WALJO11.HOST.D&Date6.T&Time6.&Destination.AHREF
//SYSTSIN  DD  DUMMY
//SYSEXEC DD DSN=&MyCLS0Library,DISP=SHR
//        DD DSN=&MyCLS2Library,DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//*================================================================
//*  Tailor JCL for   JOB #2 to be submitted next
//*================================================================
//TAILOR EXEC PGM=IRXJCL,PARM='ENBPIU00 A ',COND=(10,LE)   SHIP#FTP
//MODEL    DD DSN=&&XFTC,DISP=(SHR,PASS)
//TABLE    DD  *
*  DO--
   Once
//SYSTSIN  DD  DUMMY
//OPTIONS  DD  *
  $delimiter ='¬'
 VNBSQDSP='SHIP PAC '&Package' TO DEST &Destination OPT &ShipOutput .'
  VPHPKGID = '&Package'
   VNBLSDST = '&Destination'
  HSYSEXEC = PSP.ENDV.TEAM.REXX
  Userid   ='&Userid'
  SENDNODE = '&SENDNODE'
  VNBCPARM = 'C1BMX000,&Date8,&Time8'
  MyCLS0Library = '&MyCLS0Library'
  MyCLS2Library = '&MyCLS2Library'
//SYSEXEC DD DSN=&MyCLS0Library,DISP=SHR
//        DD DSN=&MyCLS2Library,DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//*BLOUT    DD SYSOUT=*
//TBLOUT    DD SYSOUT=(A,INTRDR)
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DUMMY
//*------------------------------------------------------- SHIP#FTP
