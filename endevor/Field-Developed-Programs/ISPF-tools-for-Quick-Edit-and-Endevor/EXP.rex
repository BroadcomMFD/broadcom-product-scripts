 /* REXX   */
   'ISREDIT MACRO ' ;

   ADDRESS ISREDIT;
 /*                                                                 */
 /*    You must change the contents of EXP                          */
 /*        according to the comments below to point to potential    */
 /*        library names where input components can be found.       */
 /*                                                                 */
 /*    See various examples for assigning lists of library names    */
 /*    to INCLUDE_LIBRARY_LIST                                      */
 /*                                                                 */
 /*    See the Get_COPY_library_name_list section, where you can    */
 /*    use the varaiables provided by Quick-Edit for                */
 /*    ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI                     */
 /*    to build a list of library names in INCLUDE_LIBRARY_LIST     */
 /*                                                                 */
   CALL BPXWDYN "INFO FI(EXP) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then DoTrace = 'Y'

   Use_Long_Name_Search = 'N'  ;  /* Suppport 9 or 10 char names? */
   LP = 1   ;                     /* Line position is 1           */
   CP = 1   ;                     /* Char position is 1           */

   ADDRESS ISPEXEC  "CONTROL ERRORS RETURN" ;
   X = OUTTRAP(LINE.);

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
    SEARCH_WORDS = "COPY ++INCLUDE -INC INCLUDE " ;
  If lastnode = 'PROC' then,
    SEARCH_WORDS = "PROC= ++INCLUDE -INC EXEC   " ;
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
            'SYSDE32.NDVR.QAS.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.PRD.'ENVBSYS'.ACCTPAY.'lastnode,
            'SYSDE32.NDVR.SHARED.PROD.'lastnode
   Else,
   IF ENVBENV = 'PRD' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSDE32.NDVR.PRD.'ENVBSYS'.ACCTPAY.'lastnode,
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
         CALL EXPAND_INCLUDE ;
         END ;
/*                                                                    */
      ADDRESS ISREDIT  "CURSOR = "STRTLINE STRTCHAR ;
      LEAVE ;
   END ; /* DO FOREVER */

  return ;

EXPAND_INCLUDE :
   call Search_library_list ;
   if result > 0 then Return;

   ADDRESS TSO,
      "ALLOC F(INCLLIB)",
         " DA('"FROMDSN"') SHR REUSE " ;
   SA= PARM ;
   SA= INCLNAME ;
   ADDRESS TSO "EXECIO * DISKR INCLLIB (STEM ENDEVOR. FINIS" ;
   ADDRESS TSO "FREE  F(INCLLIB)"
   IF ENDEVOR.0 = 0 THEN ITERATE ;

   WHERE = 'LINE_AFTER' ;

   reference_expanded = "Y" ;
   DO I = ENDEVOR.0 TO 1 BY -1
      IF EDITVIEW = 'VIEW' THEN,
         ENDEVOR.I = COPIES(' ',09) || ENDEVOR.I
      SPECIAL_CHAR = '&' ; /* AMPERSAND */
      POSITION  = POS(SPECIAL_CHAR,ENDEVOR.I) ;
      ENDEVOR.I = TRANSLATE(ENDEVOR.I,"'",'"') ;
      IF POSITION > 0 THEN CALL HANDLE_SPECIAL_CHARACTER;
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

Get_Endevor_Classification:


   /*  Save line pointed to by user  */
   ADDRESS ISREDIT "(STRTLINE STRTCHAR)=CURSOR"

   /*  Find Endevor banner info      */
   ADDRESS ISREDIT "CURSOR = 1 1 " ;
   ADDRESS ISREDIT "FIND '**    ENVIRONMENT:' First "
   ADDRESS ISREDIT  "(ENVLINE ENVCHAR)=CURSOR"
   ADDRESS ISREDIT  "(DATALINE)=LINE" ENVLINE
   tmp = DATALINE
   If Words(tmp) < 7 then exit
   ENVBENV     = Word(tmp,03) ;
   ENVSENV     = Word(tmp,03) ;
   ENVBSYS     = Word(tmp,05) ;
   ENVSSYS     = Word(tmp,05) ;
   ENVBSBS     = Word(tmp,07) ;
   ENVSSBS     = Word(tmp,07) ;

   ADDRESS ISREDIT "FIND '**    TYPE:       ' "
   ADDRESS ISREDIT  "(TYPLINE ELECHAR)=CURSOR"
   ADDRESS ISREDIT  "(DATALINE)=LINE" TYPLINE
   tmp = DATALINE
   If Words(tmp) < 6 then exit
   ENVBTYP     = Word(tmp,03) ;
   ENVSTYP     = Word(tmp,03) ;
   ENVBSTGI    = Word(tmp,06) ;
   ENVSSTGI    = Word(tmp,06) ;

   ADDRESS ISREDIT "FIND '**    ELEMENT:       '"
   ADDRESS ISREDIT  "(ELELINE ELECHAR)=CURSOR"
   ADDRESS ISREDIT  "(DATALINE)=LINE" ELELINE
   tmp = DATALINE
   If Words(tmp) < 3 then exit
   ENVELMV     = Word(tmp,03) ;

   /*  Return cursor to place where user pointed*/
   ADDRESS ISREDIT "CURSOR = "STRTLINE STRTCHAR

   /*  FREE Working libraries */
   ADDRESS TSO "FREE  F(ELEMLIST) "
   ADDRESS TSO "FREE  F(SYSIN)    "
   ADDRESS TSO "FREE  F(MSGFILE)  "
   ADDRESS TSO "FREE  F(BSTAPI)   "
   ADDRESS TSO "FREE  F(BSTERR)   "

   RETURN;
