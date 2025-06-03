/*  REXX    */
   /*----------------------------------------------------------*/
   /*  This Rexx is given a JCL dataset and member name in its */
   /*  parameter.                                              */
   /*  The REXX:                                               */
   /*      o submits the JCL                                   */
   /*      o watches and waits for it to complete its execution*/
   /*      o returns to caller                                 */
   /*                                                          */
   /*----------------------------------------------------------*/
   CALL BPXWDYN 'INFO DD(SUBMITST)'
   If  RESULT = 0 Then Trace ?R
   Arg SubmitJCL WaitLoops LoopSeconds;

   /* Set the value for Phase that indicates job is done       */
   FinalExpectedPhase = "AWAITING OUTPUT"

   /*----------------------------------------------------------*/
   /* Get my jobname....  Cannot wait for myself               */
   /* Ensure the job we submit does not have the same jobname  */
   /* as my own.                                               */
   /*----------------------------------------------------------*/
   myJobName = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */

   /* Submit the JCL named in the parameter                    */
   Call Submit_n_save_jobInfo;
   If SelectJobName = myJobName then,
      Do
      Say 'The job to be monitored is mine. Invalid request'
      Exit(8)
      End;

   /* Wait for the submitted job to finish                     */
   jobnum =  SelectJobNumber
   jobid  =  SelectJobName
   ownerid = USERID()
   retcode. = ' '
   daten.   = ' '
   Timen.= ' '
   PhaseName. = ' '
   Call Monitor_Job_Status;

   exit

Submit_n_save_jobInfo: /* submit SubmitJCL job and save job info */

   Address TSO "PROFILE NOINTERCOM"     /* turn off msg notific      */
   CALL MSG "ON"
   CALL OUTTRAP "out."
   ADDRESS TSO "SUBMIT '"SubmitJCL"'" ;
   CALL OUTTRAP "OFF"
   JobData   = Strip(out.1);
   jobinfo         = Word(JobData,2) ;
   If jobinfo = 'JOB' then,
      jobinfo   = Word(JobData,3) ;
   SelectJobName   = Word(Translate(jobinfo,' ',')('),1) ;
   SelectJobNumber = Word(Translate(jobinfo,' ',')('),2) ;

   Return;

Monitor_Job_Status:

   IsfRC = isfcalls( "ON" )
   if IsfRC <> 0 then Exit(8)

   myMessage = ' ';
   isfprefix = SelectJobname
   isfowner = USERID()
   isfcols = "jname jobid ownerid queue jclass prtdest retcode",
             " daten TIMEN PHASENAME "

   seconds = LoopSeconds /* Number of Seconds to wait if needed */

   /*********************************************/
   /* Wait until the submitted job is completed */
   /*********************************************/
   Do loop# = 1 to WaitLoops
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
        say "No rows returned from ISFEXEC"
        Call WaitAwhile
        Iterate ;
        end;

      SubmittedJobPhase = 'Submitted'
      Call  EvaluateSubmittedJob
      If SubmittedJobPhase = FinalExpectedPhase then Leave;

      Call WaitAwhile

   End;  /* Do loop# = 1 to WaitLoops */

   If SubmittedJobPhase /= FinalExpectedPhase then,
      Do
      Say 'Job' SelectJobname SelectJobNumber,
          ' not completed within Wait arguments',
          WaitLoops LoopSeconds
      exit(8)
      End

   Say 'Job' SelectJobname SelectJobNumber 'is completed',
       ' at ' DATE(S) TIME()

   Return;

EvaluateSubmittedJob:

   Do row# = 1 to StRows
     Sa= 'Finding' jname.row# jobid.row# ownerid.row#,
         jclass.row# PhaseName.row# Timen.row#
     if jobid.row# /= SelectJobNumber then iterate;

     SubmittedJobPhase = PhaseName.row#
     Sa= 'Status:' SelectJobname SelectJobNumber ,
         'retcode.row#=' retcode.row# SubmittedJobPhase ,
         ' on ' row# 'wait loop'
     Leave;
   End;  /*Do row# = 1 to StRows */

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

