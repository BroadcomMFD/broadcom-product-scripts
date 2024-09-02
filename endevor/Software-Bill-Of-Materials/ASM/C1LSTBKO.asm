C1LSTBKO TITLE 'LIST PACKAGE BACKOUTS'                                          
***********************************************************************         
*   DESCRIPTION: THIS SAMPLE PROGRAM ISSUES A REQUEST TO THE                    
*                ENDEVOR API TO EXECUTE LIST PACKAGE BACKOUT                    
*                USING ENDEVOR API.                                             
*                                                                               
*   LINK EDIT:   AMODE=31,RMODE=24,RENT,REUS (RECOMMENDED)                      
*                OR                                                             
*                AMODE=24,RMODE=24,RENT,REUS                                    
*                                                                               
*   REGISTERS ON ENTRY:                                                         
*                                                                               
*   REGISTER USAGE:                                                             
*                R1     -> PARAMETER LIST                                       
*                R2     -> SAVE RETURN CODE                                     
*                R3     -> SAVE REASON CODE                                     
*                R12    -> BASE PROGRAM                                         
*                R13    -> STANDARD USAGE........                               
*                R15    -> RETURN CODE FROM CALL                                
*   ==>                 -> WE USE STANDARD STACK SAVEAREA USAGE                 
*                                                                               
*   THIS TEST PROGRAM PERFORMS THE FOLLOWING PACKAGE ACTIONS;                   
*         -- LBKO     LIST BACK-OUT INFORMATION FOR A PKG                       
*            HOW MANY ACTIONS ARE EXECUTED.  AS DELIVERED, ALL 7                
*            LIST PACKAGE ACTION WILL BE EXECUTED.                              
***********************************************************************         
*   WORKAREA                                                                    
***********************************************************************         
WORKAREA DSECT                                                                  
SAVEAREA DS    18F                                                              
WPARMLST DS    3A                      PARAMETER LIST                           
WCNT     DS    H                       ACTION COUNTER                           
PKGID    DS    CL16                                                             
         DS    0D                                                               
***********************************************************************         
* API CONTROL BLOCK                                                             
***********************************************************************         
         ENHAACTL DSECT=NO                                                      
***********************************************************************         
* API PACKAGE ACTION REQUEST BLOCKS                                             
***********************************************************************         
         ENHALBKO DSECT=NO                                                      
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
***********************************************************************         
C1LSTBKO CSECT                                                                  
C1LSTBKO AMODE 31                                                               
C1LSTBKO RMODE ANY                                                              
***********************************************************************         
*   HOUSEKEEPING                                                                
***********************************************************************         
         SAVE  (14,12)                 SAVE CALLERS REG 12(13)                  
         LR    R12,R15                 POINT TO THIS PROGRAM                    
         LR    R4,R1                   PARAMETER LIST ADDRESS                   
         USING C1LSTBKO,R12                                                     
***********************************************************************         
*   GET STORAGE FOR WORKAREA                                                    
***********************************************************************         
         L     R0,=A(WORKLN)           GET SIZE OF W.A                          
         GETMAIN R,LV=(0)              GET WORKING STORAGE                      
         ST    R1,8(R13)               STORE NEW STACK +8(OLD)                  
         ST    R13,4(R1)               STORE OLD STACK +4(NEW)                  
         LR    R13,R1                  POINT R13 TO OUR STACK                   
         LR    R11,R1                  LOAD SECOND BASE REGISTER                
         AHI   R11,4096                MOVE FOR 4096 BYTES                      
         USING SAVEAREA,R13,R11        ESTABLISH ADDRESSIBILIY                  
         SPACE ,                                                                
************************************************************                    
*        GET PACKAGE ID PASSED TO THIS PROGRAM                                  
************************************************************                    
         L    R4,0(R4)                                                          
         N    R4,=X'7FFFFFFF'                                                   
         LH   R5,0(R4)            GET  LENGTH                                   
         LTR  R5,R5                                                             
         BZ   NOPKGID                                                           
         BCTR R5,0                                                              
         MVC  PKGID,=CL16' '                                                    
         EX   R5,MOVEPKG                                                        
************************************************************                    
*        INITIALIZE AND POPULATE THE CONTROL STRUCTURE                          
*        NOTE: IF ANY INVENTORY MANAGEMENT MESSAGES ARE ISSUED, THEY            
*        ARE WRITTEN TO THE MSG DATA SET. THE OUTPUT FROM THIS REQUEST          
*        IS WRITTEN TO THE LIST DATA SET.                                       
************************************************************                    
         API$INIT STG=AACTL,BLOCK=AACTL                                         
         MVI   AACTL_SHUTDOWN,C'N'                                              
         MVC   AACTL_MSG_DDN,=CL8'APIMSGS '                                     
         MVC   AACTL_LIST_DDN,=CL8'       '                                     
         MVC   AACTL_STOPRC,=H'16'                                              
*                                                                               
************************************************************                    
BACKOUT  DS    0H                                                               
         MVC   AACTL_MSG_DDN,=CL8'BOUTMSG '                                     
         MVC   AACTL_LIST_DDN,=CL8'BOUTLST '                                    
*                                                                               
************************************************************                    
* LIST PACKAGE BACKOUT INFORMATION REQUEST                                      
*        INITIALIZE AND POPULATE THE REQUEST STRUCTURE                          
************************************************************                    
LISTBOUT DS    0H                                                               
         API$INIT STG=ALBKO_RQ,BLOCK=ALBKO_RQ                                   
         API$INIT STG=ALBKO_RS,BLOCK=ALBKO_RS                                   
* PACKAGE SELECTION CRITERIA                                                    
         MVC   ALBKO_RQ_PKGID,PKGID                                             
*                                                                               
************************************************************                    
*        BUILD PARMLIST                                                         
************************************************************                    
BLDPARML DS    0H                                                               
         LA    R1,WPARMLST                                                      
         LA    R14,AACTL                                                        
         ST    R14,0(0,R1)                                                      
         LA    R14,ALBKO_RQ                                                     
         ST    R14,4(0,R1)                                                      
         LA    R14,ALBKO_RS                                                     
         ST    R14,8(0,R1)                                                      
         OI    8(R1),X'80'                                                      
*                                                                               
************************************************************                    
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
         B     EXITOK                                                           
***********************************************************************         
* PROGRAM EXIT                                                                  
***********************************************************************         
NOPKGID  DS    0H                                                               
         WTO   'C1LSTBKO - NO PACKAGE ID PASSED TO THIS PROGRAM'                
         LA    R7,114                                                           
EXITOK   DS    0H                      SAVE SAVEAREA ADDRESS                    
         LR    R5,R13                  SAVE SAVEAREA ADDRESS                    
         L     R13,4(R13)              POINT TO PREVIOUS SAVEAREA               
*   CLEAN UP THIS PROGRAM'S STORAGE                                             
         L     R0,=A(WORKLN)                GET SIZE                            
         FREEMAIN R,A=(R5),LV=(R0)          FREE STORAGE                        
         C     R7,=F'114'                                                       
         BE    EXTNPARM                                                         
         LR    R15,R2                       SET RETURN CODE FROM CALL           
         B     LOADSA                                                           
EXTNPARM DS    0H                                                               
         LR    R15,R7                                                           
LOADSA   L     R14,12(R13)                                                      
         LM    R0,R12,20(R13)                                                   
         BSM   0,R14                        RETURN                              
MOVEPKG  MVC   PKGID(0),2(R4)                                                   
         END                                                                    
