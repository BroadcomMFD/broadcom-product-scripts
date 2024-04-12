C1UEXSHP TITLE 'ENDEVOR/MVS Package Shipping Exit'
***********************************************************************
*   DESCRIPTION: THIS PACKAGE EXIT PROGRAM WILL EXTRACT               *
*                call the rexx program PKGESHIP to support            *
*                automated package shipping submissions.              *
*                                                                     *
*   SETUP        THE SETUP ROUTINE ENABLES THIS PROGRAM               *
*                AT THE FOLLOWING EXIT POINTS:                        *
*                                                                     *
*       =====>   1. POST Execute                                      *
*                2. POST Backout                                      *
*                2. POST Backin                                       *
*                                                                     *
*                                                                     *
*   REGISTERS ON ENTRY:                                               *
*                                                                     *
*                0(R1) --> $PECBDS     EXIT CONTROL BLOCK             *
*                4(R1) --> $PREQPDS    EXIT REQUEST BLOCK             *
*                8(R1) --> $PHDRDS     EXIT HEADER BLOCK              *
*               12(R1) --> $PFILDS     EXIT FILE BLOCK                *
*               16(R1) --> $PACTREQ    EXIT ACT SUMMARY REQUEST       *
*               24(R1) --> $PBODREQ    EXIT BACKOUT REQUEST           *
*                                                                     *
*   REGISTER USAGE:                                                   *
*                                                                     *
*                R6     -> $PECBDS                                    *
*                R7     -> $PREQPDS                                   *
*                R8     -> WORKAREA                                   *
*                R9     -> $PHDRDS                                    *
*                R12    -> BASE PROGRAM                               *
*                R13    -> STACK USED FOR STANDARD IBM USAGE          *
*                                                                     *
*                                                                     *
***********************************************************************
*   PACKAGE EXIT CONTROL BLOCK                                        *
***********************************************************************
         $PECBDS
***********************************************************************
*   PACKAGE EXIT REQUEST BLOCK                                        *
***********************************************************************
         $PREQPDS
***********************************************************************
*   PACKAGE EXIT HEADER  BLOCK                                        *
***********************************************************************
         $PHDRDS
***********************************************************************
*   REGISTER EQUATES                                                  *
***********************************************************************
*
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
*
***********************************************************************
*   THIS PROGRAM'S WORKAREA MAP                                       *
***********************************************************************
WORKAREA DSECT
*
SAVEAREA DS    18F                     primary function's save-area
*
DYNPARMS DS    6F                                                       01110000
*
REXXPRMS DS    0H         Parameters passed to the REXX PKGESHIP
REX#LEN  DS    H              Parms Length
REX#PGM  DS    CL08        Name of Rexx program called
REX#SP1  DS    CL1            space
REX#PKG  DS    CL16           Package id
REX#SP2  DS    CL1            space
REX#ENV  DS    CL08           Promotion Environment
REX#SP3  DS    CL1            space
REX#STG  DS    CL1            Promotion Stgid
REX#SP4  DS    CL1            space
*EX#COMM DS    CL50           Package Comment
REX#CRUS DS    CL08           Package create userid
REX#UPUS DS    CL08           Package update userid
REX#CAUR DS    CL08           Package Cast   userid
REX#SP5  DS    CL1            space
REX#NOT1 DS    CL60           Package Notes line #1
REX#NOT2 DS    CL60           Package Notes line #2
REX#NOT3 DS    CL60           Package Notes line #3
REX#NOT4 DS    CL60           Package Notes line #4
REX#NOT5 DS    CL60           Package Notes line #5
REX#NOT6 DS    CL60           Package Notes line #6
REX#NOT7 DS    CL60           Package Notes line #7
REX#NOT8 DS    CL60           Package Notes line #8
REX#OUT  DS    CL03           Package shipment output option
REXPRLN  EQU   *-REXXPRMS
*
         DS    CL10
*
WORKLN   EQU   *-WORKAREA
         TITLE 'C1UEXSHP: Automated Shipments'
***********************************************************************
*   MAINLINE LOGIC                                                    *
***********************************************************************
C1UEXSHP CSECT
C1UEXSHP AMODE 31
C1UEXSHP RMODE ANY
         SAVE  (14,12),,'PKG Shipment Exit'  SAVE CALLERS REG 12(13)
         LR    R12,R15                      POINT TO THIS PROGRAM
         USING C1UEXSHP,R12
         L     R6,0(,R1)                    POINT TO THE $PECBDS
         USING $PECBDS,R6
         L     R7,4(,R1)                    POINT TO THE $PREQPDS
         USING $PREQPDS,R7
         L     R9,8(,R1)                    POINT TO THE $PHDRDS
         USING $PHDRDS,R9
***********************************************************************
*   GET STORAGE FOR SAVEAREA                                          *
***********************************************************************
         L     R0,=A(WORKLN)                GET SIZE OF W.A
         GETMAIN R,LV=(0),LOC=BELOW         GET WORKING STORAGE
         LR    R2,R1                        SAVE REG 1
         LR    R14,R2                       ADDR OF OUR LOCAL WORKAREA
         ICM   R15,B'1111',=A(WORKLN)       IT'S SIZE
         SLR   R1,R1
         MVCL  R14,R0                       INITIALIZE IT
*
         ST    R2,8(R13)                    STORE NEW STACK +8(OLD)
         ST    R13,4(R2)                    STORE OLD STACK +4(NEW)
         LR    R13,R2                       POINT R13 TO OUR STACK
         LR    R8,R2
         USING  WORKAREA,R8
***********************************************************************
*        CHECK FOR SETUP CALL                                        *
***********************************************************************
         CLC    PECBFNNM,=CL8'SETUP'        ARE WE AT SETUP
         BNE    MAIN0010                    NO GO CHECK FOR FUNCTION
**********************************************************************
*        ENABLE THE EXIT POINTS FOR THIS PROGRAM                     *
*                                                                    *
*                                                                    *
*  THE FOLLOWING FIELDS ARE USED EXCLUSIVELY DURING SETUP PROCESSING.*
*  THE USER EXIT SHOULD MODIFY THESE FIELDS TO ENABLE EXIT POINTS.   *
*  THIS SETUP IS DONE ONCE PER ENDEVOR SESSION.                      *
*  THE DEFAULT IS 'N'. TO ENABLE SET FIELD TO 'Y'.                   *
*                                                                    *
**********************************************************************
*
SETUP    DS    0H
         MVI   PECBEXBE,C'Y'                ENABLE AFTER  Execute
         MVI   PECBBOBE,C'Y'                ENABLE AFTER Backout
         MVI   PECBBIBE,C'Y'                ENABLE AFTER Backin
*
         MVI   PECBCAMD,C'Y'               MID    CAST
         MVI   PECBCAAF,C'Y'               AFTER  CAST
         MVI   PECBCABE,C'Y'               Before CAST
*
*      Before Package create
         MVI   PECBCBBE,C'Y'               Before create/build
         MVI   PECBCCBE,C'Y'               Before create/copy
         MVI   PECBCEBE,C'Y'               Before create/edit
         MVI   PECBCIBE,C'Y'               Before create/import
*
*      Package modify actions
         MVI   PECBMBBE,C'Y'               MODIFY / BUILD EXIT
         MVI   PECBMCBE,C'Y'               MODIFY / COPY EXIT
         MVI   PECBMEBE,C'Y'               MODIFY / EDIT EXIT
         MVI   PECBMIBE,C'Y'               MODIFY / IMPORT EXIT
         MVI   PECBMBAF,C'Y'               MODIFY / BUILD EXIT
         MVI   PECBMCAF,C'Y'               MODIFY / COPY EXIT
         MVI   PECBMEAF,C'Y'               MODIFY / EDIT EXIT
         MVI   PECBMIAF,C'Y'               MODIFY / IMPORT EXIT
*
         MVI   PECBEABX,C'Y'               Include elm backout/backin
         MVI   PECBUECB,C'Y'               Include elm backout/backin
*
         WTO   'C1UEXSHP  - ASM - in Setup               '
*
         B     MAIN9000                     RETURN TO ENDEVOR
***********************************************************************
*   CHECK FUNCTION                                                            *
***********************************************************************
MAIN0010 DS    0H
*
         CLC   PECBFNNM,=CL8'EXECUTE'       'Execute' ?
         BE    MAIN0020
         CLC   PECBFNNM,=CL8'BACKOUT'       'Back out ?'
         BE    MAIN0020
         CLC   PECBFNNM,=CL8'BACKIN'        'Back In  ?'
         BE    MAIN0020
*
*
***********************************************************************
*   Enforce the Enable Backout option                                         *
***********************************************************************
MAIN0015 DS    0H
         CLI   PREQBOEN,C'Y'                Package Backout enabled?
         BE    MAINEXIT                     RETURN TO ENDEVOR
*
         WTO   'C1UEXSHP - Package Backout enabled.      ',            X
               ROUTCDE=11
*
         MVI   PREQBOEN,C'Y'                ENABLE Package Backout
         MVI   PECBUREQ,C'Y'                MODS MADE TO PREQPDS
         MVC   PECBRTCD,=A(PECB$MOK)        RETURN CODE to upd Endevor
         MVC   PECBNDRC,=A(PECB$MOK)        RETURN CODE to upd Endevor
         B     MAINEXIT                     RETURN TO ENDEVOR
***********************************************************************
*   HAVE WE ALREADY  BEEN HERE?                                       *
***********************************************************************
MAIN0020 DS    0H
         LH    R15,PECBRQRC                 LOAD RETURN CODE FROM NDVR
         CLC   PECBMODE,=CL1'B'             Running Batch or Tso ?
         BNE   MAIN0021                     Bypass SYSEXEC allocation
***********************************************************************
*   Allocate a SYSEXEC library - replace if one is already there      *
***********************************************************************
         LA    R1,ALLOREXX              Allocate a SYSEXEC file
         ST    R1,DYNPARMS                 "
         OI    DYNPARMS,X'80'              "
         LA    R1,DYNPARMS                 "
         LINK  EP=BPXWDYN                  "
         LTR   R15,R15         Verify allocate was successful
         BZ    MAIN0021
*
         WTO   'C1UEXSHP  Unable to allocate SYSEXEC     ',            X
               ROUTCDE=11
*
         B     MAIN9000                     RETURN TO ENDEVOR
***********************************************************************
*   Call PKGESHIP to do the rest of the work...                       *
*        Build parms                                                  *
***********************************************************************
*
MAIN0021 DS    0H
         LA    R1,REXPRLN              Save Rexx Parm length
         STH   R1,REX#LEN                "
         MVC   REX#PGM,=CL08'PKGESHIP'
         MVI   REX#SP1,C' '                enter space
         MVC   REX#PKG,PECBPKID        SAVE PACKAGE ID
         MVI   REX#SP2,C' '                enter space
         MVC   REX#ENV,PHDRENV         Promtion Env
         MVI   REX#SP3,C' '                enter space
         MVC   REX#STG,PHDRSTGID       Promtion Stgid
         MVI   REX#SP4,C' '                enter space
*        MVC   REX#COMM,PREQCOMM       Package Description/Comment
         MVC   REX#CRUS,PHDRCRUS             CREATE USERID
         MVC   REX#UPUS,PHDRUPUS             UPDATE USERID
         MVC   REX#CAUR,PHDRCAUS             CAST USERID
         MVI   REX#SP5,C' '                enter space
         MVC   REX#NOT1,PHDRNOTE1       Package Note line
         MVC   REX#NOT2,PHDRNOTE2       Package Note line
         MVC   REX#NOT3,PHDRNOTE3       Package Note line
         MVC   REX#NOT4,PHDRNOTE4       Package Note line
         MVC   REX#NOT5,PHDRNOTE5       Package Note line
         MVC   REX#NOT6,PHDRNOTE6       Package Note line
         MVC   REX#NOT7,PHDRNOTE7       Package Note line
         MVC   REX#NOT8,PHDRNOTE8       Package Note line
*
         MVC   REX#OUT,=CL03'OUT'
         CLC   PECBFNNM,=CL8'BACKOUT'       'Back out ?'
         BNE   MAIN0022
*
         MVC   REX#OUT,=CL03'BAC'
*
MAIN0022 DS    0H
*
         WTO   'C1UEXSHP  Calling REXX PKGESHIP          ',            X
               ROUTCDE=11
*
         LA    R1,REXXPRMS     Point to parms, and call Rexx PKGESHIP
         ST    R1,DYNPARMS                 "
         OI    DYNPARMS,X'80'              "
         LA    R1,DYNPARMS                 "
         LINK  EP=IRXJCL               PARAM=(REXXPRMS)
         LTR   R15,R15         VERIFY LOAD WAS SUCCESSFUL
         BZ    MAIN9000
*
         WTO   'C1UEXSHP  Unsuccessful PKGESHIP execution',            X
               ROUTCDE=11
*
         B     MAINEXIT
*---------------------------------------------------------------------- 00159000
*---------------------------------------------------------------------- 00159000
MAIN9000 DS    0H
         XC    PECBRTCD,PECBRTCD            CLEAR RETURN CODE
MAINEXIT DS    0H
*
         LR    R5,R13                        SAVE NEW STACK POINTER
*
         L     R13,4(R13)                    POINT TO OLD STACK
***********************************************************************
*   CLEAN UP THIS PROGRAM'S STORAGE                                   *
*   NOTE: THIS HAS TO BE DONE BEFORE THE "LOAD MULTIPLE" IS           *
*   DONE BECAUSE YOU LOSE THE POINTER TO YOUR STORAGE                 *
***********************************************************************
*
         L     R0,=A(WORKLN)                GET SIZE
         FREEMAIN R,A=(5),LV=(0)            FREE STORAGE
MAINRTRN DS    0H
         RETURN (14,12)
         SPACE ,
*
***********************************************************************
*   PROGRAM CONSTANTS                                                 *
***********************************************************************
*---------------                                                        01150000
*        CONSTANTS                                                      01100000
*---------------                                                        01150000
ALLOREXX DC    X'0060'     length in hex
         DC    CL18'ALLOC DD(SYSEXEC) '
*  Enter your REXX dataset name and length here \
*        DC    CL28'DA(CADEMO.BUNDLE.PACKAGE)'
         DC    CL30'DA(SYSMD32.NDVR.TEAM.REXX)'
*        DC    CL28'DA(SYS1.EXEC)'
*  Enter your REXX dataset name and length here /
         DC    CL42' SHR REUSE'
*        DC    CL40'----+----1----+----2----+----3----+----4
BLANKS   DC    CL132' '
         END
