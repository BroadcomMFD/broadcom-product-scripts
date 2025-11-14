      ******************************************************************00110000
       IDENTIFICATION DIVISION.                                                 
      ******************************************************************00110000
                                                                                
       PROGRAM-ID. C1X7CUST.                                                    
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
                                                                                
       01 WK-PKG-SNOW.                                                          
          03  WK-PKG-SNOW-MOD                    PIC X(3).                      
          03  WK-PKG-SNOW-SUFIX.                                                
            05  WK-PKG-SNOW-SUFIX-NUM            PIC 9(7).                      
          03  WK-PKG-SNOW-PAD                    PIC X(6).                      
                                                                                
       01 WK-ENV                                 PIC X(8).                      
       01 SN-OBJECT-NUMBER                       PIC X(10).                     
       01 PGM                                    PIC X(8).                      
                                                                                
       77 WK-TALLY                               PIC 9(2).                      
       77 TRIMMED-LEN                            PIC 9(2).                      
                                                                                
                                                                                
                                                                                
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
       LINKAGE SECTION.                                                         
      *-----------------------------------------------------------------        
                                                                                
       COPY PKGXBLKS.                                                           
                                                                                
      ******************************************************************        
       PROCEDURE DIVISION USING PACKAGE-EXIT-BLOCK                              
                                PACKAGE-REQUEST-BLOCK                           
                                PACKAGE-EXIT-HEADER-BLOCK                       
                                PACKAGE-EXIT-FILE-BLOCK                         
                                PACKAGE-EXIT-ACTION-BLOCK                       
                                PACKAGE-EXIT-APPROVER-MAP                       
                                PACKAGE-EXIT-BACKOUT-BLOCK                      
                                PACKAGE-EXIT-SHIPMENT-BLOCK                     
                                PACKAGE-EXIT-SCL-BLOCK                          
                                PACKAGE-EXIT-COLLECT-BLOCK.                     
      ******************************************************************        
                                                                                
      *-----------------------------------------------------------------        
       MAIN SECTION.                                                            
      *-----------------------------------------------------------------00110000
                                                                                
           MOVE 0 TO TRACEAPI                                                   
           PERFORM CHECK-TRACE-DDNAME-ALLOC                                     
                                                                                
           IF TRACE-ENABLE                                                      
                                                                                
              DISPLAY '---------------------------------------------'           
                                                                                
              DISPLAY 'EX07 - START'                                            
              DISPLAY 'EX07'                                                    
              DISPLAY 'EX07 - PACKAGE-ID ' PECB-PACKAGE-ID                      
              DISPLAY 'EX07 - FUNCTION   ' PECB-FUNCTION-LITERAL                
              DISPLAY 'EX07 - SUBFUNC    ' PECB-SUBFUNC-LITERAL                 
              DISPLAY 'EX07 - BEF-AFTER  ' PECB-BEF-AFTER-LITERAL               
              DISPLAY 'EX07'                                                    
              DISPLAY 'EX07 - STOP'                                             
                                                                                
              DISPLAY '---------------------------------------------'           
                                                                                
           END-IF                                                               
                                                                                
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
                                                                                
           PERFORM P-MAIN                                                       
                                                                                
           GOBACK.                                                              
                                                                                
      *-----------------------------------------------------------------        
       P-MAIN.                                                                  
      *-----------------------------------------------------------------        
                                                                                
           EVALUATE TRUE                                                        
             WHEN SETUP-EXIT-OPTIONS                                            
               MOVE 'N' TO PECB-BEFORE-BACKIN                                   
               MOVE 'N' TO PECB-AFTER-BACKIN                                    
               MOVE 'N' TO PECB-BEFORE-BACKOUT                                  
               MOVE 'N' TO PECB-AFTER-BACKOUT                                   
               MOVE 'N' TO PECB-BEFORE-CAST                                     
               MOVE 'N' TO PECB-MID-CAST                                        
               MOVE 'N' TO PECB-AFTER-CAST                                      
               MOVE 'N' TO PECB-BEFORE-COMMIT                                   
               MOVE 'N' TO PECB-AFTER-COMMIT                                    
               MOVE 'Y' TO PECB-BEFORE-CREATE-BLD                               
               MOVE 'N' TO PECB-AFTER-CREATE-BLD                                
               MOVE 'Y' TO PECB-BEFORE-CREATE-COPY                              
               MOVE 'N' TO PECB-AFTER-CREATE-COPY                               
               MOVE 'Y' TO PECB-BEFORE-CREATE-EDIT                              
               MOVE 'N' TO PECB-AFTER-CREATE-EDIT                               
               MOVE 'Y' TO PECB-BEFORE-CREATE-IMPT                              
               MOVE 'N' TO PECB-AFTER-CREATE-IMPT                               
               MOVE 'N' TO PECB-BEFORE-DELETE                                   
               MOVE 'N' TO PECB-AFTER-DELETE                                    
               MOVE 'N' TO PECB-BEFORE-DSPLY-APPR                               
               MOVE 'N' TO PECB-BEFORE-DSPLY-BKOUT                              
               MOVE 'N' TO PECB-BEFORE-DSPLY-SCL                                
               MOVE 'N' TO PECB-BEFORE-DSPLY-ELMSM                              
               MOVE 'N' TO PECB-BEFORE-DSPLY-PKG                                
               MOVE 'N' TO PECB-BEFORE-DSPLY-RPT                                
               MOVE 'N' TO PECB-BEFORE-EXEC                                     
               MOVE 'N' TO PECB-AFTER-EXEC                                      
               MOVE 'N' TO PECB-BEFORE-EXPORT                                   
               MOVE 'N' TO PECB-AFTER-EXPORT                                    
               MOVE 'Y' TO PECB-BEFORE-GENPID                                   
               MOVE 'N' TO PECB-AFTER-GENPID                                    
               MOVE 'N' TO PECB-BEFORE-LIST                                     
               MOVE 'N' TO PECB-AFTER-LIST                                      
               MOVE 'N' TO PECB-BEFORE-MOD-BLD                                  
               MOVE 'N' TO PECB-AFTER-MOD-BLD                                   
               MOVE 'N' TO PECB-BEFORE-MOD-CPY                                  
               MOVE 'N' TO PECB-AFTER-MOD-CPY                                   
               MOVE 'N' TO PECB-BEFORE-MOD-EDIT                                 
               MOVE 'N' TO PECB-AFTER-MOD-EDIT                                  
               MOVE 'N' TO PECB-BEFORE-MOD-IMPT                                 
               MOVE 'N' TO PECB-AFTER-MOD-IMPT                                  
               MOVE 'N' TO PECB-BEFORE-RESET                                    
               MOVE 'N' TO PECB-AFTER-RESET                                     
               MOVE 'N' TO PECB-BEFORE-REV-APPR                                 
               MOVE 'N' TO PECB-AFTER-REV-APPR                                  
               MOVE 'N' TO PECB-BEFORE-REV-DENY                                 
               MOVE 'N' TO PECB-AFTER-REV-DENY                                  
               MOVE 'N' TO PECB-BEFORE-SHIP-XMIT                                
               MOVE 'N' TO PECB-AFTER-SHIP-XMIT                                 
               MOVE 'N' TO PECB-BEFORE-SHIP-CON                                 
               MOVE 'N' TO PECB-AFTER-SHIP-CON                                  
             WHEN CREATE-PACKAGE                                                
               EVALUATE TRUE                                                    
                 WHEN PECB-BEFORE                                               
                  IF PECB-UEXIT-HOLD-FIELD = 8                                  
                    MOVE 8 TO PECB-NDVR-EXIT-RC                                 
                    MOVE '0719' TO PECB-MESSAGE-ID                              
                    MOVE 'Package creation Error.'                              
                      TO PECB-MESSAGE                                           
                  END-IF                                                        
                 WHEN PECB-AFTER                                                
                   EXIT                                                         
               END-EVALUATE                                                     
             WHEN GENERATE-PACKAGE-ID                                           
               EVALUATE TRUE                                                    
                 WHEN PECB-BEFORE                                               
                   PERFORM PROCESS-GENPKGID-GEN                                 
                   MOVE PECB-NDVR-EXIT-RC TO PECB-UEXIT-HOLD-FIELD              
                 WHEN PECB-AFTER                                                
                   EXIT                                                         
               END-EVALUATE                                                     
           END-EVALUATE                                                         
                                                                                
           EXIT.                                                                
                                                                                
                                                                                
      *-----------------------------------------------------------------00400000
       PROCESS-GENPKGID-GEN.                                                    
      *-----------------------------------------------------------------00400000
           IF PECB-PACKAGE-ID(1:3) ='INC' OR                                    
              PECB-PACKAGE-ID(1:3) ='CHG'                                       
                                                                                
               MOVE PECB-PACKAGE-ID TO WK-PKG-SNOW                              
               PERFORM CHECK-PKGID-SN                                           
                                                                                
           END-IF                                                               
                                                                                
           EXIT.                                                                
                                                                                
      *-----------------------------------------------------------------00400000
       CHECK-PKGID-SN.                                                          
      *-----------------------------------------------------------------        
                                                                                
           MOVE ZERO TO WK-TALLY                                                
           INSPECT FUNCTION REVERSE(WK-PKG-SNOW)                                
                   TALLYING WK-TALLY FOR LEADING SPACES                         
           COMPUTE TRIMMED-LEN = 16 - WK-TALLY                                  
                                                                                
           DISPLAY 'TRIMMED-LEN: 'TRIMMED-LEN                                   
                                                                                
           IF TRIMMED-LEN >= 10                                                 
                                                                                
            IF WK-PKG-SNOW-SUFIX-NUM IS NUMERIC                                 
                                                                                
              MOVE WK-PKG-SNOW(1:10) TO SN-OBJECT-NUMBER                        
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
                                                                                
              MOVE 8 TO PECB-NDVR-EXIT-RC                                       
              MOVE '0729' TO PECB-MESSAGE-ID                                    
              MOVE 'Package ID for ServiceNow Object must be numeric'           
                     TO PECB-MESSAGE                                            
                                                                                
            END-IF                                                              
                                                                                
           ELSE                                                                 
                                                                                
             MOVE 8 TO PECB-NDVR-EXIT-RC                                        
             MOVE '0710' TO PECB-MESSAGE-ID                                     
             MOVE 'PackageID for ServiceNow object must have at least           
      -    '10 characters.'                                                     
                   TO PECB-MESSAGE                                              
                                                                                
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
                                                                                
           IF PECB-PACKAGE-ID(1:3) = 'CHG'                                      
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
                                                                                
              MOVE 8 TO PECB-NDVR-EXIT-RC                                       
              MOVE '0717' TO PECB-MESSAGE-ID                                    
              MOVE 'ServiceNow Obj could not be validated in the service        
      -    'now instance.'                                                      
                    TO PECB-MESSAGE                                             
                                                                                
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
                                                                                
                                                                                
