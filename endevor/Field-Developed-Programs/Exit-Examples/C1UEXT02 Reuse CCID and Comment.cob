       PROCESS DYNAM RENT OUTDD(DISPLAYS) APOST LIB LIST OFFSET
      *
      * Miscelaneous "Before element Action" exit.
      *
      *  Reuse the CCID and COMMENT values for the Element when        *
      *  left blank.                                                   *
      *
      *  Save the name of the Entry environment in the USERData field  *
      *  so that it remains available in the merged section of the     *
      *  Endevor map.                                                  *
      *
       ID DIVISION.
       PROGRAM-ID.  C1UEXT02.
       AUTHOR. Person.
      ******************************************************************
      *                                                                *
      *  EXIT TO REUSE CCID AND COMMENT AND PROVIDE COLLISION MSGS .   *
      *                                                                *
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *                                                                *
       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE  SECTION.
       01  WS-WORK-FIELDS.
           05  WS-TALLY                PIC  9(04).
       01  WS-VARIABLES.
           05  WS-FILE-STATUS          PIC  X(02)  VALUE ' '.
           05  WS-END-OF-FILE          PIC  X(01)  VALUE ' '.
               88 END-OF-FILE                      VALUE 'Y'.
           05  WS-END-SEARCH           PIC  X(01)  VALUE SPACES.
           05  WS-WORKING-KEYWORD      PIC  X(12)  VALUE SPACES.
           05  WS-WORKING-COMMENT      PIC  X(40)  VALUE SPACES.
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
           IF ECB-USER-ID(1:7) NOT = 'IbmUser'
              GOBACK.
*******    DISPLAY 'REQ-DELETE-AFTER=' REQ-DELETE-AFTER.
*******    DISPLAY 'REQ-BYPASS-DEL-PROC= ' REQ-BYPASS-DEL-PROC.
*******          IF ECB-USER-ID(1:7) = 'Ibmuser'
*******    DISPLAY 'C1UEXT02: ENTERING EXIT 2 -'
*******            'ECB-USER-ID = ' ECB-USER-ID
*******            ' ECB-ACTION-NAME ' ECB-ACTION-NAME
*******            ' REQ-GEN-COPYBACK ' REQ-GEN-COPYBACK
*******            ' ECB-CALLER-ORIGIN IS '
*******             ECB-CALLER-ORIGIN .
           MOVE ZERO TO ECB-RETURN-CODE.
      *** If doing an ADD or UPDATE then replicate the
      *** Environment and Subsystem fields into the 'User Data'
      *** to keep the element's entry location for the life of
      *** its trip thru the life cycle.
      *** Default to the source block USER data field.
           IF  SRC-EXTERNAL-ENV-BLOCK
               MOVE SRC-ELM-USER-DATA TO REQ-USER-DATA
               MOVE 4                 TO ECB-RETURN-CODE
           END-IF.
      *** Under these conditions, force an update of the USER data fiel
           IF (ADD-ACTION      OR UPDATE-ACTION OR
               GENERATE-ACTION OR TRANSFER-ACTION)
            AND (TGT-ENV-ENVIRONMENT-NAME(5:4) NOT = 'PROD' )
               MOVE SPACES TO REQ-USER-DATA
               STRING
                   TGT-ENV-ENVIRONMENT-NAME DELIMITED BY SIZE
                   '   '                    DELIMITED BY SIZE
                   TGT-ENV-SUBSYSTEM-NAME   DELIMITED BY SIZE
                   INTO REQ-USER-DATA(1:20)
               END-STRING
               MOVE 4                      TO ECB-RETURN-CODE
***********    DISPLAY 'C1UEXT02: Userdata='REQ-USER-DATA(1:20)
           END-IF.
      *** If doing a GENERATE in a non-prod environment, then place
      *** Environment and Subsystem fields into the 'User Data'
           IF    GENERATE-ACTION
            AND (SRC-ENV-ENVIRONMENT-NAME(5:4) NOT = 'PROD' )
            AND (TGT-ENV-ENVIRONMENT-NAME      < 'A')
               MOVE SPACES TO REQ-USER-DATA
               STRING
                   SRC-ENV-ENVIRONMENT-NAME DELIMITED BY SIZE
                   '   '                    DELIMITED BY SIZE
                   SRC-ENV-SUBSYSTEM-NAME   DELIMITED BY SIZE
                   INTO REQ-USER-DATA(1:20)
               END-STRING
               MOVE 4                      TO ECB-RETURN-CODE
     ****      DISPLAY 'C1UEXT02: Userdata='REQ-USER-DATA(1:20)
           END-IF.
******************************************************************
******* IF MOVE, BUT NOT TO PROD, THEN RETAIN SIGNOUT            *
******* ALSO, CHECK FOR COLLISION:                               *
*******       - ONE SIGNOUT TO OVERLAY ANOTHER                   *
******************************************************************
           MOVE 1 TO WS-TALLY.
           IF MOVE-ACTION AND
              TGT-ENV-ENVIRONMENT-NAME NOT = 'SMPLPROD'
              MOVE 'Y' TO REQ-RETAIN-SIGNOUT-OPT
              MOVE 4   TO ECB-RETURN-CODE
******        IF ECB-USER-ID(1:7) = 'ibmuser'
******           DISPLAY 'Collision checking'
******           DISPLAY 'TGT-ENV-ENVIRONMENT-NAME='
******                    TGT-ENV-ENVIRONMENT-NAME
******           DISPLAY 'SRC-ELM-SIGNOUT-ID='
******                    SRC-ELM-SIGNOUT-ID
******           DISPLAY 'TGT-ELM-SIGNOUT-ID='
******                    TGT-ELM-SIGNOUT-ID
******        END-IF
              IF TGT-INTERNAL-C1-BLOCK
                 MOVE TGT-ELM-SIGNOUT-ID TO WS-WORKING-KEYWORD(1:8)
                 PERFORM VARYING WS-TALLY FROM 1 BY 1
                        UNTIL WS-TALLY > 7
                   IF WS-WORKING-KEYWORD(WS-TALLY:1) < ' '
                      MOVE SPACES TO WS-WORKING-KEYWORD
                      MOVE 8 TO WS-TALLY
                   END-IF
                 END-PERFORM
******           IF ECB-USER-ID(1:7) = 'Ibmuser'
******              DISPLAY 'SRC-ELM-SIGNOUT-ID='
******                       SRC-ELM-SIGNOUT-ID
******              DISPLAY 'WS-WORKING-KEYWORD='
******                       WS-WORKING-KEYWORD
******           END-IF
                 IF WS-WORKING-KEYWORD NOT = SPACES AND
                   (SRC-ELM-SIGNOUT-ID NOT = TGT-ELM-SIGNOUT-ID)
                    MOVE 8                   TO ECB-RETURN-CODE
                    MOVE '0011'              TO ECB-MESSAGE-CODE
                    MOVE 132                 TO ECB-MESSAGE-LENGTH
                    MOVE '***COLLISION - ATTEMPTING TO OVERLAY ELM***'
                                             TO ECB-MESSAGE-TEXT
                    GOBACK
                 END-IF
              END-IF
           END-IF.
******************************************************************
******* IF CCID OR COMMENT IS BLANK, REUSE LAST ONE              *
*******                                                          *
******* COMMENT/CCID MAY BE PULLED FROM THE LAST ONE SPECIFIED   *
******* WITH ENDEVOR.                                            *
*******                                                          *
******* COMMENT/CCID ARE REQUIRED ON AN ADD.                     *
******************************************************************
*******
*******    MOVE 'ASSIGNED DATA BY C1UEXT02' TO
*******                   REQ-USER-DATA .
           IF NOT (RETRIEVE-ACTION AND RETRIEVE-COPY-ONLY)
               PERFORM 0200-REUSE-CCID-AND-COMMENT.
*******    DISPLAY 'C1UEXT02: EXITING PROGRAM ' .
           GOBACK.
       0200-REUSE-CCID-AND-COMMENT.
   ******* If the user leaves blank the CCID and/or COMMENT
   ******* then we can use a previously stated value
******     IF ECB-USER-ID(1:7) = 'Ibmuser'
******        DISPLAY 'C1UEXT02: '
******                'REQ-CCID = ' REQ-CCID  .
           IF REQ-CCID = ALL SPACES
              IF NOT ADD-ACTION AND
                 NOT GEN-COPYBACK AND
                 SRC-INTERNAL-C1-BLOCK
    ******       If any chars of the CCID are hex, space fill
                 MOVE SRC-ELM-ACTION-CCID TO WS-WORKING-KEYWORD
                 INSPECT WS-WORKING-KEYWORD REPLACING
                         ALL LOW-VALUES BY SPACES
                 PERFORM VARYING WS-TALLY FROM 1 BY 1
                        UNTIL WS-TALLY > 11
                   IF WS-WORKING-KEYWORD(WS-TALLY:1) < ' '
                      MOVE SPACES TO WS-WORKING-KEYWORD
                      MOVE 12 TO WS-TALLY
                   END-IF
                 END-PERFORM
******           IF ECB-USER-ID(1:7) = 'Ibmuser'
******              DISPLAY 'C1UEXT02: Examining SRC CCID '
******              DISPLAY 'C1UEXT02: '
******                'SRC-ELM-ACTION-CCID=' SRC-ELM-ACTION-CCID
******                'WS-WORKING-KEYWORD='  WS-WORKING-KEYWORD
******           END-IF
    ******       If the CCID is good, we can re-use it
                 IF WS-WORKING-KEYWORD NOT = ALL SPACES
                    MOVE SRC-ELM-ACTION-CCID  TO REQ-CCID
                    MOVE 4                    TO ECB-RETURN-CODE
******              IF ECB-USER-ID(1:7) = 'Ibmuser'
******                  DISPLAY 'C1UEXT02: '
******                  'REQ-CCID COPIED FROM SRC-ELM-ACTION-CCID'
******                  DISPLAY 'C1UEXT02: REQ-CCID NOW ' REQ-CCID
******              END-IF
                 END-IF
              END-IF.
    ******  If the CCID is still blank, consider the TGT...CCID
            IF REQ-CCID = ALL SPACES AND
               TGT-INTERNAL-C1-BLOCK AND
               NOT GEN-COPYBACK AND
               (TGT-ENV-ELEMENT-LEVEL > 0 OR NOT ADD-ACTION)
               MOVE TGT-ELM-ACTION-CCID TO WS-WORKING-KEYWORD
               INSPECT WS-WORKING-KEYWORD REPLACING
                       ALL LOW-VALUES BY SPACES
               PERFORM VARYING WS-TALLY FROM 1 BY 1
                        UNTIL WS-TALLY > 11
                  IF WS-WORKING-KEYWORD(WS-TALLY:1) < ' '
                     MOVE SPACES TO WS-WORKING-KEYWORD
                     MOVE 12 TO WS-TALLY
                  END-IF
               END-PERFORM
******         IF ECB-USER-ID(1:7) = 'Ibmuser'
******            DISPLAY 'C1UEXT02: Examining TGT CCID '
******            DISPLAY 'C1UEXT02: '
******              'TGT-ELM-ACTION-CCID=' TGT-ELM-ACTION-CCID
******              'WS-WORKING-KEYWORD=' WS-WORKING-KEYWORD
******         END-IF
    ******     If the CCID is good, we can re-use it
               IF WS-WORKING-KEYWORD NOT = ALL SPACES
                  MOVE TGT-ELM-ACTION-CCID    TO REQ-CCID
                  MOVE 4                      TO ECB-RETURN-CODE
******            IF ECB-USER-ID(1:7) = 'Ibmuser'
******                DISPLAY 'C1UEXT02: '
******                'REQ-CCID COPIED FROM TGT-ELM-ACTION-CCID'
******                DISPLAY 'C1UEXT02: REQ-CCID NOW ' REQ-CCID
******            END-IF
            END-IF.
    ******  If the CCID is still blank, we have an error
            IF REQ-CCID = ALL SPACES
******           IF ECB-USER-ID(1:7) = 'Ibmuser'
******               DISPLAY 'C1UEXT02: '
******               'CAUSING FAILURE '
******           END-IF
                 MOVE 8                      TO ECB-RETURN-CODE
                 MOVE '0011'                 TO ECB-MESSAGE-CODE
                 MOVE 132                    TO ECB-MESSAGE-LENGTH
                 MOVE '***CCID AND COMMENT ARE REQUIRED***'
                                             TO ECB-MESSAGE-TEXT
                 GOBACK
              .
    ****   Now reuse COMMENT if appropriatae
           IF REQ-COMMENT = ALL SPACES AND
              SRC-INTERNAL-C1-BLOCK AND
              NOT ADD-ACTION     AND
              NOT UPDATE-ACTION  AND
              NOT GEN-COPYBACK   AND
              ECB-RETURN-CODE < 8
    ******    If any chars of the COMMENT are hex, space fill
******        IF ECB-USER-ID(1:7) = 'Ibmuser'
******           DISPLAY 'C1UEXT02: Examining SRC COMMENT '
******        END-IF
              MOVE SRC-ELM-PROCESSOR-LAST-COMMENT
                TO WS-WORKING-COMMENT
              INSPECT WS-WORKING-COMMENT REPLACING
                      ALL LOW-VALUES BY SPACES
              PERFORM VARYING WS-TALLY FROM 1 BY 1
                     UNTIL WS-TALLY > 39
                IF WS-WORKING-COMMENT(WS-TALLY:1) < ' '
                   MOVE SPACES TO WS-WORKING-COMMENT
                   MOVE 40 TO WS-TALLY
                END-IF
              END-PERFORM
              IF WS-WORKING-COMMENT NOT = ALL SPACES
                 MOVE SRC-ELM-PROCESSOR-LAST-COMMENT TO REQ-COMMENT
                 MOVE 4                      TO ECB-RETURN-CODE
*******              DISPLAY 'C1UEXT02: '
*******                 'REQ-COMMENT COPIED FROM SRC-ELM-PROCESSOR-LAST-COMMENT'
*******              DISPLAY 'C1UEXT02: REQ-COMMENT NOW ' REQ-COMMENT
              END-IF.
    ****** If COMMENT is still blank, consider the TGT...COMMENT
           IF REQ-COMMENT = ALL SPACES AND
              TGT-INTERNAL-C1-BLOCK AND
              NOT GEN-COPYBACK      AND
              (TGT-ENV-ELEMENT-LEVEL > 0 OR NOT ADD-ACTION)
******        IF ECB-USER-ID(1:7) = 'Ibmuser'
******           DISPLAY 'C1UEXT02: Examining TGT COMMENT '
******        END-IF
              MOVE TGT-ELM-PROCESSOR-LAST-COMMENT
                TO WS-WORKING-COMMENT
              INSPECT WS-WORKING-COMMENT REPLACING
                      ALL LOW-VALUES BY SPACES
              PERFORM VARYING WS-TALLY FROM 1 BY 1
                     UNTIL WS-TALLY > 39
                IF WS-WORKING-COMMENT(WS-TALLY:1) < ' '
                   MOVE SPACES TO WS-WORKING-COMMENT
                   MOVE 40 TO WS-TALLY
                END-IF
              END-PERFORM
              IF WS-WORKING-COMMENT NOT = ALL SPACES
                 MOVE TGT-ELM-PROCESSOR-LAST-COMMENT TO REQ-COMMENT
                 MOVE 4                      TO ECB-RETURN-CODE
*******              DISPLAY 'C1UEXT02: '
*******                 'REQ-COMMENT COPIED FROM TGT-ELM-PROCESSOR-LAST-COMMENT'
*******              DISPLAY 'C1UEXT02: REQ-COMMENT NOW ' REQ-COMMENT
              END-IF.
    ****** If COMMENT is still blank, consider the TGT...COMMENT
           IF REQ-COMMENT = ALL SPACES
                 MOVE 8                      TO ECB-RETURN-CODE
                 MOVE '0011'                 TO ECB-MESSAGE-CODE
                 MOVE 132                    TO ECB-MESSAGE-LENGTH
                 MOVE '***CCID AND COMMENT ARE REQUIRED***'
                                             TO ECB-MESSAGE-TEXT
              .
       0699-EXIT.
           EXIT.
       999-EXIT .
