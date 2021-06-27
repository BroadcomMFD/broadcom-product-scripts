//*--------------------------------------------------------------------
//*- Determine whether this element has an expected        ------------
//*- AutomatedTest@<C1stage> reference for testing         ------------
//*-   RC=0 means no testing found. RC=1 means yes         ------------
//*--------------------------------------------------------------------
//AUTOTST1 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'        AUTOTEST
//TABLE    DD DSN=&&OPTIONE,DISP=(OLD,PASS) <- Required in processor
//PARMLIST DD *         <- List of inputs/outputs/Options
NOTHING  NOTHING  OPTIONS  0
MODELSCL TBLOUT   OPTIONS1 A
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
  If keyword /= 'AutomatedTest@UTC.'$index then, +
     Do; Say keyword 'is out of sequence'; Exit(12); end;
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
//NOTHING  DD DUMMY
//TBLOUT   DD  DSN=&&GENERSCL,
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
