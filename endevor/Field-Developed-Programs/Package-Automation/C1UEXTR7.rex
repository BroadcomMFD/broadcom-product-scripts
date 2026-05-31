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
   /* In case these are not already allocated, these are attempted  */
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;
   /* If C1UEXTR7 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then Trace ?R
   /* Initialize variables....                             */
   Message = ''
   MessageCode = '    '
   MyRc = 0
   /* Parms are REXX statements passed from COBOL exit              */
   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)
   If TraceRQ = 'Y' then,
      Say 'C1UEXTR7 is called again:'
   /* Parms from C1UEXT07 is a string of REXX statements   */
   Interpret Parms
   If TraceRQ = 'Y' & PECB_MODE = 'B' then Trace r
   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRc = 1
   where = 'C1UEXTR7'
   what = 'C1UEXTR7-' PECB_FUNCTION_LITERAL,
                      PECB_BEF_AFTER_LITERAL,
                      PHDR_PACKAGE_STATUS
   /* Find GTUNIQUE on GitHub in the folder-                   */
   /* endevor/Field-Developed-Programs/Miscellaneous-items     */
   Unique_Name = GTUNIQUE()
   /* Validate Package prefix with ServiceNow              */
   If PECB_FUNCTION_LITERAL  ='CREATE'   &,
      PECB_BEF_AFTER_LITERAL ='BEFORE'   &,
      (Substr(PECB_PACKAGE_ID,1,3) = 'PRB' |,
       Substr(PECB_PACKAGE_ID,1,3) = 'CHG' )         then,
      Do
      PackageSnowRef = Substr(PECB_PACKAGE_ID,1,10)
      /* Find SERVINOW on GitHub in the folder-                   */
      /* \ServiceNow-Interface\COBOL+REXX+PythonOrGoLang-Example*/
      Message = SERVINOW('C1UEXTR7' PackageSnowRef ECB_TSO_BATCH_MODE)
      If POS('**NOT**', Message) > 0 then,
         Do
         MyRc        = 8
         Call SetExitReturnInfo
         Exit
         End;  /* If POS('**NOT**', Message) > 0 */
      End;  /* If PECB_FUNCTION_LITERAL  ='CREATE' ... */
   /* If the package status just became IN-APPROVAL, send emails */
   /*  to request approval(s).                                   */
   IF PHDR_PACKAGE_STATUS = 'IN-APPROVAL' &,
      PECB_BEF_AFTER_LITERAL = 'AFTER'    &,
      PECB_FUNCTION_LITERAL = 'CAST'      &,
      Substr(CALL_REASON,1,16) = 'APPROVER GROUP #' then,
       Do
       /* Find SENDMAIL on GitHub in the folder-                 */
       /* endevor/Field-Developed-Programs/...                   */
       /*   Email-For-External-Approver-Groups                   */
       Call SENDMAIL PAPP_GROUP_NAME PECB_PACKAGE_ID,
          'Needs-Approval' PAPP_APPROVAL_IDS
       Exit
       End
   IF PHDR_PACKAGE_STATUS = 'APPROVED' &,
      PECB_BEF_AFTER_LITERAL = 'AFTER' &,
      (PECB_FUNCTION_LITERAL = 'CAST' |,
       PECB_FUNCTION_LITERAL = 'REVIEW') Then,
       Do
       GoExecute = 'Y'
       Call CheckExecutionWindow
       If GoExecute = 'Y' then,
         DO
         Call Get_Site_Shipping_Variables
         PKGEXECT_Parm = Copies(' ',055)
         PKGEXECT_Parm = Overlay(PECB_PACKAGE_ID     ,PKGEXECT_Parm,001)
         PKGEXECT_Parm = Overlay(PHDR_PKG_ENV        ,PKGEXECT_Parm,018)
         PKGEXECT_Parm = Overlay(PHDR_PKG_STGID      ,PKGEXECT_Parm,026)
         PKGEXECT_Parm = Overlay(REXX_EXEC_MODE      ,PKGEXECT_Parm,028)
         PKGEXECT_Parm = Overlay(PHDR_PKG_CREATE_USER,PKGEXECT_Parm,029)
         PKGEXECT_Parm = Overlay(PHDR_PKG_UPDATE_USER,PKGEXECT_Parm,037)
         PKGEXECT_Parm = Overlay(PHDR_PKG_CAST_USER  ,PKGEXECT_Parm,045)
         /* Find PKGEXECT on GitHub in the folder-               */
         /* endevor/Field-Developed-Programs/Package-Automation  */
         Call PKGEXECT PKGEXECT_Parm
         End  /* If GoExecute = 'Y' */
       Exit
       End
   /* If a package is being Backed out/in in batch            */
   If Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK' &,
      PECB_MODE = 'B' then,
      Do
      message = 'C1UEXTR7 -',
         'Package Backout/Backin unAuthorized for Batch'
      MyRc = 8
      Call SetExitReturnInfo
      If TraceRQ = 'Y' then Say 'C1UEXTR7 is exiting @123 '
      Exit
      End
   /* Before a package is being Backed out/in ....            */
   IF PECB_BEF_AFTER_LITERAL = 'BEFORE' & PECB_MODE = 'T' &,
      Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK' then,
      Do
      what = 'C1UEXTR7 before Backout/Backin'
      ADDRESS TSO "EXECIO 1 DISKR AUTHORIZ (Finis"
      pull BakoutCCID
      BakoutCCID = Strip(BakoutCCID)
      /* Find BKOUTLOG on GitHub in the folder-                  */
      /* endevor/Field-Developed-Programs/...                    */
      /*   Package-Backout-Logging                               */
      Call BKOUTLOG PECB_PACKAGE_ID 'Before',
           BakoutCCID USERID()
      End
   /* If a package is being Backed out/in ....                */
   IF PECB_BEF_AFTER_LITERAL = 'AFTER' & PECB_MODE = 'T' &,
      Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK' then,
      Do
      what = 'C1UEXTR7 after Backout/Backin'
      ADDRESS TSO "EXECIO 1 DISKR AUTHORIZ (Finis"
      pull BakoutCCID
      CALL BPXWDYN "FREE  DD(AUTHORIZ)"
      BakoutCCID = Strip(BakoutCCID)
      Call BKOUTLOG PECB_PACKAGE_ID 'After',
           BakoutCCID USERID()
      ModelMember = 'SHIPRUNS'
      Call SubmitBatchJCL
      Exit
      End
   /* If a package is executed, examine for package shipments */
   /* Examine NOTES to determine whether the Package NOTES    */
   /* contain Shipping instructions...                        */
       /* You can limit this action to packages with Approvals  */
       /* by including    the next line....                     */
       /* PECB_ACT_REC_EXIST_FLAG = 'Y' &,                      */
   IF PECB_BEF_AFTER_LITERAL = 'AFTER' &,
      (Substr(PECB_FUNCTION_LITERAL,1,4) = 'EXEC' |,
       Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK') then,
       Do
       TodaysDate = DATE('S') ;
       NOW  = TIME(L);
       HOUR = SUBSTR(NOW,1,2) ;
       IF HOUR = '00' THEN HOUR = '0'
       MINUTE = SUBSTR(NOW,4,2) ;
       CurrentTime= HOUR || MINUTE ;
       GetDestinationInfo_FilesAllocated  = 'N'
       TriggerFileName = '?'
       /* Pulling shipment data from package notes */
       /* Examine Package notes to find Destination and schedule info */
       /* - Submit Package Shipments for those that can be submitted  */
       /*       immeditely.                                           */
       /*       (future submissions are not supported )               */
        Do n# = 8 to 1 by -1
          noteline = VALUE('PHDR_PKG_NOTE' || n#)
          sa = noteline
          if Substr(noteline,1,3) /= "TO " then Iterate ;
          if Substr(noteline,12,2) /= ": " then Iterate ;
          If Words(noteline) < 6           then Iterate ;
          noteline = Substr(Overlay(" ",noteline,12),3) ;
          Destination = Word(noteline,1) ;
          /* Default to first model     */
          /* Get info for Destination   */
          Call  GetDestinationInfo;
          If Hostprefix = "?" then,
             Do
             Say 'PKGESHIP - Destination not found' Destination
             Iterate;
             End
          ShipSchedulingMethod = 'Notes'
          Call UpdateTriggerFromNotes
        End;  /*  Do n# = 8 to 1 by -1   */
       If GetDestinationInfo_FilesAllocated = 'Y' then,
          Call GetDestinationInfo_FreeFiles
       If TriggerFileName /= '?' then,
          Do
          "EXECIO 0 DISKW TRIGGER (Finis "
          Call FreeTriggerFile
          interpret 'Call' WhereIam "'MySEN2Library'"
          MySEN2Library     = Result
          PULLTGGRParms = USERID()'.PULLTGGR' MySEN2Library
          Call PULLTGGR PULLTGGRParms ;
          End /* If After EXEC | BACK */
       Exit
       End /* If After EXEC | BACK ... for Ship by NOTES */
   /* If a package is executed, examine for package shipments */
      /* You can limit this action to packages with Approvals  */
      /* by including    the next line....                     */
      /* PECB_ACT_REC_EXIST_FLAG = 'Y' &,                      */
   IF PECB_BEF_AFTER_LITERAL = 'AFTER' &,
      (Substr(PECB_FUNCTION_LITERAL,1,4) = 'EXEC' |,
       Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK') then,
       Do
       If TraceRQ = 'Y' then Say 'C1UEXTR7 is exiting @160 '
       /* Find PKGESHIP on GitHub in the folder-                 */
       /* endevor/Field-Developed-Programs/Package-Automation    */
       PKGESHIP_Parm = Copies(' ',055)
       PKGESHIP_Parm = Overlay(PECB_PACKAGE_ID     ,PKGESHIP_Parm,001)
       PKGESHIP_Parm = Overlay(PHDR_PKG_ENV        ,PKGESHIP_Parm,018)
       PKGESHIP_Parm = Overlay(PHDR_PKG_STGID      ,PKGESHIP_Parm,027)
       PKGESHIP_Parm = Overlay(REXX_EXEC_MODE      ,PKGESHIP_Parm,028)
       PKGESHIP_Parm = Overlay(PHDR_PKG_CREATE_USER,PKGESHIP_Parm,029)
       PKGESHIP_Parm = Overlay(PHDR_PKG_UPDATE_USER,PKGESHIP_Parm,037)
       PKGESHIP_Parm = Overlay(PHDR_PKG_CAST_USER  ,PKGESHIP_Parm,045)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE1      ,PKGESHIP_Parm,054)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE2      ,PKGESHIP_Parm,114)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE3      ,PKGESHIP_Parm,174)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE4      ,PKGESHIP_Parm,234)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE5      ,PKGESHIP_Parm,294)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE6      ,PKGESHIP_Parm,354)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE7      ,PKGESHIP_Parm,414)
       PKGESHIP_Parm = Overlay(PHDR_PKG_NOTE8      ,PKGESHIP_Parm,474)
       If Substr(PECB_FUNCTION_LITERAL,1,4) = 'BACK' then,
          PKGESHIP_Parm = Overlay('BAK'            ,PKGESHIP_Parm,584)
       Else,
          PKGESHIP_Parm = Overlay('OUT'            ,PKGESHIP_Parm,584)
       /* Find PKGESHIP on GitHub in the folder-                 */
       /* endevor/Field-Developed-Programs/Package-Automation    */
       Call PKGESHIP PKGESHIP_Parm
       If TraceRQ = 'Y' then Say 'C1UEXTR7 is exiting @183 '
       Exit
       End
   If MyRc > 0 then Call SetExitReturnInfo
   /* Another way to Determine if Trace is wanted...  */
   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRQ = 'Y'
   If TraceRQ = 'Y' then,
      Do
      Sa= 'CALL_REASON           = '    CALL_REASON
      Sa= 'PECB_FUNCTION_LITERAL = '    PECB_FUNCTION_LITERAL
      Sa= 'PECB_SUBFUNC_LITERAL  = '    PECB_SUBFUNC_LITERAL
      Sa= 'PECB_BEF_AFTER_LITERAL= '    PECB_BEF_AFTER_LITERAL
      Sa= 'PECB_PACKAGE_ID       = '    PECB_PACKAGE_ID
      Sa= 'MYSMTP_EMAIL_ID_SIZE  = '    MYSMTP_EMAIL_ID_SIZE
      End
   /* Early outs          ....                             */
   If PECB_FUNCTION_LITERAL = 'SETUP' then Exit
   /* Execute a SonarQube analysis?                        */
   /* Look at Notes to see if SonarQube processing or      */
   /* Package Shipment via Notes are given.                */
   /* Set to values indicating unassigned                  */
   If PECB_FUNCTION_LITERAL  ='CAST'     &,
      PECB_SUBFUNC_LITERAL   ='CAST'     &,
      PECB_BEF_AFTER_LITERAL ='BEFORE'   then,
        Do
        /* Set these to un-initialized values */
        Cast_Location_for_Sonarqube = ''
        Wait_for_SonarQube          = ''
        SonarQube_Element_Types     = ''
        /* Package notes may make or override SonarQube requests */
        Call CheckPackageNotesBeforeCast;
        If Cast_Location_for_Sonarqube /= 'none' then,
           Do
           SonarDSNPrefix = USERID()'.SONRQUBE.' || Unique_Name
           Call SonarQubeAnalysisAndKickoff
           End
        End; /* If PECB_FUNCTION_LITERAL  ='CAST' ... BEFORE */
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
   If TraceRQ = 'Y' then Say 'C1UEXTR7 is exiting @280 '
   EXIT
   If PECB_FUNCTION_LITERAL  ='CAST'     &,
      PECB_SUBFUNC_LITERAL   ='CAST'     &,
      PECB_APP_REC_EXIST_FLAG="Y"        &,
      PECB_BEF_AFTER_LITERAL ='AFTER'    then,
      Call ManageEmails    ;
   Exit
CheckPackageNotesBeforeCast:
   sa = Force_CAST_in_Batch
   /* Package notes may make or override SonarQube requests */
   AllNotes = PHDR_PKG_NOTE1 PHDR_PKG_NOTE2,
              PHDR_PKG_NOTE3 PHDR_PKG_NOTE4,
              PHDR_PKG_NOTE5 PHDR_PKG_NOTE6,
              PHDR_PKG_NOTE7 PHDR_PKG_NOTE8
   AllNotes = Translate(AllNotes,' ','="_')
   AllNotes = Translate(AllNotes,' ',"'-")
   /* To match any case, we are forcing upper case here */
   Upper AllNotes
   wheretext = Pos('RUN SONARQUBE', AllNotes)
   If wheretext > 0 then,
      Do
      Cast_Location_for_Sonarqube = 'notes'
      Force_CAST_in_Batch = 'Y' ;
      Say 'C1UEXTR7 - user notes request',
          'a SonarQube Analysis '
      End
   wheretext = Pos('BYPASS SONARQUBE WAIT', AllNotes)
   If wheretext > 0 then,
      Do
      Wait_for_SonarQube  = 'N'
      Say 'C1UEXTR7 - user notes request',
          'to Bypass the wait for the SonarQube Analysis'
      End
   wheretext = Pos('BYPASS SONARQUBE ANALYSIS', AllNotes)
   If wheretext > 0 then,
      Do
      Cast_Location_for_Sonarqube = 'none'
      Say 'C1UEXTR7 - user notes request',
          'SonarQube Analysis be bypassed'
      End
   Return
Get_Site_Shipping_Variables:
  /* Get the related site-level options */
  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
  /* ShipSchedulingMethod can be set by C1System */
  interpret 'Call' WhereIam,
           "'ShipSchedulingMethod_"PackageSystem"'"
  ShipSchedulingMethod = Result
  If Wordpos(ShipSchedulingMethod,'Rules Notes One None') = 0 then,
    Do
    interpret 'Call' WhereIam "'ShipSchedulingMethod'"
    ShipSchedulingMethod = Result
    End
  Return
Get_SonarQube_variables:
  /* If unassigned....                       */
  /* identify Choices for SonarQube Scanning */
  /* Cast_Location_for_Sonarqube can be set by C1System */
  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
  If Force_CAST_in_Batch /= 'Y' then,
     Do
     interpret 'Call' WhereIam,
        "'Force_CAST_in_Batch_"PackageSystem"'"
     Force_CAST_in_Batch   = Result
     End
  If Wordpos(Force_CAST_in_Batch,'Y N') = 0 then,
     Do
     interpret 'Call' WhereIam "'Force_CAST_in_Batch'"
     Force_CAST_in_Batch   = Result
     End
  If Cast_Location_for_Sonarqube = '' then,
     Do
     interpret 'Call' WhereIam,
              "'Cast_Location_for_Sonarqube_"PackageSystem"'"
     Cast_Location_for_Sonarqube = Result
     If Words(Cast_Location_for_Sonarqube) /= 2 then,
       Do
       interpret 'Call' WhereIam "'Cast_Location_for_Sonarqube'"
       Cast_Location_for_Sonarqube = Result
       End
     End ; /* If Words(Cast_Location_for_Sonarqube)  */
  If Cast_Location_for_Sonarqube = 'notes' |,
    Words(Cast_Location_for_Sonarqube)  = 2 then,
    Do
    If Wait_for_SonarQube  = '' then,
       Do
       /* If unassigned....                       */
       interpret 'Call' WhereIam,
                "'Wait_for_SonarQube_"PackageSystem"'"
       Wait_for_SonarQube            = Result
       If Length(Wait_for_SonarQube) /= 1 then,
         Do
         interpret 'Call' WhereIam "'Wait_for_SonarQube'"
         Wait_for_SonarQube            = Result
         End
       End; /* If Wait_for_SonarQube  = '' */
    interpret 'Call' WhereIam,
             "'SonarQube_Element_Types_"PackageSystem"'"
    SonarQube_Element_Types       = Result
    If SonarQube_Element_Types  = 'Not-valid' then,
      Do
      interpret 'Call' WhereIam "'SonarQube_Element_Types'"
      SonarQube_Element_Types       = Result
      End
    End /* If Cast_Location_for_Sonarqube ..... */
 Return ;
SonarQubeAnalysisAndKickoff:
  /* Do an EXPORT to Capture the Package SCL                  */
  Call CapturePackageSCL
  /* Convert exported SCL into a Table format                 */
  STRING = "ALLOC DD(RESULTS) LRECL(80) BLKSIZE(24000) ",
             " DSORG(PS) ",
             " SPACE(5,5) RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
  CALL BPXWDYN STRING;
  /* Use SCAN#SCL to create a TABLE from the SCL content      */
  /* Find SCAN#SCL on GitHub in the folder-                   */
  /* endevor/Field-Developed-Programs/Miscellaneous-items     */
  Call SCAN#SCL 'TABLE'
  /* Does this package require SonarQube analysis?   */
  "EXECIO * DISKR RESULTS (Stem tblscl. Finis"
  whereSystem = Pos('System ',tblscl.1)
  whereCommand= Pos('Command ',tblscl.1)
  whereEnvmnt = Pos('Envmnt ',tblscl.1)
  whereStg    = Pos(' S ',tblscl.1) + 1
  If whereSystem    = 0 |,
     whereCommand   = 0 |,
     whereEnvmnt    = 0 |,
     whereStg       = 0 then
      Do
      message = 'C1UEXTR7 -',
         'RESULTS Table format error or SCAN#SCL error '
      MyRc = 8
      Call SetExitReturnInfo
      Exit
      End / * If whereSystem    = 0 .....    */
  PackageSystem = word(Substr(tblscl.2,whereSystem),1)
  Call Get_SonarQube_variables
   /* If this site indicates all CASTS are to run in Batch */
  If  PECB_MODE = "T" &,          /* TSO foreground  */
      Force_CAST_in_Batch= 'Y'       then,                              ,
        Do
        ModelMember = 'CAST#JCL'
        Call SubmitBatchJCL
        Message = JobData
        MyRc        = 8
        PACKAGE = PECB_PACKAGE_ID
        MessageCode = 'U033'
        Call SetExitReturnInfo
        Exit
        End
   sa = Cast_Location_for_Sonarqube
   sa = SonarQube_Element_Types
  PackageCommand= word(Substr(tblscl.2,whereCommand),1)
  PackageEnvmnt = word(Substr(tblscl.2,whereEnvmnt),1)
  PackageStg    = word(Substr(tblscl.2,whereStg),1)
  /* Adjust the Environment and StageID if a MOVE action */
  If Cast_Location_for_Sonarqube /= 'notes' &,
     PackageCommand = 'MOVE' then,
     Do
     /* Find GTUNIQUE on GitHub in the folder-                   */
     /* endevor/Field-Developed-Programs/Miscellaneous-items     */
     NextLocation = GTNXTSTG(PackageEnvmnt PackageStg)
     PackageEnvmnt = Word(NextLocation,1)
     PackageStg    = Word(NextLocation,2)
     sa = Cast_Location_for_Sonarqube '|' PackageEnvmnt PackageStg
     End /* If PackageCommand = 'MOVE' */
  /* Based on just looking at Site variables, including those */
  /* for the c1System, we can                                 */
  /* Exit if a SonarQube run is not expected for this package */
  If Cast_Location_for_Sonarqube /= 'notes' &,
     Cast_Location_for_Sonarqube /= PackageEnvmnt PackageStg then,
       Do
       Call FREE_Files_For_ProcessingPackageSCL
       Return
       End
  /* Either Notes or Cast_Location_for_Sonarqube says    */
  /* we should continue.                                 */
  /* See if types are designated for SonarQube Scanning  */
  If Cast_Location_for_Sonarqube  = 'notes' then foundmatch = 1
  Else,
   Do
     foundmatch = 0
     /* Examine Element Types in package                */
     /* Search packaged types for list of SonarQube Types */
     whereType   = Pos('Type ',tblscl.1)
     Do typ# = 2 to tblscl.0
        C1ElType =   word(Substr(tblscl.typ#,whereType),1)
        Do s# = 1 to Words(SonarQube_Element_Types)
           typemask = Word(SonarQube_Element_Types,s#)
           /* Find QMATCH   on GitHub in the folder-              */
           /* endevor/Field-Developed-Programs/Miscellaneous-items*/
           foundmatch = QMATCH(C1ElType typemask)
           If foundmatch then Leave;
        End /* Do s# = 1 to Words(SonarQube_Element_Types) */
        If foundmatch then Leave;
     End; /* Do typ# = 2 to tblscl.0  */
   End /* Else.. If Cast_Location_for_Sonarqube  = 'notes' */
  /* Based on the types in this package, no SonarQube analysis*/
  /* is expected.                                             */
  If foundmatch = 0 then,
       Do
       Call FREE_Files_For_ProcessingPackageSCL
       Return
       End
  /* A SonarQube run is expected */
  /* Are we running in TSO foreground?               */
  If  PECB_MODE = "T" then,       /* TSO foreground  */
       Do
       Call FREE_Files_For_ProcessingPackageSCL
       ModelMember = 'CAST#JCL'
       Call SubmitBatchJCL
       Message = JobData
       MyRc        = 8
       PACKAGE = PECB_PACKAGE_ID
       MessageCode = 'U033'
       Call SetExitReturnInfo
       Exit
       End
  /* Running in Batch..                              */
  /* Preparing the SonarQube run. Create the Work file   */
  SonarWorkfile = SonarDSNPrefix || '.SONARWRK'
  SonarElmDSN   = SonarDSNPrefix || '.SONARELM'
  STRING = "ALLOC DD(WRKFILE) LRECL(080) BLKSIZE(24000) ",
             " DA("SonarWorkfile") ",
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",
             " SPACE(5,5) RECFM(F,B) CYL ",
             " NEW CATALOG REUSE ";
  CALL BPXWDYN STRING;
  CALL BPXWDYN "FREE DD(WRKFILE)"
  /* Save exported tblscl */
  CALL BPXWDYN "FREE DD(RESULTS)"
  STRING =,
     "ALLOC DD(RESULTS) DA("SonarWorkfile"(PKGTBL)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO" tblscl.0 "DISKW RESULTS (Stem tblscl. Finis"
  /* Save exported SCL */
  "EXECIO * DISKR SCL (Stem scl. Finis"
  CALL BPXWDYN "FREE DD(SCL)" ;
  STRING = "ALLOC DD(SCL) DA("SonarWorkfile"(SCL)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKW SCL (Stem scl. Finis"
  STRING = "ALLOC DD(SONARELM) LRECL(080) BLKSIZE(24000) ",
             " DA("SonarElmDSN") ",
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",
             " SPACE(5,5) RECFM(F,B) CYL ",
             " NEW CATALOG REUSE ";
  CALL BPXWDYN STRING;
  CALL BPXWDYN "FREE DD(SONARELM) "
  /* Create TimeStamp member in the SonarWorkfile    */
  TimeStamp = DATE('S') TIME()
  STRING="ALLOC DD(TIMESTMP) DA("SonarWorkfile"(@TIME)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "TimeStamp = '"TimeStamp"'"
  Queue "Package   = '"PECB_PACKAGE_ID"'"
  Queue "WaitOption= '"Wait_for_SonarQube"'"
  "EXECIO 3 DISKW TIMESTMP (FINIS ";   /* count queued */
  CALL BPXWDYN "FREE DD(TIMESTMP)" ;
  /* Find SONRQUBE on GitHub in the folder-                  */
  /* Field-Developed-Programs\SonarQube-interface-to-Endevor */
  Message =,
     SONRQUBE(PackageSystem,
              Wait_for_SonarQube,
              Unique_Name,
              PECB_PACKAGE_ID)
  Call FREE_Files_For_ProcessingPackageSCL
  If Message /= '' then,
     Do
     MyRc = 8
     Call SetExitReturnInfo
     End
  Return ;
CapturePackageSCL:
  STRING = "ALLOC DD(C1MSGS1) SYSOUT(A)"
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(BSTERR) SYSOUT(A)"
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(BSTAPI) SYSOUT(A)"
  CALL BPXWDYN STRING;
  /* Export the Package content into SCL        e    */
  STRING = "ALLOC DD(SCL) LRECL(080) BLKSIZE(24000) ",
              " DSORG(PS) ",
              " SPACE(5,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(ENPSCLIN) LRECL(80) BLKSIZE(24000) ",
             " DSORG(PS) ",
             " SPACE(5,5) RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
  CALL BPXWDYN STRING;
  QUEUE "EXPORT PACKAGE '"PECB_PACKAGE_ID"'"
  QUEUE "    TO DDN 'SCL' ."
  "EXECIO 2 DISKW ENPSCLIN (FINIS ";   /* count queued */
  ADDRESS LINK 'ENBP1000'   ;  /* run  from CSIQAUTH*/
  call_rc = rc ;
  CALL BPXWDYN "FREE DD(BSTAPI)  " ;
  CALL BPXWDYN "FREE DD(BSTERR)  " ;
  CALL BPXWDYN "FREE DD(C1MSGS1) " ;
  CALL BPXWDYN "FREE DD(ENPSCLIN)" ;
  /* Caller is responsible for freeing SCL */
  Return ;
CheckExecutionWindow:
  /* Check the Execution window for immediate package Execution */
  curntTimestamp = Substr(DATE('S'),3) || '@'|| Substr(TIME(),1,5)
  startTimestamp = ConvertDate(PREQ_EXEC_START_DATE) ||'@'||,
                               PREQ_EXEC_START_TIME
  sa= curntTimestamp startTimestamp PREQ_EXEC_START_DATE
  If curntTimestamp < startTimestamp then,
     Do
     GoExecute = 'N'
     Return
     End
  ENDTimestamp = ConvertDate(PREQ_EXEC_END_DATE) ||'@'||,
                             PREQ_EXEC_END_TIME
  sa= curntTimestamp ENDTimestamp PREQ_EXEC_END_DATE
  If curntTimestamp > ENDTimestamp then GoExecute = 'N'
  Return
ConvertDate:
  alphaMonths = 'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC'
  /* convert date from 24FEB26 format to a 260224 format */
  Arg dateToConvert
  ConvertedDay = Substr(dateToConvert,1,2)
  ConvertedMon = Substr(dateToConvert,3,3)
  ConvertedMon = WordPos(ConvertedMon,alphaMonths)
  ConvertedMon = Right(ConvertedMon,2,'0')
  ConvertedYear= Substr(dateToConvert,6,2)
  sa= thisYear ConvertedYear
  Converted_Date = Convertedyear || ConvertedMon || ConvertedDay
  return Converted_Date
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
       'From REXX(C1UEXTR7)'
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
SubmitBatchJCL:
  If TraceRQ = 'Y'             then Trace ?R
  whereami = 'SubmitBatchJCL'
  /* Variable settings for each site --->           */
  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
  interpret 'Call' WhereIam "'MySENULibrary'"
  MySENULibrary = Result
  interpret 'Call' WhereIam "'MySEN2Library'"
  MySEN2Library = Result
  interpret 'Call' WhereIam "'MyCLS0Library'"
  MyCLS0Library = Result
  interpret 'Call' WhereIam "'MyCLS2Library'"
  MyCLS2Library = Result
  /* Get job-related information from low address locations */
  /* Find GETACCTC on GitHub in the folder-                   */
  /* endevor/Field-Developed-Programs/Miscellaneous-items     */
  MyAccountingCode = GETACCTC()
  job_name         = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */
   /* Find BUMPJOB  on GitHub in the folder-                   */
   /* endevor/Field-Developed-Programs/Miscellaneous-items     */
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
  QUEUE "MyCLS0Library   ='"MyCLS0Library"'"
  QUEUE "MyCLS2Library   ='"MyCLS2Library"'"
  QUEUE "Unique_Name     ='"Unique_Name"'"
  QUEUE "PECB_PACKAGE_ID ='"PECB_PACKAGE_ID"'"
  QUEUE "Jobname= '"Jobname"'"
  QUEUE "TBLOUT = 'SUBMTJCL'"
  "EXECIO 10 DISKW OPTIONS (FINIS ";  /* count queued */
  /* For CASTing a package in Batch                           */
  /*   Build a JCL model, and name its location here....      */
    /* Name a work dataset to be created then deleted...        */
  Jcl2SumbitModel = MySEN2Library || '(' || ModelMember || ')'
  "ALLOC F(MODEL) DA('"Jcl2SumbitModel"') SHR REUSE"
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
  Return;
Submit_n_save_jobInfo: /* submit Jcl2SumbitModel job and save job info */
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
FREE_Files_For_ProcessingPackageSCL:
   CALL BPXWDYN "FREE DD (SCL)    "
   CALL BPXWDYN "FREE DD (RESULTS)"
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
/* ////  Routines to support Package Shipments from NOTES \\\\ */
UpdateTriggerFromNotes:
   If TriggerFileName = '?' then,
      Do
      Call AllocateTriggerForMod
      Call Process_Trigger_Heading
      End
   Date            = Word(noteline,2) ;
   Time            = Word(noteline,3) ;
   Jobname         = Word(noteline,4) ;
   Notify          = " "
   TYPRUN  = ' '
   If Words(noteline) > 4 then,
      If Word(noteline,5) = "HOLD" |,
         Word(noteline,5) = "SCAN" then,
         TYPRUN      = Word(noteline,5)
   Call CreateNewTriggerEntry
   /* endevor/Field-Developed-Programs/Package-Automation    */
   BildRC = RESULT ;
   Return ;
GetDestinationInfo_FileAllocations:
   GetDestinationInfo_FilesAllocated = 'Y'
   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   STRING = "ALLOC DD(C1MSGS1) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTAPI) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(DESTINFO) LRECL(4000) BLKSIZE(32000) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   Return
GetDestinationInfo:
   /* Set values for Hostprefix and Rmteprefix */
   /*     From the site definition             */
   /*  Call CSV to Get Destination information  */
   Hostprefix = "?"
   Rmteprefix = "?"
   If GetDestinationInfo_FilesAllocated /= 'Y' then,
      Call GetDestinationInfo_FileAllocations
   QUEUE "LIST DESTINATION '"Destination"'"
   QUEUE "     TO DDNAME 'DESTINFO' "
   QUEUE "          OPTIONS NOCSV . "
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";
   CALL BPXWDYN "INFO FI(CONLIB) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then,
      Do
      CSVParm = 'DDN:CONLIB,BC1PCSV0'
      ADDRESS LINKMVS 'CONCALL' "CSVParm"
      End
   Else,
      ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */
   call_rc = rc ;
  Drop apiDestinations.
  "EXECIO * DISKR DESTINFO (STEM apiDestinations. finis"
   IF apiDestinations.0 < 1 THEN RETURN;
   Hostprefix = Strip(Substr(apiDestinations.1,079,14))
   Rmteprefix = Strip(Substr(apiDestinations.1,113,14))
   Return ;
GetDestinationInfo_FreeFiles:
   CALL BPXWDYN "FREE DD(DESTINFO)" ;
   CALL BPXWDYN "FREE DD(BSTIPT01)" ;
   CALL BPXWDYN "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN "FREE DD(BSTERR)" ;
   CALL BPXWDYN "FREE DD(BSTAPI)" ;
   Return ;
   /* From PKGESHIP   */
SubmitPackageShipmentFromNotes:
/*                                                                    */
/* This subroutine is modified from the TBL#TOOL                      */
/*                                                                    */
   "EXECIO * DISKR "MODEL "(STEM $Model. FINIS" ;
   $delimiter = "|" ;
   DO $LINE = 1 TO $Model.0
      $PLACE_VARIABLE = 1;
      CALL EVALUATE_SYMBOLICS ;
      END; /* DO $LINE = 1 TO $Model.0 */
   STRING = "ALLOC DD(SHIPJCL) LRECL(80) BLKSIZE(27920) ",
              " DA("USERID()".SHIPJCL."Destination")",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW CATALOG REUSE ";
   CALL BPXWDYN STRING;
   "EXECIO * DISKW SHIPJCL (STEM $Model. FINIS" ;
   If RunUnderAltid  = 'Y' then CALL SWAP2ALT
   Call Submit_Job ;
   If RunUnderAltid  = 'Y' then CALL SWAP2USR
   Drop $Model. ;
   STRING = "FREE DD(SHIPJCL) DELETE"
   CALL BPXWDYN STRING;
   RETURN;
   /* From BILDTGGR   */
AllocateTriggerForMod:
  /* Get the related site-level options */
  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
  interpret 'Call' WhereIam "'TriggerFileName'"
  TriggerFileName = Result
   STRING = "ALLOC DD(TRIGGER)",
              " DA('"TriggerFileName"') MOD REUSE"
   seconds = '000005' /* Number of Seconds to wait if needed */
   Do Forever  /* or at least until the file is available */
      CALL BPXWDYN STRING;
      MyResult = RESULT ;
      If MyResult = 0 then Leave
      Say 'C1UEXTR7 is waiting for' TriggerFileName
      Call WaitAwhile
   End /* Do Forever */
   Return ;
   /* From BILDTGGR   */
CreateNewTriggerEntry:
   If TraceRc = 1 then Say 'CreateNewTriggerEntry+            '
   If TraceRc = 1 then Trace r
   St = '_'
   JOBNUMB = ' '
   Package = PECB_PACKAGE_ID
   Trigger = Copies(' ',400) ;
   $Heading_TriggerVar_count = WORDS($trigger_variables) ;
   Do $pos = 1 to $Heading_TriggerVar_count
      $HeadingVariable = Word($trigger_variables,$pos) ;
      /* Build ...pos variables and values */
      tmp = "Trigger = Overlay(",
            $HeadingVariable",Trigger,"$HeadingVariable"pos)"
      SaY tmp
      Interpret tmp
   end; /* DO $pos = 1 to $Heading_TriggerVar_count */
   Sa= Trigger
   Push Trigger
   "EXECIO 1 DISKW TRIGGER "
   Return ;
   /* From BILDTGGR   */
FreeTriggerFile:
   STRING = "FREE DD(TRIGGER)"
   CALL BPXWDYN STRING;
   Return ;
/*                                                                    */
/* Convert Date formats                                               */
/*                                                                    */
WaitAwhile:
  /*                                                               */
  /* A resource is unavailable. Wait awhile and try                */
  /*   accessing the resource again.                               */
  /*                                                               */
  /*   The length of the wait is designated in the parameter       */
  /*   value which specifies a number of seconds.                  */
  /*   A parameter value of '000003' causes a wait for 3 seconds.  */
  /*                                                               */
  seconds = Abs(seconds)
  seconds = Trunc(seconds,0)
  Say "Waiting for" seconds "seconds at " DATE(S) TIME()
  /* AOPBATCH and BPXWDYN are IBM programs */
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"
  /* AOPBATCH and BPXWDYN are IBM programs */
  parm = "sleep "seconds
  Address LINKMVS "AOPBATCH parm"
  Return
Process_Trigger_Heading :
   sa= 'Process_Trigger_Heading'
   "EXECIO 1 DISKR TRIGGER (Stem $tablerec. FINIS"
/* Get layout of TRIGGER file from heading */
/* The subroutine below is modified from the TBL#TOOL                 */
   $tbl = 1 ;
   $TableHeadingChar = '*'
   $LastWord = Word($tablerec.$tbl,Words($tablerec.$tbl));
   If DATATYPE($LastWord) = 'NUM' then,
      Do
      Say 'Please remove sequence numbers from the Table'
      Exit(12)
      End
   $tmprec = Substr($tablerec.$tbl,2) ;
   $PositionSpclChar = POS('-',$tmprec) ;
   If $PositionSpclChar = 0 then,
      $PositionSpclChar = POS('*',$tmprec) ;
   $tmpreplaces = '-,.'$TableHeadingChar ;
   $tmprec = TRANSLATE($tmprec,' ',$tmpreplaces);
   $table_variables = strip($tmprec);
   $Heading_Variable_count = WORDS($table_variables) ;
   If $Heading_Variable_count /=,
      Words(Substr($tablerec.$tbl,2)) then,
      Do
      Say 'Invalid table Heading:' $tablerec.$tbl
      exit(12)
      End
   $heading = Overlay(' ',$tablerec.$tbl,1); /* Space leading * */
   Do $pos = 1 to $Heading_Variable_count
      $HeadingVariable = Word($table_variables,$pos) ;
      $tmp = Wordindex($Heading,$pos) ;
      $Starting_$position.$HeadingVariable = $tmp
      $tmp = $tmp + Length(Word($Heading,$pos)) -1 ;
      $Ending_$position.$HeadingVariable = $tmp
      /* Build ...pos variables and values */
      tmp = ""$HeadingVariable"pos =",
             $Starting_$position.$HeadingVariable
      Sa= tmp
      Interpret tmp
   end; /* DO $pos = 1 to $Heading_Variable_count */
   $Heading = Translate($Heading,' ','-*')
   $trigger_variables = $Heading
   Return ;
/* \\\\  Routines to support Package Shipments from NOTES //// */
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
