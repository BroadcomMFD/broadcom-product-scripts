//WALJO11G JOB (301000000),'EXAMPLEG',CLASS=B,PRTY=6,
//  MSGCLASS=3,REGION=0M,NOTIFY=&SYSUID
/*JOBPARM  SYSAFF=*
//*-------------------------------------------------------------------
//*- Build a report showing a count of each processor group referenced
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL)
//  EXPORT SYMLIST=(*)
//*********************************************************************
//  SET ENVIRON=DEV
//  SET SYSTEM='FINANCE'
//*-------------------------------------------------------------------
//*   Report processor usage counts
//*--------------------------------------------------------------------
//*-------------------------------------------------------------------
//*   STEP 1 -- EXECUTE CSV UTILITY to collect processor group info
//*-------------------------------------------------------------------
//STEP1   EXEC PGM=NDVRC1,
//         PARM='BC1PCSV0'
//*--
//   INCLUDE MEMBER=STEPLIB
//*--
//BSTIPT01 DD *,SYMBOLS=JCLONLY
  LIST ELEMENT '*'
     FROM ENVIRONMENT '&ENVIRON' SYSTEM  '&SYSTEM'
          SUBSYSTEM '*'  TYPE  '*'   STAGE NUMBER '*'
     TO DDNAME 'LISTELMS'
     OPTIONS  NOSEARCH   RETURN ALL  .
//LISTELMS DD DSN=&&LISTELMS,
//      DCB=(RECFM=VB,LRECL=4092,BLKSIZE=4096,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(TRK,(5,5),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&LISTELMS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*------ Count  Processor Group usage
//*--------------------------------------------------------------------
//STEP2   EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//TABLE    DD  DSN=&&LISTELMS,DISP=(OLD,DELETE)
//PARMLIST DD *
  NOTHING   NOTHING   OPTIONS0 0
  NOTHING   NOTHING   OPTIONS2 A
  MODEL     TBLOUT    OPTIONS3 1
//OPTIONS0 DD *                                   CONTROL STATEMENTS
 PGrpCount.       = 0
 indexCount       = 0
 ListIndexes = ''
//OPTIONS2 DD *                                   CONTROL STATEMENTS
* PROC_NAME &ENV_NAME &STG_ID &SYS_NAME &TYPE_NAME &PROC_GRP_NAME
 $nomessages = 'Y'  ;         /* Bypass messages Y/N        */
 PROC_GRP_NAME = Translate(PROC_GRP_NAME,'#','*')
 index = ENV_NAME'.'STG_ID'.'SYS_NAME'.'TYPE_NAME'.'PROC_GRP_NAME
 PGrpCount.index  = PGrpCount.index + 1
 if Wordpos(index,ListIndexes)= 0 then ListIndexes= index ListIndexes
//OPTIONS3 DD *                                   CONTROL STATEMENTS
  Say 'At OPTIONS3 ListIndexes =' Substr(ListIndexes,1,60)
  Say 'At OPTIONS3 ListIndexes =' Words(ListIndexes)
  Do i# = 1 to Words(ListIndexes) ; +
     index = Word(ListIndexes,i#); +
     indexCount = PGrpCount.index ; +
     x = BuildFromModel(MODEL) ; +
  End
  $SkipRow = 'Y'
//NOTHING  DD DUMMY
//MODEL    DD *
 PGrpCount.&index = &indexCount
//NOTHING  DD DUMMY                               CONTROL STATEMENTS
//SYSTSPRT DD SYSOUT=*
//   INCLUDE MEMBER=CSIQCLS0
//TBLOUT   DD  DSN=&&COUNTS,DISP=(NEW,PASS),
//             UNIT=SYSALLDA,SPACE=(CYL,(5,5),RLSE),
//             DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PS)
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&COUNTS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*   STEP 3 -- EXECUTE CSV UTILITY to collect processor group info
//*--------------------------------------------------------------------
//STEP3   EXEC PGM=NDVRC1,
//         PARM='BC1PCSV0'
//*--
//   INCLUDE MEMBER=STEPLIB
//*--
//BSTIPT01 DD *,SYMBOLS=JCLONLY
    LIST PROCESSOR GROUP '*'
     FROM ENVIRONMENT '&ENVIRON' SYSTEM  '&SYSTEM'
           TYPE '*'
         OPTIONS NOSEARCH RETURN ALL TO FILE CSVEXTR  .
//CSVEXTR  DD DSN=&&CSVFILE,
//      DCB=(RECFM=VB,LRECL=4092,BLKSIZE=4096,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(TRK,(5,5),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*------ Analyze Processor Group CSV data
//*--------------------------------------------------------------------
//REPORT  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)
//PARMLIST DD *
  NOTHING   NOTHING   OPTIONS0 0
  NOTHING   NOTHING   COUNTS   0
  MODEL     REPORT    OPTIONS2 A
//OPTIONS0 DD *
  PGrpCount.   = 0
//COUNTS   DD  DSN=&&COUNTS,DISP=(OLD,DELETE)
//OPTIONS2 DD *                                   CONTROL STATEMENTS
* PROC_NAME &ENV_NAME &STG_ID &SYS_NAME &TYPE_NAME &PROC_GRP_NAME
 $nomessages = 'Y'            /* Bypass messages Y/N        */
 If PROC_TYPE /= 'GEN' then $SkipRow = 'Y'
 PROC_GRP_NAME = Translate(PROC_GRP_NAME,'#','*')
 index = ENV_NAME'.'STG_ID'.'SYS_NAME'.'TYPE_NAME'.'PROC_GRP_NAME
 thisCount = PGrpCount.index
 tmp = Translate(index,' ','.')
 Env = Left(Word(tmp,1),8)
 Stg = Left(Word(tmp,2),1)
 Sys = Left(Word(tmp,3),8)
 Typ = Left(Word(tmp,4),8)
 Grp = Left(Word(tmp,5),8)
 PROC_NAME = Left(PROC_NAME,8)
//MODEL    DD *
 &PROC_NAME &Env &Stg &Sys &Typ &Grp &thisCount
//NOTHING  DD DUMMY                               CONTROL STATEMENTS
//SYSTSPRT DD SYSOUT=*
//   INCLUDE MEMBER=CSIQCLS0
//REPORT   DD SYSOUT=*
