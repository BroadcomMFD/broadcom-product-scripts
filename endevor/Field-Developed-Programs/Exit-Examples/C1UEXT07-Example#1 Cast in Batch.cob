       PROCESS DYNAM OUTDD(DISPLAYS)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. C1UEXT07.
      *****************************************************************
      * DESCRIPTION: THIS PGM IS CALLED for misc Package actions.
      *              It gathers Endevor info from the exit blocks     *
      *              then calls REXX program C1UEXTR7.                *
      *   Together they can force CAST actions to be in Batch.        *
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      **
       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       COPY NOTIFYDS.

       01  WS-VGET     PIC X(8)  VALUE 'VGET    '.
       01  WS-PROFILE  PIC X(8)  VALUE 'PROFILE '.
       01  WS-ISPLINK  PIC X(8)  VALUE 'ISPLINK ' .

       01  WS-C1BJC1-JOBCARD   PIC X(80) .
       01  WS-C1BJC1 PIC X(08) VALUE '(C1BJC1)'.

       01  WS-C1PJC1-JOBCARD   PIC X(80) .
       01  WS-C1PJC1 PIC X(08) VALUE '(C1PJC1)'.

       01 WS-VARIABLES.
          03  WS-POINTER                   PIC 9(09) COMP.
          03  WS-WORK-ADDRESS-ADR          PIC 9(09) COMP SYNC .
          03  WS-WORK-ADDRESS-PTR          REDEFINES WS-WORK-ADDRESS-ADR
                                           USAGE IS POINTER .

          03  WS-PECB-REQUEST-RETURNCODE     PIC 9999 .
          03  WS-PECB-NDVR-HIGH-RC           PIC 9999 .

          03  ADDRESS-NOTI-USER              PIC 9(09) .

          03  ADDRESS-PECB-NDVR-EXIT-RC      PIC 9(09) .
          03  ADDRESS-PECB-MESSAGE-ID        PIC 9(09) .
          03  ADDRESS-PECB-MESSAGE           PIC 9(09) .
          03  ADDRESS-PECB-ERROR-MESS-LENGTH PIC 9(09) .
          03  ADDRESS-PECB-MODS-MADE-TO-PREQ PIC 9(09) .
          03  ADDRESS-PREQ-SHARE-ENABLED     PIC 9(09) .
          03  ADDRESS-PREQ-BACKOUT-ENABLED   PIC 9(09) .

       01 BPXWDYN PIC X(8) VALUE 'BPXWDYN'.
       01 ALLOC-STRING.
          05 ALLOC-LENGTH PIC S9(4) BINARY VALUE 100.
          05 ALLOC-TEXT   PIC X(100).

       01  IRXJCL                            PIC X(6)  VALUE 'IRXJCL'.
       01  IRXEXEC-PGM                       PIC X(08) VALUE 'IRXEXEC'.

      *
      * DEFINE THE IRXEXEC DATA AREAS AND ARG BLOCKS
      *
       77  FLAGS                             PIC S9(8) BINARY.
       77  REXX-RETURN-CODE                  PIC S9(8) BINARY.
       77  DUMMY-ZERO                        PIC S9(8) BINARY.
       77  LPAR-ID                           PIC X(04).
           88  DO-NOT-PROCESS-LPAR                     VALUE 'SKIP'.
       77  ARG1                              PIC X(16).
       77  UPDPRINT-FILE-STATUS              PIC X(02).
       77  ARGUMENT-PTR                      POINTER.
       77  EXECBLK-PTR                       POINTER.
       77  ARGTABLE-PTR                      POINTER.
       77  EVALBLK-PTR                       POINTER.
       77  TEMP-PTR                          POINTER.

       01  EXECBLK.
           05 EXECBLK-ACRYN                  PIC X(08) VALUE 'IRXEXECB'.
           05 EXECBLK-LENGTH                 PIC S9(8) BINARY
                                                       VALUE 48.
           05 EXECBLK-RESERVED               PIC S9(8) BINARY
                                                       VALUE 0.
           05 EXECBLK-MEMBER                 PIC X(08) VALUE 'C1UEXTR7'.
           05 EXECBLK-DDNAME                 PIC X(08) VALUE 'REXFILE7'.
           05 EXECBLK-SUBCOM                 PIC X(08) VALUE SPACES.
           05 EXECBLK-DSNPTR                 POINTER   VALUE NULL.
           05 EXECBLK-DSNLEN                 PIC 9(04) COMP
                                                       VALUE 0.

       01  EVALBLK.
           05 EVALBLK-EVPAD1                 PIC S9(8) BINARY
                                                       VALUE 0.
           05 EVALBLK-EVSIZE                 PIC S9(8) BINARY
                                                       VALUE 34.
           05 EVALBLK-EVLEN                  PIC S9(8) BINARY
                                                       VALUE 0.
           05 EVALBLK-EVPAD2                 PIC S9(8) BINARY
                                                       VALUE 0.
           05 EVALBLK-EVDATA                 PIC X(256).

       01  ARGUMENT.
           02 ARGUMENT-1                     OCCURS 1 TIMES.
              05 ARGSTRING-PTR               POINTER.
              05 ARGSTRING-LENGTH            PIC S9(8) BINARY.
           02 ARGSTRING-LAST1                PIC S9(8) BINARY
                                                       VALUE -1.
           02 ARGSTRING-LAST2                PIC S9(8) BINARY
                                                       VALUE -1.

      * The block of data below can be used with either an
      * IRXJCL or IRXEXEC call to the rexx program C1UEXTR7.
      * IRXJCL is used when running in batch (batch CAST) .
      * IRXEXEC is used when running in foreground (CAST or APPROVE).
       01  PKG-C1UEXTR7-PARMS-IRXJCL.
         02  PKG-C1UEXTR7-PARMS-IRXJCL-TOP.
           03 PARM-LENGTH          PIC X(2) VALUE X'0BC1'.
           03 REXX-NAME            PIC X(8) VALUE 'C1UEXTR7'.
           03 FILLER               PIC X(1) VALUE SPACE .
         02  PKG-C1UEXTR7-PARMS-IRXEXEC.
           03 WS-REXX-STATEMENTS   PIC X(3000).

       LINKAGE SECTION.
       COPY PKGXBLKS.

       PROCEDURE DIVISION USING
               PACKAGE-EXIT-BLOCK
               PACKAGE-REQUEST-BLOCK
               PACKAGE-EXIT-HEADER-BLOCK
               PACKAGE-EXIT-FILE-BLOCK
               PACKAGE-EXIT-ACTION-BLOCK
               PACKAGE-EXIT-APPROVER-MAP
               PACKAGE-EXIT-BACKOUT-BLOCK
               PACKAGE-EXIT-SHIPMENT-BLOCK
               PACKAGE-EXIT-SCL-BLOCK.
      ****
           IF PECB-USER-BATCH-JOBNAME(1:7) NOT = 'WALJO11' AND
              PECB-USER-BATCH-JOBNAME(1:7) NOT = 'PL05958'
              GOBACK.
      ****

*********  DISPLAY 'C1UEXT07: GOT INTO EXIT 7' .

           IF  SETUP-EXIT-OPTIONS
               MOVE ZERO TO PECB-UEXIT-HOLD-FIELD
*********    to enforce package create rules
*********      MOVE 'Y'   TO PECB-BEFORE-CREATE-BLD
*********      MOVE 'Y'   TO PECB-BEFORE-CREATE-COPY
*********      MOVE 'Y'   TO PECB-BEFORE-CREATE-EDIT
*********      MOVE 'Y'   TO PECB-BEFORE-CREATE-IMPT
*********    to enforce package backout = Y
               MOVE 'Y'   TO PECB-BEFORE-CAST
*********      MOVE 'Y'   TO PECB-MID-CAST
*********      MOVE 'Y'   TO PECB-BEFORE-MOD-IMPT
*********      MOVE 'Y'   TO PECB-AFTER-RESET
*********      MOVE 'Y'   TO PECB-AFTER-DELETE
               MOVE ZEROS TO RETURN-CODE
               GO TO 0100-MAIN-EXIT.

           MOVE 0 TO PECB-NDVR-EXIT-RC.

           MOVE SPACES TO WS-REXX-STATEMENTS  .

           PERFORM 1000-ALLOCATE-REXFILE .
           PERFORM 1500-CALL-C1UEXTR7-REXX .
           MOVE ZERO TO PECB-UEXIT-HOLD-FIELD  .
           PERFORM 2000-FREE-REXFILES .

       0100-MAIN-EXIT.
*********  DISPLAY 'C1UEXT07:   GOING BACK '

           GOBACK.

       1500-CALL-C1UEXTR7-REXX.

      *    Give addresses of updatable fields to the REXX.
      *    MAKES A CALL TO THE REXX ROUTINE C1UEXTR7.

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PECB-NDVR-EXIT-RC .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PECB-NDVR-EXIT-RC.

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PECB-MESSAGE      .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PECB-MESSAGE     .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PECB-ERROR-MESS-LENGTH .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PECB-ERROR-MESS-LENGTH.

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PECB-MODS-MADE-TO-PREQ .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PECB-MODS-MADE-TO-PREQ.

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PECB-MESSAGE-ID.
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PECB-MESSAGE-ID .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PREQ-SHARE-ENABLED.
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PREQ-SHARE-ENABLED .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF PREQ-BACKOUT-ENABLED.
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-PREQ-BACKOUT-ENABLED .

           MOVE PECB-REQUEST-RETURNCODE TO
                WS-PECB-REQUEST-RETURNCODE.

           MOVE PECB-NDVR-HIGH-RC       TO
                WS-PECB-NDVR-HIGH-RC      .

      *****
      ***** / Convert COBOL exit block Datanames into Rexx \
      *****
      *****
           MOVE 1 TO WS-POINTER.

           STRING
              'PECB_PACKAGE_ID = "' PECB-PACKAGE-ID '";'
                 DELIMITED BY SIZE
              'PECB_FUNCTION_LITERAL="' PECB-FUNCTION-LITERAL '";'
                 DELIMITED BY SIZE
              'PECB_SUBFUNC_LITERAL="' PECB-SUBFUNC-LITERAL '";'
                 DELIMITED BY SIZE
              'PECB_BEF_AFTER_LITERAL="' PECB-BEF-AFTER-LITERAL '";'
                 DELIMITED BY SIZE
              'PECB_USER_BATCH_JOBNAME="' PECB-USER-BATCH-JOBNAME '";'
                 DELIMITED BY SIZE
              'PREQ_PKG_CAST_COMPVAL="' PREQ-PKG-CAST-COMPVAL '";'
                 DELIMITED BY SIZE
              'PHDR_PKG_SHR_OPTION  ="' PHDR-PKG-SHR-OPTION '";'
                 DELIMITED BY SIZE
              'PHDR_PKG_ENV ="' PHDR-PKG-ENV '";'
                 DELIMITED BY SIZE
              'PHDR_PKG_STGID ="' PHDR-PKG-STGID '";'
                 DELIMITED BY SIZE
              'PECB_MODE = "' PECB-MODE '";'
                 DELIMITED BY SIZE
              'PECB_AUTOCAST ="' PECB-AUTOCAST '";'
                 DELIMITED BY SIZE
              'PECB_REQUEST_RETURNCODE=' WS-PECB-REQUEST-RETURNCODE ';'
                 DELIMITED BY SIZE
              'PECB_NDVR_HIGH_RC = ' WS-PECB-NDVR-HIGH-RC ';'
                 DELIMITED BY SIZE
              'PREQ_BACKOUT_ENABLED="' PREQ-BACKOUT-ENABLED '";'
                   DELIMITED BY SIZE
              'Address_PREQ_BACKOUT_ENABLED='
                   ADDRESS-PREQ-BACKOUT-ENABLED ';'
                   DELIMITED BY SIZE
              'PREQ_SHARE_ENABLED="' PREQ-SHARE-ENABLED '";'
                   DELIMITED BY SIZE
              'Address_PREQ_SHARE_ENABLED='
                   ADDRESS-PREQ-SHARE-ENABLED ';'
                   DELIMITED BY SIZE
              'Address_PECB_MODS_MADE_TO_PREQ='
                   ADDRESS-PECB-MODS-MADE-TO-PREQ ';'
                   DELIMITED BY SIZE
              'Address_PECB_NDVR_EXIT_RC='
                   ADDRESS-PECB-NDVR-EXIT-RC ';'
                   DELIMITED BY SIZE
              'Address_PECB_MESSAGE_ID=' ADDRESS-PECB-MESSAGE-ID ';'
                   DELIMITED BY SIZE
              'Address_PECB_ERROR_MESS_LENGTH = '
                   ADDRESS-PECB-ERROR-MESS-LENGTH ';'
                     DELIMITED BY SIZE
              'Address_PECB_MESSAGE = ' ADDRESS-PECB-MESSAGE ';'
                     DELIMITED BY SIZE
              INTO   WS-REXX-STATEMENTS
              WITH POINTER WS-POINTER .

*********  For these text fields, make sure none use a double quote
*********  character. This ensures the integrity of the REXX

*******    Replace any double quote characters in data to be passed
           IF CAST-PACKAGE
              INSPECT PREQ-PACKAGE-COMMENT REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE1       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE2       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE3       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE4       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE5       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE6       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE7       REPLACING ALL '"' BY X'7D'
              INSPECT PHDR-PKG-NOTE8       REPLACING ALL '"' BY X'7D'
              STRING
                'PREQ_PACKAGE_COMMENT = "' PREQ-PACKAGE-COMMENT '";'
                   DELIMITED BY SIZE
                'PHDR_PACKAGE_TYPE = "' PHDR-PACKAGE-TYPE '";'
                       DELIMITED BY SIZE
                'PHDR_PACKAGE_STATUS = "' PHDR-PACKAGE-STATUS '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_BACKOUT_STATUS="' PHDR-PKG-BACKOUT-STATUS '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_CREATE_USER = "' PHDR-PKG-CREATE-USER '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_CAST_USER = "' PHDR-PKG-CAST-USER '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE1 = "' PHDR-PKG-NOTE1 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE2 = "' PHDR-PKG-NOTE2 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE3 = "' PHDR-PKG-NOTE3 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE4 = "' PHDR-PKG-NOTE4 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE5 = "' PHDR-PKG-NOTE5 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE6 = "' PHDR-PKG-NOTE6 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE7 = "' PHDR-PKG-NOTE7 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_NOTE8 = "' PHDR-PKG-NOTE8 '";'
                       DELIMITED BY SIZE
                'PHDR_PKG_CAST_COMPVAL = "' PHDR-PKG-CAST-COMPVAL '";'
                       DELIMITED BY SIZE
                INTO   WS-REXX-STATEMENTS
                WITH POINTER WS-POINTER
              END-STRING
           END-IF.

      ***** \ Convert COBOL exit block Datanames into Rexx /
      *****

           MOVE 'C1UEXTR7'           TO EXECBLK-MEMBER .
           MOVE  3000                TO ARGSTRING-LENGTH(1)

           IF PECB-TSO-MODE
              CALL 'SET-ARG1-POINTER'  USING ARGUMENT-PTR
                                             PKG-C1UEXTR7-PARMS-IRXEXEC
              PERFORM 1800-REXX-CALL-VIA-IRXEXEC
              MOVE 0 TO PECB-NDVR-HIGH-RC
           ELSE
*********     DISPLAY 'C1UEXT07: Running in Batch       '
              CALL IRXJCL  USING PKG-C1UEXTR7-PARMS-IRXJCL .

           IF RETURN-CODE NOT = 0
               DISPLAY 'C1UEXT07: BAD CALL TO IRXJCL - RC = '
                        RETURN-CODE
           END-IF

           MOVE 0           TO RETURN-CODE
           .
       1800-REXX-CALL-VIA-IRXEXEC.
      *--- GET THE ADDRESS OF THE ARGUMENT(S) TO BE PASSED TO IXREXEC
      *--- AND LOAD INTO THE ARGUMENT TABLES
*******    IF PECB-USER-BATCH-JOBNAME(1:7) = 'PL05958'
*******        DISPLAY 'C1UEXT07: SETTING UP REXX EXECUTION'
*******                ' FOR PACKAGE 'PECB-PACKAGE-ID
*******    END-IF .
           SET ARGSTRING-PTR (1)           TO ARGUMENT-PTR .
           CALL 'SET-ARGUMENT-POINTER'  USING ARGTABLE-PTR
                                              ARGUMENT .
           CALL 'SET-EXECBLK-POINTER'   USING EXECBLK-PTR
                                              EXECBLK .
           CALL 'SET-EVALBLK-POINTER'   USING EVALBLK-PTR
                                              EVALBLK .
      *--- SET FLAGS TO HEX 20000000
      *    I.E. EXEC INVOKED AS SUBROUTINE
           MOVE 536870912         TO FLAGS
           MOVE 0                 TO REXX-RETURN-CODE .

*********  DISPLAY 'C1UEXT07: CALLING IRXEXC  '
*********              PECB-PACKAGE-ID .
      *--- CALL THE REXX EXEC ---
           CALL IRXEXEC-PGM USING EXECBLK-PTR
                                  ARGTABLE-PTR
                                  FLAGS
                                  DUMMY-ZERO
                                  DUMMY-ZERO
                                  EVALBLK-PTR
                                  DUMMY-ZERO
                                  DUMMY-ZERO
                                  DUMMY-ZERO .

           IF REXX-RETURN-CODE NOT = 0
               DISPLAY 'C1UEXT07: IRXEXEC RETURN CODE = '
                       REXX-RETURN-CODE
           END-IF

           CANCEL IRXEXEC-PGM
           .

       1000-ALLOCATE-REXFILE.

           MOVE SPACES TO ALLOC-TEXT.

           IF PECB-BATCH-MODE
              STRING 'ALLOC DD(SYSEXEC) ',
                'DA(SHARE.ENDV.SHARABLE.REXX)'
                     DELIMITED BY SIZE
                        ' SHR REUSE'
                     DELIMITED BY SIZE
                INTO ALLOC-TEXT
              END-STRING
           ELSE
              STRING 'ALLOC DD(REXFILE7) ',
                'DA(SHARE.ENDV.SHARABLE.REXX)'
                     DELIMITED BY SIZE
                        ' SHR REUSE'
                     DELIMITED BY SIZE
                INTO ALLOC-TEXT
              END-STRING
           END-IF.

           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

********** MOVE 'CONCAT DDLIST(REXFILE,REXFILE2)'
**********   TO ALLOC-TEXT .
**********
********** PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

      *****************************************************************
      **  DYNAMICALLY DE-ALLOCATE UNNEEDED REXX FILES
      *****************************************************************
       2000-FREE-REXFILES.

           MOVE SPACES TO ALLOC-TEXT.

           IF PECB-BATCH-MODE
              MOVE 'FREE  DD(SYSEXEC)' TO ALLOC-TEXT
           ELSE
              MOVE 'FREE  DD(REXFILE7)' TO ALLOC-TEXT
           END-IF.


           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC
           .
      *****************************************************************
      **  CALL BPXWDYN TO PREFORM REQUIRED REXX FUNCTIONS
      *****************************************************************
       9000-DYNAMIC-ALLOC-DEALLOC.

           CALL BPXWDYN USING ALLOC-STRING

           IF RETURN-CODE NOT = ZERO
               DISPLAY 'C1UEXT07: ALLOCATION FAILED: RETURN CODE = '
                       RETURN-CODE
               DISPLAY ALLOC-TEXT
           END-IF

*********  DISPLAY ALLOC-TEXT .
           MOVE SPACES TO ALLOC-TEXT
           .


      ******************************************************************
      *  BEGIN NESTED PROGRAMS USED TO SET THE POINTERS OF DATA AREAS
      *  THAT ARE BEING PASSED TO IRXEXEC SO THAT A REXX ROUTINE CAN
      *  PASS DATA (OTHER THAN A RETURN CODE) BACK TO A COBOL PROGRAM.
      ******************************************************************

      ******** SET-ARG1-POINTER ********
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SET-ARG1-POINTER.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
         77 ARG-PTR                        POINTER.
         77 ARG1                           PIC X(16).
       PROCEDURE DIVISION USING ARG-PTR
                                ARG1.
           SET ARG-PTR TO ADDRESS OF ARG1
           GOBACK.
       END PROGRAM SET-ARG1-POINTER.

      ******** SET-ARGUMENT-POINTER ********
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SET-ARGUMENT-POINTER.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
         77 ARGTABLE-PTR                   POINTER.
         01 ARGUMENT.
           02 ARGUMENT-1                   OCCURS 1 TIMES.
            05 ARGSTRING-PTR               POINTER.
            05 ARGSTRING-LENGTH            PIC S9(8) BINARY.
           02 ARGSTRING-LAST1              PIC S9(8) BINARY.
           02 ARGSTRING-LAST2              PIC S9(8) BINARY.
       PROCEDURE DIVISION USING ARGTABLE-PTR
                                ARGUMENT.
           SET ARGTABLE-PTR TO ADDRESS OF ARGUMENT
           GOBACK.
       END PROGRAM SET-ARGUMENT-POINTER.

      ******** SET-EXECBLK-POINTER ********
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SET-EXECBLK-POINTER.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
         77 EXECBLK-PTR                    POINTER.
         01 EXECBLK.
            03 EXECBLK-ACRYN               PIC X(8).
            03 EXECBLK-LENGTH              PIC 9(4) COMP.
            03 EXECBLK-RESERVED            PIC 9(4) COMP.
            03 EXECBLK-MEMBER              PIC X(8).
            03 EXECBLK-DDNAME              PIC X(8).
            03 EXECBLK-SUBCOM              PIC X(8).
            03 EXECBLK-DSNPTR              POINTER.
            03 EXECBLK-DSNLEN              PIC 9(4) COMP.
       PROCEDURE DIVISION USING EXECBLK-PTR
                                EXECBLK.
           SET EXECBLK-PTR TO ADDRESS OF EXECBLK
           GOBACK.
       END PROGRAM SET-EXECBLK-POINTER.

      ******** SET-EVALBLK-POINTER ********
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SET-EVALBLK-POINTER.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.
         77 EVALBLK-PTR                    POINTER.
         01 EVALBLK.
            03 EVALBLK-EVPAD1              PIC 9(4) COMP.
            03 EVALBLK-EVSIZE              PIC 9(4) COMP.
            03 EVALBLK-EVLEN               PIC 9(4) COMP.
            03 EVALBLK-EVPAD2              PIC 9(4) COMP.
            03 EVALBLK-EVDATA              PIC X(256).
       PROCEDURE DIVISION USING EVALBLK-PTR
                                EVALBLK.
           SET EVALBLK-PTR TO ADDRESS OF EVALBLK
           GOBACK.
       END PROGRAM SET-EVALBLK-POINTER.
      *--- END OF MAIN PROGRAM
       END PROGRAM C1UEXT07.
