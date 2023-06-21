 /* REXX   */
   'ISREDIT MACRO ' ;

   ADDRESS ISREDIT;
 /*                                                                 */
 /*    You must change the contents of QEX                          */
 /*        according to the comments below to point to potential    */
 /*        library names where input components can be found.       */
 /*                                                                 */
 /*    Expand Copy members, included members, DCLGENS , PROCs...    */
 /*                                                                 */
 /*    See various examples for assigning lists of library names    */
 /*    to INCLUDE_LIBRARY_LIST                                      */
 /*                                                                 */
 /*    See the Get_COPY_library_name_list section, where you can    */
 /*    use the varaiables provided by Quick-Edit for                */
 /*    ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI                     */
 /*    to build a list of library names in INCLUDE_LIBRARY_LIST     */
 /*                                                                 */
 /*    If QEX is allocated to anything, show additional outputs.    */
 
   CALL BPXWDYN "INFO FI(QEX)   INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then DoTrace = 'Y'

   Use_Long_Name_Search = 'N'  ;  /* Suppport 9 or 10 char names? */
   LP = 1   ;                     /* Line position is 1           */
   CP = 1   ;                     /* Char position is 1           */

   ADDRESS ISPEXEC  "CONTROL ERRORS RETURN" ;
   X = OUTTRAP(LINE.);

   ADDRESS ISPEXEC
            'VGET (RANGE) SHARED'

   /* Determine whether we are in Edit or View  */
   ADDRESS ISREDIT "(EDITVIEW,TMP) = SESSION"
   x = EDITVIEW

   IF EDITVIEW = "EDIT" then,
      Do
      ADDRESS ISPEXEC
            'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN
                   ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN
                   ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN)
             PROFILE'
      End
   /* If in View, then we have to get Env,Sys,Sub etc from banner */
   ELSE,
      Call Get_Endevor_Classification ;

   ADDRESS ISREDIT 'HILIGHT ON'

   IF EDITVIEW = "EDIT" &,
      RC > 0 THEN EXIT ;

   IF RANGE = 'ALL' THEN,
      ADDRESS ISREDIT 'RESET'

   SA=  ENVBENV ENVBSYS ENVBSBS  ENVBTYP;
   SA=  ENVBENV ENVSSYS ENVSSBS  ENVSTYP;

  /*                                                                 */
  /*  APPLICATION CUSTOMIZATIONS HERE                                */
  /*     are required for ENHANCED mode only.....                    */
  /*                                                                 */
  /*        If wanting to use Enhanced mode, you must assign a       */
  /*           list of libraries to search in the variable           */
  /*           INCLUDE_LIBRARY_LIST. Example code is shown below.    */
  /*                                                                 */
  /*        Use the variables from Quick Edit                        */
  /*          ENVBENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVELM        */
  /*                 as                                              */
  /*          envrionment system subsystem type stage-id element     */
  /*        You may also change the value for SEARCH_STRING .        */
  /*          This variable contains the word that indicates that    */
  /*           an input component name follows. It defaults to       */
  /*           the value you would want for COBOL - "COPY", but you  */
  /*           may change it to whatever you want.                   */
  /*                                                                 */

  Call Get_COPY_library_name_list;

  ADDRESS ISREDIT  "(STRTLINE STRTCHAR)=CURSOR"


  If lastnode = 'COPYBOOK' then,
    SEARCH_WORDS = "COPY ++INCLUDE INCLUDE " ;
  If lastnode = 'PROC' then,
    SEARCH_WORDS = "PROC= ++INCLUDE EXEC   " ;
  IF RANGE = 'ALL' THEN,
     Do
       DO word# = 1 to words(SEARCH_WORDS)
          ADDRESS ISREDIT "CURSOR = 1 1 " ;
          SEARCH_STRING = WORD(SEARCH_WORDS,word#) ;
          Call Search_for_keyword ;
       END;
       ADDRESS ISREDIT "CURSOR = 1 1 " ;
       call Expand_Endevor_lib_Includes;
     end;
  ELSE,
     DO
     reference_expanded = "N" ;
     ADDRESS ISREDIT "CURSOR = "STRTLINE" 1 " ;
     ADDRESS ISREDIT  "(DATALINE)=LINE" STRTLINE
       DO WORD# = 1 TO WORDS(DATALINE)
          TEMP = WORD(DATALINE,WORD#) ;
          IF WORDPOS(TEMP,SEARCH_WORDS) > 0 THEN,
             do
             SEARCH_STRING = WORD(DATALINE,WORD#) ;
             Call Search_for_keyword;
             LEAVE ;
             end ; /* IF WORDPOS(TEMP..... */
       END; /* DO WORD# = 1 .....  */
  /*                                                                 */
  /*                                                                 */
  /*   IF SOME OF THE REFERENCES ARE FOR MEMBERS WITHIN AN ELIB      */
  /*   THEN INCLUDE THE CALL BELOW TOO.                              */
  /*                                                                 */
  /*   IF reference_expanded = "N" THEN,                             */
  /*      call Expand_Endevor_lib_Includes;                          */
  /*                                                                 */
     END;  /* DO */

  ADDRESS ISREDIT "CURSOR =" LP CP ;

  exit

Get_COPY_library_name_list:

   if DoTrace = 'Y' then Trace ?r

   INCLUDE_LIBRARY_LIST = ' ' ;

   SEARCH_STRING = 'COPY' ;
   IF ENVSTYP = 'PROCESS' | ENVBTYP = 'PROCESS' THEN,
      do
      SEARCH_STRING = '++INCLUDE' ;
      INCLUDE_LIBRARY_LIST =,
            'SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.INCLUDE',
            'SYSDE32.NDVR.ADMIN.ENDEVOR.ADM2.INCLUDE'
      end;

   If ENVBTYP = 'JCL' | ENVBTYP = 'JOB' then lastnode = 'PROC'
   ELSE                                      lastnode = 'COPYBOOK'

   /* Looking at the DEV Environment  ?   */
   IF ENVBENV = 'DEV' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSDE32.NDVR.'ENVBENV'.'ENVBSYS'.'ENVBSBS'.'lastnode,
            'SYSDE32.NDVR.QAS.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.PRD.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.SHARED.PROD.'lastnode
   Else,
   IF ENVBENV = 'QAS' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSDE32.NDVR.QAS'.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.PRD'.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.SHARED.PROD.'lastnode

  return ;

Search_for_keyword:

   if DoTrace = 'Y' then Trace ?r

   DO FOREVER ;
      ADDRESS ISREDIT  "FIND '"SEARCH_STRING"' .ZCSR .ZCSR " ;
      IF RC > 0 THEN LEAVE  ;
      ADDRESS ISREDIT  "(LP CP)=CURSOR"
      ADDRESS ISREDIT  "(DATALINE)=LINE" LP
      SA= "DATALINE = " DATALINE ;
      PLACE = WORDPOS(SEARCH_STRING,DATALINE) ;
      PLACE = PLACE + 1;

      IF PLACE <= WORDS(DATALINE) THEN,
         DO
         INCLNAME = WORD(DATALINE,PLACE) ;
         If Substr(INCLNAME,1,5) = 'PROC=' then,
            INCLNAME = Substr(INCLNAME,6)
         INCLNAME = STRIP(INCLNAME,T,'.');
         INCLNAME = STRIP(INCLNAME,T,';');
         INCLNAME = STRIP(INCLNAME);
         IF DATATYPE(SUBSTR(INCLNAME,1,1)) = "NUM" THEN LEAVE ;
/*                                                                    */
         CALL EXPAND_INCLUDE ;
         END ;
      IF RANGE = 'NEXT' THEN,
         DO
         ADDRESS ISREDIT  "CURSOR = "STRTLINE STRTCHAR ;
         LEAVE ;
         END;
      ADDRESS ISREDIT  "FIND P'=' 01 NEXT" ;
   END ; /* DO FOREVER */

  return ;

EXPAND_INCLUDE :
   If Use_Long_Name_Search = 'Y' then,
      DO
      call Expand_Endevor_lib_Includes;
      Return ;
      END
   Else,
      call Search_library_list ;
   if result > 0 then,
      DO
      call Expand_Endevor_lib_Includes;
      Return ;
      END

   ADDRESS TSO,
      "ALLOC F(INCLLIB)",
         " DA('"FROMDSN"') SHR REUSE " ;
   SA= PARM ;
   SA= INCLNAME ;
   ADDRESS TSO "EXECIO * DISKR INCLLIB (STEM ENDEVOR. FINIS" ;
   IF RC > 0 | ENDEVOR.0 = 0 THEN ITERATE ;

   WHERE = 'LINE_AFTER' ;

   IF RANGE = 'ALL' THEN,
      'ISREDIT ' WHERE '.ZCSR = NOTELINE "'COPIES("<",72)'"' ;

   reference_expanded = "Y" ;
   IF RANGE = "ALL" THEN sa= "EXPANDING " INCLNAME ;
   DO I = ENDEVOR.0 TO 1 BY -1
      IF EDITVIEW = 'VIEW' THEN,
         ENDEVOR.I = COPIES(' ',09) || ENDEVOR.I
      SPECIAL_CHAR = '&' ; /* AMPERSAND */
      POSITION  = POS(SPECIAL_CHAR,ENDEVOR.I) ;
      ENDEVOR.I = TRANSLATE(ENDEVOR.I,"'",'"') ;
      IF POSITION > 0 THEN CALL HANDLE_SPECIAL_CHARACTER;

      IF RANGE = 'ALL' THEN,
         'ISREDIT ' WHERE '.ZCSR = DATALINE "'ENDEVOR.I'"' ;
      ELSE,
         'ISREDIT ' WHERE '.ZCSR = NOTELINE "'ENDEVOR.I'"' ;
   END ; /* DO I = 1 TO ENDEVOR.0*/
   INTROLINE = "       FROM:" FROMDSN ;
   'ISREDIT LINE_AFTER  .ZCSR = NOTELINE "'INTROLINE'"' ;

   RETURN;

HANDLE_SPECIAL_CHARACTER:
   DO FOREVER ;
      NEW_STRING = SUBSTR(ENDEVOR.I,1,POSITION) ||,
                   SPECIAL_CHAR || SPECIAL_CHAR || SPECIAL_CHAR ||,
                   SUBSTR(ENDEVOR.I,(POSITION+1)) ;
      ENDEVOR.I = NEW_STRING ;
      POSITION = POS(SPECIAL_CHAR,ENDEVOR.I,(POSITION+4));
      IF POSITION = 0 THEN LEAVE ;
   END ; /* DO FOREVER */

   RETURN;

Search_library_list:

   if DoTrace = 'Y' then Trace ?r

   sa = INCLUDE_LIBRARY_LIST  ;
   X = OUTTRAP(LINE.);

   DO LIB = 1 TO WORDS(INCLUDE_LIBRARY_LIST) ;
      FROMDSN = WORD(INCLUDE_LIBRARY_LIST,LIB) ||,
                "("INCLNAME")" ;
      IF SYSDSN("'"FROMDSN"'") = 'OK' THEN RETURN(0) ;
   END ;

   RETURN(1) ;

Expand_Endevor_lib_Includes:
/*                                                                 */
   SELTYPE = 'INCLUDE' ;
   IF RANGE = 'NEXT' THEN ,
      ADDRESS ISREDIT "CURSOR = "STRTLINE 1 ;
   ELSE,
      ADDRESS ISREDIT "CURSOR = 1 1 " ;

   DO FOREVER ;
      IF EDITVIEW = "EDIT" then,
         ADDRESS ISREDIT  "FIND ++INCLUDE 8 " ;
      Else,
         ADDRESS ISREDIT  "FIND ++INCLUDE 21" ;
      IF RC > 0 THEN LEAVE  ;
      ADDRESS ISREDIT  "(LP CP)=CURSOR"
      ADDRESS ISREDIT  "(DATALINE)=LINE" LP
      PLACE = WORDPOS('++INCLUDE',DATALINE) ;
      PLACE = PLACE + 1;

      IF PLACE <= WORDS(DATALINE) THEN,
         DO
         INCLNAME = WORD(DATALINE,PLACE) ;
/*                                                                    */
         CALL EXPAND_ELIB_INCLUDE ;
         END ;
      IF RANGE = 'NEXT' THEN LEAVE ;
   END ; /* DO FOREVER */

   ADDRESS ISREDIT  "CURSOR = "STRTLINE STRTCHAR ;

   return ;

 EXPAND_ELIB_INCLUDE :
   IF USERID() = "$WALDER" THEN NOP ;

   ADDRESS TSO,
      "ALLOC F(SYSIN) LRECL(80)",
            "BLKSIZE(1600) SPACE(1,1)",
            "RECFM(F B) TRACKS DSORG(PS) ",
            "NEW UNCATALOG REUSE "     ;

   SYSIN_DATA.1= "AACTL MSGFILE ELEMLIST" ;
   SYSIN_DATA.2 = COPIES(" ",80);
   SYSIN_DATA.2 = OVERLAY("ALELM FA",SYSIN_DATA.2,01) ;
   SYSIN_DATA.2 = OVERLAY(ENVBENV,SYSIN_DATA.2,10) ; /*ENVIRONMENT*/
/* SYSIN_DATA.2 = OVERLAY(ENVBSTGI,SYSIN_DATA.2,18) ;    STAGE ID */
   SYSIN_DATA.2 = OVERLAY("*",SYSIN_DATA.2,18) ; /* STAGE ID */
   SYSIN_DATA.2 = OVERLAY("*",SYSIN_DATA.2,19) ; /* SYSTEM */
/* SYSIN_DATA.2 = OVERLAY(ENVBSBS,SYSIN_DATA.2,27) ;    SUBSYSTEM */
   SYSIN_DATA.2 = OVERLAY('*',SYSIN_DATA.2,27) ; /* SUBSYSTEM */
   SYSIN_DATA.2 = OVERLAY(INCLNAME,SYSIN_DATA.2,35) ; /* ELM NAME */
   SYSIN_DATA.2 = OVERLAY("INCLUDE",SYSIN_DATA.2,45) ; /* TYPE */
   SYSIN_DATA.2 = OVERLAY("PROCINCL",SYSIN_DATA.2,45) ; /* TYPE */
   SYSIN_DATA.3= "RUN " ;
   SYSIN_DATA.4= "AACTLY " ;
   SYSIN_DATA.5= "RUN " ;
   SYSIN_DATA.6= "QUIT " ;
   SYSIN_DATA.0= 6;
   ADDRESS TSO "EXECIO * DISKW SYSIN ( STEM SYSIN_DATA. FINIS" ;

   IF USERID() = '$XXXXXR' THEN,
      DO
      ADDRESS TSO "ALLOC F(SYSOUT) DA(*) REUSE"
      ADDRESS TSO "ALLOC F(BSTERR) DA(*) REUSE"
      ADDRESS TSO "ALLOC F(BSTAPI) DA(*) REUSE"
      ADDRESS TSO "ALLOC F(SYSPRINT) DA(*) REUSE"
      END;
   ELSE,
      DO
      ADDRESS TSO "ALLOC F(SYSOUT) DUMMY REUSE"
      ADDRESS TSO "ALLOC F(BSTERR) DUMMY REUSE"
      ADDRESS TSO "ALLOC F(BSTAPI) DUMMY REUSE"
      ADDRESS TSO "ALLOC F(SYSPRINT) DUMMY REUSE"
      END;

   ADDRESS TSO,
      "ALLOC F(MSGFILE) LRECL(133)",
            "BLKSIZE(13300) SPACE(10,10)",
            "RECFM(F B) TRACKS DSORG(PS) ",
            "NEW UNCATALOG REUSE "     ;

   ADDRESS TSO,
      "ALLOC F(ELEMLIST) LRECL(2048)",
            "BLKSIZE(0) SPACE(10,10)",
            "RECFM(F B) TRACKS DSORG(PS) ",
            "NEW UNCATALOG REUSE "     ;


   IF USERID() = "$WALDER" THEN NOP
   X = OUTTRAP(LINE.);
/* ADDRESS ISPEXEC "SELECT PGM(ENTBJAPI)"  */
   ADDRESS LINK    "ENTBJAPI"
   if rc > 0 then return;

   IF USERID() = "$WALDER" THEN NOP

   ADDRESS TSO "EXECIO * DISKR ELEMLIST ( STEM ALELM_DATA. FINIS" ;
   CNT = ALELM_DATA.0 ;
   IF CNT > 1 THEN,
      ALELM_DATA.1 = ALELM_DATA.CNT ;

   C1ENVMNT = SUBSTR(ALELM_DATA.1,15,08) ;
     C1ENVMNT = STRIP(C1ENVMNT) ;
   C1STGID  = SUBSTR(ALELM_DATA.1,65,01) ;
   C1SYSTEM = SUBSTR(ALELM_DATA.1,23,08) ;
     C1SYSTEM = STRIP(C1SYSTEM) ;
   C1SUBSYS = SUBSTR(ALELM_DATA.1,31,08) ;
     C1SUBSYS = STRIP(C1SUBSYS)
   FromLocation = C1ENVMNT'/'C1STGID'/'C1SYSTEM'/'C1SUBSYS'/'INCLNAME

   ADDRESS TSO "FREE F(SYSIN) " ;
   ADDRESS TSO "FREE F(ELEMLIST) ";

   ADDRESS TSO,
      "ALLOC F(SYSIN) LRECL(80)",
            "BLKSIZE(1600) SPACE(1,1)",
            "RECFM(F B) TRACKS DSORG(PS) ",
            "NEW UNCATALOG REUSE "     ;

   ADDRESS TSO,
      "ALLOC F(ELEMLIST) LRECL(2048)",
            "BLKSIZE(0) SPACE(10,10)",
            "RECFM(F B) TRACKS DSORG(PS) ",
            "NEW UNCATALOG REUSE "     ;

   SYSIN_DATA.1= "AACTL MSGFILE ELEMLIST" ;
   SYSIN_DATA.2 = COPIES(" ",80);
   SYSIN_DATA.2 = OVERLAY("AEELMBE",SYSIN_DATA.2,01) ;
   SYSIN_DATA.2 = OVERLAY(C1ENVMNT,SYSIN_DATA.2,10) ; /*ENVIRONMENT*/
   SYSIN_DATA.2 = OVERLAY(C1STGID,SYSIN_DATA.2,18) ; /* STAGE ID */
   SYSIN_DATA.2 = OVERLAY(C1SYSTEM,SYSIN_DATA.2,19) ; /* SYSTEM */
   SYSIN_DATA.2 = OVERLAY(C1SUBSYS,SYSIN_DATA.2,27) ; /* SUBSYSTEM */
   SYSIN_DATA.2 = OVERLAY(INCLNAME,SYSIN_DATA.2,35) ; /* ELM NAME */
   SYSIN_DATA.2 = OVERLAY("INCLUDE",SYSIN_DATA.2,45) ; /* TYPE */
   SYSIN_DATA.2 = OVERLAY("PROCINCL",SYSIN_DATA.2,45) ; /* TYPE */
   SYSIN_DATA.3= "RUN " ;
   SYSIN_DATA.4= "AACTLY " ;
   SYSIN_DATA.5= "RUN " ;
   SYSIN_DATA.6= "QUIT " ;
   SYSIN_DATA.0= 6;
   ADDRESS TSO "EXECIO * DISKW SYSIN ( STEM SYSIN_DATA. FINIS" ;

   X = OUTTRAP(LINE.);
/* ADDRESS ISPEXEC "SELECT PGM(ENTBJAPI)"  */
   ADDRESS LINK    "ENTBJAPI"
   if rc > 0 then return;

   ADDRESS TSO "EXECIO * DISKR ELEMLIST ( STEM ENDEVOR. FINIS" ;

   WHERE = 'LINE_AFTER' ;

   /*
   IF RANGE = 'ALL' THEN,
      ADDRESS ISREDIT  "FIND P'=' 1 NEXT";
   */

   reference_expanded = "Y" ;
   IF RANGE = "ALL" THEN sa= "EXPANDING " INCLNAME ;
   DO I = ENDEVOR.0 TO 1 BY -1
      if substr(ENDEVOR.i,74,1) /= "+" then iterate ;
      ENDEVOR.I = TRANSLATE(substr(ENDEVOR.I,85,80),"'",'"') ;
      IF EDITVIEW = 'VIEW' THEN,
         ENDEVOR.I = COPIES(' ',13) || ENDEVOR.I

      SPECIAL_CHAR = '&' ; /* AMPERSAND */
      POSITION  = POS(SPECIAL_CHAR,ENDEVOR.I) ;
      IF POSITION > 0 THEN CALL HANDLE_SPECIAL_CHARACTER;

      IF RANGE = 'ALL' THEN,
         'ISREDIT ' WHERE '.ZCSR = DATALINE "'ENDEVOR.I'"' ;
      ELSE,
         'ISREDIT ' WHERE '.ZCSR = NOTELINE "'ENDEVOR.I'"' ;
   END ; /* DO I = 1 TO ENDEVOR.0*/

   INTROLINE = "       FROM:" FromLocation
   'ISREDIT LINE_AFTER  .ZCSR = NOTELINE "'INTROLINE'"' ;

   RETURN;

Get_Endevor_Classification:


   /*  Save line pointed to by user  */
   ADDRESS ISREDIT "(STRTLINE STRTCHAR)=CURSOR"

   /*  Find Endevor banner info      */
   ADDRESS ISREDIT "CURSOR = 1 1 " ;
   ADDRESS ISREDIT "FIND 'ENVIRONMENT:' FIRST "
   ADDRESS ISREDIT  "(ENVLINE ENVCHAR)=CURSOR"
   ADDRESS ISREDIT  "(DATALINE)=LINE" ENVLINE
   tmp = Substr(DATALINE,ENVCHAR) ;
   ENVBENV     = Word(tmp,02) ;
   ENVSENV     = Word(tmp,02) ;
   ENVBSYS     = Word(tmp,04) ;
   ENVSSYS     = Word(tmp,04) ;
   ENVBSBS     = Word(tmp,06) ;
   ENVSSBS     = Word(tmp,06) ;

   ADDRESS ISREDIT "FIND 'ELEMENT:' "
   ADDRESS ISREDIT  "(ELELINE ELECHAR)=CURSOR"
   ADDRESS ISREDIT  "(DATALINE)=LINE" ELELINE
   tmp = Substr(DATALINE,ELECHAR) ;
   ENVELMV     = Word(tmp,02) ;
   ENVBTYP     = Word(tmp,04) ;
   ENVSTYP     = Word(tmp,04) ;
   ENVBSTGI    = Word(tmp,07) ;
   ENVSSTGI    = Word(tmp,07) ;

   /*  Return cursor to place where user pointed*/
   ADDRESS ISREDIT "CURSOR = "STRTLINE STRTCHAR

   /*  FREE Working libraries */
   ADDRESS TSO "FREE  F(ELEMLIST) "
   ADDRESS TSO "FREE  F(SYSIN)    "
   ADDRESS TSO "FREE  F(MSGFILE)  "
   ADDRESS TSO "FREE  F(BSTAPI)   "
   ADDRESS TSO "FREE  F(BSTERR)   "

   RETURN;
