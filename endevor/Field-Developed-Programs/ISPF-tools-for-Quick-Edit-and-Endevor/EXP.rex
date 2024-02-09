/*     REXX - Edit Macro to Expand the COPYBOOK or INCLUDE member on
              the line that the cursor is currently positioned.

       Usage: EXP (help) (with cursor positoned on the line to expand)

              Depending on the element type, it will look for keywords
              like COPY, INCLUDE, PROC, -INC  etc. and then attempt
              to parse a member name (following that keyword). If
              found will search a set of libraries (defined by your
              administrator) to find and insert that member as
              INFOLINEs (denoted by '======' in the number/sequence
              column).

              You must code your own subroutine named EXP#LIBS, where
              based on the variables that provide the Endevor
              Classification details, you name the libraries to be
              searched, and the keywords to be used for them.
              See the examples EXP#LIBS and EXP#LIBS#example#2.
              See also the ENDIEIM1 for EXP.rex for minor updates
              necessary for your ENDIEIM1 member.

              Use the RESET command, to remove all expanded INFO and
              MSG lines.

              Note: INFOLINES can not be searched, but if necessary
              you can convert INFOLINES to regular data using the
              MDn or MDD...MDD line commands, just remember to delete
              them again before saving! Or you can use the MSGLINE
              prompt to identify where the member was found and open
              that member in a split screen.

              Hint: Set 'EXP' as a PFKEY (like shift+F5) to avoid
              having to use <home> to type the EXP command and then
              reposition the cursor.

       Note:  This command is provided ASIS as part of the FDP
              Developed Program) bundle, see doc for warranty and
              support information.

              */

   ADDRESS ISREDIT "MACRO (PARMS)"
   if rc > 0 | wordpos("HELP",translate(parms)) > 0 then signal Help

   ADDRESS ISREDIT;
 /*                                                                 */
 /*    You must not change the contents of EXP. Rather, make        */
 /*    your specific your changes within your version of EXP#LIBS   */
 /*                                                                 */
 /*                                                                 */
   CALL BPXWDYN "INFO FI(EXP) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then  DoTrace = 'Y'

   reference_expanded = "N" ;     /* Flag Expand Status           */
   THISPRFX = ''                  /* Default no prefix/indenting  */

   /*  Save line pointed to by user  */
   ADDRESS ISREDIT "(STRTLINE STRTCHAR) = CURSOR"
   ADDRESS ISREDIT "(ENTSTAT) = USER_STATE"        /* and status */

   ADDRESS ISPEXEC "CONTROL ERRORS RETURN" ;

   /* Determine whether we are in Edit or View  */
   ADDRESS ISPEXEC "VGET (NDUSRXV) SHARED"
   ADDRESS ISREDIT "(EDITVIEW,TMP) = SESSION"
   x = EDITVIEW

   IF NDUSRXV == "NDUSRXV" ,   /* if we're running under View User Command */
    | EDITVIEW = "EDIT" then nop
   /* If in View, then we have to get Env,Sys,Sub etc from banner */
   ELSE,
      Do
      Call Get_Endevor_Classification ;

      ADDRESS ISPEXEC,
         'VPUT (EN$BENV EN$BSYS EN$BSBS EN$BTYP EN$BSTGI EN$BSTGN ',
              ' EN$SENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$SSTGN ',
              ' EN$ELM ',
              ' DOTRACE) ',
         'SHARED'
      End

   ADDRESS ISREDIT "HILIGHT ON"

   IF EDITVIEW = "EDIT" &,
      RC > 0 THEN EXIT ; /* todo: Why Exit it highlight didn't work??? */

  /*                                                                 */
  /*                                                                 */
  /*        Create a REXX member named EXP#LIBS and assign a         */
  /*          list of libraries to search in the variable            */
  /*          INCLUDE_LIBRARY_LIST. Examples are provided.           */
  /*          in members EXP#LIBS and EXP#LIBS_Example#2.rex. *      */
  /*          Use the name EXP#LIBS and place into your REXX library.*/
  /*          Use the variables named                                */
  /*          EN$BENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$ELM        */
  /*                 as                                              */
  /*          envrionment system subsystem type stage-id element     */
  /*                                                                 */

  /*  Call EXP#LIBS for Search_Words and INCLUDE_LIBRARY_LIST        */
  Working_Values       = EXP#LIBS()

  If RC > 1 then,
        Do
        ZERRLM   = "Cannot find your version of EXP#LIBS."
        ZERRSM   = "EXP#LIBS is missing "
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
        Exit(8)
        End

  PARSE VAR Working_Values SEARCH_WORDS "||" INCLUDE_LIBRARY_LIST
  If Words(SEARCH_WORDS) = 0 then,
     SEARCH_WORDS = "COPY ++INCLUDE -INC INCLUDE PROC" ;

  reference_expanded = "W" ;     /* Flag Expand Status - search for word */


  ADDRESS ISREDIT "CURSOR = "STRTLINE" 1 " ;
  ADDRESS ISREDIT "(DATALINE)=LINE" STRTLINE
  DO WORD# = 1 TO WORDS(DATALINE)
     TEMP = WORD(DATALINE,WORD#) ;
     IF WORDPOS(TEMP,SEARCH_WORDS) > 0 THEN,
        do
        SEARCH_STRING = WORD(DATALINE,WORD#) ;
        Call Search_for_keyword;
        LEAVE ;
        end ; /* IF WORDPOS(TEMP..... */
  END; /* DO WORD# = 1 .....  */

  /* report what happened and get out */
  select
     When reference_expanded = "P" then do
        ZERRLM   = "Parsing the Endevor banner complete,",
                   "but some other error happened - nothing expanded"
        ZERRSM   = "Unexpected error Status: 'P'"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
     When reference_expanded = "W" then do
        ZERRLM   = "The Cursor is not on a valid copy, or include line.",
                   "Could not find one of the copy keywords",
                || "("SEARCH_WORDS")",
                   "on line:" strip(STRTLINE,"L","0"),
                   "- '"strip(DATALINE,"B")"'"
        ZERRSM   = "Invalid Cusror line"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
     When reference_expanded = "V" then do
        ZERRLM   = "VIEW mode detected, but unable to",
                   "parse the Endevor banner/flower box"
        ZERRSM   = "No Banner"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
     When reference_expanded = "N" then do
        ZERRLM   = "Nothing to expand here: '"Dataline"'"
        ZERRSM   = "Nothing to expand"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
     When reference_expanded = "S" then do
        ZERRLM   = "Couldn't find member: '"INCLNAME"'",
        "while searching:" INCLUDE_LIBRARY_LIST
        ZERRSM   = "Can't find '"INCLNAME"'"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
     When reference_expanded = "Y" then do
        ZERRLM   = "Expanded from: '"FROMDSN"'"
        ZERRSM   = "Expanded '"INCLNAME"'"
        ZERRALRM = "NO"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
     end
  otherwise
     say "Unexpected state:'"reference_expanded"'"
  end
   /*  Return cursor to place where user pointed*/
  ADDRESS ISREDIT "RESET FIND" /* don't flag any found or seeked lines */
  ADDRESS ISREDIT "CURSOR = (STRTLINE STRTCHAR)"
  ADDRESS ISREDIT "USER_STATE = (ENTSTAT)"         /* and status */

  exit

Search_for_keyword:


   DO FOREVER ;
      ADDRESS ISREDIT "SEEK '"SEARCH_STRING"' .ZCSR .ZCSR " ;
      IF RC > 0 THEN LEAVE  ;
      ADDRESS ISREDIT "(LP CP)=CURSOR"
      ADDRESS ISREDIT "(DATALINE)=LINE" LP
      SA= "DATALINE = " DATALINE ;
      PLACE = WORDPOS(SEARCH_STRING,DATALINE) ;
      PLACE = PLACE + 1;

      IF PLACE <= WORDS(DATALINE) THEN,
         DO
         INCLNAME = WORD(DATALINE,PLACE) ;
         If Substr(INCLNAME,1,5) = 'PROC=' then,
            INCLNAME = Substr(INCLNAME,6)
         If pos('(',INCLNAME) > 2 then /* was there a '(' */
            INCLNAME = left(INCLNAME,pos('(',INCLNAME)-1)
         INCLNAME = STRIP(INCLNAME,T,'.');
         INCLNAME = STRIP(INCLNAME,T,';');
         INCLNAME = STRIP(INCLNAME);
         IF DATATYPE(SUBSTR(INCLNAME,1,1)) = "NUM" THEN LEAVE ;
         CALL EXPAND_INCLUDE ;
         END ;
/*                                                                    */
      LEAVE ;
   END ; /* DO FOREVER */

  return ;

EXPAND_INCLUDE :
   reference_expanded = "S" ;  /* Searching for an include member */
   call Search_library_list ;
   if result > 0 then Return;

   reference_expanded = "Y" ;  /* Yes we got one! */

   ADDRESS TSO,
      "ALLOC F(INCLLIB)",
         " DA('"FROMDSN"') SHR REUSE " ;
   SA= PARM ;
   SA= INCLNAME ;
   ADDRESS TSO "EXECIO * DISKR INCLLIB (STEM ENDEVOR. FINIS" ;
   ADDRESS TSO "FREE  F(INCLLIB)"
   IF ENDEVOR.0 = 0 THEN ITERATE ;

   WHERE = 'LINE_AFTER' ;

   INTROLINE = "     FROM:" left(FROMDSN,54) ;

   'ISREDIT LINE_AFTER  .ZCSR = NOTELINE "'INTROLINE'*END*  "' ;

   /* Note use INFO lines so it's not truncated to 72 bytes and is
      scrollable - yes that'll make it white... but that's better than
      truncated - maybe only if in VIEW mode?
      Use NOTELINE for the start/end INTROLINEs so they have a diff colour
      */
   DO I = ENDEVOR.0 TO 1 BY -1
      thisline = ThisPrfx || Endevor.i
      'ISREDIT ' WHERE '.ZCSR = INFOLINE (thisline)' ;
   END ; /* DO I = 1 TO ENDEVOR.0*/

   'ISREDIT LINE_AFTER  .ZCSR = NOTELINE "'INTROLINE'*START*"' ;

   RETURN;

Search_library_list:


   X = OUTTRAP("LINE.",99,"CONCAT")

   DO LIB = 1 TO WORDS(INCLUDE_LIBRARY_LIST) ;
      FROMDSN = WORD(INCLUDE_LIBRARY_LIST,LIB) ||,
                "("INCLNAME")" ;
      IF SYSDSN("'"FROMDSN"'") = 'OK' THEN do
         X = OUTTRAP("OFF")
         RETURN(0)
      end
   END ;

   X = OUTTRAP("OFF")
   if LINE.0 > 1 then do /* didn't find anything maybe there's a message */
      Say "Could not find member ("INCLNAME") in any dataset"
      say "in:" INCLUDE_LIBRARY_LIST
      do i = 1 to LINE.0
         say LINE.i
      end
   end
   RETURN(1) ;

Get_Endevor_Classification:

   reference_expanded = "V" ;     /* We are looking for a banner  */
   /*  Find Endevor banner info (are we in Browse/History/Changes */
   ADDRESS ISREDIT "SEEK '**    ENVIRONMENT:' First "
   if RC = 0 then do /* if we found a valid banner */
     /* Yes - then set an indent prefix and save the values like QE */
     THISPRFX = COPIES(' ',09) /* ...view mode, then indent */
     ADDRESS ISREDIT "(ENVLINE ENVCHAR)=CURSOR"
     ADDRESS ISREDIT "(DATALINE)=LINE" ENVLINE
     tmp = DATALINE
     If Words(tmp) < 7 then leave /* we didn't get all the data */
     EN$BENV     = Word(tmp,03) ;
     EN$SENV     = Word(tmp,03) ;
     EN$BSYS     = Word(tmp,05) ;
     EN$SSYS     = Word(tmp,05) ;
     EN$BSBS     = Word(tmp,07) ;
     EN$SSBS     = Word(tmp,07) ;

     ADDRESS ISREDIT "SEEK '**    TYPE:       ' "
     ADDRESS ISREDIT "(TYPLINE ELECHAR)=CURSOR"
     ADDRESS ISREDIT "(DATALINE)=LINE" TYPLINE
     tmp = DATALINE
     If Words(tmp) < 6 then leave /* we didn't get all the data */
     reference_expanded = "P" ;   /* We found a valid banner */
     EN$BTYP     = Word(tmp,03) ;
     EN$STYP     = Word(tmp,03) ;
     EN$BSTGI    = Word(tmp,06) ;
     EN$SSTGI    = Word(tmp,06) ;

     /* ToDo: This area needs to be expanded for LONG element names  */
     /*       as they can extend over multiple lines - on the other  */
     /*       hand EXP doesn't need to know the CURRENT element name */
     ADDRESS ISREDIT "SEEK '**    ELEMENT:       '"
     ADDRESS ISREDIT "(ELELINE ELECHAR)=CURSOR"
     ADDRESS ISREDIT "(DATALINE)=LINE" ELELINE
     tmp = DATALINE
     If Words(tmp) < 3 then leave /* we didn't get all the data */
     EN$ELMV     = Word(tmp,03) ;
   end

   RETURN;

Help: /* Display Macro Help Text */

/* This routine can be called by Signaling HELP at any point and
   will  parse/echo to the display any lines from the prolog/comment box
   until a lone terminator is found - as an excercize for the reader it's
   clear that if there were a LOT of help it'd be nicer to allow the
   text to scroll, perhaps in a pop-up window...
   */
blockFound = 0
Do i = 1 to Sourceline()   /* First lets check there IS a comment block */
   if wordpos("/*",Sourceline(i)) = 1 then    /* yes found a blk start */
      blockFound = i                          /* save the start line */
   if blockFound > 0 then                     /* look for the end */
      if strip(sourceline(i)) == "*/" then do /* look for a terminator */
         say ' '                              /* leave a space... */
         do j = BlockFound to I               /* and for each line found */
            say Sourceline(j)                 /* echo it to the terminal */
         end
         exit /* exit with high RC to keep command on screen */
      end
end

/* if we're still here we didn't find a valid comment block, let the user
   know we tried, and get out
   */
Say "Unfortuantely this Rexx doesn't do help, Please contact the developer"
exit 28

