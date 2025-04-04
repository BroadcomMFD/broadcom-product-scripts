LOADTABL CSECT
*  THESE ROUTINES ARE DISTRIBUTED BY THE BROADCOM STAFF
*  "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE
*  FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES
*  ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE
*  CORRECTED.
*
***********************************************************************
*        SEE IBM TSO EXTENSIONS FOR MVS                               *
*                PROGRAMMING SERVICES                                 *
*                VERSION 2 RELEASE 5                                  *
*                DOCUMENT NUMBER SC28-1875-08                         *
*                24.8 EXAMPLES USING IKJCT441                         *
***********************************************************************
CVTPTR   EQU   16
CVTTVT   EQU   X'9C'
R15      EQU   15
R14      EQU   14
R13      EQU   13
R12      EQU   12
R11      EQU   11
R07      EQU   7
R01      EQU   1
R00      EQU   0
         IKJTSVT
LOADTABL CSECT
         STM   R14,R12,12(R13)   SAVE CALLER'S REGISTERS
         BALR  R12,0             ESTABLISH ADDRESSABILITY
         USING *,R12             BASE REGISTER OF EXECUTING PROGRAM
         ST    R13,SAVEAREA+4    CALLER'S SAVEAREA ADDRESS
         LA    R15,SAVEAREA      EXECUTING PROGRAM'S SAVEAREA ADDRESS
         ST    R15,8(,R13)       EXECUTING PROGRAM'S SAVEAREA ADDRESS
         LA    R13,SAVEAREA      EXECUTING PROGRAM'S SAVEAREA ADDRESS
*
*----------------------------------------------------------------------
*-       LOAD THE TABLE NAMED IN PARM STRING
*----------------------------------------------------------------------
*
         L     R07,0(R01)              GET TABLENAME IN PARAMETER S
         MVC   TABLELEN(10),0(R07)     SAVE TABLE LEN AND NAME
*                                      LENGTH (0 => NOT CALLED BY REXX)
*
*        MVC   SWTO+19(08),=C'LOADING '
*        MVC   SWTO+27(10),0(R07)            *DAN*
*        BAL   R14,SWTO                      *DAN*
*
*        WTO   'LOADTABL - CALLING LOAD                             ',*
*              ROUTCDE=(11)
*
         LOAD  EPLOC=TABLENAM
         LTR   R15,R15         VERIFY LOAD WAS SUCCESSFUL
         BZ    CONTINU1
         ST    R15,VALUE            SAVE ADDRESS INTO REXX VAR VALUE
*
*        WTO   'LOADTABL - CALLED  LOAD. RESULT FAILED.             ',*
*              ROUTCDE=(11)
         B     CONTINU2
*
SWTO     WTO  'SHOWME -                                             ', *
               ROUTCDE=(11)
         MVC   SWTO+19(40),SPACES     *DAN*
         BR    R14
*
*
CONTINU1 DS    0H                  CONTINUE
         ST    R00,VALUE           SAVE ADDRESS INTO REXX VAR VALUE
*        WTO   'LOADTABL - CALLED  LOAD. RESULT OK.                 ',*
*              ROUTCDE=(11)
*
         LA    R07,0
         LH    R07,TABLELEN
         C     R07,=X'0000'
         BE    NOTREXX            NOT CALLED BY REXX, JUST RETURN
*
*        WTO   'LOADTABL - CALLED FROM REXX                         ',*
*              ROUTCDE=(11)
*
CONTINU2 L     R15,CVTPTR              ACCESS THE CVT
         L     R15,CVTTVT(,R15)        ACCESS THE TSVT
         L     R15,TSVTVACC-TSVT(,R15) ACCESS THE VARIABLE ACCESS RTN

*        INVOKE THE VARIABLE ACCESS SERVICE
*
         LTR   R15,R15         VERIFY TSVT ADDRESS PRESENT
         BNZ   CALL441         IF PRESENT, CALL IKJCT441

LINK441  LINK  EP=IKJCT441,                                            *
               PARAM=(ECODE,   ENTRY CODE                              *
               NAMEPTR,        POINTER TO VARIABLE NAME                *
               NAMELEN,        LENGTH OF VARIABLE NAME                 *
               VALUEPTR,       POINTER TO VARIABLE VALUE               *
               VALUELEN,       LENGTH OF VARIABLE VALUE                *
               TOKEN),         TOKEN TO VARIABLE ACCESS SERVICE        *
               VL=1            CAUSES HI BIT ON IN THE PARM LIST
         B     RET441
CALL441  CALL  (15),                                                   *
               (ECODE,         ENTRY CODE                              *
               NAMEPTR,        POINTER TO VARIABLE NAME                *
               NAMELEN,        LENGTH OF VARIABLE NAME                 *
               VALUEPTR,       POINTER TO VARIABLE VALUE               *
               VALUELEN,       LENGTH OF VARIABLE VALUE                *
               TOKEN),         TOKEN TO VARIABLE ACCESS SERVICE        *
               VL              CAUSES HI BIT ON IN THE PARM LIST
*
RET441   LTR   R15,R15         CHECK RETURN CODE
         BNZ   NOTREXX
         L    R13,4(,R13)      CALLER'S SAVEAREA
         L    R14,12(,R13)     RESTORE REGISTER 14
         LM   R00,R12,20(R13)  RESTORE REMAINING REGISTERS
         BR   R14              RETURN TO CALLER, REGISTER 15 CONTAINS
*                              THE RETURN CODE FROM IKJCT441
NOTREXX  DS    0H
*
*        WTO   'LOADTABL - CALLED FROM OTHER THAN REXX              ',*
*              ROUTCDE=(11)
*
         L    R13,4(,R13)      CALLER'S SAVEAREA
         L    R14,12(,R13)     RESTORE REGISTER 14
         LM   R00,R12,20(R13)  RESTORE REMAINING REGISTERS
         L    R15,VALUE        PROVIDE LOADED ADDRESS IN RETURNCODE
         BR   R14              RETURN TO CALLER, REGISTER 15 CONTAINS
*                              THE RETURN CODE FROM IKJCT441
*
SPACES   DC    C'                                        '
TABLELEN DC    CL02'  '            LENGTH (0 => NOT CALLED BY REXX)
TABLENAM DC    CL08'        '      NAME OF THE TABLE TO BE LOADED
*                   1234567890
NAME     DC    CL07'TBLADDR'       NAME OF THE REXX VARIABLE
NAMELEN  DC    F'07'               LENGTH OF THE VARIABLE NAME
VALUE    DC    F'0'                VARIABLE VALUE
VALUELEN DC    F'4'                LENGTH OF THE VARIABLE VALUE
NAMEPTR  DC    A(NAME)             POINTER TO THE VARIABLE NAME
VALUEPTR DC    A(VALUE)            POINTER TO THE VARIABLE VALUE
TOKEN    DC    F'0'                TOKEN (UNUSED HERE)
ECODE    DC    A(TSVEUPDT)         ENTRY CODE FOR SETTING VALUES
SAVEAREA DS    18F
         END
