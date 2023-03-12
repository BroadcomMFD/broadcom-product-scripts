APIALELM TITLE 'ENDEVOR - API LIST ELEMENT LOCATIONS '                  00010000
*********************************************************************** 00020000
*   DESCRIPTION: THIS SAMPLE PROGRAM ISSUES REQUESTS TO THE             00030000
*                ENDEVOR API TO EXTRACT ENDEVOR PACKAGE BACKOUT INFO.   00040000
*                                                                       00050000
*   HOW TO USE:  PASS Endevor element information  WITH THE PROGRAM     00060000
*                CALL.                                                  00070000
*          EXAMPLE:                                                     00080000
*                                                                       00090000
*  //STEP1    EXEC PGM=NDVRC1,                                          00100000
*  // PARM='APIALELMSMPLPRODCATSNDVR*       *       API*      *'        00110000
*  //*PARM='APIALELM-ENV----SYS-----SUB-----TYPE----ELEMENT---S'        00120000
*  //*PARM='APIALELM----+--8----+--8----+--8----+--8--------10S'        00130000
*                EXEC PGM=NDVRC1,                                       00140000
*                PARM='CONCALL,DDN:STEPLIB,APIALELM,PR#BACKOUT#TEST1'   00150000
*                                                                       00160000
*   REGISTER USAGE:                                                     00170000
*                R2     -> SAVE RETURN CODE                             00180000
*                R3     -> SAVE REASON CODE                             00190000
*                R12    -> BASE PROGRAM                                 00200000
*                R13    -> STANDARD USAGE........                       00210000
*                R15    -> RETURN CODE FROM CALL                        00220000
*   ==>                 -> WE USE STANDARD STACK SAVEAREA USAGE         00230000
*                                                                       00240000
*********************************************************************** 00250000
*   WORKAREA                                                            00260000
*********************************************************************** 00270000
WORKAREA DSECT                                                          00280000
SAVEAREA DS    18F                                                      00290000
WPARMLST DS    4F                      PARAMETER LIST                   00300000
WCNT     DS    H                       ACTION COUNTER                   00310000
         DS    0D                                                       00320000
*********************************************************************** 00330000
* API CONTROL BLOCK                                                     00340000
*********************************************************************** 00350000
         ENHAACTL DSECT=NO                                              00360000
*********************************************************************** 00370000
* API ACTION REQUEST BLOCKS                                             00380000
*********************************************************************** 00390000
         ENHALELM DSECT=NO                                              00400000
WORKLN   EQU   *-WORKAREA                                               00410000
*********************************************************************** 00420000
*   REQISTER EQUATES                                                    00430000
*********************************************************************** 00440000
R0       EQU   0                                                        00450000
R1       EQU   1                                                        00460000
R2       EQU   2                                                        00470000
R3       EQU   3                                                        00480000
R4       EQU   4                                                        00490000
R5       EQU   5                                                        00500000
R6       EQU   6                                                        00510000
R7       EQU   7                                                        00520000
R8       EQU   8                                                        00530000
R9       EQU   9                                                        00540000
R10      EQU   10                                                       00550000
R11      EQU   11                                                       00560000
R12      EQU   12                                                       00570000
R13      EQU   13                                                       00580000
R14      EQU   14                                                       00590000
R15      EQU   15                                                       00600000
APIALELM CSECT                                                          00610000
APIALELM AMODE 31                                                       00620000
APIALELM RMODE ANY                                                      00630000
*********************************************************************** 00640000
*   HOUSEKEEPING                                                        00650000
*********************************************************************** 00660000
         SAVE  (14,12)                 SAVE CALLERS REG 12(13)          00670000
         LR    R12,R15                 POINT TO THIS PROGRAM            00680000
         USING APIALELM,R12                                             00690000
*********************************************************************** 00700000
*   VALIDATE PARM LEN                                                   00710000
*********************************************************************** 00720000
*                                                                       00730000
         L     R6,0(,R1)                                                00740000
         LA    R6,2(,R6)               POINT TO package id in parm      00750000
*                                                                       00760000
*                                      Parameter contains Endevor info  00770000
*                                      ALELM_RQ_ENV    (8)              00780000
*                                      ALELM_RQ_SYSTEM (8)              00790000
*                                      ALELM_RQ_SUBSYS (8)              00800000
*                                      ALELM_RQ_TYPE   (8)              00810000
*                                      ALELM_RQ_ELM    (10)             00820000
*                                      ALELM_RQ_STG_ID (1)              00830000
*                                                                       00840000
*********************************************************************** 00850000
*   GET STORAGE FOR WORKAREA                                            00860000
*********************************************************************** 00870000
         L     R0,=A(WORKLN)           GET SIZE OF W.A                  00880000
         GETMAIN R,LV=(0)              GET WORKING STORAGE              00890000
         ST    R1,8(R13)               STORE NEW STACK +8(OLD)          00900000
         ST    R13,4(R1)               STORE OLD STACK +4(NEW)          00910000
         LR    R13,R1                  POINT R13 TO OUR STACK           00920000
         USING SAVEAREA,R13            ESTABLISH ADDRESSIBILIY          00930000
         SPACE ,                                                        00940000
************************************************************            00950000
*        INITIALIZE AND POPULATE THE CONTROL STRUCTURE                  00960000
*        NOTE: IF ANY INVENTORY MANAGEMENT MESSAGES ARE ISSUED, THEY    00970000
*        ARE WRITTEN TO THE MSG DATA SET. THE OUTPUT FROM THIS REQUEST  00980000
*        IS WRITTEN TO THE LIST DATA SET.                               00990000
************************************************************            01000000
*                                                                       01010000
XSCL000  DS    0H                                                       01020000
************************************************************            01030000
*        INITIALIZE AND POPULATE THE REQUEST STRUCTURE                  01040000
************************************************************            01050000
*                                                                       01060000
         API$INIT STG=AACTL,BLOCK=AACTL                                 01070000
         API$INIT STG=ALELM_RQ,BLOCK=ALELM_RQ                           01080000
         API$INIT STG=ALELM_RS,BLOCK=ALELM_RS                           01090000
*                                                                       01100000
         MVC   AACTL_MSG_DDN(8),=C'APIMSGS '   DDNAME for Messages      01110000
         MVC   AACTL_LIST_DDN(8),=C'APILIST '  DDNAME for list out      01120000
*                                                                       01130000
         MVC   ALELM_RQ_ENV,0(R6)          Move Environment             01140000
         MVC   ALELM_RQ_SYSTEM(8),08(R6)   Move SYSTEM                  01150000
         MVC   ALELM_RQ_SUBSYS(8),16(R6)   Move SUBSYS                  01160000
         MVC   ALELM_RQ_TYPE(8),24(R6)     Move TYPE                    01170000
         MVC   ALELM_RQ_ELM(10),32(R6)     Move Element                 01180000
         MVC   ALELM_RQ_STG_ID(1),42(R6)   Move STG_ID                  01190000
*                                                                       01200000
************************************************************            01210000
*        BUILD PARMLIST                                                 01220000
************************************************************            01230000
         LA    R1,WPARMLST                                              01240000
         LA    R14,AACTL                                                01250000
         ST    R14,0(0,R1)                                              01260000
         LA    R14,ALELM_RQ                                             01270000
         ST    R14,4(0,R1)                                              01280000
         LA    R14,ALELM_RS                                             01290000
         ST    R14,8(0,R1)                                              01300000
         OI    8(R1),X'80'                                              01310000
************************************************************            01320000
*                                                                       01330000
*        CALL THE ENDEVOR API INTERFACE PROGRAM                         01340000
************************************************************            01350000
XCALLAPI DS    0H                                                       01360000
         L     R15,=V(ENA$NDVR)                                         01370000
         BALR  R14,R15                                                  01380000
         LR    R2,R15                    HOLD ONTO THE RETURN CODE      01390000
         LR    R3,R0                     HOLD ONTO THE REASON CODE      01400000
************************************************************            01410000
* SHUTDOWN THE API SERVER. ONLY THE AACTL BLOCK IS REQUIRED.            01420000
************************************************************            01430000
XSHUTDWN DS    0H                                                       01440000
         API$INIT STG=AACTL,BLOCK=AACTL                                 01450000
         MVI   AACTL_SHUTDOWN,C'Y'                                      01460000
         LA    R1,WPARMLST                                              01470000
         LA    R14,AACTL                                                01480000
         ST    R14,0(0,R1)                                              01490000
         OI    0(R1),X'80'                                              01500000
         L     R15,=V(ENA$NDVR)                                         01510000
         BALR  R14,R15                                                  01520000
*********************************************************************** 01530000
* PROGRAM EXIT                                                          01540000
*********************************************************************** 01550000
         LR    R5,R13                  SAVE SAVEAREA ADDRESS            01560000
         L     R13,4(R13)              POINT TO PREVIOUS SAVEAREA       01570000
*   CLEAN UP THIS PROGRAM'S STORAGE                                     01580000
         L     R0,=A(WORKLN)                GET SIZE                    01590000
         FREEMAIN R,A=(R5),LV=(R0)          FREE STORAGE                01600000
         LR    R15,R2                       SET RETURN CODE             01610000
         L     R14,12(R13)                                              01620000
         LM    R0,R12,20(R13)                                           01630000
         BSM   0,R14                        RETURN                      01640000
         END                                                            01650000
