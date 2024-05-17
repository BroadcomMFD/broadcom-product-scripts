//********************************************************************
//MCONMOVE PROC AAA=,
//         HLQ='SYSDE32.NDVR.&C1ENVMNT..&C1SY..&C1SU.',                 00000700
//         HLQS='SYSDE32.NDVR.&C1SENVMNT..&C1SSYSTEM..&C1SSUBSYS.',     00000700
//         LISTSRC='&HLQS..LISTLIB',   SRC LISTING DSN
//         LISTTRG='&HLQ..LISTLIB',    TRG LISTING DSN
//         LOADLIB='&LOAD&C1PRGRP(1,3)', Sending lib batch
//           LOADBAT='&HLQS..LOADLIB',  Sending lib batch
//           LOADCIC='&HLQS..LOADCICS', Sending lib online
//         LOADTRG='&HLQ..LOADLIB',    TRG LOADLIB DSN
//         REXXLIB='SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX',
//         SHOWME='Y',
//         TUNIT='3390',              UNIT FOR TEMP DSNS
//         ZZZ=
//*********************************************************************
//* STEP0 Get The YAML controls for this System
//**********************************************************************
//GETYAML  EXEC PGM=CONWRITE,PARM='EXPINCL(Y)',MAXRC=0     MCONMOVE
//MYYAML   DD DSN=&&MYYAML,DISP=(,PASS),
//            SPACE=(TRK,(1,5)),UNIT=SYSDA,
//            DCB=(RECFM=FB,LRECL=180,BLKSIZE=7200)
//CONWIN   DD *
WRITE ELEMENT &C1SY
   FROM ENV &C1EN SYS &C1SY
//  IF (&C1ACTION = 'TRANSFER') THEN
//         DD *
   SUB '&C1SSUBSYS'
//  ELSE
//         DD *
   SUB '&C1SU'
//  ENDIF
//         DD *
   TYPE YAML STAGE &C1STGID
   TO   DDN MYYAML
   OPTION SEARCH .
/*
//*********************************************************************
//* STEP1 CONMOVE1: Convert YAML to REXX
//*********************************************************************
//CONMOVE1 EXEC PGM=IRXJCL,                                MCONMOVE
//         PARM='ENBPIU00 PARMLIST',MAXRC=4,COND=(4,LE)
//PARMLIST  DD *
  NOTHING   NOTHING  OPTIONS   0
  CONMOVEM  CONMOVES OPTIONS1  A
//TABLE     DD *
* Do
  *
//MYYAML    DD DSN=&&MYYAML,DISP=(OLD,DELETE)
//YAML2REX  DD DUMMY   <- Turn on/off Trace
//OPTIONS   DD *       <- Convert YAML to REXX
  FINANCE. = ''
* Convert YAML to REXX   **
 Call YAML2REX 'MYYAML'
 HowManyYamls = QUEUED();
 If HowManyYamls < 1 then, +
    Do; Say 'YAML2REX: Not finding any Rexx converted from YAML'; +
    Exit(8); +
    End;
 Say 'HowManyYamls=' HowManyYamls
 Do yaml# =1 to HowManyYamls; +
    Parse pull yaml2rexx; +
    Interpret yaml2rexx ; +
 End
//OPTIONS1  DD *
*  Now build Outputs from Rexx created from YAML
 thisDB2_Subsytem_ID = Value('&C1SY..&C1SU..DB2_Subsytem_ID')
 BatchLoad     = Value('&C1SY..&C1SU..Load_Batch')
 CICS#Load     = Value('&C1SY..&C1SU..Load_CICS')
 TargetLoad = ''
 If Substr('&C1PRGRP',1,4) = 'BATC' then TargetLoad = BatchLoad
 If Substr('&C1PRGRP',1,4) = 'CICS' then TargetLoad = CICS#Load
 If TargetLoad = '' then Exit(0)
 $my_rc = 1
//CONMOVEM  DD *
* BatchLoad     =  '&BatchLoad'
* CICS#Load     =  '&CICS#Load'
FROM DSN '&LOADLIB'
  TO DSN '&TargetLoad'
  CREATE FOOTPRINT
  DO NOT VERIFY FOOTPRINT .
//SYSEXEC   DD DISP=SHR,DSN=&REXXLIB
//SYSTSPRT  DD SYSOUT=*
//CONMOVES  DD DSN=&&CONMOVE,DISP=(,PASS),      <-Output Mask
//     SPACE=(TRK,(1,1)),UNIT=SYSDA,
//     LRECL=080,RECFM=FB,BLKSIZE=0
/*
//**------------------------------------------------------------------*
//SHOWME   EXEC PGM=IEBGENER,COND=(1,NE,CONMOVE1)          MCONMOVE
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1    DD DSN=&&CONMOVE,DISP=(OLD,PASS)
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE
//SYSIN     DD DUMMY                              CONTROL STATEMENTS
//SYSUDUMP  DD SYSOUT=*
//*********************************************************************
//* STEP2 CONMOVE2: Use CONMOVE/BSTCOPY to copy to output libs
//*********************************************************************
//CONMOVE2 EXEC PGM=CONMOVE,COND=(4,LT),MAXRC=4            MCONMOVE
//SYSPRINT DD   SYSOUT=*
//  IF (CONMOVE1.RC = 1) THEN
//CONMVIN  DD DSN=&&CONMOVE,DISP=(OLD,DELETE)
//  ELSE
//CONMVIN  DD   *
FROM DSN '&LOADLIB'
  TO DSN '&LOADTRG'
  DO NOT VERIFY FOOTPRINT .
//  ENDIF
//*********************************************************************
//* STEP8 COPYLIST: COPY THE LISTING TO THE NEXT LOCATION AND REBUILD
//*        BANNER
//*********************************************************************
//COPYLIST EXEC PGM=CONLIST,COND=EVEN,MAXRC=0,PARM=COPY    MCONMOVE
//C1LLIBI  DD DSN=&LISTSRC,
//            DISP=SHR
//C1BANNER DD DSN=&&BANNER,
//            DISP=(,PASS,DELETE),UNIT=&TUNIT,SPACE=(TRK,(1,1)),
//            DCB=(RECFM=FBA,LRECL=121,DSORG=PS)
//C1LLIBO  DD DSN=&LISTTRG,
//            DISP=SHR,MONITOR=COMPONENTS
//*
//**********************************************************************
//MOVECMP  EXEC PGM=BC1PMVCL,COND=(4,LT)                   MCONMOVE
//*
