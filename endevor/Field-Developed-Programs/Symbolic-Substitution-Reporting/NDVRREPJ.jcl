//IBMUSERA JOB (0000),                                                  JOB05921
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//* RESTART=RUNTEST,
//*==================================================================*
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)
//  SET TRACE=T                     T/Y/N/variable-name
//  SET TRACE=#VARB1                T/Y/N/variable-name
//*==================================================================*
//*   LIST ENTRIES OF THE ENDEVOR SITE SYMBOL   TABLE              **
//*******************************************************************
//ESYMBOLS EXEC PGM=IKJEFT01,DYNAMNBR=30,REGION=4096K
//   INCLUDE MEMBER=SYSEXEC
//STEPLIB  DD  DISP=SHR,DSN=YOURSITE.NDVR.NODES1.LOADLIB
//         DD  DISP=SHR,DSN=YOUR.NDVR.CSIQAUTU
//         DD  DISP=SHR,DSN=YOUR.NDVR.CSIQAUTH
//         DD  DISP=SHR,DSN=YOUR.NDVR.CSIQLOAD
//SYSTSIN  DD * / The name of your ESYMBOLS table
 %LOADSYMB ESYMBOLS REXX
//SYSTSPRT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//ESYMBOLS DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.WRK(ESYMBOLO)
//*
//*================================================================
//RUNTEST  EXEC PGM=IRXJCL,
//         PARM='NDVRREPT &TRACE'
//INPUT    DD *,SYMBOLS=JCLONLY
C1EN     = 'PRD'
C1ELEMEBT =  GEORGE
C1PRGRP   =  12345678
C1SI      =  P
C1ST      =  PRD
C1SY      =  FINAN
C1SU      =  SSSSS
C1TY      =  CBL
C1SSTGNUM = 2
C1SSTAGE  = TEST
C1SSTGID  = T
C1SSTG    =  TEST
C1SSTG#   =  1
C1SSUBSYS =  A110
//         DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.WRK(ESYMBOLO)
//*        DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.WRK(PSYMBOLS)
//         DD * <use stmts like these for longer variable names>
C1ENVMNT  = &C1EN.
C1STGID   = &C1SI.
C1STAGE   = &C1ST.
C1SYSTEM  = &C1SY.
C1SUBSYS  = &C1SU.
C1ELTYPE  = &C1TY.
//SYSEXEC  DD DISP=SHR,DSN=YOURSITE.NDVR.REXX
//         DD DISP=SHR,DSN=YOURSITE.YOUR.NDVR.NODES2.CLSTREXX
//         DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.REXX
//REPORT   DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.WRK(NDVRREPT)
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//*================================================================
