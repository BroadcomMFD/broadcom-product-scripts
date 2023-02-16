//WALJO11E JOB (0000),                                                  JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//* Create new Dynamic Environment(s) from an existing Environment
//* Use the table in the first step for new Environment(s)
//*--
//*   JCL: PSP.ENDV.TEAM.JCL(DEFINENS)
//*-------------------------------------------------------------------
// JCLLIB  ORDER=(PSP.ENDV.TEAM.JCL)     <-DSN containing INCLUDE mbrs
// EXPORT SYMLIST=(*)
//*--
//    SET LIKENV=DEV01                   <-Old Env to model for NEw
//*-------------------------------------------------------------------*
//*   STEP 1 -- Collect info from the Table
//*-------------------------------------------------------------------*
//DYNENVS  EXEC PGM=IRXJCL,PARM='ENBPIU00 A' <-Process Table
//TABLE    DD *  <- List details for new Dynamic Environments
*NewEnvir NewStage1 NewStage2 Description-----------------------------
 DEV10    DEV10A    DEV10B
//TABLEX   DD *  <- List details for new Dynamic Environments
 DEV02    DEV02A    DEV02B
 DEV03    DEV03A    DEV03B
 DEV04    DEV04A    DEV04B
 DEV05    DEV05A    DEV05B
 DEV06    DEV06A    DEV06B
 DEV07    DEV07A    DEV07B
 DEV08    DEV08A    DEV08B
 DEV09    DEV09A    DEV09B
 VIN01    VIN0VA    VIN0VB    Environment for Vin
//OPTIONS  DD *,SYMBOLS=JCLONLY
  Jobchar = Substr(NewEnvir,5,1)
  LikeEnvir       = '&LIKENV'
  DefinesDSN      = '&DEFINES'
  If Description=' ' then Description='DEVELOPMENT Dynamic' NewEnvir
  Userid = USERID()
  $delimiter = '|'
//MODEL    DD DISP=SHR,DSN=PSP.ENDV.TEAM.MODELS(DEFINENS)
//   INCLUDE MEMBER=CSIQCLS0      <- where is ENBPIU00
//SYSTSPRT  DD SYSOUT=*
//TBLOUT   DD DSN=&&SUBMITS,
//      DCB=(RECFM=FB,LRECL=080,BLKSIZE=24000,DSORG=PS),
//      DISP=(MOD,PASS),
//      SPACE=(TRK,(5,5),RLSE)
//*-------------------------------------------------------------------*
//*----- Submit (or print) the job for each new Environment-----------*
//*--------------------------------------------------------------------
//SUBMIT   EXEC PGM=IEBGENER,REGION=1024K    <-Submit or print
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&SUBMITS,DISP=(OLD,DELETE)
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//SYSUT2X   DD SYSOUT=*                     / Print or Submit
//SYSUT2    DD SYSOUT=(A,INTRDR),LRECL=80
//*--------------------------------------------------------------------
