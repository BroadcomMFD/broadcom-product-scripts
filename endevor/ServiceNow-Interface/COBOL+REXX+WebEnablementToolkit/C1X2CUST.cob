      ******************************************************************00110000
       IDENTIFICATION DIVISION.                                                 
      ******************************************************************00110000
                                                                                
       PROGRAM-ID. C1X2CUST.                                                    
       AUTHOR.     (C) 2025 Broadcom                                            
                   Jose Benigno Gonzalez for CUST.                              
                                                                                
      ******************************************************************        
       ENVIRONMENT DIVISION.                                                    
      ******************************************************************        
                                                                        00220000
      *-----------------------------------------------------------------00230000
       CONFIGURATION SECTION.                                           00240000
      *-----------------------------------------------------------------00250000
                                                                                
       SOURCE-COMPUTER. IBM-S390 WITH DEBUGGING MODE.                           
                                                                                
       OBJECT-COMPUTER. IBM-S390.                                               
                                                                        00260000
       SPECIAL-NAMES.                                                   00270000
           DECIMAL-POINT IS COMMA                                               
           CLASS VALID-NAME 'A' THRU 'I'                                        
                            'J' THRU 'R'                                        
                            'S' THRU 'Z'                                        
                            '0' THRU '9'.                                       
                                                                        00290000
                                                                                
      ******************************************************************        
       DATA DIVISION.                                                           
      ******************************************************************        
                                                                        00390000
      *-----------------------------------------------------------------00400000
       WORKING-STORAGE SECTION.                                                 
      *-----------------------------------------------------------------00400000
                                                                                
       01 RACF_GROUP                             PIC X(8).                      
       01 WK-REQ-CCID.                                                          
          03  WK-REQ-CCID-MOD                    PIC X(3).                      
          03  WK-REQ-CCID-SUFIX.                                                
            05  WK-REQ-CCID-SUFIX-NUM            PIC 9(7).                      
          03  WK-REQ-CCID-PAD                    PIC X(2).                      
       01 WK-ENV                                 PIC X(8).                      
       01 SN-OBJECT-NUMBER                       PIC X(10).                     
       01 PGM                                    PIC X(8).                      
                                                                                
       77 WK-TALLY                               PIC 9(2).                      
       77 TRIMMED-LEN                            PIC 9(2).                      
                                                                                
      *COPY WSCOMMON.                                                           
      *COPY WSEX02.                                                             
                                                                                
                                                                                
      *================================================================         
      *================================================================         
      *= List of parameters passed by ref to the IRXJCL                         
      *================================================================         
      *==LINKAGE TO IRXJCL=============================================         
         01 IRXPARM.                                                            
            03 PARM-LENGTH                  PIC 9(4) COMP.                      
            03 REXX-NAME                    PIC X(9).                           
      *--ARGUMENTOS PASADOS AL REXX    --------------------------------         
            03 PARM1-A                      USAGE POINTER.                      
            03 PARM1-L                      PIC 9(4) COMP.                      
            03 PARM2-A                      USAGE POINTER.                      
            03 PARM2-L                      PIC 9(4) COMP.                      
            03 PARM3-A                      USAGE POINTER.                      
            03 PARM3-L                      PIC 9(4) COMP.                      
            03 PARM4-A                      USAGE POINTER.                      
            03 PARM4-L                      PIC 9(4) COMP.                      
      *================================================================         
         77 PGM-NAME                        PIC X(8)   VALUE 'IRXJCL'.          
      * Input/Output Parameter                                                  
         77 SNOWOBJ                         PIC X(10)  VALUE SPACES.            
      * Input Parameter                                                         
         77 AUTHTYPE                        PIC X(8)   VALUE SPACES.            
         77 ACTION                          PIC X(8)   VALUE SPACES.            
      * Ouput Parameter                                                         
         77 OBJSTATE                        PIC X(15)  VALUE SPACES.            
      *================================================================         
      *-----------------------------------------------------------------        
      *                                                                         
      * Dynalloc Areas for INFO Request - SNOWTRC DD allocation                 
      *                                                                         
      *-----------------------------------------------------------------        
        01  WS-WORK-AREA.                                                       
            05 WS-RC                   PIC  9(9) COMP-5.                        
            05 WS-DYN-PGM              PIC  X(8) VALUE 'BPXWDY2 '.              
                                                                                
        01  WDYN-PARM.                                                          
            05 WDYN-VALUE              PIC  X(40) VALUE                         
               'INFO DD(SNOWTRC) '.                                             
            05 WDYN-NULL               PIC  X(01) VALUE LOW-VALUES.             
                                                                                
        01 TRACEAPI                               PIC X(1).                     
            88 TRACE-DISABLE                      VALUE '0'.                    
            88 TRACE-ENABLE                       VALUE '1'.                    
                                                                                
      *-----------------------------------------------------------------        
      *                                                                         
      *-----------------------------------------------------------------        
                                                                                
      *-----------------------------------------------------------------00400000
       LINKAGE SECTION.                                                         
      *-----------------------------------------------------------------00400000
                                                                                
       COPY EXITBLKS.                                                   00010000
                                                                                
      ******************************************************************        
       PROCEDURE DIVISION USING EXIT-CONTROL-BLOCK                              
                                REQUEST-INFO-BLOCK                              
                                SRC-ENVIRONMENT-BLOCK                           
                                SRC-ELEMENT-MASTER-INFO-BLOCK                   
                                SRC-FILE-CONTROL-BLOCK                          
                                TGT-ENVIRONMENT-BLOCK                           
                                TGT-ELEMENT-MASTER-INFO-BLOCK                   
                                TGT-FILE-CONTROL-BLOCK.                         
                                                                                
      *================================================================         
      *-- CONSTRUIMOS LISTA DE PARAMETROS A SER PASADA AL LLAMADOR=====         
      *================================================================         
      *  77 PGM-NAME                       PIC X(8)   VALUE 'IRXJCL'.           
      * Input/Output Parameter                                                  
      *  77 SNOW-CR                        PIC X(10)  VALUE SPACES.             
      * Input Parameter                                                         
      *  77 AUTHTYPE                       PIC X(8)   VALUE SPACES.             
      *  77 ACTION                         PIC X(8)   VALUE SPACES.             
      * Ouput Parameter                                                         
      *  77 CR-START-DATE                  PIC X(7)   VALUE SPACES.             
      *  77 CR-START-TIME                  PIC X(5)   VALUE SPACES.             
      *  77 CR-END-DATE                    PIC X(7)   VALUE SPACES.             
      *  77 CR-END-TIME                    PIC X(5)   VALUE SPACES.             
      *  77 OBJSTATE                       PIC X(15)  VALUE SPACES.             
      *  77 CR-STATUS                      PIC X(5)   VALUE SPACES.             
      *  77 CR-APPROVAL                    PIC X(20)  VALUE SPACES.             
                                                                                
             MOVE +100                TO PARM-LENGTH                            
             MOVE "SNOWCUST"          TO REXX-NAME                              
                                                                                
             SET PARM1-A              TO ADDRESS OF SNOWOBJ                     
             MOVE +10                 TO PARM1-L                                
                                                                                
             SET PARM2-A              TO ADDRESS OF AUTHTYPE                    
             MOVE +8                  TO PARM2-L                                
                                                                                
             SET PARM3-A              TO ADDRESS OF ACTION                      
             MOVE +8                  TO PARM3-L                                
                                                                                
             SET PARM4-A              TO ADDRESS OF OBJSTATE                    
             MOVE +15                 TO PARM4-L                                
                                                                                
             MOVE 0 TO TRACEAPI                                                 
             PERFORM CHECK-TRACE-DDNAME-ALLOC                                   
                                                                                
             IF TRACE-ENABLE                                                    
                                                                                
               DISPLAY '------------------------------------------'             
                                                                                
               DISPLAY 'EX02 - START'                                           
               DISPLAY 'EX02'                                                   
               DISPLAY 'EX02 - RC         ' ECB-RETURN-CODE                     
               DISPLAY 'EX02 - USER-ID    ' ECB-USER-ID                         
               DISPLAY 'EX02 - ACTION     ' ECB-ACTION-NAME                     
               DISPLAY 'EX02 - HIGH-RC    ' ECB-HIGH-RC                         
               DISPLAY 'EX02 - REQ-CCID   ' REQ-CCID                            
               DISPLAY 'EX02 - REQ-COMMENT ' REQ-COMMENT                        
               DISPLAY 'EX02 - REQ-SISO-INDICATOR 'REQ-SISO-INDICATOR           
               DISPLAY 'EX02'                                                   
               DISPLAY 'EX02 - ACCION DESDE: 'ECB-API-IND                       
               DISPLAY 'EX02'                                                   
               DISPLAY 'EX02 - SRC-ENV-ENVIRONMENT-NAME: '                      
                        SRC-ENV-ENVIRONMENT-NAME                                
               DISPLAY 'EX02 - TGT-ENV-ENVIRONMENT-NAME: '                      
                        TGT-ENV-ENVIRONMENT-NAME                                
               DISPLAY 'EX02'                                                   
               DISPLAY 'EX02 - STOP'                                            
                                                                                
               DISPLAY '------------------------------------------'             
                                                                                
             END-IF                                                             
                                                                                
             EVALUATE TRUE                                                      
               WHEN MOVE-ACTION                                                 
                  MOVE SRC-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN RETRIEVE-ACTION                                             
                  MOVE SRC-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN ADD-ACTION                                                  
                  MOVE TGT-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN UPDATE-ACTION                                               
                  MOVE TGT-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN RETRIEVE-ACTION                                             
                  MOVE SRC-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN GENERATE-ACTION                                             
                  MOVE SRC-ENV-ENVIRONMENT-NAME TO WK-ENV                       
                  PERFORM CHECK-CCID-VALUE                                      
               WHEN OTHER                                                       
                  EXIT                                                          
             END-EVALUATE                                                       
                                                                                
           GOBACK.                                                              
                                                                                
      *-----------------------------------------------------------------00400000
       CHECK-CCID-VALUE.                                                        
      *-----------------------------------------------------------------00400000
           IF WK-ENV(1:3) = 'DEV'                                               
             IF REQ-CCID(1:3) = 'INC' OR                                        
                REQ-CCID(1:3) = 'CHG'                                           
               MOVE REQ-CCID TO WK-REQ-CCID                                     
               PERFORM CHECK-CCID-SN                                            
             END-IF                                                             
           END-IF                                                               
                                                                                
           EXIT.                                                                
                                                                                
      *-----------------------------------------------------------------00400000
       CHECK-CCID-SN.                                                           
      *-----------------------------------------------------------------        
                                                                                
           MOVE ZERO TO WK-TALLY                                                
           INSPECT FUNCTION REVERSE(WK-REQ-CCID)                                
                   TALLYING WK-TALLY FOR LEADING SPACES                         
           COMPUTE TRIMMED-LEN = 12 - WK-TALLY                                  
                                                                                
           IF TRIMMED-LEN = 10                                                  
                                                                                
            IF WK-REQ-CCID-SUFIX-NUM IS NUMERIC                                 
                                                                                
              MOVE WK-REQ-CCID(1:10) TO SN-OBJECT-NUMBER                        
              PERFORM VALIDATE-SN-OBJECT                                        
                                                                                
              IF RETURN-CODE = 0                                                
                                                                                
                DISPLAY "------------------------------------------"            
                DISPLAY "Servicenow Object STATE       : " OBJSTATE             
                DISPLAY "------------------------------------------"            
                                                                                
              ELSE                                                              
                                                                                
                DISPLAY "------------------------------------------"            
                DISPLAY "REXX Return Code              : " RETURN-CODE          
                DISPLAY "------------------------------------------"            
                                                                                
              END-IF                                                            
                                                                                
            ELSE                                                                
                                                                                
              MOVE 8 TO ECB-RETURN-CODE                                         
              MOVE 'ServiceNOW Object Number should be NUMERIC'                 
                   TO ECB-MESSAGE-TEXT                                          
              MOVE '0231'         TO ECB-MESSAGE-CODE                           
                                                                                
            END-IF                                                              
                                                                                
           ELSE                                                                 
                                                                                
             MOVE 8 TO ECB-RETURN-CODE                                          
             MOVE 'CCID For ServiceNOW Must Have 10 CHARACTERS'                 
                  TO ECB-MESSAGE-TEXT                                           
             MOVE '0230' TO ECB-MESSAGE-CODE                                    
                                                                                
           END-IF                                                               
                                                                                
           EXIT.                                                                
                                                                                
      *-----------------------------------------------------------------00400000
       VALIDATE-SN-OBJECT.                                                      
      *-----------------------------------------------------------------00400000
      *    MOVE 'SETDUB1S' TO PGM                                               
      *                                                                         
      *    CALL PGM USING BY REFERENCE RACF_GROUP                               
      *                                                                         
      ***************************************************************           
           MOVE SN-OBJECT-NUMBER    TO SNOWOBJ                                  
           MOVE 'BASIC'             TO AUTHTYPE                                 
                                                                                
           IF REQ-CCID(1:3) = 'CHG'                                             
             MOVE 'VALCHG'          TO ACTION                                   
           ELSE                                                                 
             MOVE 'VALINC'          TO ACTION                                   
           END-IF                                                               
                                                                                
           MOVE SPACES              TO OBJSTATE                                 
                                                                                
           CALL PGM-NAME USING BY REFERENCE IRXPARM                             
                                                                                
           IF RETURN-CODE NOT = 0                                               
                                                                                
              IF TRACE-ENABLE                                                   
                                                                                
               DISPLAY "------------------------------------------"             
               DISPLAY "REXX Return Code              : " RETURN-CODE           
               DISPLAY "------------------------------------------"             
                                                                                
              END-IF                                                            
                                                                                
              MOVE 8 TO ECB-RETURN-CODE                                         
              MOVE '0236' TO ECB-MESSAGE-CODE                                   
              MOVE 'ServiceNow Obj could not be validated in the service        
      -    'now instance.'                                                      
                    TO ECB-MESSAGE-TEXT                                         
                                                                                
           ELSE                                                                 
             IF TRACE-ENABLE                                                    
               DISPLAY "------------------------------------------"             
               DISPLAY "REXX Return Code              : " RETURN-CODE           
               DISPLAY "Servicenow CR STATE           : " OBJSTATE              
               DISPLAY "------------------------------------------"             
             END-IF                                                             
           END-IF                                                               
                                                                                
                                                                                
           EXIT.                                                                
                                                                                
      *-----------------------------------------------------------------        
       CHECK-TRACE-DDNAME-ALLOC.                                                
      *-----------------------------------------------------------------        
      * validate if DDNAME SNOWTRACE esta activaE                               
                                                                                
           CALL WS-DYN-PGM USING WDYN-VALUE                                     
                           RETURNING WS-RC.                                     
           IF WS-RC = 0                                                         
                                                                                
            MOVE 1 TO TRACEAPI                                                  
                                                                                
           END-IF                                                               
                                                                                
           EXIT.                                                                
                                                                                
                                                                                
