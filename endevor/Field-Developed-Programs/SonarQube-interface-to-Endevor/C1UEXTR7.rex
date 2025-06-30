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
   /* If wanting to limit the use of this exit, uncomment...        */          
/*                                                                              
   If USERID() /= 'IBMUSER' &,                                                  
      USERID() /= 'JW61868' &,                                                  
      USERID() /= 'JW618685' then Say USERID()                                  
*/                                                                              
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
                                                                                
   /* If C1UEXTR7 is allocated to anything, turn on Trace  */                   
   WhatDDName = 'C1UEXTR7'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if RESULT = 0 then TraceRQ = 'Y'                                             
   /* Values to be set for your site......                     */               
   /* For package REVIEW  (APPROVE/DENY).....                  */               
   /*   Enter location of Approver Group sequencing   ...      */               
   ApproverGroupSequence= 'YOURSITE.NDVR.PARMLIB(APPROVER)'                     
   ApproverGroupSequence= ''                                                    
                                                                                
   /* Do you want all CAST actions to be peformed in Batch?    */               
   Force_CAST_in_Batch = 'Y' ; /*  Y/N   */                                     
   Force_CAST_in_Batch = 'N' ; /*  Y/N   */                                     
                                                                                
   Cast_with_SonarQube= '?'   /* Y/N/?=Check Notes */                           
                                                                                
   /* Parms are REXX statements passed from COBOL exit              */          
   Arg Parms                                                                    
   Parms = Strip(Parms)                                                         
   sa= 'Parms len=' Length(Parms)                                               
                                                                                
   If TraceRQ = 'Y' then,                                                       
      Say 'C1UEXTR7 is called again:'                                           
                                                                                
   /* Parms from C1UEXT07 is a string of REXX statements   */                   
                                                                                
   Interpret Parms                                                              
   If TraceRQ = 'Y' & PECB_MODE = 'B' then Trace r                              
                                                                                
   /* Another way to Determine if Trace is wanted...  */                        
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
                                                                                
   /* Early outs          ....                             */                   
   If PECB_FUNCTION_LITERAL = 'SETUP' then Exit                                 
                                                                                
   /* Work to Do          ....                             */                   
                                                                                
   /* Unspecified about SonarQube?  Let NOTES decide....   */                   
   If Cast_with_SonarQube /= 'N' then,                                          
      Do                                                                        
      Call CheckForSonarQubeOption                                              
      If Cast_with_SonarQube = 'Y' then,                                        
         Do                                                                     
         COBOL_Element_Types     = 'COB* CBL*'                                  
         COBOL_Compile_StepNames = 'COMPILE COMP CMP COB'                       
         TransmitMethod = 'FTP'       /* **chose one ** */                      
         TransmitMethod = 'XCOM'      /* **chose one ** */                      
         Call GetUnique_Name                                                    
         SonarDSNPrefix = USERID()'.SONRQUBE.' || Unique_Name                   
         SonarRemoteCommand =,                                                  
           "python3 /opt/xfer/scripts/SonarDriver.py" Unique_Name.lst                 
         TransmitTable = ""                                                     
         End /* If Cast_with_SonarQube = 'Y' */                                 
      End /* If Cast_with_SonarQube /= 'N' */                                   
                                                                                
   If PECB_FUNCTION_LITERAL  ='CAST'     &,                                     
      PECB_SUBFUNC_LITERAL   ='CAST'     &,                                     
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,                                     
      PHDR_PACKAGE_STATUS    ='IN-EDIT'  &,                                     
      PECB_MODE = "T" &,          /* TSO foreground  */                         
      (Force_CAST_in_Batch= 'Y' | Cast_with_SonarQube= 'Y') then,               
        Do                                                                      
        Call SubmitBatchCAST                                                    
        Exit                                                                    
        End                                                                     
                                                                                
   /* Initialize variables....                             */                   
   Message = ''                                                                 
   MessageCode = '    '                                                         
   MyRc = 0                                                                     
                                                                                
   /* Execute a SonarQube analysis?                        */                   
   If Cast_with_SonarQube = 'Y' &,                                              
      PECB_FUNCTION_LITERAL = 'CAST' &,                                         
      PECB_BEF_AFTER_LITERAL = 'BEFORE' Then                                    
      Do                                                                        
      If TraceRQ = 'Y' then Trace ?r                                            
      Call Allocate_Files_For_CSV_and_API                                       
      Elements.0 = 0                                                            
      Call ProcessPackageSCL                                                    
      If  COBOLinPackage = 'Y' then,                                            
          Do                                                                    
          Call RETRIEVE_Cobol_Elements                                          
          Call Use_ENTBJAPI_For_BX_Info                                         
          Trace r                                                               
          Call SubmitandWaitForSonarQube                                        
          If myRC > 4 then,                                                     
             Do                                                                 
             If message = '' then,                                              
                message = 'C1UEXTR7 -',                                         
                   'Package Failed the SonarQube Analysis'                      
             MyRc        = 8                                                    
             End   /* If myRC > 4 */                                            
          Else,                                                                 
             Do                                                                 
             MyRc     =  4                                                      
             message = 'C1UEXTR7 -',                                            
                'Package passed a SonarQube Analysis'                           
             End   /* Else        */                                            
          Call SetExitReturnInfo                                                
          Exit                                                                  
          End;  /* If  COBOLinPackage = 'Y'  ...  */                            
      Call FREE_Files_For_CSV_and_API                                           
      End;  /* If Cast_with_SonarQube = 'Y' ...  */                             
                                                                                
   /* Validate Package prefix with ServiceNow              */                   
   If PECB_FUNCTION_LITERAL  ='CREATE'   &,                                     
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,                                     
      (Substr(PECB_PACKAGE_ID,1,3) = 'PRB' |,                                   
       Substr(PECB_PACKAGE_ID,1,3) = 'CHG' )         then,                      
      Do                                                                        
      Call Validate_PackageID                                                   
      If MyRc > 0 then Exit                                                     
      End                                                                       
                                                                                
   /* Enforce packages to be Backout Enabled              */                    
   IF PREQ_BACKOUT_ENABLED /= 'Y' then,                                         
      Do                                                                        
      Message = 'C1UEXTR7 - Package made to be Backout enabled'                 
      MyRc        = 4                                                           
      hexAddress = D2X(Address_PREQ_BACKOUT_ENABLED)                            
      storrep = STORAGE(hexAddress,,'Y')                                        
      Call SetExitReturnInfo                                                    
      Exit                                                                      
      End;                                                                      
                                                                                
   If PECB_FUNCTION_LITERAL  ='CAST'     &,                                     
      PECB_SUBFUNC_LITERAL   ='CAST'     &,                                     
      PECB_BEF_AFTER_LITERAL ='AFTER'    then,                                  
      Call ManageEmails    ;                                                    
                                                                                
   Exit                                                                         
                                                                                
GetUnique_Name:                                                                 
                                                                                
   Unique_Name = GTUNIQUE()                                                     
   If TraceRQ = 'Y' then,                                                       
      SAY "Unique Member name is " Unique_Name                                  
                                                                                
   Return                                                                       
                                                                                
CheckForSonarQubeOption:                                                        
                                                                                
   Cast_with_SonarQube = 'Y'      /* Default */                                 
   If Substr(PHDR_PKG_NOTE8,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE7,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE6,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE5,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE4,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE3,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE2,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Else,                                                                        
   If Substr(PHDR_PKG_NOTE1,1,16)= 'BYPASS SONARQUBE' then,                     
      Cast_with_SonarQube = 'N'                                                 
   Return                                                                       
                                                                                
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
       'YOURSITE.NDVR.REXX(C1UEXTR7)'                                           
   MySMTP_Message =,                                                            
       'SHARE.ENDV.SHARABLE.REXX(C1UEXTR7)'                                     
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
         Sa= 'We need to wait'                                                  
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
         sa= 'You must wait for the' orderedApproverGroup,                      
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
   sa= words(unsorted_list) unsorted_list;                                      
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
   sa= words(sorted_list) sorted_list;                                          
                                                                                
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
                                                                                
  /* Variable settings for each site --->           */                          
  WhereIam =  WHERE@M1()                                                        
  interpret 'Call' WhereIam "'MySENULibrary'"                                   
  MySENULibrary = Result                                                        
  interpret 'Call' WhereIam "'MySEN2Library'"                                   
  MySEN2Library = Result                                                        
                                                                                
  Unique_Name = GTUNIQUE()                                                      
  /* Get job-related information from low address locations */                  
  MyAccountingCode = GETACCTC()                                                 
  job_name         = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */             
  Jobname= BUMPJOB(job_name)                                                    
                                                                                
  /* Prepare and run a Table Tool to build CAST jcl.......  */                  
  CALL BPXWDYN ,                                                                
    "ALLOC DD(TABLE) LRECL(80) BLKSIZE(27920) SPACE(1,1) ",                     
           " RECFM(F,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  Queue "* Do"                                                                  
  Queue "  * "                                                                  
  "EXECIO 2 DISKW TABLE    (FINIS ";   /* count queued */                       
                                                                                
  CALL BPXWDYN "ALLOC DD(NOTHING)  DUMMY"                                       
                                                                                
  CALL BPXWDYN ,                                                                
    "ALLOC DD(OPTIONS) LRECL(80) BLKSIZE(27920) SPACE(1,1) ",                   
           " RECFM(F,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  QUEUE "$nomessages     ='Y'"                                                  
  QUEUE "MyAccountingCode='"MyAccountingCode"'"                                 
  QUEUE "MySEN2Library   ='"MySEN2Library"'"                                    
  QUEUE "MySENULibrary   ='"MySENULibrary"'"                                    
  QUEUE "Unique_Name     ='"Unique_Name"'"                                      
  QUEUE "PECB_PACKAGE_ID ='"PECB_PACKAGE_ID"'"                                  
  QUEUE "Jobname= '"Jobname"'"                                                  
  QUEUE "TBLOUT = 'SUBMTJCL'"                                                   
  "EXECIO 8 DISKW OPTIONS (FINIS ";  /* count queued */                         
                                                                                
  /* For CASTing a package in Batch                           */                
  /*   Build a JCL model, and name its location here....      */                
    /* Name a work dataset to be created then deleted...        */              
                                                                                
  CastPackageModel = MySEN2Library || '(CAST#JCL)'                              
  "ALLOC F(MODEL) DA('"CastPackageModel"') SHR REUSE"                           
                                                                                
  /* Build the JCL for a Batch Cast                       */                    
  CastPackageJCL   = USERID()".C1UEXTR7.SUBMIT."Unique_Name                     
  "ALLOC F(SUBMTJCL) DA('"CastPackageJCL"') ",                                  
         "LRECL(80) BLKSIZE(16800) SPACE(5,5)",                                 
         "RECFM(F B) TRACKS ",                                                  
        "NEW CATALOG REUSE "     ;                                              
                                                                                
  myRC = ENBPIU00("A")                                                          
  "EXECIO 0 DISKW SUBMTJCL (Finis"                                              
                                                                                
  "FREE DD(TABLE)   "                                                           
  "FREE DD(NOTHING) "                                                           
  "FREE DD(OPTIONS) "                                                           
  "FREE DD(MODEL)   "                                                           
                                                                                
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
                                                                                
   JobData    = Strip(out.1);                                                   
   jobinfo    = Word(JobData,2) ;                                               
   If jobinfo = 'JOB' then,                                                     
      jobinfo   = Word(JobData,3) ;                                             
   SelectJobName   = Word(Translate(jobinfo,' ',')('),1) ;                      
   SelectJobNumber = Word(Translate(jobinfo,' ',')('),2) ;                      
                                                                                
   Return;                                                                      
                                                                                
Allocate_Files_For_CSV_and_API:                                                 
                                                                                
   STRING = "ALLOC DD(C1MSGS1) DUMMY "                                          
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTERR) DA(*) "                                           
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTAPI) DA(*) "                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(MSGFILE) LRECL(133) BLKSIZE(26600) ",                     
              " DSORG(PS) ",                                                    
              " SPACE(5,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return;                                                                      
                                                                                
FREE_Files_For_CSV_and_API:                                                     
                                                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS1)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTERR)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTAPI)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(MSGFILE)";                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return;                                                                      
                                                                                
CSV_to_List_Package_Actions:                                                    
                                                                                
  /* Get Package Action information for SonarQube preparations     */           
                                                                                
   STRING = "ALLOC DD(EXTRACTM) LRECL(4000) BLKSIZE(32000) ",                   
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",                       
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   QUEUE "LIST PACKAGE ACTION FROM PACKAGE '"PECB_PACKAGE_ID"'"                 
   QUEUE "     TO DDNAME 'EXTRACTM' "                                           
   QUEUE "     ."                                                               
                                                                                
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";                                  
                                                                                
   ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */                         
                                                                                
   call_rc = rc ;                                                               
                                                                                
  "EXECIO * DISKR EXTRACTM (STEM CSV. finis"                                    
                                                                                
   STRING = "FREE DD(EXTRACTM)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTIPT01)" ;                                               
  /* To Search the package action data in CSV format.              */           
  /* Identify matches with Rules file, determining Ship Dests      */           
                                                                                
  IF CSV.0 < 2 THEN RETURN;                                                     
                                                                                
  /* CSV data heading - showing CSV variables */                                
  $table_variables= Strip(CSV.1,'T')                                            
                                                                                
  $table_variables = translate($table_variables,"_"," ") ;                      
  $table_variables = translate($table_variables," ",',"') ;                     
  $table_variables = translate($table_variables,"@","/") ;                      
  $table_variables = translate($table_variables,"@",")") ;                      
  $table_variables = translate($table_variables,"@","(") ;                      
                                                                                
  WantedCSVVariables= ,                                                         
        "ELM_@S@  ENV_NAME_@S@ STG_ID_@S@ ",                                    
        "SYS_NAME_@S@ SBS_NAME_@S@ TYPE_NAME_@S@ "                              
                                                                                
  Do rec# = 2 to CSV.0                                                          
     $detail = CSV.rec#                                                         
     Drop SBS_NAME_@T@                                                          
                                                                                
     Trace Off                                                                  
     /* Parse CSV fields in the Detail record until done */                     
     Do $column =  1 to Words($table_variables)                                 
        Call ParseDetailCSVline                                                 
     End                                                                        
                                                                                
     If TraceRc =  1 then Trace r                                               
     IF Substr(ENV_NAME_@S@,1,1) = '00'x |,                                     
        Substr(ENV_NAME_@S@,1,1) = ' ' then Iterate;                            
                                                                                
     elm# = Elements.0 + 1                                                      
     Elements.elm# = ELM_@S@  ENV_NAME_@S@ STG_ID_@S@,                          
                     SYS_NAME_@S@ SBS_NAME_@S@ TYPE_NAME_@S@                    
     Elements.0 = elm#                                                          
     Sa= 'Messages from C1UEXTR7:' Elements.elm#                                
     Trace Off                                                                  
  End; /* Do rec# = 1 to CSV.0 */                                               
                                                                                
  RETURN ;                                                                      
                                                                                
ParseDetailCSVline:                                                             
                                                                                
  /* Find the data for the current $column */                                   
                                                                                
  $dlmchar = Substr($detail,1,1);                                               
                                                                                
  If $dlmchar = "'" then,                                                       
     Do                                                                         
     SA= 'parsing with single quote '                                           
     PARSE VAR $detail "'" $temp_value "'" $detail ;                            
     If Substr($detail,1,1) = ',' then,                                         
        $detail = Strip(Substr($detail,2),'L')                                  
     End                                                                        
  Else,                                                                         
  If $dlmchar = '"' then,                                                       
     Do                                                                         
     SA= 'parsing with double quote '                                           
     PARSE VAR $detail '"' $temp_value '"' $detail ;                            
     If Substr($detail,1,1) = ',' then,                                         
        $detail = Strip(Substr($detail,2),'L')                                  
     End                                                                        
  Else,                                                                         
  If $dlmchar = ',' then,                                                       
     Do                                                                         
     SA= 'parsing with comma        '                                           
     PARSE VAR $detail ',' $temp_value ',' $detail ;                            
     If Substr($detail,1,1)/= ',' then,                                         
        $detail = "," || $detail                                                
        $detail = Strip(Substr($detail,2),'L')   */                             
     End                                                                        
  Else,                                                                         
  If Words($detail) = 0 then,                                                   
     $temp_value = ' '                                                          
  Else,                                                                         
     Do                                                                         
     SA= 'parsing with comma        '                                           
     PARSE VAR $detail $temp_value ',' $detail ;                                
     Sa= '$temp_value=>' $temp_value '<'                                        
     End                                                                        
  $temp_value = STRIP($temp_value) ;                                            
  $rslt = $temp_value                                                           
  $rslt = Strip($rslt,'B','"')                             ;                    
  $rslt = Strip($rslt,'B',"'")                             ;                    
  if Length($rslt) < 1 then $rslt = ' '                                         
  thisVariable = WORD($table_variables,$column)                                 
  If Wordpos(thisVariable,WantedCSVVariables) = 0 then Return                   
  if Length($rslt) < 250 then,                                                  
     $temp = WORD($table_variables,$column) '= "'$rslt'"';                      
  Else,                                                                         
     $temp = WORD($table_variables,$column) "=$rslt"                            
  INTERPRET $temp;                                                              
  If rec# < 3 then Say $temp                                                    
                                                                                
  RETURN ;                                                                      
                                                                                
ProcessPackageSCL:                                                              
                                                                                
  /* Do an EXPORT to Capture the Package SCL                  */                
  SonarWorkfile = SonarDSNPrefix || '.SONARWRK'                                 
  SonarCOBOL    = SonarDSNPrefix || '.SONARCOB'                                 
                                                                                
  STRING = "ALLOC DD(WRKFILE) LRECL(080) BLKSIZE(24000) ",                      
             " DA("SonarWorkfile") ",                                           
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",                             
             " SPACE(5,5) RECFM(F,B) CYL ",                                     
             " NEW CATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  CALL BPXWDYN "FREE DD(WRKFILE)"                                               
                                                                                
  STRING = "ALLOC DD(COBOL) LRECL(080) BLKSIZE(24000) ",                        
             " DA("SonarCOBOL") ",                                              
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",                             
             " SPACE(5,5) RECFM(F,B) CYL ",                                     
             " NEW CATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  CALL BPXWDYN "FREE DD(COBOL)  "                                               
                                                                                
  STRING = "ALLOC DD(SCL) DA("SonarWorkfile"(SCL)) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
                                                                                
  STRING="ALLOC DD(ENPSCLIN) DA("SonarWorkfile"(SCLEXPRT)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  QUEUE "EXPORT PACKAGE '"PECB_PACKAGE_ID"'"                                    
  QUEUE "    TO DDN 'SCL' ."                                                    
  "EXECIO 2 DISKW ENPSCLIN (FINIS ";   /* count queued */                       
                                                                                
  ADDRESS LINK 'ENBP1000'   ;  /* run  from CSIQAUTH*/                          
  call_rc = rc ;                                                                
                                                                                
  CALL BPXWDYN "FREE DD(ENPSCLIN)" ;                                            
                                                                                
  STRING = "ALLOC DD(RESULTS) DA("SonarWorkfile"(PKGTBL)) SHR REUSE"            
  CALL BPXWDYN STRING;                                                          
                                                                                
  /* Use SCAN#SCL to create a TABLE from the SCL content      */                
  Call SCAN#SCL 'TABLE'                                                         
                                                                                
  CALL BPXWDYN "FREE DD(SCL)" ;                                                 
                                                                                
 /* Use TableTool to create multiple outputs                 */                 
  STRING = "ALLOC DD(TABLE) DA("SonarWorkfile"(PKGTBL)) SHR REUSE"              
  CALL BPXWDYN STRING;                                                          
                                                                                
  STRING="ALLOC DD(PARMLIST) DA("SonarWorkfile"(PARMLIST)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  QUEUE " HEADING1  TBLOUT1  INITS2   1    "                                    
  QUEUE " HEADING3  TBLOUT3  NOTHING  1    "                                    
  QUEUE "   MODEL1  TBLOUT1  OPTIONS# A    "                                    
  QUEUE " TRAILER2  TBLOUT2  OPTIONS2 1    "                                    
  "EXECIO 4 DISKW PARMLIST (FINIS ";   /* count queued */                       
                                                                                
  STRING="ALLOC DD(INITS2) DA("SonarWorkfile"(INITS2)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
  QUEUE " COBOL_Element_Types     = '"COBOL_Element_Types"'"                    
  QUEUE " COBOL_Compile_StepNames = '"COBOL_Compile_StepNames"'"                
  QUEUE " SonarCOBOL     = '"SonarCOBOL"'"                                      
  QUEUE " SonarWorkfile  = '"SonarWorkfile"'"                                   
  QUEUE " $MultiplePDSmemberOuts = 'Y' /* mult PDS mbr outputs */ "             
  QUEUE "$nomessages     ='Y'"                                                  
  "EXECIO 6 DISKW INITS2 (FINIS ";  /* count queued */                          
                                                                                
  CALL BPXWDYN "ALLOC DD(NOTHING) DUMMY"                                        
                                                                                
  STRING="ALLOC DD(HEADING1) DA("SonarWorkfile"(HEADING1)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  QUEUE "  SET TO DSN '"SonarCOBOL"'."                                          
  QUEUE "  SET OPTIONS REPLACE NO SIGNOUT. "                                    
  "EXECIO 2 DISKW HEADING1 (FINIS ";                                            
                                                                                
  STRING="ALLOC DD(MODEL1) DA("SonarWorkfile"(MODEL1)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
  QUEUE "  RETRIEVE ELEMENT &Element                             "              
  QUEUE "     FROM ENVIRONMENT &Envmnt STAGE &S                  "              
  QUEUE "          SYSTEM &System SUBSYSTEM &Subsys TYPE &Type . "              
  "EXECIO 3 DISKW MODEL1 (FINIS ";                                              
                                                                                
  STRING="ALLOC DD(OPTIONS#) DA("SonarWorkfile"(OPTIONS#)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  Queue "$NumberModelsAndTblouts= 3                               "             
  Queue "HaveCobol = 0                                            "             
  Queue "Do w# = 1 to Words(COBOL_Element_Types) ; +              "             
  Queue "   HaveCobol=QMATCH(Type Word(COBOL_Element_Types,w#)); +"             
  Queue "   If HaveCobol = 1 then Do; $my_rc = 1; Leave; End; +   "             
  Queue "End;                                                     "             
  Queue "If HaveCobol = 0 then $SkipRow='Y'                       "             
  Queue "AEELM= COPIES(' ',80);                                   "             
  Queue "AEELM= Overlay('AEELMBC ',AEELM,1) ;                     "             
  Queue "AEELM= Overlay(Envmnt,AEELM,10) ;     /* Env      */     "             
  Queue "AEELM= Overlay(S,AEELM,18) ;          /* stg id   */     "             
  Queue "AEELM= Overlay(System,AEELM,19) ;     /* Sys      */     "             
  Queue "AEELM= Overlay(Subsys,AEELM,27) ;     /* Sub      */     "             
  Queue "AEELM= Overlay(Element,AEELM,35) ;    /* Ele      */     "             
  Queue "AEELM= Overlay(Type,AEELM,45);        /* Typ      */     "             
  Queue "*                                                        "             
  Queue "Element = Left(Element,08)                               "             
  "EXECIO 17 DISKW OPTIONS# (FINIS "; /* count queued */                        
                                                                                
  STRING="ALLOC DD(OPTIONS2) DA("SonarWorkfile"(OPTIONS2)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  Queue "$NumberModelsAndTblouts= 1 ; /* Number of MODEL inputs */"             
  "EXECIO 1 DISKW OPTIONS2 (FINIS ";   /* count queued */                       
                                                                                
  STRING="ALLOC DD(MODEL2) DA("SonarWorkfile"(MODEL2)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
  Queue "AACTL MSGFILE COMPLIST                                   "             
  Queue "&AEELM                                                   "             
  Queue "RUN                                                      "             
  "EXECIO 3 DISKW MODEL2 (FINIS ";                                              
                                                                                
  STRING="ALLOC DD(HEADING3) DA("SonarWorkfile"(HEADING3)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  Queue "* Folder-- Member--  ",                                                
        "Dataset------------------------------------- "                         
  "EXECIO 1 DISKW HEADING3 (FINIS ";                                            
                                                                                
  STRING="ALLOC DD(MODEL3) DA("SonarWorkfile"(MODEL3)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
  Queue "  COBOL    &Element   &SonarCOBOL "                                    
  "EXECIO 1 DISKW MODEL3 (FINIS ";                                              
                                                                                
  STRING="ALLOC DD(TRAILER2) DA("SonarWorkfile"(TRAILER2)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  Queue "AACTLY  "                                                              
  Queue "RUN     "                                                              
  Queue "QUIT    "                                                              
  "EXECIO 3 DISKW TRAILER2 (FINIS ";                                            
                                                                                
  STRING="ALLOC DD(TBLOUT1) DA("SonarWorkfile"(RETRIEVE)) SHR REUSE"            
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(TBLOUT2) DA("SonarWorkfile"(AEELMBC)) SHR REUSE"             
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(TBLOUT3) DA("SonarWorkfile"(TRANSMIT)) SHR REUSE"            
  CALL BPXWDYN STRING;                                                          
                                                                                
  If TraceRQ = 'Y' then Trace R                                                 
  myRC = ENBPIU00("PARMLIST")                                                   
  If myRC = 1 then COBOLinPackage = 'Y'                                         
                                                                                
  CALL BPXWDYN "FREE DD(SCL)     " ;                                            
  CALL BPXWDYN "FREE DD(ENPSCLIN)" ;                                            
  CALL BPXWDYN "FREE DD(RESULTS) " ;                                            
                                                                                
  CALL BPXWDYN "FREE DD(TABLE)   " ;                                            
  CALL BPXWDYN "FREE DD(PARMLIST)" ;                                            
  CALL BPXWDYN "FREE DD(INITS2)  " ;                                            
  CALL BPXWDYN "FREE DD(NOTHING) " ;                                            
  CALL BPXWDYN "FREE DD(HEADING1)" ;                                            
  CALL BPXWDYN "FREE DD(MODEL1)  " ;                                            
  CALL BPXWDYN "FREE DD(OPTIONS#)" ;                                            
  CALL BPXWDYN "FREE DD(OPTIONS2)" ;                                            
  CALL BPXWDYN "FREE DD(MODEL2)  " ;                                            
  CALL BPXWDYN "FREE DD(HEADING3)" ;                                            
  CALL BPXWDYN "FREE DD(MODEL3)  " ;                                            
  CALL BPXWDYN "FREE DD(TRAILER2)" ;                                            
  CALL BPXWDYN "FREE DD(TBLOUT1) " ;                                            
  CALL BPXWDYN "FREE DD(TBLOUT2) " ;                                            
  CALL BPXWDYN "FREE DD(TBLOUT3) " ;                                            
                                                                                
  RETURN ;                                                                      
                                                                                
RETRIEVE_Cobol_Elements:                                                        
                                                                                
  STRING="ALLOC DD(BSTIPT01) DA("SonarWorkfile"(RETRIEVE)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
                                                                                
  ADDRESS LINK 'C1BM3000'                                                       
                                                                                
  RETURN ;                                                                      
                                                                                
Use_ENTBJAPI_For_BX_Info:                                                       
                                                                                
  /*    See your CSIQJCL(BC1JAAPI)                                  */          
  /*    V - COLUMN 6 = FORMAT SETTING                               */          
  /*      = ' ' FOR NO FORMAT, JUST EXTRACT ELEMENT                 */          
  /*      = 'B' FOR ENDEVOR BROWSE DISPLAY FORMAT                   */          
  /*      = 'C' FOR ENDEVOR CHANGE DISPLAY FORMAT                   */          
  /*      = 'H' FOR ENDEVOR HISTORY DISPLAY FORMAT                  */          
  /*    V - COLUMN 7 = Replay TYPE SETTING                          */          
  /*      = 'E' FOR ELEMENT                                         */          
  /*      = 'C' FOR COMPONENT                                       */          
  /*       VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                 */          
  /*               V - COLUMN 18 = STAGE ID                         */          
  /*                VVVVVVVV - COLUMN 19-26 SYSTEM NAME             */          
  /*                        VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME  */          
  /*   COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                      */          
  /*   COLUMN 45-52 = TYPE NAME               VVVVVVVV              */          
  /*                                                                */          
                                                                                
  Sa= 'Use_ENTBJAPI_For_BX_Info'                                                
                                                                                
  STRING="ALLOC DD(SYSIN) DA("SonarWorkfile"(AEELMBC)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
                                                                                
                                                                                
  STRING = "ALLOC DD(COMPLIST) LRECL(200) BLKSIZE(20000) ",                     
             " DSORG(PS) ",                                                     
             " SPACE(5,15) RECFM(F,B) TRACKS ",                                 
             " MOD UNCATALOG REUSE ";                                           
  CALL BPXWDYN STRING;                                                          
                                                                                
  /* Call Built-in API program for COBOL source extracts  */                    
  /* and COBOL component List requests.                   */                    
  ADDRESS LINK "ENTBJAPI"                                                       
                                                                                
  CALL BPXWDYN "FREE DD(SYSIN)  "                                               
                                                                                
  "EXECIO * DISKR COMPLIST (Stem cmplist. FINIS ";                              
  CALL BPXWDYN "FREE DD(COMPLIST)"                                              
                                                                                
  sa= cmplist.0                                                                 
  If  cmplist.0 = 0 then Return;                                                
                                                                                
  Call ProcessCopybookMembers;                                                  
  Call UpdateSonarTransmitTable;                                                
  Drop element.                                                                 
                                                                                
  RETURN ;                                                                      
                                                                                
ProcessCopybookMembers:                                                         
                                                                                
   Do rec# = 1 to cmplist.0                                                     
      complist   = Substr(cmplist.rec#,73)                                      
      If Substr(complist,1,22) = Copies('-',22) then,                           
         thisSection = Word(complist,2)                                         
      If thisSection /= 'INPUT' then iterate;                                   
      If Word(complist,1) = 'STEP:' then,                                       
         Do                                                                     
         StepName    = Word(complist,2)                                         
         DDname      = Substr(Word(complist,3),4)                               
         DatasetName = Substr(Word(complist,5),5)                               
         Iterate                                                                
         End                                                                    
      If Substr(Word(complist,5),3,1) = ':' &,                                  
         WordPos(StepName,COBOL_Compile_StepNames) > 0 &,                       
         DDname  = 'SYSLIB'     then,                                           
         Do                                                                     
         member = Word(complist,2)                                              
         entry = "COPYBOOK,"member","DatasetName                                
         If Wordpos(entry,TransmitTable) = 0 then,                              
         TransmitTable = TransmitTable entry                                    
         End                                                                    
   End;  /* Do rec# = 1 to cmplist.0 */                                         
                                                                                
  RETURN ;                                                                      
                                                                                
UpdateSonarTransmitTable:                                                       
                                                                                
  STRING =,                                                                     
     "ALLOC DD(SONARXMT) DA("SonarWorkfile"(TRANSMIT)) SHR REUSE"               
  CALL BPXWDYN STRING;                                                          
  "Execio * DISKR SONARXMT (Stem xmit. Finis"                                   
  xm# = xmit.0                                                                  
                                                                                
  Do w# = 1 to Words(TransmitTable)                                             
     xm# = xm# + 1                                                              
     transtable = Word(TransmitTable,w#)                                        
     Parse var transtable folder ',' member ',' dataset                         
     entry = " " left(folder,8) left(member,10) dataset                         
     xmit.xm# = entry                                                           
  End; /*  Do w# = 1 to Words(TransmitTable) */                                 
                                                                                
  "Execio * DISKW SONARXMT (Stem xmit. Finis"                                   
                                                                                
  transtable = ""                                                               
  RETURN ;                                                                      
                                                                                
SubmitandWaitForSonarQube:                                                      
                                                                                
  /* Allocate files for a TableTool driven submission of the                    
     SonarQube job, and a series of waits for parts of the job                  
     to complete.                                              */               
  /* Variable settings for each site --->           */                          
  WhereIam =  WHERE@M1()                                                        
                                                                                
  interpret 'Call' WhereIam "'MySENULibrary'"                                   
  MySENULibrary = Result                                                        
  interpret 'Call' WhereIam "'MySEN2Library'"                                   
  MySEN2Library = Result                                                        
  interpret 'Call' WhereIam "'MyCLS0Library'"                                   
  MyCLS0Library = Result                                                        
  interpret 'Call' WhereIam "'MyCLS2Library'"                                   
  MyCLS2Library = Result                                                        
  interpret 'Call' WhereIam "'MyHomeAddress'"                                   
  MyHomeAddress = Result                                                        
                                                                                
  STRING="ALLOC DD(SETUP) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",               
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
  CALL BPXWDYN STRING;                                                          
  s# = 0                                                                        
  s# = s#+1                                                                     
  set.s# = "Package       ='"PECB_PACKAGE_ID"'"                                 
  s# = s#+1                                                                     
  set.s# = "MyHomeAddress ='"MyHomeAddress"'"                                   
  s# = s#+1                                                                     
  set.s# = "MySENULibrary ='"MySENULibrary"'"                                   
  s# = s#+1                                                                     
  set.s# = "MySEN2Library ='"MySEN2Library"'"                                   
  s# = s#+1                                                                     
  set.s# = "MyCLS0Library ='"MyCLS0Library"'"                                   
  s# = s#+1                                                                     
  set.s# = "MyCLS2Library ='"MyCLS2Library"'"                                   
  s# = s#+1                                                                     
  set.s# = "SonarWorkfile ='"SonarWorkfile"'"                                   
  s# = s#+1                                                                     
  set.s# = "Unique_Name   ='"Unique_Name"'"                                     
  s# = s#+1                                                                     
  ReportingPFX = USERID() || '.SONRQUBE.'Unique_Name'.RESULTS'                  
  set.s# = "ReportingPFX = '"ReportingPFX"'"                                    
  s# = s#+1                                                                     
  set.s# = "$nomessages    = 'Y'"                                               
  myJob     = MVSVAR('SYMDEF','JOBNAME' )                                       
  s# = s#+1                                                                     
  set.s# = "myJob     = '"myJob"'"                                              
  Jobname = BUMPJOB(myJob)                                                      
  s# = s#+1                                                                     
  set.s# = "Jobname = '"Jobname"'"                                              
  s# = s#+1                                                                     
  set.s# = "TransmitMethod = '"TransmitMethod"'"                                
  s# = s#+1                                                                     
  set.s# = "TransmitCOND  ="0                                                   
  "Execio * DISKW SYSTSPRT (Stem set. Finis"                                    
  "Execio * DISKW SETUP    (Stem set. Finis"                                    
                                                                                
  STRING="ALLOC DD(PARMLIST) DA("MySEN2Library"(SONARPRM)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
                                                                                
  STRING="ALLOC DD(MDL#JOB) ",                                                  
         "DA("MySEN2Library"("TransmitMethod"#JOB) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(MDL#RCV) ",                                                  
         "DA("MySEN2Library"("TransmitMethod"#RCV) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(MDL#RUN) ",                                                  
         "DA("MySEN2Library"("TransmitMethod"#RUN) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
                                                                                
  STRING="ALLOC DD(JCL#JOB) ",                                                  
         "DA("SonarWorkfile"("TransmitMethod"#JOB) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(JCL#RCV) ",                                                  
         "DA("SonarWorkfile"("TransmitMethod"#RCV) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(JCL#RUN) ",                                                  
         "DA("SonarWorkfile"("TransmitMethod"#RUN) SHR REUSE"                   
  CALL BPXWDYN STRING;                                                          
                                                                                
  STRING="ALLOC DD(WAIT#1)   DA("MySEN2Library"(SONARW#1)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(WAIT#2)   DA("MySEN2Library"(SONARW#2)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(WAIT#3)   DA("MySEN2Library"(SONARW#3)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(MODEL)    DA("MySEN2Library"(SONARMDL)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(TABLE)    DA("MySEN2Library"(SONARTBL)) SHR REUSE"           
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(NOTHING)  DUMMY"                                             
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(SYSTSPRT) SYSOUT(A) "                                        
  CALL BPXWDYN STRING;                                                          
  STRING="ALLOC DD(REPORT)   SYSOUT(A) "                                        
  CALL BPXWDYN STRING;                                                          
  STRING = "ALLOC DD(TBLOUT) SYSOUT(A) WRITER(INTRDR) REUSE " ;                 
  CALL BPXWDYN STRING;                                                          
                                                                                
  myRC = ENBPIU00("PARMLIST")                                                   
                                                                                
  CALL BPXWDYN "FREE DD(TBLOUT)   "                                             
  CALL BPXWDYN "FREE DD(REPORT)   "                                             
  CALL BPXWDYN "FREE DD(PARMLIST)"                                              
  CALL BPXWDYN "FREE DD(SETUP)    "                                             
  CALL BPXWDYN "FREE DD(WAIT#1)   "                                             
  CALL BPXWDYN "FREE DD(WAIT#2)   "                                             
  CALL BPXWDYN "FREE DD(WAIT#3)   "                                             
  CALL BPXWDYN "FREE DD(MODEL)    "                                             
  CALL BPXWDYN "FREE DD(TABLE)    "                                             
  CALL BPXWDYN "FREE DD(NOTHING) "                                              
  CALL BPXWDYN "FREE DD(SYSTSPRT)"                                              
                                                                                
  If myRC = 11 then,                                                            
     message = 'C1UEXTR7 - could not submit the SonarQube job'                  
  If myRC = 12 then,                                                            
     message = 'C1UEXTR7 - File transmissions failed         '                  
  If myRC = 13 then,                                                            
     message = 'C1UEXTR7 - could not initiate SonarQube',                       
               ' analysis'                                                      
                                                                                
  If myRC < 8 then,                                                             
     Do                                                                         
     STRING="ALLOC DD(RESULTS)",                                                
            " DA("SonarWorkfile".RESULTS) SHR REUSE"                            
     CALL BPXWDYN STRING;                                                       
     "Execio * DISKR RESULTS (Stem rslt. Finis"                                 
     CALL BPXWDYN "FREE  DD(RESULTS)"                                           
     lastline# = rslt.0                                                         
     lastline = rslt.lastline#                                                  
     If Pos('Status: SUCCESS ',lastline) = 0 then myRc= 8                       
     End   /* If myRC < 8 */                                                    
                                                                                
  RETURN ;                                                                      
                                                                                
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
                                                                                
