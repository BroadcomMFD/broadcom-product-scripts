/*   rexx    */
   /* Make CAST actions always be batch...                     */

   /* Values to be set for your site......                     */
     /* Build a JCL model, and name its location here....        */
   CastPackageModel = 'SYSMD32.NDVR.TEAM.MODELS(CASTPKGE)'
     /* Name a work dataset to be created then deleted...        */
   CastPackageJCL   = USERID()".C1UEXTR7.SUBMIT"

   /* If wanting to limit the use of this exit, uncomment...   */
   If USERID() /= 'IBMUSER' then exit

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

   Arg Parms
   sa= 'Parms len=' Length(Parms)
   MyRc = 0

   /* If C1UEXTR7 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) /= ' ' then Trace ?r

   /* Parms from C1UEXT07 is a string of REXX statements   */
   Interpret Parms

   /* Only run if a CAST is being done                     */
   If PECB_FUNCTION_LITERAL /= 'CAST' then Exit

   Message = ''
   MessageCode = '    '

   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRc = 1

   Sa= 'You called C1UEXTR7 '

   If PECB_MODE = "T" then,       /* TSO foreground  */
      Do
      Call SubmitBatchCAST
      Exit
      End

   /* Enforce packages to be Backout Enabled              */
   IF PREQ_BACKOUT_ENABLED /= 'Y' then,
      Do
      Message = 'Package made to be Backout enabled'
      MyRc        = 4
      hexAddress = D2X(Address_PREQ_BACKOUT_ENABLED)
      storrep = STORAGE(hexAddress,,'Y')
      Call SetExitReturnInfo
      End;

   Exit

SubmitBatchCAST:

   "ALLOC F(CASTPKGE) DA('"CastPackageModel"') SHR REUSE"
   "Execio * DISKR CASTPKGE (Stem jcl. Finis"
   "FREE  F(CASTPKGE)"
   jcl.1 = Overlay(USERID(),jcl.1,3)
   "ALLOC F(SUBMTJCL) DA('"CastPackageJCL"') ",
          "LRECL(80) BLKSIZE(16800) SPACE(5,5)",
          "RECFM(F B) TRACKS ",
         "MOD CATALOG REUSE "     ;
   "Execio * DISKW SUBMTJCL (Stem jcl. "

   /* Push Cast command (in reverse order).  */
   If PREQ_PKG_CAST_COMPVAL = 'Y' then,
      PUSH  '    OPTION VALIDATE COMPONENTS .'
   Else,
   If PREQ_PKG_CAST_COMPVAL = 'W' then,
      PUSH  '    OPTION VALIDATE COMPONENT WITH WARNING .'
   Else,
      PUSH  '    OPTION DO NOT VALIDATE COMPONENT .'
   PUSH  "  CAST PACKAGE '" || PECB_PACKAGE_ID || "'"
   "Execio 2 DISKW SUBMTJCL ( finis"

   Call Submit_n_save_jobInfo ;
   "FREE  F(SUBMTJCL) DELETE "
   Message = JobData
   MyRc        = 8
   PACKAGE = PECB_PACKAGE_ID
   MessageCode = 'U033'
   Call SetExitReturnInfo

   Return;

Submit_n_save_jobInfo: /* submit CastPackageModel job and save job info */

   If TraceRc = 1 then Say 'Submit_n_save_jobInfo:'

   Address TSO "PROFILE NOINTERCOM"     /* turn off msg notific      */
   CALL MSG "ON"
   CALL OUTTRAP "out."
   ADDRESS TSO "SUBMIT '"CastPackageJCL"'" ;
   If RC > 4 then,
      Do
      MyRC = 8
      Message = 'Cannot find Element member to submit.'
      Call SetExitReturnInfo
      Exit(12)
      End
   CALL OUTTRAP "OFF"
   Address TSO "PROFILE INTERCOM"       /* turn on  msg notific      */

   JobData   = Strip(out.1);
   jobinfo         = Word(JobData,2) ;
   If jobinfo = 'JOB' then,
      jobinfo   = Word(JobData,3) ;
   SelectJobName   = Word(Translate(jobinfo,' ',')('),1) ;
   SelectJobNumber = Word(Translate(jobinfo,' ',')('),2) ;

   Return;

SetExitReturnInfo:

   If TraceRc = 1 then Say 'SetExitReturnInfo:    '

   hexAddress = D2X(Address_PECB_MESSAGE)
   storrep = STORAGE(hexAddress,,Message)
   hexAddress = D2X(Address_PECB_ERROR_MESS_LENGTH)
   storrep = STORAGE(hexAddress,,'0084'X)
   hexAddress = D2X(ADDRESS_PECB_MODS_MADE_TO_PREQ)
   storrep = STORAGE(hexAddress,,'Y')

   If MessageCode /= '    ' then,
      Do
      hexAddress = D2X(Address_PECB_MESSAGE_ID)
      storrep = STORAGE(hexAddress,,MessageCode)
      End


/* Set the return code for the exit                */
/*  for PECB-NDVR-EXIT-RC                          */
   hexAddress = D2X(Address_PECB_NDVR_EXIT_RC)
   If MyRc = 4 then,
      storrep = STORAGE(hexAddress,,'00000004'X)
   Else,
      storrep = STORAGE(hexAddress,,'00000008'X)

   RETURN ;

