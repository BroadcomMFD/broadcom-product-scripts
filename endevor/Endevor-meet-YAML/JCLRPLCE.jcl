//WALJO11T JOB (1),'ENDEVOR TEAM',REGION=0M,                            JOB05791
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*================================================================
//  EXPORT SYMLIST=(*)
//  SET MEMBER=JOBNUM44
//  SET MEMBER=WAITSECS
//*--------
//  SET OPTIONS=SYSDE32.NDVR.TEAM.REXX150
//  SET NEWJCL=SYSDE32.NDVR.TEAM.JCL
//  SET OLDJCL=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.JCL(ACM#LOD1)
//  SET OLDJCL=SYSDE32.NDVR.TEAM.JCL(ENBPIU00)
//  SET OLDJCL=SYSDE32.NDVR.TEAM.JCL(TESTJCL1)
//*--------
//  SET C1STAGE=UNITTEST
//  SET SYSTEM=FINANCE
//  SET SUBSYS=ACCTPAY
//  SET TYPE=JCL
//*----
// SET CSIQCLS0=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
// SET REXXLIB=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
// SET MYYAML=SYSDE32.NDVR.TEAM.YAML(ENBPIU00)
//*==================================================================*
//*-------------------------------------------------------------------*
//*-- Apply   YAML changes for JCL                   -----------------*
//*-------------------------------------------------------------------*
//BILDMASK EXEC PGM=IRXJCL,
//         PARM='JCLRPLCE &C1STAGE'
//OPTIONS   DD DSN=&MYYAML,DISP=SHR     (OLD,DELETE)
//*YAML2REX  DD DUMMY   <- Turn on/off Trace
//JCLRPLCE  DD DUMMY   <- Turn on/off Trace
//OLDJCL    DD DISP=SHR,DSN=&OLDJCL
//NEWJCL    DD SYSOUT=*
//SYSEXEC   DD DISP=SHR,DSN=&CSIQCLS0
//          DD DISP=SHR,DSN=&REXXLIB
//SYSTSPRT  DD SYSOUT=*
//
//
//
//OPTIONSX  DD *       <- Convert YAML to REXX
 Do yaml# =1 to HowManyYamls; +
    Parse pull yaml2rexx; +
    Interpret yaml2rexx ; +
    say       yaml2rexx ; +
 End
//MASKING   DD DSN=&&MASKING,DISP=(,PASS),      <-Output Mask
//     SPACE=(TRK,(1,1)),UNIT=SYSDA,
//     LRECL=080,RECFM=FB,BLKSIZE=0
//BPIOPOUT  DD DSN=&&BPIOPT,DISP=(,PASS),       <-DBTool cntlcard
//     SPACE=(TRK,(1,1)),UNIT=SYSDA,
//     LRECL=080,RECFM=FB,BLKSIZE=0
//SPUFIOUT  DD DSN=&&SPUFI,DISP=(,PASS),        <-SPUFI check command
//     SPACE=(TRK,(1,1)),UNIT=SYSDA,
//     DCB=(LRECL=080,RECFM=FB,BLKSIZE=0)
//*-------------------------------------------------------------------*
//*------------------------------------------------------- C1BMXFTP
//
//
//
//REPLACE1  EXEC PGM=IRXJCL,PARM='JCLRPLCE &C1STAGE'       C1BMXFTP
//OLDJCL    DD DSN=&OLDJCL(&MEMBER),
//          DISP=SHR
//NEWJCL    DD SYSOUT=*
//NEWJCLX   DD DSN=&NEWJCL(&MEMBER),
//          DISP=SHR
//*JCLRPLCE  DD DUMMY          Turn on/off Trace
//JCLRPLCE  DD DUMMY          Turn on/off Trace
//OPTIONS   DD DISP=SHR,DSN=&OPTIONS(&MEMBER)
//SYSEXEC   DD DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX,
//             DISP=SHR
//          DD DSN=CARSMINI.NDVR.R1801.CSIQCLS0,
//             DISP=SHR
//          DD DSN=SYSDE32.NDVR.TEAM.REXX,DISP=SHR
//SYSTSIN   DD DUMMY
//VARIABLE  DD *,SYMBOLS=JCLONLY
  C1ENVMNT ='UNITTEST'
  C1SYSTEM ='FINANCE'
  C1SUBSYS ='ACCTPAY'
  C1ELTYPE ='JCL'
//SYSTSPRT  DD SYSOUT=*
//SYSPRINT  DD SYSOUT=*
