//*--------------------------------------------------------------------
//* AUTOTEST - a processor include                         ------------
//*- Determine whether this element has an expected        ------------
//*- AutomatedTest@<C1stage> reference for testing         ------------
//*-   RC=0 means no testing found. RC=1 means yes         ------------
//*- Apply RELATE commands for element to testing JCL      ------------ 
//*--------------------------------------------------------------------
//AUTOTST1 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'        AUTOTEST
//TABLE    DD DSN=&&OPTIONE,DISP=(OLD,PASS) <- Required in processor
//PARMLIST DD *         <- List of inputs/outputs/Options
NOTHING  NOTHING  OPTIONS  0
MODELSCL TBLOUT   OPTIONS1 A
MODELREL RELATES  OPTIONS2 A
//OPTIONS  DD *         <- Set Defaults
  $Table_Type = "positions"
  $my_rc = 0    /* Assume RC=0 until proven otherwise */
  $index = 0
//POSITION DD *         <- Must parse each OPTION statement
  Option   1 80
//OPTIONS1 DD *         <- Parse each OPTION statement
* Split the option statement using "=" character
  PARSE VAR Option keyword "=" myValue
  say 'AutomatedTest@&C1STAGE..'
  go = Abbrev(keyword,'AutomatedTest@&C1STAGE..')
  If go /= 1 then $SkipRow = 'Y'
  $index = $index + 1
*
  myValue = Strip(Strip(Strip(myValue),"B",'"'))
  AutomatedTest = Strip(Strip(Strip(myValue),"B","'"))
  If WordPos('ELEMENT',AutomatedTest) = 0 then, +
     AutomatedTest = 'ELEMENT' AutomatedTest ; +
  $my_rc =1;
//MODELSCL DD *         <- Build Generate wi Copyback SCL
* AutoTest spawed for element &C1ELEMENT in:
*   Env=&C1ENVMNT Sys=&C1SY Sub=&C1SU Typ= &C1TY
 SET FROM ENVIRONMENT '&C1ENVMNT' STAGE '&C1STGID'
          SYSTEM '&C1SYSTEM' SUBSYSTEM '*'
          TYPE 'JCL'.
 SET OPTIONS COPYBACK SEARCH
          PROCESSOR GROUP = AUTOTEST
          CCID '&C1CCID'
          COMMENT '&C1COMMENT'.
 GENERATE
  &AutomatedTest .
//OPTIONS2 DD *         <- Build Relates
* Split the option statement using "=" character
  PARSE VAR Option keyword "=" myValue
  go = Abbrev(keyword,'AutomatedTest@&C1STAGE..')
  If go /= 1 then $SkipRow = 'Y'
  $index = $index + 1
*
  myValue = Strip(Strip(Strip(myValue),"B",'"'))
  AutomatedTest = Strip(Strip(Strip(myValue),"B","'"))
  If WordPos('ELEMENT',AutomatedTest) = 0 then, +
     RelateElement = Word(AutomatedTest,1) ; +
  Else, +
     RelateElement = Word(AutomatedTest,where + 1);
*
  RelateSystem = '&C1SYSTEM'
  where = Wordpos('SYSTEM',AutomatedTest)
  If where > 0 then RelateSystem = Word(AutomatedTest,where + 1);
*
  RelateSubsys = '&C1SUBSYS'
  where = Wordpos('SUBSYSTEM',AutomatedTest)
  If where > 0 then RelateSubsys = Word(AutomatedTest,where + 1);
*
  RelateType   = 'JCL'
//MODELREL DD *         <- Format for Relates  ...
RELATE ELEMENT &RelateElement
       LOCATION
       ENVIRONMENT = &C1ENVMNT
       SYSTEM      = &RelateSystem
       SUBSYSTEM   = &RelateSubsys
       TYPE        = &RelateType
       STAGE       = &C1STGID
       INPUT VALIDATE.
//NOTHING  DD DUMMY
//TBLOUT   DD  DSN=&&GENERSCL,
//             UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//RELATES  DD  DSN=&&RELATES,
//             UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//SYSTSPRT DD DUMMY
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1
//         DD DISP=SHR,DSN=&SYSEXEC2
//*-------------------------------------------------------------------
//*--- Execute JCL element for Batch Testing --------------------------*
//*--------------------------------------------------------------------*
//AUTOTST2 EXEC PGM=C1BM3000,PARM='TESTDD1,TESTAUTO',      AUTOTEST
//              COND=(1,NE,AUTOTST1)
//TESTDD1  DD  DSN=&&GENERSCL,DISP=(OLD,DELETE)
//TESTAUTO DD  SYSOUT=*
//LISTFILE DD  SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//*
//*-------------------------------------------------------------------
//*--- Execute JCL element for Batch Testing --------------------------*
//*--------------------------------------------------------------------*
//RELATES  EXEC PGM=CONRELE,                               AUTOTEST
//              COND=(1,NE,AUTOTST1),
//              EXECIF=(&C1ACTION,EQ,GENERATE)
//NDVRIPT  DD   DSN=&&RELATES,DISP=(OLD,DELETE)
//*-------------------------------------------------------------------
