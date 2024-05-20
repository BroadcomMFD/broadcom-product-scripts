//*****************************************************************
//**  GJCLTAIL Uses YAML to modify JCL for the Endevor           **
//**      Env/Stg/Sys/Sub                                        **
//*****************************************************************
//GJCLTAIL PROC AAAAAA=,
//    OUTLIB='SYSDE32.NDVR.&&C1ENVMNT.&&C1SYSTEM.&&C1SU.JCL',
//    YAMLLIB='SYSDE32.NDVR.TEAM.YAML',
//    SHOWME='Y',       Show diagnostics & intermediate results Y/N
//    SYSEXEC1='&#SYSEXEC1',
//    SYSEXEC2='&#SYSEXEC2',
//    WRKUNIT=3390,                                                     00002600
//    ZZZZZZZ=
//**********************************************************************
//* Get YAML if it exists for element RC=1, if found RC=0 not found
//*--------------------------------------------------------------------
//GETYAML  EXEC PGM=CONWRITE,PARM='EXPINCL(N)',MAXRC=4
//CONWIN   DD *
 WRITE ELEMENT '&C1ELEMENT'
   FROM ENVIRONMENT '&C1EN' SYSTEM '&C1SY' SUBSYSTEM '&C1SU'
     TYPE YAML  STAGE &C1SI
   TO DDN MYYAML
   OPTIONS SEARCH .
//MYYAML   DD DSN=&&MYYAML,DISP=(,PASS),
//            UNIT=3390,SPACE=(CYL,(1,5),RLSE),
//            DCB=(RECFM=FB,LRECL=180,BLKSIZE=0)
//*********************************************************************
//* READ JCL   element
//*********************************************************************
//CONWRITE EXEC PGM=CONWRITE,COND=(4,LT),                  GJCLTAIL
// PARM='EXPINCL(N)',MAXRC=0
//  IF (GETYAML.RC = 0) THEN
//ELMOUT   DD DSN=&&ELMOUT,DISP=(,PASS),
//            UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
//  ELSE
//ELMOUT    DD DISP=SHR,DSN=&OUTLIB(&C1ELEMENT),
//          MONITOR=COMPONENTS,FOOTPRNT=CREATE
//  ENDIF
//*-------------------------------------------------------------------*
//*-- Apply   YAML changes for JCL                   -----------------*
//*-------------------------------------------------------------------*
//TAILORIT EXEC PGM=IRXJCL,COND=(0,NE,GETYAML),            GJCLTAIL
//         PARM='JCLRPLCE &C1STAGE',MAXRC=4
//OPTIONS  DD DSN=&&MYYAML,DISP=(OLD,DELETE)
//VARIABLE DD *  List Endevor variables for more substitutions
* Format:        variable-name = "value"
* A variable-name can be existing Endevor/processor/Site Symbol
*                 variable names, or or any valid (rexx) name

  C1ELEMENT    = "&C1ELEMENT"
  C1ENVMNT     = "&C1ENVMNT"
  C1SYSTEM     = "&C1SYSTEM"
  C1SUBSYS     = "&C1SUBSYS"
  C1ELTYPE     = "&C1ELTYPE"
  C1STAGE      = "&C1STAGE"
  C1STGNUM     = "&C1STGNUM"
  #SYSEXEC1    = "&#SYSEXEC1"
  #SYSEXEC2    = "&#SYSEXEC2"
//OLDJCL    DD DSN=&&ELMOUT,DISP=(OLD,DELETE)
//NEWJCL    DD DISP=SHR,DSN=&OUTLIB(&C1ELEMENT),
//          MONITOR=COMPONENTS,FOOTPRNT=CREATE
//SYSEXEC   DD DISP=SHR,DSN=&SYSEXEC1
//          DD DISP=SHR,DSN=&SYSEXEC2
//SYSTSPRT  DD SYSOUT=*
//*-\ TAILRJCL /------------------------------------------------------*
