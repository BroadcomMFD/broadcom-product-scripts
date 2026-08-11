WTO#MSG  CSECT
***********************************************************************
* SEND WTO MESSAGE                                                    *
*   (get the message from input Parameter)                            *
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
WTO#MSG  AMODE 31
WTO#MSG  RMODE ANY
*---------------------------------------------------------------------*
* Standard Register Equates
*---------------------------------------------------------------------*
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
R16      EQU   16
*---------------------------------------------------------------------*
* Standard OS Linkage & Save Area
*---------------------------------------------------------------------*
         SAVE  (14,12),,'WTO#MSG V1.0'
         LR    R12,R15             Set up base register
         USING WTO#MSG,R12
         ST    R13,SAVEAREA+4      Link save areas
         LA    R11,SAVEAREA
         ST    R11,8(,R13)
         LR    R13,R11
*---------------------------------------------------------------------*
* Process Input Parameter
* R1 points to the parameter list (for standard CALLs)
*---------------------------------------------------------------------*
         LR    R2,R1               Save R1 (Parm pointer)
         LTR   R2,R2               Check if parm pointer is null
         BZ    ERROR               Error if no parm passed
         L     R3,0(,R2)           R3 -> Address of string (fullword)
         LTR   R3,R3               Verify address isn't null
         BZ    ERROR
*---------------------------------------------------------------------*
* Get Length from Parameter (Standard COBOL/REXX passes a halfword
* length prefix, but JCL PARM does the same. For generic CALLs,
* checking the boundary or simply hardcoding a safe maximum works).
*---------------------------------------------------------------------*
         LH    R4,0(,R3)           Load the halfword length prefix
         CH    R4,=H'0'            Is length zero?
         BE    ERROR
         CH    R4,=H'125'          WTO text limit is 125 chars
         BNH   LENGTH_OK           Use actual length if <= 125
         LA    R4,125              Truncate to max 125 characters
LENGTH_OK EQU  *
         STH   R4,MSG_LEN          Store in the WTO message length
         BCTR  R4,0                Subtract 1 for Execute Form of MVC
         EX    R4,MOVE_MSG         Move input parm to WTO text area
         B     ISSUE_WTO
MOVE_MSG MVC   MSG_TEXT(0),2(R3)   (Executed Instruction to move text)
*---------------------------------------------------------------------*
* Issue the WTO
*---------------------------------------------------------------------*
ISSUE_WTO EQU *
         WTO   TEXT=MSG_AREA,MF=(E,WTO_LIST)
         LA    R15,0               Set Return Code 0
         B     EXIT
ERROR    EQU   *
         LA    R15,12              Set Return Code 12 (Error)
EXIT     EQU   *
         L     R13,SAVEAREA+4      Restore register R13
         RETURN (14,12),RC=(15)    Return to caller
*---------------------------------------------------------------------*
* Constants and Data Areas
*---------------------------------------------------------------------*
SAVEAREA DS    18F
WTO_LIST WTO   TEXT=MSG_AREA,MF=L
MSG_AREA DS    0H
MSG_LEN  DS    H                   Halfword length required by WTO
MSG_TEXT DS    CL125               Buffer for the text
         END   WTO#MSG
