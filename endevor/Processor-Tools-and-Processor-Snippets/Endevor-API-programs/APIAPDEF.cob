       PROCESS OUTDD(DISPLAYS) DYNAM
       IDENTIFICATION DIVISION.
       PROGRAM-ID. APIAPDEF.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-390 WITH DEBUGGING MODE.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.
      *                                                                *
       WORKING-STORAGE SECTION.
       77   WS-PGM          PIC X(8) VALUE 'ENA$NDVR'.
           COPY ECHAACTL.
           COPY ECHAAREB.
           COPY ECHAPDEF.
       LINKAGE SECTION.
       01  PARM.
           05  LINK-PARM-LENGTH        PIC S9(04)  COMP.
           05  PARM-RQ-PKGID           PIC  X(16).
           05  PARM-MSGDDN             PIC  X(08).
           05  PARM-LISTDDN            PIC  X(08).
           05  PARM-RQ-FUNC            PIC  X(01).
           05  PARM-RQ-APPEND          PIC  X(01).
           05  PARM-RQ-IMPORT-DDN      PIC  X(08).
           05  PARM-RQ-DESCRIPTION     PIC  X(50).
           05  PARM-RQ-EWF-DATE        PIC  X(07).
           05  PARM-RQ-EWF-TIME        PIC  X(05).
           05  PARM-RQ-EWT-DATE        PIC  X(07).
           05  PARM-RQ-EWT-TIME        PIC  X(05).

       EJECT
       PROCEDURE DIVISION   USING   PARM.
       MAIN-LINE.
      ******************************************************
      * DISPLAY PARMS
      ******************************************************
********   DISPLAY 'PARM-RQ-PKGID       = ' PARM-RQ-PKGID
********   DISPLAY 'PARM-MSGDDN         = ' PARM-MSGDDN
********   DISPLAY 'PARM-LISTDDN        = ' PARM-LISTDDN
********   DISPLAY 'PARM-RQ-FUNC        = ' PARM-RQ-FUNC
********   DISPLAY 'PARM-RQ-APPEND      = ' PARM-RQ-APPEND
********   DISPLAY 'PARM-RQ-IMPORT-DDN  = ' PARM-RQ-IMPORT-DDN
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
           MOVE PARM-RQ-FUNC         TO APDEF-RQ-FUNC.
           MOVE PARM-RQ-APPEND       TO APDEF-RQ-APPEND.
           MOVE PARM-RQ-IMPORT-DDN   TO APDEF-RQ-IMPORT-DDN.
           MOVE PARM-RQ-DESCRIPTION  TO APDEF-RQ-DESC .
           MOVE PARM-RQ-EWF-DATE     TO APDEF-RQ-EWF-DATE .
           MOVE PARM-RQ-EWF-TIME     TO APDEF-RQ-EWF-TIME .
           MOVE PARM-RQ-EWT-DATE     TO APDEF-RQ-EWT-DATE .
           MOVE PARM-RQ-EWT-TIME     TO APDEF-RQ-EWT-TIME .
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
