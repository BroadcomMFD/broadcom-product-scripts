//**
//*******************************************************************
//**                                                               **
//**    COBOL2 AND COBOL/MVS COMPILE AND LINK-EDIT PROCESSOR
//**                                                               **
//*******************************************************************
//COBPGMP PROC LISTLIB='&PROJECT..&C1SSTAGE1..LISTLIB',
//             CLECOMP='IGY.SIGYCOMP',
//             CLERUN='CEE.SCEERUN',
//             CLELKED='CEE.SCEELKED',
//             CSIQCLS0='HLQ.CSIQCLS0',
//             PROJECT='yourHLQ',
//             COPYLIB='&PROJECT..&C1ST..COPY',
//             EXPINC=N,
//             LOADLIB='&PROJECT..&C1ST..LOADLIB',
       ++INCLUDE T4ZCONFG  Test4Z processor variables
//             MEMBER=&C1ELEMENT,
//             MONITOR=COMPONENTS,
//             CPARMA='',
//             CPARMZ='',
//             PARMLNK='LIST,MAP,XREF,RENT',
//             PARMCOB='LIB,NOSEQ,OBJECT,APOST,TEST(SEPARATE,DWARF)',
//             SYSOUT=*,
//             WRKUNIT=3390
//*********************************************************************
//*   ALLOCATE TEMPORARY LISTING DATASETS
//*********************************************************************
//DELETE EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
   DELETE &PROJECT..&C1ELEMENT..RECRDNG
   DELETE &PROJECT..&C1ELEMENT..ZLOPTS
   DELETE yourHLQ.&C1ELEMENT..ZLOPTS
   SET MAXCC=0
//INITCOB  EXEC PGM=BC1PDSIN,MAXRC=0                       COBPGMP
//C1INIT01 DD DSN=&&COBLIST,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//C1INIT02 DD DSN=&&LNKLIST,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//C1INIT03 DD DSN=&&ZLRESLT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=VB,LRECL=5000,BLKSIZE=5004,DSORG=PS)
//C1INIT04 DD DSN=&&ZLMESG,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)
//********************************************************************
//* READ SOURCE AND EXPAND INCLUDES
//*********************************************************************
//CONWRITE EXEC PGM=CONWRITE,COND=(0,LT),MAXRC=0,          COBPGMP
// PARM='EXPINCL(&EXPINC)'
//ELMOUT   DD DSN=&&ELMOUT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=0),
//            MONITOR=&MONITOR
//*******************************************************************
//**    COMPILE THE ELEMENT                                        **
//*******************************************************************
//COMPILE  EXEC PGM=CONPARMX,COND=(4,LT),MAXRC=4,          GCOBOL
//            PARM=(IGYCRCTL,'(&CPARMA)','&C1SYSTEM','&C1PRGRP',
//            '&C1ELEMENT','(&CPARMZ)','N','N')
//STEPLIB  DD  DSN=&CLECOMP,DISP=SHR
//         DD  DSN=&CLERUN,DISP=SHR
//PARMSDEF DD  DSN=&OPTIONS,
//             MONITOR=&MONITOR,ALLOC=LMAP,
//             DISP=SHR
//*******************************************************************
//*     COPYLIB CONCATENATIONS                                     **
//*******************************************************************
//SYSLIB   DD  DSN=&COPYLIB,ALLOC=PMAP,
//             MONITOR=&MONITOR,
//             DISP=SHR
//SYSIN    DD  DSN=&&ELMOUT,DISP=(OLD,PASS)
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(,PASS,DELETE),
//             UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=0),
//             FOOTPRNT=CREATE
//SYSUT1   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT2   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT3   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT4   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT5   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT6   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT7   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT8   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT9   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT10  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT11  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT12  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT13  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT14  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT15  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT16  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT17  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT18  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT19  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSUT20  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))
//SYSMDECK DD  UNIT=&WRKUNIT,SPACE=(CYL,(1,1))
//SYSPRINT DD  DSN=&&COBLIST,DISP=(OLD,PASS)
//*******************************************************************
//**    LINK EDIT THE ELEMENT                                      **
//*******************************************************************
//LKED     EXEC PGM=IEWL,COND=(4,LT),MAXRC=4,              COBPGMP
// PARM='&PARMLNK'
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(OLD,DELETE)
//SYSLMOD  DD  DSN=&LOADLIB(&MEMBER),
//             MONITOR=&MONITOR,
//             FOOTPRNT=CREATE,
//             DISP=SHR
//SYSLIB   DD  DSN=&LOADLIB,ALLOC=PMAP,
//             MONITOR=&MONITOR,
//             DISP=SHR
//         DD  DSN=&CLELKED,
//             DISP=SHR
//SYSUT1   DD  UNIT=&WRKUNIT,SPACE=(CYL,(1,1))
//SYSPRINT DD  DSN=&&LNKLIST,DISP=(OLD,PASS)
//*********************************************************************
//*** for Test4z processing\
//*********INCLUDES(TEST4Z)***(include 1st and either/both others)*****
       ++INCLUDE T4ZRECRD  Test4Z Examine OPTIONS
//**
