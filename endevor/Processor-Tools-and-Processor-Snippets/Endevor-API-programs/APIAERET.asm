APIAERET TITLE 'ENDEVOR - API LIST ELEMENT LOCATIONS '
***********************************************************************
*   DESCRIPTION: THIS SAMPLE PROGRAM ISSUES REQUESTS TO THE
*                ENDEVOR API TO EXTRACT ENDEVOR PACKAGE BACKOUT INFO.
*
*   HOW TO USE:  PASS Endevor element information  WITH THE PROGRAM
*                CALL.
*          EXAMPLE:
*
*  //STEP1    EXEC PGM=NDVRC1,
*  // PARM='APIAERETSMPLPRODCATSNDVR*       *       API*      *'
*  //*PARM='APIAERET-ENV----SYS-----SUB-----TYPE----ELEMENT---S'
*  //*PARM='APIAERET----+--8----+--8----+--8----+--8--------10S'
*                EXEC PGM=NDVRC1,
*                PARM='CONCALL,DDN:STEPLIB,APIAERET,PR#BACKOUT#TEST1'
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
***********************************************************************
         ENHAACTL DSECT=NO
***********************************************************************
* API ACTION REQUEST BLOCKS
***********************************************************************
         ENHAERET DSECT=NO
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
APIAERET CSECT
APIAERET AMODE 31
APIAERET RMODE ANY
***********************************************************************
*   HOUSEKEEPING
***********************************************************************
         SAVE  (14,12)                 SAVE CALLERS REG 12(13)
         LR    R12,R15                 POINT TO THIS PROGRAM
         USING APIAERET,R12
***********************************************************************
*   VALIDATE PARM LEN
***********************************************************************
*
         L     R6,0(,R1)
         LA    R6,2(,R6)               POINT TO package id in parm
*
*                                      Parameter contains Endevor info
*                                      AERET_RQ_ENV    (8)
*                                      AERET_RQ_SYSTEM (8)
*                                      AERET_RQ_SUBSYS (8)
*                                      AERET_RQ_TYPE   (8)
*                                      AERET_RQ_ELM    (10)
*                                      AERET_RQ_STG_ID (1)
*
***********************************************************************
*   GET STORAGE FOR WORKAREA
***********************************************************************
         L     R0,=A(WORKLN)           GET SIZE OF W.A
         GETMAIN R,LV=(0)              GET WORKING STORAGE
         ST    R1,8(R13)               STORE NEW STACK +8(OLD)
         ST    R13,4(R1)               STORE OLD STACK +4(NEW)
         LR    R13,R1                  POINT R13 TO OUR STACK
         USING SAVEAREA,R13            ESTABLISH ADDRESSIBILIY
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
         API$INIT STG=AERET_RQ,BLOCK=AERET_RQ
*
         MVC   AACTL_MSG_DDN(8),=C'APIMSGS '   DDNAME for Messages
         MVC   AACTL_LIST_DDN(8),=C'APILIST '  DDNAME for list out
*
         MVC   AERET_RQ_ENV,0(R6)          Move Environment
         MVC   AERET_RQ_SYSTEM(8),08(R6)   Move SYSTEM
         MVC   AERET_RQ_SUBSYS(8),16(R6)   Move SUBSYS
         MVC   AERET_RQ_TYPE(8),24(R6)     Move TYPE
         MVC   AERET_RQ_ELM(10),32(R6)     Move Element
         MVC   AERET_RQ_STG_ID(1),42(R6)   Move STG_ID
         MVC   AERET_RQ_DDN(8),43(R6)      Move DDNAME for output
         MVI   AERET_RQ_NO_SIGNO,C'Y'      Request w/o Signout
         MVI   AERET_RQ_EXPAND,C'Y'        Request with Expand
         MVI   AERET_RQ_REPLACE,C'Y'       Request REPLACE
         MVI   AERET_RQ_SEARCH,C'Y'        Request SEARCH
*
************************************************************
*        BUILD PARMLIST
************************************************************
         LA    R1,WPARMLST
         LA    R14,AACTL
         ST    R14,0(0,R1)
         LA    R14,AERET_RQ
         ST    R14,4(0,R1)
         OI    4(R1),X'80'
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
