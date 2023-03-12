APIAESCL TITLE 'ENDEVOR - API SAMPLE ASSEMBLER PROGRAM'
*  THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF
*  "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE
*  FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES
*  ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE
*  CORRECTED.
*
*  This API executes standard Enedevor element action SCL as
*      provoded by the caller in its parameter .                 
*      WRITTEN BY DAN WALTHER 
*
***********************************************************************
*   DESCRIPTION: THIS SAMPLE PROGRAM ISSUES REQUESTS TO THE
*                ENDEVOR API TO EXERCISE EACH OF THE ELEMENT ACTIONS.
*
*                ADD, DELETE, GENERATE, MOVE, PRINT ELEMENT, PRINT
*                MEMBER, RETRIEVE, SIGNIN, TRANSFER AND UPDATE.
*
*   HOW TO USE:  POPULATE THE CONTROL AND REQUEST BLOCKS WITH THE
*                DESIRED VALUES.
*                ASSEMBLE AND LINK-EDIT THIS MODULE.
*
*   LINK EDIT:   AMODE=31,RMODE=24,RENT,REUS (RECOMMENDED)
*                OR
*                AMODE=24,RMODE=24,RENT,REUS
*
*   REGISTERS ON ENTRY:
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
WPARMLST DS    3A                      PARAMETER LIST
WCNT     DS    H                       ACTION COUNTER
         DS     0D
***********************************************************************
* API CONTROL BLOCK
***********************************************************************
         ENHAACTL DSECT=NO
***********************************************************************
* API ACTION REQUEST BLOCKS
***********************************************************************
         ENHAUSCL DSECT=NO
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
APIAESCL CSECT
APIAESCL AMODE 31
APIAESCL RMODE ANY
***********************************************************************
*   HOUSEKEEPING
***********************************************************************
         SAVE  (14,12)                 SAVE CALLERS REG 12(13)
         LR    R12,R15                 POINT TO THIS PROGRAM
        USING APIAESCL,R12
***********************************************************************
*   VALIDATE PARM LEN
***********************************************************************
*
         L     R6,0(,R1)
         SLR   R9,R9
         ICM   R9,B'1100',0(R6)
         SRL   R9,16
*
         C     R9,=F'2000'
         BH    BADEND
         LA    R8,2(,R6)               POINT TO PARMS (SCL STMTS)
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
*   PERFORM SCL ACTION
************************************************************
*
         API$INIT STG=AUSCL_RQ,BLOCK=AUSCL_RQ
*
         MVI   AUSCL_RQ_SCLTYPE,AUSCL_RQ_SCLTYPE_E
         LA    R6,AUSCL_RQ_SCL1        POINT TO SCL IN API BLOCK
         LR    R7,R9                   COPY PARM LENGTH
         MVCL  R6,R8                   COPY SCL STMTS IN PARM
*
************************************************************
* SCL ELEMENT REQUEST
*        INITIALIZE AND POPULATE THE REQUEST STRUCTURE
************************************************************
*
         API$INIT STG=AACTL,BLOCK=AACTL
*
         MVC   AACTL_MSG_DDN(8),=C'APIMSGS '   DDNAME for Messages
*        The APILIST dd is not needed, and causes RC:4
*        MVC   AACTL_LIST_DDN(8),=C'APILIST '  DDNAME for list out
*
************************************************************
*        BUILD PARMLIST
************************************************************
         LA    R1,WPARMLST
         LA    R14,AACTL
         ST    R14,0(0,R1)
         LA    R14,AUSCL_RQ
         ST    R14,4(0,R1)
         OI    4(R1),X'80'
*
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
***********************************************************************
* PROGRAM EXIT
***********************************************************************
         LR    R5,R13                  SAVE SAVEAREA ADDRESS
         L     R13,4(R13)              POINT TO PREVIOUS SAVEAREA
*   CLEAN UP THIS PROGRAM'S STORAGE
         L     R0,=A(WORKLN)                GET SIZE
         FREEMAIN R,A=(R5),LV=(R0)          FREE STORAGE
         LR    R15,R2                       SET RETURN CODE FROM CALL
         L     R14,12(R13)
         LM    R0,R12,20(R13)
         BSM   0,R14                        RETURN
BADEND   DS    0H
         LA    R15,17                       SET BAD RETURN CODE
         L     R14,12(R13)
         LM    R0,R12,20(R13)
         BSM   0,R14                        RETURN
         END
