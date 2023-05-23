//EXAMPLE1 JOB (55800000),'ENDEVOR JOB',MSGLEVEL=(1,1),                 JOB0
//         CLASS=B,REGION=0M,MSGCLASS=A,NOTIFY=&SYSUID
//*--------------------------------------------------------------------*
//*- Report Elements in DEV, flagging those in parallel development
//*--------------------------------------------------------------------*
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL)
//RUNCSV   EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//   INCLUDE MEMBER=STEPLIB
//BSTIPT01 DD *,SYMBOLS=JCLONLY     <- Permits JCL variables here
LIST ELEMENT '*'
     FROM ENVIRONMENT DEV SYSTEM '*' SUBSYSTEM '*'
          TYPE  '*' STAGE NUMBER 2
     DATA BASIC TO DDNAME 'CSVOUTPT'
     OPTIONS NOSEARCH NOCSV.
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//CSVOUTPT DD DSN=&&CSVFILE,
//      DCB=(RECFM=FB,LRECL=800,BLKSIZE=8000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(5,5),RLSE)
//*****Sort data by ele, typ, sys, sub  **************************
//SORT    EXEC PGM=SORT
//SYSPRT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=&&CSVFILE,DISP=(OLD,DELETE)
//SORTOUT  DD DSN=&&CSVFILE2,
//      DCB=(RECFM=FB,LRECL=800,BLKSIZE=8000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(5,5),RLSE)
//SYSIN    DD *  / sort by ele, typ, sys, sub
 SORT FIELDS=(39,08,CH,A,49,08,CH,A,23,16,CH,A)
//*-Report -----------------------------------------------------------
//REPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//POSITION DD *
  System      23 30
  Subsys      31 38
  Element     39 46
  Type        49 56
  Userid      95 102
  Date        79 86
//OPTIONS  DD *
  $StripData = 'N'
  If $row# = 1 then x = BuildFromMODEL(HEADING)
  entry = Element Type
  flag = '   '
  if entry = lastentry then flag ='***'
  lastentry = entry
//HEADING  DD  *
         --- Elements in the DEV Environment ---
Element- Type---- Dup System-- Subsys-- --Date-- Signout
//MODEL    DD  *
&Element &Type &flag &System &Subsys &Date &Userid
//TABLE    DD  DSN=&&CSVFILE2,DISP=(OLD,DELETE)
//SYSTSPRT DD SYSOUT=*
//SYSEXEC  DD DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQCLS0
//TBLOUT    DD SYSOUT=*
