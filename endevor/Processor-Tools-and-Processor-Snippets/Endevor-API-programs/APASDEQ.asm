AFASDEQ  CSECT
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3                        RNAME LENGTH
R4       EQU   4                        LOOP COUNTER
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12                       PROGRAM BASE
R13      EQU   13
R14      EQU   14
R15      EQU   15                       RETURN CODES
         SPACE 5
         USING *,R12
         STM   R14,R12,12(R13)
         LA    R12,0(R15)
         LA    R15,SAVE
         ST    R15,8(R13)
         ST    R13,4(R15)
         LR    R13,R15
         XC    RCODE,RCODE          POSIT GOOD RETURN
   SPACE 2
         L     R2,0(R1)             POINT R2 TO PARM DATA
         LH    R3,0(R2)             PARM LENGTH
         LA    R2,2(R2)             ADVANCE TO PARM TEXT
         STC   R3,RLEN              STORE RNAME LENGTH
         XC    RTEXT,RTEXT          CLEAR RNAME
         BCTR  R3,0                 DECREMENT FOR EX
         EX    R3,RMOVE             MOVE REMAINING PARM TO RNAME
*RMOVE   MVC   RTEXT(0),0(R2)       TARGET INSTRUCTION FOR EX
   SPACE
BEGIN    DS    0H
         DEQ   (QNAME,RNAME,0,SYSTEMS),RET=HAVE
         LTR   R15,R15
         BZ    RETURN
   SPACE
         LA    R15,8
         ST    R15,RCODE
*
*    RETURN
*
RETURN   EQU   *
         L     R15,RCODE
         L     R13,4(R13)
         LM    R0,R12,20(R13)
         L     R14,12(R13)
         BR    R14
   SPACE 5
*
SAVE     DC    18F'0'        SAVEAREA
RCODE    DC    F'0'
*
RMOVE    MVC   RTEXT(0),0(R2)       TARGET INSTRUCTION FOR EX
*
QNAME    DC    CL8'APTAFSQU'
*
RNAME    DS    0CL100        RNAME FIELD
RLEN     DC    X'00'         LENGTH
RTEXT    DC    XL99'00'      NAME
*
         END
