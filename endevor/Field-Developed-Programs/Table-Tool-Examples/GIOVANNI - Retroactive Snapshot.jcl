//IBMUSERE JOB (0000),                                              JOB00133
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
//*- JCL: YOURSITE.NDVR.TEAM.JCL(GIOVANNI)          -------------------
//*- Out: YOURSITE.NDVR.TEAM.SCL(GIOVANNI)          -------------------
//*-------------------------------------------------------------------
//*   Build SCL for inventory at a specific timestamp
//*-------------------------------------------------------------------
// EXPORT SYMLIST=(*)
// SET C1ENVMNT='DEV'
// SET C1STGID='D'
// SET C1ELMMNT='*'
// SET C1SYSTEM='FINANCE'
// SET C1SUBSYS='*'
// SET C1ELTYPE='COBOL'
// SET ACTION='RETRIEVE'
// SET DATETIME='2025/03/05 12:00:00'
//*********************************************************************
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)
//*********************************************************************
//*   STEP 1 -- EXECUTE CSV UTILITY
//*-------------------------------------------------------------------
//STEP1    EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//*--
//   INCLUDE MEMBER=STEPLIB
//*--
//BSTIPT01 DD *,SYMBOLS=JCLONLY
LIST ELEMENT
'&C1ELMMNT'
     FROM ENVIRONMENT  &C1ENVMNT SYSTEM &C1SYSTEM SUBSYSTEM &C1SUBSYS
          TYPE  '&C1ELTYPE'
          STAGE '&C1STGID'
     DATA ELEMENT CHANGE LEVEL SUMMARY
     TO DDNAME 'TABLE'
     OPTIONS NOSEARCH   RETURN ALL .
//TABLE    DD DSN=&&EXTRACTM,
//      DCB=(RECFM=FB,LRECL=4000,BLKSIZE=8000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(5,5),RLSE)
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//*--------------------------------------------------------------------
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K,COND=(4,LT)
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&EXTRACTM,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*
//*--------------------------------------------------------------------
//*-- Read CSV file of Endevor Element information --------------------
//*--------------------------------------------------------------------
//BILDSCL  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST',
//         COND=(4,LT)
//   INCLUDE MEMBER=SYSEXEC
//TABLE    DD  DSN=&&EXTRACTM,DISP=(OLD,DELETE)
//PARMLIST DD *
  NOTHING  NOTHING  DEFAULTS  0
  MODEL    TBLOUT   OPTIONS   A
//DEFAULTS DD *,SYMBOLS=JCLONLY
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */
  ThreshHoldTimestamp = '&DATETIME'
  prevTimestamp = '9999/99/99 24:00:00'
  Action = '&ACTION'
//OPTIONS  DD *
  If $row# < 1 then $SkipRow = 'Y'
  entry = FULL_ELM_NAME'_'SYS_NAME'_'SBS_NAME'_'TYPE_NAME
  thisTimestamp = CHG_DATE Substr(CHG_TIME,1,8)
*
  If entry /= lastEntry | thisTimestamp > ThreshHoldTimestamp then, +
     If prevTimestamp <= ThreshHoldTimestamp then, +
        X = BuildFromMODEL(MODEL); +
*
  If entry /= lastEntry then, +
     Do; +
     If thisTimestamp > ThreshHoldTimestamp then, +
        Do; Say FULL_ELM_NAME 'is newer than' ThreshHoldTimestamp; +
        $SkipRow = 'Y'; +
        End; +
     C1element = FULL_ELM_NAME ; +
     C1System  = SYS_NAME  ; +
     C1Subsys  = SBS_NAME  ; +
     C1Eltype  = TYPE_NAME  ; +
     C1Environ = ENV_NAME ; +
     C1Stgid   = STG_ID  ; +
     prevTimestamp = thisTimestamp ; +
     LastEntry = entry; +
     End
*
  If prevTimestamp <= ThreshHoldTimestamp then, +
     Do; +
     C1vers    = CHG_VV ; +
     C1levl    = CHG_LL ; +
     prevTimestamp = thisTimestamp ; +
     End
*
  $SkipRow = 'Y'
//NOTHING  DD DUMMY
//MODEL    DD *
* Threshold: &ThreshHoldTimestamp
* Thisstamp: &prevTimestamp &C1vers &C1levl &LastEntry
* Nextstamp: &thisTimestamp &CHG_VV &CHG_LL &entry
 &Action ELEMENT '&C1element'  VERSION &C1vers  LEVEL &C1levl
     FROM ENVIRONMENT &C1Environ STAGE &C1Stgid
          SYSTEM &C1System SUBSYSTEM &C1Subsys TYPE &C1Eltype
     .
//LISTEM   DD SYSOUT=*
//TBLOUT   DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.SCL(GIOVANNI)
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//DISPLAYS DD SYSOUT=*
//NOTHING  DD DUMMY
//SYSTSIN  DD DUMMY
//*--------------------------------------------------------------------
