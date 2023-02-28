//*****************************************************************
//**  GJCLTEST New JCLCHECK processor tailored from              **
//**           JCLGNNNN and JCLGCA7                              **
//**  04/04/2020 JCL Original processor.                         **
//**        Uses the processor Group name rather than the        **
//**             JCKOPT symbolic override.                       **
//**        Uses Site symbol references and ALLOC=LMAP to        **
//**             designate library names                         **
//**                                                             **
//*****************************************************************
//*--------------------------------------------------------------------*
//JCHKNDVR PROC AAAAAA=,
//    CNTLCRDS=&HLQ01.&C1ENVMNT..&C1STAGE..PARMLIB.APP,
//    ETYP='&C1PRGRP(4,1)',      T/Q        4'th char of processor grp
//    EUID='&C1ELEMENT(1,5)',                         ELEMENT USERID
//    EXPINC=N,                             EXPAND INCLUDES
//    HLQ01='ENDPCPB.N.',                             ENDEVOR CENTRAL
//    JCL#OPT1=' CC(5)  CT    SP(RPT 65 NOALL)    ',
//    JCL#OPT2=' V PROC(SYSPROC) XREF PXREF       ',
//    JCL#OPT3=' F SX RP ER( END) PROCXREF        ',
//    JCL#OPT4=' SYN RUNT  J                      ',
//    JCL#OPT5=' NOAUD NOAUTOP NOJCLLIB           ',
//    JCL#OPT6=' NOPDS UPDTDD(XREFUPDT)           ',
//    LASTNODE=&LASTND@&ETYP,               Last node for datasets
//      LASTND@T='CA7QTST',                      for prgrp ending T
//      LASTND@Q='CA7QQA',                       for prgrp ending Q
//    OUTLIB='SYSDE32.NDVR.&&C1ENVMNT.&&C1SYSTEM.&&C1SU.&LASTNODE',
//    PRCLIB='SYSDE32.NDVR.&&C1ENVMNT.&&C1SYSTEM.&&C1SU.PROC',
//    LSTLIB='SYSDE32.NDVR.&&C1ENVMNT.&&C1SYSTEM.&&C1SU.LISTLIB',
//    PRDLIB='',        PNCPPPB.SUBLIB..&LASTNODE
//    SHOWME='Y',       Show diagnostics & intermediate results Y/N
//    QAST='QAST',
//    SYSEXEC='SYSSHR.JCLCHECK.R1200A.CAZ2CLS0',
//    ZZZZZZZ=                              the end
//*
//*--------------------------------------------------------------------*
//* COPY SOURCE TO ENDEVOR LIBRARY                                     *
//*--------------------------------------------------------------------*
//WRITEEND EXEC PGM=CONWRITE,          < Save JCL into a PDS
//         PARM='EXPINCL(&EXPINC)',
//             COND=(0,LT),MAXRC=0
//ELMOUT    DD DSN=&OUTLIB(&C1ELEMENT),
//             DISP=SHR,MONITOR=COMPONENTS
//*
//*--------------------------------------------------------------------*
//* ALLOCATE LISTING DATASETS                                          *
//*--------------------------------------------------------------------*
//ALLOCLST EXEC PGM=BC1PDSIN,          < Allocate outputs
//              MAXRC=0
//C1INIT01  DD DSN=&&LIST01,DISP=(,PASS),
//             UNIT=3390,SPACE=(TRK,(1,5)),
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=13300,DSORG=PS)
//*--------------------------------------------------------------------*
//* CA JCLCHECK                                                        *
//*--------------------------------------------------------------------*
//JCLCHECK EXEC PGM=JCLCHECK,          < Run JCLCheck to validate JCL
//          PARM=('O(JCKOPTS),PDS,INC(&C1ELEMENT)'),
//             ALTID=N,
//             COND=(0,LT),MAXRC=4
//SYSEXEC   DD DISP=SHR,DSN=&SYSEXEC                   REXX PROGRAM
//SYSTSPRT  DD SYSOUT=*                                REXX MESSAGES
//*
//SYSPRINT  DD DSN=&&LIST01,DISP=(OLD,PASS)
//*YSPRINT  DD SYSOUT=*                                REPORTS
//*
//*            **** JCLCHECK TABLE ****
//*
//*
//*            **** JCLCHECK PROC LIBRARIES  ****
//*
//SYSPROC   DD DISP=(,DELETE),DSN=&&SYSPROC,
//             SPACE=(TRK,(1,1,1),RLSE),UNIT=SYSDA,
//             DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=27920
//          DD DISP=SHR,DSN=&PRCLIB,
//             ALLOC=(LMAP,COND),MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=SYSP.PROCLIB,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=PNCPPPB.PROCLIB,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=PNCLLPB.PROCLIB.REMOTE,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=PNCFFPB.PROCLIB,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=SYS1.PRODUSER,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=PNCPPTB.PROCLIB,
//             ALLOC=COND,MONITOR=COMPONENTS
//          DD DISP=SHR,DSN=PNCLLTB.PROCLIB,
//             ALLOC=COND,MONITOR=COMPONENTS
//*            **** CONTROL CARDS LIBRARIES  ****
//*
//*CNTLCRDS DD DISP=SHR,DSN=&CNTLCRDS,
//*            ALLOC=(LMAP,COND),MONITOR=COMPONENTS
//*         DD DISP=SHR,DSN=&HLQ01.PRD.PROD.PARMLIB
//*
//SYSIN     DD DSN=&OUTLIB(&C1ELEMENT),           INPUT JCL
//             DISP=SHR
//JCLOPTS   DD  *
&JCL#OPT1
&JCL#OPT2
&JCL#OPT3
&JCL#OPT4
&JCL#OPT5
&JCL#OPT6
//*
//XREFUPDT DD  DSN=&&XREFUPDT,DISP=(,PASS),
//             DCB=(LRECL=1024,RECFM=FB,BLKSIZE=27648),
//             UNIT=3390,SPACE=(CYL,(1,5))
//*
//*--------------------------------------------------------------------
//SHOWME1 EXEC PGM=IEBGENER,           < Show results
//        EXECIF=(&SHOWME,EQ,'Y')
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD DSN=&&XREFUPDT,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------*
//* Create Endevor RELATE statements from JCLCHECK's XREFUPDT output   *
//*--------------------------------------------------------------------*
//RELATES1 EXEC PGM=IRXJCL,            <-Create Relate stmts
//         PARM='ENBPIU00 A'
//TABLE    DD DSN=&&XREFUPDT,DISP=(OLD,PASS)
//POSITION DD DISP=SHR,DSN=SYSDE32.NDVR.TEAM.PARM(JCLCKXRF)
//OPTIONS  DD  *
*XRF_DSN_MEM XRF_DSN_NAME XRF_DSN_JOBSTEP XRF_DSN_DDNAME XRF_DSN_PGM
  $Table_Type = "positions"
  If $row# < 1 then $SkipRow = 'Y'
  If XRF_TYPE  = 'DSN' & Substr(XRF_DSN_NAME,1,1) = '50'x then, +
     $SkipRow = 'Y'
  If XRF_TYPE /= 'DSN' & XRF_TYPE /= 'PGM' then $SkipRow = 'Y'
  $my_rc = 1
  If XRF_TYPE  = 'PGM' then, +
     Do; +
     XRF_PROC_PROCLIB = Strip(XRF_PROC_PROCLIB) ; +
     XRF_PROC_PROCLIB = Translate(XRF_PROC_PROCLIB,'*','7D'x); +
     XRF_PROC_PROCLIB = Translate(XRF_PROC_PROCLIB,'*',' '); +
     entry = XRF_PROC_PROCLIB'('|| Strip(XRF_DSN_MEM) ||')'; +
     entry = Translate(entry,'_',' ') ; +
     If Wordpos(entry,AlreadyDone) = 0 then, +
        Do; +
        x= BuildFromMODEL(MODELPGM); +
        AlreadyDone = AlreadyDone entry; +
        End; +
     $SkipRow = 'Y'; +
     End
*
  MODEL = 'MODELDSN'
  DSNInfo = XRF_DSN_NAME
  If XRF_DSN_MEM > ' ' then, +
     DSNInfo = DSNInfo'('XRF_DSN_MEM')'
*
  DSNInfo = DSNInfo '@stp:'XRF_DSN_JOBSTEP' ddn:'XRF_DSN_DDNAME
  entry = Translate(DSNInfo,'_',' ')
  If Wordpos(entry,AlreadyDone) > 0 then $SkipRow = 'Y'
  AlreadyDone = AlreadyDone entry
//MODELDSN DD *
  RELATE OBJECT
  '&DSNInfo'.
//MODELPGM DD *
  RELATE MEMBER &XRF_DSN_MEM
      DATASET = '&XRF_PROC_PROCLIB'
      INPUT.
//SYSEXEC  DD DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQCLS0
//SYSTSPRT DD SYSOUT=*                                REXX MESSAGES
//TBLOUT    DD DSN=&&RELATES,DISP=(,PASS),
//             UNIT=3390,SPACE=(TRK,(1,1)),
//             DCB=(RECFM=FBA,LRECL=080,BLKSIZE=8000,DSORG=PS)
//*--------------------------------------------------------------------
//SHOWME2 EXEC PGM=IEBGENER,           < Show RELATES
//        COND=(1,NE,RELATES1),
//        EXECIF=(&SHOWME,EQ,'Y')
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD DSN=&&RELATES,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
//*--------------------------------------------------------------------*
//* Process Relates into Endevor                                       *
//*--------------------------------------------------------------------*
//RELATES2 EXEC  PGM=CONRELE,          < Endevor RELATES
//         COND=(1,NE,RELATES1)
//NDVRIPT  DD DSN=&&RELATES,DISP=(OLD,DELETE)
//*--------------------------------------------------------------------*
//* PRINT OUTPUT LISTING                                               *
//*--------------------------------------------------------------------*
//PRINTLST EXEC PGM=CONLIST,           < Handle Listings
//         PARM='PRINT',
//         COND=EVEN,MAXRC=0
//C1BANNER  DD DSN=&&BANNER,DISP=(,PASS,DELETE),
//             UNIT=SYSDA,SPACE=(TRK,(1,1)),
//             DCB=(RECFM=FBA,LRECL=121,BLKSIZE=6171,DSORG=PS)
//C1PRINT   DD SYSOUT=*,
//             DCB=(RECFM=FBA,LRECL=133,BLKSIZE=27930,DSORG=PS)
//LIST01    DD DSN=&&LIST01,DISP=(OLD,PASS)
//*
//*--------------------------------------------------------------------
//*  Store this listing.
//*--------------------------------------------------------------------
//STORELST EXEC PGM=CONLIST,
//            PARM='STORE',
//            MAXRC=0,
//            COND=EVEN
//C1BANNER DD UNIT=VIO,
//            SPACE=(TRK,(1,1),RLSE),
//            RECFM=FBA,LRECL=121
//C1LLIBO  DD DSN=&LSTLIB,
//            DISP=SHR,
//            MONITOR=COMPONENTS
//LIST01    DD DSN=&&LIST01,DISP=(OLD,DELETE)
