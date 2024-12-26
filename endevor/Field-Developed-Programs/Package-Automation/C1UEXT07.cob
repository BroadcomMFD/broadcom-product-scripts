       PROCESS DYNAM OUTDD(DISPLAYS)                                            
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. C1UEXT07.                                                    
                                                                                
      ************************************************************              
      * DESCRIPTION:  THIS PACKAGE EXIT PROGRAM WILL:            *              
      * 1) Performs Automated Package Executions                 *              
      *    by calling REXX subroutine PKGEXECT                   *              
      * 2) Performs Automated Package Shipping                   *              
      *    by calling REXX subroutine PKGESHIP                   *              
      * https://github.com/BroadcomMFD/broadcom-product-scripts                 
      ************************************************************              
      * THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".                 
      * NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.             
      * COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE              
      * ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.        
      ************************************************************              
                                                                                
       ENVIRONMENT DIVISION.                                                    
       INPUT-OUTPUT SECTION.                                                    
       FILE-CONTROL.                                                            
      **                                                                        
       DATA DIVISION.                                                           
       FILE SECTION.                                                            
                                                                                
       WORKING-STORAGE SECTION.                                                 
                                                                                
       01  WS-DATE-VARIABLES.                                                   
           03  WS-DATE-TO-CONVERT                PIC X(07).                     
           03  WS-DATE-CONVERTED.                                               
               05  WS-DATE-CENTURY               PIC 9(02).                     
               05  WS-DATE-YEAR                  PIC 9(02).                     
               05  WS-DATE-MONTH                 PIC 9(02).                     
               05  WS-DATE-DAY                   PIC 9(02).                     
           03  WS-DATE-OF-RUN                    PIC 9(06).                     
           03  WS-DOR REDEFINES WS-DATE-OF-RUN.                                 
               05  WS-DOR-YEAR                   PIC 9(02).                     
               05  WS-DOR-MONTH                  PIC 9(02).                     
               05  WS-DOR-DAY                    PIC 9(02).                     
                                                                                
           03  WS-RUN-DATE                       PIC 9(06).                     
           03  FILLER   REDEFINES   WS-RUN-DATE.                                
               05  WS-RUN-DATE-YEAR              PIC 9(02).                     
               05  WS-RUN-DATE-MONTH             PIC 9(02).                     
               05  WS-RUN-DATE-DAY               PIC 9(02).                     
                                                                                
           03  WS-TIME-OF-RUN                    PIC 9(08).                     
           03  FILLER REDEFINES WS-TIME-OF-RUN.                                 
               05  WS-TOR.                                                      
                   10  WS-TOR-HOUR               PIC 9(02).                     
                   10  WS-TOR-MINUTE             PIC 9(02).                     
               05  FILLER                        PIC 9(04).                     
                                                                                
           03  WS-RUN-TIME                       PIC 9(04).                     
           03  FILLER   REDEFINES   WS-RUN-TIME.                                
               05  WS-RUN-TIME-HOUR              PIC 9(02).                     
               05  WS-RUN-TIME-MINUTE            PIC 9(02).                     
                                                                                
           03  WS-PACKAGE-DATE.                                                 
               10  WS-PKG-DAY                PIC 9(02).                         
               10  WS-PKG-MONTH              PIC X(03).                         
               10  WS-PKG-YEAR               PIC 9(02).                         
                                                                                
           03  WS-PKG-START-DATE.                                               
               10  WS-PKG-START-YEAR         PIC 9(02).                         
               10  WS-PKG-START-MONTH        PIC 9(02).                         
               10  WS-PKG-START-DAY          PIC 9(02).                         
                                                                                
           03  WS-PKG-END-DATE.                                                 
               10  WS-PKG-END-YEAR           PIC 9(02).                         
               10  WS-PKG-END-MONTH          PIC 9(02).                         
               10  WS-PKG-END-DAY            PIC 9(02).                         
                                                                                
           03  WS-PACKAGE-TIME.                                                 
               10  WS-PKG-HOUR               PIC 9(02).                         
               10  FILLER                    PIC X(01).                         
               10  WS-PKG-MINUTE             PIC 9(02).                         
                                                                                
           03  WS-PKG-START-TIME.                                               
               10  WS-PKG-START-HOUR         PIC 9(02).                         
               10  WS-PKG-START-MINUTE       PIC 9(02).                         
                                                                                
           03  WS-PKG-END-TIME.                                                 
               10  WS-PKG-END-HOUR           PIC 9(02).                         
               10  WS-PKG-END-MINUTE         PIC 9(02).                         
                                                                                
       01  WS-MONTHS-TABLE.                                                     
           03 FILLER                             PIC X(36)                      
              VALUE 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC' .                    
       01  WS-MONTHS-TABLE-RE REDEFINES WS-MONTHS-TABLE.                        
           03 WS-MONTH OCCURS 12 TIMES INDEXED BY WS-MONTH-INX                  
                                                 PIC X(03).                     
       01  WS-VARIABLES.                                                        
           03  WS-SUBMIT-SWITCH        PIC X(01) VALUE 'N'.                     
               88  SUBMIT-OK               VALUE 'S'.                           
               88  DO-NOT-SUBMIT           VALUE 'N'.                           
           03  WS-TIME                 PIC 9(8).                                
           03  WS-PACKAGE-VARIABLE     PIC X(01).                               
           03  WS-JOBCARD-ID           PIC X(07) VALUE SPACES.                  
           03  ME                      PIC X(07) VALUE 'XALJO11'.               
           03  ADMIN1                  PIC X(01) VALUE 'P'.                     
           03  ADMIN2                  PIC X(01) VALUE 'T'.                     
           03  WS-TALLY                PIC  9(4) VALUE 0000.                    
                                                                                
       01 BPXWDYN PIC X(8) VALUE 'BPXWDYN'.                                     
       01 ALLOC-STRING.                                                         
          05 ALLOC-LENGTH PIC S9(4) BINARY VALUE 100.                           
          05 ALLOC-TEXT   PIC X(100).                                           
                                                                                
       01  IRXJCL                            PIC X(6)  VALUE 'IRXJCL'.          
       01  IRXEXEC-PGM                       PIC X(08) VALUE 'IRXEXEC'.         
                                                                                
      *                                                                         
      * DEFINE THE IRXEXEC DATA AREAS AND ARG BLOCKS                            
      *                                                                         
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
           05 EXECBLK-MEMBER                 PIC X(08) VALUE 'PKGEXECT'.        
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
      * IRXJCL or IRXEXEC call to the rexx program PKGEXECT.                    
      * IRXJCL is used when running in batch (batch CAST) .                     
      * IRXEXEC is used when running in foreground (CAST or APPROVE).           
       01  PKG-EXECUTE-PARMS-IRXJCL.                                            
         02  PKG-EXECUTE-PARMS-IRXJCL-TOP.                                      
           03 PARM-LENGTH          PIC X(2) VALUE X'0114'.                      
           03 REXX-NAME            PIC X(8) VALUE 'PKGEXECT'.                   
           03 FILLER               PIC X(1) VALUE SPACE .                       
         02  PKG-EXECUTE-PARMS-IRXEXEC.                                         
           03 REXX-EXEC-PACKAGE    PIC X(16) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-EXEC-ENV        PIC X(08) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-EXEC-STGID      PIC X(01) .                                  
           03 REXX-EXEC-MODE       PIC X(01) .                                  
           03 REXX-EXE-CREATE-USER PIC X(08) .                                  
           03 REXX-EXE-UPDATE-USER PIC X(08) .                                  
           03 REXX-EXE-CAST-USER   PIC X(08) .                                  
           03 REXX-EXEC-COMMENT    PIC X(50) .                                  
                                                                                
      * The block of data below can be used for submitting pkg shipments        
      * IRXJCL is always used since executions are always in batch.             
       01  PKG-SHIPMENT-PARMS-IRXJCL.                                           
         02  PKG-SHIPMENT-PARMS-IRXJCL-TOP.                                     
           03 PARM-LENGTH          PIC X(2) VALUE X'0253'.                      
           03 REXX-NAME            PIC X(8) VALUE 'PKGESHIP'.                   
           03 FILLER               PIC X(1) VALUE SPACE .                       
         02  PKG-SHIPMENT-PARMS.                                                
           03 REXX-SHIP-PACKAGE    PIC X(16) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-SHIP-ENV        PIC X(08) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-SHIP-STGID      PIC X(01) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-SHIP-COMMENT    PIC X(50) .                                  
           03 REXX-SHIP-CREATE-USR PIC X(08) .                                  
           03 REXX-SHIP-UPDATE-USR PIC X(08) .                                  
           03 REXX-SHIP-CAST-USER  PIC X(08) .                                  
           03 FILLER               PIC X(1) VALUE SPACE .                       
           03 REXX-SHIP-NOTE1      PIC X(60) .                                  
           03 REXX-SHIP-NOTE2      PIC X(60) .                                  
           03 REXX-SHIP-NOTE3      PIC X(60) .                                  
           03 REXX-SHIP-NOTE4      PIC X(60) .                                  
           03 REXX-SHIP-NOTE5      PIC X(60) .                                  
           03 REXX-SHIP-NOTE6      PIC X(60) .                                  
           03 REXX-SHIP-NOTE7      PIC X(60) .                                  
           03 REXX-SHIP-NOTE8      PIC X(60) .                                  
           03 REXX-SHIP-OUT        PIC X(03) .                                  
                                                                                
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
      ****                                                                      
                                                                                
*******    DISPLAY 'C1UEXT07: GOT INTO EXIT 7' .                                
           ACCEPT WS-DATE-OF-RUN FROM DATE.                                     
           ACCEPT WS-TIME-OF-RUN FROM TIME.                                     
           MOVE WS-DOR-YEAR TO WS-RUN-DATE-YEAR.                                
           MOVE WS-DOR-MONTH TO WS-RUN-DATE-MONTH.                              
           MOVE WS-DOR-DAY TO WS-RUN-DATE-DAY.                                  
           MOVE WS-TOR-HOUR TO WS-RUN-TIME-HOUR.                                
           MOVE WS-TOR-MINUTE TO WS-RUN-TIME-MINUTE.                            
                                                                                
           IF  SETUP-EXIT-OPTIONS                                               
*********    to support automated package shipping                              
               MOVE 'Y'   TO PECB-AFTER-EXEC                                    
               MOVE 'Y'   TO PECB-REQ-ELEMENT-ACTION-BIBO                       
               MOVE 'Y'   TO PECB-AFTER-BACKOUT                                 
               MOVE 'Y'   TO PECB-AFTER-BACKIN                                  
*********    to enforce package backout = Y                                     
*********      MOVE 'Y'   TO PECB-BEFORE-CAST                                   
*********      MOVE 'Y'   TO PECB-MID-CAST                                      
               MOVE 'Y'   TO PECB-BEFORE-CREATE-BLD                             
               MOVE 'Y'   TO PECB-BEFORE-CREATE-COPY                            
               MOVE 'Y'   TO PECB-BEFORE-CREATE-EDIT                            
               MOVE 'Y'   TO PECB-BEFORE-CREATE-IMPT                            
               MOVE 'Y'   TO PECB-BEFORE-MOD-BLD                                
               MOVE 'Y'   TO PECB-BEFORE-MOD-CPY                                
               MOVE 'Y'   TO PECB-BEFORE-MOD-EDIT                               
               MOVE 'Y'   TO PECB-BEFORE-MOD-IMPT                               
*********    to support submission of package Execute jobs                      
               MOVE 'Y'   TO PECB-AFTER-REV-APPR                                
               MOVE 'Y'   TO PECB-AFTER-CAST                                    
               MOVE ZEROS TO RETURN-CODE                                        
               GO TO 100-MAIN-EXIT.                                             
                                                                                
           MOVE 0 TO PECB-NDVR-EXIT-RC.                                         
                                                                                
**   *******====---> SUBMIT PACKAGE SHIPMENT JOBS                               
           IF (EXECUTE-PACKAGE AND                                              
              PHDR-PACKAGE-STATUS(1:4) = 'EXEC')                                
           OR (BACK-OUT-PACKAGE AND PECB-AFTER )                                
           OR (BACK-IN-PACKAGE AND PECB-AFTER )                                 
                 PERFORM 800-SUBMIT-PACKAGE-SHIPMENTS                           
                 GO TO 100-MAIN-EXIT.                                           
                                                                                
           IF CAST-PACKAGE AND PECB-AFTER AND                                   
              PHDR-PACKAGE-STATUS = 'APPROVED'                                  
*******       DISPLAY 'PERFORM 599-CHECK-SUBMIT-DATES'                          
              PERFORM 599-CHECK-SUBMIT-DATES                                    
              IF SUBMIT-OK                                                      
*******          DISPLAY 'PERFORM 600-SUBMIT-PACKAGE-AUTOMATION'                
                       IF PECB-BATCH-MODE                                       
                          MOVE SPACES TO ALLOC-TEXT                             
                          PERFORM 2100-ALLOCATE-REXFILE                         
                       END-IF                                                   
                       PERFORM 600-SUBMIT-PACKAGE-AUTOMATION                    
                       PERFORM 2100-ALLOCATE-REXFILE                            
                 GO TO 100-MAIN-EXIT                                            
              ELSE                                                              
                 GO TO 100-MAIN-EXIT.                                           
                                                                                
           IF REVIEW-PACKAGE AND PECB-AFTER AND                                 
              PHDR-PACKAGE-STATUS = 'APPROVED'                                  
              PERFORM 599-CHECK-SUBMIT-DATES                                    
              IF SUBMIT-OK                                                      
                 IF PECB-BATCH-MODE                                             
                    MOVE SPACES TO ALLOC-TEXT                                   
                    PERFORM 2100-ALLOCATE-REXFILE                               
                 END-IF                                                         
                 PERFORM 600-SUBMIT-PACKAGE-AUTOMATION                          
                 GO TO 100-MAIN-EXIT                                            
              ELSE                                                              
                 GO TO 100-MAIN-EXIT.                                           
                                                                                
*******     DISPLAY 'C1UEXT07: PHDR-PACKAGE-STATUS='                            
*******              PHDR-PACKAGE-STATUS.                                       
                                                                                
           IF PREQ-BACKOUT-ENABLED NOT = 'Y'                                    
              MOVE 'Y' TO PREQ-BACKOUT-ENABLED                                  
              MOVE 4 TO PECB-NDVR-EXIT-RC                                       
              MOVE 'Y' TO PECB-MODS-MADE-TO-PREQ                                
              DISPLAY 'C1UEXT07: Package Backout is Enforced'                   
           END-IF.                                                              
                                                                                
       100-MAIN-EXIT.                                                           
*******    DISPLAY 'C1UEXT07:   GOING BACK '                                    
                                                                                
           GOBACK.                                                              
                                                                                
                                                                                
       599-CHECK-SUBMIT-DATES.                                                  
                                                                                
           ACCEPT WS-DATE-OF-RUN FROM DATE                                      
           ACCEPT WS-TIME-OF-RUN FROM TIME                                      
           MOVE WS-DOR-YEAR             TO WS-RUN-DATE-YEAR                     
           MOVE WS-DOR-MONTH            TO WS-RUN-DATE-MONTH                    
           MOVE WS-DOR-DAY              TO WS-RUN-DATE-DAY                      
           MOVE WS-TOR-HOUR             TO WS-RUN-TIME-HOUR                     
           MOVE WS-TOR-MINUTE           TO WS-RUN-TIME-MINUTE                   
                                                                                
           MOVE PHDR-PKG-EXEC-STRT-DATE TO WS-DATE-TO-CONVERT                   
           PERFORM 700-CONVERT-DATE-CONVERT                                     
           MOVE WS-DATE-YEAR            TO WS-PKG-START-YEAR                    
           MOVE WS-DATE-MONTH           TO WS-PKG-START-MONTH                   
           MOVE WS-DATE-DAY             TO WS-PKG-START-DAY                     
                                                                                
           MOVE PHDR-PKG-EXEC-END-DATE  TO WS-DATE-TO-CONVERT                   
           PERFORM 700-CONVERT-DATE-CONVERT                                     
           MOVE WS-DATE-YEAR            TO WS-PKG-END-YEAR                      
           MOVE WS-DATE-MONTH           TO WS-PKG-END-MONTH                     
           MOVE WS-DATE-DAY             TO WS-PKG-END-DAY                       
                                                                                
           MOVE PHDR-PKG-EXEC-STRT-TIME TO WS-PACKAGE-TIME                      
           MOVE WS-PKG-HOUR             TO WS-PKG-START-HOUR                    
           MOVE WS-PKG-MINUTE           TO WS-PKG-START-MINUTE                  
                                                                                
           MOVE PHDR-PKG-EXEC-END-TIME  TO WS-PACKAGE-TIME                      
           MOVE WS-PKG-HOUR             TO WS-PKG-END-HOUR                      
           MOVE WS-PKG-MINUTE           TO WS-PKG-END-MINUTE                    
                                                                                
           IF PECB-USER-BATCH-JOBNAME(1:7) = ME                                 
               DISPLAY 'C1UEXT07: USING THESE DATES'                            
               DISPLAY 'RUN DATE:   ' WS-RUN-DATE                               
                      ' TIME: '       WS-RUN-TIME                               
               DISPLAY 'START DATE: ' WS-PKG-START-DATE                         
                      ' TIME: '       WS-PKG-START-TIME                         
               DISPLAY 'END DATE:   ' WS-PKG-END-DATE                           
                      ' TIME: '       WS-PKG-END-TIME                           
           END-IF                                                               
                                                                                
           SET SUBMIT-OK TO TRUE                                                
           IF WS-PKG-START-DATE > WS-RUN-DATE                                   
               SET DO-NOT-SUBMIT TO TRUE                                        
           END-IF                                                               
                                                                                
           IF   WS-PKG-START-DATE = WS-RUN-DATE                                 
            AND WS-PKG-START-TIME > WS-RUN-TIME                                 
               SET DO-NOT-SUBMIT TO TRUE                                        
           END-IF                                                               
                                                                                
           IF WS-PKG-END-DATE < WS-RUN-DATE                                     
               SET DO-NOT-SUBMIT TO TRUE                                        
           END-IF                                                               
                                                                                
           IF   WS-PKG-END-DATE = WS-RUN-DATE                                   
            AND WS-PKG-END-TIME < WS-RUN-TIME                                   
               SET DO-NOT-SUBMIT TO TRUE                                        
           END-IF                                                               
                                                                                
           IF PECB-USER-BATCH-JOBNAME(1:7) = ME                                 
               DISPLAY 'C1UEXT07: SUBMIT SWITCH: ' WS-SUBMIT-SWITCH             
           END-IF                                                               
           .                                                                    
       600-SUBMIT-PACKAGE-AUTOMATION.                                           
                                                                                
      *    MAKES A CALL TO THE REXX ROUTINE PKGEXECT.                           
      *    THE REXX ROUTINE PKGEXECT SUBMITS PACKAGE SHIPMENT JOBS.             
      *    THE REXX ROUTINE PKGEXECT SUBMITS PACKAGE SHIPMENT JOBS.             
                                                                                
******     IF PECB-USER-BATCH-JOBNAME(1:7) = ME                                 
******         DISPLAY 'C1UEXT07: SUBMITTING PACKAGE '                          
******                 PECB-PACKAGE-ID                                          
******         DISPLAY 'C1UEXT07: PHDR-PKG-ENV  ' PHDR-PKG-ENV                  
******         DISPLAY 'C1UEXT07: PHDR-PKG-STGID' PHDR-PKG-STGID                
******     END-IF                                                               
                                                                                
           MOVE PECB-PACKAGE-ID      TO REXX-EXEC-PACKAGE                       
           MOVE PHDR-PKG-ENV         TO REXX-EXEC-ENV                           
           MOVE PHDR-PKG-STGID       TO REXX-EXEC-STGID                         
           MOVE PECB-MODE            TO REXX-EXEC-MODE                          
           MOVE PHDR-PKG-CREATE-USER TO  REXX-EXE-CREATE-USER                   
           MOVE PHDR-PKG-UPDATE-USER TO  REXX-EXE-UPDATE-USER                   
           MOVE PHDR-PKG-CAST-USER   TO  REXX-EXE-CAST-USER                     
           MOVE PREQ-PACKAGE-COMMENT TO REXX-EXEC-COMMENT                       
           MOVE 'PKGEXECT'           TO EXECBLK-MEMBER .                        
           MOVE  102                 TO ARGSTRING-LENGTH(1)                     
                                                                                
********                                                                        
********   IF PECB-TSO-MODE                                                     
********      DISPLAY 'C1UEXT07: IN TSO FOREGROUND  '                           
********      CALL 'SET-ARG1-POINTER'  USING ARGUMENT-PTR                       
********                                     PKG-EXECUTE-PARMS-IRXEXEC          
********      PERFORM 1800-REXX-CALL-VIA-IRXEXEC                                
********   ELSE                                                                 
********      DISPLAY 'C1UEXT07: NOT IN TSO FOREGROUND  '                       
              CALL IRXJCL  USING PKG-EXECUTE-PARMS-IRXJCL .                     
                                                                                
                                                                                
           IF RETURN-CODE NOT = 0                                               
               DISPLAY 'C1UEXT07: BAD CALL TO IRXJCL - RC = '                   
                        RETURN-CODE                                             
           END-IF                                                               
                                                                                
           MOVE 0           TO RETURN-CODE                                      
           .                                                                    
       700-CONVERT-DATE-CONVERT.                                                
                                                                                
           SET WS-MONTH-INX TO 1.                                               
           SEARCH WS-MONTH VARYING WS-MONTH-INX                                 
           AT END MOVE 00 TO WS-DATE-MONTH                                      
             WHEN WS-MONTH(WS-MONTH-INX) = WS-DATE-TO-CONVERT(3:3)              
                  SET WS-DATE-MONTH TO WS-MONTH-INX                             
           END-SEARCH                                                           
                                                                                
           MOVE WS-DATE-TO-CONVERT (1:2) TO WS-DATE-DAY                         
           MOVE WS-DATE-TO-CONVERT (6:2) TO WS-DATE-YEAR                        
           MOVE '20'                     TO WS-DATE-CENTURY                     
           .                                                                    
       800-SUBMIT-PACKAGE-SHIPMENTS.                                            
                                                                                
      *    MAKES A CALL TO THE REXX ROUTINE PKGESHIP                            
      *    THE REXX ROUTINE PKGESHIP SUBMITS PACKAGE SHIPMENT JOBS              
                                                                                
      *    Package Shipments may occur in batch only                            
      *    As a result, IRXJCL will be always be used to                        
      *    submit the package Shipment jobs.                                    
                                                                                
*******    IF PECB-USER-BATCH-JOBNAME(1:7) = 'IBMUSER'                          
*******        DISPLAY 'C1UEXT07: SHIPPING PACKAGE '                            
*******                PECB-PACKAGE-ID                                          
*******        DISPLAY 'C1UEXT07: PHDR-PKG-ENV  ' PHDR-PKG-ENV                  
*******        DISPLAY 'C1UEXT07: PHDR-PKG-STGID' PHDR-PKG-STGID                
*******    END-IF                                                               
                                                                                
           PERFORM 2100-ALLOCATE-REXFILE.                                       
                                                                                
           MOVE PECB-PACKAGE-ID      TO REXX-SHIP-PACKAGE                       
           MOVE PHDR-PKG-ENV         TO REXX-SHIP-ENV                           
           MOVE PHDR-PKG-STGID       TO REXX-SHIP-STGID                         
           MOVE PREQ-PACKAGE-COMMENT TO REXX-SHIP-COMMENT                       
           MOVE PHDR-PKG-CREATE-USER TO REXX-SHIP-CREATE-USR                    
           MOVE PHDR-PKG-UPDATE-USER TO REXX-SHIP-UPDATE-USR                    
           MOVE PHDR-PKG-CAST-USER   TO REXX-SHIP-CAST-USER                     
           MOVE PHDR-PKG-NOTE1       TO REXX-SHIP-NOTE1                         
           MOVE PHDR-PKG-NOTE2       TO REXX-SHIP-NOTE2                         
           MOVE PHDR-PKG-NOTE3       TO REXX-SHIP-NOTE3                         
           MOVE PHDR-PKG-NOTE4       TO REXX-SHIP-NOTE4                         
           MOVE PHDR-PKG-NOTE5       TO REXX-SHIP-NOTE5                         
           MOVE PHDR-PKG-NOTE6       TO REXX-SHIP-NOTE6                         
           MOVE PHDR-PKG-NOTE7       TO REXX-SHIP-NOTE7                         
           MOVE PHDR-PKG-NOTE8       TO REXX-SHIP-NOTE8                         
           IF BACK-OUT-PACKAGE                                                  
           MOVE 'BAC'                TO REXX-SHIP-OUT                           
           ELSE                                                                 
           MOVE 'OUT'                TO REXX-SHIP-OUT  .                        
                                                                                
           CALL IRXJCL  USING PKG-SHIPMENT-PARMS-IRXJCL.                        
                                                                                
           MOVE 0           TO RETURN-CODE                                      
           .                                                                    
                                                                                
                                                                                
       1800-REXX-CALL-VIA-IRXEXEC.                                              
      *--- GET THE ADDRESS OF THE ARGUMENT(S) TO BE PASSED TO IXREXEC           
      *--- AND LOAD INTO THE ARGUMENT TABLES                                    
*******    IF PECB-USER-BATCH-JOBNAME(1:7) = ME                                 
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
                                                                                
           IF PECB-USER-BATCH-JOBNAME(1:7) = ME                                 
               DISPLAY 'C1UEXT07: CALLING IRXEXC  '                             
                       PECB-PACKAGE-ID                                          
           END-IF .                                                             
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
                                                                                
       2100-ALLOCATE-REXFILE.                                                   
                                                                                
           MOVE SPACES TO ALLOC-TEXT.                                           
                                                                                
           STRING 'ALLOC DD(REXFILE7) ',                                        
             'DA(YOURSITE.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX) SHR REUSE'          
                  DELIMITED BY SIZE                                             
             INTO ALLOC-TEXT                                                    
           END-STRING .                                                         
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .                                 
           STRING 'ALLOC DD(SYSEXEC) ',                                         
             'DA(YOURSITE.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX) SHR REUSE'          
                  DELIMITED BY SIZE                                             
             INTO ALLOC-TEXT                                                    
           END-STRING.                                                          
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .                                 
                                                                                
********** MOVE 'CONCAT DDLIST(REXFILE,REXFILE2)'                               
**********   TO ALLOC-TEXT .                                                    
**********                                                                      
********** PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .                                 
                                                                                
      *****************************************************************         
      **  DYNAMICALLY DE-ALLOCATE UNNEEDED REXX FILES                           
      *****************************************************************         
       2200-FREE-REXFILES.                                                      
                                                                                
           MOVE 'FREE  DD(REXFILE7)' TO ALLOC-TEXT                              
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC                                   
                                                                                
           MOVE 'FREE  DD(SYSEXEC)' TO ALLOC-TEXT                               
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
