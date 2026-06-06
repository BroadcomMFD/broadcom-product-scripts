/*     REXX   */
/* Edit macro to examine members and determine an Endevor Type / Proc */
/* You can run in ISPF foreground for one member, or run in batch     */
/* for all or selected members of a Dataset.                          */
/*                                                                    */
/* Tailor the content to identify Endevor Types and Processor group   */
/* names used at your site.                                           */
   "ISREDIT MACRO (DOPUSH) " ;
/* When called with DOPUSH = Y, then the findings are expected        */
/* to be pushed back to the caller.                                   */
   ADDRESS ISREDIT " (MEMBER) = MEMBER " ;
   IF SYSVAR(SYSENV) = 'BACK' THEN,
      Say 'ANL#VIEW is called for' MEMBER
   MY_RC = 0
   /* Get the values from the table */
   TYPE   = ' '
   C1PRGRP = ' '
/*                                                                    */
   IF TYPE = ' ' THEN CALL REXX_CHECK;
   IF TYPE = ' ' THEN CALL COBOL_CHECK;
/*                                                                    */
   IF TYPE = ' ' THEN CALL BMS_CHECK ;
/* IF TYPE = ' ' THEN CALL MAPPEP_CHECK ;                             */
   IF TYPE = ' ' THEN CALL PL1_CHECK ;
   IF TYPE = ' ' THEN CALL ASM_CHECK ;
   IF TYPE = ' ' THEN CALL SAS_CHECK ;
   IF TYPE = ' ' THEN CALL ETRV_CHECK ;
   IF TYPE = ' ' THEN CALL COPY_CHECK ;
   IF TYPE = ' ' THEN CALL JCL_CHECK ;
   IF TYPE = ' ' THEN CALL BIND_CHECK ;
   IF TYPE = ' ' THEN CALL UNKNOWN_TYPE ;
/* CALL SAVE_TYPE;  */
   MY_RC = 0;
   IF SYSVAR(SYSENV) = 'BACK' THEN,
      DO
      ADDRESS ISREDIT " RESET  " ;
      ADDRESS ISREDIT " CANCEL " ;
      END
   EXIT
REXX_CHECK:
/* Is it REXX       ?                                                 */
   sa= MEMBER '@REXX_CHECK'
   ADDRESS ISREDIT "FIND ' REXX ' .ZF .ZF " ;
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'REXX'
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
ETRV_CHECK:
/* IS IT EASYTRIEVE ?                                                 */
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "EXCLUDE '*' 1 ALL" ;
   ADDRESS ISREDIT "FIND 'FILE ' FIRST 1    NX" ;
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'EZTRIEVE';
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
JCL_CHECK:
/* IS IT JCL/PROC   ?                                                 */
   sa= MEMBER '@JCL_CHECK'
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "FIND '//' 1 FIRST .ZF .ZF " ;
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'JCL';
      ADDRESS ISREDIT "FIND ' JOB ' FIRST " ;
      If RC > 0 then TYPE = 'PROC'
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
SAS_CHECK:
/* IS IT SAS        ?                                                 */
   sa= MEMBER '@SAS_CHECK'
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "FIND ' PROC ' FIRST" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND '%INCLUDE' FIRST" ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'SAS';
      ADDRESS ISREDIT "FIND '%INCLUDE' FIRST" ;
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
PL1_CHECK:
/* IS IT PL1   ?                                                    */
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "EXCLUDE '*' 1 ALL" ;
   ADDRESS ISREDIT "FIND ' DCL ' FIRST  NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'PROCESS ' 2 .ZF .ZF " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND '%INCLUDE ' FIRST  NX" ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' DECLARE ' FIRST  NX" ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'NOTE ' 1 FIRST  NX" ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'SOURCE';
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
MAPPEP_CHECK:
/* IS IT PEP+ MAP   ?                                                 */
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "EXCLUDE '*' 1 ALL" ;
   ADDRESS ISREDIT "FIND P'###### M' 1 ALL  " ;
   ADDRESS ISREDIT "FIND P'######*'  1 ALL  " ;
   ADDRESS ISREDIT "FIND P'='  1 X FIRST  " ;
   MY_RC = RC ;
   IF MY_RC /= 0 THEN,
      DO
      TYPE = 'MAPPEP';
      CALL SAVE_TYPE;
      MY_RC = 0;
      END;
   RETURN ;
COBOL_CHECK:
/* IS IT COBOL ?                                                      */
   ADDRESS ISREDIT "EXCLUDE '*' 7 ALL" ;
   ADDRESS ISREDIT "FIND 'IDENTIFICATION DIVISION' FIRST NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'ID DIVISION' FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'WORKING-STORAGE' FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'LINKAGE SECTION' FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'COBOL';
      C1PRGRP = 'BATCH'
      CALL DB2_CHECK ;
      CALL IMS_CHECK ;
      CALL CICS_CHECK ;
      CALL SAVE_TYPE;
      MY_RC = 0;
      END; /*COBOL */
   RETURN ;
DB2_CHECK:
   sa= MEMBER '@DB2_CHECK         '
   ADDRESS ISREDIT "EXCLUDE ALL" ;
   ADDRESS ISREDIT "FIND 'EXEC' WORD ALL";
   ADDRESS ISREDIT "FIND 'SQL' FIRST NX"
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      Do
      DB2 = 'DB2'
      C1PRGRP = CICPRGRP || 'DB2'
      End
   RETURN ;
CICS_CHECK:
   sa= MEMBER '@CICS_CHECK        '
   ADDRESS ISREDIT "EXCLUDE ALL" ;
   ADDRESS ISREDIT "FIND 'EXEC' WORD ALL";
   ADDRESS ISREDIT "FIND 'CICS' FIRST NX"
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      Do
      BAT#ONL = 'ONLINE'
      C1PRGRP = 'CICS#'
      End
   RETURN ;
/**********************************************************************/
IMS_CHECK:
   sa= MEMBER '@IMS_CHECK         '
/* Search for CBLTDLI */
   SearchCall = 'CBLTDLI'
   IF TYPE = 'ASMPGM' then
      SearchCall = 'ASMTDLI'
   ADDRESS ISREDIT "FIND '"SearchCall"' FIRST "
   MY_RC = RC
   IF MY_RC = 0 THEN
   DO
      IMS = 'IMS'
      C1PRGRP = CICPRGRP || 'IMS'
      RETURN
   END
/* Search for DLITCBL */
   SearchCall = 'DLITCBL'
   IF TYPE = 'ASMPGM' then
      SearchCall = 'DLITASM'
   ADDRESS ISREDIT "FIND '"SearchCall"' FIRST "
   MY_RC = RC
   IF MY_RC = 0 THEN
   DO
      IMS     = 'IMS'
      BAT#ONL = 'BATCH'
      C1PRGRP = Overlay('IMS',C1PRGRP,4)
      RETURN
   END
/* Search for ADATTR -  A Copybook in FEPD programs that calls IMS    */
   SearchCall = ' ADATTR'
   ADDRESS ISREDIT "FIND '"SearchCall"' FIRST "
   MY_RC = RC
   IF MY_RC = 0 THEN
      IMS     = 'IMS'
   RETURN
/**********************************************************************/
FORTRAN_CHECK:
   sa= MEMBER '@FORTRAN_CHECK     '
   ADDRESS ISREDIT "RESET"
/* IS IT FORTRAN ?                                                    */
   ADDRESS ISREDIT "EXCLUDE 'C' 1 ALL" ;
   ADDRESS ISREDIT "FIND 'DOUBLE PRECISION' FIRST NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'FORMAT (' FIRST NX" ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'FTN';
      CALL SAVE_TYPE;
      MY_RC = 0;
      END; /*COBOL */
   RETURN ;
BMS_CHECK:
/* IS IT BMS   ?                                                      */
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "EXCLUDE '*' 1 ALL" ;
   ADDRESS ISREDIT "FIND 'TYPE=MAP' FIRST NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'DFHMDF' WORD  FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'BMSMAP';
      C1PRGRP = 'BMSMAP'
      CALL SAVE_TYPE;
      MY_RC = 0;
      END; /*COBOL */
   RETURN ;
MAC_CHECK:
/* Is it an ASMPGMbler Macro?                                         */
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "EXCLUDE '*'    1 ALL"
   ADDRESS ISREDIT "FIND 'MACRO ' 10 FIRST NX"
   MY_RC = RC
   IF MY_RC = 0 THEN
   DO
      TYPE = 'MACRO'
      CALL SAVE_TYPE
      MY_RC = 0
   END
   RETURN
ASM_CHECK:
   sa= MEMBER '@ASM_CHECK         '
   ADDRESS ISREDIT "RESET"
/* IS IT ASM   ?                                                      */
   ADDRESS ISREDIT "EXCLUDE '*' 1 ALL" ;
   ADDRESS ISREDIT "FIND 'END ' 10 FIRST NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'CSECT' FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'DSECT' FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' DC '  FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' DS '  FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND 'TITLE ' 10 FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND P' ,' 71 FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'ASMPGM' ;
      CALL IMS_CHECK ;
      CALL SAVE_TYPE;
      MY_RC = 0;
      END; /*ASM   */
   RETURN ;
/**********************************************************************/
COPY_CHECK:
   sa= MEMBER '@COPY_CHECK        '
   ADDRESS ISREDIT "RESET"
/* IS IT A COPYBOOK ?                                                 */
   ADDRESS ISREDIT "EXCLUDE '*' 7 ALL" ;
   ADDRESS ISREDIT "FIND P' ## ' 7 12 FIRST NX" ;
   MY_RC = RC ;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' PIC ' 12 72 FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' MOVE ' 11 72 FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' WHEN ' 11 72 FIRST NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' PERFORM ' 11 72 FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' SELECT ' 11 72 FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' DISPLAY ' 11 72 FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ' PIC ' 11 72 FIRST WORD NX " ;
      MY_RC = RC ;
      END;
   IF MY_RC > 0 THEN,
      DO
      ADDRESS ISREDIT "FIND ',BOOK=P' 11 72 FIRST X " ;
      MY_RC = RC ;
      END;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'COPYBOOK';
      CALL SAVE_TYPE;
      MY_RC = 0;
      END; /*COBOL */
   RETURN ;
BIND_CHECK:
/* IS IT Bind cntl  ?                                                 */
   sa= MEMBER 'Bind_CHECK'
   ADDRESS ISREDIT "RESET"
   ADDRESS ISREDIT "FIND 'BIND' WORD 1 FIRST .ZF .ZF " ;
   MY_RC = RC ;
   IF MY_RC = 0 THEN,
      DO
      TYPE = 'BINDCNTL' ;
      CALL SAVE_TYPE;
      END;
   RETURN ;
UNKNOWN_TYPE:
/* DONT KNOW WHAT IT IS ....                                          */
   TYPE = 'SOURCE' ;
   CALL SAVE_TYPE;
   SA= MEMBER 'TYPE=' TYPE ;
   MY_RC = 1;
   RETURN ;
GET_SYSTEM:
  /* Default to System FINANCE */
  ELEMENT = MEMBER ;
  /* Example statements shown:                               */
  /* If the member name in position 1 (for len of 2) is 'C1'
        then make ENDEVOR the System Name                    */
  IF SUBSTR(ELEMENT,1,2) = 'C1' THEN SYSTEM = 'ENDEVOR'
  /* If the member name in position 1 (for len of 2) is 'AP'
        then make UTILITY the System Name                    */
  IF SUBSTR(ELEMENT,1,2) = 'AP' THEN SYSTEM = 'UTILITY'
  IF SYSTEM = ' ' then SYSTEM = 'FINANCE'
  IF SUBSYS = ' ' then SUBSYS = 'BASE'
  RETURN ;
SAVE_TYPE:
   If C1PRGRP = ' ' then C1PRGRP = TYPE
   SAY MEMBER 'ANL#VIEW Findings=' TYPE C1PRGRP
   IF SYSVAR(SYSENV) = 'BACK' | DOPUSH = 'Y' then,
      Push  TYPE C1PRGRP
   RETURN ;
