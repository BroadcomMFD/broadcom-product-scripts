//WALJO11T JOB (1),'ENDEVOR TEAM',REGION=0M,                            JOB05791
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*================================================================
//  EXPORT SYMLIST=(*)
//  SET MEMBER=JOBNUM44
//  SET MEMBER=WAITSECS
//*--------
//  SET OPTIONS=SYSDE32.NDVR.TEAM.REXX150
//  SET NEWJCL=SYSDE32.NDVR.TEAM.JCL
//  SET OLDJCL=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.JCL(ACM#LOD1)
//  SET OLDJCL=SYSDE32.NDVR.TEAM.JCL(ENBPIU00)
//  SET OLDJCL=SYSDE32.NDVR.TEAM.JCL(TESTJCL1)
//*--------
//  SET C1STAGE=UNITTEST
//  SET C1SYSTEM=FINANCE
//  SET C1SUBSYS=ACCTPAY
//  SET C1ELTYPE=JCL
//*----
// SET CSIQCLS0=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
// SET REXXLIB=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
// SET MYYAML=SYSDE32.NDVR.TEAM.YAML(ENBPIU00)
//*==================================================================*
//*-------------------------------------------------------------------*
//*-- Apply   YAML changes for JCL                   -----------------*
//*-------------------------------------------------------------------*
//BILDMASK EXEC PGM=IRXJCL,
//         PARM='JCLRPLCE &C1STAGE'
//OPTIONS   DD DSN=&MYYAML,DISP=SHR     (OLD,DELETE)
//VARIABLE DD *,SYMBOLS=JCLONLY         more substitution variables
* Format:        variable-name = 'value'
* A variable-name can be existing Endevor/processor/Site Symbol
*                 variable names, or or any valid (rexx) name

  C1ELEMENT    = '&C1ELEMENT'
  C1ENVMNT     = '&C1ENVMNT'
  C1SYSTEM     = '&C1SYSTEM'
  C1SUBSYS     = '&C1SUBSYS'
  C1ELTYPE     = '&C1ELTYPE'
  C1STAGE      = '&C1STAGE'
  C1STGNUM     = '&C1STGNUM'
  CSIQCLS0='&#HLQ..EMER.CSIQCLS0'
  #OCLIST###@1= '&#OREXX####@1'
  #OCLIST###@2= '&#OREXX####@2'
  MyDSNPrefix='MOTM.&C1SY..&C1SU..&C1EN(1,1)&C1S#.'
//*YAML2REX  DD DUMMY   <- Turn on/off Trace
//JCLRPLCE  DD DUMMY   <- Turn on/off Trace
//OLDJCL    DD DISP=SHR,DSN=&OLDJCL
//NEWJCL    DD SYSOUT=*
//SYSEXEC   DD DISP=SHR,DSN=&CSIQCLS0
//          DD DISP=SHR,DSN=&REXXLIB
//SYSTSPRT  DD SYSOUT=*
//
 global :
      - FindTxt   : "&JCLSYSTEM"
      - Replace   : "&C1SYSTEM"

      - FindTxt   : "&JCLSUBSYS"
      - Replace   : "&C1SUBSYS"

      - FindTxt   : "&JCLSUBSYS"
      - Replace   : "&C1SUBSYS"
