/*  REXX    */
   /*----------------------------------------------------------*/
   /*  This Rexx is given a JCL dataset and member name in its */
   /*  parameter.                                              */
   /*  This Rexx:                                              */
   /*      o Tailors the JCL for the testing location (C1STAGE)*/
   /*        using OPTIONS statements or a YAML input          */
   /*      o submits the JCL                                   */
   /*      o watches and waits for it to complete its execution*/
   /*      o then captures all the output from JES and copies  */
   /*        it to a dataset                                   */
   /*      o compares the dataset with the most recent former  */
   /*        dataset, if found. However, if an OPT statement   */
   /*        names a "BaseLine" for your comparison, then it   */
   /*        is used and not the most recent former dataset.   */
   /*      o provides the comparison as output                 */
   /*                                                          */
   /*  This uses REXX methods supported by SDSF.               */
   /*                                                          */
   /*  See-                                                    */
   /*  https://www.ibm.com/support/knowledgecenter/            */
   /*  en/SSLTBW_2.2.0/com.ibm.zos                             */
   /*  .v2r2.isfa500/rexref.htm                                */
   /*                                                          */
   /*----------------------------------------------------------*/
   /*                                                             */
   /* OPTIONS syntax-  (see Github for YAML input examples)       */
   /*                                                             */
   /*   TXT.C1Stage.FindTxt.# = <searchText>'                     */
   /*   TXT.C1Stage.Replace.# = <ReplaceText>'                    */
   /*                \ where # is a number from 1 up, as needed.  */
   /*                                                             */
   /*   TXT.C1Stage.FindTxt.# = <searchText>'                     */
   /*   TXT.C1Stage.Insertx.# = '<inserted JCL statements>'       */
   /*   TXT.C1Stage.where.# = 'BEFORE' / 'AFTER'                  */
   /*                                     \ (defaults to 'AFTER') */
   /*                                                             */
   /*  Optionally, a DDname can be used for identifying where     */
   /*  to insert lines of JCL-                                    */
   /*                                                             */
   /*   TXT.C1Stage.REPLACE.<ddname>.     = '<jcl>'               */
   /*                                                             */
   /*  Optionally, a DDname and stepname can be used.             */
   /*                                                             */
   /*   TXT.C1Stage.REPLACE.<ddname>.<stepname>'  = '<jcl>'       */
   /*                                                             */
   /*  If new or replacement JCL text begins with '//' then the   */
   /*  lines of JCL are inserted, using '//' to identifiy the     */
   /*  start of each line.                                        */
   /*  If '//' is not found, then it is assumed that dataset      */
   /*  names are listed in the value, and each is to be           */
   /*  included with DISP=SHR. The first dataset name is given    */
   /*  the label <ddname>.                                        */
   /*                                                             */
   /*  Examples                                                   */
   /*                                                             */
   /*   TXT.C1Stage.FindTxt.1 = 'CLASS=P'                         */
   /*   TXT.C1Stage.Replace.1 = 'CLASS=T'                         */
   /*                                                             */
   /*   TXT.C1Stage.FindTxt.2 = ' PEND '                          */
   /*   TXT.C1Stage.where.2 = 'AFTER'                             */
   /*   TXT.C1Stage.Insertx.2 = '//START  EXEC PGM=IEFBR14'       */
   /*                                                             */
   /*   TXT.C1Stage.REPLACE.STEPLIB.STEP1 = 'IBMUSER.LOADLIB'     */
   /*   TXT.C1Stage.REPLACE.STEPLIB.STEP2 = ,                     */
   /*                 '//     DD DISP=SHR,DSN=IBMUSER.LOADLIB     */
   /*                                                             */
   /*                                                             */
   /*----------------------------------------------------------*/

/* Is TEST#JOB allocated? If yes, then turn on Trace  */
   isItThere = ,
     BPXWDYN("INFO FI(TEST#JOB) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then TraceRc = 'Y'

   /* A processor provides these Endevor values as arguments */
   ARG C1Element C1Stage ,
       WaitLoops LoopSeconds TestResultsHLQ ;

   /* There is a limit to the length of the TestResultsHLQ   */
   If Length(TestResultsHLQ) > 21 then,
      Do
      Push 'The TestResultsHLQ length must be 21 characters or less'
      Push TestResultsHLQ 'is' Length(TestResultsHLQ) 'characters long'
      "EXECIO 2 DISKW ERRORS (Finis"
      Exit(12)
      End

   /* Set Defaults / initial values....                        */
   /* Set the value for Phase that indicates job is done       */
   my_rc = 0
   FinalExpectedPhase = "AWAITING OUTPUT"

   $numbers   = '0123456789'   /* chars for numeric values   */
   AlphaChars   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
   $OptionCommentChar = '*'
   $EndevorVariables  = ''
   ShowReplaceResults = 'Y'

   /*   Select a Default for the SUPERC parameter.             */
   /* Set defaults                   */

   Drop MaxReturnCode
   SuperCRc = 0
   Drop Baseline
   TXT.C1Stage.BASELINE = ' '        /* Name of C1stage Baseline*/

   /* Default replacement strings to keep in the output results */
   NeutralizeMasks = 'JOB99999 D9999999 99.99.99 ',
                     'SYS99999 T999999 ',
                     '99:99 9999999.9999'
   Superc_Parms = 'DELTAL,LINECMP'
   Superc_Parms = 'LONGL,LINECMP'
   Superc_Parms = 'LONGL,LINECMP,WIDE'

   NumberReplaceStrings = 0   ; /* Assume zero, unless we find some*/
   NumberMaskStrings    = 0   ; /* Assume zero, unless we find some*/

   Say 'TEST#JOB: Automated Testing is examining details for '
   Say 'TEST#JOB: Element ' C1Element 'at stage ' C1Stage

   /* Get   Options for tailoring and processing the JCL       */
   /* If Options are in a YAML format, comment the 1st line    */
   /* If no Options are designated for C1stage, then exit      */
   Call ProcessInputOptions;

   /* Instructions for changing a JCL are on the Stack       */
   /* and they are already syntactically validated.          */
   /* (options created from Yaml are created as validated)   */
   /* Here is how many there are....                         */
   QueuedTotal = QUEUED()
   /* In case some are for MASK or SuperC, this step needs   */
   /* to interpret those too, and place others back on Stack.*/

   If TraceRc = 'Y' then Say 'TEST#JOB: Preparing OPTIONS:'
   /* re-Stack  the ones beginning with TXT.         */
   /* Interpret the others.                          */
   Do QueuedTotal
      Parse Pull thisVopt
      thisVopt = Strip(thisVopt)
      If TraceRc = 'Y' then Say 'TEST#JOB:' thisVopt
      Queue thisVopt    ;  /* opt is for TXTRPLCE */
      interpret thisVopt;  /* opt is for TEST#JOB */
   End;   /* Do v# = 1 to vopts.0 */

   QueuedTotal = QUEUED()
   if QueuedTotal = 0 then Exit(4)

   Say 'TEST#JOB: Applying' QueuedTotal,
       ' Search and Replace actions'
   /* Now call TXTRPLCE to update NEWTXT from OLDTXT         */
   /* using instructions on the Stack (already validated)    */
   If TraceRc = 'Y' then,
      say "TEST#JOB: calling TXTRPLCE(C1Stage STACK)"
   If my_rc < 4 then my_rc = TXTRPLCE(C1Stage STACK)
   Else,
      Do
      Say 'TEST#JOB: is having issues with OPTIONS'
      Exit(12)
      End

   /* If Baseline specified at Stage level use it.     */
   If TraceRc = 'Y' then Trace r
   Drop Baseline
   thisBaseline = TXT.C1Stage.BASELINE

   /* If MaxReturnCode given at Stage level use it.     */
   Drop MaxReturncode
   thisMaxReturncode = TXT.C1Stage.MaxReturnCode
   If Verify(thisMaxReturncode,$numbers) > 0 then,
      thisMaxReturncode = 4;

   /* Get Dataset name for new JCL - to be submitted           */
   $rslt =  LISTDSI("NEWTXT" "FILE")
   If $rslt = 0 then SubmitJCL = sysdsname
   Else,
      Do
      Push 'NEWTXT must be a cataloged dataset'
      "EXECIO 1 DISKW ERRORS (Finis"
      Exit(12)
      End

   /*----------------------------------------------------------*/
   /* Get my jobname....  Cannot wait for myself               */
   /* Ensure the job we submit does not have the same jobname  */
   /* as my own.                                               */
   /*----------------------------------------------------------*/
   myJobName = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */

   /* Submit the tailored JCL                                  */
   Call Submit_n_save_jobInfo;
   If SelectJobName = myJobName then,
      Do
      Push 'The job to be monitored is mine. Invalid request'
      Push 'you must ensure the test job has a different name.'
      "EXECIO 2 DISKW ERRORS (Finis"
      Exit(8)
      End;

   Call Monitor_Job_Status;

   Say SelectJobNumber SelectJobName 'has completed'

   /* Name the dataset where the job output is to be copied */
   Today= DATE('S')
   DateNode = 'D' || Substr(Today,3)
   nowTime= TIME()
   TimeNode = 'T' || Substr(nowTime,1,2) || Substr(nowTime,4,2)
   /*             || Substr(nowTime,7,2)  */
   thisTestResult =   TestResultsHLQ'.' ||,
                      C1Stage'.'DateNode'.'SelectJobNumber

   ADDRESS TSO,
     "ALLOC F(JOBSAVE) LRECL(132) BLKSIZE(0) SPACE(10,10) ",
          " DA('"thisTestResult"')",
          " RECFM(F B) CYLINDER ",
          " MOD CATALOG REUSE ";

   /* Collect the outputs from the submitted job            */
   Call Collect_Job_Outputs;
   "EXECIO 0 DISKW JOBSAVE (Finis"
   ADDRESS TSO  "FREE  F(JOBSAVE)"
   Say 'TEST#JOB: Test Results captured into' thisTestResult

   /* Create a Relate for output results */
   Push "RELATE OBJECT '"thisTestResult"'."

   /* If a Baseline for comparison is not named, search for former */
   If thisBaseline = ' ' then,
      Call Locate_Former_TestResults;

   /* If we have something to compare        */
   /* and thisMaxReturncode < 999 then compare.. */
   if thisMaxReturncode >= 999 then,
      Say 'TEST#JOB: MaxReturnCode at Stage' C1Stage 'is' thisMaxReturncode'.',
          ' The comparison of results is being skipped.'
   Else,
   if thisBaseline /= ' ' & thisMaxReturncode < 999 then,
      Do
      Say 'TEST#JOB: Comparing' thisTestResult
      Say 'TEST#JOB:        to' thisBaseline
      Call CompareTestResults;
      If thisBaseline /= ' ' then,
         Push "RELATE OBJECT '"thisBaseline"'."
      End

   "EXECIO" QUEUED() "DISKW RELATE (Finis"

   If SuperCRc > thisMaxReturncode then,
      Do
      Push 'Comparison Fails. SUPERC rc='SuperCRc
      "EXECIO 1 DISKW ERRORS (Finis"
      Exit(8)
      End

   Say 'TEST#JOB: Comparison is successful. SUPERC rc='SuperCRc
   Exit(1); /* Submitted a Successful test */

ProcessInputOptions:

   /* Determine from 1st record if OPTIONS are in YAML format  */
   If  TraceRc = 'Y'  then Trace r
   "EXECIO 1 DISKR OPTIONS "    /* may be in Rexx or Yaml format*/
   Parse Pull FirstOption
   whereText = WordIndex(FirstOption,1)
   /* If Yaml is being used, the 1st record must be a comment  */
   If Substr(FirstOption,whereText,1)='#' then, /*We are using YAML*/
      Do
      /* Convert Yaml to REXX and place onto Stack */
      If TraceRc = 'Y' then,
         say "TEST#JOB: calling YAML2REX 'OPTIONS'"
      Call YAML2REX 'OPTIONS'
      OptionsType = 'YAML'
      Push  " OptionsType = 'YAML'";  /* tell TXTRPLCE */
      End ; /* If Substr(FirstOption,1,1) = '#' */
   Else,                                   /* We are using Rexx */
      Do
      /* Validate OPTIONS and place onto Stack */
      If TraceRc = 'Y' then,
         say "TEST#JOB: calling OPTVALDT(OPTIONS Y)"
      my_rc = OPTVALDT(OPTIONS Y)
      OptionsType = 'Rexx'
      End ; /* If Substr(FirstOption,1,1) = '%' */

   /* Instructions for changing a JCL are on the Stack       */
   /* Here is how many there are....                         */
   QueuedTotal = QUEUED()

   /* Read the VARIABLE data (variables provided by Endevor) */
   /* Variables can be mixture of C1* variables  of Endevor, */
   /* processor variables and Site Symbol variables.         */
   /* Append new instructions onto the Stack                 */
   "EXECIO * DISKR VARIABLE ( Stem var. Finis"

   If OptionsType = 'YAML' then,
      VarPrefix = 'TXT.'C1Stage'.Change'
   Else,
      VarPrefix = 'TXT.'C1Stage
   indx#= QUEUED() +1

   Do v# = 1 to var.0
      ndvrVariable = var.v#
      whereText = WordIndex(ndvrVariable,1)
      if whereText = 0 then Iterate;
      If Substr(ndvrVariable,whereText,1) = '#' |,
         Substr(ndvrVariable,whereText,1) = '*' then Iterate;

      PARSE VAR ndvrVariable $keyword "=" $keyValue
      $keyword = Strip($keyword)
      $keyValue = Strip($keyValue)
      Queue VarPrefix".Findtxt."indx# "='&"$keyword"'"
      Queue VarPrefix".Replace."indx# "="$keyValue
      If TraceRc = 'Y' then,
         Do
         Say 'TEST#JOB:'
         Say VarPrefix".Findtxt."indx# "='&"$keyword"'"
         Say VarPrefix".Replace."indx# "="$keyValue
         End
      indx#= indx# +1
   End; /*  Do v# = 1 to var.0 */
 trace Off

   Return;

Submit_n_save_jobInfo: /* submit SubmitJCL job and save job info */

   Address TSO "PROFILE NOINTERCOM"     /* turn off msg notific      */
   CALL MSG "ON"
   CALL OUTTRAP "out."
   ADDRESS TSO "SUBMIT '"SubmitJCL"("C1Element")'" ;
   If RC > 4 then,
      Do
      Push 'Cannot find Element member to submit.'
      "EXECIO 1 DISKW ERRORS (Finis"
      Exit(12)
      End
   CALL OUTTRAP "OFF"
   JobData   = Strip(out.1);
   jobinfo         = Word(JobData,2) ;
   If jobinfo = 'JOB' then,
      jobinfo   = Word(JobData,3) ;
   SelectJobName   = Word(Translate(jobinfo,' ',')('),1) ;
   SelectJobNumber = Word(Translate(jobinfo,' ',')('),2) ;

   Return;

Monitor_Job_Status:

   /* Indicate we need isfcalls                                */
   IsfRC = isfcalls( "ON" )
   if IsfRC <> 0 then,
      Do
      Push "Failure with isfcalls"
      "EXECIO 1 DISKW ERRORS (Finis"
      Exit(8)
      End

   /* Wait for the submitted job to finish                     */
   jobnum =  SelectJobNumber
   jobid  =  SelectJobName
   thisJobPhase = 'Submitted'
   ownerid = USERID()
   retcode. = ' '
   daten.   = ' '
   Timen.= ' '
   PhaseName. = ' '

   myMessage = ' ';
   isfprefix = SelectJobname
   isfowner = USERID()
   isfcols = "jname jobid ownerid queue jclass prtdest retcode",
             " daten TIMEN PHASENAME "

   seconds = LoopSeconds /* Number of Seconds to wait if needed */

   /*********************************************/
   /* Wait until the submitted job is completed */
   /*********************************************/
   Do WaitLoops
      /* call exec_sdsf "0 ISFEXEC ST" opts_sdsf */
      Address SDSF "isfexec ST (VERBOSE ALTERNATE DELAYED)"

      if RC <> 0 then,
        Do
        Push "RC" RC "returned from ISFEXEC ST" ;
        "EXECIO 1 DISKW ERRORS (Finis"
        Exit(12);
        end;

      Sa= 'isfcols=' isfcols
      StRows = isfrows
      If StRows = 0 then,
        Do
        sa= "No rows returned from ISFEXEC"
        call WaitAwhile;
        Iterate ;
        end;

      drop i
      Do i = 1 to StRows
        Sa= 'At' TIME() 'Finding' jname.i jobid.i ownerid.i,
            jclass.i PhaseName.i Timen.i
      End;  /*Do i = 1 to StRows */

      drop i
      Do i = 1 to StRows
        sa= 'jobid.i ='jobid.i'/ SelectJobNumber='SelectJobNumber
        if jobid.i = SelectJobNumber then,
           Do
           thisJobid         = jobid.i
           thisEndTime       = timen.i
           thisJobPhase = PhaseName.i

           Say 'TEST#JOB: Status:' SelectJobname SelectJobNumber ,
               'retcode.i=' retcode.i thisJobPhase,
               ' on ' i 'wait loop'
           If thisJobPhase = FinalExpectedPhase |,
              thisEndTime > "00:00:00.00" then Leave;
           End;  /* if jobid.i = SelectJobNumber */
      End;  /*Do i = 1 to StRows */
      If thisJobPhase = FinalExpectedPhase |,
         thisEndTime > "00:00:00.00" then Leave;
      Say 'TEST#JOB: At' TIME(),
          'Waiting for job'  SelectJobname SelectJobNumber,
           thisJobPhase;
      call WaitAwhile;
   End;  /* Do Waitloops */

   If thisJobPhase = FinalExpectedPhase |,
      thisEndTime > "00:00:00.00" then,
      Do
      Say 'TEST#JOB: Job' SelectJobname SelectJobNumber 'is completed',
          ' at ' DATE(S) TIME()
      End
   Else,
      Do
      Push 'Job' SelectJobname SelectJobNumber,
          ' not completed within Wait arguments',
          WaitLoops LoopSeconds
      "EXECIO 1 DISKW ERRORS (Finis"
      exit(8)
      End

   Return;

WaitAwhile:
  /*                                                               */
  /* A resource is unavailable. Wait awhile and try                */
  /*   accessing the resource again.                               */
  /*                                                               */
  /*   The length of the wait is designated in the parameter       */
  /*   value which specifies a number of seconds.                  */
  /*   A parameter value of '000003' causes a wait for 3 seconds.  */
  /*                                                               */
  /*seconds = Abs(seconds)                                         */
  /*seconds = Trunc(seconds,0)                                     */
  Say "Waiting for" seconds "seconds at " DATE(S) TIME()
  /* AOPBATCH and BPXWDYN are IBM programs */
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"

  /* AOPBATCH and BPXWDYN are IBM programs */
  parm = "sleep "seconds
  Address LINKMVS "AOPBATCH parm"

  Return


Collect_Job_Outputs:

  myMessage = ' ';
  isfprefix = SelectJobname
  isfowner = USERID()
  isfcols = "jname jobid ownerid queue jclass prtdest retcode"

  address SDSF "isfexec st"

  if RC <> 0 then do
    say "RC" RC "returned from ISFEXEC ST" ; end;

  StRows = isfrows
  Drop i
  do i = 1 to StRows
    Sa= jname.i jobid.i ownerid.i retcode.i jclass.i
    if jobid.i = SelectJobNumber then,
       Do
       myReturnCode =  0000
       call ProcessSysouts  jname.i, jname.i, token.i
       Leave;
       End
  End;  /*do i = 1 to StRows */

  Return

ProcessSYSOUTS:

       parse arg JobName, MemberName, SdsfToken

       sa= "ProcessSYSOUTS: "
       /* Display the job's datasets */

       address SDSF,
       "isfact st token('"SdsfToken"') parm(np ?) (prefix j_"
       ActRC = RC
       if RC <> 0 then do
         say "JDS processing failed for job" JobName "with RC" ActRC
         call DisplayMessages
         return
       end

       /* Find the line for the specified DD name */

       /* Loop thru Sysout output DDnames. Write to JOBSAVE   */
       Do jX = 1 to j_ddname.0
         this_ddname = j_ddname.jX
         Sa= "Capturing " this_ddname;
         address SDSF "isfact st token('"j_token.jX"') parm(np sa)"
         if RC <> 0 then do
           Push "SYSOUT allocation failed for" JobName "with RC" ActRC
           "EXECIO 1 DISKW ERRORS (Finis"
           Exit(12)
           end
         /* Copy ot examine the SYSOUT        */
         Push '{{{{{{{{{{{{{{{ ' this_ddname || '-Start',
             ' }}}}}}}}}}}}}}}'
         "EXECIO 1 DISKW  JOBSAVE "
         myReturnCode = CopySysout("DD:"isfddname.1 ) ;
         Push '{{{{{{{{{{{{{{{ ' this_ddname || '-End  ',
             ' }}}}}}}}}}}}}}}'
         "EXECIO 1 DISKW  JOBSAVE "

       end  /* do jX = 1 to j_ddname.0   */

       return

CopySysout:

        parse arg CS_Input ;

        myReturnCode = 0
        sa= 'CopySysout:'
        sa= 'myReturnCode is currently' myReturnCode

        /* Allocate the input dataset if necessary */
        Drop inp.
        Sysut1DD = substr( CS_Input, 4 )
        "EXECIO * DISKR" Sysut1DD " ( Stem inp. Finis"
        myReturnCode = RC
        /* Copy to the JOBSAVE output              */
        "EXECIO * DISKW  JOBSAVE    ( Stem inp."

        Return myReturnCode ;

DisplayMessages:

       say "DisplayMessages:"
       say "isfmsg: '"isfmsg"'"
       say isfmsg2.0 "long messages in the isfmsg2 stem:"
       do i = 1 to isfmsg2.0
       say " '"isfmsg2.i"'"
       END
       Return

Locate_Former_TestResults:

   /* Get a list of datasets named with TestResultsHLQ */
   /* Find one prior to the one just created .......   */
   /* ... if it exists.                                */

   "ALLOC F(SYSPRINT) LRECL(133) BLKSIZE(1330) SPACE(5,5)",
          "RECFM(F B) TRACKS ",
          "NEW UNCATALOG REUSE "     ;

   "ALLOC FI(SYSIN) BLKSIZE(0) TRACKS LRECL(80) SPACE(5 5)",
       "RECFM(F B) NEW REUSE UNCATALOG" ;

   Push  " LISTCAT LEVEL('"TestResultsHLQ"."C1Stage"') NAME"

   "EXECIO 1 DISKW SYSIN (FINIS"

   ADDRESS LINK 'IDCAMS'
   my_rc =RC

   "EXECIO * DISKR SYSPRINT (Stem prt. FINIS"

 /* Look through the former test result outputs */
 /* .. to find the most recent one.             */
   If prt.0 > 1 then,
      Do lin# = prt.0 by -1 to 1
         print = Substr(prt.lin#,2)
         if Substr(print,1,7) /= 'NONVSAM' then iterate;
         sa= print
         If pos(TestResultsHLQ,print) = 0 then iterate;
         If pos(thisTestResult,print) > 0 then iterate;
         thisBaseline = Word(print,3)
         Leave
      End;

 /*   If no recent output is found,      */
 /*   then we have nothing to compare.   */
 /*   Just exit as a successful test.    */
   If thisBaseline = ' ' then,
      Say 'TEST#JOB: There is no former output to compare'

   "FREE  F(SYSPRINT)"
   "FREE  FI(SYSIN)"

   Return

CompareTestResults:

   /* Compare current Test result with former          */
   /* ... if it exists.                                */

   /* Prepare inputs    for a SUPERC call              */
   "ALLOC F(NEWDD) DA('"thisTestResult"') SHR REUSE"
   /* Neutralize for        a SUPERC call              */
   "EXECIO * DISKR NEWDD (Stem rcd. Finis"
   Do rc# = 1 to rcd.0
      String = rcd.rc#
      Call NeutralizeString
      rcd.rc# = String;
   End;
   "EXECIO * DISKW NEWDD (Stem rcd. Finis"

   /* Neutralize for        a SUPERC call              */
   "ALLOC F(OLDDD) DA('"thisBaseline"') SHR REUSE"
   Drop rcd.
   "EXECIO * DISKR OLDDD (Stem rcd. Finis "
   Do rc# = 1 to rcd.0
      String = rcd.rc#
      Call NeutralizeString
      rcd.rc# = String;
   End;
   "EXECIO * DISKW OLDDD (Stem rcd. Finis"

   /* Prepare the SYSIN for a SUPERC call              */
   "ALLOC FI(SYSIN) BLKSIZE(0) TRACKS LRECL(80) SPACE(5 5)",
       "RECFM(F B) NEW REUSE UNCATALOG" ;
   Push  "CMPCOLM 2:131"
   Push  "CMPSECT START  TOP 'JESYSMSG-End'"
   "EXECIO 2 DISKW SYSIN (FINIS"


   ADDRESS TSO,
   "CALL *(ISRSUPC) '"||Superc_Parms||"'"
   SuperCRc =RC

   "FREE  F(NEWDD)"
   "FREE  F(OLDDD)"
   "FREE  F(SYSIN)"

   Return

NeutralizeString:

   /* Tailor content for a better SUPERC comparison  */
   /* Neutralize Date and time specific fields */

   nineString = Translate(String,'999999999','012345678')
   sa= nineString

   /* Mask out upper and camel case versions of Month */
   Month = Word(DATE('N'),2)
   thisMask  = '99' Month '9999 '
   whereMask = Pos(thisMask,nineString)
   If whereMask > 0 then,
      string = Overlay('DD MMM YYYY ',String,whereMask)
   thisMask  = '99' Month '99 '
   whereMask = Pos(thisMask,nineString)
   If whereMask > 0 then,
      string = Overlay('99 MMM 99 ',String,whereMask)

   Upper Month
   thisMask  = '99' Month '9999 '
   whereMask = Pos(thisMask,nineString)
   If whereMask > 0 then,
      string = Overlay('DD MMM YYYY ',String,whereMask)
   thisMask  = '99' Month '99 '
   whereMask = Pos(thisMask,nineString)
   If whereMask > 0 then,
      string = Overlay('99 MMM 99 ',String,whereMask)

   /* Mask out upper and camel case versions of Day of Week*/
   WeekDay = Strip(DATE('W') )
   whereMask = Pos(WeekDay,String)
   If whereMask > 0 then,
      string = Overlay('DayOfWeek-',String,whereMask)
   Upper WeekDay
   whereMask = Pos(WeekDay,String)
   If whereMask > 0 then,
      string = Overlay('DayOfWeek-',String,whereMask)
   Sa= 'NeutralizeMasks =' NeutralizeMasks

   /* Process built-in Numeric Masks         */
   Do msk# = 1 to Words(NeutralizeMasks)
      thisMask =  Word(NeutralizeMasks,msk#)
      whereMask =  Pos(thisMask, nineString)
      If whereMask = 0 then iterate;
      Do while whereMask > 0
        String = Overlay(thisMask,String,whereMask)
        whereMask =  Pos(thisMask, nineString, (whereMask+1))
        If whereMask = 0 then Leave;
      End;  /* Do Forever  */
   End; /*  Do msk# = 1 to Words(NeutralizeMasks) */

   If TraceRc = 'Y' then Trace r
   /* Process User MaskTarget and MaskColumn pairs */
   If NumberMaskStrings > 0 then,
      Do
       If rc# = 1 then,
          Say 'TEST#JOB: Applying user MaskTarget and MaskColum pairs to',
              ' test results'
       Do msk# = 1 to NumberMaskStrings
          thisMaskTarget = TXT.C1stage.MaskTarget.msk# ;
          thisMaskColumn = TXT.C1stage.MaskColumn.msk# ;
          if thisMaskTarget > '' &,
             thisMaskColumn > 0 then,
                Call MaskOutputString;
       End /* Do msk# = 1 to NumberMaskStrings */
      End /* If NumberMaskStrings > 0         */

   Return

MaskOutputString:

   If TraceRc = 'Y' then Trace r
   /* Apply masking changes to the String, and if the result     */
   /* matches the mask, then overlay the line.                   */
   origString = ,
      Substr(String,thisMaskColumn,Length(thisMaskTarget))
   tempString = origString

   /* Convert numeric characters to '9's            */
   If Pos('99',thisMaskTarget) > 0 then,
      tempString = Translate(tempString,,$numbers,'9')

   /* Convert alpha   characters to 'Z's            */
   If Pos('ZZ',thisMaskTarget) > 0 then,
      tempString = Translate(tempString,,AlphaChars,'Z')

   If tempString /= thisMaskTarget then Return;

   Say "B4:" Substr(String,1,80)
   String = Overlay(tempString,String,thisMaskColumn)
   Say "AF:" Substr(String,1,80)

   Return

