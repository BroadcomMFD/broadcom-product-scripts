APIALSUM TITLE 'ENDEVOR - API LIST PACKAGE ACTION SUMMARY'                      
*  THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF                  
*  "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE                  
*  FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES                
*  ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE                    
*  CORRECTED.                                                                   
*                                                                               
*  /* WRITTEN BY DAN WALTHER */                                                 
***********************************************************************         
*   DESCRIPTION: THIS SAMPLE PROGRAM ISSUES REQUESTS TO THE                     
*                ENDEVOR API TO EXTRACT ENDEVOR PACKAGE BACKOUT INFO.           
*                                                                               
*   HOW TO USE:  PASS THE PACKAGE NAME IN THE PARM WITH THE PROGRAM             
*                CALL.                                                          
*          EXAMPLE:                                                             
*                EXEC PGM=NDVRC1,                                               
*                PARM='CONCALL,DDN:STEPLIB,APIALSUM,PR#BACKOUT#TEST1'           
*                                                                               
*   REGISTER USAGE:                                                             
*                R2     -> SAVE RETURN CODE                                     
*                R3     -> SAVE REASON CODE                                     
*                R12    -> BASE PROGRAM                                         
*                R13    -> STANDARD USAGE........                               
*                R15    -> RETURN CODE FROM CALL                                
*   ==>                 -> WE USE STANDARD STACK SAVEAREA USAGE                 
*                                                                               
***********************************************************************         
*   WORKAREA                                                                    
***********************************************************************         
WORKAREA DSECT                                                                  
SAVEAREA DS    18F                                                              
WPARMLST DS    4F                      PARAMETER LIST                           
WCNT     DS    H                       ACTION COUNTER                           
         DS    0D                                                               
***********************************************************************         
* API CONTROL BLOCK                                                             
** CAPRD.SIQ7006.SOURCE(ENHALSUM)                                               
***********************************************************************         
         ENHAACTL DSECT=NO                                                      
***********************************************************************         
* API ACTION REQUEST BLOCKS                                                     
***********************************************************************         
         ENHALSUM DSECT=NO                                                      
WORKLN   EQU   *-WORKAREA                                                       
***********************************************************************         
*   REQISTER EQUATES                                                            
***********************************************************************         
R0       EQU   0                                                                
R1       EQU   1                                                                
R2       EQU   2                                                                
R3       EQU   3                                                                
R4       EQU   4                                                                
R5       EQU   5                                                                
R6       EQU   6                                                                
R7       EQU   7                                                                
R8       EQU   8                                                                
R9       EQU   9                                                                
R10      EQU   10                                                               
R11      EQU   11                                                               
R12      EQU   12                                                               
R13      EQU   13                                                               
R14      EQU   14                                                               
R15      EQU   15                                                               
APIALSUM CSECT                                                                  
APIALSUM AMODE 31                                                               
APIALSUM RMODE ANY                                                              
***********************************************************************         
*   HOUSEKEEPING                                                                
***********************************************************************         
         SAVE  (14,12)                 SAVE CALLERS REG 12(13)                  
         LR    R12,R15                 POINT TO THIS PROGRAM                    
        USING APIALSUM,R12                                                      
***********************************************************************         
*   VALIDATE PARM LEN                                                           
***********************************************************************         
*                                                                               
         L     R6,0(,R1)                                                        
         LA    R6,2(,R6)               POINT TO package id in parm              
*                                                                               
***********************************************************************         
*   GET STORAGE FOR WORKAREA                                                    
***********************************************************************         
         L     R0,=A(WORKLN)           GET SIZE OF W.A                          
         GETMAIN R,LV=(0)              GET WORKING STORAGE                      
         ST    R1,8(R13)               STORE NEW STACK +8(OLD)                  
         ST    R13,4(R1)               STORE OLD STACK +4(NEW)                  
         LR    R13,R1                  POINT R13 TO OUR STACK                   
        USING SAVEAREA,R13             ESTABLISH ADDRESSIBILIY                  
         SPACE ,                                                                
************************************************************                    
*        INITIALIZE AND POPULATE THE CONTROL STRUCTURE                          
*        NOTE: IF ANY INVENTORY MANAGEMENT MESSAGES ARE ISSUED, THEY            
*        ARE WRITTEN TO THE MSG DATA SET. THE OUTPUT FROM THIS REQUEST          
*        IS WRITTEN TO THE LIST DATA SET.                                       
************************************************************                    
*                                                                               
XSCL000  DS    0H                                                               
************************************************************                    
*        INITIALIZE AND POPULATE THE REQUEST STRUCTURE                          
************************************************************                    
*                                                                               
         API$INIT STG=AACTL,BLOCK=AACTL                                         
         API$INIT STG=ALSUM_RQ,BLOCK=ALSUM_RQ                                   
         API$INIT STG=ALSUM_RS,BLOCK=ALSUM_RS                                   
*                                                                               
         MVC   AACTL_MSG_DDN(8),=C'APIMSGS '                                    
         MVC   AACTL_LIST_DDN(8),=C'APILIST '                                   
*                                                                               
         MVC   ALSUM_RQ_PKGID(16),0(R6) Move package id to request              
*                                                                               
************************************************************                    
*        BUILD PARMLIST                                                         
************************************************************                    
         LA    R1,WPARMLST                                                      
         LA    R14,AACTL                                                        
         ST    R14,0(0,R1)                                                      
         LA    R14,ALSUM_RQ                                                     
         ST    R14,4(0,R1)                                                      
         LA    R14,ALSUM_RS                                                     
         ST    R14,8(0,R1)                                                      
         OI    8(R1),X'80'                                                      
************************************************************                    
*                                                                               
*        CALL THE ENDEVOR API INTERFACE PROGRAM                                 
************************************************************                    
XCALLAPI DS    0H                                                               
         L     R15,=V(ENA$NDVR)                                                 
         BALR  R14,R15                                                          
         LR    R2,R15                    HOLD ONTO THE RETURN CODE              
         LR    R3,R0                     HOLD ONTO THE REASON CODE              
************************************************************                    
* SHUTDOWN THE API SERVER. ONLY THE AACTL BLOCK IS REQUIRED.                    
************************************************************                    
XSHUTDWN DS    0H                                                               
         API$INIT STG=AACTL,BLOCK=AACTL                                         
         MVI   AACTL_SHUTDOWN,C'Y'                                              
         LA    R1,WPARMLST                                                      
         LA    R14,AACTL                                                        
         ST    R14,0(0,R1)                                                      
         OI    0(R1),X'80'                                                      
         L     R15,=V(ENA$NDVR)                                                 
         BALR  R14,R15                                                          
***********************************************************************         
* PROGRAM EXIT                                                                  
***********************************************************************         
         LR    R5,R13                  SAVE SAVEAREA ADDRESS                    
         L     R13,4(R13)              POINT TO PREVIOUS SAVEAREA               
*   CLEAN UP THIS PROGRAM'S STORAGE                                             
         L     R0,=A(WORKLN)                GET SIZE                            
         FREEMAIN R,A=(R5),LV=(R0)          FREE STORAGE                        
         LR    R15,R2                       SET RETURN CODE                     
         L     R14,12(R13)                                                      
         LM    R0,R12,20(R13)                                                   
         BSM   0,R14                        RETURN                              
         END                                                                    
