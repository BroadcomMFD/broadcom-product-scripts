/*  REXX    */
   /*----------------------------------------------------------*/
   /*  This Rexx is given a JCL dataset and member name in its */
   /*  parameter.                                              */
   /*  The REXX                                                */
   /*      o Tailors the JCL for the testing location (C1STAGE)*/
   /*        using OPTIONS statements                          */
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
   /* OPTIONS syntax-                                             */
   /*                                                             */
   /*   JCL.C1Stage.FindTxt.# = <searchText>'                     */
   /*   JCL.C1Stage.Replace.# = <ReplaceText>'                    */
   /*                \ where # is a number from 1 up, as needed.  */
   /*                                                             */
   /*   JCL.C1Stage.FindTxt.# = <searchText>'                     */
   /*   JCL.C1Stage.Insertx.# = '<inserted JCL statements>'       */
   /*   JCL.C1Stage.where.# = 'BEFORE' / 'AFTER'                  */
   /*                                     \ (defaults to 'AFTER') */
   /*                                                             */
   /*  Optionally, a DDname can be used for identifying where     */
   /*  to insert lines of JCL-                                    */
   /*                                                             */
   /*   JCL.C1Stage.REPLACE.<ddname>.     = '<jcl>'               */
   /*                                                             */
   /*  Optionally, a DDname and stepname can be used.             */
   /*                                                             */
   /*   JCL.C1Stage.REPLACE.<ddname>.<stepname>'  = '<jcl>'       */
   /*                                                             */
   /*  If new or replacment JCL text begins with '//' then the    */
   /*  lines of JCL are inserted, using '//' to identifiy the     */
   /*  start of each line.                                        */
   /*  If '//' is not found, then it is assumed that dataset      */
   /*  names are listed in the value, and each is to be           */
   /*  included with DISP=SHR. The first dataset name is given    */
   /*  the label <ddname>.                                        */
   /*                                                             */
   /*  Examples                                                   */
   /*                                                             */
   /*   JCL.C1Stage.FindTxt.1 = 'CLASS=P'                         */
   /*   JCL.C1Stage.Replace.1 = 'CLASS=T'                         */
   /*                                                             */
   /*   JCL.C1Stage.FindTxt.2 = ' PEND '                          */
   /*   JCL.C1Stage.where.2 = 'AFTER'                             */
   /*   JCL.C1Stage.Insertx.2 = '//START  EXEC PGM=IEFBR14'       */
   /*                                                             */
   /*   JCL.C1Stage.REPLACE.STEPLIB.STEP1 = 'WALJO11.LOADLIB'     */
   /*   JCL.C1Stage.REPLACE.STEPLIB.STEP2 = ,                     */
   /*                 '//     DD DISP=SHR,DSN=WALJO11.LOADLIB     */
   /*                                                             */
   /*                                                             */
   /*----------------------------------------------------------*/
   Trace Off
/* Is TEST#JOB allocated? If yes, then turn on Trace  */
   isItThere = ,
     BPXWDYN("INFO FI(TEST#JOB) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then TraceRc = 'Y'

   ARG C1Element C1Stage ,
       WaitLoops LoopSeconds TestResultsHLQ ;

   If Length(TestResultsHLQ) > 21 then,
      Do
      Say 'The TestResultsHLQ length must be 21 characters or less'
      Say TestResultsHLQ 'is' Length(TestResultsHLQ) 'characters long'
      Exit(12)
      End

   /* Set Defaults / initial values....                        */

   /* Set the value for Phase that indicates job is done       */
   FinalExpectedPhase = "AWAITING OUTPUT"

   $numbers   = '0123456789'   /* chars for numeric values   */
   AlphaChars   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
   $OptionCommentChar = '*'
   $EndevorVariables  = ''
   ShowReplaceResults = 'Y'

   /*   Select a Default for the SUPERC parameter.             */
   /* Set defaults                   */
   JCL.                = ''

   Drop MaxReturnCode
   JCL.C1Stage.MaxReturnCode = 4     /* Value for MaxReturncode */
   JCL.C1Stage.where.  = 'AFTER'     /* either BEFORE/AFTER */
   JCL.C1Stage.FindTxt. = ''
   JCL.C1Stage.REPLACE. = ''
   JCL.C1Stage.Insertx. = ''
   SuperCRc = 0
   Drop Baseline
   JCL.C1Stage.BASELINE = ' '        /* Name of C1stage Baseline*/

   /* Default replacment strings to keep in the output results */
   NeutralizeMasks = 'JOB99999 D9999999 99.99.99 ',
                     'SYS99999 T999999 ',
                     '99:99 9999999.9999'
   Superc_Parms = 'DELTAL,LINECMP'
   Superc_Parms = 'LONGL,LINECMP'
   Superc_Parms = 'LONGL,LINECMP,WIDE'

   NumberReplaceStrings = 0   ; /* Assume zero, unless we find some*/
   NumberMaskStrings    = 0   ; /* Assume zero, unless we find some*/

   Say 'Automated Testing is examining details for '
   Say 'Element ' C1Element 'at stage ' C1Stage

   /* Get   Options for tailoring and processing the JCL       */
   /* If no Options are designated for C1stage, then exit      */
   Call ProcessInputOptions;

   /* If ShowReplaceResults not = 'Y' then notify msgs are off */
   If ShowReplaceResults /= 'Y' then,
      Say 'FindTxt-Replace messages are turned off via',
          ' ShowReplaceResults'

   /* If Baseline specified at Stage level use it.     */
   If TraceRc = 'Y' then Trace r
   Drop Baseline
   thisBaseline = JCL.C1Stage.BASELINE

   /* If MaxReturnCode given at Stage level use it.     */
   Drop MaxReturncode
   thisMaxReturncode = JCL.C1Stage.MaxReturnCode
   If Verify(thisMaxReturncode,$numbers) > 0 then,
      thisMaxReturncode = 4;

   /* Using Options tailor the JCL so it can be Submitted      */
   Call TailorNewJCLfromOld;

   /* Get Dataset name for new JCL - to be submitted           */
   $rslt =  LISTDSI("NEWJCL" "FILE")
   If $rslt = 0 then SubmitJCL = sysdsname
   Else,
      Do
      Say 'NEWJCL must be a cataloged dataset'
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
      Say 'The job to be monitored is mine. Invalid request'
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
   Say 'Test Results captured into' thisTestResult

   /* Create a Relate for output results */
   Push "RELATE OBJECT '"thisTestResult"'."

   /* If a Baseline for comparison is not named, search for former */
   If thisBaseline = ' ' then,
      Call Locate_Former_TestResults;

   /* If we have something to compare        */
   /* and thisMaxReturncode < 999 then compare.. */
   if thisMaxReturncode >= 999 then,
      Say 'MaxReturnCode at Stage' C1Stage 'is' thisMaxReturncode'.',
          ' The comparison of results is being skipped.'
   Else,
   if thisBaseline /= ' ' & thisMaxReturncode < 999 then,
      Do
      Say 'Comparing' thisTestResult
      Say '       to' thisBaseline
      Call CompareTestResults;
      If thisBaseline /= ' ' then,
         Push "RELATE OBJECT '"thisBaseline"'."
      End

   "EXECIO" QUEUED() "DISKW RELATE (Finis"

   If SuperCRc > thisMaxReturncode then,
      Do
      Say 'Comparison Fails. SUPERC rc='SuperCRc
      Exit(8)
      End

   Say 'Comparison is successful. SUPERC rc='SuperCRc
   Exit(1); /* Submitted a Successful test */

ProcessInputOptions:

   /* Read the OPTIONS (each value must be quoted) */
   x = IncludeQuotedOptions(OPTIONS)
   If ShowReplaceResults = 'Y' then,
      Say 'NumberReplaceStrings=' NumberReplaceStrings

   If NumberReplaceStrings = 0 then,
      Do
      Say 'No Automated Test instructions are found for ',
          C1Element 'in stage' C1Stage
      Exit(0) ; /* No tests to submit      */
      End

   If ShowReplaceResults = 'Y' then,
      Say 'NumberMaskStrings   =' NumberMaskStrings

   /* Read the VARIABLE data (variables provided by Endevor) */
   /* Variables can be mixture of C1* variables  of Endevor, */
   /* processor variables and Site Symbol variables.         */
   x = IncludeQuotedOptions(VARIABLE)
   If ShowReplaceResults = 'Y' then,
      Say 'Number Endevor Variables =' Words($EndevorVariables)

   Return;

TailorNewJCLfromOld:

   /* Read the OLDJCL file           */
   "EXECIO * DISKR OLDJCL ( Stem jclrec. Finis"
   /* Scan each record of the JCL    */
   Do j# = 1 to jclrec.0
      jclline = jclrec.j#
      thisJCLlineQueued = 'N'
      /* Determine the Stepname */
      If Pos(' EXEC ',jclline) > 0 &,
         Substr(jclline,1,2)  = '//' &,
         Substr(jclline,3,1)  > '*' then,
            thisStepName = Word(Substr(jclline,3),1)
      /* Determine whether we are looking at a DDNAME */
      If Substr(jclline,1,2)  = '//' &,
         Substr(jclline,3,1)  > '*' then,
         Do
         thisDDname   = Word(Substr(jclline,3),1)
         /* Is there an override for this DDNAME or DDNAME.STEP */
         newDDnameJcl = ''
         newDDnameJcl= JCL.C1Stage.REPLACE.thisDDname.thisStepName;
         if newDDnameJcl = '' then,
            newDDnameJcl= JCL.C1Stage.REPLACE.thisDDname.
         If newDDnameJcl /= '' then,
            Do; Call ReplaceDDname; Iterate; end;
         End

      If TraceRc = 'Y' then Trace r
      jclline = jclrec.j#

      /* Execute the Search and replace string actions */
      /*  If TraceRc = 'Y' then Trace r  */
      Do rpl# = 1 to NumberReplaceStrings
         findString = JCL.C1Stage.FindTxt.rpl#
         If findString = '' then iterate;
         whereTxt = Pos(findString,jclline)
         If whereTxt = 0 then iterate;
         replaceString = JCL.C1Stage.Replace.rpl#
         If replaceString /= '' then,
            Do
            Call ReplaceText;
            Call ReplaceEndevorVariables;
            End /* If replaceString /= '' */
         Else,
            Do
            insertJclLines = JCL.C1Stage.Insertx.rpl#
            If insertJclLines /= '' then,
               Do
               insertWhere  = JCL.C1Stage.where.rpl#
               If insertWhere /= 'BEFORE' then,
                  insertWhere = 'AFTER'
               If ShowReplaceResults = 'Y' then,
                  Say 'Inserting JCL lines' insertWhere,
                   findString
               If insertWhere = 'AFTER' then,
                  Do
                  Queue jclline
                  thisJCLlineQueued = 'Y'
                  End
               Call InsertJclLines;
               End
            End /* else ..  If replaceString /= ''  */
      End; /* Do rpl# = 1 to NumberReplaceStrings */
      /* Write line of JCL to output                   */
      Trace off
      If thisJCLlineQueued /= 'Y' then,
         Do
         Call ReplaceEndevorVariables;
         Queue jclline
         End
   End; /* Do j# = 1 to jclrec.0  */

   "EXECIO" QUEUED() "DISKW NEWJCL ( Finis"

   Return;

IncludeQuotedOptions:
/* (this routine is tailored from a 2021 version of ENBPIU00)         */
/* Options built by others might not be trustworthy.                  */
/* Use this routine in such conditions to interpret only those that   */
/* have values contained in quotes, or values that are numeric.       */
   Arg $UserOptDDname;

   /*  Process only quoted Rexx assignment statements from User */
   $USROPTS = STRIP($UserOptDDname) ;
   /*  Already Read this OPtions file as input ?                */
   $options# = WordPos($USROPTS,$List_Read_Options)

   If $options# = 0 then,
      Do
      $List_Read_Options = $List_Read_Options $USROPTS ;
      $options# = WordPos($USROPTS,$List_Read_Options)
      "EXECIO * DISKR" $USROPTS "(Stem $Opts."$options#". Finis"
      IF RC > 8 THEN,
         DO
         SAY 'Cannot find OPTIONS File ' $USROPTS
         EXIT(12)
         END;
      End; /* if $options# = 0 then */

   /*  Process only quoted Rexx assignment statements from User */
   DO $Uop# = 1 TO $Opts.$options#.0
      $UserOption = STRIP($Opts.$options#.$Uop#) ;
      IF SUBSTR($UserOption,1,1) = $OptionCommentChar then ITERATE ;
      If Words($UserOption) < 1                   then ITERATE ;
      Do 20;    /* Supporting only 20 quoted lines wi continuations */
         $lastchar = Substr($UserOption,Length($UserOption))
         If Pos($lastchar,',-+') = 0 then Leave;
         $UserOption = STRIP(STRIP($UserOption,'T',$lastchar))
         $lastchar = Substr($UserOption,Length($UserOption))
         $Uop# = $Uop# + 1
         $continueOption = STRIP($Opts.$options#.$Uop#) ;
         $firstchar = Substr($continueOption,1,1)
         If ($lastchar  = "'" | $lastchar  = "'") &,
             $firstchar = $lastchar then,
             $UserOption = Strip($UserOption,'T',$lastchar) ||,
                       Strip($continueOption,'L',$firstchar)
         Else,
             $UserOption = $UserOption $continueOption
      End /* Do 20 */

      If TraceRc = 'Y' then,
         Say '$UserOption' $Uop# '=' $UserOption

      PARSE VAR $UserOption $keyword '=' $UserOptionValue ;
      $UserOptionValue = Strip($UserOptionValue)
      sa= '$keyword =' $keyword
      Sa= '$UserOptionValue= ' $UserOptionValue

      $firstchar = Substr($UserOptionValue,1,1)
      $nextQuote = 0
      If ($firstchar = "'" | $firstchar = "'") then,
         $nextQuote = Pos($firstchar,$UserOptionValue,2)
      /* Only statements in acceptable format are iterpreted.  */
      /*        keyword = 'value'                              */
      /*        keyword = "value"                              */
      /*        keyword = <number>                             */
      $rslt =  VERIFY($UserOptionValue,$numbers)
      If $rslt = 0 then Nop;
      Else,
      if Words($keyword) /= 1 |,
         ($firstchar /= "'" & $firstchar /= "'") |,
         ($nextQuote /= Length($UserOptionValue)) then,
         Do
         If $nomessages = 'N' then,
            Say 'SUBMITST- Invalid to Interpret.',
                $UserOption ;
         Iterate ;
         End /* If Words.....   */

      If TraceRc = 'Y' then Say $UserOption

      Interpret $UserOption

      If Pos('JCL.'C1Stage'.FindTxt.',$keyword)    > 0 then,
         Do
         $tmp = Translate($keyword,' ','.');
         $tmpNumber = Word($tmp,Words($tmp));
         $rslt =  VERIFY($tmpNumber,$numbers)
         If $rslt = 0 & $tmpNumber > NumberReplaceStrings then,
            NumberReplaceStrings = $tmpNumber;
         End;
      Else,
      If Pos('JCL.'C1Stage'.MaskTarget.',$keyword) > 0 then,
         Do
         $tmp = Translate($keyword,' ','.');
         $tmpNumber = Word($tmp,Words($tmp));
         $rslt =  VERIFY($tmpNumber,$numbers)
         If $rslt = 0 & $tmpNumber > NumberMaskStrings then,
            NumberMaskStrings    = $tmpNumber;
         End;
      Else,
      If Pos('.',$keyword) = 0 &,
         wordpos($keyword,$EndevorVariables) = 0 then,
         $EndevorVariables = $EndevorVariables $keyword ;
   End /* DO $Uop# = 1 TO $Opts.$options#.0 */

   RETURN $UserOptDDname


ReplaceDDname:

/* If  TraceRc = 'Y'    then Trace r  */
   If ShowReplaceResults = 'Y' then,
      Say 'Replace the Step' thisStepName 'DDname' thisDDname 'with:'
   Label = thisDDname
   leadingSlashSlash = Pos('//',newDDnameJcl)
   If leadingSlashSlash =0 then, /* no // in replacement */
      Do w# = 1 to Words(newDDnameJcl)
      JCLtext = Word(newDDnameJcl,w#)
      insertJclLines = '//'Label ' DD DSN='JCLtext || ','
      Call InsertJclLines ;
      Queue            '//         DISP=SHR'
      Label = '       '
      End /* Do w# = 1 to Words(newDDnameJcl) */
   Else,
   If leadingSlashSlash = 1 then, /* Yes // in replacement */
      Do Forever
      whereNextSlashSlash = Pos('//',newDDnameJcl,3)
      If whereNextSlashSlash = 0 then,
         whereNextSlashSlash = Length(newDDnameJcl) + 1
      JCLtext = Substr(newDDnameJcl,1,whereNextSlashSlash-1)
      insertJclLines = JCLtext
      Call InsertJclLines ;
      newDDnameJcl =,
            Strip(Substr(newDDnameJcl,whereNextSlashSlash))
      If length(newDDnameJcl) < 1 then Leave;
      End /* Do Forever */
   Else,
      Do
      Say 'Unsupported DDName replacment text is found- '
      Exit(12)
      End /* Else */

   j# = j# +1;
   Call SkiptoNextLabel;

   Return

SkiptoNextLabel:

   SkipThirdChars = ' *'
   /* Find next JCL line with a label in position 3 */
   Do forever
      if j# > jclrec.0 then Leave;
      jclline = jclrec.j#
      ThirdChar = Substr(jclline,3,1)
      if Substr(jclline,1,2) = '//' &,
         Pos(ThirdChar,SkipThirdChars) = 0 then,
            DO
            j# = j# -1 ;
            Leave;
            End;
      j# = j# +1 ;
   End; /*  Do forever  */

   Return

ReplaceText:

   Saved_jclline = jclline;
   If whereTXT = 1 then,
      jclline = replaceString || ,
                substr(jclline,whereTXT+Length(findString))
   Else,
      jclline = substr(jclline,1,(whereTXT-1)) ||,
                replaceString || ,
                substr(jclline,whereTXT+Length(findString))

   If ShowReplaceResults = 'Y' then,
      Do
      Say "JCL line Changed:"
      Say " B4:"Saved_jclline
      Say " AF:"jclline
      End

   Return

ReplaceEndevorVariables:

   /* Use Endevor variables for Search and replace actions */
   Do ndvr# = 1 to Words($EndevorVariables)
      ndvrVariable = Word($EndevorVariables,ndvr#)
      findString = '&' || Word($EndevorVariables,ndvr#)
      whereTxt = Pos(findString,jclline)
      If whereTxt = 0 then iterate;
      replaceString = Value(ndvrVariable)
      If replaceString /= '' then,
         Call ReplaceText;
   End; /*  Do ndvr# = 1 to Words($EndevorVariables) */

   Return

InsertJclLines:

   /* Apply Search and Replace actions to inserted lines */
   Save_jclline = jclline;
   jclline = insertJclLines
   Call ReplaceEndevorVariables;
   Do rpl# = 1 to NumberReplaceStrings
      findString = JCL.C1Stage.FindTxt.rpl#
      whereTxt = Pos(findString,jclline)
      If whereTxt = 0 then iterate;
      replaceString = JCL.C1Stage.Replace.rpl#
      If replaceString /= '' then,
         Call ReplaceText;
   End ;  /*Do rpl# = 1 to NumberReplaceStrings */

   insertJclLines = jclline   /* line(s) to be inserted         */
   jclline = Save_jclline     /* The line that triggered insert */

   leadingSlashSlash = Pos('//',insertJclLines)

   If leadingSlashSlash = 1 then, /* Yes // in new jcl lines */
      Do Forever
      whereNextSlashSlash = Pos('//',insertJclLines,3)
      If whereNextSlashSlash = 0 then,
         whereNextSlashSlash = Length(insertJclLines) + 1
      JCLtext = Substr(insertJclLines,1,whereNextSlashSlash-1)
      If ShowReplaceResults = 'Y' then,
         Say JCLtext
      queue JCLtext
      insertJclLines =,
            Strip(Substr(insertJclLines,whereNextSlashSlash))
      If length(insertJclLines) < 1 then Leave;
      End /* Do Forever */
   Else,
      Do
      Say 'Unsupported DDName replacment text is found- '
      Exit(12)
      End /* Else */


   Return

Submit_n_save_jobInfo: /* submit SubmitJCL job and save job info */

   Address TSO "PROFILE NOINTERCOM"     /* turn off msg notific      */
   CALL MSG "ON"
   CALL OUTTRAP "out."
   ADDRESS TSO "SUBMIT '"SubmitJCL"("C1Element")'" ;
   If RC > 4 then,
      Do
      Say 'Cannot find Element member to submit.'
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
      Say "Failure with isfcalls"
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
        say "RC" RC "returned from ISFEXEC ST" ;
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

           Say 'Status:' SelectJobname SelectJobNumber ,
               'retcode.i=' retcode.i thisJobPhase,
               ' on ' i 'wait loop'
           If thisJobPhase = FinalExpectedPhase |,
              thisEndTime > "00:00:00.00" then Leave;
           End;  /* if jobid.i = SelectJobNumber */
      End;  /*Do i = 1 to StRows */
      If thisJobPhase = FinalExpectedPhase |,
         thisEndTime > "00:00:00.00" then Leave;
      Say 'At' TIME(),
          'Waiting for job'  SelectJobname SelectJobNumber,
           thisJobPhase;
      call WaitAwhile;
   End;  /* Do Waitloops */

   If thisJobPhase = FinalExpectedPhase |,
      thisEndTime > "00:00:00.00" then,
      Do
      Say 'Job' SelectJobname SelectJobNumber 'is completed',
          ' at ' DATE(S) TIME()
      End
   Else,
      Do
      Say 'Job' SelectJobname SelectJobNumber,
          ' not completed within Wait arguments',
          WaitLoops LoopSeconds
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
           say "SYSOUT allocation failed for" JobName "with RC" ActRC
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
   MyRC =RC

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
      Say 'There is no former output to compare'

   "FREE  F(SYSPRINT)"
   "FREE  FI(SYSIN)"

   Return

CompareTestResults:

/* If TraceRc = 'Y' then trace r */
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

/* If TraceRc = 'Y' then trace r */

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
          Say 'Applying user MaskTarget and MaskColum pairs to',
              ' test results'
       Do msk# = 1 to NumberMaskStrings
          thisMaskTarget = JCL.C1stage.MaskTarget.msk# ;
          thisMaskColumn = JCL.C1stage.MaskColumn.msk# ;
          if thisMaskTarget > '' &,
             thisMaskColumn > 0 then,
                Call MaskOutputString;
       End /* Do msk# = 1 to NumberMaskStrings */
      End /* If NumberMaskStrings > 0         */
   Trace off

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
   Trace off

   Return

