       PROCESS OUTDD(DISPLAYS) DYNAM
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
       PROGRAM-ID. APINOTES.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-390 WITH DEBUGGING MODE.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT NOTEDATA ASSIGN TO NOTEDATA.

       DATA DIVISION.

       FILE SECTION.
       FD  NOTEDATA
           RECORDING MODE IS F
                 BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS  80 CHARACTERS
           LABEL RECORDS ARE STANDARD
           DATA RECORD IS NOTES-REC.
       01  NOTES-REC                   PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-VARIABLES.
           03  WS-PGM                  PIC X(08) VALUE 'ENA$NDVR'.
           03  WS-NOTEDATA-FILE-STATUS PIC X(01) VALUE ' '.
               88 NOTEDATA-ATEND       VALUE 'E'.
           03  WS-SAVED-NOTES-DATA     PIC X(60) OCCURS 8 TIMES
               INDEXED BY WS-INX.

           COPY ECHAACTL.
           COPY ECHAAREB.
           COPY ECHAPDEF.

       LINKAGE SECTION.
       01  PARM.
           05  LINK-PARM-LENGTH        PIC S9(04)  COMP.
           05  PARM-RQ-PKGID           PIC  X(16).
           05  PARM-MSGDDN             PIC  X(08).
           05  PARM-LISTDDN            PIC  X(08).

       EJECT
       PROCEDURE DIVISION   USING   PARM.
       MAIN-LINE.
      ******************************************************
      * DISPLAY PARMS
      ******************************************************
********   DISPLAY 'PARM-RQ-PKGID       = ' PARM-RQ-PKGID
********   DISPLAY 'PARM-MSGDDN         = ' PARM-MSGDDN
********   DISPLAY 'PARM-LISTDDN        = ' PARM-LISTDDN

           OPEN INPUT NOTEDATA .

           PERFORM 0100-READ-NOTEDATA VARYING WS-INX
                   FROM 1 BY 1
                   UNTIL (WS-INX > 8 OR NOTEDATA-ATEND).

           CLOSE NOTEDATA.

      ******************************************************
      * SETUP AACTL BLOCK
      ******************************************************
           INITIALIZE         AACTL-DATAAREA.
      *    MOVE LOW-VALUES TO AACTL-DATAAREA.
           MOVE 'Y'                  TO AACTL-SHUTDOWN.
           MOVE PARM-MSGDDN          TO AACTL-MSG-DDN.
           MOVE PARM-LISTDDN         TO AACTL-LIST-DDN.
      ******************************************************
      * SETUP REQUEST BLOCK
      ******************************************************
           INITIALIZE         APDEF-RQ-DATAAREA.
           MOVE PARM-RQ-PKGID        TO APDEF-RQ-PKGID.
           MOVE 'M'                  TO APDEF-RQ-FUNC.
           MOVE 'Y'                  TO APDEF-RQ-UPDT-NOTES.
           MOVE WS-SAVED-NOTES-DATA(1) TO APDEF-RQ-NOTES1.
           IF WS-SAVED-NOTES-DATA(2) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(2) TO APDEF-RQ-NOTES2.
           IF WS-SAVED-NOTES-DATA(3) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(3) TO APDEF-RQ-NOTES3.
           IF WS-SAVED-NOTES-DATA(4) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(4) TO APDEF-RQ-NOTES4.
           IF WS-SAVED-NOTES-DATA(5) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(5) TO APDEF-RQ-NOTES5.
           IF WS-SAVED-NOTES-DATA(6) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(6) TO APDEF-RQ-NOTES6.
           IF WS-SAVED-NOTES-DATA(7) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(7) TO APDEF-RQ-NOTES7.
           IF WS-SAVED-NOTES-DATA(8) NOT EQUAL SPACES
              MOVE WS-SAVED-NOTES-DATA(8) TO APDEF-RQ-NOTES8.
      *******************************************************
      * CALL INTERFACE
      *******************************************************
           CALL WS-PGM     USING AACTL
                                 APDEF-RQ.
********   IF AACTL-RTNCODE = 0
********          NEXT SENTENCE
********   ELSE
********       DISPLAY 'RETURN CODE GT THAN ZERO'
********       DISPLAY AACTL-DATAAREA.
           MOVE AACTL-RTNCODE TO RETURN-CODE.
           STOP RUN.

       0100-READ-NOTEDATA.
           READ NOTEDATA
              AT END
                   MOVE 'E' TO WS-NOTEDATA-FILE-STATUS
              NOT AT END
              MOVE NOTES-REC(1:60) TO WS-SAVED-NOTES-DATA(WS-INX).
********   DISPLAY 'READ RECORD ' WS-SAVED-NOTES-DATA(WS-INX) .

       0199-READ-NOTEDATA.

