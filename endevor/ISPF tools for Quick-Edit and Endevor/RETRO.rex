 /* REXX   */
 /*THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED. */

/*                                                                   */
/* Retro performs a Code merger for one element using PDM            */
/* It is initiated by referencing one of the messages presented by   */
/* the PDA (Parallel Development Alert) facility.                    */
/* Messages show other Endevor locations for the element being edited*/
/* If the user wants to merger changes from one of the other versions*/
/* into the element being edited, then the user invokes RETRO.       */
/*                                                                   */
/* To invoke RETRO, the user must be viewing the PDA mesages, enters */
/* the word 'RETRO' onto the command line, and uses the cursor       */
/* to point to the message for a seleceted element.                  */
/* Changes made in the selected element are then broght into the     */
/* edited element, using PDM.                                        */
/*                                                                   */
/* Automated oversight of the PDM execution is performed by RETRO:   */
/*  1) the PDM Root, Deverivation #1 and Derivation #2 are made      */
/*  2) If no changed/deleted lines are made by Derivation #2         */
/*     a 'Clean' message is given to imply no merge is necessary     */
/*  3) The user is given the option to view the PDM Wip file         */
/*  4) The user is given the option to view the PDM Merged results   */
/*  5) The user is given the option to update the edited element     */
/*     with the merged results                                       */
/*  6) If the selected element is up the map from the edited element,*/
/*     the user is given the option to resolve a potential           */
/*     SYNC error condition with a batch job submission.             */
/*     The job will perform TRANSFER commands to clear the SYNC error*/
/*                                                                   */
/*  See the options for RETRO for determining the element name       */
/*  to be used temporarily for resolving the SYNC error condition.   */
/*                                                                   */
/*                                                                   */
   'ISREDIT MACRO ' ;
   TRACE o  ;
   WhatDDName = 'RETRO'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) = ' ' then Sa= WhatDDName 'Not allocated'
   Else Trace ?r ;

   ADDRESS ISREDIT;
/*                                                                   */
/* Variable settings for each site --->           */
   WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
   interpret 'Call' WhereIam "'RetroTempName'"
   RetroTempName = Result
/* <---- Variable settings for each site          */
/*                                                                   */
/* RETRO_DSN_PRFX = "PUBLIC.RETROFIT" ;                              */
   RETRO_DSN_PRFX = USERID()".RETROFIT" ;

/*                                                                   */
/*  Find what the cursor is pointing to....                          */
/*                                                                   */
   ADDRESS ISPEXEC,
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"

   Strt    = zscreenc // 80 ;
   Strt    = zscreenc - Strt + 8;
   Their_line = substr(zscreeni,Strt,72);
   TUSERID   = Word(Their_line,1) ;
   TCCID     = Substr(Their_line,11,12);

   Part_line = substr(Their_line,23);
   Part_line = substr(Their_line,25);


  ADDRESS ISPEXEC
            'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN
                   ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN
                   ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN)
             PROFILE'
/*                                                                   */
/*  'My' element is the one being edited...                          */
/*                                                                   */

   MELEMENT           = ENVELM
   MELTYPE            = ENVSTYP
   MUSERID            = USERID()
   MENVMNT            = ENVSENV
   MSTGID             = ENVSSTGI
   MSYSTEM            = ENVSSYS
   MSUBSYS            = ENVSSBS
   MCCID              = ENVCCID
/*                                                                   */
/*  Find the 'Selected' element for the PDM code merge ...           */
/*                                                                   */
   TENVMNT   = WORD(PART_LINE,1) ;
   TSTGID    = Word(Part_line,2) ;
   TSYSTEM   = Word(Part_line,3) ;
   TSUBSYS   = Word(Part_line,4) ;
   TELTYPE   = ENVSTYP ;
   TELEMENT  = ENVELM
   ELEMENT   = TELEMENT;

/*-------------------------------------------------------------------*/
/*- Invoke a PDM exeuction from the PDNF2 message                   -*/
/*-------------------------------------------------------------------*/
   X = OUTTRAP(LINE.);
   X = MSG(OFF)
    mdisp = SYSVAR("SOLDISP")        /* Save current message set */

   ADDRESS TSO,
    "CONSPROF SOLDISPLAY(NO)"        /* Inhibit message displays */

   ADDRESS ISPEXEC "VGET (ZAPPLID) ASIS"
   IF ZAPPLID /= 'CTLI' THEN EXIT

   X = OUTTRAP(LINE.);

/*                                                                   */
/* HIGH-LEVEL CONTROL VALUES .....                                   */
/*                                                                   */
/*     RETRO_DSN_PRFX - MUST MATCH VALUE ASSIGNED                    */
/*         TO RETRO_DSN_PRFX IN RETROFT3. THESE ARE THE DATASETS     */
/*         THAT RETROFIT WILL ALLOCATE FOR SAVING COPIES OF SOURCE,  */
/*         DELTAS, UPDATED-SOURCE, ETC.                              */
/* Note: Dataset name will be formed as userid.RETROFIT. The         */
/* userid value is determined by the TSO PREFIX variable. If this    */
/* variable is set to nulls at your site, you must add a HLQ such as */
/* PUBLIC below.                                                     */
/*                                                                   */

/*                                                                   */
/*  Give message if cursor is placed onto an invalid line            */
/*                                                                   */
   IF WORDS(THEIR_LINE) < 6 THEN,
      DO
      MSG1 = "You must place your cursor on another "
      MSG2 = "line. This line is invalid.           "
      MSG3 = "                                      "
      MSG4 = "                                      "
      MSG5 = "     (Enter, END or PF3)          "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      EXIT
      END; /* IF THEIR_CP = 0 THEN */

/*                                                                   */
/*  Give message if cursor is placed onto an invalid line            */
/*                                                                   */
   IF THEIRCP = 0 THEN,
      DO
      MSG1 = "You must place your cursor on one of  "
      MSG2 = "the msgs related to another element   "
      MSG3 = "before invoking RETROFIT.             "
      MSG4 = "                                      "
      MSG5 = "     (Enter, END or PF3)          "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      EXIT
      END; /* IF THEIR_CP = 0 THEN */


/*                                                                   */
/*  If the 'Selected' element is 'My' element.... invalid            */
/*                                                                   */
   If MENVMNT = TENVMNT &,
      MSTGID  = TSTGID  &,
      MSYSTEM = TSYSTEM &,
      MSUBSYS = TSUBSYS THEN,
      DO
      MSG1 = "The PDM derivation locations are the  "
      MSG2 = "same. This line is invalid.           "
      MSG3 = "                                      "
      MSG4 = "                                      "
      MSG5 = "     (Enter, END or PF3)          "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      EXIT
      END; /* IF THEIR_CP = 0 THEN */
/*                                                                    */
/*  Save any changes made within Edit session                        */
/*                                                                   */
   ADDRESS ISREDIT "SAVE"

/*                                                                   */
/* Establish default PDM ROOT AND DV1 AND DV2 SELECTIONS              */
/* 'My' element and 'Selected' element are derivations                */
/* ROOT for PDM will be the base level of the 'Selected' element      */
/*                                                                    */
   ADDRESS ISPEXEC "VGET (RENVMNT RSYSTEM RSUBSYS RSTGID) PROFILE "
   If MSYSTEM = TSYSTEM then RSYSTEM = MSYSTEM ;
   If MSUBSYS = TSUBSYS then RSUBSYS = MSUBSYS ;
/*                                                                    */
/* Use API to search for 'My' and 'Selected' locations.               */
/*                                                                    */
   SA= "CALL CSV_to_Search_Current_Locations"
   CALL CSV_to_Search_Current_Locations;
/*                                                                    */
/* Show PDM Root and DV1 and DV2 Selections made...                   */
/*                                                                    */
   ADDRESS ISPEXEC " SETMSG MSG(RETR010I) "
   ADDRESS ISPEXEC " DISPLAY PANEL(RETRSHOW) "
   if rc > 0 then exit ;
   UPPER RENVMNT RSTGID RSYSTEM RSUBSYS ;
   ADDRESS ISPEXEC "VPUT (RENVMNT RSYSTEM RSUBSYS RSTGID) PROFILE "

   SA= "CALL DetermineUniqueMemberName "
   CALL DetermineUniqueMemberName; /* COPIED FROM RETROFT1 */
   SA= "CALL ALLOCATE_LIBRARIES_FOR_PDM     "
   CALL ALLOCATE_LIBRARIES_FOR_PDM;

/*                                                                    */
/* Execute PDM to Build Wip file                                      */
/*                                                                    */
   SA= "CALL BUILD_PDMWIP                   "
   CALL BUILD_PDMWIP;
   IF BUILD_PDMWIP_RC < 4 THEN,
      DO
      /* If all is well, do PDM merge      */
      SA= "CALL RUN_PDMMERGE                   "
      CALL RUN_PDMMERGE;
      SA= "CALL Replace_Source_And_Gen         "
      /* If OK with user, update  'My' (edited) element */
      CALL Replace_Source_And_Gen;
/*    CALL Replace_Element_Source_with_Transfers;   */
      END;

Shutdown:
   STOPNAG    = 'N'
   ADDRESS ISPEXEC "VPUT (STOPNAG) PROFILE "

   CALL DELETE_INITIAL_LIBRARIES ;

   EXIT 0

DetermineUniqueMemberName:
   /*                                           */
   /* Use Date and Time to build a unique       */
   /*     member name                           */
   /*                                           */
   NUMBERS    = '123456789' ;
   CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;
   TODAY = DATE(O) ;

   YEAR = SUBSTR(TODAY,1,2) + 1;
   YEAR = SUBSTR(CHARACTERS||CHARACTERS||CHARACTERS||CHARACTERS,YEAR,1)

   MONTH = SUBSTR(TODAY,4,2) ;
   MONTH = SUBSTR(CHARACTERS,MONTH,1) ;

   DAY = SUBSTR(TODAY,7,2) ;
   DAY = SUBSTR(CHARACTERS || NUMBERS,DAY,1) ;

   NOW  = TIME() ;

   HOUR = SUBSTR(NOW,1,2) ;
   IF HOUR = '00' THEN HOUR = '0'
   ELSE
   HOUR = SUBSTR(CHARACTERS,HOUR,1) ;

   MINUTE = SUBSTR(NOW,4,2) ;

   SECOND = SUBSTR(NOW,7,2) ;

   DO FOREVER
      RETROFIT_MEMBER = YEAR || MONTH || DAY || HOUR ||,
         MINUTE || SECOND ;
      TESTDSN = "'"RETRODSN"("RETROFIT_MEMBER")'" ;
      IF SYSDSN(TESTDSN) /= 'OK' THEN LEAVE ;
      SECOND = SECOND + 1;
      END; /* DO FOREVER */

   SA= "RETROFIT MEMBER NAME IS " RETROFIT_MEMBER
   RETURN ;

CSV_to_Search_Current_Locations:
   /*                                           */
   /* Use a built-in Endevor CSV program        */
   /*     to find 'My' and 'Selected' elements. */
   /*                                           */

   SA= "GETTING CURRENT LOCATIONS FROM ENDEVOR" ;
    ADDRESS TSO "ALLOC FI(C1MSGS1)  DUMMY SHR REUSE"
/*  ADDRESS TSO "ALLOC FI(C1MSGS1)  DA(*) SHR REUSE"  */
   ADDRESS TSO;
/* 'ALLOC F(SYSOUT)   DUMMY SHR REUSE '  */
/* 'ALLOC F(SYSPRINT) DUMMY SHR REUSE '  */
/* 'ALLOC F(SYSTSPRT) DUMMY SHR REUSE '  */
/*                                       */
/*  ADDRESS TSO "ALLOC FI(C1MSGS2)  DUMMY SHR REUSE" */
/* 'ALLOC F(BSTERR)   DUMMY SHR REUSE '                       */
/* 'ALLOC F(BSTAPI)   DUMMY SHR REUSE '                       */
/* 'ALLOC F(MSGEFILE) LRECL(133) BLKSIZE(13300) SPACE(5,5) ', */
/*   'RECFM(F B) TRACKS NEW UNCATALOG REUSE ' ;               */


   'ALLOC F(EXTRACTM) LRECL(2048) BLKSIZE(22800) SPACE(5,5) ',
     'RECFM(V B) TRACKS NEW UNCATALOG REUSE ' ;
   'ALLOC F(EXTRACTT) LRECL(2048) BLKSIZE(22800) SPACE(5,5) ',
     'RECFM(V B) TRACKS NEW UNCATALOG REUSE ' ;
   'ALLOC F(EXTRATYP) LRECL(0800) BLKSIZE(08000) SPACE(1,1) ',
     'RECFM(V B) TRACKS NEW UNCATALOG REUSE ' ;

   "ALLOC FI(BSTIPT01) BLKSIZE(0) TRACKS LRECL(80) SPACE(5 5)",
       "RECFM(F B) NEW REUSE UNCATALOG" ;

   QUEUE "LIST ELEMENT " ELEMENT
   QUEUE "     FROM ENVIRONMENT " MENVMNT,
                  " SYSTEM " MSYSTEM,
                  " SUBSYSTEM " MSUBSYS ;
   QUEUE "          TYPE " MELTYPE ;
   QUEUE "          STAGE "MSTGID ;
   QUEUE "     TO DDNAME 'EXTRACTM' "
   QUEUE "     OPTIONS   SEARCH NOCSV RETURN ALL ."

   QUEUE "LIST ELEMENT " ELEMENT
   QUEUE "     FROM ENVIRONMENT " TENVMNT,
                  " SYSTEM " TSYSTEM,
                  " SUBSYSTEM " TSUBSYS ;
   QUEUE "          TYPE " TELTYPE ;
   QUEUE "          STAGE "TSTGID ;
   QUEUE "     TO DDNAME 'EXTRACTT' "
   QUEUE "     OPTIONS NOSEARCH NOCSV RETURN ALL ."

   QUEUE "LIST TYPE" MELTYPE
   QUEUE "     FROM ENVIRONMENT " MENVMNT " STAGE" MSTGID
   QUEUE "          SYSTEM " MSYSTEM
   QUEUE "     TO DDNAME 'EXTRATYP' "
   QUEUE "     OPTIONS NOSEARCH NOCSV RETURN FIRST ."

   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";

/*
   ADDRESS ISPEXEC,
     "SELECT PGM(BC1PCSV0) "
*/
   ndvrprm = 'DDN:CONLIB,BC1PCSV0'
   ADDRESS LINKMVS 'CONCALL' 'ndvrprm'

   call_rc = rc ;

   IF call_rc  > 0 THEN,
      DO
      SAY "THE SEARCH FOR CURRENT LOCATIONS FAILED"
      EXIT
      END; /* IF PROD < 2 THEN  */

   "EXECIO 1 DISKR EXTRATYP (STEM ALTYP. FINIS ";
   ALTYP_RS_SLEN = Substr(ALTYP.1,185,5) ;
   MyLrecl       = ALTYP_RS_SLEN

   "EXECIO * DISKR EXTRACTT (STEM ALELM. FINIS ";

   ALELM_RS_ELM_VV   = Substr(ALELM.1,103,2) ;
   DV2VER  =  ALELM_RS_ELM_VV ;
   BASEVV  =  ALELM_RS_ELM_VV ;

   ALELM_RS_EBAS_LVL = Substr(ALELM.1,242,2) ;
   BASELL  = ALELM_RS_EBAS_LVL;

   ALELM_RS_ELM_LL   = Substr(ALELM.1,105,2) ;
   DV2LVL = ALELM_RS_ELM_LL  ;

   If TENVMNT /= SUBSTR(ALELM.1,015,8) |,
      TSYSTEM /= SUBSTR(ALELM.1,023,8) |,
      TSUBSYS /= SUBSTR(ALELM.1,031,8) |,
      TSTGID  /= SUBSTR(ALELM.1,065,1) THEN,
      do
      MSG1 = "The 'other' users element was not found"
      MSG2 = "at the location specified on the Para- "
      MSG3 = "llel Development Alert Panel.  The PDNF"
      MSG4 = "VSAM file may need to be rebuilt to be "
      MSG6 = "in synch with your environment. Please "
      MSG7 = "contact your Endevor Administrator.    "
      MSG5 = "     (Enter, END or PF3)          "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      exit   ;
      end;


/*                                                                    */
/* Examing CSV output built from 'My' element location with SEARCH    */
/*                                                                    */

   DROP ALELM.  ;
   "EXECIO * DISKR EXTRACTM (STEM ALELM. FINIS ";

   If MENVMNT /= SUBSTR(ALELM.1,015,8) |,
      MSYSTEM /= SUBSTR(ALELM.1,023,8) |,
      MSUBSYS /= SUBSTR(ALELM.1,031,8) |,
      MSTGID  /= SUBSTR(ALELM.1,065,1) THEN,
      Do
      MSG1 = "'Your' element was not found at the    "
      MSG2 = "location specified on the PDA panel.   "
      MSG3 = "Refresh your Quick-Edit element list   "
      MSG4 = "and attempt the RETRO action again.    "
      MSG5 = "     (Enter, END or PF3)          "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      exit   ;
      End;

/*                                                                   */
/*  The ROOT element is the 'Selected' element.                      */
/*  The version/level for ROOT will be the lowest number there.      */
/*                                                                   */
   RENVMNT = TENVMNT ;
   RSYSTEM = TSYSTEM ;
   RSUBSYS = TSUBSYS ;
   RSTGID  = TSTGID  ;

   "FREE FI(BSTIPT01)" ;
   "FREE FI(EXTRATYP)" ;
   "FREE FI(EXTRACTM)" ;
   "FREE FI(EXTRACTT)" ;
   "FREE FI(MSGEFILE)" ;

/*                                                                   */
/*  Search the list of elements found in the search for 'My'         */
/*  element. If the 'Selected' element is found (up the map),        */
/*  then we may have a potential SYNC error.                         */
/*                                                                   */
   Call DetermineWhetherSelectedIsUpTheMap ;

   RETURN;

DetermineWhetherSelectedIsUpTheMap:

/*                                                                    */
/* Is the referenced element is up the map from the edited element?   */
/*                                                                    */
   PossibleSyncError = 'N'    /* Assume 'N' until found differently */
/* Theirs is the 'Selected' element                                   */
   Theirs = Strip(TENVMNT)"." || ,
            Strip(TSYSTEM)"." || ,
            Strip(TSUBSYS)"." || ,
            Strip(TSTGID);

/* Read thru the API output for edited  element which includes        */
/*      'Search'ed locations                                          */
   DO R# = 1 TO ALELM.0
      temp = Strip(SUBSTR(ALELM.R#,015,8))"." || ,
             Strip(SUBSTR(ALELM.R#,023,8))"." || ,
             Strip(SUBSTR(ALELM.R#,031,8))"." || ,
             Strip(SUBSTR(ALELM.R#,065,1));
      /* If 'Selected' is up the map from 'My' element */
      /* then Possible Sync Error.                     */
      If temp = Theirs then,
         PossibleSyncError = 'Y'
   END; /* DO R# = 2 ALELM.0 */

   DROP ALELM.  ;

   RETURN;

ALLOCATE_LIBRARIES_FOR_PDM:
/*                                                                    */
/* Allocate libraries for a PDM execution                             */
/*                                                                    */

   PDMWIP_DSN = ,
      RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".PDMWIP" ;
   PDMSCL_DSN = ,
      RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".PDMSCL" ;
   PDMMERGE_DSN = ,
      RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".PDMMERGE" ;
   SCL_DSN = RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".SCL" ;

    ADDRESS TSO "ALLOC DA('"PDMWIP_DSN"')",
             "BLKSIZE(0) CYLINDERS ",
             "LRECL("MyLrecl+8") SPACE(5 5) RECFM(F B) DIR(45) ",
             "MOD CATALOG ";
    ADDRESS TSO "FREE  DA('"PDMWIP_DSN"')" ;

    ADDRESS TSO "ALLOC DA('"PDMSCL_DSN"')",
             "BLKSIZE(0) TRACKS    ",
             "LRECL(80) SPACE(5 5) RECFM(F B) DIR(45) ",
             "MOD CATALOG ";
    ADDRESS TSO "FREE  DA('"PDMSCL_DSN"')" ;

    ADDRESS TSO "ALLOC DA('"PDMMERGE_DSN"')",
             "BLKSIZE(0) CYLINDERS ",
             "LRECL("MyLrecl") SPACE(15 15) RECFM(F B) DIR(45) ",
             "MOD CATALOG ";
    ADDRESS TSO "FREE  DA('"PDMMERGE_DSN"')" ;

  /* SETUP ALLOCATES FOR API CALL  */
    ADDRESS TSO "ALLOC FI(SYSUDUMP) DUMMY SHR REUSE"
/*                                                                    */
/*  ADDRESS TSO "ALLOC FI(C1MSGS1)  DA(*) SHR REUSE"                  */
    ADDRESS TSO,
      "ALLOC F(C1MSGS1)",
          "LRECL(133) BLKSIZE(13300) SPACE(5,5)",
          "RECFM(V B) TRACKS ",
          "NEW UNCATALOG REUSE "     ;

/*  ADDRESS TSO "ALLOC FI(C1MSGS2)  DA(*) SHR REUSE"                  */
/*  ADDRESS TSO "ALLOC FI(C1MSGS1)  DUMMY SHR REUSE"                  */
/*  ADDRESS TSO "ALLOC FI(C1MSGS2)  DUMMY SHR REUSE"                  */
/*  ADDRESS TSO "ALLOC FI(C1MSGS1)  DUMMY SHR REUSE"                  */
    ADDRESS TSO "ALLOC FI(C1MSGS2)  DUMMY SHR REUSE"
    ADDRESS TSO "ALLOC FI(SYSOUT)   DUMMY SHR REUSE"
/*  ADDRESS TSO "ALLOC FI(SYSOUT)   DUMMY SHR REUSE"                  */

   RETURN ;

BUILD_PDMWIP:
/*                                                                   */
/*  Run PDM to build a WIP file                                      */
/*                                                                   */

   ADDRESS TSO ;
   "ALLOC FI(BATCHIN) LRECL(80) BLKSIZE(9000) SPACE(5,5) ",
     "RECFM(F B) TRACKS NEW UNCATALOG REUSE " ;

   QUEUE "BUILD WIP  DSNAME  '"PDMWIP_DSN"'"
   QUEUE "      ROOT ENVIRONMENT" RENVMNT,
         "SYSTEM" RSYSTEM "SUBSYSTEM" RSUBSYS ;
   QUEUE "           TYPE" TELTYPE "STAGE" RSTGID ;

   QUEUE "      DV1  ENVIRONMENT" MENVMNT,
         "SYSTEM" MSYSTEM "SUBSYSTEM" MSUBSYS ;
   QUEUE "           TYPE" MELTYPE "STAGE" MSTGID ;

   QUEUE "      DV2  ENVIRONMENT" TENVMNT,
         "SYSTEM" TSYSTEM "SUBSYSTEM" TSUBSYS ;
   QUEUE "           TYPE" TELTYPE "STAGE" TSTGID ;

   QUEUE "           REPLACE . "
   QUEUE "    WIP  '"TELEMENT"'" ;
   QUEUE "    ROOT '"TELEMENT"' VERSION" BASEVV "LEVEL" BASELL
   QUEUE "    DV1  '"TELEMENT"'" ;
   QUEUE "    DV2  '"TELEMENT"' ." ;

   ADDRESS TSO "EXECIO" QUEUED() "DISKW BATCHIN (FINIS";


/*                                                                   */
   ADDRESS ISPEXEC,
     "SELECT PGM(BC1G0000) "

   BUILD_PDMWIP_RC = RC ;
/*                                                                   */
   If BUILD_PDMWIP_RC > 7 then,
      Do
      Say "Showing results....."
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      want = 'N'
      MSG1 = "Want to continue  ? (Enter 'Y')       "
      MSG2 = "Want to exit      ? (Enter 'N')       "
      MSG3 = " "
      MSG4 = " "
      MSG5 = "(Y/N)            "
      ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
      ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
      ADDRESS ISPEXEC "REMPOP " ;
      IF want = 'N' then Exit
      End


   "FREE FI(BATCHIN)" ;
/*
*/

   "ALLOC FI(PDMWIP) DA('"PDMWIP_DSN"("TELEMENT")') SHR REUSE"

   "EXECIO 20 DISKR PDMWIP (STEM WIP. FINIS ";
   "FREE FI(PDMWIP)" ;

   TITLE           = WORD(WIP.20,4) ;
   CONFLICTS       = WORD(WIP.20,5) ;
   IF CONFLICTS > 0 THEN,
      DO
      MSG1= "Found Conflicts"
      BUILD_PDMWIP_RC = 4 ;
      END;
   ELSE,
      SA= "NO CONFLICTS"


   TEMP            = TRANSLATE(WIP.18,' ',',') ;
   DELETES_DV2     = WORD(TEMP,10);
   TEMP            = TRANSLATE(WIP.19,' ',',') ;
   INSERTS_DV2     = WORD(TEMP,10);
   IF DELETES_DV2 > 0 | INSERTS_DV2 > 0 THEN,
      DO
      WANT = 'N'
      MSG1= "There are changes in the other version you need to Merge" ;
      MSG2 = "Want to see WIPFILE (Y/N)             "
      MSG3 = "                                      "
      MSG4 = "                                      "
      MSG5 = "(Y/N)              "
      BUILD_PDMWIP_RC = 2 ;
      END;
   ELSE,
      DO
      WANT = ' '
      MSG1 = "YOU'RE CLEAN. No need to Merge" ;
      MSG2 = "                                      "
      MSG3 = "                                      "
      MSG4 = "                                      "
      MSG5 = "(Press Enter)      "
      BUILD_PDMWIP_RC = 0 ;
      END;

   DROP WIP. ;

   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

   IF BUILD_PDMWIP_RC = 0  THEN signal Shutdown ;
   IF want /= 'Y' & want /= 'y' THEN RETURN;

   ADDRESS ISPEXEC,
      "EDIT DATASET('"PDMWIP_DSN"("TELEMENT")') ",
            "MACRO(BC1GM100)"

   RETURN;


   PTBWPOTH = "'"PDMWIP_DSN"("TELEMENT")'" ;
   PTBRQOTH = "'"PDMSCL_DSN"'" ;

   VARWKCMD = '2' ;
   ADDRESS ISPEXEC,
      "VPUT (PTBWPOTH) PROFILE "
   ADDRESS ISPEXEC,
      "VPUT (PTBRQOTH) SHARED "
   ADDRESS ISPEXEC,
      "VPUT (VARWKCMD) PROFILE "
   ADDRESS LINK 'BC1G0000'   ;  /* load from authlib */

/* ADDRESS ISPEXEC,                                 */
/*   "SELECT PGM(BC1G0000) "                                         */
/*   "SELECT PGM(BC1G1000) NOCHECK NEWAPPL(CTLI) PASSLIB"            */
   RETURN;

RUN_PDMMERGE:
/*                                                                   */
/*  Run PDM to merge output                                          */
/*                                                                   */

   SA= "EXECUTING PDM - Merge     INTO" PDMMERGE_DSN ;

   ADDRESS TSO ;
   "ALLOC FI(BATCHIN) DA('"PDMSCL_DSN"(WIPMERGE)') SHR REUSE"

   QUEUE "MERGE WIP  DSNAME  '"PDMWIP_DSN"'"
   QUEUE "    OUTPUT DSNAME  '"PDMMERGE_DSN"'"
   QUEUE "           REPLACE "
   QUEUE "                      . "
   QUEUE "  OUTPUT '"TELEMENT"'"
   QUEUE "     WIP '"TELEMENT"'. "
   ADDRESS TSO "EXECIO" QUEUED() "DISKW BATCHIN (FINIS";

/*                                                                   */
   ADDRESS ISPEXEC,
     "SELECT PGM(BC1G0000) NEWAPPL(CTLI) PASSLIB"
/*   "SELECT PGM(BC1G0000)                                           */
/*   "SELECT PGM(NDVRC1) PARM(BC1G0000) NEWAPPL(CTLI) PASSLIB"       */

   "FREE FI(BATCHIN)" ;

   WANT = 'N'
   MSG1 = "Want to See Merge FILE (Y/N) ?"
   MSG2 = "                                      "
   MSG3 = "                                      "
   MSG4 = "                                      "
   MSG5 = "(Y/N)              "
   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

   IF want /= 'Y' & want /= 'y' THEN RETURN;

   ADDRESS ISPEXEC,
      "EDIT DATASET('"PDMMERGE_DSN"("TELEMENT")')" ;

   RETURN;

Replace_Source_And_Gen:
/*                                                                   */
/*  Run PDM to build a WIP file                                      */
/*                                                                   */

   WANT = 'Y'
   MSG1 = "Want to update your version of the    "
   MSG2 = "source with the merged one ?          "
   MSG3 = "                                      "
   MSG4 = "                                      "
   MSG5 = "(Y/N)              "
   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

   IF want /= 'Y' & want /= 'y' THEN RETURN;

   ADDRESS ISREDIT "RESET" ;
   ADDRESS ISREDIT "DELETE ALL NX" ;
   ADDRESS ISREDIT,
        " COPY '"PDMMERGE_DSN"("MELEMENT")'",
                   "AFTER  .ZLAST  " ;

   ADDRESS ISREDIT "SAVE"
   If PossibleSyncError /= 'Y' then Return;

   ADDRESS ISREDIT "CANCEL"
   WANT = " "
   MSG1 = "                                      " ;
   MSG2 = "Message from Endevor                  " ;
   MSG3 = "                                      " ;
   MSG4 = "          (just press enter)          " ;
   MSG5 = "                   "
   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

/*                                                               */
/* This code will attempt to resolve SYNCH errors....            */
/*      in batch                                                 */
/*                                                               */

   WANT = 'Y'
   MSG1 = "Want to resolve possible SYNC error   " ;
   MSG2 = "in batch (Y/N) ?                      " ;
   MSG3 = "                                      " ;
   MSG4 = "                                      " ;
   MSG5 = "(Y/N)              "
   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

   IF want /= 'Y' & want /= 'y' THEN RETURN;

   Call ResolvePossibleSYNCErrorInBatch ;

   RETURN;

ResolvePossibleSYNCErrorInBatch:
/*                                                               */
/* If user indicates 'Y', then prepare a job with two Endevor    */
/*    steps:                                                     */
/*    1) Transfer the element to another name                    */
/*    2) Transfer the other name back to the element name        */
/*                                                               */
/*    The other name is to be established by hi-level RETRO      */
/*    options                                                    */
/*                                                               */
   /* The value for the temporary element name is used here... */
   /* RETRO actions:                                           */
   /*  '1'   Use the original element name and '##' suffix.    */
   /*        You must support 10-char element names with this  */
   /*        option                                            */
   /* 'user' Use the userid of the person executing the RETRO  */
   /*        extended to 8 characters with the use of '#'      */
   /*'<name>'Use the designated name - one that is not used for*/
   /*        any real elements in the Endevor inventory.       */

   If RetroTempName = '1' then,
      tempElement  = MELEMENT"##"
   Else,
   If RetroTempName = 'user' then,
      tempElement  = Left(USERID(),8,'#') ;
   Else,
      tempElement  = RetroTempName

/* ADDRESS ISPEXEC "VGET (VNBRPRO VNBRGRP VNBRTYP) PROFILE " */
   SCL_DSN = ,
     RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".SCL1" ;
   ADDRESS TSO "ALLOC DA('"SCL_DSN"')",
            "BLKSIZE(0) TRACKS ",
            "LRECL(80) SPACE(15 15) RECFM(F B) ",
            "NEW CATALOG ";
   ADDRESS TSO "FREE  DA('"SCL_DSN"')" ;
   ADDRESS TSO "ALLOC DA('"SCL_DSN"') DD(MYSCL) SHR"

   queue " TRANSFER ELEMENT "MELEMENT
   queue "  FROM ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   queue "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE
   queue "      STAGE" MSTGID
   queue "  TO   ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   queue "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE
   queue "      STAGE" MSTGID
   queue "      ELEMENT "tempElement
   queue "  OPTIONS CCID '"MCCID"'"
   queue "   COMMENT 'Retrofitted with",
          TENVMNT"/"TSTGID"/"TSUBSYS"'"
   queue "*  Env="TENVMNT" Stg="TSTGID" Sys="TSYSTEM" Sub="TSUBSYS
   queue "    IGNORE BYPASS GENERATE PROCESSOR   "
   queue "           WITH HISTORY                "
   queue "*******    Do     ELEMENT  DELETE      "
   queue "    .                                  "

   ADDRESS TSO "EXECIO" QUEUED() "DISKW MYSCL (FINIS ";
   ADDRESS TSO "FREE  DD(MYSCL) " ;

   VNBDFDSN = SCL_DSN
   VNBINCF  = "Y"
   VNBDD01  = "//CLEANUP DD DISP=(SHR,DELETE,DELETE),"
   VNBDD02  = "//           DSN="SCL_DSN

   ADDRESS ISPEXEC "FTOPEN TEMP"

   ADDRESS ISPEXEC "FTINCL C1SB3000"

   Save_C1BJC1 = C1BJC1;   C1BJC1 = '' ;
   Save_C1BJC2 = C1BJC2;   C1BJC2 = '' ;
   Save_C1BJC3 = C1BJC3;   C1BJC3 = '' ;
   Save_C1BJC4 = C1BJC4;   C1BJC4 = '' ;

   SCL_DSN = ,
     RETRO_DSN_PRFX"."ELEMENT"."RETROFIT_MEMBER".SCL2" ;
   ADDRESS TSO "ALLOC DA('"SCL_DSN"')",
            "BLKSIZE(0) TRACKS ",
            "LRECL(80) SPACE(15 15) RECFM(F B) ",
            "NEW CATALOG ";
   ADDRESS TSO "FREE  DA('"SCL_DSN"')" ;
   ADDRESS TSO "ALLOC DA('"SCL_DSN"') DD(MYSCL) SHR"

   queue " TRANSFER ELEMENT "tempElement
   queue "  FROM ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   queue "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE
   queue "      STAGE" MSTGID
   queue "  TO   ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   queue "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE
   queue "      STAGE" MSTGID
   queue "      ELEMENT "MELEMENT
   queue "  OPTIONS CCID '"MCCID"'"
   queue "   COMMENT 'Retrofitted with",
          TENVMNT"/"TSTGID"/"TSUBSYS"'"
   queue "*  Env="TENVMNT" Stg="TSTGID" Sys="TSYSTEM" Sub="TSUBSYS
   queue "    IGNORE WITH HISTORY SYNCHRONIZE    "
   queue "    BYPASS DELETE PROCESSOR BYPASS GENERATE PROCESSOR "
   queue "*******    Do     ELEMENT  DELETE      "
   queue "    .                                  "

   ADDRESS TSO "EXECIO" QUEUED() "DISKW MYSCL (FINIS ";
   ADDRESS TSO "FREE  DD(MYSCL) " ;

   VNBDFDSN = SCL_DSN
   VNBINCF  = "Y"
   VNBDD01  = "//CLEANUP DD DISP=(SHR,DELETE,DELETE),"
   VNBDD02  = "//           DSN="SCL_DSN

   ADDRESS ISPEXEC "FTINCL C1SB3000"

   ADDRESS ISPEXEC "FTCLOSE " ;

   C1BJC1 = Save_C1BJC1
   C1BJC2 = Save_C1BJC2
   C1BJC3 = Save_C1BJC3
   C1BJC4 = Save_C1BJC4

   ADDRESS ISPEXEC "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;

   WANT = 'Y'
   MSG1 = "JCL will resolve SYNC and GENERATE:   "
   MSG2 = "Want to Submit JCL? (Enter 'Y')       "
   MSG3 = "Want to Edit   JCL? (Enter 'J')       "
   MSG4 = "Want to exit        (Enter 'N')       "
   MSG5 = "(J/Y/N)            "
   ADDRESS ISPEXEC " ADDPOP  ROW(3)  COLUMN(12)"
   ADDRESS ISPEXEC " DISPLAY PANEL(RETROPOP) "
   ADDRESS ISPEXEC "REMPOP " ;

   IF want = 'J' | want = 'j' THEN,
      DO
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(&ZTEMPN)"
      ADDRESS ISPEXEC "EDIT DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      END;

   IF want = 'Y' | want = 'y' THEN,
      Do
      X = OUTTRAP(submit.);
      ADDRESS TSO "SUBMIT '"ZTEMPF"'" ;
       Do s# = 1 to submit.0
          Say submit.s# ;
       End
      End;
   ELSE,
      ADDRESS TSO "DELETE '"SCL_DSN"'" ;

   IF LENGTH(C1BJC1)  > 10 THEN,
      ADDRESS ISPEXEC "SELECT CMD(%XLSLBUMP C1BJC1 PROFILE)"

   RETURN;

Replace_Element_Source_with_Transfers:


   ADDRESS ISREDIT " SAVE  "
   ADDRESS ISREDIT " CANCEL "

   MY_PARMS = COPIES(' ',720) ;      /*     80 * 9(LINES OF SCL) */
   TEMP1 = " TRANSFER ELEMENT "MELEMENT
   TEMP2 = "  FROM ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   TEMP3 = "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE "STAGE" MSTGID
   TEMP4 = "  TO   ENVIRONMENT "MENVMNT " SYSTEM "MSYSTEM
   TEMP5 = "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE "STAGE" MSTGID
   TEMP6 = "    ELEMENT '"MELEMENT"##'"
   TEMP6 = "    ELEMENT 'WALJO11'"
   TEMP7 = "  OPTIONS IGNORE BYPASS GENERATE PROCESSOR "
   TEMP8 = "                 BYPASS ELEMENT DELETE   . "
   TEMP9 = "  EOF.                                     "

   CALL Execute_API_SCL ;

   ADDRESS TSO "ISRDDN"

   RETURN;

Execute_API_SCL:

   MY_PARMS = OVERLAY(TEMP1,MY_PARMS,001) ;
   MY_PARMS = OVERLAY(TEMP2,MY_PARMS,081) ;
   MY_PARMS = OVERLAY(TEMP3,MY_PARMS,161) ;
   MY_PARMS = OVERLAY(TEMP4,MY_PARMS,241) ;
   MY_PARMS = OVERLAY(TEMP5,MY_PARMS,321) ;
   MY_PARMS = OVERLAY(TEMP6,MY_PARMS,401) ;
   MY_PARMS = OVERLAY(TEMP7,MY_PARMS,481) ;
   MY_PARMS = OVERLAY(TEMP8,MY_PARMS,561) ;
   MY_PARMS = OVERLAY(TEMP9,MY_PARMS,641) ;
   SA= my_parms ;

   ADDRESS TSO "ALLOC F(APIMSGS)  DA(*) REUSE"
   ADDRESS TSO "ALLOC F(APILIST)  DA(*) REUSE"
   ADDRESS TSO "FREE F(C1MSGS1)"
   ADDRESS TSO,
   "ALLOC F(C1MSGS1) LRECL(133) BLKSIZE(26600) SPACE(5,5) ",
    "DSORG(PS)",
     "RECFM(V B) TRACKS NEW UNCATALOG REUSE " ;
   ADDRESS TSO "ALLOC FI(SYSOUT)  DA(*) SHR REUSE"
   ADDRESS LINKMVS 'APIAESCL MY_PARMS'
   Temp_RC = RC ;
   if Temp_RC = 20 then,
      do
      ADDRESS LINKMVS 'APIAESCL' 'MY_PARMS'
      Temp_RC = RC ;
      end
   If Temp_RC > 4 THEN,
      Do
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      End;

   RETURN;


DELETE_INITIAL_LIBRARIES:

   X = OUTTRAP(XXXX.);
   ADDRESS TSO "DELETE '"PDMWIP_DSN"'" ;
   ADDRESS TSO "DELETE '"PDMSCL_DSN"'";
   ADDRESS TSO "DELETE '"PDMMERGE_DSN"'" ;

   RETURN;


