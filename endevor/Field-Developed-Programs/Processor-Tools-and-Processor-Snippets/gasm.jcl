//**=================================================================** 00000100
//**  GASM - GENERATE ASSEMBLER PROGRAM                              ** 00000200
//**=================================================================** 00000300
//**   0) ALLOCATE TEMP DATASETS                                     ** 00000400
//**   1) GET SOURCE FROM ENDEVOR                                    ** 00000500
//**   3) GET LNK CARDS                                              ** 00000600
//**   4) DB2 PRE-COMPILER                                           ** 00000700
//**   6) ASSEMBLE                                                   ** 00000800
//**   8) LINK                                                       ** 00000900
//**  14) INVOKE EDVCEMT FOR CICS NEWCOPY                            ** 00001000
//**  15) SAVE  LISTINGS                                             ** 00001100
//**  16) PRINT LISTINGS                                             ** 00001200
//**=================================================================** 00001300
//GASM PROC PROCNAME=GASM,                                              00001400
//     CAISRC='&#CAISRC',                                               00001600
//     PRMCMPA='',                                                      00001700
//     PRMCMPZ='',                                                      00001800
//     PRMLNKA='',                                                      00001900
//     PRMLNKZ='',                                                      00002000
//     LNKPARM='&HILVL..PROD.LNKPARM',                                  00002100
//     LNKASMX='ASXO&C1PRGRP(5)',                                       00002200
//*                                                                     00002300
//* SYMBOLIC FOR CURRENT COPYBOOKS/MAC    SYSLIB                        00002400
//     CPYFX='&HILVL..&C1ST..CPY',                                      00002500
//     CPYXX='&HILVL..&C1ST..&C1SY..&C1SU..CPY',                        00002510
//     CPY='&HILVL..&C1ST..&C1SY..CPY',                                 00002600
//     MACFX='&HILVL..&C1ST..MAC',                                      00002700
//     MACXX='&HILVL..&C1ST..&C1SY..&C1SU..MAC',                        00002710
//     MAC='&HILVL..&C1ST..&C1SY..MAC',                                 00002800
//     CPAFX='&HILVL..&C1ST..CPC',                                      00002900
//     CPAXX='&HILVL..&C1ST..&C1SY..&C1SU..CPC',                        00002910
//     CPA='&HILVL..&C1ST..&C1SY..CPC',                                 00003000
//*                                                                     00003100
//* SYMBOLIC FOR CURRENT COMPILE OPTIONS                                00003200
//     OPTFX='&HILVL..&C1ST..OPT',                                      00003300
//     OPTXX='&HILVL..&C1ST..&C1SY..&C1SU..OPT',                        00003310
//     OPT='&HILVL..&C1ST..&C1SY..OPT',                                 00003400
//     OPTBASE='&HILVL..PROD.OPT',                                      00003500
//     LCTFX='&HILVL..&C1ST..LCT',                                      00003600
//     LCTXX='&HILVL..&C1ST..&C1SY..&C1SU..LCT',                        00003610
//     LCT='&HILVL..&C1ST..LCT',                                        00003700
//*                                                                     00003800
//* SYMBOLIC FOR CURRENT DBRMLIB                                        00003900
//     DBRFX='&HILVL..&C1ST..&#ND2NODE',                                00004000
//     DBRXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND2NODE',                  00004010
//     DBR='&HILVL..&C1ST..&C1SY..&#ND2NODE',                           00004100
//*                                                                     00004200
//     HILVL='&#HILVL.',                                                00004300
//     LSTSFX='&C1PRGRP(4,1)',                                          00004400
//*                                                                     00004500
//* SYMBOLIC FOR CURRENT SYSTEM BINDER    SYSLIB                        00004600
//     LNKFX='&HILVL..&C1ST..&#ND1NODE',                                00004700
//     LNKXX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND1NODE',                  00004710
//     LNK='&HILVL..&C1ST..&C1SY..&#ND1NODE',                           00004800
//     LNK2FX='&HILVL..&C1ST..&#ND2NODE',                               00004900
//     LNK2XX='&HILVL..&C1ST..&C1SY..&C1SU..&#ND2NODE',                 00004910
//     LNK2='&HILVL..&C1ST..&C1SY..&#ND2NODE',                          00005000
//     LODBASE='&#ND1BASE',                                             00005100
//     ND1CHGM='&#ND1CHGM',                                             00005200
//     ND2CHGM='&#ND2CHGM',                                             00005300
//*                                                                     00005400
//     PLNFX='&HILVL..&C1ST..DBB',                                      00005510
//     PLNXX='&HILVL..&C1ST..&C1SY..&C1SU..DBB',                        00005520
//     PLN='&HILVL..&C1ST..&C1SY..DBB',                                 00005600
//     PKGFX='&HILVL..&C1ST..PKG',                                      00005710
//     PKGXX='&HILVL..&C1ST..&C1SY..&C1SU..PKG',                        00005720
//     PKG='&HILVL..&C1ST..&C1SY..PKG',                                 00005800
//*                                                                     00005900
//     OLLIBXX='&HILVL..&C1ST.&C1SU..LIST',                             00006000
//     OLLIB='&HILVL..&C1ST..LIST',                                     00006100
//*                                                                     00006200
//     PRTOUT='*',                                                      00006300
//     SCEELKED='&#SCEELKED',                                           00006400
//     SCEECICS='&#SCEECICS',                                           00006500
//     SCEEMAC='&#SCEEMAC',                                             00006600
//     SCSQLOAD='&#SCSQLOAD',                                           00006700
//     SDFHLOAD='&#SDFHLOAD',                                           00006800
//     SDFHMAC='&#SDFHMAC',                                             00006900
//     SDSNEXIT='&#SDSNEXIT',                                           00007000
//     SDSNLOAD='&#SDSNLOAD',                                           00007100
//     SORCMAC='&#SORCMAC',                                             00007200
//     SYS1MAC='&#SYS1MAC',                                             00007300
//     SYS1MOD='&#SYS1MOD',                                             00007400
//     SYSWK='SYSDA',                                                   00007500
//     TMP='VIO'                                                        00007600
//*                                                                     00007700
//*                                                                     00007800
//*<<<                                                             >>>> 00007900
//*<<<<<<<<<<<<<<<<  0) ALLOCATE TEMP DATASETS   >>>>>>>>>>>>>>>>>>>>>> 00008000
//*<<<                                                             >>>> 00008100
//*                                                                     00008200
//ALLOCATE EXEC PGM=BC1PDSIN,MAXRC=0                                    00008300
//C1INIT01 DD DSN=&&DB2LST,DISP=(,PASS),                                00008400
//     UNIT=&TMP,SPACE=(CYL,(5,5)),RECFM=FBA,LRECL=121                  00008500
//C1INIT02 DD DSN=&&TRNLST,DISP=(,PASS),                                00008600
//     UNIT=&TMP,SPACE=(CYL,(2,1)),RECFM=FBA,LRECL=121                  00008700
//C1INIT03 DD DSN=&&CMPLST,DISP=(,PASS),                                00008800
//     UNIT=&TMP,SPACE=(CYL,(5,5)),RECFM=FBA,LRECL=133                  00008900
//C1INIT04 DD DSN=&&LNKLST,DISP=(,PASS),                                00009000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  00009100
//C1INIT04 DD DSN=&&LNKXLST,DISP=(,PASS),                               00009200
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=133                  00009300
//C1INIT05 DD DSN=&&BLDLNK,DISP=(,PASS),                                00009400
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=121                  00009500
//C1INIT06 DD   DSN=&&BLDPKG,DISP=(,PASS),                              00009600
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FBA,LRECL=121                  00009700
//C1INIT07 DD   DSN=&&CHG1CPY,DISP=(,PASS),                             00009800
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FB,LRECL=80                    00009900
//C1INIT08 DD   DSN=&&CHG2CPY,DISP=(,PASS),                             00010000
//     UNIT=&TMP,SPACE=(TRK,(5,5)),RECFM=FB,LRECL=80                    00010100
//*                                                                     00010200
//*<<<                                                             >>>> 00010300
//*<<<<<<<<<<<<<<<<  1) GET SOURCE FROM ENDEVOR  >>>>>>>>>>>>>>>>>>>>>> 00010400
//*<<<                                                             >>>> 00010500
//*                                                                     00010600
//EXTSRC   EXEC PGM=CONWRITE,PARM='EXPINCL(N)',MAXRC=0                  00010700
//ELMOUT   DD   DISP=(NEW,PASS),DSN=&&ELMOUT,                           00010800
//     UNIT=&TMP,SPACE=(CYL,(1,1)),                                     00010900
//     RECFM=FB,LRECL=80,BLKSIZE=27920                                  00011000
//*                                                                     00011100
//*<<<                                                             >>>> 00011200
//*<<<<<<<<<<<<<<<<  2) GET DB2 PKG ELEMENT      >>>>>>>>>>>>>>>>>>>>>> 00011300
//*<<<                                                             >>>> 00011400
//*                                                                     00011500
//*                                                                     00011600
//*<<<                                                             >>>> 00011700
//*<<<<<<<<<<<<<<<<  3) GET LCT CARDS            >>>>>>>>>>>>>>>>>>>>>> 00011800
//*<<<                                                             >>>> 00011900
//*                                                                     00012000
//EXTRC00  IF (EXTSRC.RC = 0) THEN                                      00012100
//*                                                                     00012200
//BLDLCT   EXEC PGM=IEBGENER,MAXRC=0                                    00012300
//*                                                                     00012400
//SYSPRINT DD   SYSOUT=*                                                00012500
//SYSUT1   DD *                                                         00012600
 NAME &C1ELEMENT(R)                                                     00012700
/*                                                                      00012800
//SYSUT2   DD   DISP=(NEW,PASS),DSN=&&LCTOUT,                           00012900
//     UNIT=&TMP,SPACE=(TRK,(2,2)),RECFM=FB,LRECL=80,BLKSIZE=3200       00013000
//SYSIN    DD   DUMMY                                                   00013100
//*                                                                     00013200
//*                                                                     00013300
//*<<<                                                             >>>> 00013400
//*<<<<<<<<<<<<<<<<  5) ASSEMBLY                 >>>>>>>>>>>>>>>>>>>>>> 00013500
//*<<<                                                             >>>> 00013600
//*                                                                     00013700
//CMP IF (RC<= 4) THEN                                                  00013800
//*                                                                     00013900
//CMP      EXEC PGM=CONPARMX,MAXRC=4,                                   00014000
//     PARM=(ASMA90,'(&PRMCMPA)',$$$$DFLT,&C1PRGRP(1,4),&C1ELEMENT,    X00014100
//             '(&PRMCMPZ)','Y','N')                                    00014200
//*                                                                     00014300
//PARMSDEF DD DISP=(,DELETE),DSN=&&NULLOPT,                             00014400
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               00014500
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          00014600
//*                                                                     00014700
//EMER   IF (&C1ST = 'EMER') THEN                                       00014800
//         DD DISP=SHR,DSN=&OPTFX,MONITOR=COMPONENTS                    00014900
//         DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..OPT,MONITOR=COMPONENTS   00014910
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00014920
//EMER   ELSE                                                           00015000
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN                                00015010
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    00015020
//TESTX  ENDIF                                                          00015030
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           00015100
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00015200
//EMER   ENDIF                                                          00015210
//PARMS    DD SYSOUT=*                                                  00015300
//*                                                                     00015400
//SYSLIB   DD   DISP=(,PASS),DSN=&&NULLCPY,                             00015500
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               00015600
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          00015700
//*                                                                     00015800
//EMER   IF (&C1ST = 'EMER') THEN                                       00015900
//         DD   DISP=SHR,DSN=&CPAFX,MONITOR=COMPONENTS                  00016000
//         DD   DISP=SHR,DSN=&MACFX,MONITOR=COMPONENTS                  00016100
//         DD   DISP=SHR,DSN=&CPYFX,MONITOR=COMPONENTS                  00016200
//EMER   ELSE                                                           00016300
//CPY    IF ('&C1ST(1,4)' = 'TEST') THEN                                00016310
//         DD   DISP=SHR,DSN=&CPAXX,MONITOR=COMPONENTS                  00016320
//         DD   DISP=SHR,DSN=&MACXX,MONITOR=COMPONENTS                  00016330
//         DD   DISP=SHR,DSN=&CPYXX,MONITOR=COMPONENTS                  00016340
//CPY    ENDIF                                                          00016350
//         DD   DISP=SHR,DSN=&CPA,MONITOR=COMPONENTS,ALLOC=LMAP         00016400
//         DD   DISP=SHR,DSN=&MAC,MONITOR=COMPONENTS,ALLOC=LMAP         00016500
//         DD   DISP=SHR,DSN=&CPY,MONITOR=COMPONENTS,ALLOC=LMAP         00016600
//EMER   ENDIF                                                          00016610
//*                                                                     00016700
//         DD   DISP=SHR,DSN=&SCEEMAC,MONITOR=COMPONENTS                00016800
//         DD   DISP=SHR,DSN=&SDFHMAC,MONITOR=COMPONENTS                00016900
//         DD   DISP=SHR,DSN=&SYS1MAC,MONITOR=COMPONENTS                00017000
//         DD   DISP=SHR,DSN=&SYS1MOD,MONITOR=COMPONENTS                00017100
//         DD   DISP=SHR,DSN=&SORCMAC,MONITOR=COMPONENTS                00017200
//         DD   DISP=SHR,DSN=&CAISRC,MONITOR=COMPONENTS                 00017300
//*                                                                     00017700
//SYSIN    DD   DSN=&&ELMOUT,DISP=(OLD,DELETE),FREE=CLOSE               00017800
//*                                                                     00017900
//SYSLIN   DD   DISP=(NEW,PASS),DSN=&&OBJ,FOOTPRNT=CREATE,              00018000
//     UNIT=&TMP,SPACE=(CYL,(5,5)),                                     00018100
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   00018200
//*                                                                     00018300
//SYSPRINT DD   DISP=(SHR,PASS),DSN=&&CMPLST                            00018400
//SYSUT1   DD   UNIT=&TMP,SPACE=(CYL,(10,10))                           00018500
//CMP ENDIF                                                             00018600
//*                                                                     00018700
//*<<<                                                             >>>> 00018800
//*<<<<<<<<<<<<<<<<  7) LINK                     >>>>>>>>>>>>>>>>>>>>>> 00018900
//*<<<                                                             >>>> 00019000
//*                                                                     00019100
//LNK IF (CMP.RUN AND CMP.RC <= 4) THEN                                 00019200
//*                                                                     00019300
//LNK      EXEC PGM=CONPARMX,MAXRC=4,                                   00019400
//     PARM=(IEWL,'(&PRMLNKA)',$$$$DFLT,&C1PRGRP(1,4),&C1ELEMENT,      X00019500
//             '(&PRMLNKZ)','Y','N')                                    00019600
//*                                                                     00019700
//PARMSDEF DD   DISP=(,DELETE),DSN=&&NULLOPT,                           00019800
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               00019900
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          00020000
//*                                                                     00020100
//EMER   IF (&C1ST = 'EMER') THEN                                       00020300
//         DD DISP=SHR,DSN=&OPTFX,MONITOR=COMPONENTS                    00020400
//         DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..OPT,MONITOR=COMPONENTS   00020500
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00020600
//EMER   ELSE                                                           00020610
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN                                00020620
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    00020630
//TESTX  ENDIF                                                          00020640
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           00020650
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00020660
//EMER   ENDIF                                                          00020670
//PARMS    DD   SYSOUT=*                                                00020700
//*                                                                     00020800
//SYSLIB   DD   DSN=&&NULLLNK,DISP=(,PASS),                             00020900
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),                                   00021000
//     LRECL=0,RECFM=U,BLKSIZE=32760                                    00021100
//*                                                                     00021200
//EMER   IF (&C1ST  = 'EMER') THEN                                      00021300
//         DD DISP=SHR,DSN=&LNKFX,MONITOR=COMPONENTS                    00021400
//         DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..&#ND1NODE,               00021410
//    MONITOR=COMPONENTS                                                00021420
//EMER   ELSE                                                           00021500
//LNKL   IF ('&C1ST(1,4)' = 'TEST') THEN                                00021510
//         DD   DISP=SHR,DSN=&LNKXX,MONITOR=COMPONENTS                  00021520
//LNKL   ENDIF                                                          00021530
//         DD   DISP=SHR,DSN=&LNK,MONITOR=COMPONENTS,ALLOC=LMAP         00021600
//EMER   ENDIF                                                          00021610
//*                                                                     00021700
//         DD   DISP=SHR,DSN=&SCEELKED,MONITOR=COMPONENTS               00022200
//         DD   DISP=SHR,DSN=&SDFHLOAD,MONITOR=COMPONENTS               00022300
//         DD   DISP=SHR,DSN=&SCSQLOAD,MONITOR=COMPONENTS               00022400
//*                                                                     00022500
//SYSLIN   DD   DISP=(OLD,DELETE),DSN=&&OBJ,                            00022600
//     RECFM=FB,LRECL=80,BLKSIZE=3200,FREE=CLOSE                        00022700
//         DD   DSN=&LNKPARM(&C1PRGRP),DISP=SHR,MONITOR=COMPONENTS      00022800
//         DD   DISP=(OLD,PASS),DSN=&&LCTOUT,                           00022900
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   00023000
//*                                                                     00023100
//EMER   IF (&C1ST  = 'EMER') THEN                                      00023200
//SYSLMOD  DD   DISP=SHR,DSN=&LNKFX,                                    00023300
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00023400
//EMER   ELSE                                                           00023500
//SLMOD  IF ('&C1ST(1,4)' = 'TEST') THEN                                00023510
//SYSLMOD  DD   DISP=SHR,DSN=&LNKXX,                                    00023520
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00023530
//SLMOD  ELSE                                                           00023540
//SYSLMOD  DD   DISP=SHR,DSN=&LNK,                                      00023600
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00023700
//SLMOD  ENDIF                                                          00023800
//EMER   ENDIF                                                          00023810
//*                                                                     00023900
//SYSPRINT DD   DISP=(SHR,PASS),DSN=&&LNKLST                            00024000
//*                                                                     00024100
//*<<<                                                             >>>> 00024200
//*<<<<<<<<<<<<<<<<  7) LINK COBX CICS           >>>>>>>>>>>>>>>>>>>>>> 00024300
//*<<<                                                             >>>> 00024400
//*                                                                     00024500
//LNKX     EXEC PGM=CONPARMX,MAXRC=4,                                   00024600
//     EXECIF=('&C1PRGRP(1,4)',EQ,'ASMX'),                              00024700
//     PARM=(IEWL,'(&PRMLNKA)',$$$$DFLT,&LNKASMX,&C1ELEMENT,           X00024800
//             '(&PRMLNKZ)','Y','N')                                    00024900
//*                                                                     00025000
//PARMSDEF DD   DISP=(,DELETE),DSN=&&NULLOPT,                           00025100
//    UNIT=&TMP,SPACE=(TRK,(1,1,1),RLSE),                               00025200
//    DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920                          00025300
//*                                                                     00025400
//EMER   IF (&C1ST = 'EMER') THEN                                       00025600
//         DD DISP=SHR,DSN=&OPTFX,MONITOR=COMPONENTS                    00025700
//         DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..OPT,MONITOR=COMPONENTS   00025800
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00025900
//EMER   ELSE                                                           00025910
//TESTX  IF ('&C1ST(1,4)' = 'TEST') THEN                                00025920
//         DD DISP=SHR,DSN=&OPTXX,MONITOR=COMPONENTS                    00025930
//TESTX  ENDIF                                                          00025940
//         DD DISP=SHR,DSN=&OPT,MONITOR=COMPONENTS,ALLOC=LMAP           00025950
//         DD DISP=SHR,DSN=&OPTBASE,MONITOR=COMPONENTS                  00025960
//EMER   ENDIF                                                          00025970
//PARMS    DD   SYSOUT=*                                                00026000
//*                                                                     00026100
//SYSLIB   DD   DSN=&&NULLLNK,DISP=(,PASS),                             00026200
//     UNIT=&TMP,SPACE=(TRK,(1,1,1)),                                   00026300
//     LRECL=0,RECFM=U,BLKSIZE=32760                                    00026400
//*                                                                     00026500
//EMER   IF (&C1ST  = 'EMER') THEN                                      00026600
//         DD   DISP=SHR,DSN=&LNK2FX,MONITOR=COMPONENTS                 00026700
//         DD DISP=SHR,DSN=&HILVL..PROD.&C1SY..&#ND1NODE,               00026710
//    MONITOR=COMPONENTS                                                00026720
//EMER   ELSE                                                           00026800
//LNKL   IF ('&C1ST(1,4)' = 'TEST') THEN                                00026810
//         DD   DISP=SHR,DSN=&LNK2XX,MONITOR=COMPONENTS                 00026820
//LNKL   ENDIF                                                          00026830
//         DD   DISP=SHR,DSN=&LNK2,MONITOR=COMPONENTS,ALLOC=LMAP        00026900
//EMER   ENDIF                                                          00027000
//*                                                                     00027400
//         DD   DISP=SHR,DSN=&SCEELKED,MONITOR=COMPONENTS               00027500
//         DD   DISP=SHR,DSN=&SDFHLOAD,MONITOR=COMPONENTS               00027600
//         DD   DISP=SHR,DSN=&SCSQLOAD,MONITOR=COMPONENTS               00027700
//*                                                                     00027800
//SYSLIN   DD   DISP=(OLD,DELETE),DSN=&&OBJ,                            00027900
//     RECFM=FB,LRECL=80,BLKSIZE=3200,FREE=CLOSE                        00028000
//         DD   DSN=&LNKPARM(&C1PRGRP),DISP=SHR,MONITOR=COMPONENTS      00028100
//         DD   DISP=(OLD,PASS),DSN=&&LCTOUT,                           00028200
//     RECFM=FB,LRECL=80,BLKSIZE=3200                                   00028300
//*                                                                     00028400
//EMER   IF (&C1ST  = 'EMER') THEN                                      00028500
//SYSLMOD  DD   DISP=SHR,DSN=&LNK2FX,                                   00028600
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00028700
//EMER   ELSE                                                           00028800
//SLMOD  IF ('&C1ST(1,4)' = 'TEST') THEN                                00028810
//SYSLMOD  DD   DISP=SHR,DSN=&LNK2XX,                                   00028820
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00028830
//SLMOD  ELSE                                                           00028840
//SYSLMOD  DD   DISP=SHR,DSN=&LNK2,                                     00028900
//     MONITOR=COMPONENTS,FOOTPRNT=CREATE                               00029000
//SLMOD  ENDIF                                                          00029100
//EMER   ENDIF                                                          00029110
//*                                                                     00029200
//SYSPRINT DD   DISP=(SHR,PASS),DSN=&&LNKLST                            00029300
//*                                                                     00029400
//*<<<                                                             >>>> 00029500
//*<<<<<<<<<<<<<<<<  8) OTHER  OUTPUT DATASETS   >>>>>>>>>>>>>>>>>>>>>> 00029600
//*<<<                                                             >>>> 00029700
//*                                                                     00029800
//*  IF SITE SYMBOLIC ND1CHGM POINTS TO VALID DSN                       00029900
//*                                                                     00030000
//LOD1CPY EXEC PGM=BSTCOPY,MAXRC=0,EXECIF=(&ND1CHGM,GE,'A')             00030100
//*                                                                     00030200
//SYSPRINT DD DSN=&&CHG1CPY,DISP=(SHR,PASS)                             00030300
//SYSUT3   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               00030400
//SYSUT4   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               00030500
//*                                                                     00030600
//EMER    IF (&C1ST  = 'EMER') THEN                                     00030700
//INLOD    DD DSN=&LNKFX,DISP=SHR                                       00030800
//EMER    ELSE                                                          00030900
//SANDBXI IF ('&C1ST(1,4)' = 'TEST') THEN                               00030910
//INLOD    DD DSN=&LNKXX,DISP=SHR                                       00030920
//SANDBXI ELSE                                                          00030930
//INLOD    DD DSN=&LNK,DISP=SHR                                         00031000
//SANDBXI ENDIF                                                         00031100
//EMER    ENDIF                                                         00031110
//*                                                                     00031200
//OTLOD    DD DSN=&ND1CHGM,DISP=SHR,MONITOR=COMPONENTS                  00031300
//*                                                                     00031400
//SYSIN    DD *                                                         00031500
    COPY OUTDD=OTLOD,INDD=INLOD                                         00031600
      S M=((&C1ELEMENT,,R))                                             00031700
//*                                                                     00031800
//*  IF SITE SYMBOLIC ND2CHGM POINTS TO VALID DSN                       00031900
//*                                                                     00032000
//LOD2CPY EXEC PGM=BSTCOPY,MAXRC=0,EXECIF=(&ND2CHGM,GE,'A')             00032100
//*                                                                     00032200
//SYSPRINT DD DSN=&&CHG2CPY,DISP=(SHR,PASS)                             00032300
//SYSUT3   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               00032400
//SYSUT4   DD UNIT=&TMP,SPACE=(CYL,(1,1))                               00032500
//*                                                                     00032600
//EMER    IF (&C1ST = 'EMER') THEN                                      00032700
//INLDX    DD DSN=&LNK2FX,DISP=SHR                                      00032800
//EMER    ELSE                                                          00032900
//SANDBXI IF ('&C1ST(1,4)' = 'TEST') THEN                               00032910
//INLDX    DD DSN=&LNK2XX,DISP=SHR                                      00032920
//SANDBXI ELSE                                                          00032930
//INLDX    DD DSN=&LNK2,DISP=SHR                                        00033000
//SANDBXI ENDIF                                                         00033100
//EMER    ENDIF                                                         00033110
//*                                                                     00033200
//OTLDX    DD DSN=&ND2CHGM,DISP=SHR,MONITOR=COMPONENTS                  00033300
//*                                                                     00033400
//SYSIN    DD *                                                         00033500
    COPY OUTDD=OTLDX,INDD=INLDX                                         00033600
      S M=((&C1ELEMENT,,R))                                             00033700
//*                                                                     00033800
//*<<<                                                             >>>> 00033900
//*<<<<<<<<<<<<<<<<  9) INVOKE CICS NEWCOPY      >>>>>>>>>>>>>>>>>>>>>> 00034000
//*<<<                                                             >>>> 00034100
//*                                                                     00034200
//CICNC IF ('&C1PRGRP(1,4)' = 'ASMO') THEN                              00034300
//*                                                                     00034400
//CICNC01 EXEC PGM=AFCP2016,PARM=SYSIN,EXECIF=(&#CICNC01,GE,'A')        00034500
//STEPLIB   DD DSN=&SD$CICS,DISP=SHR                                    00034600
//SYSPRINT  DD SYSOUT=*                                                 00034700
//SYSUDUMP  DD SYSOUT=*                                                 00034800
//CAFCTRAC  DD SYSOUT=*                                                 00034900
//SYSIN     DD *                                                        00035000
&#CICNC01,CEMT,SET PROG(&C1ELEMENT) PH                                  00035100
//*                                                                     00035200
//CICNC02 EXEC PGM=AFCP2016,PARM=SYSIN,EXECIF=(&#CICNC02,GE,'A')        00035300
//STEPLIB   DD DSN=&SD$CICS,DISP=SHR                                    00035400
//SYSPRINT  DD SYSOUT=*                                                 00035500
//SYSUDUMP  DD SYSOUT=*                                                 00035600
//CAFCTRAC  DD SYSOUT=*                                                 00035700
//SYSIN     DD *                                                        00035800
&#CICNC02,CEMT,SET PROG(&C1ELEMENT) PH                                  00035900
//*                                                                     00036000
//CICNC ENDIF                                                           00036100
//LNK ENDIF                                                             00036200
//EXTRC00  ENDIF                                                        00036300
//*                                                                     00036400
//*<<<                                                             >>>> 00036500
//*<<<<<<<<<<<<<<<<  9) SAVE LISTING             >>>>>>>>>>>>>>>>>>>>>> 00036600
//*<<<                                                             >>>> 00036700
//*                                                                     00036800
//SAVLST   EXEC PGM=CONLIST,PARM='STORE.MBR(&C1ELEMENT.#&LSTSFX)',      00036900
//      COND=EVEN,MAXRC=0                                               00037000
//C1BANNER DD DISP=(NEW,DELETE),UNIT=&TMP,SPACE=(TRK,(1,1)),            00037100
//     RECFM=FBA,LRECL=121,BLKSIZE=27951                                00037200
//*                                                                     00037300
//LLIBO  IF ('&C1ST(1,4)' = 'TEST') THEN                                00037400
//C1LLIBO  DD  DISP=SHR,DSN=&OLLIBXX,MONITOR=COMPONENTS                 00037500
//LLIBO  ELSE                                                           00037600
//C1LLIBO  DD  DISP=SHR,DSN=&OLLIB,MONITOR=COMPONENTS                   00037700
//LLIBO  ENDIF                                                          00037800
//*                                                                     00037900
//LIST01   DD *                                                         00038000
  ##########  ELEMENT INVENTORY LOCATION #######                        00038100
  &C1ST/&C1SY/&C1SU/&C1TY/&C1ELEMENT      PROCESSOR GROUP: &C1PRGRP     00038200
// IF (CMP.RUN) THEN                                                    00038300
//LIST02   DD *                                                         00038400
  ##########  COMPILE  ##########                                       00038500
//LIST03   DD DSN=&&CMPLST,DISP=(OLD,PASS)                              00038600
// ENDIF                                                                00038700
// IF (LNK.RUN) THEN                                                    00038800
//LIST04   DD *                                                         00038900
  ##########  LINK EDIT  ##########                                     00039000
//LIST05   DD DSN=&&LNKLST,DISP=(OLD,PASS)                              00039100
// ENDIF                                                                00039200
// IF (LNKX.RUN) THEN                                                   00039300
//LIST06   DD *                                                         00039400
  ##########  LINK EDIT  ##########                                     00039500
//LIST07   DD DSN=&&LNKXLST,DISP=(OLD,PASS)                             00039600
// ENDIF                                                                00039700
//LIST08   DD DSN=&&BLDLNK,DISP=(OLD,PASS)                              00039800
//LIST09   DD DSN=&&CHG1CPY,DISP=(OLD,PASS)                             00039900
//LIST10   DD DSN=&&CHG2CPY,DISP=(OLD,PASS)                             00040000
//*                                                                     00040100
//*<<<                                                             >>>> 00040200
//*<<<<<<<<<<<<<<<< 10) PRINT LISTING            >>>>>>>>>>>>>>>>>>>>>> 00040300
//*<<<                                                             >>>> 00040400
//*                                                                     00040500
//PRTLST   EXEC PGM=CONLIST,PARM=PRINT,COND=EVEN,MAXRC=0                00040600
//C1PRINT  DD SYSOUT=&PRTOUT,                                           00040700
//     RECFM=FBA,LRECL=133,BLKSIZE=27930                                00040800
//C1BANNER DD DISP=(NEW,DELETE),UNIT=&TMP,SPACE=(TRK,(1,1)),            00040900
//     RECFM=FBA,LRECL=121,BLKSIZE=27951                                00041000
//LIST01   DD *                                                         00041100
  ##########  ELEMENT INVENTORY LOCATION #######                        00041200
  &C1ST/&C1SY/&C1SU/&C1TY/&C1ELEMENT      PROCESSOR GROUP: &C1PRGRP     00041300
// IF (CMP.RUN AND CMP.RC > 4) THEN                                     00041400
//LIST02   DD *                                                         00041500
  ##########  COMPILE  ##########                                       00041600
//LIST03   DD DSN=&&CMPLST,DISP=(OLD,DELETE),FREE=CLOSE                 00041700
// ENDIF                                                                00041800
// IF (LNK.RUN) THEN                                                    00041900
//LIST04   DD *                                                         00042000
  ##########  LINK EDIT &C1PRGRP ##########                             00042100
//LIST05   DD DSN=&&LNKLST,DISP=(OLD,DELETE),FREE=CLOSE                 00042200
// ENDIF                                                                00042300
// IF (LNK.RUN) THEN                                                    00042400
//LIST06   DD *                                                         00042500
  ##########  LINK EDIT ASMX     ##########                             00042600
//LIST07   DD DSN=&&LNKXLST,DISP=(OLD,DELETE),FREE=CLOSE                00042700
// ENDIF                                                                00042800
//LIST08   DD DSN=&&BLDLNK,DISP=(OLD,DELETE),FREE=CLOSE                 00042900
//LIST09   DD DSN=&&CHG1CPY,DISP=(OLD,DELETE),FREE=CLOSE                00043000
//LIST10   DD DSN=&&CHG2CPY,DISP=(OLD,DELETE),FREE=CLOSE                00043100
