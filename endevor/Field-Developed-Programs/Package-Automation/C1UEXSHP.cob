       PROCESS DYNAM OUTDD(DISPLAYS)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. C1UEXSHP.

      ************************************************************
      * DESCRIPTION:  THIS PACKAGE EXIT PROGRAM WILL INITIATE    *
      * 1) Require all packages be backout enabled               *
      * 2) Support Automated PACKAGE Shipping                    *
      ************************************************************
      * THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".
      * NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.
      * COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE
      * ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.
      ************************************************************
      * Change the Dataset references within this program:       *
      * 1) Find all "DA("                                        *
      * 2) Change each dataset name to your REXX library         *
      ************************************************************

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      **
       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.

       01  WS-VARIABLES.
           03  ME                      PIC X(07) VALUE 'XALJO11'.

       01 BPXWDYN PIC X(8) VALUE 'BPXWDYN'.
       01 ALLOC-STRING.
          05 ALLOC-LENGTH PIC S9(4) BINARY VALUE 120.
          05 ALLOC-TEXT   PIC X(120).

       01  IRXJCL                            PIC X(6)  VALUE 'IRXJCL'.

      * The block of data below can be used for submitting pkg shipments
      * Prepared for both foreground and batch executions
       01  PKG-SHIPMENT-PARMS-IRXJCL.
         02  PKG-SHIPMENT-PARMS-IRXJCL-TOP.
           03 PARM-LENGTH          PIC X(2) VALUE X'0253'.
           03 REXX-NAME            PIC X(8) VALUE 'PKGESHIP'.
           03 FILLER               PIC X(1) VALUE SPACE .
         02  PKG-SHIPMENT-PARMS.
           03 REXX-SHIP-PACKAGE    PIC X(16) .
           03 FILLER               PIC X(1) VALUE SPACE .
           03 REXX-SHIP-ENV        PIC X(08) .
           03 FILLER               PIC X(1) VALUE SPACE .
           03 REXX-SHIP-STGID      PIC X(01) .
           03 FILLER               PIC X(1) VALUE SPACE .
           03 REXX-SHIP-COMMENT    PIC X(50) .
           03 REXX-SHIP-CREATE-USR PIC X(08) .
           03 REXX-SHIP-UPDATE-USR PIC X(08) .
           03 REXX-SHIP-CAST-USER  PIC X(08) .
           03 FILLER               PIC X(1) VALUE SPACE .
           03 REXX-SHIP-NOTE1      PIC X(60) .
           03 REXX-SHIP-NOTE2      PIC X(60) .
           03 REXX-SHIP-NOTE3      PIC X(60) .
           03 REXX-SHIP-NOTE4      PIC X(60) .
           03 REXX-SHIP-NOTE5      PIC X(60) .
           03 REXX-SHIP-NOTE6      PIC X(60) .
           03 REXX-SHIP-NOTE7      PIC X(60) .
           03 REXX-SHIP-NOTE8      PIC X(60) .
           03 REXX-SHIP-OUT        PIC X(03) .

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

*********  IF PECB-USER-BATCH-JOBNAME(1:7) = ME
*********  DISPLAY 'C1UEXSHP: GOT INTO EXIT 7' .

           IF  SETUP-EXIT-OPTIONS
*********    to support automated package shipping
               MOVE 'Y'   TO PECB-AFTER-EXEC
*********      MOVE 'Y'   TO PECB-REQ-ELEMENT-ACTION-BIBO
*********      MOVE 'Y'   TO PECB-BEFORE-BACKIN
*********      MOVE 'Y'   TO PECB-BEFORE-BACKOUT
*********      MOVE 'Y'   TO PECB-AFTER-EXEC
*********      MOVE 'Y'   TO PECB-AFTER-BACKOUT
*********      MOVE 'Y'   TO PECB-AFTER-BACKIN
*********    to enforce package backout = Y
               MOVE 'Y'   TO PECB-BEFORE-CAST
               MOVE 'Y'   TO PECB-MID-CAST
               MOVE 'Y'   TO PECB-AFTER-CAST
               MOVE 'Y'   TO PECB-BEFORE-CREATE-BLD
               MOVE 'Y'   TO PECB-BEFORE-CREATE-COPY
               MOVE 'Y'   TO PECB-BEFORE-CREATE-EDIT
               MOVE 'Y'   TO PECB-BEFORE-CREATE-IMPT
               MOVE 'Y'   TO PECB-BEFORE-MOD-BLD
               MOVE 'Y'   TO PECB-BEFORE-MOD-CPY
               MOVE 'Y'   TO PECB-BEFORE-MOD-EDIT
               MOVE 'Y'   TO PECB-BEFORE-MOD-IMPT
               MOVE ZEROS TO RETURN-CODE
               GO TO 100-MAIN-EXIT.

           MOVE 0 TO PECB-NDVR-EXIT-RC.

**   *******====---> SUBMIT PACKAGE SHIPMENT JOBS
           IF (EXECUTE-PACKAGE AND
              PHDR-PACKAGE-STATUS = 'EXECUTED')
           OR (BACK-OUT-PACKAGE AND PECB-AFTER )
           OR (BACK-IN-PACKAGE AND PECB-AFTER )
                 PERFORM 800-SUBMIT-PACKAGE-SHIPMENTS
           ELSE
           IF PREQ-BACKOUT-ENABLED NOT = 'Y'
              MOVE 'Y' TO PREQ-BACKOUT-ENABLED
              MOVE 4 TO PECB-NDVR-EXIT-RC
              MOVE 'Y' TO PECB-MODS-MADE-TO-PREQ
              DISPLAY 'C1UEXSHP: Package Backout is Enforced'
           END-IF.
**   ******.......................  <<<<

       100-MAIN-EXIT.

           GOBACK.

       800-SUBMIT-PACKAGE-SHIPMENTS.

      *    MAKES A CALL TO THE REXX ROUTINE PKGESHIP
      *    THE REXX ROUTINE PKGESHIP SUBMITS PACKAGE SHIPMENT JOBS

      *    Package Shipments may occur in batch only
      *    As a result of package Executions, Backouts and Backins

******     IF PECB-USER-BATCH-JOBNAME(1:7) = ME
******         DISPLAY 'C1UEXSHP: SHIPPING PACKAGE '
******                 PECB-PACKAGE-ID
******         DISPLAY 'C1UEXSHP: PHDR-PKG-ENV  ' PHDR-PKG-ENV
******         DISPLAY 'C1UEXSHP: PHDR-PKG-STGID' PHDR-PKG-STGID
******     END-IF

           PERFORM 2100-ALLOCATE-REXFILE.

           MOVE PECB-PACKAGE-ID      TO REXX-SHIP-PACKAGE
           MOVE PHDR-PKG-ENV         TO REXX-SHIP-ENV
           MOVE PHDR-PKG-STGID       TO REXX-SHIP-STGID
           MOVE PREQ-PACKAGE-COMMENT TO REXX-SHIP-COMMENT
           MOVE PHDR-PKG-CREATE-USER TO REXX-SHIP-CREATE-USR
           MOVE PHDR-PKG-UPDATE-USER TO REXX-SHIP-UPDATE-USR
           MOVE PHDR-PKG-CAST-USER   TO REXX-SHIP-CAST-USER
           MOVE PHDR-PKG-NOTE1       TO REXX-SHIP-NOTE1
           MOVE PHDR-PKG-NOTE2       TO REXX-SHIP-NOTE2
           MOVE PHDR-PKG-NOTE3       TO REXX-SHIP-NOTE3
           MOVE PHDR-PKG-NOTE4       TO REXX-SHIP-NOTE4
           MOVE PHDR-PKG-NOTE5       TO REXX-SHIP-NOTE5
           MOVE PHDR-PKG-NOTE6       TO REXX-SHIP-NOTE6
           MOVE PHDR-PKG-NOTE7       TO REXX-SHIP-NOTE7
           MOVE PHDR-PKG-NOTE8       TO REXX-SHIP-NOTE8
           IF BACK-OUT-PACKAGE
           MOVE 'BAC'                TO REXX-SHIP-OUT
           ELSE
           MOVE 'OUT'                TO REXX-SHIP-OUT  .

           CALL IRXJCL  USING PKG-SHIPMENT-PARMS-IRXJCL.

           MOVE 0           TO RETURN-CODE
           .

       2100-ALLOCATE-REXFILE.

           MOVE SPACES TO ALLOC-TEXT .
           STRING 'ALLOC DD(SYSEXEC) ',
              'DA(SYSMD32.NDVR.TEAM.REXX)  SHR REUSE'
                  DELIMITED BY SIZE
             INTO ALLOC-TEXT
           END-STRING.
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

********** MOVE 'CONCAT DDLIST(REXFILE,REXFILE2)'
**********   TO ALLOC-TEXT .
**********
********** PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

136600*****************************************************************
136600**  DYNAMICALLY DE-ALLOCATE UNNEEDED REXX FILES
136600*****************************************************************
       2200-FREE-REXFILES.

           MOVE SPACES              TO ALLOC-TEXT .
           MOVE 'FREE  DD(SYSEXEC)' TO ALLOC-TEXT .
           PERFORM 9000-DYNAMIC-ALLOC-DEALLOC .

136600*****************************************************************
136600**  CALL BPXWDYN TO PREFORM REQUIRED REXX FUNCTIONS
136600*****************************************************************
136700 9000-DYNAMIC-ALLOC-DEALLOC.
136800
136900     CALL BPXWDYN USING ALLOC-STRING
137000
137100     IF RETURN-CODE NOT = ZERO
137200         DISPLAY 'C1UEXSHP: ALLOCATION FAILED: RETURN CODE = '
137200                 RETURN-CODE
137300         DISPLAY ALLOC-TEXT
137600     END-IF

           MOVE SPACES TO ALLOC-TEXT
137700     .
