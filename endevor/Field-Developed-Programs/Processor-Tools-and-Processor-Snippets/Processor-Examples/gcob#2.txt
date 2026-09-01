//**=================================================================**
//**  GCOB - GENERATE COBOL/BATCH/ONLINE  COMPILE/LINK/              ** 00020000
//**=================================================================**
//**   0) ALLOCATE TEMP DATASETS                                     **
//**   1) GET SOURCE FROM ENDEVOR                                    **
//**   2) GET LNK CARDS                                              ** 00080000
//**   3) CHECK OPT CARDS                                            ** 00170000
//**   4) DB2  PRE-PROCESSOR  CHECK OPT                              ** 00170000
//**   5) DB2  PRE-PROCESSOR                                         ** 00170000
//**   6) CICS PRE-TRANSLATOR                                        ** 00170000
//**   7) COBOL COMPILE                                              ** 00170000
//**   8) LINK                                                       ** 00180000
//**   9) LINK COBX CICS                                             ** 00180000
//**  10) PROCESS DB2                                                ** 00180000
//**  11) BUILD DB2 CARDS                                            ** 00180000
//**  12) INVOKE DB2 BIND                                            ** 00180000
//**  13) INVOKE DB2 GRANTS                                          ** 00180000
//**  14) PROCES DB2 STP                                             ** 00180000
//**  15) PROCES DB2 STP                                             ** 00180000
//**  16) OTHER  OUTPUT DATASETS                                     ** 00200000
//**  17) INVOKE CICS NEWCOPY                                        ** 00200000
//**  18) DELETE TEMP INPUT                                          ** 00210000
//**  19) PRINT LISTINGS                                             ** 00220000
//**  20) SAVE  LISTINGS                                             ** 00230000
//**=================================================================** 00240000
//GCOB PROC PROCNAME=GCOB,                                              00250000
//     CAISRC='&#CAISRC',                                               00270000
//  DB2VER='&C1SY&C1AYYYY.-&C1AMM.-&C1ADD..&C1AHH..&C1ATMM..&C1ASS',    00270000
//     PRMCMPA='',                                                      00310000
//     PRMCMPZ='',                                                      00320000
//     PRMLNKA='',                                                      00330000
//     PRMLNKZ='',                                                      00340000
//     HILVL='&#HILVL.',                                                00350000
//     LSTSFX='&C1PRGRP(4,1)',
//     LNKPARM='&HILVL..PROD.LNKPARM',                                  00210000
//     LNKCOBX='COXO&C1PRGRP(5)',                                       00210000
//*                                                                     00380000
//* SYMBOLIC FOR CURRENT COPYBOOKS SYSLIB                               00390000
//     CPYXX='&HILVL..&C1ST..&C1SY..&C1SU..CPY',                        00450000
//     CPY='&HILVL..&C1ST..&C1SY..CPY',                                 00450000
//     DCLXX='&HILVL..&C1ST..&C1SY..&C1SU..DCL',                        00450000
//     DCL='&HILVL..&C1ST..&C1SY..DCL',                                 00450000
//     MPCXX='&HILVL..&C1ST..&C1SY..&C1SU..MPC',                        00450000
//     MPC='&HILVL..&C1ST..&C1SY..MPC',                                 00450000
//* SYMBOLIC FOR CURRENT SHARED COPYBOOKS                               00390000
//     CPY@C0@P='&#&C1SY.#$C0@P',                                       00450000
//     CPY@C1@P='&#&C1SY.#$C1@P',                                       00450000
//     CPY@C2@P='&#&C1SY.#$C2@P',                                       00450000
//     CPY@C3@P='&#&C1SY.#$C3@P',                                       00450000
//     CPY@C4@P='&#&C1SY.#$C4@P',                                       00450000
//     CPY@C5@P='&#&C1SY.#$C5@P',                                       00450000
//     CPY@C6@P='&#&C1SY.#$C6@P',                                       00450000
//*                                                                     00560000
//* SYMBOLIC FOR CURRENT SHARED DCL GENS                                00390000
//     DCL@D1@P='&#&C1SY.#$D1@P',                                       00450000
//     DCL@D2@P='&#&C1SY.#$D2@P',                                       00450000
//*                                                                     00560000
//* SYMBOLIC FOR CURRENT DB2 DBR/PKG/DBB                                00660000
//     DB2$BCXX='&HILVL..&C1ST..&C1SY..&C1SU..$BC',                     00680000
//     DB2$BC='&HILVL..&C1ST..&C1SY..$BC',                              00680000
//     TMP$BC='&C1USERID..&C1ST..&C1SY..&C1ELEMENT..$BC',               00680000
//     DBRXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND2NODE',                  00680000
//     DBR='&HILVL..&C1ST..&C1SY..&#ND2NODE',                           00680000
//     DBBXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND1DBB',                   00680000
//     DBB='&HILVL..&C1ST..&C1SY..&#ND1DBB',                            00680000
//     PKGXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND1PKG',                   00680000
//     PKG='&HILVL..&C1ST..&C1SY..&#ND1PKG',                            00680000
//*                                                                     00560000
//* SYMBOLIC FOR CURRENT SHARED LOAD LIBS                               00390000
//     LOD@L1@P='&#&C1SY.#$L1@P',                                       00450000
//     LOD@L2@P='&#&C1SY.#$L2@P',                                       00450000
//*                                                                     00560000
//* SYMBOLIC FOR CURRENT COMPILE OPTIONS                                00660000
//     OPTXX='&HILVL..&C1ST..&C1SY..&C1SU..OPT',                        00680000
//     OPT='&HILVL..&C1ST..&C1SY..OPT',                                 00680000
//     OPTBASE='&HILVL..PROD.OPT',                                      00680000
//     LCTXX='&HILVL..&C1ST..&C1SY..&C1SU..LCT',                        00690000
//     LCT='&HILVL..&C1ST..LCT',                                        00700000
//*                                                                     00810000
//* SYMBOLIC FOR CURRENT SYSTEM OBJECT
//     SROXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND1NODE',
//     SRO='&HILVL..&C1ST..&C1SY..&#ND1NODE',
//*                                                                     00810000
//* SYMBOLIC FOR CURRENT SYSTEM BINDER    SYSLIB                        00910000
//     LNKXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND1NODE',                  00930000
//     LNK='&HILVL..&C1ST..&C1SY..&#ND1NODE',                           00930000
//     LODXX='&HILVL..&C1ST..&C1SY..&C1SU..LOD',                        00930000
//     LOD='&HILVL..&C1ST..&C1SY..LOD',                                 00930000
//     LNK2XX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND2NODE',                 00930000
//     LNK2='&HILVL..&C1ST..&C1SY..&#ND2NODE',                          00930000
//*                                                                     00810000
//     XDATASET='&HILVL..&C1ST..&C1SY..X',
//     STGLIB='&HILVL..&C1ST..&C1SY',
//     ND1CHGM='&#ND1CHGM',                                             00940000
//     ND2CHGM='&#ND2CHGM',                                             00940000
//*                                                                     01130000
//     OLLIBXX='&HILVL..&C1ST..&C1SU..LIST',                            01150000
//     OLLIB='&HILVL..&C1ST..LIST',                                     01150000
//*                                                                     01160000
//     PRTOUT='*',                                                      01170000
//     EDVREX='&#EDVREX',                                               01200000
//     SCEELKED='&#SCEELKED',                                           01200000
//**   SCEECICS='&#SCEECICS',                                           01210000
//     SCEESAMP='&#SCEESAMP',                                           01220000
//     SD$CICS='&#SD$CICS',                                             01260000
//     SDSNLOAD='&#SDSNLOAD',                                           01260000
//     SDSNEXIT='&#SDSNEXIT',                                           01260000
//     SDFHLOAD='&#SDFHLOAD',                                           01260000
//**   SDFHEXCI='&#SDFHEXCI',                                           01270000
//     SDFHCOB='&#SDFHCOB',                                             01280000
//     SDFHMAC='&#SDFHMAC',                                             01280000
//**   SDFHSAMP='&#SDFHSAMP',                                           01290000
//     SCSQCOBC='&#SCSQCOBC',                                           01300000
//**   SCSQCOBS='&#SCSQCOBS',                                           01310000
//     SCSQLOAD='&#SCSQLOAD',                                           01320000
//     SYSWK='SYSDA',                                                   01340000
//     TMP='VIO'                                                        01350000
//*                                                                     01360000
//*<<<                                                             >>>> 01370000
//*<<<<<<<<<<<<<<<<  0) ALLOCATE TEMP DATASETS   >>>>>>>>>>>>>>>>>>>>>> 01380000
//*<<<                                                             >>>> 01390000
//*                                                                     01400000
//ALLOCATE EXEC PGM=BC1PDSIN,MAXRC=0                                    01410000
//C1INIT01 DD DSN=&&DB2LST,DISP=(,PASS),                                01440000
//     UNIT=&TMP,SPACE=(CYL,(5,5)),RECFM=FBA,LRECL=133                  01450000
//C1INIT02 DD DSN=&&CMPLST,DISP=(,PASS),                                01440000
//     UNIT=&TMP,SPACE=(CYL,(5,5)),RECFM=FBA,LRECL=133                  01450000
//C1INIT03 DD DSN=&&CMPXLST,DISP=(,PASS),                               01440000
//     UNIT=&TMP,SPACE=(CYL,(5,5)),RECFM=FBA,LRECL=133                  01450000
//C1INIT04 DD DSN=&&LNKLST,DISP=(,PASS),                                01460000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01470000
//C1INIT05 DD DSN=&&LNKXLST,DISP=(,PASS),                               01460000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01470000
//C1INIT06 DD DSN=&&BLDLNK,DISP=(,PASS),                                01480000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=121                  01490000
//C1INIT07 DD DSN=&&XPDCPY,DISP=(,PASS),                                01720000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT08 DD DSN=&&OPTNEW,DISP=(,PASS),                                01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FB,LRECL=80                    01750000
//C1INIT09 DD DSN=&&CHG1CPY,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT10 DD DSN=&&TRNLST,DISP=(,PASS),                                01460000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=121                  01470000
//C1INIT11 DD DSN=&&CHG2CPY,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT12 DD   DSN=&&OPTNEW,DISP=(,PASS),
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FB,LRECL=80
//C1INIT13 DD DSN=&&DB2LST1,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT14 DD DSN=&&DB2RPT1,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT15 DD DSN=&&DB2LST2,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT16 DD DSN=&&DB2RPT2,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT17 DD DSN=&&PKGBND,DISP=(,PASS),                                01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT18 DD DSN=&&DB2GRNT,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT19 DD DSN=&&STPLST,DISP=(,PASS),                                01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT20 DD DSN=&&WLMLST1,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT21 DD DSN=&&WLMLST2,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT22 DD DSN=&&WLMLST3,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//C1INIT23 DD DSN=&&DB2LST3,DISP=(,PASS),                               01740000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  01730000
//*                                                                     01760000
//*<<<                                                             >>>> 01770000
//*<<<<<<<<<<<<<<<<  1) GET SOURCE FROM ENDEVOR  >>>>>>>>>>>>>>>>>>>>>> 01780000
//*<<<                                                             >>>> 01790000
//*                                                                     01800000
//EXTSRC   EXEC PGM=CONWRITE,PARM='EXPINCL(N)',MAXRC=0                  01810000
//ELMOUT   DD DISP=(NEW,PASS),DSN=&&ELMOUT,                             01820000
//     UNIT=&TMP,SPACE=(CYL,(1,1)),                                     01830000
//     RECFM=FB,LRECL=80,BLKSIZE=27920                                  01840000
//*                                                                     01850000
//*<<<                                                             >>>> 01860000
//*<<<<<<<<<<<<<<<<  2) GET LCT CARDS            >>>>>>>>>>>>>>>>>>>>>>
//*<<<                                                             >>>>
//*
//BLDLCT   EXEC PGM=IEBGENER,MAXRC=0
//*
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD *
 NAME &C1ELEMENT(R)
/*
//SYSUT2   DD DISP=(NEW,PASS),DSN=&&LCTOUT,
//     UNIT=&TMP,SPACE=(TRK,(2,2)),RECFM=FB,LRECL=80,BLKSIZE=3200
//SYSIN    DD DUMMY
//*
//*<<<                                                             >>>>
//*<<<<<<<<<<<<<<<<  3) CHECK OPT CARDS          >>>>>>>>>>>>>>>>>>>>>>
//*<<<                                                             >>>>
//*
//GETOPT   EXEC PGM=IEBUPDTE,MAXRC=4
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
./  REPRO NEW=PS,NAME=&C1ELEMENT
/*
//OPT    IF ('&C1ST(1,4)' = 'TEST') THEN
//SYSUT1   DD   DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS
//         DD   DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP
//OPT    ELSE
//SYSUT1   DD   DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP
//OPT    ENDIF
//*
//SYSUT2   DD   DSN=&&OPTNEW,DISP=(SHR,PASS)
//*
//*<<<                                                             >>>>
//*<<<<<<<<<<<<<<<<  4) CHECK DB2 PREPROCESSOR   >>>>>>>>>>>>>>>>>>>>>>
//*<<<                                                             >>>>
//*
//CHKDB2   EXEC PGM=VALUECHK,PARM='DB2PRE Y'
//OPTIONS  DD   DSN=&&OPTNEW,DISP=(OLD,PASS)
//SYSPRINT DD   SYSOUT=*
//*                                                                     02870000
//*<<<                                                             >>>>
//*<<<<<<<<<<<<<<<<  5) DB2  PRECOMPILE          >>>>>>>>>>>>>>>>>>>>>>
//*<<<                                                             >>>>
//*
//DB2P IF ('&C1PRGRP(5,1)' = '2' AND CHKDB2.RC = '1') THEN
//*
//DB2      EXEC PGM=DSNHPC,MAXRC=04,
//    PARM=('HOST(IBMCOB),SOURCE,XREF,VERSION(&DB2VER)')
//*
//STEPLIB  DD DISP=SHR,DSN=&SDSNEXIT
//         DD DISP=SHR,DSN=&SDSNLOAD
//*
//DBR    IF ('&C1ST(1,4)' = 'TEST') THEN
//DBRMLIB  DD DISP=SHR,DSN=&DBRXX(&C1ELEMENT),
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE
//DBR    ELSE
//DBRMLIB  DD DISP=SHR,DSN=&DBR(&C1ELEMENT),
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE
//DBR    ENDIF
//SYSIN    DD DISP=(OLD,PASS),DSN=&&ELMOUT
//SYSCIN   DD DISP=(,PASS),DSN=&&DB2OUT,
//     UNIT=&TMP,SPACE=(CYL,(1,1))
//*
//SYSLIB   DD DISP=(,PASS),DSN=&&NULLDB2,
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920
//*
//DCL    IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&CPYXX,MONITOR=COMPONENTS
//         DD DISP=SHR,DSN=&DCLXX,MONITOR=COMPONENTS
//DCL    ENDIF
//         DD DISP=SHR,DSN=&CPY,MONITOR=COMPONENTS,ALLOC=LMAP
//         DD DISP=SHR,DSN=&DCL,MONITOR=COMPONENTS,ALLOC=LMAP
//CPYC0 IF (&CPY@C0@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C0@P,MONITOR=COMPONENTS                 06880000
//CPYC0 ENDIF                                                           08050000
//CPYC1 IF (&CPY@C1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C1@P,MONITOR=COMPONENTS                 06880000
//CPYC1 ENDIF                                                           08050000
//CPYC2 IF (&CPY@C2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C2@P,MONITOR=COMPONENTS                 06880000
//CPYC2 ENDIF                                                           08050000
//CPYC3 IF (&CPY@C3@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C3@P,MONITOR=COMPONENTS                 06880000
//CPYC3 ENDIF                                                           08050000
//CPYC4 IF (&CPY@C4@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C4@P,MONITOR=COMPONENTS                 06880000
//CPYC4 ENDIF                                                           08050000
//CPYC5 IF (&CPY@C5@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C5@P,MONITOR=COMPONENTS                 06880000
//CPYC5 ENDIF                                                           08050000
//CPYC6 IF (&CPY@C6@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C6@P,MONITOR=COMPONENTS                 06880000
//CPYC6 ENDIF                                                           08050000
//*
//DCLD1 IF (&DCL@D1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&DCL@D1@P,MONITOR=COMPONENTS                 06880000
//DCLD1 ENDIF                                                           08050000
//DCLD2 IF (&DCL@D2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&DCL@D2@P,MONITOR=COMPONENTS                 06880000
//DCLD2 ENDIF                                                           08050000
//****     DD DISP=SHR,DSN=&CPYBASE,MONITOR=COMPONENTS
//****     DD DISP=SHR,DSN=&DCLBASE,MONITOR=COMPONENTS
//****     DD DISP=SHR,DSN=&CPYPRD1,MONITOR=COMPONENTS
//****     DD DISP=SHR,DSN=&DCLPRD1,MONITOR=COMPONENTS
//****     DD DISP=SHR,DSN=&SDFHCOB,MONITOR=COMPONENTS
//SYSPRINT DD DISP=(SHR,PASS),DSN=&&DB2LST
//SYSUT1   DD UNIT=&TMP,SPACE=(CYL,(5,5),RLSE)
//SYSUT2   DD UNIT=&TMP,SPACE=(CYL,(5,5),RLSE)
//*                                                                     02870000
//DB2P ENDIF
//*                                                                     02870000
//*<<<                                                             >>>> 02880000
//*<<<<<<<<<<<<<<<<  6) CICS PRE-TRANSLATOR      >>>>>>>>>>>>>>>>>>>>>> 06280000
//*<<<                                                             >>>> 06290000
//*                                                                     06300000
//TRN  IF ('&C1PRGRP(1,4)' = 'COBO' OR '&C1PRGRP(1,4)' = 'OBJO') THEN
//*                                                                     06300000
//TRN      EXEC PGM=CONPARMX,MAXRC=4,
//     PARM=(DFHECP1$,'(&PRMCMPA)',$$$$DFLT,&C1PRGRP(1,4),&C1ELEMENT,  X06340000
//             '(&PRMCMPZ)','Y','N')                                    06350000
//STEPLIB  DD DSN=&SDFHLOAD,DISP=SHR
//*                                                                     02870000
//PARMSDEF DD DISP=(,DELETE),DSN=&&NULLOPT,                             06400000
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               06410000
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          06420000
//*                                                                     06430000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    06510000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           06510000
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  06510000
//PARMSMSG DD SYSOUT=*
//SYSPRINT DD DSN=&&TRNLST,DISP=(OLD,PASS)
//*
//DB2  IF ('&C1PRGRP(5,1)' = '2' AND DB2.RUN AND DB2.RC < 5) THEN
//SYSIN    DD DSN=&&DB2OUT,DISP=(OLD,PASS)
//DB2  ELSE
//SYSIN    DD DSN=&&ELMOUT,DISP=(OLD,PASS)
//DB2  ENDIF
//SYSPUNCH DD DSN=&&CICOUT,DISP=(,PASS),
//    SPACE=(CYL,(2,1)),UNIT=&TMP,
//    BLKSIZE=27920,LRECL=80,RECFM=FB
//*                                                                     02870000
//TRN  ENDIF
//*                                                                     02870000
//*<<<                                                             >>>> 02880000
//*<<<<<<<<<<<<<<<<  7) COBOL COMPILE            >>>>>>>>>>>>>>>>>>>>>> 06280000
//*<<<                                                             >>>> 06290000
//*                                                                     06300000
//CMP IF (RC<=4) THEN                                                   06310000
//*                                                                     06320000
//CMP      EXEC PGM=CONPARMX,MAXRC=4,                                   06330000
//     PARM=(IGYCRCTL,'(&PRMCMPA)',$$$$DFLT,&C1PRGRP(1,4),&C1ELEMENT,  X06340000
//             '(&PRMCMPZ)','Y','N')                                    06350000
//*                                                                     06360000
//STEPLIB  DD DSN=&SDSNEXIT,DISP=SHR
//         DD DSN=&SDSNLOAD,DISP=SHR
//*                                                                     06360000
//PARMSDEF DD DISP=(,DELETE),DSN=&&NULLOPT,                             06400000
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               06410000
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          06420000
//*                                                                     06430000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    06510000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           06510000
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  06510000
//PARMS    DD SYSOUT=*                                                  06520000
//*                                                                     06530000
//SYSLIB   DD DISP=(,PASS),DSN=&&NULLCPY,                               06540000
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               06550000
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          06560000
//*                                                                     06930000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&CPYXX,MONITOR=COMPONENTS                    02520000
//         DD DISP=SHR,DSN=&DCLXX,MONITOR=COMPONENTS                    02520000
//         DD DISP=SHR,DSN=&MPCXX,MONITOR=COMPONENTS                    02530000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&CPY,MONITOR=COMPONENTS,ALLOC=LMAP           02520000
//         DD DISP=SHR,DSN=&DCL,MONITOR=COMPONENTS,ALLOC=LMAP           02520000
//         DD DISP=SHR,DSN=&MPC,MONITOR=COMPONENTS,ALLOC=LMAP           02520000
//CPYC0 IF (&CPY@C0@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C0@P,MONITOR=COMPONENTS                 06880000
//CPYC0 ENDIF                                                           08050000
//CPYC1 IF (&CPY@C1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C1@P,MONITOR=COMPONENTS                 06880000
//CPYC1 ENDIF                                                           08050000
//CPYC2 IF (&CPY@C2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C2@P,MONITOR=COMPONENTS                 06880000
//CPYC2 ENDIF                                                           08050000
//CPYC3 IF (&CPY@C3@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C3@P,MONITOR=COMPONENTS                 06880000
//CPYC3 ENDIF                                                           08050000
//CPYC4 IF (&CPY@C4@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C4@P,MONITOR=COMPONENTS                 06880000
//CPYC4 ENDIF                                                           08050000
//CPYC5 IF (&CPY@C5@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C5@P,MONITOR=COMPONENTS                 06880000
//CPYC5 ENDIF                                                           08050000
//CPYC6 IF (&CPY@C6@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&CPY@C6@P,MONITOR=COMPONENTS                 06880000
//CPYC6 ENDIF                                                           08050000
//*
//DCLD1 IF (&DCL@D1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&DCL@D1@P,MONITOR=COMPONENTS                 06880000
//DCLD1 ENDIF                                                           08050000
//DCLD2 IF (&DCL@D2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&DCL@D2@P,MONITOR=COMPONENTS                 06880000
//DCLD2 ENDIF                                                           08050000
//         DD DISP=SHR,DSN=&SDFHCOB,MONITOR=COMPONENTS                  06880000
//         DD DISP=SHR,DSN=&SCEESAMP,MONITOR=COMPONENTS                 06890000
//         DD DISP=SHR,DSN=&SCSQCOBC,MONITOR=COMPONENTS                 06900000
//         DD DISP=SHR,DSN=&CAISRC,MONITOR=COMPONENTS                   06920000
//*                                                                     06930000
//DB2DBR IF ('&C1PRGRP(5,1)' = '2' AND DB2.RUN=FALSE) THEN
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//DBRMLIB  DD DISP=SHR,DSN=&DBRXX(&C1ELEMENT),                          06510000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02520000
//TESTX  ELSE
//DBRMLIB  DD DISP=SHR,DSN=&DBR(&C1ELEMENT),                            06510000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02520000
//TESTX  ENDIF
//DB2DBR ENDIF
//*
//CIC  IF ('&C1PRGRP(1,4)' = 'COBO' OR '&C1PRGRP(1,4)' = 'OBJO') THEN
//DB2O IF ('&C1PRGRP(5,1)' = '2' AND DB2.RUN=FALSE) THEN
//SYSIN    DD *
CBL SQL('SOURCE,VERSION(&DB2VER)'),LIB
//         DD DSN=&&CICOUT,DISP=(OLD,PASS)                              06970000
//DB2O ELSE
//SYSIN    DD DSN=&&CICOUT,DISP=(OLD,PASS)                              06970000
//DB2O ENDIF
//*
//CIC  ELSE
//*
//DB2B IF ('&C1PRGRP(5,1)' = '2' AND DB2.RUN=FALSE) THEN
//SYSIN    DD *
CBL SQL('SOURCE,VERSION(&DB2VER)'),LIB
//         DD DSN=&&ELMOUT,DISP=(OLD,PASS)                              06970000
//DB2B ELSE
//DB2  IF ('&C1PRGRP(5,1)' = '2' AND DB2.RUN) THEN
//SYSIN    DD DSN=&&DB2OUT,DISP=(OLD,PASS)                              06970000
//DB2  ELSE
//SYSIN    DD DSN=&&ELMOUT,DISP=(OLD,PASS)                              06970000
//DB2  ENDIF
//DB2B ENDIF
//CIC  ENDIF
//*                                                                     06990000
//SYSUT1   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07000000
//SYSUT2   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07010000
//SYSUT3   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07020000
//SYSUT4   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07030000
//SYSUT5   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07040000
//SYSUT6   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07050000
//SYSUT7   DD UNIT=&TMP,SPACE=(CYL,(5,5))                               07060000
//*                                                                     07070000
//SRO   IF ('&C1PRGRP(1,3)' = 'XXX') THEN
//*                                                                     01800000
//SROX   IF ('&C1ST(1,4)' = 'TEST') THEN                                02470001
//SYSLIN   DD DISP=SHR,DSN=&SROXX,                                      02480000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02490000
//SROX   ELSE                                                           02500000
//SYSLIN   DD DISP=SHR,DSN=&SRO,                                        02510000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02520000
//SROX   ENDIF                                                          02530000
//*                                                                     01800000
//SRO   ELSE
//SYSLIN   DD DISP=(NEW,PASS),DSN=&&OBJ,FOOTPRNT=CREATE,                01810000
//     UNIT=&TMP,SPACE=(CYL,(5,5)),                                     07090000
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   01830000
//SRO   ENDIF
//*                                                                     07110000
//SYSPRINT DD DSN=&&CMPLST,DISP=(SHR,PASS)                              07120000
//*                                                                     07130000
//CMP ENDIF                                                             07140000
//*                                                                     07150000
//NOLNK IF ('&C1PRGRP(1,3)' NE 'OBJ') THEN                              07160000
//LNK IF (CMP.RUN AND CMP.RC <= 4) THEN                                 07160000
//*                                                                     07170000
//*<<<                                                             >>>> 07180000
//*<<<<<<<<<<<<<<<<  8) LINK                     >>>>>>>>>>>>>>>>>>>>>> 07190000
//*<<<                                                             >>>> 07200000
//*                                                                     07210000
//LNK      EXEC PGM=CONPARMX,MAXRC=4,                                   07220000
//     PARM=(IEWL,'(&PRMLNKA)',$$$$DFLT,&C1PRGRP(1,4),&C1ELEMENT,      X07230000
//             '(&PRMLNKZ)','Y','N')                                    07240000
//*                                                                     07250000
//PARMSDEF DD DISP=(,DELETE),DSN=&&NULLOPT,                             07260000
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               07270000
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          07280000
//*                                                                     07290000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    06510000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           07370000
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  06510000
//PARMS    DD SYSOUT=*                                                  07380000
//*                                                                     07390000
//SYSLIB   DD DSN=&&NULLLNK,DISP=(,PASS),                               07400000
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),                                   07410000
//     LRECL=0,RECFM=U,BLKSIZE=32760                                    07420000
//*                                                                     07430000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&LNKXX,MONITOR=COMPONENTS                    07470000
//         DD DISP=SHR,DSN=&LODXX,MONITOR=COMPONENTS                    07470000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&LNK,MONITOR=COMPONENTS,ALLOC=LMAP           07470000
//         DD DISP=SHR,DSN=&LOD,MONITOR=COMPONENTS,ALLOC=LMAP           07470000
//LODL1 IF (&LOD@L1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&LOD@L1@P,MONITOR=COMPONENTS                 06880000
//LODL1 ENDIF                                                           08050000
//LODL2 IF (&LOD@L2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&LOD@L2@P,MONITOR=COMPONENTS                 06880000
//LODL2 ENDIF                                                           08050000
//*                                                                     07600000
//* CHGMAN DATASETS ARE TEMPORARY
//*                                                                     07600000
//         DD DISP=SHR,DSN=&SCEELKED,MONITOR=COMPONENTS                 07610000
//         DD DISP=SHR,DSN=&SDFHLOAD,MONITOR=COMPONENTS                 07620000
//         DD DISP=SHR,DSN=&SCSQLOAD,MONITOR=COMPONENTS                 07620000
//****     DD DISP=SHR,DSN=&SEZATCP,MONITOR=COMPONENTS                  07650000
//*                                                                     07660000
//SYSLIN   DD DISP=(OLD,PASS),DSN=&&OBJ,                                07770000
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   07780000
//*******  DD DSN=&LNKPARM(&C1PRGRP),DISP=SHR,MONITOR=COMPONENTS
//         DD DISP=(OLD,PASS),DSN=&&LCTOUT,                             07830000
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   07840000
//*                                                                     07860000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//SYSLMOD  DD DISP=SHR,DSN=&LNKXX,                                      07910000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               07920000
//TESTX  ELSE
//SYSLMOD  DD DISP=SHR,DSN=&LNK,                                        07910000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               07920000
//TESTX  ENDIF
//*                                                                     07940000
//SYSPRINT DD DSN=&&LNKLST,DISP=(SHR,PASS)                              07950000
//*                                                                     07960000
//SYSUT1   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               07970000
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<<  9) LINK COBX CICS           >>>>>>>>>>>>>>>>>>>>>> 07190000
//*<<<                                                             >>>> 07200000
//*                                                                     07210000
//LNKX     EXEC PGM=CONPARMX,MAXRC=4,                                   07220000
//     EXECIF=('&C1PRGRP(1,4)',EQ,'COBX'),
//     PARM=(IEWL,'(&PRMLNKA)',$$$$DFLT,&LNKCOBX,&C1ELEMENT,           X07230000
//             '(&PRMLNKZ)','Y','N')                                    07240000
//*                                                                     07250000
//PARMSDEF DD DISP=(,DELETE),DSN=&&NULLOPT,                             07260000
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               07270000
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          07280000
//*                                                                     07290000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    06510000
//TESTX  ENDIF
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           07370000
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  06510000
//PARMS    DD SYSOUT=*                                                  07380000
//*                                                                     07390000
//SYSLIB   DD DSN=&&NULLLNK,DISP=(,PASS),                               07400000
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),                                   07410000
//     LRECL=0,RECFM=U,BLKSIZE=32760                                    07420000
//*                                                                     07430000
//         DD DISP=SHR,DSN=&LNK2,MONITOR=COMPONENTS,ALLOC=LMAP          07470000
//         DD DISP=SHR,DSN=&LNK,MONITOR=COMPONENTS,ALLOC=LMAP           07470000
//LODL1 IF (&LOD@L1@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&LOD@L1@P,MONITOR=COMPONENTS                 06880000
//LODL1 ENDIF                                                           08050000
//LODL2 IF (&LOD@L2@P GE 'A') THEN                                      08050000
//         DD DISP=SHR,DSN=&LOD@L2@P,MONITOR=COMPONENTS                 06880000
//LODL2 ENDIF                                                           08050000
//*                                                                     07600000
//* CHGMAN DATASETS ARE TEMPORARY
//*                                                                     07600000
//         DD DISP=SHR,DSN=&SCEELKED,MONITOR=COMPONENTS                 07610000
//         DD DISP=SHR,DSN=&SDFHLOAD,MONITOR=COMPONENTS                 07620000
//         DD DISP=SHR,DSN=&SCSQLOAD,MONITOR=COMPONENTS                 07620000
//****     DD DISP=SHR,DSN=&SEZATCP,MONITOR=COMPONENTS                  07650000
//*                                                                     07660000
//SYSLIN   DD DISP=(OLD,PASS),DSN=&&OBJ,                                07770000
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   07780000
//*******  DD DSN=&LNKPARM(&LNKCOBX),DISP=SHR,MONITOR=COMPONENTS
//         DD DISP=(OLD,PASS),DSN=&&LCTOUT,                             07830000
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   07840000
//*                                                                     07860000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN
//SYSLMOD  DD DISP=SHR,DSN=&LNK2XX,                                     07910000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               07920000
//TESTX  ELSE
//SYSLMOD  DD DISP=SHR,DSN=&LNK2,                                       07910000
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               07920000
//TESTX  ENDIF
//*                                                                     07940000
//SYSPRINT DD DSN=&&LNKXLST,DISP=(SHR,PASS)                             07950000
//*                                                                     07960000
//SYSUT1   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               07970000
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 10) PROCESS DB2              >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//LNKOK IF (LNK.RUN AND LNK.RC <= 4) THEN                               07160000
//*                                                                     08020000
//DB2  IF ('&C1PRGRP(5,1)' = '2') THEN
//FRDDB2PL EXEC PGM=IKJEFT01,MAXRC=2,ALTID=NO
//*
//SYSPROC  DD DSN=&EDVREX,DISP=SHR
//SYSTSIN  DD *
 ISPSTART CMD(FRDDB2PL)
//*
//ISPPLIB  DD DSN=SYS3.ISPF.ISPPLIB,DISP=SHR
//ISPSLIB  DD DSN=SYS3.ISPF.ISPSLIB,DISP=SHR
//ISPLLIB  DD DSN=SYS3.ISPF.ISPLLIB,DISP=SHR
//ISPMLIB  DD DSN=SYS3.ISPF.ISPMLIB,DISP=SHR
//ISPTLIB  DD DCB=(LRECL=80,RECFM=FB),
//     UNIT=SYSDA,SPACE=(TRK,(4,1,4))
//         DD DSN=SYS3.ISPF.ISPTLIB,DISP=SHR
//ISPTABL  DD DUMMY
//ISPLOG   DD SYSOUT=*,
//     RECFM=VA,LRECL=125,BLKSIZE=129
//ISPPROF  DD DSN=&&BNDPROF,
//     SPACE=(TRK,(1,1,2)),UNIT=SYSDA,DISP=(,DELETE),
//     LRECL=80,RECFM=FB,BLKSIZE=800,DSORG=PO
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSTSPRT DD DISP=(SHR,PASS),DSN=&&DB2LST1
//REPORT   DD DISP=(SHR,PASS),DSN=&&DB2RPT1
//BINDJOBS DD SYSOUT=(A,INTRDR)   ** USED ONLY DURING PROMOTION **
//*
//DB2BCTL  DD DSN=&TMP$BC,DISP=(MOD,CATLG),
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,
//     LRECL=80,RECFM=FB,BLKSIZE=27920
//*
//DB2SSIDS DD *
&#DB2SYS
//CMNPLCTL DD *
TYPE=STAGE
TARGET=PACKAGE
PACKAGE=&C1SY
PACKAGETYPE=PLANNED
XDATASET=&HILVL..&C1ST..&C1SY..&C1SU..X
STGLIB=&STGLIB
SSI=5F4F9B4B
PCVER='&DB2VER'
USEROPTS='NNNNNNNYNNNNNNNNNNNY'
//CMNPLPKG DD *            PKG COMPONENTS
&C1ELEMENT
//CMNPLDBR DD *            DBR COMPONENTS
&C1ELEMENT
//CMNPLDBB DD *            DBB COMPONENTS
&C1ELEMENT
//PKGSBAS   DD DISP=(,PASS),DSN=&&NULLPKG,
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=27920
//PKGTST IF ('&C1ST(1,4)' = 'TEST') THEN
//          DD DISP=SHR,DSN=&PKGXX,MONITOR=COMPONENTS
//PKGTST ELSE
//          DD DISP=SHR,DSN=&PKG,MONITOR=COMPONENTS
//PKGTST ENDIF
//PKGSDEF   DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..PKG,
//     MONITOR=COMPONENTS
//*
//DBBSBAS   DD DISP=(,PASS),DSN=&&NULLDBB,
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=27920
//DBBTST IF ('&C1ST(1,4)' = 'TEST') THEN
//          DD DISP=SHR,DSN=&DBBXX,MONITOR=COMPONENTS
//DBBTST ELSE
//          DD DISP=SHR,DSN=&DBB,MONITOR=COMPONENTS
//DBBTST ENDIF
//*
//DBBSDEF   DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..DBB,
//     MONITOR=COMPONENTS
//DBRTST IF ('&C1ST(1,4)' = 'TEST') THEN
//DBRSSTG   DD DISP=SHR,DSN=&DBRXX,MONITOR=COMPONENTS
//DBRSBAS   DD DISP=SHR,DSN=&DBRXX,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=&DBR,MONITOR=COMPONENTS,ALLOC=LMAP
//DBRTST ELSE
//DBRSSTG   DD DISP=SHR,DSN=&DBR,MONITOR=COMPONENTS
//DBRSBAS   DD DISP=SHR,DSN=&DBR,MONITOR=COMPONENTS,ALLOC=LMAP
//DBRTST ENDIF
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 11) SAVE DB2 $BC CARDS       >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//SAVTMP   EXEC PGM=IEBGENER,ALTID=NO
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&TMP$BC,DISP=(SHR,DELETE)
//SYSUT2   DD DSN=&&DB2BCTL,DISP=(,PASS),
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,
//     LRECL=80,RECFM=FB,BLKSIZE=27920
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 11) SAVE DB2 $BC CARDS       >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//SAV$BC   EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&DB2BCTL,DISP=(SHR,PASS)
//CTLTST IF ('&C1ST(1,4)' = 'TEST') THEN
//SYSUT2   DD DISP=SHR,DSN=&DB2$BCXX(&C1ELEMENT),
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02490000
//CTLTST ELSE
//SYSUT2   DD DISP=SHR,DSN=&DB2$BC(&C1ELEMENT),
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               02490000
//CTLTST ENDIF
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 11) BUILD DB2 CARDS          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//FRDDB2BC EXEC PGM=IKJEFT01,MAXRC=1
//*
//SYSPROC  DD DSN=&EDVREX,DISP=SHR
//SYSTSIN  DD *
 ISPSTART CMD(FRDDB2BC)
//*
//ISPPLIB  DD DSN=SYS3.ISPF.ISPPLIB,DISP=SHR
//ISPSLIB  DD DSN=SYS3.ISPF.ISPSLIB,DISP=SHR
//ISPLLIB  DD DSN=SYS3.ISPF.ISPLLIB,DISP=SHR
//ISPMLIB  DD DSN=SYS3.ISPF.ISPMLIB,DISP=SHR
//ISPTLIB  DD DCB=(LRECL=80,RECFM=FB),
//     UNIT=SYSDA,SPACE=(TRK,(4,1,4))
//         DD DSN=SYS3.ISPF.ISPTLIB,DISP=SHR
//ISPTABL  DD DUMMY
//ISPLOG   DD SYSOUT=*,
//     RECFM=VA,LRECL=125,BLKSIZE=129
//ISPPROF  DD DSN=&&BNDPROF,
//     SPACE=(TRK,(1,1,2)),UNIT=SYSDA,DISP=(,DELETE),
//     LRECL=80,RECFM=FB,BLKSIZE=800,DSORG=PO
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSTSPRT DD DISP=(SHR,PASS),DSN=&&DB2LST2
//REPORT   DD DISP=(SHR,PASS),DSN=&&DB2RPT2
//OUTPUTBC DD DISP=(NEW,PASS),
//     DSN=&&FRDDB2BC,
//     UNIT=&TMP,SPACE=(CYL,(1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=16000,DSORG=PS
//OUTPUTGC DD DISP=(NEW,PASS),
//     DSN=&&FRDDB2GC,
//     UNIT=&TMP,SPACE=(CYL,(1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=16000,DSORG=PS
//OUTPUTSQ DD DISP=(NEW,PASS),
//     DSN=&&FRDDB2SQ,
//     UNIT=&TMP,SPACE=(CYL,(1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=16000,DSORG=PS
//*
//CTLTST IF ('&C1ST(1,4)' = 'TEST') THEN
//INPUTBC  DD DISP=SHR,DSN=&DB2$BCXX(&C1ELEMENT)
//CTLTST ELSE
//INPUTBC  DD DISP=SHR,DSN=&DB2$BC(&C1ELEMENT)
//CTLTST ENDIF
//*
//CNTL     DD *
TYPE=PROMOTE
 TARGET=&#DB2SYS
 PACKAGE=&C1SY
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 12) INVOKE DB2 BIND          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//PKGBIND  EXEC PGM=IKJEFT01,
//     PARM='EN$BIND BIND,&C1TY,&C1ELEMENT',MAXRC=04,
//     EXECIF=(&C1ST,NE,'PROD')
//STEPLIB   DD  DISP=SHR,DSN=&SDSNEXIT
//          DD  DISP=SHR,DSN=&SDSNLOAD
//SYSPROC   DD  DISP=SHR,DSN=&EDVREX
//*
//DBRTST IF ('&C1ST(1,4)' = 'TEST') THEN
//DBRMLIB   DD DISP=SHR,DSN=&DBRXX
//          DD DISP=SHR,DSN=&DBR,ALLOC=LMAP
//DBB$$CHK  DD DISP=SHR,DSN=&DBBXX
//DBRTST ELSE
//DBRMLIB   DD DISP=SHR,DSN=&DBR,ALLOC=LMAP
//DBB$$CHK  DD DISP=SHR,DSN=&DBB
//DBRTST ENDIF
//*
//SYSPRINT  DD  SYSOUT=*
//SYSTSPRT  DD  DSN=&&PKGBND,DISP=(SHR,PASS)
//SYSTSIN   DD  DUMMY
//PKGIN     DD  DISP=(OLD,DELETE),DSN=&&FRDDB2BC
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 13) INVOKE DB2 GRANTS        >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//DB2GRANT EXEC PGM=IKJEFT01,
//     PARM='EN$BIND GRANT,&C1TY,&C1ELEMENT',MAXRC=04
//*
//STEPLIB   DD  DISP=SHR,DSN=&SDSNEXIT
//          DD  DISP=SHR,DSN=&SDSNLOAD
//SYSPROC   DD  DISP=SHR,DSN=&EDVREX
//SYSPRINT  DD  DSN=&&DB2GRNT,DISP=(SHR,PASS)
//SYSTSPRT  DD  SYSOUT=*
//SYSIN     DD  DISP=(OLD,DELETE),DSN=&&FRDDB2SQ
//          DD  DISP=(OLD,DELETE),DSN=&&FRDDB2GC
//SYSTSIN   DD  DUMMY
//PKGIN     DD  *
 DSN SYSTEM(&#DB2SYS)
 RUN PROGRAM(DSNTEP2) PLAN(DSNTEP2)
 END
/*
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 14) PROCESS DB2 STP          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//BLDSTP    EXEC PGM=IEBGENER,MAXRC=0,
//        EXECIF=('&C1PRGRP(1,3)',EQ,'STP')
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD *
DSN SYSTEM(&#DB2SYS) RETRY(10)
-STOP PROCEDURE (&C1ELEMENT) ACTION(QUEUE)
-START PROCEDURE (&C1ELEMENT)
//SYSUT2   DD DISP=(,PASS),DSN=&&DB2STPS,
//     UNIT=&TMP,SPACE=(TRK,(1,1)),
//     LRECL=80,RECFM=FB,BLKSIZE=16000,DSORG=PS
//*
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 15) PROCESS DB2 STP          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//STP$$ACT EXEC PGM=IKJEFT01,
//     PARM='EN$BIND STP,&C1TY,&C1ELEMENT',MAXRC=04,
//     EXECIF=('&C1PRGRP(1,3)',EQ,'STP')
//STEPLIB   DD  DISP=SHR,DSN=&SDSNEXIT
//          DD  DISP=SHR,DSN=&SDSNLOAD
//SYSPROC   DD  DISP=SHR,DSN=&#EDVREX
//SYSTSPRT  DD  DSN=&&STPLST,DISP=(SHR,PASS)
//SYSPRINT  DD  SYSOUT=*
//SYSTSIN   DD  DUMMY
//PKGIN     DD  DISP=(OLD,DELETE),DSN=&&DB2STPS
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 11) BUILD DB2 CARDS          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//FRDWLMDB EXEC PGM=IKJEFT01,MAXRC=0,
//        EXECIF=('&C1PRGRP(1,3)',EQ,'STP')
//*
//SYSPROC  DD DSN=&EDVREX,DISP=SHR
//SYSTSIN  DD *
 ISPSTART CMD(FRDWLMDB)
//*
//ISPPLIB  DD DSN=SYS3.ISPF.ISPPLIB,DISP=SHR
//ISPSLIB  DD DSN=SYS3.ISPF.ISPSLIB,DISP=SHR
//ISPLLIB  DD DSN=SYS3.ISPF.ISPLLIB,DISP=SHR
//ISPMLIB  DD DSN=SYS3.ISPF.ISPMLIB,DISP=SHR
//ISPTLIB  DD DCB=(LRECL=80,RECFM=FB),
//     UNIT=SYSDA,SPACE=(TRK,(4,1,4))
//         DD DSN=SYS3.ISPF.ISPTLIB,DISP=SHR
//ISPTABL  DD DUMMY
//ISPLOG   DD SYSOUT=*,
//     RECFM=VA,LRECL=125,BLKSIZE=129
//ISPPROF  DD DSN=&&BNDPROF,
//     SPACE=(TRK,(1,1,2)),UNIT=SYSDA,DISP=(,DELETE),
//     LRECL=80,RECFM=FB,BLKSIZE=800,DSORG=PO
//*
//SYSTERM  DD SYSOUT=*
//SYSTSPRT DD DISP=(SHR,PASS),DSN=&&DB2LST3
//OUTPUTBC DD DISP=(NEW,PASS),
//     DSN=&&FRDWLMDB,
//     UNIT=&TMP,SPACE=(CYL,(2,2)),
//     LRECL=80,RECFM=FB,BLKSIZE=16000,DSORG=PS
//CTLTST IF ('&C1ST(1,4)' = 'TEST') THEN
//INPUTBC  DD DISP=SHR,DSN=&DB2$BCXX(&C1ELEMENT)
//CTLTST ELSE
//INPUTBC  DD DISP=SHR,DSN=&DB2$BC(&C1ELEMENT)
//CTLTST ENDIF
//*
//CNTL     DD *
&C1ELEMENT
//*                                                                     07980000
//FRDWLMEX EXEC PGM=IKJEFT01,
//     PARM='EN$BIND STP,&C1TY,&C1ELEMENT',MAXRC=04,
//     EXECIF=('&C1PRGRP(1,3)',EQ,'STP')
//*                                                                     07980000
//STEPLIB   DD  DISP=SHR,DSN=&SDSNEXIT
//          DD  DISP=SHR,DSN=&SDSNLOAD
//SYSPROC   DD  DISP=SHR,DSN=&#EDVREX
//SYSTSIN   DD  DUMMY
//PKGIN     DD *
 DSN SYSTEM(&#DB2SYS)
 RUN PROGRAM(DSNTEP2) PLAN(DSNTEP2)
 END
//SYSIN        DD DISP=(OLD,PASS),DSN=&&FRDWLMDB
//SYSTSPRT     DD DISP=(SHR,PASS),DSN=&&WLMLST1
//SYSPRINT     DD DISP=(SHR,PASS),DSN=&&WLMLST2
//*
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 11) BUILD DB2 CARDS          >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//FRDWLMRF EXEC PGM=IKJEFT01,MAXRC=0,
//        EXECIF=('&C1PRGRP(1,3)',EQ,'STP')
//*
//SYSPROC  DD DSN=&EDVREX,DISP=SHR
//SYSTSIN  DD *
 ISPSTART CMD(FRDWLMRF)
//ISPPLIB  DD DSN=SYS3.ISPF.ISPPLIB,DISP=SHR
//ISPSLIB  DD DSN=SYS3.ISPF.ISPSLIB,DISP=SHR
//ISPLLIB  DD DSN=SYS3.ISPF.ISPLLIB,DISP=SHR
//ISPMLIB  DD DSN=SYS3.ISPF.ISPMLIB,DISP=SHR
//ISPTLIB  DD DCB=(LRECL=80,RECFM=FB),
//     UNIT=&TMP,SPACE=(TRK,(4,1,4))
//         DD DSN=SYS3.ISPF.ISPTLIB,DISP=SHR
//ISPTABL  DD DUMMY
//ISPLOG   DD SYSOUT=*,
//     RECFM=VA,LRECL=125,BLKSIZE=129
//ISPPROF  DD DSN=&&BNDPROF,
//     SPACE=(TRK,(1,1,2)),UNIT=SYSDA,DISP=(,DELETE),
//     LRECL=80,RECFM=FB,BLKSIZE=800,DSORG=PO
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSTSPRT DD DISP=(SHR,PASS),DSN=&&WLMLST3
//SYSROUTN DD DISP=(OLD,PASS),DSN=&&WLMLST2
//*
//DB2  ENDIF
//*                                                                     07980000
//*<<<                                                             >>>> 07990000
//*<<<<<<<<<<<<<<<< 16) OTHER  OUTPUT DATASETS   >>>>>>>>>>>>>>>>>>>>>> 08000000
//*<<<                                                             >>>> 08010000
//*                                                                     08020000
//*  IF SITE SYMBOLIC ND1CHGM POINTS TO VALID DSN                       08020000
//*                                                                     08020000
//LOD1CPY EXEC PGM=BSTCOPY,MAXRC=0,EXECIF=(&ND1CHGM,GE,'A')             08050000
//*                                                                     08040000
//SYSPRINT DD DSN=&&CHG1CPY,DISP=(SHR,PASS)                             08070000
//SYSUT3   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               08080000
//SYSUT4   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               08090000
//*                                                                     08100000
//SANDBXI IF ('&C1ST(1,4)' = 'TEST') THEN                               08110000
//INLOD    DD DSN=&LNKXX,DISP=SHR                                       08120000
//SANDBXI ELSE                                                          08130000
//INLOD    DD DSN=&LNK,DISP=SHR                                         08140000
//SANDBXI ENDIF                                                         08150000
//*                                                                     08160000
//OTLOD    DD DSN=&ND1CHGM,DISP=SHR,MONITOR=COMPONENTS                  08200000
//*                                                                     08220000
//SYSIN    DD *                                                         08230000
    COPY OUTDD=OTLOD,INDD=INLOD                                         08240000
      S M=((&C1ELEMENT,,R))                                             08250000
//*                                                                     08260000
//*  IF SITE SYMBOLIC ND2CHGM POINTS TO VALID DSN                       08020000
//*                                                                     08260000
//LOD2CPY EXEC PGM=BSTCOPY,MAXRC=0,EXECIF=(&ND2CHGM,GE,'A')             08050000
//*                                                                     08040000
//SYSPRINT DD DSN=&&CHG2CPY,DISP=(SHR,PASS)                             08070000
//SYSUT3   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               08080000
//SYSUT4   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               08090000
//*                                                                     08100000
//SANDBXI IF ('&C1ST(1,4)' = 'TEST') THEN                               08110000
//DBRX IF ('&C1PRGRP(5,1)' = '2') THEN
//INLDX    DD DSN=&DBRXX,DISP=SHR                                       08120000
//DBRX ELSE
//INLDX    DD DSN=&LNK2XX,DISP=SHR                                      08120000
//DBRX ENDIF
//*
//SANDBXI ELSE                                                          08130000
//*
//DBR  IF ('&C1PRGRP(5,1)' = '2') THEN
//INLDX    DD DSN=&DBR,DISP=SHR                                         08120000
//DBR  ELSE
//INLDX    DD DSN=&LNK2,DISP=SHR                                        08140000
//DBR  ENDIF
//*
//SANDBXI ENDIF                                                         08150000
//*                                                                     08160000
//OTLDX    DD DSN=&ND2CHGM,DISP=SHR,MONITOR=COMPONENTS                  08200000
//*                                                                     08220000
//SYSIN    DD *                                                         08230000
    COPY OUTDD=OTLDX,INDD=INLDX                                         08240000
      S M=((&C1ELEMENT,,R))                                             08250000
//*                                                                     08260000
//*<<<                                                             >>>> 09390000
//*<<<<<<<<<<<<<<<< 17) INVOKE CICS NEWCOPY      >>>>>>>>>>>>>>>>>>>>>> 09400000
//*<<<                                                             >>>> 09410000
//*                                                                     09420000
//CICNC IF ('&C1PRGRP(1,4)' = 'COBO') THEN
//*                                                                     09420000
//CICNC01 EXEC PGM=IEBGENER,EXECIF=(&#CICNC01,GE,'A')
//SYSPRINT  DD DUMMY
//SYSIN     DD DUMMY
//SYSUT2    DD SYSOUT=(A,INTRDR),RECFM=FB,BLKSIZE=80
//SYSUT1    DD DATA,DLM=$$
//&C1USERID.1 JOB (2,90118,PRINT-DEST),'CICNC &#CICNC01',
//         MSGCLASS=9,MSGLEVEL=(1,1)
/*JOBPARM S=&#CICLPAR
//*
//* CICS NEWCOPY
//* RGN  &#CICNC01
//* ELM  &C1ELEMENT
//*
//CICNC01 EXEC PGM=AFCP2016,PARM=SYSIN                                  00010000
//STEPLIB   DD DSN=&SD$CICS,DISP=SHR                                    00040000
//SYSPRINT  DD SYSOUT=*                                                 00050000
//SYSUDUMP  DD SYSOUT=*                                                 00060000
//CAFCTRAC  DD SYSOUT=*                                                 00070000
//SYSIN     DD *                                                        00080000
&#CICNC01,CEMT,SET PROG(&C1ELEMENT) PH                                  00090000
$$
//*                                                                     09440000
//CICNC02 EXEC PGM=IEBGENER,EXECIF=(&#CICNC02,GE,'A')
//SYSPRINT  DD DUMMY
//SYSIN     DD DUMMY
//SYSUT2    DD SYSOUT=(A,INTRDR),RECFM=FB,BLKSIZE=80
//SYSUT1    DD DATA,DLM=$$
//&C1USERID.2 JOB (2,90118,PRINT-DEST),'CICNC &#CICNC02',
//         MSGCLASS=9,MSGLEVEL=(1,1)
/*JOBPARM S=&#CICLPAR
//*
//* CICS NEWCOPY
//* RGN  &#CICNC02
//* ELM  &C1ELEMENT
//*
//CICNC02 EXEC PGM=AFCP2016,PARM=SYSIN                                  00010000
//STEPLIB   DD DSN=&SD$CICS,DISP=SHR                                    00040000
//SYSPRINT  DD SYSOUT=*                                                 00050000
//SYSUDUMP  DD SYSOUT=*                                                 00060000
//CAFCTRAC  DD SYSOUT=*                                                 00070000
//SYSIN     DD *                                                        00080000
&#CICNC02,CEMT,SET PROG(&C1ELEMENT) PH                                  00090000
$$
//*                                                                     09440000
//CICNC ENDIF
//LNKOK ENDIF                                                           07160000
//*                                                                     09440000
//*<<<                                                             >>>> 09450000
//*<<<<<<<<<<<<<<<< 18) DELETE TEMP INPUT        >>>>>>>>>>>>>>>>>>>>>> 09460000
//*<<<                                                             >>>> 09470000
//*                                                                     09480000
//DELTMP   EXEC PGM=IEFBR14                                             09490000
//ELMOUT   DD DSN=&&ELMOUT,DISP=(OLD,DELETE),FREE=CLOSE                 09500000
//LCTOUT   DD DSN=&&LCTOUT,DISP=(OLD,DELETE),FREE=CLOSE                 09500000
//OBJ      DD DSN=&&OBJ,DISP=(OLD,DELETE),FREE=CLOSE                    09500000
//LNK ENDIF                                                             09430000
//NOLNK ENDIF                                                           07160000
//*                                                                     09590000
//*<<<                                                             >>>> 09630000
//*<<<<<<<<<<<<<<<< 19) PRINT LISTING            >>>>>>>>>>>>>>>>>>>>>> 09640000
//*<<<                                                             >>>> 09650000
//*                                                                     09660000
//PRTLST   EXEC PGM=CONLIST,PARM=PRINT,COND=EVEN,MAXRC=0                09670000
//C1PRINT  DD SYSOUT=&PRTOUT,FREE=CLOSE,                                09680000
//     RECFM=FBA,LRECL=133,BLKSIZE=27930                                09690000
//C1BANNER DD DISP=(NEW,DELETE),UNIT=&TMP,SPACE=(TRK,(1,1)),            09700000
//     RECFM=FBA,LRECL=121,BLKSIZE=27951                                09710000
//LIST01   DD *                                                         09720000
  ##########  ELEMENT INVENTORY LOCATION #######                        09730000
  &C1ST/&C1SY/&C1SU/&C1TY/&C1ELEMENT      PROCESSOR GROUP: &C1PRGRP     09740000
// IF (DB2.RUN AND DB2.RC > 4) THEN                                     09800000
//LIST02   DD *                                                         09810000
  ##########  DB2 PREPROCESSOR ##########                               10270000
//LIST03   DD DSN=&&DB2LST,DISP=(OLD,PASS)                              10280000
// ENDIF                                                                09840000
// IF (TRN.RUN AND TRN.RC > 4) THEN                                     09800000
//LIST04   DD *                                                         09810000
  ##########  CICS TRN ##########                                       09820000
//LIST05   DD DSN=&&TRNLST,DISP=(OLD,PASS)                              09830000
// ENDIF                                                                09840000
// IF (CMP.RUN AND CMP.RC > 4) THEN                                     09800000
//LIST06   DD *                                                         09810000
  ##########  COMPILE  ##########                                       09820000
//LIST07   DD DSN=&&CMPLST,DISP=(OLD,PASS)                              09830000
// ENDIF                                                                09840000
// IF (LNK.RUN) THEN                                                    09850000
//LIST08   DD *                                                         09860000
  ##########  LINK EDIT &C1PRGRP ##########                             09870000
//LIST09   DD DSN=&&LNKLST,DISP=(OLD,PASS)                              09880000
// ENDIF                                                                09890000
// IF (LNKX.RUN) THEN                                                   09850000
//LIST10   DD *                                                         09860000
  ##########  LINK EDIT COBX     ##########                             09870000
//LIST11   DD DSN=&&LNKXLST,DISP=(OLD,PASS)                             09880000
// ENDIF                                                                09890000
// IF ('&C1PRGRP(5,1)' = '2') THEN                                      09850000
//LIST12   DD *                                                         09860000
  ##########  POST DB2 TASKS     ##########                             09870000
//LIST13   DD DSN=&&DB2LST1,DISP=(OLD,PASS)                             09880000
//LIST14   DD DSN=&&DB2RPT1,DISP=(OLD,PASS)                             09880000
//LIST15   DD DSN=&&DB2LST2,DISP=(OLD,PASS)                             09880000
//LIST16   DD DSN=&&DB2RPT2,DISP=(OLD,PASS)                             09880000
//LIST17   DD DSN=&&PKGBND,DISP=(OLD,PASS)                              09880000
//LIST18   DD DSN=&&DB2GRNT,DISP=(OLD,PASS)                             09880000
//LIST19   DD DSN=&&STPLST,DISP=(OLD,PASS)                              09880000
//LIST20   DD DSN=&&DB2LST3,DISP=(OLD,PASS)                             09880000
//LIST21   DD DSN=&&WLMLST1,DISP=(OLD,PASS)                             09880000
//LIST22   DD DSN=&&WLMLST2,DISP=(OLD,PASS)                             09880000
//LIST23   DD DSN=&&WLMLST3,DISP=(OLD,PASS)                             09880000
// ENDIF                                                                09890000
//LIST24   DD DSN=&&XPDCPY,DISP=(OLD,PASS)                              09900000
//LIST25   DD DSN=&&CHG1CPY,DISP=(OLD,PASS)                             09900000
//LIST26   DD DSN=&&CHG2CPY,DISP=(OLD,PASS)                             09900000
//LIST27   DD DSN=&&BLDLNK,DISP=(OLD,PASS)                              10360000
//*                                                                     10010000
//*<<<                                                             >>>> 10020000
//*<<<<<<<<<<<<<<<< 20) SAVE LISTING             >>>>>>>>>>>>>>>>>>>>>> 10030000
//*<<<                                                             >>>> 10040000
//*                                                                     10050000
//SAVLST   EXEC PGM=CONLIST,PARM='STORE.MBR(&C1ELEMENT.#&LSTSFX)',
//      COND=EVEN,MAXRC=0
//C1BANNER DD DISP=(NEW,DELETE),UNIT=&TMP,SPACE=(TRK,(1,1)),            10080000
//     RECFM=FBA,LRECL=121,BLKSIZE=27951                                10090000
//*                                                                     10100000
//LLIBO  IF ('&C1ST(1,4)' = 'TEST') THEN                                10110000
//C1LLIBO  DD DISP=SHR,DSN=&OLLIBXX,MONITOR=COMPONENTS                  10120000
//LLIBO  ELSE                                                           10130000
//C1LLIBO  DD DISP=SHR,DSN=&OLLIB,MONITOR=COMPONENTS                    10140000
//LLIBO  ENDIF                                                          10150000
//*                                                                     10160000
//LIST01   DD *                                                         10170000
  ##########  ELEMENT INVENTORY LOCATION #######                        10180000
  &C1ST/&C1SY/&C1SU/&C1TY/&C1ELEMENT      PROCESSOR GROUP: &C1PRGRP     10190000
// IF (DB2.RUN) THEN                                                    10250000
//LIST02   DD *                                                         10260000
  ##########  DB2 PREPROCESSOR ##########                               10270000
//LIST03   DD DSN=&&DB2LST,DISP=(OLD,DELETE),FREE=CLOSE                 10280000
// ENDIF                                                                10290000
// IF (TRN.RUN) THEN                                                    10250000
//LIST04   DD *                                                         10260000
  ##########  CICS TRN ##########                                       10270000
//LIST05   DD DSN=&&TRNLST,DISP=(OLD,DELETE),FREE=CLOSE                 10280000
// ENDIF                                                                10290000
// IF (CMP.RUN) THEN                                                    10250000
//LIST06   DD *                                                         10260000
  ##########  COMPILE  ##########                                       10270000
//LIST07   DD DSN=&&CMPLST,DISP=(OLD,DELETE),FREE=CLOSE                 10280000
// ENDIF                                                                10290000
// IF (LNK.RUN) THEN                                                    10300000
//LIST08   DD *                                                         10310000
  ##########  LINK EDIT &C1PRGRP ##########                             09870000
//LIST09   DD DSN=&&LNKLST,DISP=(OLD,DELETE),FREE=CLOSE                 10330000
// ENDIF                                                                10340000
// IF (LNKX.RUN) THEN                                                   10300000
//LIST10   DD *                                                         10310000
  ##########  LINK EDIT COBX     ##########                             09870000
//LIST11   DD DSN=&&LNKXLST,DISP=(OLD,DELETE),FREE=CLOSE                10330000
// ENDIF                                                                10340000
// IF ('&C1PRGRP(5,1)' = '2') THEN                                      09850000
//LIST12   DD *                                                         09860000
  ##########  POST DB2 TASKS     ##########                             09870000
//LIST13   DD DSN=&&DB2LST1,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST14   DD DSN=&&DB2RPT1,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST15   DD DSN=&&DB2LST2,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST16   DD DSN=&&DB2RPT2,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST17   DD DSN=&&PKGBND,DISP=(OLD,DELETE),FREE=CLOSE                 09880000
//LIST18   DD DSN=&&DB2GRNT,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST19   DD DSN=&&STPLST,DISP=(OLD,DELETE),FREE=CLOSE                 09880000
//LIST20   DD DSN=&&DB2LST3,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST21   DD DSN=&&WLMLST1,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST22   DD DSN=&&WLMLST2,DISP=(OLD,DELETE),FREE=CLOSE                09880000
//LIST23   DD DSN=&&WLMLST3,DISP=(OLD,DELETE),FREE=CLOSE                09880000
// ENDIF                                                                09890000
//LIST24   DD DSN=&&XPDCPY,DISP=(OLD,DELETE),FREE=CLOSE                 10350000
//LIST25   DD DSN=&&CHG1CPY,DISP=(OLD,DELETE),FREE=CLOSE                10350000
//LIST26   DD DSN=&&CHG2CPY,DISP=(OLD,DELETE),FREE=CLOSE                10350000
//LIST27   DD DSN=&&BLDLNK,DISP=(OLD,DELETE),FREE=CLOSE                 10360000
