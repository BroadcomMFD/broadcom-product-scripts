/*   rexx    */
   /* Make CAST actions always be batch...                     */
   /* Values to be set for your site......                     */
     /* Build a JCL model, and name its location here....        */
   CastPackageModel = 'your.ndvrhlq.SKELS(CASTPKGE)'
   CastPackageModel = ''
     /* Name a work dataset to be created then deleted...        */
   CastPackageJCL   = USERID()".C1UEXTR7.SUBMIT"
   /* If wanting to limit the use of this exit, uncomment...   */
/* If USERID() /= 'IBMUSER' then exit */
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;
   /* If C1UEXTR7 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then Trace ?r
   Sa= 'You called C1UEXTR7 '
   Message = ''
   MessageCode = '    '
   /* Values to be set for your site......                     */
   /* For package REVIEW  (APPROVE/DENY).....                  */
   /*   Enter location of Approver Group sequencing   ...      */
   ApproverGroupSequence= 'your.ndvrhlq.PARMLIB(APPROVER)'
   ApproverGroupSequence= ''
   /* Do you want all CAST actions to be peformed in Batch?    */
   Force_CAST_in_Batch = 'Y' ; /*  Y/N   */
   Force_CAST_in_Batch = 'N' ; /*  Y/N   */
   Cast_with_SonarQube= 'N'   /* Y/N/?=Check Notes and pkg content*/
   Cast_with_SonarQube= 'Y'   /* Y/N/?=Check Notes and pkg content*/
   Arg Parms
   sa= 'Parms len=' Length(Parms)
   MyRc = 0
   /* Parms from C1UEXT07 is a string of REXX statements   */
   Interpret Parms
   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRc = 1
   /* Validate Package prefix with ServiceNow              */
   If PECB_FUNCTION_LITERAL  ='CREATE'   &,
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,
      (Substr(PECB_PACKAGE_ID,1,3) = 'PRB' |,
       Substr(PECB_PACKAGE_ID,1,3) = 'CHG' )         then,
      Do
      PackageSnowRef = Substr(PECB_PACKAGE_ID,1,10)
      Message = SERVINOW('C1UEXTR7' PackageSnowRef PECB-MODE )
      If POS('**NOT**', Message) > 0 then,
         Do
         MyRc        = 8
         Call SetExitReturnInfo
         Exit
         End;  /* If POS('**NOT**', Message) > 0 */
      End;  /* If PECB_FUNCTION_LITERAL  ='CREATE' ... */
   /* Is package ready to be automatically Executed.....   */
   IF PHDR_PACKAGE_STATUS = 'APPROVED' &,
      PECB_BEF_AFTER_LITERAL = 'AFTER' &,
      (PECB_FUNCTION_LITERAL = 'CAST' |,
       PECB_FUNCTION_LITERAL = 'REVIEW') Then,
       Do
       PKGEXECT_Parm = Copies(' ',055)
       PKGEXECT_Parm = Overlay(PECB_PACKAGE_ID     ,PKGEXECT_Parm,001)
       PKGEXECT_Parm = Overlay(PHDR_PKG_ENV        ,PKGEXECT_Parm,018)
       PKGEXECT_Parm = Overlay(PHDR_PKG_STGID      ,PKGEXECT_Parm,026)
       PKGEXECT_Parm = Overlay(REXX_EXEC_MODE      ,PKGEXECT_Parm,028)
       PKGEXECT_Parm = Overlay(PHDR_PKG_CREATE_USER,PKGEXECT_Parm,029)
       PKGEXECT_Parm = Overlay(PHDR_PKG_UPDATE_USER,PKGEXECT_Parm,037)
       PKGEXECT_Parm = Overlay(PHDR_PKG_CAST_USER  ,PKGEXECT_Parm,045)
       Call PKGEXECT PKGEXECT_Parm
       Exit
       End
   /* Is package ready to be CAST in batch .............   */
     /*  Does PACKAGE builder indicate the package has COBOL ? */
   thisPackageHasCobol = 'N'
   If Substr(PREQ_PACKAGE_COMMENT,47,4) = '+COB' then,
      thisPackageHasCobol = 'Y'
   If Cast_with_SonarQube= 'Y' & thisPackageHasCobol = 'Y' then,
      Do
      /*  Does user want to BYPASS SonarQube for this package ? */
      AllNotes = ,
         PHDR_PKG_NOTE1 || PHDR_PKG_NOTE2 || PHDR_PKG_NOTE3 ||,
         PHDR_PKG_NOTE4 || PHDR_PKG_NOTE5 || PHDR_PKG_NOTE6 ||,
         PHDR_PKG_NOTE7 || PHDR_PKG_NOTE8
      If Pos('BYPASS SONARQUBE',AllNotes) > 0 then,
         Cast_with_SonarQube= 'N'
      End
   /* If Going to interface with SonarQube, do CAST in Batch */
   /*    if foreground, re-Submit in Batch                   */
   IF Cast_with_SonarQube= 'Y' &,
      thisPackageHasCobol= 'Y' &,
      PECB_FUNCTION_LITERAL = 'CAST' &,
      PECB_BEF_AFTER_LITERAL = 'BEFORE' &,
      PECB_MODE = "T" then,       /* TSO foreground  */
      Do
      Call SubmitBatchCAST
      Exit
      End
   /* If Going to interface with SonarQube, do CAST in Batch */
   /*    if Batch, engage the interface with SonarQube       */
   IF Cast_with_SonarQube= 'Y' &,
      thisPackageHasCobol= 'Y' &,
      PECB_FUNCTION_LITERAL = 'CAST' &,
      PECB_BEF_AFTER_LITERAL = 'BEFORE' &,
      PECB_MODE = "B" then,       /* TSO foreground  */
      Do
      Message =  SONRQUBE(PECB_PACKAGE_ID)
      If Message /= '' then,
         Do
         MyRc = 8
         Call SetExitReturnInfo
         End
      Exit
      End
   EXIT
   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRc = 1
   IF PHDR_PACKAGE_STATUS = 'APPROVED' &,
      PECB_BEF_AFTER_LITERAL = 'AFTER' &,
      (PECB_FUNCTION_LITERAL = 'CAST' |,
       PECB_FUNCTION_LITERAL = 'REVIEW') Then,
       Do
       PKGEXECT_Parm = Copies(' ',055)
       PKGEXECT_Parm = Overlay(PECB_PACKAGE_ID     ,PKGEXECT_Parm,001)
       PKGEXECT_Parm = Overlay(PHDR_PKG_ENV        ,PKGEXECT_Parm,018)
       PKGEXECT_Parm = Overlay(PHDR_PKG_STGID      ,PKGEXECT_Parm,026)
       PKGEXECT_Parm = Overlay(REXX_EXEC_MODE      ,PKGEXECT_Parm,028)
       PKGEXECT_Parm = Overlay(PHDR_PKG_CREATE_USER,PKGEXECT_Parm,029)
       PKGEXECT_Parm = Overlay(PHDR_PKG_UPDATE_USER,PKGEXECT_Parm,037)
       PKGEXECT_Parm = Overlay(PHDR_PKG_CAST_USER  ,PKGEXECT_Parm,045)
       Call PKGEXECT PKGEXECT_Parm
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
   /* Preparing to CAST The package...               */
   If PREQ_PKG_CAST_COMPVAL = 'Y' then,
   CastOption = '    OPTION VALIDATE COMPONENTS'
   Else,
   If PREQ_PKG_CAST_COMPVAL = 'W' then,
   CastOption = '    OPTION VALIDATE COMPONENT WITH WARNING'
   Else,
   CastOption = '    OPTION DO NOT VALIDATE COMPONENT'
   /* Variable settings for each site --->           */
   WhereIam =  WHERE@M1()
   interpret 'Call' WhereIam "'MyDATALibrary'"
   MyDATALibrary = Result
   interpret 'Call' WhereIam "'MySEN2Library'"
   MySEN2Library = Result
   interpret 'Call' WhereIam "'MySENULibrary'"
   MySENULibrary = Result
   interpret 'Call' WhereIam "'AltIDAcctCode'"
   AltIDAcctCode = Result
   interpret 'Call' WhereIam "'MySENULibrary'"
   MySENULibrary = Result
   interpret 'Call' WhereIam "'AltIDJobClass'"
   AltIDJobClass = Result
   /* <---- Variable settings for each site          */
   Sa= 'Running C1UEXTR7 '
   /* Allocate and prepare files for ENBPIU00 execution               */
   /* OPTIONS will contain date and time values                       */
   /*                                                                 */
   STRING = "ALLOC DD(OPTIONS) LRECL(80) BLKSIZE(27920) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   QUEUE "  $nomessages = 'Y' " ;
   QUEUE "  Package = '"PECB_PACKAGE_ID"'" ;
   QUEUE "  Userid  = '"USERID()"'" ;
   QUEUE "  Userjob = '"USERID()|| SUBSTR(Package,1,1)"'"
   QUEUE "  AltIDAcctCode = '"AltIDAcctCode"'"
   QUEUE "  MySEN2Library = '"MySEN2Library"'"
   QUEUE "  MySENULibrary = '"MySENULibrary"'"
   QUEUE "  AltIDJobClass = '"AltIDJobClass"'"
   QUEUE "  CastOption    = '"CastOption"'"
   "EXECIO " QUEUED() "DISKW OPTIONS (FINIS"
   /*                                                                 */
   /* TABLE is simple to allow the CAST                               */
   /*                                                                 */
   STRING = "ALLOC DD(TABLE) LRECL(80) BLKSIZE(8000) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   QUEUE "* Do "
   QUEUE "  *  "
   "EXECIO  2 DISKW TABLE (FINIS"
   STRING = 'ALLOC DD(MODEL) ',
            "DA('"MySEN2Library"(CASTPKGE)') SHR REUSE "
   CALL BPXWDYN STRING;
   /* TBLOUT is assigned to a temporary dataset to receive the jcl    */
   /*                                                                 */
   STRING = "ALLOC DD(TBLOUT) LRECL(80) BLKSIZE(27920) ",
              " DA("CastPackageJCL") ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW CATALOG REUSE ";
   CALL BPXWDYN STRING;
   /*                                                                 */
   /* Now call ENBPIU00 which does the rest                           */
   /*                                                                 */
   "ENBPIU00 M 1 "
   "EXECIO 0 DISKW TBLOUT (FINIS"
   CALL BPXWDYN "FREE DD(OPTIONS)" ;
   CALL BPXWDYN "FREE DD(TABLE)" ;
   CALL BPXWDYN "FREE DD(MODEL)" ;
   Call Submit_n_save_jobInfo ;
   Message = JobData
   MyRc        = 8
   PACKAGE = PECB_PACKAGE_ID
   MessageCode = 'U033'
   Call SetExitReturnInfo
   CALL BPXWDYN "FREE DD(TBLOUT) DELETE"
   Return
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
