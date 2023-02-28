//WALJO11E JOB (55800000),                                              00010000
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,      00030000
//      NOTIFY=&SYSUID                                                  00040000
//*-------------------------------------------------------------------  00050000
//  SET WORKLIB=WALJO11.PARMS                                           00060000
//  SET CSIQCLS0=CAPRD.NDVR.PROD.CATSNDVR.CSIQCLS0                      00070000
//  SET NDVR#HLQ=CAPRD.NDVR.V180CA06                                    00080000
//*-------------------------------------------------------------------  00090000
//*   Report processor usage                                            00100000
//*   Outputs:                                                          00110000
//*     &WORKLIB(PRC#ENV1)    WALJO11.PARMS(PRC#ENV1)                   00120000
//*     &WORKLIB(PRC#ENV2)    WALJO11.PARMS(PRC#ENV2)                   00130000
//*     &WORKLIB(PRC#GRPS)    WALJO11.PARMS(PRC#GRPS)                   00140000
//*     &WORKLIB(PROCUSED)    WALJO11.PARMS(PROCUSED)                   00150000
//*     &WORKLIB(NOTUSED))    WALJO11.PARMS(NOTUSED))                   00160000
//*-------------------------------------------------------------------  00170000
//*   STEP 1 -- EXECUTE CSV UTILITY to Gather Environment info          00180000
//*-------------------------------------------------------------------  00190000
//STEP1   EXEC PGM=NDVRC1,REGION=4M,                                    00200000
//         PARM='BC1PCSV0'                                              00210000
//STEPLIB  DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTU            SCMM@LIB     00220000
//         DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTH            SCMM@LIB     00230000
//         DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQLOAD            SCMM@LIB     00240000
//CONLIB   DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQLOAD            SCMM@LIB     00250000
//BSTIPT01 DD *                                                         00260000
LIST ENVIRONMENT                                                        00270000
'*'                                                                     00280000
     TO DDNAME 'EXTRACTS'                                               00290000
     OPTIONS   RETURN ALL.                                              00300000
//EXTRACTS DD DSN=&&EXTRACTS,                                           00310000
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                00320000
//      DISP=(NEW,PASS),                                                00330000
//      SPACE=(TRK,(5,1),RLSE)                                          00340000
//C1MSGS1  DD SYSOUT=*                                                  00350000
//BSTERR   DD SYSOUT=*                                                  00360000
//*------                                                               00370000
//WORKLIB  DD DSN=&WORKLIB,                                             00380000
//      DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PO),                    00390000
//      DISP=(MOD,CATLG,KEEP),DSNTYPE=LIBRARY,                          00400000
//      SPACE=(TRK,(5,5),RLSE)                                          00410000
//*-------------------------------------------------------------------- 00420000
//*------ Reformat Envionments into CSV requests for Procesor Grp info- 00430000
//*-------------------------------------------------------------------- 00440000
//STEP1A  EXEC PGM=IRXJCL,PARM='ENBPIU00 A'                             00450000
//TABLE    DD  DSN=&&EXTRACTS,DISP=(OLD,DELETE)                         00460000
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                    00470000
//MODEL1   DD *                                                         00480000
    LIST PROCESSOR GROUP '*'                                            00490000
      FROM ENVIRONMENT '&ENV_NAME' STAGE '*'                            00500000
           SYSTEM '*' TYPE '*'                                          00510000
         OPTIONS NOSEARCH RETURN ALL TO FILE CSVEXTR  .                 00520000
//MODEL2   DD *                                                         00530000
LIST ELEMENT                                                            00540000
'*'                                                                     00550000
     FROM ENVIRONMENT  &ENV_NAME SYSTEM  '*' SUBSYSTEM '*'              00560000
          TYPE  'PROCESS'                                               00570000
          STAGE NUMBER '*'                                              00580000
     TO DDNAME 'LISTELMS'                                               00590000
     OPTIONS   SEARCH   RETURN FIRST PATH PHYSICAL .                    00600000
//OPTIONS  DD *                                   CONTROL STATEMENTS    00610000
  $NumberModelsAndTblouts= 2                                            00620000
//SYSTSPRT DD SYSOUT=*                                                  00630000
//TBLOUT1  DD DISP=SHR,DSN=&WORKLIB(PRC#ENV1)                           00640000
//TBLOUT2  DD DISP=SHR,DSN=&WORKLIB(PRC#ENV2)                           00650000
//*                                                                     00660000
//*-------------------------------------------------------------------  00670000
//*   STEP 2 -- EXECUTE CSV UTILITY to collect processor group info     00680000
//*-------------------------------------------------------------------  00690000
//STEP2   EXEC PGM=NDVRC1,REGION=4M,                                    00700000
//         PARM='BC1PCSV0'                                              00710000
//STEPLIB  DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTU            SCMM@LIB     00720000
//         DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTH            SCMM@LIB     00730000
//         DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQLOAD            SCMM@LIB     00740000
//CONLIB   DD  DISP=SHR,DSN=&NDVR#HLQ..CSIQLOAD            SCMM@LIB     00750000
//BSTIPT01 DD DISP=SHR,DSN=&WORKLIB(PRC#ENV1)                           00760000
//CSVEXTR  DD DSN=&&CSVFILE,                                            00770000
//      DCB=(RECFM=VB,LRECL=4092,BLKSIZE=4096,DSORG=PS),                00780000
//      DISP=(MOD,PASS),                                                00790000
//      SPACE=(TRK,(5,5),RLSE)                                          00800000
//C1MSGS1  DD SYSOUT=*                                                  00810000
//BSTERR   DD SYSOUT=*                                                  00820000
//*-------------------------------------------------------------------- 00830000
//*------ Analyze Processor Group CSV data                              00840000
//*-------------------------------------------------------------------- 00850000
//STEP2A  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                      00860000
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)                          00870000
//PARMLIST DD *                                                         00880000
  NOTHING   NOTHING   OPTIONS0 0                                        00890000
  NOTHING   NOTHING   OPTIONS1 A                                        00900000
  HEADING   TBLOUT1   NOTHING  1                                        00910000
  MODEL     TBLOUT2   OPTIONS2 A                                        00920000
  IAMUSED   PROCUSED  OPTIONS3 A                                        00930000
//HEADING  DD *                                                         00940000
*Processr Environ- S System-- Type---- PrcGrp-- ProcType                00950000
//MODEL    DD *                                                         00960000
 &PROC_NAME &ENV_NAME &STG_ID &SYS_NAME &TYPE_NAME &PROC_GRP_NAME &PROC_00970000
//OPTIONS0 DD *                                   CONTROL STATEMENTS    00980000
  Processor. = ''                                                       00990000
  ProcessorUsed. = 'N'                                                  01000000
  $nomessages = 'Y'            /* Bypass messages Y/N        */         01010000
//OPTIONS1 DD *                                   CONTROL STATEMENTS    01020000
  if PROC_NAME = '*NOPROC*' Then $SkipRow = 'Y'                         01030000
  entry= ENV_NAME SYS_NAME TYPE_NAME STG_ID PROC_TYPE PROC_GRP_NAME     01040000
  entry = Translate(entry,'_',' ')                                      01050000
  PROC_NAME = Strip(PROC_NAME) ;                                        01060000
  If Wordpos(entry,Processor.PROC_NAME) = 0 then, +                     01070000
     Processor.PROC_NAME = Processor.PROC_NAME entry ;                  01080000
  ProcessorUsed.PROC_NAME = 'Y'                                         01090000
  $SkipRow = 'Y'                                                        01100000
//IAMUSED  DD *                                   CONTROL STATEMENTS    01110000
  ProcessorUsed.&PROC_NAME = 'Y'                                        01120000
//PROCUSED DD DISP=SHR,DSN=&WORKLIB(PROCUSED)                           01130000
//NOTHING  DD DUMMY                               CONTROL STATEMENTS    01140000
//OPTIONS2 DD *                                   CONTROL STATEMENTS    01150000
  PROC_NAME = Strip(PROC_NAME) ;                                        01160000
  if PROC_NAME = '*NOPROC*' Then $SkipRow = 'Y'                         01170000
  ProcessorEntries  = Processor.PROC_NAME ;                             01180000
  Processor.PROC_NAME = '' ;                                            01190000
  If ProcessorEntries = '' then $SkipRow = 'Y'                          01200000
  PROC_NAME      = Left(PROC_NAME,8) ;                                  01210000
  Do ent# = 1 to Words(ProcessorEntries); +                             01220000
     entry= Word(ProcessorEntries,ent#) ; +                             01230000
     entry = Translate(entry,' ','_') ; +                               01240000
     ENV_NAME       = Left(Word(entry,1),8); +                          01250000
     SYS_NAME       = Left(Word(entry,2),8); +                          01260000
     TYPE_NAME      = Left(Word(entry,3),8); +                          01270000
     STG_ID         = Left(Word(entry,4),1); +                          01280000
     PROC_TYPE      = Left(Word(entry,5),8); +                          01290000
     PROC_GRP_NAME  = Left(Word(entry,6),8); +                          01300000
     x = BuildFromModel(MODEL); +                                       01310000
     Processor.PROC_NAME  = '' ;+                                       01320000
  End;                                                                  01330000
  $SkipRow = 'Y'                                                        01340000
//OPTIONS3 DD *                                   CONTROL STATEMENTS    01350000
  PROC_NAME = Strip(PROC_NAME);                                         01360000
  If PROC_NAME = '*NOPROC*' then $SkipRow = 'Y' ;                       01370000
  IsProcessorUsed = ProcessorUsed.PROC_NAME                             01380000
  If IsProcessorUsed = 'Y' then x = BuildFromModel(IAMUSED)             01390000
  ProcessorUsed.PROC_NAME = 'done'                                      01400000
  $SkipRow = 'Y'                                                        01410000
//SYSTSPRT DD SYSOUT=*                                                  01420000
//NOTHING  DD DUMMY                               CONTROL STATEMENTS    01430000
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                    01440000
//TBLOUT1  DD  DSN=&&TBLOUT1,DISP=(NEW,PASS),                           01450000
//             UNIT=SYSALLDA,SPACE=(CYL,(1,5),RLSE),                    01460000
//             DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PS)              01470000
//TBLOUT2  DD  DSN=&&TBLOUT2,DISP=(NEW,PASS),                           01480000
//             UNIT=SYSALLDA,SPACE=(CYL,(1,5),RLSE),                    01490000
//             DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PS)              01500000
//********************************************************************* 01510000
//*    SORT DATA                                                      * 01520000
//********************************************************************* 01530000
//SORT    EXEC PGM=SORT                                                 01540000
//SYSPRT   DD SYSOUT=*                                                  01550000
//SYSPRINT DD SYSOUT=*                                                  01560000
//SYSOUT   DD SYSOUT=*                                                  01570000
//SORTIN   DD DSN=&&TBLOUT2,DISP=(OLD,PASS,DELETE)                      01580000
//SORTOUT  DD DSN=&&TBLOUT2A,DISP=(NEW,PASS),                           01590000
//            UNIT=SYSALLDA,SPACE=(CYL,(1,5),RLSE),                     01600000
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PS)               01610000
//SYSIN    DD *                                                         01620000
 SORT FIELDS=(01,80,CH,A)                                               01630000
//*                                                                     01640000
//*-------------------------------------------------------------------- 01650000
//SAVEMBR EXEC PGM=IEBGENER,REGION=1024K                                01660000
//SYSPRINT DD SYSOUT=*                           MESSAGES               01670000
//SYSUT1   DD DSN=&&TBLOUT1,DISP=(OLD,PASS,DELETE)                      01680000
//         DD DSN=&&TBLOUT2A,DISP=(OLD,PASS,DELETE)                     01690000
//SYSIN    DD DUMMY                               CONTROL STATEMENTS    01700000
//SYSUDUMP DD SYSOUT=*                                                  01710000
//SYSUT2   DD DISP=SHR,DSN=&WORKLIB(PRC#GRPS)                           01720000
//*                                                                     01730000
//*-------------------------------------------------------------------- 01740000
//*------ Report UnUsed processors.                                     01750000
//*-------------------------------------------------------------------  01760000
//*   STEP 3 -- EXECUTE CSV UTILITY                                     01770000
//*-------------------------------------------------------------------  01780000
//STEP3   EXEC PGM=NDVRC1,REGION=4M,                                    01790000
//         PARM='BC1PCSV0'                                              01800000
//STEPLIB  DD DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTU                          01810000
//         DD DISP=SHR,DSN=&NDVR#HLQ..CSIQAUTH                          01820000
//         DD DISP=SHR,DSN=&NDVR#HLQ..CSIQLOAD                          01830000
//BSTIPT01 DD DISP=SHR,DSN=&WORKLIB(PRC#ENV2)                           01840000
//LISTELMS DD DSN=&&LISTELMS,                                           01850000
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                01860000
//      DISP=(MOD,PASS),                                                01870000
//      SPACE=(CYL,(5,5),RLSE)                                          01880000
//C1MSGS1  DD SYSOUT=*                                                  01890000
//BSTERR   DD SYSOUT=*                                                  01900000
//*-------------------------------------------------------------------- 01910000
//*------ Report UnUsed processors.                                     01920000
//*-------------------------------------------------------------------- 01930000
//STEP3A  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                      01940000
//TABLE    DD DSN=&&LISTELMS,DISP=(OLD,DELETE)                          01950000
//PARMLIST DD *                                                         01960000
  NOTHING   NOTHING   OPTIONS0 0                                        01970000
  HEADING   NOTUSED   PROCUSED 1                                        01980000
  MODEL     NOTUSED   OPTIONS2 A                                        01990000
//OPTIONS0 DD *                                                         02000000
  ProcessorUsed. = 'N'                                                  02010000
  $nomessages = 'Y'            /* Bypass messages Y/N        */         02020000
//PROCUSED DD DISP=SHR,DSN=&WORKLIB(PROCUSED)                           02030000
//HEADING  DD *                                                         02040000
*Element- Environ- System-- SubSystm Type---- St Msg------              02050000
//MODEL    DD *                                                         02060000
 &ELM_NAME &ENV_NAME &SYS_NAME &SBS_NAME &TYPE_NAME  &STG_ID not used   02070000
//OPTIONS2 DD *                                   CONTROL STATEMENTS    02080000
  element  = Strip(ELM_NAME)                                            02090000
  If Words(element) > 1 then $SkipRow = 'Y'                             02100000
  IsProcessorUsed = ProcessorUsed.element                               02110000
  If IsProcessorUsed /= 'N' then $SkipRow = 'Y'                         02120000
  ProcessorUsed.element  = 'done'                                       02130000
* Format outputs                                                        02140000
  ELM_NAME   = Left(ELM_NAME,8)                                         02150000
  ENV_NAME   = Left(ENV_NAME,8)                                         02160000
  SYS_NAME   = Left(SYS_NAME,8)                                         02170000
  SBS_NAME   = Left(SBS_NAME,8)                                         02180000
  TYPE_NAME  = Left(TYPE_NAME,8)                                        02190000
//SYSTSPRT DD SYSOUT=*                                                  02200000
//NOTHING  DD DUMMY                               CONTROL STATEMENTS    02210000
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                    02220000
//TBLOUT   DD SYSOUT=*                                                  02230000
//NOTUSED  DD DISP=SHR,DSN=&WORKLIB(NOTUSED)                            02240000
//*-------------------------------------------------------------------- 02250000
