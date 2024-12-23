       PROCESS DYNAM OUTDD(DISPLAYS)
      *****************************************************************
      * DESCRIPTION: THIS PGM IS CALLED before Element processing     *
      *              It gathers Endevor info from the exit blocks     *
      *              then calls REXX program C1UEXTR2.                *
      *                                                               *
      * SETUP:       The REXX C1UEXTR2 gets called from DD REXFILE2.  *
      *              Change the DSN to a secure dataset.(2 places)    *
      *                                                               *
      *    STRING 'ALLOC DD(REXFILE2) ', <--look for REXFILE2/SYSEXEC *
      *          'DA(Your.Endevor.CLSTREXX)'  <----- here             *
      *               DELIMITED BY SIZE                               *
      *                 ' SHR REUSE'                                  *
      *               DELIMITED BY SIZE                               *
      *          INTO ALLOC-TEXT                                      *
      *    END-STRING.                                                *
      *****************************************************************
      ** see also EAGGXCOB for Calling IRXEXEC - the IBM example      *
      ** for calling IRXEXEC from a Cobol program                     *
      *****************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. C1UEXT02.
       DATE-COMPILED.
       DATE-WRITTEN.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
      *                                                               *
      *****************************************************************
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.

      *****************************************************************
      * W O R K I N G  S T O R A G E                                  *
      *****************************************************************
       WORKING-STORAGE SECTION.

       77  WS-TRACE                          PIC X    VALUE 'N'.
       77  FLAGS                             PIC S9(8) BINARY.
       77  REXX-RETURN-CODE                  PIC S9(8) BINARY.
       77  DUMMY-ZERO                        PIC S9(8) BINARY VALUE 0.
       77  ARGUMENT-PTR                      POINTER.
       77  EXECBLK-PTR                       POINTER.
       77  ARGTABLE-PTR                      POINTER.
       77  EVALBLK-PTR                       POINTER.

       01  IRXJCL                            PIC X(6)  VALUE 'IRXJCL'.
       01  IRXEXEC-PGM                       PIC X(08) VALUE 'IRXEXEC'.

       01 WS-VARIABLES.
          03  WS-POINTER                   PIC 9(8)  COMP.
          03  WS-WORK-ADDRESS-ADR          PIC S9(8) COMP SYNC .
          03  WS-WORK-ADDRESS-PTR          REDEFINES WS-WORK-ADDRESS-ADR
                                           USAGE IS POINTER .
          03  ADDRESS-ECB-RETURN-CODE      PIC 9(10) .
          03  ADDRESS-ECB-MESSAGE-CODE     PIC 9(10) .
          03  ADDRESS-ECB-MESSAGE-LENGTH   PIC 9(10) .
          03  ADDRESS-ECB-MESSAGE-TEXT     PIC 9(10) .
          03  ADDRESS-REQ-SISO-INDICATOR   PIC 9(10) .
          03  ADDRESS-REQ-CCID             PIC 9(10) .
          03  ADDRESS-REQ-COMMENT          PIC 9(10) .
          03  WS-INSPECT-CCID              PIC X(12) .
          03  WS-INSPECT-COMMENT           PIC X(40) .


       01 BPXWDYN PIC X(8) VALUE 'BPXWDYN'.
       01 ALLOC-STRING.
          05 ALLOC-LENGTH PIC S9(4) BINARY VALUE 100.
          05 ALLOC-TEXT   PIC X(100).

      * The block of data below is passed to the REXX program C1UEXTR2
      * to ensure new elements are Registered.
      * The bulk of the logic is found in C1UEXTR2
       01  ELM-C1UEXTR2-PARMS-IRXJCL.
         02  ELM-EXECUTE-PARMS-IRXJCL-TOP.
           03 PARM-LENGTH           PIC X(02) VALUE X'0F89'.            00004500
           03 REXX-NAME             PIC X(08) VALUE 'C1UEXTR2'.
           03 FILLER                PIC X(01) VALUE SPACE .
         02  ELM-EXECUTE-PARMS-IRXEXEC.                                 00004800
           03 WS-REXX-STATEMENTS    PIC X(4000).

       01  EXECBLK.
           05 EXECBLK-ACRYN                  PIC X(08) VALUE 'IRXEXECB'.
           05 EXECBLK-LENGTH                 PIC S9(8) BINARY
                                                       VALUE 48.
           05 EXECBLK-RESERVED               PIC S9(8) BINARY
                                                       VALUE 0.
           05 EXECBLK-MEMBER                 PIC X(08) VALUE 'C1UEXTR2'.
           05 EXECBLK-DDNAME                 PIC X(08) VALUE 'REXFILE2'.
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


      *-----------------------------------------------------------------
       LINKAGE SECTION.
      *-----------------------------------------------------------------
       COPY EXITBLKS.

       PROCEDURE DIVISION USING
                          EXIT-CONTROL-BLOCK
                          REQUEST-INFO-BLOCK
                          SRC-ENVIRONMENT-BLOCK
                          SRC-ELEMENT-MASTER-INFO-BLOCK
                          SRC-FILE-CONTROL-BLOCK
                          TGT-ENVIRONMENT-BLOCK
                          TGT-ELEMENT-MASTER-INFO-BLOCK
                          TGT-FILE-CONTROL-BLOCK.

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: RETURN-CODE =' RETURN-CODE  .

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Entered'
                 ' SRC-ENV-TYPE-OF-BLOCK=' SRC-ENV-TYPE-OF-BLOCK
                 ' TGT-ENV-TYPE-OF-BLOCK=' TGT-ENV-TYPE-OF-BLOCK
              DISPLAY 'C1UEXT02:   '
                 ' SRC-ENV-IO-TYPE=' SRC-ENV-IO-TYPE
                 ' TGT-ENV-IO-TYPE=' TGT-ENV-IO-TYPE
           END-IF.

           IF PACKAGE-INSPECT THEN GOBACK.

           MOVE SPACES TO WS-REXX-STATEMENTS .

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Setting up addresses ' .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF ECB-RETURN-CODE .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-ECB-RETURN-CODE .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF ECB-MESSAGE-CODE.
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-ECB-MESSAGE-CODE.

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF ECB-MESSAGE-LENGTH.
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-ECB-MESSAGE-LENGTH .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF ECB-MESSAGE-TEXT  .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-ECB-MESSAGE-TEXT   .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF REQ-CCID  .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-REQ-CCID .

           SET  WS-WORK-ADDRESS-PTR TO
                ADDRESS OF REQ-COMMENT .
           MOVE WS-WORK-ADDRESS-ADR
                                TO ADDRESS-REQ-COMMENT .

      *****
      ***** / Convert COBOL exit block Datanames into Rexx \
      *****
      *****
           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: removing quote chars ' .

           MOVE 1 TO WS-POINTER.

           INSPECT REQ-CCID               REPLACING ALL '"' BY X'7D'.
           INSPECT REQ-COMMENT            REPLACING ALL '"' BY X'7D'.

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Stringing ECB vars   ' .

           STRING
                  'ECB_TSO_BATCH_MODE = "'
                     DELIMITED BY SIZE
                   ECB-TSO-BATCH-MODE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'ECB_USER_ID = "'
                     DELIMITED BY SIZE
                   ECB-USER-ID
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'ECB_ACTION_NAME = "'
                     DELIMITED BY SIZE
                   ECB-ACTION-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_CCID = "'
                     DELIMITED BY SIZE
                   REQ-CCID
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'Address_REQ_CCID = '
                     DELIMITED BY SIZE
                   ADDRESS-REQ-CCID
                     DELIMITED BY SIZE
                  ';'
                     DELIMITED BY SIZE
                  'REQ_COMMENT = "'
                     DELIMITED BY SIZE
                   REQ-COMMENT
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'Address_REQ_COMMENT = '
                     DELIMITED BY SIZE
                   ADDRESS-REQ-COMMENT
                     DELIMITED BY SIZE
                  ';'
                     DELIMITED BY SIZE
                  'REQ_SISO_INDICATOR = "'
                     DELIMITED BY SIZE
                   REQ-SISO-INDICATOR
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_DELETE_AFTER = "'
                     DELIMITED BY SIZE
                   REQ-DELETE-AFTER
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_SYNCHRONIZE = "'
                     DELIMITED BY SIZE
                   REQ-SYNCHRONIZE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_IGNGEN_FAIL = "'
                     DELIMITED BY SIZE
                   REQ-IGNGEN-FAIL
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_PROCESSOR_GROUP = "'
                     DELIMITED BY SIZE
                   REQ-PROCESSOR-GROUP
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_OVERWRITE_INDICATOR = "'
                     DELIMITED BY SIZE
                   REQ-OVERWRITE-INDICATOR
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_GEN_COPYBACK = "'
                     DELIMITED BY SIZE
                   REQ-GEN-COPYBACK
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_BENE = "'
                     DELIMITED BY SIZE
                   REQ-BENE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'REQ_AUTOGEN = "'
                     DELIMITED BY SIZE
                   REQ-AUTOGEN
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'Address_ECB_RETURN_CODE = ' ADDRESS-ECB-RETURN-CODE
                     DELIMITED BY SIZE
                  '; '
                     DELIMITED BY SIZE
                  'Address_ECB_MESSAGE_CODE = ' ADDRESS-ECB-MESSAGE-CODE
                     DELIMITED BY SIZE
                  '; '
                     DELIMITED BY SIZE
                  'Address_ECB_MESSAGE_LENGTH = '
                     ADDRESS-ECB-MESSAGE-LENGTH
                     DELIMITED BY SIZE
                  '; '
                     DELIMITED BY SIZE
                  'Address_ECB_MESSAGE_TEXT = '
                     ADDRESS-ECB-MESSAGE-TEXT
                     DELIMITED BY SIZE
                  '; '
                     DELIMITED BY SIZE
              INTO   WS-REXX-STATEMENTS
              WITH POINTER WS-POINTER
           END-STRING.

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Stringing SRC vars   '
                      'SRC-ENV-IO-TYPE=' SRC-ENV-IO-TYPE .

           IF SRC-ENV-LENGTH GREATER THAN ZERO
              MOVE SRC-ELM-ACTION-CCID TO WS-INSPECT-CCID
              INSPECT WS-INSPECT-CCID
                 REPLACING ALL '"' BY X'7D'
              MOVE SRC-ELM-LEVEL-COMMENT TO
                 WS-INSPECT-COMMENT
              INSPECT WS-INSPECT-COMMENT
                 REPLACING ALL '"' BY X'7D'

              INSPECT WS-INSPECT-CCID     REPLACING ALL '"' BY X'7D'
              INSPECT WS-INSPECT-COMMENT  REPLACING ALL '"' BY X'7D'
              STRING
                 'SRC_ELM_ACTION_CCID = "'
                    DELIMITED BY SIZE
                  WS-INSPECT-CCID
                    DELIMITED BY SIZE
                 '";'
                    DELIMITED BY SIZE
                 'SRC_ELM_LEVEL_COMMENT= "'
                    DELIMITED BY SIZE
                  WS-INSPECT-COMMENT
                    DELIMITED BY SIZE
                 '";'
                    DELIMITED BY SIZE
                 'SRC_ELM_LAST_PROC_PACKAGE = "'
                    DELIMITED BY SIZE
                  SRC-ELM-LAST-PROC-PACKAGE
                    DELIMITED BY SIZE
                 '";'
                    DELIMITED BY SIZE
                 'SRC_ELM_PROCESSOR_GROUP = "'
                    DELIMITED BY SIZE
                  SRC-ELM-PROCESSOR-GROUP
                    DELIMITED BY SIZE
                 '";'
                    DELIMITED BY SIZE
              INTO   WS-REXX-STATEMENTS
              WITH POINTER WS-POINTER
              END-STRING

              STRING
                  'SRC_ENV_ENVIRONMENT_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-ENVIRONMENT-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_STAGE_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-STAGE-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_SYSTEM_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-SYSTEM-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_SUBSYSTEM_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-SUBSYSTEM-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_TYPE_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-TYPE-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_ELEMENT_NAME = "'
                     DELIMITED BY SIZE
                   SRC-ENV-ELEMENT-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_TYPE_OF_BLOCK = "'
                     DELIMITED BY SIZE
                   SRC-ENV-TYPE-OF-BLOCK
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'SRC_ENV_IO_TYPE = "'
                     DELIMITED BY SIZE
                   SRC-ENV-IO-TYPE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
              INTO   WS-REXX-STATEMENTS
              WITH POINTER WS-POINTER
              END-STRING
              END-IF .

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Stringing TGT vars   '
           END-IF .

           IF TGT-ENV-LENGTH GREATER THAN ZERO
              STRING
                  'TGT_ENV_ENVIRONMENT_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-ENVIRONMENT-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_STAGE_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-STAGE-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_SYSTEM_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-SYSTEM-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_SUBSYSTEM_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-SUBSYSTEM-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_TYPE_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-TYPE-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_ELEMENT_NAME = "'
                     DELIMITED BY SIZE
                   TGT-ENV-ELEMENT-NAME
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_TYPE_OF_BLOCK = "'
                     DELIMITED BY SIZE
                   TGT-ENV-TYPE-OF-BLOCK
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ENV_IO_TYPE = "'
                     DELIMITED BY SIZE
                   TGT-ENV-IO-TYPE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ELM_LAST_PROC_PACKAGE = "'
                     DELIMITED BY SIZE
                   TGT-ELM-LAST-PROC-PACKAGE
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
                  'TGT_ELM_PROCESSOR_GROUP = "'
                     DELIMITED BY SIZE
                   TGT-ELM-PROCESSOR-GROUP
                     DELIMITED BY SIZE
                  '";'
                     DELIMITED BY SIZE
              INTO   WS-REXX-STATEMENTS
              WITH POINTER WS-POINTER
              END-STRING

              IF TGT-ENV-TYPE-OF-BLOCK = 'C'
                 MOVE TGT-ELM-ACTION-CCID TO WS-INSPECT-CCID
                 INSPECT WS-INSPECT-CCID
                    REPLACING ALL '"' BY X'7D'
                 MOVE TGT-ELM-LEVEL-COMMENT TO
                    WS-INSPECT-COMMENT
                 INSPECT WS-INSPECT-COMMENT
                    REPLACING ALL '"' BY X'7D'

                 STRING
                    'TGT_ELM_ACTION_CCID = "'
                       DELIMITED BY SIZE
                     WS-INSPECT-CCID
                       DELIMITED BY SIZE
                    '";'
                       DELIMITED BY SIZE
                    'TGT_ELM_LEVEL_COMMENT= "'
                       DELIMITED BY SIZE
                     WS-INSPECT-COMMENT
                       DELIMITED BY SIZE
                    '";'
                       DELIMITED BY SIZE
                 INTO   WS-REXX-STATEMENTS
                 WITH POINTER WS-POINTER
                 END-STRING
                 END-IF
           END-IF.
      ***** \ Convert COBOL exit block Datanames into Rexx /
      *****

           IF WS-TRACE = 'Y' THEN
              DISPLAY 'C1UEXT02: Calling Rexx'
           END-IF.

      *****IF TSO
              MOVE 'C1UEXTR2'             TO EXECBLK-MEMBER
              MOVE  4000                  TO ARGSTRING-LENGTH(1)
              MOVE SPACES TO ALLOC-TEXT
              PERFORM 2100-ALLOCATE-REXFILE
              CALL 'SET-ARG1-POINTER'  USING ARGUMENT-PTR
                                             ELM-EXECUTE-PARMS-IRXEXEC
              PERFORM 1800-REXX-CALL-VIA-IRXEXEC
              PERFORM 2200-FREE-REXFILES
      *****ELSE
      *****   PERFORM 2101-ALLOCATE-SYSEXEC
      *****   CALL IRXJCL  USING ELM-C1UEXTR2-PARMS-IRXJCL
      *****   IF RETURN-CODE NOT = 0
      *****       DISPLAY 'C1UEXT02: BAD CALL TO IRXJCL - RC = '
      *****             RETURN-CODE
      *****   END-IF
      *****   PERFORM 2201-FREE-SYSEXEC
      *****END-IF .

           MOVE 0           TO RETURN-CODE .

           GOBACK.

       1800-REXX-CALL-VIA-IRXEXEC.
           SET ARGSTRING-PTR (1)           TO ARGUMENT-PTR .
           CALL 'SET-ARGUMENT-POINTER'  USING ARGTABLE-PTR
                                              ARGUMENT .
           CALL 'SET-EXECBLK-POINTER'   USING EXECBLK-PTR
                                              EXECBLK .
           CALL 'SET-EVALBLK-POINTER'   USING EVALBLK-PTR
                                              EVALBLK .
           MOVE 536870912         TO FLAGS
           MOVE 0                 TO REXX-RETURN-CODE .

      *--- CALL THE REXX EXEC ---
           CALL IRXEXEC-PGM USING EXECBLK-PTR
                                  ARGTABLE-PTR
                                  FLAGS
                                  DUMMY-ZERO
                                  DUMMY-ZERO
                                  EVALBLK-PTR
                                  DUMMY-ZERO
                                  DUMMY-ZERO
                                  DUMMY-ZERO
                                  REXX-RETURN-CODE.

           IF REXX-RETURN-CODE NOT = 0
               DISPLAY 'C1UEXT02: IRXEXEC RETURN CODE = '
                       REXX-RETURN-CODE
           END-IF

           CANCEL IRXEXEC-PGM
           .

      *****************************************************************
      **  Allocate DD REXFILE for TSO processing
      *****************************************************************
       2100-ALLOCATE-REXFILE.

           MOVE SPACES TO ALLOC-TEXT .
           STRING 'ALLOC DD(REXFILE2) ',
                 'DA(Your.Endevor.CLSTREXX)'
                      DELIMITED BY SIZE
                        ' SHR REUSE'
                      DELIMITED BY SIZE
                 INTO ALLOC-TEXT
           END-STRING.
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

      *****************************************************************
      **  Allocate DD SYSEXEC for batch processing
      *****************************************************************
       2101-ALLOCATE-SYSEXEC.

           MOVE SPACES TO ALLOC-TEXT .
           STRING 'ALLOC DD(SYSEXEC) ',
                 'DA(Your.Endevor.CLSTREXX)'
                      DELIMITED BY SIZE
                        ' SHR REUSE'
                      DELIMITED BY SIZE
                 INTO ALLOC-TEXT
           END-STRING.
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

      *****************************************************************
      **  DYNAMICALLY DE-ALLOCATE UNNEEDED REXX FILES
      *****************************************************************
       2200-FREE-REXFILES.

           MOVE 'FREE  DD(REXFILE2)' TO ALLOC-TEXT
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

      *****************************************************************
      **  CALL BPXWDYN TO PREFORM REQUIRED REXX FUNCTIONS
       2201-FREE-SYSEXEC.

           MOVE 'FREE  DD(SYSEXEC)' TO ALLOC-TEXT
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

      *****************************************************************
      **  CALL BPXWDYN TO PREFORM REQUIRED REXX FUNCTIONS
       9000-DYNAMIC-ALLOC-DEALLOC.

           CALL BPXWDYN USING ALLOC-STRING

           IF RETURN-CODE NOT = ZERO OR
              WS-TRACE = 'Y' THEN
               DISPLAY 'C1UEXT02: ALLOCATION result: RETURN CODE = '
                       RETURN-CODE
               DISPLAY ALLOC-TEXT
           END-IF

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
       END PROGRAM C1UEXT02.
