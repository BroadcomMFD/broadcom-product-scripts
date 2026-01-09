//*--------------------------------------------------------------------*
//* T4ZOPTNR - CREATE A PARM OPTION MODEL FROM TABLE
//* PARM='ENBPIU00 M <SRCHVAL1> <SRCHVAL2> ....'
//* Option M - Process only selected rows based on search value given
//*--------------------------------------------------------------------*
//T4ZOPTNR EXEC PGM=IKJEFT1B,     **Examine T4Z Options**
//        PARM='ENBPIU00 M &C1ELEMENT',
//          COND=(4,LT)
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0
//         DD DISP=SHR,DSN=&USERCLS0
//MYYAML   DD DISP=SHR,DSN=&OPTIONS(&C1ELEMENT)
//OPTIONS  DD  *
  $nomessages = 'Y'
  $NumberModelsAndTblouts= 1
  Addnl_parm = ' '
  x=BuildFromMODEL('MODEL')
  call bpxwdyn "info fi(MYYAML) inrtdsn(dsnvar)"
  dsnmem =  dsnvar||'('&C1ELEMENT')';
  x = SYSDSN("'"dsnmem"'");
  if x = 'OK' then, Addnl_parm = 'Y'
//TABLE    DD DSN=&TABLE(RTABLE),
//            DISP=SHR
//MODEL    DD *                  *Reporting output
  Element = '&Element'
  Recording = '&Recording'
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&&ROPTIONS,DISP=(,PASS,DELETE)
//*--------------------------------------------------------------------*
//*            RECORDING JCL
//*--------------------------------------------------------------------*
//T4ZRECRD EXEC PGM=IKJEFT1B,     **Create RECORDING JCL
//         PARM='ENBPIU00 1',
//         COND=(4,LT)
//TABLE    DD *
* Any
  *
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//         DD DISP=SHR,DSN=&CSIQCLS0
//YAML2REX DD DUMMY   <- Turn on/off REXX trace
//MYYAML   DD DISP=SHR,DSN=&OPTIONS(&C1ELEMENT)
//*YYAML   DD DISP=(OLD,DELETE),DSN=&&OPTIONS
//OPTIONS  DD *  Bump jobcard and fetch Accounting code
* Identify Whether Recording needs to be executed
 X = IncludeQuotedOptions(TEST4OPT)
 if Recording \= 'Y' then, exit(3)
 WhoAmI = USERID()
* Accounting value fetch may not be necessary at your site
 myJobAccountingCode = GETACCTC(whoAmI)
 myJobName = MVSVAR('SYMDEF',JOBNAME )
 BumpedJobname = BUMPJOB(myJobName)
* Include the additional parms or lines in Recording JCL
 if Addnl_parm = ' ' then do; +
   x=BuildFromMODEL('MODEL'); +
   IncludeJcl='//*'; +
   x=BuildFromMODEL('MODEL1'); +
   x=BuildFromMODEL('MODEL2'); +
   $SkipRow='Y'; +
 END;
 Call YAML2REX 'MYYAML'
 HowManyYamls = QUEUED()
 Do yaml# =1 to HowManyYamls; +
    Parse pull yaml2rexx; +
    interpret yaml2rexx; +
 End;
 x=BuildFromMODEL('MODEL')
 Do yaml# =1 to TEST4Z.JCLS.0 ; +
    Includejcl=substr(TEST4Z.JCLS.yaml#,3); +
    if Includejcl = ' ' then, Includejcl = '//*'; +
    x=BuildFromMODEL('MODEL1'); +
 END;
 x=BuildFromMODEL('MODEL2')
 Do yaml# =1 to TEST4Z.PARMS.0; +
    Includejcl=substr(TEST4Z.PARMS.yaml#,3); +
    x=BuildFromMODEL('MODEL1'); +
 END;
 $SkipRow='Y'
//TEST4OPT DD DSN=&&ROPTIONS,DISP=(OLD,PASS)
//MODEL    DD DATA,DLM=QQ
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//RUNTEST  EXEC PGM=ZTESTEXE
//STEPLIB  DD DISP=SHR,DSN=your_Test4z_Runtime_Loadlib
//         DD DISP=SHR,DSN=&LOADLIB
//ZLDATA   DD DSN=&PROJECT..&C1STAGE..T4ZLDATA(RECORDNG),
//            DISP=OLD
//SYSPRINT DD SYSOUT=*
QQ
//MODEL1   DD DATA,DLM=Q1
&Includejcl
Q1
//MODEL2   DD DATA,DLM=Q2
//ZLOPTS   DD *
RUN(&C1ELEMENT)
Q2
//SYSIN    DD DUMMY
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD DSN=&PROJECT..&C1ELEMENT..RECRDNG,
//             DISP=(,PASS,DELETE)
//**********************************************************************
//* SHOW THE RECORDING JCL
//**********************************************************************
//SHOWJCL  EXEC PGM=IEBGENER,     **Show Results**
//         COND=(4,LT)
//*        COND=((4,GT,T4ZRECRD)),
//*        EXECIF=(&C1ACTION,EQ,GENERATE)
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD DISP=(OLD,PASS),DSN=&PROJECT..&C1ELEMENT..RECRDNG
//SYSUT2   DD DSN=&&ZLJCR,DISP=(,PASS,DELETE)
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//*----------------------------------------------------------
//SUBMITRB EXEC PGM=IKJEFT1B,     **Submit RECORDING JCL
//          COND=((3,EQ,T4ZRECRD),(4,LT)),
//   PARM='SUBMITST &PROJECT..&C1ELEMENT..RECRDNG 10 01'
//SYSEXEC  DD DISP=SHR,DSN=&USERCLS0
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
//*----------------------------------------------------------
//*STEP TO FOOTPRINT THE RECORDING DATASET
//*----------------------------------------------------------
//RECCOPY  EXEC PGM=IEBGENER,MAXRC=0,
//             COND=((4,LT))
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  DSN=&PROJECT..&C1STAGE..T4ZLDATA(RECORDNG),
//             DISP=SHR
//SYSUT2   DD  DSN=&PROJECT..&C1STAGE..T4ZLDATA(&C1ELEMENT.),DISP=OLD,
//             MONITOR=COMPONENTS,FOOTPRNT=CREATE
//SYSIN    DD  DUMMY
//*
//*
//RECDELET EXEC PGM=IKJEFT01
//SYSTSPRT  DD   SYSOUT=*
//SYSTSIN  DD   *
DELETE '&PROJECT..&C1STAGE..T4ZLDATA(RECORDNG)'
/*
