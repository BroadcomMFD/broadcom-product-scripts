       PROCESS DYNAM RENT OUTDD(DISPLAYS) APOST
       ID DIVISION.
       PROGRAM-ID.  C1UEXT02.
       AUTHOR. DAN WALTHER.
      ******************************************************************
      *  This exit allows an automated re-use of CCID and COMMENT      *
      *  values.                                                       *
      *  When you change an element the 1st time in Quick-Edit         *
      *  or do an Endevor ADD, a CCID and COMMENT are required.        *
      *  When you do subsequent changes, or do an UPDATE, MOVE,...     *
      *  command, then the last CCID and/or COMMENT can be used again  *
      *  if you leave the field blank. The CCID or Comment that is     *
      *  Re-used is the one entered on the ADD or initial QE session.  *                                      *
      *                                                                *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *                                                                *

       DATA DIVISION.
       FILE SECTION.


       WORKING-STORAGE  SECTION.


       01  WS-COMP-FIELDS              COMP.
           05  WS-TALLY                PIC S9(04)  VALUE +0.

       01  WS-VARIABLES.
           05  WS-FILE-STATUS          PIC  X(02)  VALUE ' '.
           05  WS-END-OF-FILE          PIC  X(01)  VALUE ' '.
               88 END-OF-FILE                      VALUE 'Y'.

           05  WS-END-SEARCH           PIC  X(01)  VALUE SPACES.

           05  WS-WORKING-KEYWORD      PIC  X(12)  VALUE SPACES.

           88  FOUND-VALID-SYSTEM      VALUE 'Y'.
           88  NOT-FOUND-VALID-SYSTEM  VALUE 'N'.

       LINKAGE  SECTION.
      * SEE CAI.ENDEVOR.SOURCE(EXITBLKS)
           COPY EXITBLKS.

       EJECT
       PROCEDURE DIVISION USING EXIT-CONTROL-BLOCK
                                REQUEST-INFO-BLOCK
                                SRC-ENVIRONMENT-BLOCK
                                SRC-ELEMENT-MASTER-INFO-BLOCK
                                SRC-FILE-CONTROL-BLOCK
                                TGT-ENVIRONMENT-BLOCK
                                TGT-ELEMENT-MASTER-INFO-BLOCK
                                TGT-FILE-CONTROL-BLOCK.
        0000-START.

           MOVE ZERO TO ECB-RETURN-CODE.

******************************************************************
******* IF CCID OR COMMENT IS BLANK, REUSE LAST ONE              *
*******                                                          *
******* COMMENT/CCID MAY BE PULLED FROM THE LAST ONE SPECIFIED   *
******* WITH ENDEVOR.                                            *
*******                                                          *
******* COMMENT/CCID ARE REQUIRED ON AN ADD.                     *
******************************************************************
*******
           IF NOT (RETRIEVE-ACTION AND RETRIEVE-COPY-ONLY)
               PERFORM 0200-REUSE-CCID-AND-COMMENT.

*******    DISPLAY 'C1UEXT02: EXITING PROGRAM ' .

           GOBACK.

       0200-REUSE-CCID-AND-COMMENT.
           IF REQ-CCID = LOW-VALUES MOVE SPACES TO REQ-CCID .
           IF REQ-COMMENT = LOW-VALUES MOVE SPACES TO REQ-COMMENT .

            IF REQ-CCID = ALL SPACES
              IF SRC-ELM-ACTION-CCID NOT = ALL SPACES
                 AND NOT ADD-ACTION
                 AND NOT UPDATE-ACTION
                 AND NOT GEN-COPYBACK
                 AND SRC-INTERNAL-C1-BLOCK
                 MOVE SRC-ELM-ACTION-CCID    TO REQ-CCID
                 MOVE 4                      TO ECB-RETURN-CODE
*******          IF ECB-USER-ID(1:7) = 'TTECJDW'
*******              DISPLAY 'C1UEXT02: '
*******              'REQ-CCID COPIED FROM SRC-ELM-ACTION-CCID'
*******              DISPLAY 'C1UEXT02: REQ-CCID NOW ' REQ-CCID
*******          END-IF
              ELSE
              IF TGT-ELM-ACTION-CCID NOT = ALL SPACES
                 AND TGT-INTERNAL-C1-BLOCK
                 AND NOT GEN-COPYBACK
                 AND (TGT-ENV-ELEMENT-LEVEL > 0 OR NOT ADD-ACTION)
                 MOVE TGT-ELM-ACTION-CCID    TO REQ-CCID
                 MOVE 4                      TO ECB-RETURN-CODE
              ELSE
                 MOVE 8                      TO ECB-RETURN-CODE
                 MOVE '0011'                 TO ECB-MESSAGE-CODE
                 MOVE 132                    TO ECB-MESSAGE-LENGTH
                 MOVE '***CCID AND COMMENT ARE REQUIRED***'
                                             TO ECB-MESSAGE-TEXT
              .
           IF REQ-COMMENT = ALL SPACES AND
              ECB-RETURN-CODE < 8
              IF SRC-ELM-PROCESSOR-LAST-COMMENT NOT = ALL SPACES
                 AND NOT ADD-ACTION
                 AND NOT UPDATE-ACTION
                 AND NOT GEN-COPYBACK
                 AND SRC-INTERNAL-C1-BLOCK
                 MOVE SRC-ELM-PROCESSOR-LAST-COMMENT TO REQ-COMMENT
                 MOVE 4                      TO ECB-RETURN-CODE
*******              DISPLAY 'C1UEXT02: '
*******                 'REQ-COMMENT COPIED FROM SRC-ELM-PROCESSOR-LAST-COMMENT'
*******              DISPLAY 'C1UEXT02: REQ-COMMENT NOW ' REQ-COMMENT
              ELSE
              IF TGT-ELM-PROCESSOR-LAST-COMMENT NOT = ALL SPACES
                 AND TGT-INTERNAL-C1-BLOCK
                 AND NOT GEN-COPYBACK
                 AND (TGT-ENV-ELEMENT-LEVEL > 0 OR NOT ADD-ACTION)
                 MOVE TGT-ELM-PROCESSOR-LAST-COMMENT TO REQ-COMMENT
                 MOVE 4                      TO ECB-RETURN-CODE
*******              DISPLAY 'C1UEXT02: '
*******                 'REQ-COMMENT COPIED FROM TGT-ELM-PROCESSOR-LAST-COMMENT'
*******              DISPLAY 'C1UEXT02: REQ-COMMENT NOW ' REQ-COMMENT
              ELSE
                 MOVE 8                      TO ECB-RETURN-CODE
                 MOVE '0011'                 TO ECB-MESSAGE-CODE
                 MOVE 132                    TO ECB-MESSAGE-LENGTH
                 MOVE '***CCID AND COMMENT ARE REQUIRED***'
                                             TO ECB-MESSAGE-TEXT
              .

       0699-EXIT.
           EXIT.

       999-EXIT .
