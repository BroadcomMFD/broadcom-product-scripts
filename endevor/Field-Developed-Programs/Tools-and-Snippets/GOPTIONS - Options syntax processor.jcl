//*******************************************************************
//**                                                               **
//**   OPTIONS Syntax Checker and Validator
//**                                                               **
//**   o It is recommended that the Base not be the active library **
//**   o This processor will get element source and perform        **
//**     validations on it. Syntax errors are reported to SYSPRINT.**
//**   o Only after a validation (with no errors), does the        **
//**     processor write the element to its output library.        **
//**   (this version of the processor must run in batch)           **
//*******************************************************************
//GOPTIONS PROC AAA=,
//              HLQ='&#HLQ',
//              OPTIONS=&HLQ..&C1ST..&C1SY..&C1SU..OPT,
//              SYSEXEC1=&#SYSEXEC1, <-Rexx lib named on ESYMBOLS
//              SYSEXEC2=&#SYSEXEC2, <-Rexx lib named on ESYMBOLS
//              WRKUNIT=SYSDA,
//              ZZZZZZ=
//*********************************************************************
//* READ SOURCE AND EXPAND INCLUDES
//*********************************************************************
//CONWRITE EXEC PGM=CONWRITE,MAXRC=0,
// PARM='EXPINCL(N)'
//ELMOUT   DD DSN=&&ELMOUT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10),RLSE),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
//*-------------------------------------------------------------------
//*     MQSERIES Requested in program OPTIONS ?                    **
//*-------------------------------------------------------------------
//VALIDATE EXEC PGM=IRXJCL,PARM='ROPTIONS',MAXRC=4
//* / List keywords that are valid at your site. Leave empty for all\
//VALIDOPT DD * /Can be empty. May contain mixed case keywords
  ASMA90
  Compiler
  IGYCRCTL
  IEWL
  HEWL
//USEROPTS DD DSN=&&ELMOUT,DISP=(OLD,DELETE)
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1
//         DD DISP=SHR,DSN=&SYSEXEC2
//*--------------------------------------------------------------------
//*  Copt the OPTion to the source O/P Library via CONWRITE.
//*--------------------------------------------------------------------
//CPYSOP   EXEC PGM=CONWRITE,
//            PARM='EXPINCL(N)',
//            MAXRC=0,
//            COND=(0,LT)
//ELMOUT   DD DSN=&OPTIONS,
//            DISP=SHR,
//            MONITOR=COMPONENTS
//*
