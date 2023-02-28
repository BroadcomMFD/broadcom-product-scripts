//WALJO11B JOB (0000),                                                  JOB01236
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//* Submit ACM collection in 'Group's of Inventory ranges ------------*
//*-      Modify the SET statements ----------------------------------*
//*-------------------------------------------------------------------*
//  SET HLQ=&SYSUID..ACM#BILD          Intermediate files HLQ
//  SET MODELLIB=&SYSUID..ACM#BILD.WORK       <-Where are ACM#*
//  SET CSIQCLS0=CARSMINI.NDVR.R1801.CSIQCLS0 <-Where is ENBPIU00
//*----------- example values for SELECT....
//  SET SELECT='10  '              <- Submit 10 groups
//  SET SELECT='A   '              <- Submit all groups
//  SET SELECT='M GRP10'           <- Submit only GRP10
//*-------------------------------------------------------------------*
//*  COLLECT ACMQ RELATIONSHIPS FOR NON-GENERATED ELEMENTS IN PROD
//*-------------------------------------------------------------------*
//*-  &HLQ..ACM#LOAD.COMPONTS a list of input components          ----*
//*-  &HLQ..ACM#LOAD.ELEMLIST is CSV data of component users   ----*
//*-------------------------------------------------------------------*
//*--------Set parameter --------->>>>>>>>     <<<<<<<----------------*
//BILDACM2 EXEC PGM=IRXJCL,PARM='ENBPIU00 &SELECT '        ACM#LOD2
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//MODEL    DD DISP=SHR,DSN=&MODELLIB(ACM#LOD3)
//*--Table is created by ACM#LOD1
//TABLE    DD DISP=SHR,DSN=&HLQ..ACMTABLE
//OPTIONS  DD DISP=SHR,DSN=&MODELLIB(ENV@STG)
//         DD *
  $nomessages = 'Y'
  $delimiter = '\'
  CCID = '*'
  Start010 = Left(Start,9)
  Userid = USERID() ;
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//SYSTSIN  DD DUMMY
//TBLOUTX  DD SYSOUT=*
//TBLOUT   DD SYSOUT=(A,INTRDR),LRECL=80,BLKSIZE=80
