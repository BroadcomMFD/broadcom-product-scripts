//*********************************************************************
//GUSS     PROC AAA=,                     first variable
//   USSPATH='/u/users/Endevor/&C1ENVMNT',
//   EXTSION='java',
//   ZZZZZZZ=
//**********************************************************************00040000
//CONW1 EXEC PGM=CONWRITE,MAXRC=0                                       00050000
//ELMOUT1 DD PATH='&USSPATH',                                           00060000
// PATHOPTS=(OWRONLY,OCREAT),                                           00070000
// PATHMODE=(SIRWXU,SIRWXG,SIRWXO)                                      00080000
//CONWIN DD *                                                           00090000
WRITE ELEMENT &C1ELMNT255                                               00100000
   FROM ENV &C1EN SYSTEM &C1SY SUBSYSTEM &C1SU                          00110000
   TYPE &C1TY STAGE &C1SI                                               00120000
TO DDN ELMOUT1                                                          00130000
HFSFILE &C1ELMNT255..tmp                                                00140000
.                                                                       00150000
//**********************************************************************00160000
//ENUSS1 EXEC PGM=ENUSSUTL,MAXRC=4,COND=(4,LT)                          00170000
//INPUT DD PATH='&USSPATH'                                              00190000
//OUTPUT DD PATH='&USSPATH',                                            00200000
// PATHMODE=(SIRWXU,SIRWXG,SIRWXO)                                      00210000
//ENUSSIN DD *                                                          00220000
 COPY INDD 'INPUT' OUTDD 'OUTPUT' .                                     00230000
 SELECT FILE '&C1ELMNT255..tmp'                                         00240000
   NEWF '&C1ELMNT255..&EXTSION'                                         00250000
 .                                                                      00260000
//**********************************************************************00270000
//BPXB1 EXEC PGM=BPXBATCH,MAXRC=0,COND=(4,LT),                          00280000
//   PARM='SH rm -r &USSPATH./&C1ELMNT255..tmp'                         00290000
//STDOUT DD SYSOUT=*                                                    00310000
//STDERR DD SYSOUT=*                                                    00320000
//*                                                                     00330000
//*********************************************************************
//* Prepare FTP   statements for a Remote Shipment from USS to USS
//*********************************************************************
//RM#FTPS  EXEC PGM=IEBGENER,
//         EXECIF=(&C1STAGE,EQ,PRD2)
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD *
 Put &C1ELMNT255..&EXTSION
//SYSUT2   DD DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.SHIP.FTPS(&C1ELEMENT),
//            DISP=SHR,MONITOR=COMPONENTS
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//**********************************************************************00340000
