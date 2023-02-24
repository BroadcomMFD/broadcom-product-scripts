       PROCESS DYNAM OUTDD(DISPLAYS)
      *
      * THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES
      * STAFF "AS IS".  NO WARRANTY, EITHER EXPRESSED OR
      * IMPLIED, IS MADE FOR THEM.  CA TECHNOLOGIES CANNOT
      * GUARANTEE THAT THE ROUTINES ARE ERROR FREE, OR THAT IF
      * ERRORS ARE FOUND, THEY WILL BE CORRECTED.
      *
      * WRITTEN BY DAN WALTHER
      *
       IDENTIFICATION DIVISION.
       PROGRAM-ID. APIDRIVE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT PACKAGE-INFORMATION ASSIGN TO PACKAGES
              FILE STATUS IS       PACKAGE-INFORMATION-FILE-CHECK .
*******           EXTERNAL DETAILS FOR PACKAGE DEFINITION

       DATA DIVISION.
       FILE SECTION.

       FD  PACKAGE-INFORMATION
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 080 CHARACTERS
           LABEL RECORDS ARE STANDARD
           DATA RECORD IS PACKAGE-INFORMATION-REC.
       01  PACKAGE-INFORMATION-REC.
           03  PACKAGE-INFORMATION-DESC    PIC X(010).
           03  PACKAGE-INFORMATION-DATA    PIC X(070).

       WORKING-STORAGE SECTION.

       01  WS-DATE-VARIABLES.
           03  WS-DATE-OF-RUN                    PIC 9(06).
           03  WS-DOR REDEFINES WS-DATE-OF-RUN.
               05  WS-DOR-YEAR                   PIC 9(02).
               05  WS-DOR-MONTH                  PIC 9(02).
               05  WS-DOR-DAY                    PIC 9(02).

           03  WS-RUN-DATE                       PIC 9(06).
           03  FILLER   REDEFINES   WS-RUN-DATE.
               05  WS-RUN-DATE-YEAR              PIC 9(02).
               05  WS-RUN-DATE-MONTH             PIC 9(02).
               05  WS-RUN-DATE-DAY               PIC 9(02).

           03  WS-TIME-OF-RUN                    PIC 9(08).
           03  FILLER REDEFINES WS-TIME-OF-RUN.
               05  WS-TOR.
                   10  WS-TOR-HOUR               PIC 9(02).
                   10  WS-TOR-MINUTE             PIC 9(02).
               05  FILLER                        PIC 9(04).

           03  WS-RUN-TIME                       PIC 9(04).
           03  FILLER   REDEFINES   WS-RUN-TIME.
               05  WS-RUN-TIME-HOUR              PIC 9(02).
               05  WS-RUN-TIME-MINUTE            PIC 9(02).

       01  WS-APIAPDEF-PARMS.
           03  APIAPDEF-PARM-LENGTH    PIC S9(04)  COMP
                                       VALUE 117.
           03  APIAPDEF-RQ-PKGID       PIC  X(16).
           03  APIAPDEF-MSGDDN         PIC  X(08).
           03  APIAPDEF-LISTDDN        PIC  X(08).
           03  APIAPDEF-RQ-FUNC        PIC  X(01).
           03  APIAPDEF-RQ-APPEND      PIC  X(01).
           03  APIAPDEF-RQ-IMPORT-DDN  PIC  X(08).
           03  APIAPDEF-RQ-DESCRIPTN   PIC  X(50).
           03  APIAPDEF-RQ-EWF-DATE    PIC  X(07).
           03  APIAPDEF-RQ-EWF-TIME    PIC  X(05).
           03  APIAPDEF-RQ-EWT-DATE    PIC  X(07).
           03  APIAPDEF-RQ-EWT-TIME    PIC  X(05).

           COPY ECHAACTL.
           COPY ECHAPDEF.

       01  WS-MONTHS-TABLE.
           03 FILLER                             PIC X(36)
              VALUE 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC' .
       01  WS-MONTHS-TABLE-RE REDEFINES WS-MONTHS-TABLE.
           03 WS-MONTH OCCURS 12 TIMES INDEXED BY WS-MONTH-INX
                                                 PIC X(03).
       01  PACKAGE-INFORMATION-FL-CHCK.
           05  PACKAGE-INFORMATION-FILE-CHECK.
              10  PACKAGE-AUTO-FILE-CHECK-NAME PIC 9(02).

       01  WS-VARIABLES.
           03  WS-TIME                 PIC 9(8).

       01  WS-PACKAGE-INFORMATION-ATEND          PIC X(01).
       PROCEDURE DIVISION.

*********  DISPLAY 'APIDRIVE: GOT INTO APIDRIVE' .

           ACCEPT WS-DATE-OF-RUN FROM DATE.
           ACCEPT WS-TIME-OF-RUN FROM TIME.
           MOVE WS-DOR-YEAR TO WS-RUN-DATE-YEAR.
           MOVE WS-DOR-MONTH TO WS-RUN-DATE-MONTH.
           MOVE WS-DOR-DAY TO WS-RUN-DATE-DAY.
           MOVE WS-TOR-HOUR TO WS-RUN-TIME-HOUR.
           MOVE WS-TOR-MINUTE TO WS-RUN-TIME-MINUTE.

           OPEN INPUT PACKAGE-INFORMATION .
           READ PACKAGE-INFORMATION
             AT END GOBACK.
           MOVE PACKAGE-INFORMATION-DATA(1:16)
                                TO APIAPDEF-RQ-PKGID .

           READ PACKAGE-INFORMATION
             AT END GOBACK.
           MOVE PACKAGE-INFORMATION-DATA(1:16)
                                TO APIAPDEF-RQ-DESCRIPTN .

           PERFORM 950-UPDATE-PACKAGE-SCL-OUT.
           CLOSE PACKAGE-INFORMATION .
           GOBACK.

       950-UPDATE-PACKAGE-SCL-OUT.

           MOVE 'PDFMSG'        TO APIAPDEF-MSGDDN .
           MOVE 'PDFLST'        TO APIAPDEF-LISTDDN .
           MOVE 'C'             TO APIAPDEF-RQ-FUNC .
           MOVE 'N'             TO APIAPDEF-RQ-APPEND .
           MOVE 'SCL'           TO APIAPDEF-RQ-IMPORT-DDN.
           SET WS-MONTH-INX     TO WS-DOR-MONTH  .
           STRING WS-DOR-DAY    DELIMITED BY SIZE
                  WS-MONTH(WS-MONTH-INX)
                                DELIMITED BY SIZE
                  WS-DOR-YEAR   DELIMITED BY SIZE
           INTO                 APIAPDEF-RQ-EWF-DATE .
           MOVE '00:00'         TO APIAPDEF-RQ-EWF-TIME .
           MOVE '00:00'         TO APIAPDEF-RQ-EWT-TIME .
*********  DISPLAY 'CALLING PACKAGE UPDATE'.
           CALL 'APIAPDEF'  USING WS-APIAPDEF-PARMS .
*********  DISPLAY 'BACK FROM PACKAGE UPDATE'.

       1100-EXIT.
           EXIT.
