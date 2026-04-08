//IBMUSERA JOB (0000),                                                  JOB05921
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//* RESTART=RUNTEST,
//*==================================================================*
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)
//  SET TRACE=N                     T/Y/N/variable-name
//*==================================================================*
//*   If a Site Symbol table is inuse at your site, 
//*   Create a representation of the table in a format like:
//*      SYMBOLNAME="value"
//*   See the ESYMBOLR.rex member for a method for doing this.
//*   Place the results into a dataset(member) for the next step. 
//*   Something like DSN=YOURSITE.NDVR.TEAM.WRK(ESYMBOLO)
//*-----------
//*   Concatenate below it, another input containing variables from
//*   one or more processors, in the same format. 
//*//*================================================================
//RUNTEST  EXEC PGM=IRXJCL,
//         PARM='NDVRREPT &TRACE'
//INPUT    DD *    < "seed" C1 variables here (only ones necessary)
C1PRGRP   =  G2345678
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
//         DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.WRK(PSYMBOLS)
//         DD * <use stmts like these for longer variable names>
C1ENVMNT  = &C1EN.
C1STGID   = &C1SI.
C1STAGE   = &C1ST.
C1SYSTEM  = &C1SY.
C1SUBSYS  = &C1SU.
C1ELTYPE  = &C1TY.
//SYSEXEC  DD DISP=SHR,DSN=YOURSITE.NDVR.REXX
//REPORT   DD SYSOUT=* 
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//*================================================================
