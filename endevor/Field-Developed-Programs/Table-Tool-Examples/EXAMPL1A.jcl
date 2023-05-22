//EXAMPL1A JOB (55800000),'ENDEVOR JOB',MSGLEVEL=(1,1),                 JOB0
//         CLASS=B,REGION=0M,MSGCLASS=A,NOTIFY=&SYSUID
//*--------------------------------------------------------------------*
//*- Report Elements in DEV signed out to one userid
//*--------------------------------------------------------------------*
// JCLLIB  ORDER=(SYSDE32.NDVR.TEAM.JCL)
//RUNCSV   EXEC PGM=NDVRC1,REGION=4M,
//         PARM='BC1PCSV0'
//   INCLUDE MEMBER=STEPLIB
//BSTIPT01 DD *
LIST ELEMENT '*'
     FROM ENVIRONMENT PRD SYSTEM '*' SUBSYSTEM '*'
          TYPE  '*' STAGE NUMBER 2
     DATA ALL   TO DDNAME 'CSVOUTPT'
     OPTIONS NOSEARCH.
//C1MSGS1  DD SYSOUT=*
//BSTERR   DD SYSOUT=*
//CSVOUTPT DD DSN=&&CSVFILE,
//      DCB=(RECFM=FB,LRECL=800,BLKSIZE=8000,DSORG=PS),
//      DISP=(MOD,PASS),UNIT=3390,
//      SPACE=(CYL,(5,5),RLSE)
//*-Report -----------------------------------------------------------
//REPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 A'
//OPTIONS  DD *
  $Table_Type = "CSV"
  If ELM_LAST_LL_USRID /= 'NSIMEON'  then $SkipRow = 'Y'
//MODEL    DD  *
 &ELM_LAST_LL_USRID (ELM_LAST_LL_USRID)  Element = &ELM_NAME
   System/Subsys/Type = &SYS_NAME/&SBS_NAME/&TYPE_NAME/
     ELM_LAST_LL_DATE=&ELM_LAST_LL_DATE @ &ELM_LAST_LL_TIME
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)
//SYSTSPRT DD SYSOUT=*
//SYSEXEC  DD DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQCLS0
//TBLOUT    DD SYSOUT=*
