/* REXX                                                              */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  (C) 2002 COMPUTER ASSOCIATES INTERNATIONAL, INC.                 */
/*                                                                   */
/* NAME: ENDIEIM1                                                    */
/*                                                                   */
/* PURPOSE: THIS IS A SAMPLE REXX EXEC THAT IS GIVEN CONTROL WHEN    */
/*  THE EDIT ELEMENT DIALOG USER SELECTS THE EDIT OR CREATE DIALOG   */
/*  OPTION.  THE EXEC CAN BE USED TO PERFORM ANY EDIT SESSION SET-UP */
/*  STEPS THAT THE USER MAY REQUIRE.  EXAMPLES INCLUDE SETTING THE   */
/*  CAPS ATTRIBUTE, DEFINING ADDITIONAL EDIT MACROS OR WRITING       */
/*  MESSAGES.                                                        */
/*                                                                   */
/*   NOTE: ENDIEIM1 CAN ALSO BE WRITTEN AS A CLIST.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
/* UNCOMMENT THIS STATEMENT TO ENABLE THE REXX TRACE FACILITY.       */
/*-------------------------------------------------------------------*/
/*TRACE ALL                                  ENABLE REXX TRACE       */

/*-------------------------------------------------------------------*/
/* FIRST, RETRIEVE THE DIALOG VARIABLES FROM THE PROFILE POOL.       */
/* NOTE: UNCOMMENT THIS CODE TO ACTIVATE THE VGET REQUEST.           */
/*-------------------------------------------------------------------*/
  TRACE  O

  ADDRESS ISPEXEC
            'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN
                   ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN
                   ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN)
             PROFILE'

/*-------------------------------------------------------------------*/
/* USE THE BASE ELEMENT TYPE NAME TO DETERMINE THE APPROPRIATE EDIT  */
/* PROFILE TO BE USED WITH THE SESSION.                              */
/* NOTE: THIS IS ONLY AN EXAMPLE.  THE CODE WILL HAVE TO BE MODIFIED */
/* TO MAP THE INSTALLATIONS ELEMENT TYPE NAMES TO THE APPROPRIATE    */
/* EDIT PROFILES.                                                    */
/*-------------------------------------------------------------------*/
/*IF (ENVBTYP = COBOL) THEN             /* IF A COBOL PROGRAM    */  */
/*  ADDRESS ISREDIT 'PROFILE COBOL 0'                                */
/*                                                                   */
/*IF (ENVBTYP = ISRCE) THEN             /* IF A CLIST/REXX EXEC  */  */
/*  ADDRESS ISREDIT 'PROFILE CLIST 0'                                */
/*                                                                   */

/*  Use LINE to determine whether/not CReating a new element         */
/*      LINE=0 if new                                                */
    "ISREDIT (LINE) = CURSOR"

/*  If type is SANDBTRG, and the last 4 chars are not numeric         */
/*     consider the SANDBTRG element as an DEPLOY target sandbox.     */
/*     Related resources are optionally entered.                     */
    IF SUBSTR(ENVBTYP,1,8) = 'SANDBTRG' then,
       DO
/*  Turn off numbering and turn on Hilite                            */
       ADDRESS ISREDIT 'NUMBER NOSTD'
       ADDRESS ISREDIT 'HILIGHT ON'
       MY_RC = 0

/*  Use LINE to determine whether/not CReating a new element         */
/*      LINE=0 if new                                                */
       "ISREDIT (LINE) = CURSOR"

       SBS_5#8 = Substr(ENVELM,5,4) ;
       "ISREDIT CAPS OFF "
       note.1 = "* Use the MD (Make Dataline) command to convert"
       note.2 = "  any of these NOTE lines into a line of source."
       note.3 = "                     "
       note.4 = "  BatchLoadlibrary = <name-of-Batch-Loadlibrary>"
       note.5 = "  CicsLoadlibrary  = <name-of-CICS-Loadlibrary>"
       note.6 = "  DB2Subsys        = <name-of-DB2-Subsystem>"
       note.7 = "  CicsRegion       = <name-of-CICS-Region>"
       note.8 = "  DBRMLibrary      = <name-of-DBRM-Library>"
       note.9 = "                     "
       IF LINE > 0 THEN,
          Do no# = 1 to 9
             "ISREDIT LINE_BEFORE .ZF = NOTELINE '"note.no#"'" ;
          End
       Else,
          Do no# = 9 to 1 by -1
             "ISREDIT LINE_AFTER .ZF = NOTELINE '"note.no#"'" ;
          End
       EXIT
       END; /* IF SUBSTR(ENVBTYP,1,8) = 'SANDBTRG' */

    IF SUBSTR(ENVBTYP,1,3) = "JCL" &,
       LINE > 0 THEN,
         DO
         ADDRESS ISREDIT "EJCK"  ;
         EXIT
         END;

    ADDRESS ISREDIT 'HILIGHT ON'

    "ISREDIT (LINE) = CURSOR"
    IF LINE > 0 THEN,      /* Use PDA or PDNF3 or BC1PPDNR */
       ADDRESS ISREDIT 'PDA'

EXIT 0
