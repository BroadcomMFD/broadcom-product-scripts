         TITLE 'WTO#MSG - TO issue a WTO message'
         PRINT ON,GEN,NODATA
***********************************************************************
* SEND WTO MESSAGE                                                    *
*   (get the message from input Parameter value)                      *
*                                                                     *
* Assemble with the 'NORENT' option                                   *
* Link     with the 'NORENT,NOREUSE' options                          *
*                                                                     *
* Example uses:                                                       *
*                                                                     *
*   JCL:                                                              *
*     //WTO   EXEC PGM=WTO#MSG,                                       *
*     //      PARM='Hello, here is a message.....'                    *
*     //STEPLIB  DD DISP=SHR,DSN=your.loadlib                         *
*                                                                     *
*   REXX:                                                             *
*     parm='Hello, here is a message.....'                            *
*     Address LINKMVS "WTO#MSG parm"                                  *
*                                                                     *
*   COBOL:                                                            *
*          01  WS-MESSAGE.                                            *
*              03 FILLER PIC S9(04)  COMP VALUE 60 .                  *
*              03 FILLER PIC X(60)                                    *
*                 VALUE Hello, here is a message.....' .              *
*          .  .  .  .  .  .                                           *
*              CALL 'WTO#MSG' USING WS-MESSAGE.                       *
***********************************************************************
*
         EJECT
*
* REGISTER ASSIGNMENTS
*
R0       EQU   0
R1       EQU   1                       ADDRESS OF SEARCH CHARACTER
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6                       POINTS TO INPUT RECORD AREA
R7       EQU   7                       CHAR COUNT FOR SCANNED INPUT
R8       EQU   8                       CONTAINS SEARCH CHAR
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         EJECT
WTO#MSG CSECT
WTO#MSG  AMODE  31
WTO#MSG  RMODE  ANY
         USING  *,R12
***********************************************************************
*                    INITIALIZATION                                   *
***********************************************************************
*
ENTRY    DS    0H
         STM   R14,R12,12(R13)         SAVE REGISTERS ....
         LR    R12,R15                 R12 FOR PROGRAM ADDRESSABILITY
         ST    R13,SAVE+4
         LA    R13,SAVE                NOW POINTS TO MY SAVE AREA
*
         L     R3,0(R1)             POINT R3 TO PARM DATA
         LH    R4,0(R3)             PARM LENGTH
         LA    R3,2(R3)             ADVANCE TO PARM TEXT
*
         LA    R15,0                   ZERO RETURN CODE
         ST    R15,RETURN
*
         MVC   SWTO+17(65),0(R3)       Insert message from Parm
*
SWTO     WTO  'Endevor-                                                X
                                                           ',          X
               ROUTCDE=(11)
*
*
THATSALL L     R13,SAVE+4
         L     R15,RETURN
         RETURN (14,12),RC=(15)
*
SAVE     DS    18F
RETURN   DS    4F
*
         LTORG
         END
