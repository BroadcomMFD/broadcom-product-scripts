//IBMUSERY JOB (0000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-Convert YAML to REXX                 -----------------------------*
//*-JCL: YOURSITE.NDVR.TEAM.JCL(YAML2REX) -----------------------------*
//*-Output:  SYSTSPRT
//*-------------------------------------------------------------------*
//  SET MEMBER=ACTP0003
//  SET MEMBER=ACTP0001
//  SET MEMBER=WAITSECS
//  SET MEMBER=JOBNUM44
//  SET MEMBER=SBOMTEST
//  SET MEMBER=TEST4Z
//*--------
//  SET YAML=YOURSITE.NDVR.TEAM.YAML
//*-------------------------------------------------------------------*
//*-- Convert YAML to REXX                           -----------------*
//*   output: YOURSITE.NDVR.TEAM.REXX150
//*-------------------------------------------------------------------*
//SAVEMBR EXEC PGM=IRXJCL,PARM='ENBPIU00 1'
//OPTIONS  DD *
   Call YAML2REX 'MYYAML'
   HowManyYamls = QUEUED();
*  Say 'HowManyYamls=' HowManyYamls
   Do yaml# =1 to HowManyYamls; +
      Parse pull yaml2rexx; Say yaml2rexx; +
   End
   Exit
//*YAML2REX DD DUMMY   <- Turn on/off REXX trace
//MYYAML   DD  DISP=SHR,DSN=&YAML(&MEMBER)
//SYSEXEC  DD  DISP=SHR,DSN=YOURSITE.NDVR.REXX
//TBLOUT   DD  SYSOUT=*
//SYSTSPRT DD  SYSOUT=*
//SYSTSIN  DD  DUMMY
//*-------------------------------------------------------------------*
