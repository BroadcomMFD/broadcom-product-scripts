//*--------------------------------------------------------------------*
//* T4ZOPTNU - CREATE A PARM OPTION MODEL FROM TABLE
//* PARM='ENBPIU00 M <SRCHVAL1> <SRCHVAL2> ...'
//* Option M - Process only selected rows based on search value given
//*--------------------------------------------------------------------*
//T4ZOPTNU EXEC PGM=IKJEFT1B,     **Examine T4Z Options**
//        PARM='ENBPIU00 M &C1ELEMENT',
//          COND=(4,LT)
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&USERCLS0
//MYYAML   DD DISP=SHR,DSN=&OPTIONS(&C1ELEMENT)
//OPTIONS  DD  *
  $nomessages = 'Y'
  $NumberModelsAndTblouts= 1
  x=BuildFromMODEL('MODEL')
  call bpxwdyn "info fi(MYYAML) inrtdsn(dsnvar)"
  TRACE ?R
  dsnmem =  dsnvar||'('&C1ELEMENT')';
  x = SYSDSN("'"dsnmem"'");
  if x = 'OK' then, x=BuildFromMODEL('MODEL1')
  $SkipRow='Y'
//TABLE    DD DSN=&TABLE(UTABLE),
//            DISP=SHR
//MODEL    DD *                  *Reporting output
  Allow_test_fails = '&Allow_test_fails'
  Tst_Suite = '&Tst_Suite'
  Unit = '&Unit'
  Subsystem = '&Subsystem'
//MODEL1   DD DATA,DLM=Q1
  Addnl_parm = 'Y'
Q1
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&&UOPTIONS,DISP=(,PASS,DELETE)
//*--------------------------------------------------------------------*
//*            UNIT TEST JCL
//*--------------------------------------------------------------------*
//T4ZUNI# EXEC PGM=IRXJCL,        **Create UNIT TEST JCL
//         PARM='ENBPIU00 1',
//         COND=(4,LT)
//TABLE    DD *
* Any
  *
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//         DD DISP=SHR,DSN=&CSIQCLS0
//OPTIONS  DD *  Bump jobcard and fetch Accounting code
* Identify whether Unit testing needs to be executed
  X = IncludeQuotedOptions(TEST4OPT)
  if Unit \= 'Y' then, exit(3)
  if Addnl_parm = 'Y' then, exit(3)
* Accounting value fetch may not be necessary at your site
  WhoAmI = USERID()
  myJobAccountingCode = GETACCTC(whoAmI)
  myJobName = MVSVAR('SYMDEF',JOBNAME )
  BumpedJobname = BUMPJOB(myJobName)
* Include the additional parms or lines
  If Subsystem = 'DB2' then do; +
      x=BuildFromMODEL('MODEL2'); +
      x=BuildFromMODEL('MODEL3'); +
      x=BuildFromMODEL('MODEL1'); +
      $SkipRow='Y'; +
    $SkipRow='Y'; +
  End
  x=BuildFromMODEL('MODEL')
  x=BuildFromMODEL('MODEL1')
  $SkipRow='Y'
//TEST4OPT DD DSN=&&UOPTIONS,DISP=(OLD,PASS)
//MODEL    DD DATA,DLM=QQ
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*----------------------------------------------------------
//  SET T4ZRUNL=&T4ZRUNL
//  SET T4ZLOAD=&T4ZLOAD
//  SET T4ZLDATA=&T4ZLDATA
//  SET T4ZRJSON=&T4ZRJSON
//  SET T4ZCJSON=&T4ZCJSON
//  SET LOADLIB=&LOADLIB
//*----------------------------------------------------------
//RUNTEST  EXEC PGM=ZESTRUN
//STEPLIB  DD DISP=SHR,DSN=&T4ZRUNL
//         DD DISP=SHR,DSN=&LOADLIB
//         DD DISP=SHR,DSN=&T4ZLOAD
//CEEOPTS  DD *
TRAP(ON,NOSPIE)
PROFILE(OFF)
//ZLRESULT DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//ZLDATA   DD DISP=SHR,DSN=&T4ZLDATA
//ZLDEBUG  DD SYSOUT=*
//ZLMSG    DD SYSOUT=*
//ZLCOVER  DD DISP=SHR,DSN=&T4ZCJSON(&C1ELEMENT)
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
QQ
//MODEL1   DD DATA,DLM=Q1
//ZLOPTS   DD *
ZESTPARM(D=&T4ZLOAD,M=&Tst_Suite)
Q1
//MODEL2   DD DATA,DLM=Q2
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
/*JOBPARM  S=CA31
//*----------------------------------------------------------
//  SET T4ZRUNL=&T4ZRUNL
//  SET T4ZLOAD=&T4ZLOAD
//  SET T4ZLDATA=&T4ZLDATA
//  SET T4ZRJSON=&T4ZRJSON
//  SET LOADLIB=&LOADLIB
//  SET DB2LLIB=&DB2LLIB
//  SET DB2S=&DB2S
//  SET PLANNME=&PLANNME
//*----------------------------------------------------------
//RUNTEST  EXEC PGM=IKJEFT1B
//STEPLIB  DD DISP=SHR,DSN=&T4ZRUNL
//         DD DISP=SHR,DSN=&LOADLIB
//         DD DISP=SHR,DSN=&T4ZLOAD
//         DD DISP=SHR,DSN=&DB2LLIB
//ZLRESULT DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//ZLDATA   DD DISP=SHR,DSN=&T4ZLDATA
//ZLDEBUG  DD SYSOUT=*
//ZLMSG    DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
Q2
//MODEL3   DD DATA,DLM=Q3
//SYSTSIN  DD *
  DSN SYSTEM(&DB2S)
  RUN PROGRAM(ZESTRUN) -
  PLAN(&PLANNME)
  END
Q3
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&PROJECT..&C1ELEMENT..UNITEST,
//             DISP=(,PASS,DELETE)
//IFT4ZU#  IF (T4ZUNI#.RC NE 3 & T4ZUNI#.RC LE 4) THEN
//*--------------------------------------------------------------------*
//*     Submit and wait for Unittest Job                               *
//*--------------------------------------------------------------------*
//SUBMITRP EXEC PGM=IKJEFT1B,     **Submit UNITTEST JCL
//          COND=((3,EQ,T4ZUNI#),(4,LT,T4ZUNI#)),
//   PARM='SUBMITST &PROJECT..&C1ELEMENT..UNITEST 30 01'
//* PARM='SUBMITST <SubmitJCL> <NumberWaits> <SecondsPerWait>'
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
//**********************************************************************
//* Show the JCL
//**********************************************************************
//SHOWJCL  EXEC PGM=IEBGENER,
//         COND=(4,GT,SUBMITRP)
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=(OLD,DELETE),DSN=&PROJECT..&C1ELEMENT..UNITEST
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//**********************************************************************
//* Show the intermediate results
//**********************************************************************
//SHOWJSON EXEC PGM=IEBGENER      **Show Results**         T4ZUNIT
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//**********************************************************************
//* Indicate a PASS or FAIL condition onto the Element
//**********************************************************************
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  T4ZUNIT
//         PARM='  ',  <- '00'x
//         COND=(4,LT),
//         MAXRC=2
//SYSEXEC  DD DSN=&&UOPTIONS,DISP=(OLD,DELETE)
//         DD *
  CALL BPXWDYN "ALLOC FI(UNITTEST) ",
       "DA(&T4ZRJSON(&C1ELEMENT)) SHR REUSE"
  If RESULT /= 0 then,
     Do; Queue "Cannot find json results in",
         "&T4ZRJSON(&C1ELEMENT)" ; $my_rc =3 ;
     End
  Else,
     Do; $my_rc =1;
     Queue "Found UnitTest results in &T4ZRJSON(&C1ELEMENT)"
     "EXECIO * DISKR UNITTEST (Stem json. Finis"
     CALL BPXWDYN "FREE FI(UNITTEST)"
     Do j# = 1 to json.0
        jsontext = json.j#
        If pos('"testSuite":',jsontext)> 0 then,
           Queue "UNITTEST:" jsontext ;
        where = Pos('"failed":',jsontext)
        If where = 0 then iterate;
        Queue "UNITTEST:" jsontext
        unittestRc = word(substr(jsontext,where),2)
        If unittestRc /= "0," then Do; $my_rc =3; Leave; End
     End; /* Do j# = 1 to json.0 */
     End; /* ELSE... */
  SAY Allow_test_failS
  if $my_rc =1 then,
     Queue "Unit Test was successful"

  if $my_rc =3 then,
     Queue "Test Failed"

  If Allow_test_fails = 'Y' then,
     Do; Queue "The Allow_test_fails = 'Y' is set"; $my_rc =2 ; End

  MessageDD  = word("SUCCESS WARNING FAILURE",$my_rc)
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "
  "EXECIO " QUEUED() "DISKW" MessageDD "( Finis"
  CALL BPXWDYN "Free  DD("MessageDD")"

  exit($my_rc)
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//         ENDIF
//*
//IFT4ZUNI IF T4ZUNI#.RC EQ 3 THEN
//*--------------------------------------------------------------------*
//*            UNIT TEST JCL
//*--------------------------------------------------------------------*
//T4ZUNI#1 EXEC PGM=IRXJCL,       **Create UNIT TEST JCL
//         PARM='ENBPIU00 1',
//         COND=(4,LT)
//TABLE    DD *
* Any
  *
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//         DD DISP=SHR,DSN=&CSIQCLS0
//MYYAML   DD DISP=SHR,DSN=&OPTIONS(&C1ELEMENT)
//OPTIONS  DD *  Bump jobcard and fetch Accounting code
* Identify whether Unit testing needs to be executed
  X = IncludeQuotedOptions(TEST4OPT)
  if Addnl_parm \= 'Y' then, exit(3)
  if Unit \= 'Y' then, exit(3)
* Accounting value fetch may not be necessary at your site
  WhoAmI = USERID()
  myJobAccountingCode = GETACCTC(whoAmI)
  myJobName = MVSVAR('SYMDEF',JOBNAME )
  BumpedJobname = BUMPJOB(myJobName)
* Call YAML2REX here to build the JCL with additional parms/lines
  Call YAML2REX 'MYYAML'
  HowManyYamls = QUEUED()
  Do yaml# =1 to HowManyYamls; +
    Parse pull yaml2rexx; +
    Say yaml2rexx; +
    interpret yaml2rexx; +
  End
* Include the additional parms or lines
  If Subsystem = 'DB2' then do; +
    Do yaml# =1 to TEST4Z.DB2P.0; +
      If (word(TEST4Z.DB2P.yaml#,2)=  'PLAN:') then, +
        PLANNME=word(TEST4Z.DB2P.yaml#,3); +
      If (word(TEST4Z.DB2P.yaml#,2)=  'DB2S:') then, +
        DB2S=word(TEST4Z.DB2P.yaml#,3); +
    End; +
    x=BuildFromMODEL('MODEL3'); +
    Do yaml# =1 to TEST4Z.JCLS.0; +
      IncludeUJcl=substr(TEST4Z.JCLS.yaml#,3); +
      if IncludeUJcl = ' '  then, IncludeUJcl = '//*'; +
      x=BuildFromMODEL('MODEL1'); +
    End; +
    x=BuildFromMODEL('MODEL4'); +
    x=BuildFromMODEL('MODEL2'); +
    Do yaml# =1 to TEST4Z.PARMS.0; +
      IncludeUJcl=substr(TEST4Z.PARMS.yaml#,3); +
      x=BuildFromMODEL('MODEL1'); +
    End; +
    $SkipRow='Y'; +
  End
  x=BuildFromMODEL('MODEL')
  Do yaml# =1 to TEST4Z.JCLS.0; +
    IncludeUJcl=substr(TEST4Z.JCLS.yaml#,3); +
    If IncludeUJcl = ' '  then, IncludeUJcl = '//*'; +
    x=BuildFromMODEL('MODEL1'); +
  End
  x=BuildFromMODEL('MODEL2')
  Do yaml# =1 to TEST4Z.PARMS.0; +
    IncludeUJcl=substr(TEST4Z.PARMS.yaml#,3); +
    x=BuildFromMODEL('MODEL1'); +
  End
  $SkipRow='Y'
//TEST4OPT DD DSN=&&UOPTIONS,DISP=(OLD,PASS)
//MODEL    DD DATA,DLM=QQ
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*----------------------------------------------------------
//  SET T4ZRUNL=&T4ZRUNL
//  SET LOADLIB=&LOADLIB
//  SET T4ZLOAD=&T4ZLOAD
//  SET T4ZLDATA=&T4ZLDATA
//  SET T4ZRJSON=&T4ZRJSON
//*----------------------------------------------------------
//RUNTEST  EXEC PGM=ZESTRUN
//STEPLIB  DD DISP=SHR,DSN=&T4ZRUNL
//         DD DISP=SHR,DSN=&LOADLIB
//         DD DISP=SHR,DSN=&T4ZLOAD
//CEEOPTS  DD *
TRAP(ON,NOSPIE)
TERMTHDACT(UADUMP)
ALL31(ON)
PROFILE(OFF)
//ZLRESULT DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//ZLDATA   DD DISP=SHR,DSN=&T4ZLDATA
//ZLDEBUG  DD SYSOUT=*
//ZLMSG    DD SYSOUT=*
//ZLCOVER  DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
QQ
//MODEL1   DD DATA,DLM=Q1
&IncludeUJcl
Q1
//MODEL2   DD DATA,DLM=Q2
//ZLOPTS   DD *
ZESTPARM(D=&T4ZLOAD,M=&Tst_Suite)
Q2
//MODEL3   DD DATA,DLM=Q3
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
/*JOBPARM  S=CA31
//*----------------------------------------------------------
//  SET T4ZRUNL=&T4ZRUNL
//  SET LOADLIB=&LOADLIB
//  SET T4ZLOAD=&T4ZLOAD
//  SET T4ZLDATA=&T4ZLDATA
//  SET T4ZRJSON=&T4ZRJSON
//  SET DB2LLIB=&DB2LLIB
//  SET DB2S=&DB2S
//  SET PLANNME=&PLANNME
//*----------------------------------------------------------
//RUNTEST  EXEC PGM=IKJEFT1B
//STEPLIB  DD DISP=SHR,DSN=&T4ZRUNL
//         DD DISP=SHR,DSN=&LOADLIB
//         DD DISP=SHR,DSN=&T4ZLOAD
//         DD DISP=SHR,DSN=&DB2LLIB
//ZLRESULT DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//ZLDATA   DD DISP=SHR,DSN=&T4ZLDATA
//ZLDEBUG  DD SYSOUT=*
//ZLMSG    DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
Q3
//MODEL4   DD DATA,DLM=Q4
//SYSTSIN  DD *
  DSN SYSTEM(&DB2S)
  RUN PROGRAM(ZESTRUN) -
  PLAN(&PLANNME)
  END
Q4
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//YAML2REX DD DUMMY  <- Turn on/off REXX trace
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&PROJECT..&C1ELEMENT..UNITES1,
//             DISP=(,PASS,DELETE)
//**********************************************************************
//* Show the JCL
//**********************************************************************
//SHOWJCL  EXEC PGM=IEBGENER,     **Show JCL only the last step fails**
//         COND=(4,GT,T4ZUNI#1)
//SYSPRINT DD DUMMY
//SYSUT1   DD DISP=(OLD,PASS),DSN=&PROJECT..&C1ELEMENT..UNITES1
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//*--------------------------------------------------------------------*
//*     Submit and wait for Unittest Job                               *
//*--------------------------------------------------------------------*
//SUBMITRP EXEC PGM=IKJEFT1B,     **Submit UNITTEST JCL
//          COND=((3,EQ,T4ZUNI#1),(4,LT,T4ZUNI#1)),
//   PARM='SUBMITST &PROJECT..&C1ELEMENT..UNITES1 30 01'
//* PARM='SUBMITST <SubmitJCL> <NumberWaits> <SecondsPerWait>'
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
//**********************************************************************
//* Show the intermediate results
//**********************************************************************
//SHOWJSON EXEC PGM=IEBGENER,     **Show Results**         T4ZUNIT
//         COND=((4,LT),(3,EQ,T4ZUNI#1))
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=SHR,DSN=&T4ZRJSON(&C1ELEMENT)
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//**********************************************************************
//* Indicate a PASS or FAIL condition onto the Element
//**********************************************************************
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  T4ZUNIT
//         PARM='  ',  <- '00'x
//         COND=((4,LT),(3,EQ,T4ZUNI#1)),
//         MAXRC=2
//SYSEXEC  DD *
  CALL BPXWDYN "ALLOC FI(UNITTEST) ",
       "DA(&T4ZRJSON(&C1ELEMENT)) SHR REUSE"
  If RESULT /= 0 then,
     Do; Queue "Cannot find json results in",
         "&T4ZRJSON(&C1ELEMENT)" ; $my_rc =3 ;
     End
  Else,
     Do; $my_rc =1;
     Queue "Found UnitTest results in &T4ZRJSON(&C1ELEMENT)"
     "EXECIO * DISKR UNITTEST (Stem json. Finis"
     CALL BPXWDYN "FREE FI(UNITTEST)"
     Do j# = 1 to json.0
        jsontext = json.j#
        If pos('"testSuite":',jsontext)> 0 then,
           Queue "UNITTEST:" jsontext ;
        where = Pos('"failed":',jsontext)
        If where = 0 then iterate;
        Queue "UNITTEST:" jsontext
        unittestRc = word(substr(jsontext,where),2)
        If unittestRc /= "0," then Do; $my_rc =3; Leave; End
     End; /* Do j# = 1 to json.0 */
     End; /* ELSE... */

  if $my_rc =1 then,
     Queue "Unit Test was successful"

  if $my_rc =3 then,
     Queue "Test Failed"

  If Allow_test_fails = 'Y' then,
     Do; Queue "The Allow_test_fails = 'Y' is set"; $my_rc =2 ; End

  MessageDD  = word("SUCCESS WARNING FAILURE",$my_rc)
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "
  "EXECIO " QUEUED() "DISKW" MessageDD "( Finis"
  CALL BPXWDYN "Free  DD("MessageDD")"

  exit($my_rc)
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//*--------------------------------------------------------------------*
//**********************************************************************
//         ENDIF
//*--------------------------------------------------------------------*
