       PROCESS DYNAM OUTDD(DISPLAYS)                                            
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. C1UEXT07.                                                    
      *****************************************************************         
      * DESCRIPTION: THIS PGM IS CALLED for misc Package actions.               
      *              It gathers Endevor info from the exit blocks               
      *              then calls REXX program C1UEXTR7.                          
      ************************************************************              
      *   https://github.com/BroadcomMFD/broadcom-product-scripts               
      ************************************************************              
      * Change the Dataset references within this program:       *              
      * 1) Find all "DA("                                        *              
      * 2) Change each dataset name to your REXX library         *              
      ************************************************************              
       ENVIRONMENT DIVISION.                                                    
       INPUT-OUTPUT SECTION.                                                    
       FILE-CONTROL.                                                            
      **                                                                        
       DATA DIVISION.                                                           
       FILE SECTION.                                                            
       WORKING-STORAGE SECTION.                                                 
       COPY NOTIFYDS.                                                           
       01  WS-VGET     PIC X(8)  VALUE 'VGET    '.                              
       01  WS-PROFILE  PIC X(8)  VALUE 'PROFILE '.                              
       01  WS-ISPLINK  PIC X(8)  VALUE 'ISPLINK ' .                             
       01  WS-C1BJC1-JOBCARD   PIC X(80) .                                      
       01  WS-C1BJC1 PIC X(08) VALUE '(C1BJC1)'.                                
       01  WS-C1PJC1-JOBCARD   PIC X(80) .                                      
       01  WS-C1PJC1 PIC X(08) VALUE '(C1PJC1)'.                                
       01  WS-CALLING-REASON   PIC X(24).                                       
       01 WS-VARIABLES.                                                         
          03  WS-POINTER                   PIC 9(09) COMP.                      
          03  WS-WORK-ADDRESS-ADR          PIC 9(09) COMP SYNC .                
          03  WS-WORK-ADDRESS-PTR          REDEFINES WS-WORK-ADDRESS-ADR        
                                           USAGE IS POINTER .                   
          03  WS-PECB-REQUEST-RETURNCODE     PIC 9999 .                         
          03  WS-PECB-NDVR-HIGH-RC           PIC 9999 .                         
          03  WS-DISPLAY-NUMBER-FOR4         PIC 9(04) .                        
          03  WS-DISPLAY-NUMBER-FOR9         PIC 9(09) .                        
                                                                        00490200
       01  PGM                                   PIC X(8).                      
       01  MYSMTP-MESSAGE                        PIC X(80).                     
       01  MYSMTP-USERID                         PIC X(8).                      
       01  MYSMTP-FROM                           PIC X(50).                     
       01  MYSMTP-SUBJECT                        PIC X(50).                     
       01  MYSMTP-TEXT.                                                         
           03  MYSMTP-COUNTER                    PIC 9(2).                      
           03  MYSMTP-MSG-TEXT.                                                 
                05  MYSMTP-LINE                  PIC X(133) OCCURS 99.          
       01  MYSMTP-URL                            PIC X(1).                      
       01  MYSMTP-EMAIL-IDS.                                                    
           03  FILLER                            PIC X(09)                      
                                                 OCCURS 320 .                   
           03  FILLER                            PIC X(8).                      
       01  MYSMTP-EMAIL-ID-SIZE                  PIC 9(8).                      
       01 WS-ADDRESSES.                                                         
          03  ADDRESS-MYSMTP-MESSAGE         PIC 9(09) .                        
          03  ADDRESS-MYSMTP-USERID          PIC 9(09) .                        
          03  ADDRESS-MYSMTP-FROM            PIC 9(09) .                        
          03  ADDRESS-MYSMTP-SUBJECT         PIC 9(09) .                        
          03  ADDRESS-MYSMTP-TEXT            PIC 9(09) .                        
          03  ADDRESS-MYSMTP-URL             PIC 9(09) .                        
          03  ADDRESS-MYSMTP-EMAIL-IDS       PIC 9(09) .                        
                                                                        00510000
          03  ADDRESS-PECB-NDVR-EXIT-RC      PIC 9(09) .                        
          03  ADDRESS-PECB-MESSAGE-ID        PIC 9(09) .                        
          03  ADDRESS-PECB-MESSAGE           PIC 9(09) .                        
          03  ADDRESS-PECB-ERROR-MESS-LENGTH PIC 9(09) .                        
          03  ADDRESS-PECB-MODS-MADE-TO-PREQ PIC 9(09) .                        
          03  ADDRESS-PREQ-SHARE-ENABLED     PIC 9(09) .                        
          03  ADDRESS-PREQ-BACKOUT-ENABLED   PIC 9(09) .                        
       01 BPXWDYN PIC X(8) VALUE 'BPXWDYN'.                                     
       01 ALLOC-STRING.                                                         
          05 ALLOC-LENGTH PIC S9(4) BINARY VALUE 100.                           
          05 ALLOC-TEXT   PIC X(100).                                           
       01  IRXJCL                            PIC X(6)  VALUE 'IRXJCL'.          
       01  IRXEXEC-PGM                       PIC X(08) VALUE 'IRXEXEC'.         
      *                                                                         
      * DEFINE THE IRXEXEC DATA AREAS AND ARG BLOCKS                            
      *                                                                         
       77  WS-INX                            PIC 9(08) COMP .                   
       77  FLAGS                             PIC S9(8) BINARY.                  
       77  REXX-RETURN-CODE                  PIC S9(8) BINARY.                  
       77  DUMMY-ZERO                        PIC S9(8) BINARY.                  
       77  LPAR-ID                           PIC X(04).                         
           88  DO-NOT-PROCESS-LPAR                     VALUE 'SKIP'.            
       77  ARG1                              PIC X(16).                         
       77  UPDPRINT-FILE-STATUS              PIC X(02).                         
       77  ARGUMENT-PTR                      POINTER.                           
       77  EXECBLK-PTR                       POINTER.                           
       77  ARGTABLE-PTR                      POINTER.                           
       77  EVALBLK-PTR                       POINTER.                           
       77  TEMP-PTR                          POINTER.                           
       01  EXECBLK.                                                             
           05 EXECBLK-ACRYN                  PIC X(08) VALUE 'IRXEXECB'.        
           05 EXECBLK-LENGTH                 PIC S9(8) BINARY                   
                                                       VALUE 48.                
           05 EXECBLK-RESERVED               PIC S9(8) BINARY                   
                                                       VALUE 0.                 
           05 EXECBLK-MEMBER                 PIC X(08) VALUE 'C1UEXTR7'.        
           05 EXECBLK-DDNAME                 PIC X(08) VALUE 'REXFILE7'.        
           05 EXECBLK-SUBCOM                 PIC X(08) VALUE SPACES.            
           05 EXECBLK-DSNPTR                 POINTER   VALUE NULL.              
           05 EXECBLK-DSNLEN                 PIC 9(04) COMP                     
                                                       VALUE 0.                 
       01  EVALBLK.                                                             
           05 EVALBLK-EVPAD1                 PIC S9(8) BINARY                   
                                                       VALUE 0.                 
           05 EVALBLK-EVSIZE                 PIC S9(8) BINARY                   
                                                       VALUE 34.                
           05 EVALBLK-EVLEN                  PIC S9(8) BINARY                   
                                                       VALUE 0.                 
           05 EVALBLK-EVPAD2                 PIC S9(8) BINARY                   
                                                       VALUE 0.                 
           05 EVALBLK-EVDATA                 PIC X(256).                        
       01  ARGUMENT.                                                            
           02 ARGUMENT-1                     OCCURS 1 TIMES.                    
              05 ARGSTRING-PTR               POINTER.                           
              05 ARGSTRING-LENGTH            PIC S9(8) BINARY.                  
           02 ARGSTRING-LAST1                PIC S9(8) BINARY                   
                                                       VALUE -1.                
           02 ARGSTRING-LAST2                PIC S9(8) BINARY                   
                                                       VALUE -1.                
      * The block of data below can be used with either an                      
      * IRXJCL or IRXEXEC call to the rexx program C1UEXTR7.                    
      * IRXJCL is used when running in batch (batch CAST) .                     
      * IRXEXEC is used when running in foreground (CAST or APPROVE).           
       01  PKG-C1UEXTR7-PARMS-IRXJCL.                                           
         02  PKG-C1UEXTR7-PARMS-IRXJCL-TOP.                                     
           03 PARM-LENGTH          PIC X(2) VALUE X'0BC1'.                      
           03 REXX-NAME            PIC X(8) VALUE 'C1UEXTR7'.                   
           03 FILLER               PIC X(1) VALUE SPACE .                       
         02  PKG-C1UEXTR7-PARMS-IRXEXEC.                                        
           03 WS-REXX-STATEMENTS   PIC X(3000).                                 
       LINKAGE SECTION.                                                         
       COPY PKGXBLKS.                                                           
       PROCEDURE DIVISION USING                                                 
               PACKAGE-EXIT-BLOCK                                               
               PACKAGE-REQUEST-BLOCK                                            
               PACKAGE-EXIT-HEADER-BLOCK                                        
               PACKAGE-EXIT-FILE-BLOCK                                          
               PACKAGE-EXIT-ACTION-BLOCK                                        
               PACKAGE-EXIT-APPROVER-MAP                                        
               PACKAGE-EXIT-BACKOUT-BLOCK                                       
               PACKAGE-EXIT-SHIPMENT-BLOCK                                      
               PACKAGE-EXIT-SCL-BLOCK.                                          
      ****                                                                      
      **** IF PECB-USER-BATCH-JOBNAME(1:7) NOT = 'IBMUSER' AND                  
      ****    PECB-USER-BATCH-JOBNAME(1:7) NOT = 'PL05958'                      
      ****    GOBACK.                                                           
      ****                                                                      
*********  DISPLAY 'C1UEXT07: GOT INTO C1UEXTT7'.                               
*********  MOVE PECB-FUNCTION-CODE TO WS-DISPLAY-NUMBER-FOR9.                   
*********  DISPLAY 'PECB-FUNCTION-CODE=' WS-DISPLAY-NUMBER-FOR9.                
           IF  SETUP-EXIT-OPTIONS                                               
               MOVE ZERO TO PECB-UEXIT-HOLD-FIELD                               
*********    to enforce package create rules                                    
               MOVE 'Y'   TO PECB-BEFORE-CREATE-BLD                             
               MOVE 'Y'   TO PECB-BEFORE-CREATE-COPY                            
               MOVE 'Y'   TO PECB-BEFORE-CREATE-EDIT                            
               MOVE 'Y'   TO PECB-BEFORE-CREATE-IMPT                            
               MOVE 'Y'   TO PECB-BEFORE-REV-APPR                               
*********    to enforce package backout = Y                                     
               MOVE 'Y'   TO PECB-BEFORE-CAST                                   
*********    to enforce Approver Group Sequencing                               
               MOVE 'Y'   TO PECB-AFTER-REV-APPR                                
               MOVE 'Y'   TO PECB-AFTER-CAST                                    
               MOVE 'Y'   TO PECB-MID-CAST                                      
*********      MOVE 'Y'   TO PECB-BEFORE-MOD-IMPT                               
*********      MOVE 'Y'   TO PECB-AFTER-RESET                                   
*********      MOVE 'Y'   TO PECB-AFTER-DELETE                                  
*********    to support automated package shipping                              
               MOVE 'Y'   TO PECB-AFTER-EXEC                                    
               MOVE 'Y'   TO PECB-REQ-ELEMENT-ACTION-BIBO                       
               MOVE 'Y'   TO PECB-BEFORE-BACKOUT                                
               MOVE 'Y'   TO PECB-BEFORE-BACKIN                                 
               MOVE 'Y'   TO PECB-AFTER-BACKOUT                                 
               MOVE 'Y'   TO PECB-AFTER-BACKIN                                  
*********    to support submission of package Execute jobs                      
**done***      MOVE 'Y'   TO PECB-AFTER-REV-APPR                                
**done***      MOVE 'Y'   TO PECB-AFTER-CAST                                    
               MOVE ZEROS TO RETURN-CODE                                        
               GOBACK.                                                          
           MOVE 0 TO PECB-NDVR-EXIT-RC.                                         
           MOVE SPACES TO WS-REXX-STATEMENTS  .                                 
*********  If just starting out, request Approver Group info                    
           IF PECB-REQUEST-RETURNCODE = 0 AND PECB-AFTER AND                    
              (CAST-PACKAGE OR REVIEW-PACKAGE)                                  
              PERFORM 1000-ALLOCATE-REXFILE                                     
              MOVE 'Y'  TO  PECB-REQ-APPROVER-REC                               
              GOBACK                                                            
           ELSE                                                                 
*********  If we just received an Appprover Group block,                        
*********     pass it to the REXX and ask for more...                           
           IF PECB-SUCCESSFUL-RECORD-SENT                                       
              MOVE PAPP-SEQUENCE-NUMBER TO WS-DISPLAY-NUMBER-FOR4               
              MOVE SPACES TO WS-CALLING-REASON                                  
              STRING 'Approver Group #'                                         
                WS-DISPLAY-NUMBER-FOR4                                          
                     DELIMITED BY SIZE                                          
                INTO WS-CALLING-REASON                                          
              END-STRING                                                        
              PERFORM 0500-CALL-C1UEXTR7-REXX                                   
              MOVE 'Y'  TO  PECB-REQ-APPROVER-REC                               
              GOBACK                                                            
           ELSE                                                                 
*********  Endevor says 'no more Appprover Group blocks'                        
*********     tell REXX and let it decide on email                              
           IF PECB-END-OF-FILE-FOR-REC-TYP OR                                   
              PECB-NO-RECORDS-FOUND                                             
              MOVE 'NO MORE Approver Grps ' TO WS-CALLING-REASON                
              PERFORM 0500-CALL-C1UEXTR7-REXX                                   
              IF MYSMTP-COUNTER NUMERIC AND                                     
                 MYSMTP-COUNTER GREATER THAN '00' AND                           
                 MYSMTP-EMAIL-IDS(1:1) GREATER THAN SPACE                       
                 MOVE 'BC1PMLIF'    TO    PGM                                   
                 PERFORM 0900-SEND-EMAILS                                       
              END-IF                                                            
              PERFORM 2000-FREE-REXFILES                                        
              GOBACK                                                            
           ELSE                                                                 
*********  If Before the CAST, just pass Package info to the REXX               
           IF (PECB-BEFORE    OR PECB-MID)     AND                              
              (CREATE-PACKAGE OR CAST-PACKAGE)                                  
              IF CREATE-PACKAGE                                                 
                 MOVE 'Before CREATE' TO WS-CALLING-REASON                      
              ELSE                                                              
                 MOVE 'Before CAST' TO WS-CALLING-REASON                        
              END-IF.                                                           
*********  For many conditions, call REXX and let it decide what to do          
           PERFORM 1000-ALLOCATE-REXFILE.                                       
           PERFORM 0500-CALL-C1UEXTR7-REXX.                                     
           PERFORM 2000-FREE-REXFILES.                                          
       0100-MAIN-EXIT.                                                          
           GOBACK.                                                              
       0500-CALL-C1UEXTR7-REXX.                                                 
      *    Give addresses of updatable fields to the REXX.                      
      *    MAKES A CALL TO THE REXX ROUTINE C1UEXTR7.                           
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-MESSAGE .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-MESSAGE.                      
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-USERID  .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-USERID .                      
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-FROM    .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-FROM   .                      
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-SUBJECT .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-SUBJECT.                      
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-TEXT    .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-TEXT   .                      
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-URL     .                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-URL    .                      
           MOVE SPACES TO MYSMTP-EMAIL-IDS .                                    
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-EMAIL-IDS .                                   
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-MYSMTP-EMAIL-IDS .                   
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF MYSMTP-EMAIL-ID-SIZE .                               
           COMPUTE MYSMTP-EMAIL-ID-SIZE =                                       
                     WS-WORK-ADDRESS-ADR - 4 -                                  
                     ADDRESS-MYSMTP-EMAIL-IDS .                                 
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PECB-NDVR-EXIT-RC .                                  
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PECB-NDVR-EXIT-RC.                   
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PECB-MESSAGE      .                                  
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PECB-MESSAGE     .                   
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PECB-ERROR-MESS-LENGTH .                             
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PECB-ERROR-MESS-LENGTH.              
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PECB-MODS-MADE-TO-PREQ .                             
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PECB-MODS-MADE-TO-PREQ.              
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PECB-MESSAGE-ID.                                     
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PECB-MESSAGE-ID .                    
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PREQ-SHARE-ENABLED.                                  
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PREQ-SHARE-ENABLED .                 
           SET  WS-WORK-ADDRESS-PTR TO                                          
                ADDRESS OF PREQ-BACKOUT-ENABLED.                                
           MOVE WS-WORK-ADDRESS-ADR                                             
                                TO ADDRESS-PREQ-BACKOUT-ENABLED .               
           MOVE PECB-REQUEST-RETURNCODE TO                                      
                WS-PECB-REQUEST-RETURNCODE.                                     
           MOVE PECB-NDVR-HIGH-RC       TO                                      
                WS-PECB-NDVR-HIGH-RC      .                                     
      *****                                                                     
      ***** / Convert COBOL exit block Datanames into Rexx \                    
      *****                                                                     
      *****                                                                     
           MOVE 1 TO WS-POINTER.                                                
           STRING                                                               
              'PECB_PACKAGE_ID = "' PECB-PACKAGE-ID '";'                        
              'PECB_FUNCTION_LITERAL="' PECB-FUNCTION-LITERAL '";'              
              'PECB_SUBFUNC_LITERAL="' PECB-SUBFUNC-LITERAL '";'                
              'PECB_BEF_AFTER_LITERAL="' PECB-BEF-AFTER-LITERAL '";'            
              'PECB_USER_BATCH_JOBNAME="' PECB-USER-BATCH-JOBNAME '";'          
              'PREQ_PKG_CAST_COMPVAL="' PREQ-PKG-CAST-COMPVAL '";'              
              'PHDR_PKG_SHR_OPTION  ="' PHDR-PKG-SHR-OPTION '";'                
              'PHDR_PKG_ENV ="' PHDR-PKG-ENV '";'                               
              'PHDR_PKG_STGID ="' PHDR-PKG-STGID '";'                           
              'PECB_MODE = "' PECB-MODE '";'                                    
              'PECB_AUTOCAST ="' PECB-AUTOCAST '";'                             
              'PECB_ACT_REC_EXIST_FLAG="' PECB-ACT-REC-EXIST-FLAG '";'          
              'PECB_APP_REC_EXIST_FLAG="' PECB-APP-REC-EXIST-FLAG '";'          
              'PECB_BAC_REC_EXIST_FLAG="' PECB-BAC-REC-EXIST-FLAG '";'          
              'PECB_REQUEST_RETURNCODE=' WS-PECB-REQUEST-RETURNCODE ';'         
              'PECB_NDVR_HIGH_RC = ' WS-PECB-NDVR-HIGH-RC ';'                   
              'PREQ_BACKOUT_ENABLED="' PREQ-BACKOUT-ENABLED '";'                
              'Address_PREQ_BACKOUT_ENABLED='                                   
                   ADDRESS-PREQ-BACKOUT-ENABLED ';'                             
              'PREQ_SHARE_ENABLED="' PREQ-SHARE-ENABLED '";'                    
              'Address_PREQ_SHARE_ENABLED='                                     
                   ADDRESS-PREQ-SHARE-ENABLED ';'                               
              'Address_PECB_MODS_MADE_TO_PREQ='                                 
                   ADDRESS-PECB-MODS-MADE-TO-PREQ ';'                           
              'Address_PECB_NDVR_EXIT_RC='                                      
                   ADDRESS-PECB-NDVR-EXIT-RC ';'                                
              'Address_PECB_MESSAGE_ID=' ADDRESS-PECB-MESSAGE-ID ';'            
              'Address_PECB_ERROR_MESS_LENGTH = '                               
                   ADDRESS-PECB-ERROR-MESS-LENGTH ';'                           
              'Address_PECB_MESSAGE = ' ADDRESS-PECB-MESSAGE ';'                
              'Address_MYSMTP_MESSAGE=' ADDRESS-MYSMTP-MESSAGE ';'              
              'Address_MYSMTP_USERID =' ADDRESS-MYSMTP-USERID ';'               
              'Address_MYSMTP_FROM   =' ADDRESS-MYSMTP-FROM ';'                 
              'Address_MYSMTP_SUBJECT=' ADDRESS-MYSMTP-SUBJECT ';'              
              'Address_MYSMTP_TEXT   =' ADDRESS-MYSMTP-TEXT ';'                 
              'Address_MYSMTP_URL    =' ADDRESS-MYSMTP-URL ';'                  
              'Address_MYSMTP_EMAIL_IDS='                                       
                   ADDRESS-MYSMTP-EMAIL-IDS ';'                                 
              'MYSMTP_EMAIL_ID_SIZE='                                           
                     MYSMTP-EMAIL-ID-SIZE ';'                                   
                     DELIMITED BY SIZE                                          
              INTO   WS-REXX-STATEMENTS                                         
              WITH POINTER WS-POINTER .                                         
*********  For these text fields, make sure none use a double quote             
*********  character. This ensures the integrity of the REXX                    
           IF REVIEW-PACKAGE OR                                                 
              (CAST-PACKAGE AND PECB-AFTER)                                     
              MOVE PAPP-QUORUM-COUNT TO WS-DISPLAY-NUMBER-FOR4                  
              STRING                                                            
                'CALL_REASON="' WS-CALLING-REASON '";'                          
                'PAPP_GROUP_NAME ="' PAPP-GROUP-NAME '";'                       
                'PAPP_GROUP_NAME ="' PAPP-GROUP-NAME '";'                       
                'PAPP_ENVIRONMENT="' PAPP-ENVIRONMENT '";'                      
                'PAPP_QUORUM_COUNT="' WS-DISPLAY-NUMBER-FOR4 '";'               
                'PAPP_APPROVER_FLAG="' PAPP-APPROVER-FLAG '";'                  
                'PAPP_APPR_GRP_TYPE="' PAPP-APPR-GRP-TYPE '";'                  
                'PAPP_APPR_GRP_DISQ="' PAPP-APPR-GRP-DISQ '";'                  
                   DELIMITED BY SIZE                                            
                'PAPP_APPROVAL_IDS= "'                                          
                   DELIMITED BY SIZE                                            
                INTO   WS-REXX-STATEMENTS                                       
                WITH POINTER WS-POINTER                                         
              END-STRING                                                        
              PERFORM VARYING WS-INX  FROM 1 BY 1 UNTIL                         
                WS-INX GREATER THAN PAPP-APPROVER-NUMBER                        
                STRING PAPP-APPROVAL-ID(WS-INX) ' '                             
                   DELIMITED BY SIZE                                            
                   INTO   WS-REXX-STATEMENTS                                    
                   WITH POINTER WS-POINTER                                      
                END-STRING                                                      
              END-PERFORM                                                       
              STRING   '";'                                                     
                   'PAPP_APPROVAL_FLAGS= "'                                     
                   DELIMITED BY SIZE                                            
                   INTO   WS-REXX-STATEMENTS                                    
                   WITH POINTER WS-POINTER                                      
              END-STRING                                                        
              PERFORM VARYING WS-INX  FROM 1 BY 1 UNTIL                         
                WS-INX GREATER THAN PAPP-APPROVER-NUMBER                        
                STRING PAPP-APPROVAL-FLAG(WS-INX) ' '                           
                   DELIMITED BY SIZE                                            
                INTO   WS-REXX-STATEMENTS                                       
                WITH POINTER WS-POINTER                                         
                END-STRING                                                      
              END-PERFORM                                                       
              STRING   '";'                                                     
                   DELIMITED BY SIZE                                            
                   INTO   WS-REXX-STATEMENTS                                    
                   WITH POINTER WS-POINTER                                      
              END-STRING                                                        
           END-IF.                                                              
*******    Replace any double quote characters in data to be passed             
           IF CAST-PACKAGE                                                      
              INSPECT PREQ-PACKAGE-COMMENT REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE1       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE2       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE3       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE4       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE5       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE6       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE7       REPLACING ALL '"' BY X'7D'           
              INSPECT PHDR-PKG-NOTE8       REPLACING ALL '"' BY X'7D'           
              STRING                                                            
                'CALL_REASON="' WS-CALLING-REASON '";'                          
                'PREQ_PACKAGE_COMMENT = "' PREQ-PACKAGE-COMMENT '";'            
                'PHDR_PACKAGE_TYPE = "' PHDR-PACKAGE-TYPE '";'                  
                'PHDR_PACKAGE_STATUS = "' PHDR-PACKAGE-STATUS '";'              
                'PHDR_PKG_BACKOUT_STATUS="' PHDR-PKG-BACKOUT-STATUS '";'        
                'PHDR_PKG_CREATE_USER = "' PHDR-PKG-CREATE-USER '";'            
                'PHDR_PKG_CAST_USER = "' PHDR-PKG-CAST-USER '";'                
                'PHDR_PKG_NOTE1 = "' PHDR-PKG-NOTE1 '";'                        
                'PHDR_PKG_NOTE2 = "' PHDR-PKG-NOTE2 '";'                        
                'PHDR_PKG_NOTE3 = "' PHDR-PKG-NOTE3 '";'                        
                'PHDR_PKG_NOTE4 = "' PHDR-PKG-NOTE4 '";'                        
                'PHDR_PKG_NOTE5 = "' PHDR-PKG-NOTE5 '";'                        
                'PHDR_PKG_NOTE6 = "' PHDR-PKG-NOTE6 '";'                        
                'PHDR_PKG_NOTE7 = "' PHDR-PKG-NOTE7 '";'                        
                'PHDR_PKG_NOTE8 = "' PHDR-PKG-NOTE8 '";'                        
                'PHDR_PKG_CAST_COMPVAL = "' PHDR-PKG-CAST-COMPVAL '";'          
                       DELIMITED BY SIZE                                        
                INTO   WS-REXX-STATEMENTS                                       
                WITH POINTER WS-POINTER                                         
              END-STRING                                                        
           END-IF.                                                              
      ***** \ Convert COBOL exit block Datanames into Rexx /                    
      *****                                                                     
           MOVE 'C1UEXTR7'           TO EXECBLK-MEMBER .                        
           MOVE  3000                TO ARGSTRING-LENGTH(1)                     
           IF PECB-TSO-MODE                                                     
              CALL 'SET-ARG1-POINTER'  USING ARGUMENT-PTR                       
                                             PKG-C1UEXTR7-PARMS-IRXEXEC         
              PERFORM 0800-REXX-CALL-VIA-IRXEXEC                                
              MOVE 0 TO PECB-NDVR-HIGH-RC                                       
           ELSE                                                                 
*********     DISPLAY 'C1UEXT07: Running in Batch       '                       
              CALL IRXJCL  USING PKG-C1UEXTR7-PARMS-IRXJCL .                    
           IF RETURN-CODE NOT = 0                                               
               DISPLAY 'C1UEXT07: BAD CALL TO IRXJCL - RC = '                   
                        RETURN-CODE                                             
           END-IF                                                               
           MOVE 0           TO RETURN-CODE                                      
           .                                                                    
       0800-REXX-CALL-VIA-IRXEXEC.                                              
      *--- GET THE ADDRESS OF THE ARGUMENT(S) TO BE PASSED TO IXREXEC           
      *--- AND LOAD INTO THE ARGUMENT TABLES                                    
*******    IF PECB-USER-BATCH-JOBNAME(1:7) = 'PL05958'                          
*******        DISPLAY 'C1UEXT07: SETTING UP REXX EXECUTION'                    
*******                ' FOR PACKAGE 'PECB-PACKAGE-ID                           
*******    END-IF .                                                             
           SET ARGSTRING-PTR (1)           TO ARGUMENT-PTR .                    
           CALL 'SET-ARGUMENT-POINTER'  USING ARGTABLE-PTR                      
                                              ARGUMENT .                        
           CALL 'SET-EXECBLK-POINTER'   USING EXECBLK-PTR                       
                                              EXECBLK .                         
           CALL 'SET-EVALBLK-POINTER'   USING EVALBLK-PTR                       
                                              EVALBLK .                         
      *--- SET FLAGS TO HEX 20000000                                            
      *    I.E. EXEC INVOKED AS SUBROUTINE                                      
           MOVE 536870912         TO FLAGS                                      
           MOVE 0                 TO REXX-RETURN-CODE .                         
*********  DISPLAY 'C1UEXT07: CALLING IRXEXC  '                                 
*********              PECB-PACKAGE-ID .                                        
      *--- CALL THE REXX EXEC ---                                               
           CALL IRXEXEC-PGM USING EXECBLK-PTR                                   
                                  ARGTABLE-PTR                                  
                                  FLAGS                                         
                                  DUMMY-ZERO                                    
                                  DUMMY-ZERO                                    
                                  EVALBLK-PTR                                   
                                  DUMMY-ZERO                                    
                                  DUMMY-ZERO                                    
                                  DUMMY-ZERO .                                  
           IF REXX-RETURN-CODE NOT = 0                                          
               DISPLAY 'C1UEXT07: IRXEXEC RETURN CODE = '                       
                       REXX-RETURN-CODE                                         
           END-IF                                                               
           CANCEL IRXEXEC-PGM                                                   
           .                                                                    
       0900-SEND-EMAILS.                                                        
********** DISPLAY 'C1UEXTT7: MYSMTP-MESSAGE=' MYSMTP-MESSAGE .                 
********** DISPLAY 'C1UEXTT7: MYSMTP-FROM   =' MYSMTP-FROM    .                 
********** DISPLAY 'C1UEXTT7: MYSMTP-SUBJECT=' MYSMTP-SUBJECT .                 
********** DISPLAY 'C1UEXTT7: MYSMTP-TEXT    ' MYSMTP-TEXT(1:80).               
           MOVE 1 TO WS-POINTER.                                                
           PERFORM UNTIL                                                        
                 MYSMTP-EMAIL-IDS(WS-POINTER:1) = LOW-VALUES OR                 
                 MYSMTP-EMAIL-IDS(WS-POINTER:8)                                 
                    LESS THAN OR EQUAL SPACES                OR                 
                 WS-POINTER GREATER THAN OR EQUAL                               
                    MYSMTP-EMAIL-ID-SIZE                                        
             MOVE SPACES TO MYSMTP-USERID                                       
             UNSTRING MYSMTP-EMAIL-IDS                                          
                     DELIMITED BY SPACE                                         
              INTO   MYSMTP-USERID                                              
              WITH POINTER WS-POINTER                                           
             END-UNSTRING                                                       
             IF MYSMTP-USERID NOT = SPACES                                      
**********      DISPLAY 'C1UEXTT7: Emailing ' MYSMTP-USERID                     
**********              ' WS-POINTER=' WS-POINTER ' '                           
**********              MYSMTP-EMAIL-IDS(WS-POINTER:60)                         
                CALL PGM        USING MYSMTP-MESSAGE                            
                                      MYSMTP-USERID                             
                                      MYSMTP-FROM                               
                                      MYSMTP-SUBJECT                            
                                      MYSMTP-TEXT                               
                                      MYSMTP-URL                                
             END-IF                                                             
             IF RETURN-CODE > 0                                                 
                 DISPLAY 'CALL BC1PMLIF RC = ' RETURN-CODE                      
                 DISPLAY MYSMTP-MESSAGE                                         
             END-IF                                                             
**********   ADD 1 TO WS-POINTER                                                
           END-PERFORM.                                                         
      *-----------------------------------------------------------------        
       1000-ALLOCATE-REXFILE.                                                   
           MOVE SPACES TO ALLOC-TEXT.                                           
           IF PECB-BATCH-MODE                                                   
              STRING 'ALLOC DD(SYSEXEC) ',                                      
                'DA(YOURSITE.NDVR.REXX)'                                        
                     DELIMITED BY SIZE                                          
                        ' SHR REUSE'                                            
                     DELIMITED BY SIZE                                          
                INTO ALLOC-TEXT                                                 
              END-STRING                                                        
           ELSE                                                                 
              STRING 'ALLOC DD(REXFILE7) ',                                     
                'DA(YOURSITE.NDVR.REXX)'                                        
                     DELIMITED BY SIZE                                          
                        ' SHR REUSE'                                            
                     DELIMITED BY SIZE                                          
                INTO ALLOC-TEXT                                                 
              END-STRING                                                        
           END-IF.                                                              
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .                                 
********** MOVE 'CONCAT DDLIST(REXFILE,REXFILE2)'                               
**********   TO ALLOC-TEXT .                                                    
**********                                                                      
********** PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .                                 
      *****************************************************************         
      **  DYNAMICALLY DE-ALLOCATE UNNEEDED REXX FILES                           
      *****************************************************************         
       2000-FREE-REXFILES.                                                      
           MOVE SPACES TO ALLOC-TEXT.                                           
           IF PECB-BATCH-MODE                                                   
              MOVE 'FREE  DD(SYSEXEC)' TO ALLOC-TEXT                            
           ELSE                                                                 
              MOVE 'FREE  DD(REXFILE7)' TO ALLOC-TEXT                           
           END-IF.                                                              
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC                                   
           .                                                                    
      *****************************************************************         
      **  CALL BPXWDYN TO PREFORM REQUIRED REXX FUNCTIONS                       
      *****************************************************************         
       9000-DYNAMIC-ALLOC-DEALLOC.                                              
           CALL BPXWDYN USING ALLOC-STRING                                      
           IF RETURN-CODE NOT = ZERO                                            
               DISPLAY 'C1UEXT07: ALLOCATION FAILED: RETURN CODE = '            
                       RETURN-CODE                                              
               DISPLAY ALLOC-TEXT                                               
           END-IF                                                               
*********  DISPLAY ALLOC-TEXT .                                                 
           MOVE SPACES TO ALLOC-TEXT                                            
           .                                                                    
      ******************************************************************        
      *  BEGIN NESTED PROGRAMS USED TO SET THE POINTERS OF DATA AREAS           
      *  THAT ARE BEING PASSED TO IRXEXEC SO THAT A REXX ROUTINE CAN            
      *  PASS DATA (OTHER THAN A RETURN CODE) BACK TO A COBOL PROGRAM.          
      ******************************************************************        
      ******** SET-ARG1-POINTER ********                                        
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. SET-ARG1-POINTER.                                            
       ENVIRONMENT DIVISION.                                                    
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
       LINKAGE SECTION.                                                         
         77 ARG-PTR                        POINTER.                             
         77 ARG1                           PIC X(16).                           
       PROCEDURE DIVISION USING ARG-PTR                                         
                                ARG1.                                           
           SET ARG-PTR TO ADDRESS OF ARG1                                       
           GOBACK.                                                              
       END PROGRAM SET-ARG1-POINTER.                                            
      ******** SET-ARGUMENT-POINTER ********                                    
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. SET-ARGUMENT-POINTER.                                        
       ENVIRONMENT DIVISION.                                                    
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
       LINKAGE SECTION.                                                         
         77 ARGTABLE-PTR                   POINTER.                             
         01 ARGUMENT.                                                           
           02 ARGUMENT-1                   OCCURS 1 TIMES.                      
            05 ARGSTRING-PTR               POINTER.                             
            05 ARGSTRING-LENGTH            PIC S9(8) BINARY.                    
           02 ARGSTRING-LAST1              PIC S9(8) BINARY.                    
           02 ARGSTRING-LAST2              PIC S9(8) BINARY.                    
       PROCEDURE DIVISION USING ARGTABLE-PTR                                    
                                ARGUMENT.                                       
           SET ARGTABLE-PTR TO ADDRESS OF ARGUMENT                              
           GOBACK.                                                              
       END PROGRAM SET-ARGUMENT-POINTER.                                        
      ******** SET-EXECBLK-POINTER ********                                     
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. SET-EXECBLK-POINTER.                                         
       ENVIRONMENT DIVISION.                                                    
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
       LINKAGE SECTION.                                                         
         77 EXECBLK-PTR                    POINTER.                             
         01 EXECBLK.                                                            
            03 EXECBLK-ACRYN               PIC X(8).                            
            03 EXECBLK-LENGTH              PIC 9(4) COMP.                       
            03 EXECBLK-RESERVED            PIC 9(4) COMP.                       
            03 EXECBLK-MEMBER              PIC X(8).                            
            03 EXECBLK-DDNAME              PIC X(8).                            
            03 EXECBLK-SUBCOM              PIC X(8).                            
            03 EXECBLK-DSNPTR              POINTER.                             
            03 EXECBLK-DSNLEN              PIC 9(4) COMP.                       
       PROCEDURE DIVISION USING EXECBLK-PTR                                     
                                EXECBLK.                                        
           SET EXECBLK-PTR TO ADDRESS OF EXECBLK                                
           GOBACK.                                                              
       END PROGRAM SET-EXECBLK-POINTER.                                         
      ******** SET-EVALBLK-POINTER ********                                     
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. SET-EVALBLK-POINTER.                                         
       ENVIRONMENT DIVISION.                                                    
       DATA DIVISION.                                                           
       WORKING-STORAGE SECTION.                                                 
       LINKAGE SECTION.                                                         
         77 EVALBLK-PTR                    POINTER.                             
         01 EVALBLK.                                                            
            03 EVALBLK-EVPAD1              PIC 9(4) COMP.                       
            03 EVALBLK-EVSIZE              PIC 9(4) COMP.                       
            03 EVALBLK-EVLEN               PIC 9(4) COMP.                       
            03 EVALBLK-EVPAD2              PIC 9(4) COMP.                       
            03 EVALBLK-EVDATA              PIC X(256).                          
       PROCEDURE DIVISION USING EVALBLK-PTR                                     
                                EVALBLK.                                        
           SET EVALBLK-PTR TO ADDRESS OF EVALBLK                                
           GOBACK.                                                              
       END PROGRAM SET-EVALBLK-POINTER.                                         
      *--- END OF MAIN PROGRAM                                                  
       END PROGRAM C1UEXT07.                                                    
