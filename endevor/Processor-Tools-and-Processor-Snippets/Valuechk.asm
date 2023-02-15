         PRINT NOGEN
*  THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF
*  "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE
*  FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES
*  ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE
*  CORRECTED.
*
*  /* WRITTEN BY DAN WALTHER */
VALUECHK CSECT
         SAVE  (14,12),,*
         LR    R2,R15              SET UP BASE REG.
         USING VALUECHK,R2
         ST    R13,SAVE+4          SAVE CALLER'S SAVEAREA ADDR
         LA    R11,SAVE
         ST    R11,8(,R13)         OUR SAVEAREA ADDR
         LR    R13,R11             SET UP SAVEAREA POINTER
*
         L     R3,0(R1)             POINT R3 TO PARM DATA
         LH    R4,0(R3)             PARM LENGTH
         LA    R3,2(R3)             ADVANCE TO PARM TEXT
*
         OPEN  (OPTIONS)
*
         MVI   SEARCHAR,X'00'       CONSIDER nulls as a blank
         BAL   R14,FINDBLNK         FIND BLANK
         LTR   R15,R15              Finding what we expect?
         BNZ   MAINRETN             No, go away
         BCTR  R7,0                 Subtract 1 from len
         ST    R7,PRMPRGRL          Save OPTION keywork len for pgm
         EX    R7,SAVEKEYW          MOVE PARM    KEYWORD
*
         LR    R3,R5                Point to next field
         LR    R4,R6                Set length to remaining len
         BAL   R14,FINDNONB         FIND NON-BLANK
         LTR   R15,R15              Finding what we expect?
         BNZ   MAINRETN             No, go away
*
         LR    R3,R5                Point to next field
         LR    R4,R6                Set length to remaining len
*
         BCTR  R6,0                 Subtract 1 from len
         ST    R6,CHKVALGN          Save OPTION value   len
         EX    R6,PARMVALU
*
         LA    R15,0
         ST    R15,RETURNCD
*
LOOP     DS    0H
         GET   OPTIONS,OPTNREC
*
         CLI   OPTNREC,C'*'         Commented line ?
         BE    LOOP                 ...YES, SKIP THIS ONE
*
         LA    R3,OPTNREC           Point to start of record
         LA    R4,80                Set length
         MVI   SEARCHAR,C' '        Search Blanks only
         BAL   R14,FINDNONB         FIND NON-BLANK
*
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
*
         LR    R3,R5                Point to next field
         LR    R4,R6                Set length to remaining len
         CLI   0(R3),C'"'           Double quote char?
         BE    LOOP
         CLI   0(R3),X'7D'          Single quote char?
         BE    LOOP
*
         MVI   SEARCHAR,C'='        Consider = as a blank
         BAL   R14,FINDBLNK         FIND BLANK or =
*
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
*
         BCTR  R7,0                 Subtract 1 from len
         C     R7,=F'30'            Len > 30 ?
         BH    LOOP                 ...Y - go to next
*
         MVI   KEYWORD,C' '            Clear area
         MVC   KEYWORD+1(29),KEYWORD
         EX    R7,SAVKEYWD             move found keyword
*
*        MVI   SWTO+19,C'R'           *DAN*
*        ST    R7,SWTO+20             *DAN*
*        MVC   SWTO+24(35),0(R3)      *DAN*
*        BAL   R14,SWTO               *DAN*
*
         CLC   KEYWORD(30),PRM#WORD   Found keyword from parm ?
         BE    FOUNDWRD
*
         B     LOOP                    GO GET MORE
*
FOUNDWRD DS    0H                   Found Search keyword
*
         MVI   OPTVALUE,C' '        Clear PARMS
         MVC   OPTVALUE+1(99),OPTVALUE "
         LA    R8,0
         STH   R8,PARMLEN
         LA    R8,OPTVALUE
*
         MVI   SEARCHAR,C'='
         BAL   R14,FINDCHAR         FIND =
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
         LR    R3,R5                Update pointer
         LR    R4,R6                Update remaining len
         MVI   0(R3),C' '           Temporarily space out =
*
         BAL   R14,FINDNONB         FIND NON BLANK
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
         LR    R3,R5                Update pointer
         LR    R4,R6                Update Length
*
TSTQUOTE DS    0H                  Is there a quote char ?
         MVC   SEARCHAR(1),0(R3)   Save quote char (if one)
         CLI   SEARCHAR,C'"'       Double quote char?
         BE    PRQUOTED
         CLI   SEARCHAR,X'7D'      Single quote char?
         BE    PRQUOTED
*
         MVI   SEARCHAR,C' '        Search blanks only
         BAL   R14,FINDBLNK         FIND BLANK to get length
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
*
         BAL   R12,PARMPART         Save found portion of Parms
*
PRMLASTC DS    0H                   Find and examine last non-blk char
*
         LA    R3,OPTNREC           Point to start of record
         LA    R3,79(R3)            Point to end   of record
         LA    R4,80                Set length
         BAL   R14,FINDLAST         FIND last NON-BLANK char
*
         CLI   0(R5),C','           Find Comma ?
         BE    CONTINUE
         CLI   0(R5),C'-'           Find dash  ?
         BE    CONTINUE
         CLI   0(R5),C'+'           Find plus  ?
         BNE   LOOP                    GO GET MORE
*
CONTINUE DS    0H                   We have a continuation ....
         GET   OPTIONS,OPTNREC
         MVI   SEARCHAR,C' '        Search Blanks only
         LA    R3,OPTNREC           Point to start of record
         LA    R4,80                Set length
         BAL   R14,FINDNONB         FIND NON BLANK
*
         LR    R3,R5                Point to next field
         LR    R4,R6                Set length to remaining len
*
*        MVI   SWTO+19,C'='           *DAN*
*        MVC   SWTO+20(30),0(R5)      *DAN*
*        BAL   R14,SWTO               *DAN*
*
         B     TSTQUOTE             Test for quoted string
*
PARMPART DS    0H                   Found a portion of parms
         LR    R9,R7                Save incremental value
         AH    R7,PARMLEN           Add length already there
*
         STH   R7,PARMLEN           Save PARM len
         C     R7,=F'100'           Exceeded a len of 100 ?
         BH    ERROR100             Got an error.
         EX    R9,MOVEOPTN          Move OPTION value portion
*
         AR    R8,R9                Increment pointer to parms
*
*        MVC   SWTO+19(06),=C'PARMS:' *DAN*
*        MVC   SWTO+25(34),PARMLEN    *DAN*
*        BAL   R14,SWTO               *DAN*
*
         BR    R12                  Return
*
PRQUOTED DS    0H                      Found Parms  quoted
*
         LA    R3,1(R3)             Increment pointer
         BCTR  R4,0                 Subtract 1 from len
*
         BAL   R14,FINDCHAR         FIND quote char again
         LTR   R15,R15              Finding what we expect?
         BNZ   LOOP                 No, go read another
*
         BAL   R12,PARMPART         Save found portion of Parms
*
         B     PRMLASTC                Go check for continuation
*
*-------- -------------------------------------------------------------
*
SWTO     WTO   'VALUECHK -                                         ',  *
               ROUTCDE=(11)
         MVI   SWTO+19,C' '           *DAN*
         MVC   SWTO+20(40),SWTO+19    *DAN*
         BR    R14
*
*-------- -------------------------------------------------------------
*
MAINRETN DS    0H                 END OF FILE
         CLOSE (OPTIONS)               CLOSE FILE
         MVC   RETURNCD,=F'0'
*
         LA    R6,OPTVALUE
         LA    R8,CHKVALUE
         LH    R7,PARMLEN
         C     R7,=F'0'
         BE    LITESOUT
         LH    R9,PARMLEN
         CLCL  R6,R8
         BNE   LITESOUT           We have a match, RC= 01
         MVC   RETURNCD,=F'1'
*
*
LITESOUT DS    0H                 END OF EVERYTHING
         L     R13,SAVE+4          OLD SAVEAREA
         L     R15,RETURNCD
         RETURN (14,12),RC=(15)    RESTORE REGS AND RETURN
*
ERROR100 DS    0H
         ABEND 99,DUMP
         LA    R15,8
         ST    R15,RETURNCD
         B     MAINRETN
*
SAVEKEYW MVC   PRM#WORD(0),0(R3)
PARMVALU MVC   CHKVALUE(0),0(R3)
SAVKEYWD MVC   KEYWORD(0),0(R3)
MOVEOPTN MVC   0(0,R8),0(R3)
COMPARE  CLC   OPTVALUE,CHKVALUE
*
FINDBLNK DS    0H                   Find next blank from R3
         LR    R5,R3                Start R5 at 1st char
         LR    R6,R4                Use R6 as decrementing len value
         LA    R7,0                 Initialize counter in R7
         LA    R15,0                Set default return code
FINDBLN1 DS    0H
         CLI   0(R5),C' '           FOUND BLANK ?
         BE    FINDBLN2
         CLC   0(1,R5),SEARCHAR     FOUND CHAR  ?
         BE    FINDBLN2
         LA    R7,1(R7)             Increment counter
         LA    R5,1(R5)             Increment pointer
         BCT   R6,FINDBLN1          Keep searching
         LA    R15,4                Set warning return code
FINDBLN2 DS    0H
         BR    R14
*
FINDNONB DS    0H                   Find next blank from R3
         LR    R5,R3                Start R5 at 1st char
         LR    R6,R4                Use R6 as decrementing len value
         LA    R7,0                 Initialize counter in R7
         LA    R15,0                Set default return code
FINDNON1 DS    0H
         CLC   0(1,R5),SEARCHAR     FOUND SEARCH CHAR  ?
         BE    FINDNONC
         CLI   0(R5),C' '           FOUND BLANK ?
         BNE   FINDNON2
FINDNONC DS    0H                   Keep Searching
         LA    R7,1(R7)             Increment counter
         LA    R5,1(R5)             Increment pointer
         BCT   R6,FINDNON1          Keep searching
         LA    R15,4                Set warning return code
FINDNON2 DS    0H
         BR    R14
*
FINDCHAR DS    0H                   Find next blank from R3
         LR    R5,R3                Start R5 at 1st char
         LR    R6,R4                Use R6 as decrementing len value
         LA    R7,0                 Initialize counter in R7
         LA    R15,0                Set default return code
FINDCHA1 DS    0H
         CLC   0(1,R5),SEARCHAR     FOUND CHAR  ?
         BE    FINDCHA2
         LA    R7,1(R7)             Increment counter
         LA    R5,1(R5)             Increment pointer
         BCT   R6,FINDCHA1          Keep searching
         LA    R15,4                Set warning return code
FINDCHA2 DS    0H
         BR    R14
*
*
FINDLAST DS    0H                   Find next blank from R3
         LR    R5,R3                Start R5 at 1st char
         LR    R6,R4                Use R6 as decrementing len value
         LA    R15,0                Set default return code
FINDLST1 DS    0H
         CLI   0(R5),C' '           FOUND SPACE ?
         BNE   FINDLST2
         BCTR  R5,0                 Subtract 1 from pointer
         BCT   R6,FINDLST1          Keep searching
         LA    R15,4                Set warning return code
FINDLST2 DS    0H
         BR    R14
*
*---------------------------------------------------------------------
*-  STORAGE AND FILE SECTION
*---------------------------------------------------------------------
*
SAVE     DS    18F                 STANDARD LINKAGE SAVE AREA
OPTIONS  DCB   DDNAME=OPTIONS,DSORG=PS,EODAD=MAINRETN,MACRF=GM,        X
               LRECL=80,RECFM=FB
*              LRECL=80,BLKSIZE=24000,RECFM=FB
*
OPTNREC  DS    CL80
         DC    CL4' '
RETURNCD DS    F                   Return code
PRMPRGRL DS    F                   Options Search name length
PRM#WORD DC    CL30' '             Options name for Search
KEYWORD  DC    CL30' '             Options name for Search
CHKVALGN DS    F                   Options parms   name length
CHKVALUE DC    CL256' '            VALUE FOR COMPARISON
PARMLEN  DS    CL2
OPTVALUE DS    CL256
SEARCHAR DS    CL1
         DS    CL40
*
R0       EQU   0
R1       EQU   1
R2       EQU   2                   BASE REGISTER
R3       EQU   3                   starting Pointer to PARM / OPTIONS
R4       EQU   4                   staring  Length
R5       EQU   5                   Working  Pointer to PARM / OPTIONS
R6       EQU   6                   Working  Length
R7       EQU   7                   Counter
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
         END
