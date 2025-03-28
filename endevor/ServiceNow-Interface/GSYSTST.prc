//*******************************************************************
//**                                                               **
//**    Run a Test4z System test - a list of Test suites
//**        The list can be in a Yaml format, or a format using
//**         <keyword> = <list of Test_Suites>
//**                                                               **
//*******************************************************************
//GSYSTST PROC AAA=,
//        CLEANUP='N',
//        PROJECT='BST.WEBUI.V190',
//        LOADLIB='&PROJECT..SMPL&C1ST..LOADLIB',
//        OPTIONST='&PROJECT..SMPL&C1ST..OPTIONST',
//        T4ZLOAD='&PROJECT..SMPL&C1ST..T4ZLOAD',
//        CSIQCLS0='BST.WEBUI.V190.CSIQCLS0',
//        USERCLS0='BST.WEBUI.V190.USERCLS0',
//        HOWMANY=M,        1-> run first found M-> run all matching
//        DATETIME='D&C1AYY&C1AMM&C1ADD..T&C1AHHMMSS.',
//* output and input
//        JCLLIB=PUBLIC.&C1ELEMENT..&DATETIME..SYSTJCL,
//        JSONLIB=PUBLIC.&C1ELEMENT..&DATETIME..SYSTJSON,
//        RESULTS=PUBLIC.&C1ELEMENT..&DATETIME..SYSTESTS,
//        SUBMIT=Y,        Submit and wait for job?  Y/N
//        WAITIMES=20,     Number of wait loops
//        WAITGAP=4,       seconds between waits
//        ZZZ=
//*-------------------------------------------------------------------*
//*- Runs a list of TEST4Z unit tests as listed in order within ------*
//*- the SYSTEST table.                                         ------*
//*-------------------------------------------------------------------*
//*-   Allocate System Test work files                            ------*
//*-------------------------------------------------------------------*
//ALLOCATE EXEC PGM=BC1PDSIN,MAXRC=0                       GSYSTST
//JCLLIB   DD DSN=&JCLLIB,
//            DISP=(MOD,CATLG,KEEP),
//            SPACE=(CYL,(1,01)),UNIT=3390,DSNTYPE=LIBRARY,
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=32000,DSORG=PO)
//RESULTS  DD DSN=&RESULTS,
//            DISP=(MOD,CATLG,KEEP),
//            SPACE=(CYL,(1,01)),UNIT=3390,
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=32000,DSORG=PS)
//*-------------------------------------------------------------------*
//*-   Build a Table of the LOADLIB concatenation             --------*
//*-   Leverage Endevor's ability to build using LMAP         --------*
//*-------------------------------------------------------------------*
//SEARCH#1 EXEC PGM=IKJEFT1B,                              GSYSTST
//         PARM='MBRSERCH LOADLIB *        0  LOADLIST'
//*                       INPUTDD MBRMASK HOWMANY OUTPUTDD'
//*                / Let Endevor build a Steplib Concatenation
//LOADLIB  DD DSN=&LOADLIB,
//            DISP=SHR,ALLOC=LMAP
//*                / Capture Steplib Concatenation here
//LOADLIST DD DSN=&&LOADLIST,
//            DISP=(NEW,PASS),SPACE=(TRK,(1,01)),UNIT=3390,
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=32000,DSORG=PS)
//*MBRSERCH DD DUMMY
//SYSTSIN  DD DUMMY
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&USERCLS0
//SYSTSPRT DD SYSOUT=*
//*-------------------------------------------------------------------*
//*-- Show intermediate results --------------------------------------*
//*-------------------------------------------------------------------*
//SHOWLISt EXEC PGM=IEBGENER,     **Show Results**         GSYSTST
//         COND=(4,LT)
//SYSPRINT DD DUMMY
//SYSUT1   DD DISP=SHR,DSN=&&LOADLIST
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//*--------------------------------------------------------------------*
//*-   Use Table of the LOADLIB concatenation                 --------*
//*-       to build a JES include member                      --------*
//*--------------------------------------------------------------------*
//SEARCH#2 EXEC PGM=IRXJCL,PARM='ENBPIU00 A',              GSYSTST
//         COND=(4,LT),MAXRC=1
//TABLE    DD DSN=&LOADLIST,DISP=(OLD,DELETE)
//         DD *
 &T4ZLOAD
//OPTIONS  DD *
  $nomessages = 'Y'            /* Bypass messages Y/N        */
  If $row# < 1 then $SkipRow = 'Y'
  TBLOUT= '@LOADLIB'
//MODEL    DD DATA,DLM=QQ
//         DD DISP=SHR,DSN=&Dataset
QQ
//*                / Creating a JES INCLUDE member here
//@LOADLIB DD DISP=SHR,DSN=&JCLLIB(@LOADLIB)
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&USERCLS0
//SYSTSPRT DD SYSOUT=*
//*-------------------------------------------------------------------*
//*-   Determine whether the element is in YAML or Options (rexx)    -*
//*-------------------------------------------------------------------*
//YAMLCHCK EXEC PGM=IRXJCL,PARM=' ',  <- x'00'             GSYSTST
//         COND=(4,LT),MAXRC=1
//OPTIONST DD DSN=&OPTIONST(&C1ELEMENT),
//            DISP=SHR
//SYSEXEC   DD *
  "EXECIO 1 DISKR OPTIONST ( FINIS"
  Pull option
  Say "GSYSTST- first line of OPTIONS....."
  Say option
  if Substr(option,1,1) = '#' then Exit(1)
  Exit
//SYSTSPRT  DD SYSOUT=*
//*-------------------------------------------------------------------*
//*-   Search the @T4ZLOAD table for each entry in the SYSTEST table.-*
//*-------------------------------------------------------------------*
//SEARCH#3 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST',       GSYSTST
//         COND=(4,LT),MAXRC=1
//TABLE    DD *   <- Build output for all &C1STAGE._Test_Suite values
*  Test_Suite
   *
//PARMLIST DD *
   JOBCARD  TBLOUT  OPTIONS0 1
// IF (YAMLCHCK.RC = 1) THEN
//         DD *     <-Yaml processing
   MODEL    TBLOUT  OPTIONS1 1
// ELSE
//         DD *     <-<keyword>="<values>"  processing
   MODEL    TBLOUT  OPTIONS2 1
// ENDIF
//OPTIONS0 DD *    <- Setup for all varieties of OPTIONS
  $nomessages = 'Y'            /* Bypass messages Y/N        */
  If $row# < 1 then $SkipRow = 'Y'
  whoAmI = USERID()
* Accounting value fetch may not be necessary at your site
  myJobAccountingCode = GETACCTC(whoAmI)
  myJobName = MVSVAR('SYMDEF',JOBNAME )
  BumpedJobname = BUMPJOB(myJobName)
* initialize variables and stem arrays
  &C1STAGE._Test_Suite = ''
  &C1STAGE._Allow_test_fails = 'N'
  Allow_test_fails = 'N'
//OPTIONS1 DD *    <- Process YAML Options
  If $row# < 1 then $SkipRow = 'Y'
  Say 'GSYSTST- Processing options as Yaml'
  Call YAML2REX 'OPTIONST'
  HowManyREXX = QUEUED();
  Say 'GSYSTST - Options are in YAML format'
  Drop Test_Suite ;
  Say "****///***Yaml converted to" HowManyREXX " REXX Stmts \\\*"
  Do yaml# =1 TO HowManyREXX; +
           Pull Yaml2Rexx; interpret Strip(Yaml2Rexx); say Yaml2Rexx; +
  End
  Say "****\\\***Yaml converted to Rexx*****************///*"
* Now process converted options for C1STAGE
  Do yaml# =1 TO HowManyREXX; +
     Drop Test_Suite ; +
     Yaml_Test_Suite = Value('&C1STAGE..Test_Suite.'yaml#); +
     if Pos('.',Yaml_Test_Suite) > 0  then Leave; +
     Test_Suite = Yaml_Test_Suite ; +
     Yaml_Allow_Fail = Value('&C1STAGE..Allow_test_fails.'yaml#); +
     If Strip(Yaml_Allow_Fail) /= 'Y' then Yaml_Allow_Fail = 'N'; +
     Allow_test_fails = Yaml_Allow_Fail; +
     say "GSYSTEST-" Test_Suite Allow_test_fails ; +
     x = BuildFromMODEL(MODEL); +
  End;
  $my_rc = 1
  $SkipRow = 'Y'
//OPTIONS2 DD *    <- Process <var> ="<value>" options
  If $row# < 1 then $SkipRow = 'Y'
  Say "GSYSTST- Processing options in <keyword>='<values>' format"
  X = IncludeQuotedOptions(OPTIONST)
*
  if Words(&C1STAGE._Test_Suite) < 1 then Exit(0)
  $my_rc = 1
  Do w# = 1 to Words(&C1STAGE._Test_Suite); +
     Test_Suite = Word(&C1STAGE._Test_Suite,w#) ; +
     If w# <= Words(&C1STAGE._Allow_test_fails) then, +
        Allow_test_fails =Word(&C1STAGE._Allow_test_fails,w#); +
     x = BuildFromMODEL(MODEL); +
  End;
  $SkipRow = 'Y'
//*                / OPTIONST element content is here
//OPTIONST DD DSN=&OPTIONST(&C1ELEMENT),
//            DISP=SHR,MONITOR=COMPONENTS
//JOBCARD  DD DATA,DLM=QQ
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',              JOB31783
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
// JCLLIB  ORDER=(&JCLLIB)
// SET JSONLIB=&JSONLIB
//*-------------------------------------------------------------------*
//ALLOCATE EXEC PGM=IEFBR14       ** Allocate JSON lib     GSYSTST
//JSONLIB  DD DSN=&JSONLIB,
//            DISP=(MOD,CATLG,KEEP),
//            SPACE=(CYL,(1,01)),UNIT=3390,DSNTYPE=LIBRARY,
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=32760,DSORG=PO)
//*-------------------------------------------------------------------*
QQ
//MODEL    DD DATA,DLM=QQ
//*--------------------------------------------------------------------*
//*     Run T4ZUNIT for Test_Suite
//***       Test_Suite = &Test_Suite
//***       Allow_test_fails = &Allow_test_fails
//*-------------------------------------------------------------------*
//*--------------------------------------------------------------------*
//&Test_Suite EXEC PGM=ZESTRUN    **Run T4Z unit Test**    GSYSTST
//STEPLIB  DD DISP=SHR,DSN=BST.T4ZPOC3.V190.T4Z.T4ZLOAD
//   INCLUDE MEMBER=@LOADLIB
//ZLOPTS   DD  *
ZESTPARM(D=&T4ZLOAD,M=&Test_Suite)
COVERAGE,DEEP
//CEEOPTS  DD *
TRAP(ON,NOSPIE)
TERMTHDACT(UADUMP)
ALL31(ON)
PROFILE(OFF)
//* Outputs \
//ZLRESULT DD DSN=&JSONLIB(&Test_Suite),
//         DISP=SHR
//ZLCOVER  DD SYSOUT=*
//ZLMSG    DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT1  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//**********************************************************************
//* Indicate a PASS or FAIL condition onto the Element
//**********************************************************************
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  GSYSTST
//         PARM=' '
//SYSEXEC  DD *
  Allow_test_fails = '&Allow_test_fails'
  CALL BPXWDYN "ALLOC FI(UNITTEST) ",
       "DA(&JSONLIB(&Test_Suite)) SHR REUSE"
  m# =0 ;
  If RESULT /= 0 then,
     Do
     m# = m# +1 ;
     Msg.m#= "Cannot find json results in",
         "&JSONLIB(&Test_Suite)";
     $my_rc =3
     End
  Else,
     Do
     $my_rc =1
     m# = m# +1
     Msg.m#= "Found UnitTest results in",
         "&JSONLIB(&Test_Suite)";
     "EXECIO * DISKR UNITTEST (Stem json. Finis"
     CALL BPXWDYN "FREE FI(UNITTEST)"
      Do j# = 1 to json.0
         jsontext = json.j#
         If pos('"testSuite":',jsontext)> 0 then,
            Do
            m# = m# +1
            Msg.m#= "UNITTEST:" jsontext ;
            End
         where = Pos('"failed":',jsontext)
         If where = 0 then iterate;
         m# = m# +1
         Msg.m#= "UNITTEST:" jsontext
         unittestRc = Word(substr(jsontext,where),2)
         If unittestRc /= "0," then Do; $my_rc =3; Leave; End
      End; /* Do j# = 1 to json.0 */
     End; /* ELSE... */

  If Allow_test_fails = 'Y' then,
     Do; Queue "The Allow_test_fails = 'Y' is set"; $my_rc =2 ; End

  if $my_rc =1 then,
     Do
     m# = m# +1
     Msg.m#= "Unit Test was successful"
     End

  if $my_rc =2 then,
     Do
     m# = m# +1
     Msg.m#= "Allow_test_fails = 'Y'"
     End

  if $my_rc =3 then,
     Do
     m# = m# +1
     Msg.m#= "Test Failed"
     End

  Msg.0 = m#
  MessageDD  = Word("SUCCESS WARNING FAILURE",$my_rc)
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "
  "EXECIO * DISKW" MessageDD "( stem Msg. Finis"
  CALL BPXWDYN "Free  DD("MessageDD")"

  "EXECIO * DISKW RESULTS ( stem Msg. Finis"

  exit($my_rc)
//SYSTSIN  DD DUMMY
//RESULTS  DD DSN=&RESULTS,
//            DISP=MOD
//SYSTSPRT DD SYSOUT=*
//*--------------------------------------------------------------------*
//**********************************************************************
QQ
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&USERCLS0
//         DD DISP=SHR,DSN=BST.ENDEVOR.DE32.REXX <where is YAML2REX
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&JCLLIB(&C1ELEMENT),
//            DISP=SHR
//*--------------------------------------------------------------------*
//*     Submit and wait for System Test job
//*--------------------------------------------------------------------*
//SUBMITRP EXEC PGM=IKJEFT1B,     **Submit System Test JCL GSYSTST
//      COND=(8,LT),
//      EXECIF=(&SUBMIT,EQ,Y),
//      PARM='SUBMITST &JCLLIB(&C1ELEMENT) &WAITIMES &WAITGAP'
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
//*--------------------------------------------------------------------*
//*     Summarize System Test Results
//*--------------------------------------------------------------------*
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  GSYSTST
//         PARM=' ',MAXRC=1
//RESULTS  DD DSN=&RESULTS,
//            DISP=SHR
//SYSEXEC  DD *
  "EXECIO * DISKR RESULTS  (STEM rslt. FINIS"
  $my_rc =2
  Do r# = 1 to rslt.0
     resultText = rslt.r#
     If $my_rc < 3 &,
        Pos('Unit Test was successful',resultText) > 0 then $my_rc =1
     If Pos('Test Failed',resultText) > 0 then $my_rc =3
  End; /* Do r# = 1 to rslt.0 */

  if $my_rc =1 then,
     Queue "System Test was successful"

  if $my_rc =2 then,
     Queue "System Test is incomplete "

  if $my_rc =3 then,
     Queue "System Test Failed"

  MessageDD  = Word("SUCCESS WARNING FAILURE",$my_rc)
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "
  "EXECIO " QUEUED() "DISKW" MessageDD "( Finis"
  CALL BPXWDYN "Free  DD("MessageDD")"

  exit($my_rc)
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//*--------------------------------------------------------------------*
//*---- Optionally Cleanup --------------------------------------------*
//*-------------------------------------------------------------------
//DELETES   EXEC PGM=IDCAMS,COND=(7,LT),                   GSYSTST
//          EXECIF=(&CLEANUP,EQ,Y)
//SYSPRINT   DD SYSOUT=*
//AMSDUMP    DD SYSOUT=*
//SYSIN    DD *
DELETE '&JCLLIB' NONVSAM
DELETE '&JSONLIB' NONVSAM
DELETE '&RESULTS' NONVSAM
SET MAXCC=0
//**********************************************************************
//**********************************************************************
