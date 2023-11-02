   /* REXX                                                              */
/*-------------------------------------------------------------------*/
/*                                                                   */
/*  (C) 2002 COMPUTER ASSOCIATES INTERNATIONAL, INC.                 */
/*                                                                   */
/* NAME- ENDIEIM1                                                    */
/*                                                                   */
/* PURPOSE- THIS IS A SAMPLE REXX EXEC THAT IS GIVEN CONTROL WHEN    */
/*  THE EDIT ELEMENT DIALOG USER SELECTS THE EDIT OR CREATE DIALOG   */
/*  OPTION.  THE EXEC CAN BE USED TO PERFORM ANY EDIT SESSION SET-UP */
/*  STEPS THAT THE USER MAY REQUIRE.  EXAMPLES INCLUDE SETTING THE   */
/*  CAPS ATTRIBUTE, DEFINING ADDITIONAL EDIT MACROS OR WRITING       */
/*  MESSAGES.                                                        */
/*                                                                   */
/*   NOTE- ENDIEIM1 CAN ALSO BE WRITTEN AS A CLIST.                  */
/*                                                                   */
/*-------------------------------------------------------------------*/
/*-------------------------------------------------------------------*/
/* UNCOMMENT THIS STATEMENT TO ENABLE THE REXX TRACE FACILITY.       */
/*-------------------------------------------------------------------*/
/*TRACE ALL                                  ENABLE REXX TRACE       */

/*-------------------------------------------------------------------*/
/* FIRST, RETRIEVE THE DIALOG VARIABLES FROM THE PROFILE POOL.       */
/* NOTE- UNCOMMENT THIS CODE TO ACTIVATE THE VGET REQUEST.           */
/*-------------------------------------------------------------------*/
  TRACE  O

  ADDRESS ISPEXEC
            'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN
                   ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN
                   ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN)
             PROFILE'

/* Variables should be stored in the shared pool, not the profile    */
/* pool.  There's only one profile pool, shared by all screens.      */
/* Dialogs can get the wrong value when split screens (or the same   */
/* userid on multiple LPARs) is used.                                */
  en$benv = envbenv
  en$bsys = envbsys
  en$bsbs = envbsbs
  en$btyp = envbtyp
  en$bstgi = envbstgi
  en$bstgn = envbstgn
  en$senv = envsenv
  en$ssys = envssys
  en$ssbs = envssbs
  en$styp = envstyp
  en$sstgi = envsstgi
  en$sstgn = envsstgn
  en$elm = envelm
  en$prgrp = envprgrp
  en$ccid = envccid
  en$com = envcom
  en$gene = envgene
  en$osign = envosign

  ADDRESS ISPEXEC
            'VPUT (EN$BENV EN$BSYS EN$BSBS EN$BTYP EN$BSTGI EN$BSTGN
                   EN$SENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$SSTGN
                   EN$ELM  EN$PRGRP EN$CCID EN$COM EN$GENE EN$OSIGN)
             SHARED'

EXIT 0