/*   rexx    */
/* Perform various Package actions in REXX                          */
/*                                                                  */
/* A   COBOL exit CALLS this REXX and provides values for           */
/* REXX variables, including these.                                 */
/* Find documentation on these in the TechDocs documentation        */
/* where each underscore appears as a dash in the documentation.    */
/* For example, PECB_PACKAGE_ID is documented as                    */
/*              PECB-PACKAGE-ID                                     */
/*                                                                  */
/* PECB_PACKAGE_ID               PAPP_GROUP_NAME                    */
/* PECB_FUNCTION_LITERAL         PAPP_ENVIRONMENT                   */
/* PECB_SUBFUNC_LITERAL          PAPP_QUORUM_COUNT                  */
/* PECB_BEF_AFTER_LITERAL        PAPP_APPROVER_FLAG                 */
/* PECB_USER_BATCH_JOBNAME       PAPP_APPR_GRP_TYPE                 */
/* PREQ_PKG_CAST_COMPVAL         PAPP_APPR_GRP_DISQ                 */
/* PHDR_PKG_SHR_OPTION           PAPP_SEQUENCE_NUMBER               */
/* PHDR_PKG_ENV                                                     */
/* PHDR_PKG_STGID                                                   */
/*     Address fields are provided for fields that may be           */
/*     modified by the REXX.                                        */
/* Address_PECB_MESSAGE          Address_MYSMTP_SUBJECT             */
/* Address_MYSMTP_MESSAGE        Address_MYSMTP_TEXT                */
/* Address_MYSMTP_USERID         Address_MYSMTP_URL                 */
/* Address_MYSMTP_FROM           Address_MYSMTP_EMAIL_IDS           */
/* MYSMTP_EMAIL_IDS              MYSMTP_EMAIL_ID_SIZE               */
/*                                                                  */
   /* Values to be set for your site......                     */
   /* For package REVIEW  (APPROVE/DENY).....                  */
   /*   Enter location of Approver Group sequencing   ...      */
   ApproverGroupSequence= 'YOURSITE.NDVR.PARMLIB(APPROVER)'

   /* Do you want all CAST actions to be peformed in Batch?    */
   Force_CAST_in_Batch = 'Y' ; /*  Y/N   */
   Force_CAST_in_Batch = 'N' ; /*  Y/N   */

   /* If wanting to limit the use of this exit, uncomment...        */
   If USERID() /= 'IBMUSER' then exit

   /* If wanting to send email, use these variables with            */
   /* designated maximum lengths. The Rexx will put them            */
   /* into their proper places.                                     */
   /*                                                               */
   /* Variable            Description                       max-Len */
   /*                                                               */
   /* MySMTP_Message      Email Message                       80    */
   /* MySMTP_From         Email From name                     50    */
   /* MySMTP_Subject      Email Subject                       50    */
   /* MySMTP_textline.1   Text line in email                 133    */
   /* MySMTP_textline.2         "                            133    */
   /* MySMTP_textline.nn     up to 99                        133    */
   /* MySMTP_textline.0   Number Text lines used (max 99)      2    */
   /* MySMTP_URL          Y/N                                  1    */
   /* MYSMTP_EMAIL_IDS    List of space delimited userids   *Exit   */
   /*                The COBOL exit OCCURS clause determines /      */
   /* In case these are not already allocated, these are attempted  */
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

   /* Parms are REXX statements passed from COBOL exit              */
   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)

   /* If C1UEXTR7 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) /= ' ' then TraceRQ = 'Y'

   If TraceRQ = 'Y' then,
      Say 'C1UEXTR7 is called again:'

   /* Parms from C1UEXT07 is a string of REXX statements   */

   Interpret Parms
   If TraceRQ = 'Y' & PECB_MODE = 'B' then Trace r

   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRQ = 'Y'

   If TraceRQ = 'Y' then,
      Do
      Trace ?r
      Sa= 'CALL_REASON           = '    CALL_REASON
      Sa= 'PECB_FUNCTION_LITERAL = '    PECB_FUNCTION_LITERAL
      Sa= 'PECB_SUBFUNC_LITERAL  = '    PECB_SUBFUNC_LITERAL
      Sa= 'PECB_BEF_AFTER_LITERAL= '    PECB_BEF_AFTER_LITERAL
      Sa= 'PECB_PACKAGE_ID       = '    PECB_PACKAGE_ID
      Sa= 'MYSMTP_EMAIL_ID_SIZE  = '    MYSMTP_EMAIL_ID_SIZE
      End

   /* Initialize variables....                             */
   Message = ''
   MessageCode = '    '
   MyRc = 0

   /* Validate Package prefix with ServiceNow              */
   If PECB_FUNCTION_LITERAL  ='CREATE'   &,
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,
      Substr(PECB_PACKAGE_ID,1,3) = 'PRB'           then,
      Do
      Call Validate_PackageID
      If MyRc > 0 then Exit
      End

   /* Enforce packages to be Backout Enabled              */
   IF PREQ_BACKOUT_ENABLED /= 'Y' then,
      Do
      Message = 'Package made to be Backout enabled'
      MyRc        = 4
      hexAddress = D2X(Address_PREQ_BACKOUT_ENABLED)
      storrep = STORAGE(hexAddress,,'Y')
      Call SetExitReturnInfo
      Exit
      End;

   If PECB_FUNCTION_LITERAL  ='CAST'     &,
      PECB_SUBFUNC_LITERAL   ='CAST'     &,
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,
      PECB_MODE = "T" &,          /* TSO foreground  */
      Force_CAST_in_Batch = 'Y' then,
      Call SubmitBatchCAST
   Else,
   If PECB_FUNCTION_LITERAL  ='CAST'     &,
      PECB_SUBFUNC_LITERAL   ='CAST'     &,
      PECB_BEF_AFTER_LITERAL ='AFTER'    then,
      Call ManageEmails    ;

   Exit

ManageEmails:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'ManageEmails'

   /* Only run if the exit is giving us an Approver Group  */
   If Substr(CALL_REASON,1,16) = 'APPROVER GROUP #' then,
      Do
      Call SaveOffApproverGrpInfo
      Return
      End

   /*****************************************************************/
   /* Initializaztion and Example statements                        */
   /*****************************************************************/
   MySMTP_Message =,
       'YOURSITE.YOUR.NDVR.NODES1.CLSTREXX(C1UEXTR7)'
   MySMTP_Subject = 'Please Approve Package' PECB_PACKAGE_ID
   MySMTP_From = Left('YOURSITE your testing Endevor',50)
   MySMTP_textline.1  = 'Package' PECB_PACKAGE_ID,
                           ' has been CAST and is ready for APPROVAL.'
   MySMTP_textline.2  = 'Your Review and approval of package',
                            PECB_PACKAGE_ID 'is reqested.'
   MySMTP_textline.3  = ' '
   MySMTP_textline.4  = ' '
   MySMTP_textline.0  = 4
   MYSMTP_EMAIL_IDS   = ''

   /* Only run if the exit says all Approver Grps are done */
   If Substr(CALL_REASON,1,22) = 'NO MORE APPROVER GRPS ' then,
      Do
      Call CheckApproverGroupSequence
      Return
      End

   Return

Validate_PackageID:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'Validate_PackageID'
   /* build  STDENV input  */
   CALL BPXWDYN ,
      "ALLOC DD(STDENV) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",
             " RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
   Queue "EXPORT PATH=$PATH:" ||,
         "'/usr/lpp/IBM/cyp/v3r11/pyz/lib/python3.11/'"
   Queue "EXPORT VIRTUAL_ENV=" ||,
         "'/u/users/NDVRTeam/venv/lib/python3.11/site-packages/'"
   "EXECIO 2 DISKW STDENV (finis"

   /* build  BPXBATCH inputs and outputs */
   /* build  STDPARM input */
   CALL BPXWDYN ,
      "ALLOC DD(STDPARM) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",
             " RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
   Queue "sh cd " ||,
         "/u/users/NDVRTeam/venv/lib/python3.11/site-packages;"
   Queue "python ServiceNow.py" Substr(PECB_PACKAGE_ID,1,10)
   "EXECIO 2 DISKW STDPARM (finis"

   CALL BPXWDYN ,
      "ALLOC DD(STDOUT) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",
             " RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
   Notnow =,
      "ALLOC DD(STDOUT) DA('IBMUSER.STDOUT') OLD REUSE "

   CALL BPXWDYN ,
      "ALLOC DD(STDERR) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",
             " RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
   Notnow =,
      "ALLOC DD(STDERR) DA(*) SHR REUSE"

   CALL BPXWDYN "ALLOC DD(STDIN)  DUMMY SHR REUSE"
   CALL BPXWDYN "ALLOC DD(STDERR) DA(*) SHR REUSE"

   ADDRESS LINK 'BPXBATCH'
   CallRC = RC

   "EXECIO * DISKR STDOUT (Stem stdout. finis"
   lastrec#   = stdout.0
   lastrecord = Substr(stdout.lastrec#,1,40)

   If Pos("Exists",lastrecord) = 0 then,
      Do
      Message = 'C1UEXTR7 - Package prefix' PECB_PACKAGE_ID ||,
                ' is not defined to Service-Now'
      MessageCode = 'U033'
      MyRc        = 8
      Call SetExitReturnInfo
      End

   If CallRC = 0 then,
      Do
      CALL BPXWDYN "FREE  DD(STDENV) "
      CALL BPXWDYN "FREE  DD(STDPARM)"
      CALL BPXWDYN "FREE  DD(STDOUT) "
      CALL BPXWDYN "FREE  DD(STDIN)  "
      CALL BPXWDYN "FREE  DD(STDERR) "
      End

   Return;

SaveOffApproverGrpInfo:

   If TraceRQ = 'Y'             then Trace ?R
   PAPP_SEQUENCE_NUMBER = Substr(CALL_REASON,17,4)
   numberQueued =  QUEUED()
   If PAPP_SEQUENCE_NUMBER = "0001" & numberQueued > 0 then,
      Do numberQueued       /* Clear out whatever is queued */
         pull leftovers
      End
   If PAPP_SEQUENCE_NUMBER = "0001" then,
      CALL BPXWDYN ,    /* save Approver group data */
        "ALLOC DD(C1UEXTD7) LRECL(180) BLKSIZE(18000) SPACE(1,1) ",
          " RECFM(F,B) TRACKS ",
          " MOD UNCATALOG REUSE ";

   pkgGrp# = Strip(PAPP_SEQUENCE_NUMBER,'L','0')
   PAPP_GROUP_NAME = Strip(PAPP_GROUP_NAME)
   Queue 'pkgGrp#                = 'pkgGrp#
   Queue 'GROUP_NAME.pkgGrp#     ="'PAPP_GROUP_NAME'"'
   Queue 'ENVIRONMENT.pkgGrp#    ="'Strip(PAPP_ENVIRONMENT)'"'
   Queue 'APPR_GRP_TYPE.pkgGrp#  ="'Strip(PAPP_APPR_GRP_TYPE)'"'
   Queue 'APPR_GRP_DISQ.pkgGrp#  ="'Strip(PAPP_APPR_GRP_DISQ)'"'
   Queue 'APPROVAL_FLAGS.pkgGrp# ="'Strip(PAPP_APPROVAL_FLAGS)'"'
   Queue 'STATUS.'PAPP_GROUP_NAME '="'Strip(PAPP_APPROVER_FLAG)'"'
   Queue 'QUORUM.'PAPP_GROUP_NAME '='Strip(PAPP_QUORUM_COUNT,'L','0')
   Queue 'USRLST.'PAPP_GROUP_NAME '="'Strip(PAPP_APPROVAL_IDS)'"'

   numberQueued =  QUEUED()
   "EXECIO" numberQueued " DISKW C1UEXTD7 "

   Return;

CheckApproverGroupSequence:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'CheckApproverGroupSequence'

   /* If C1UEXTD7 is allocated to anything, we have approvers */
   WhatDDName = 'C1UEXTD7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) = ' ' then Return

   "EXECIO 0  DISKW C1UEXTD7 (Finis"
   "EXECIO *  DISKR C1UEXTD7 (Finis"
   CALL BPXWDYN "FREE  DD(C1UEXTD7)"
   numberQueued =  QUEUED()

   /* Analyze Exit-provided Approver Group info        */
   pkgGrp# = 0
   /* By default, ordered Approver Groups are not related  */
   STATUS.  = 'NotRelated'
   QUORUM.  = 0

   /* Return Approver Group info for this package       */
   Do q# = 1 to numberQueued
      Parse Pull something
      If TraceRQ = 'Y' then say "@187" something
      interpret something
   End;
   ThisEnvironment = ENVIRONMENT.pkgGrp#

   /* Read the site's required Approver Group sequencing  */
   CALL BPXWDYN,
     "ALLOC DD(APPROVER) DA('"ApproverGroupSequence"') SHR REUSE"
   "EXECIO * DISKR APPROVER (Stem ordered. Finis"
   CALL BPXWDYN "FREE DD(APPROVER)"

   /* Build a sequenced list of all named Approver Groups       */
   OrderedApproverGroups = ''
   /* Set a default value to be 1 greater than number of groups */
   NotOrdered   = ordered.0 + 1
   Sequence.    = NotOrdered
   Do ord# = 1 to ordered.0
      orderedEntry = ordered.ord#
      orderedEnv    = Word(orderedEntry,1)
      If orderedEnv /= thisEnvironment then iterate
      orderedApproverGroup = Word(orderedEntry,2)
      If orderedApproverGroup  = 'AllOthers' then,
         DefaultOrder = ord#
      SEQUENCE.orderedApproverGroup = ord#
      If TraceRQ = 'Y' then,
         say "@201 Sequence for" orderedApproverGroup "is" ord#
   End; /* Do ord# = 1 to ordered.0 */

   Sequence.NotOrdered = DefaultOrder
   unsorted_list      = ""
   /* Build a list of Approver Groups for this package    */
   PackageApproverGroups = ''
   Do p# = 1 to pkgGrp#
      PackageApproverGroup = GROUP_NAME.p#
      thisSequence = SEQUENCE.PackageApproverGroup
      entry = Right(thisSequence,4,'0') || '.' ||,
              PackageApproverGroup
      unsorted_list = unsorted_list entry
      If TraceRQ = 'Y' then,
         Say "unsorted_list=" unsorted_list
   End;

   Call SortApproverGroupList;

   If TraceRQ = 'Y' then say "@220 PackageApproverGroups =",
                              sorted_list,
                        ' ThisEnvironment ='  ThisEnvironment
   /* Go through the Sorted list    to identify the status  */
   /* of the next group(s) to be approved                   */
   /* Find the 1st Approver group this user belongs to....   */
   thisApprover = USERID()

   lastSequence = NotOrdered
   Do seq# = 1 to Words(sorted_list)
      entry = Word(sorted_list,seq#)
      Parse Var entry thisSequence '.' orderedApproverGroup
      orderedGroupStatus    = STATUS.orderedApproverGroup
      If orderedGroupStatus = 'APPROVED' then Iterate;
      orderedGroupQuorum    = QUORUM.orderedApproverGroup
      If orderedGroupQuorum = 0          then Iterate;
      If thisSequence > lastSequence     then,
         Do
         Say 'We need to wait'
         Leave;
         End;
      lastSequence = thisSequence
      ListApprovers = USRLST.orderedApproverGroup
      whereApprover = Wordpos(thisApprover,ListApprovers)
      thisApproversFlag = " "
      If whereApprover > 0 then,
         Do
         thisApproverGroup = orderedApproverGroup
         thisApproversFlag = Word(APPROVAL_FLAGS.grp#,whereApprover)
         End

      If TraceRQ = 'Y' then,
         Say orderedApproverGroup 'has status of' orderedGroupStatus,
          " Quorum" orderedGroupQuorum

      IF whereApprover > 0 &,
         orderedGroupStatus   /= 'NotRelated' then,
         say 'You must wait for the' orderedApproverGroup,
             " group's approval"

      If Words(ListApprovers) > 0 then,
        Do w# = 1 to Words(ListApprovers)
           Approver  = Word(ListApprovers,w#)
           If Wordpos(Approver,MYSMTP_EMAIL_IDS) = 0 &,
              Substr(Approver,1,1) > '00'X then,
              MYSMTP_EMAIL_IDS = MYSMTP_EMAIL_IDS Approver
        End; /* Do w# = 1 to Words(ListApprovers) */

   End; /* Do seq# = 1 to Words(sorted_list)           */

   /* Prepare email to the usrids in MYSMTP_EMAIL_IDS         */
   Call PrepareEmail

   Return;

SortApproverGroupList:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'SortApproverGroupList'
   say words(unsorted_list) unsorted_list;
   drop sorted_list;
   sorted_list = "";
   do forever ;
      if words(unsorted_list) = 0 then leave;
      lowest_entry = 1;
      do entry = 1 to words(unsorted_list)
         if word(unsorted_list,entry) <,
            word(unsorted_list,lowest_entry) then,
               lowest_entry = entry;
      end; /* do entry = 1 .... */
      sorted_list = sorted_list word(unsorted_list,lowest_entry);
      sa= "sorted_list=" sorted_list ;
      position = wordindex(unsorted_list,lowest_entry) ;
      len  = length(word(unsorted_list,lowest_entry));
      unsorted_list =,
         overlay(copies(" ",len),unsorted_list,position) ;
      sa= "unsorted_list=" unsorted_list ;
   end; /* do forever */
   drop unsorted_list;
   say words(sorted_list) sorted_list;

   Return;

PrepareEmail:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'PrepareEmail'
/* Here you can make last-moment adjustments to the email */
   shortlist = Substr(MYSMTP_EMAIL_IDS,1,100)
   If Substr(MYSMTP_EMAIL_IDS,100,1) /= ' ' &,
      Substr(MYSMTP_EMAIL_IDS,101,1) /= ' ' then,
      Do
      whereEnd = WordIndex(shortlist,Words(shortlist))
      shortlist = DELWORD(shortlist,whereEnd)
      End
   MySMTP_textline.4 = 'Sent to Group:' shortlist

/* Code in the section below should not be changed  */
/* Code in the section below should not be changed  */
/* Code in the section below should not be changed  */

   MySMTP_Message = Left(MySMTP_Message,80)
   hexAddress = D2X(Address_MYSMTP_MESSAGE)
   storrep = STORAGE(hexAddress,,Message)

   MySMTP_From = Left(MySMTP_From,50)
   hexAddress = D2X(Address_MYSMTP_FROM)
   storrep = STORAGE(hexAddress,,MySMTP_From)

   MySMTP_Subject = Left(MySMTP_Subject,50)
   hexAddress = D2X(Address_MySMTP_Subject)
   storrep = STORAGE(hexAddress,,MySMTP_Subject)

/* If TraceRQ = 'Y' then Trace ?r   */
   MYSMTP_COUNTER = ''
   numberLines = Right(MySMTP_textline.0,2,'0')
   Do l# = 1 to Length(numberLines)
      MYSMTP_COUNTER = MYSMTP_COUNTER ||,
         'F' || Substr(numberLines,l#,1)
   End
   If TraceRQ = 'Y' then say 'MYSMTP_COUNTER=' MYSMTP_COUNTER

   MYSMTP_TEXT = X2C(MYSMTP_COUNTER)
   Do line# = 1 to numberLines
      MYSMTP_TEXT = MYSMTP_TEXT || Left(MySMTP_textline.line#,133)
   End;  /* Do line# = 1 to MySMTP_textline.0 */

   hexAddress = D2X(Address_MYSMTP_TEXT)
   storrep = STORAGE(hexAddress,,MYSMTP_TEXT)

   MySMTP_URL = 'N'
   hexAddress = D2X(Address_MYSMTP_URL)
   storrep = STORAGE(hexAddress,,MySMTP_URL)

   /* Provide distribution list ( list of userids ) to Exit */
   MYSMTP_EMAIL_IDS =,
      Space(Strip(Translate(MYSMTP_EMAIL_IDS,' ','00'x)))
   MYSMTP_EMAIL_IDS = MYSMTP_EMAIL_IDS '0000'x
   MYSMTP_EMAIL_IDS = Left(MYSMTP_EMAIL_IDS,MYSMTP_EMAIL_ID_SIZE)
   hexAddress = D2X(Address_MYSMTP_EMAIL_IDS)
   storrep = STORAGE(hexAddress,,MYSMTP_EMAIL_IDS)

   Return;

SubmitBatchCAST:

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'SubmitBatchCAST'

   /* For CASTing a package in Batch                           */
   /*   Build a JCL model, and name its location here....      */
   CastPackageModel = 'YOURSITE.NDVR.TEAM.MODELS(CASTPKGE)'
     /* Name a work dataset to be created then deleted...        */
   CastPackageJCL   = USERID()".C1UEXTR7.SUBMIT"

   "ALLOC F(CASTPKGE) DA('"CastPackageModel"') SHR REUSE"
   "Execio * DISKR CASTPKGE (Stem jcl. Finis"
   "FREE DD(CASTPKGE)"

   /* Adjust jobcard - only line 1                         */
   jcl.1 = Overlay(USERID(),jcl.1,3)
   /* If ZACCTNUM is allocated then get Users' Acct number */
   /* ZACCTNUM can optionally be called before C1UEXTR7    */
   /* and provide a User Accounting number.           7    */
   WhatDDName = 'ZACCTNUM'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) /= ' ' then,
      Do
      "EXECIO 1 DISKR ZACCTNUM ( Finis"
      Pull ZACCTNUM
      ZACCTNUM = Word(Translate(ZACCTNUM,' ',"'"),2)
      tail  = '(' || ZACCTNUM || '), '
      whereParen = Pos('(', jcl.1)
      if whereParen > 0 then,
       jcl.1 = Overlay(tail,jcl.1,whereParen)
      End

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

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'Submit_n_save_jobInfo'
   If TraceRQ = 'Y' then Say 'Submit_n_save_jobInfo:'

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

   If TraceRQ = 'Y'             then Trace ?R
   whereami = 'SetExitReturnInfo'
   If TraceRQ = 'Y' then Say 'SetExitReturnInfo:    '

   hexAddress = D2X(Address_PECB_MESSAGE)
   storrep = STORAGE(hexAddress,,Message)
   hexAddress = D2X(Address_PECB_ERROR_MESS_LENGTH)
   storrep = STORAGE(hexAddress,,'0084'X)
   hexAddress = D2X(Address_PECB_MODS_MADE_TO_PREQ)
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

