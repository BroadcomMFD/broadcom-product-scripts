/*     REXX - Endevor Rexx command to allow acces to Exp Libs

       Usage: EXPLIBS (help)

              This Helper utility address the issue that you might need
              to search your sites 'copylibs' to find a copy member, or
              using srchfor, for a particular string.  It uses your
              sites EXP#LIBS to determine the libraries you need based
              on your current/last Endevor actions and invokes ISRDDN
              to provide the UI for browsing/viewing/searching those
              libraries.  Press PF1 from ISRDDN to review help on all
              the command available.

              You must code your own subroutine named EXP#LIBS, where
              based on the variables that provide the Endevor
              Classification details, you name the libraries to be
              searched, and the keywords to be used for them.
              See the examples EXP#LIBS and EXP#LIBS#example#2.
              See also the ENDIEIM1 for EXP.rex for minor updates
              necessary for your ENDIEIM1 member.

       Note:  This command is provided ASIS as part of the FDP
              Developed Program) bundle, see doc for warranty and
              support information.

              */

   ADDRESS ISREDIT "MACRO (PARMS)" /* allow entry as edit command */
   if rc <> 0 then        /* maybe command entry, check for parms */
       parse arg parms
   if wordpos("HELP",translate(parms)) > 0 then signal Help


   CALL BPXWDYN "INFO FI(EXPLIBS) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then  Trace ?R


  /* todo: we need an onerror clause to trap routine not found, rc not set*/
  /*  Call EXP#LIBS for Search_Words and INCLUDE_LIBRARY_LIST        */
  Working_Values = EXP#LIBs()

  If Working_Values = "" then /* if we didn't get a response */
        Do
        ZERRLM   = "Cannot find your version of EXP#LIBS."
        ZERRSM   = "EXP#LIBS is missing "
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
        Exit(8)
        End

  PARSE VAR Working_Values SEARCH_WORDS "||" INCLUDE_LIBRARY_LIST

  If INCLUDE_LIBRARY_LIST \> " " then /* check we have some data */
     Do
        ZERRLM   = "Your version of EXP#LIBS. did not set a value ('",
                || INCLUDE_LIBRARY_LIST || "')"
        ZERRSM   = "EXP#LIBS not set"
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
        Exit(8)
     End

  ADDRESS ISPEXEC "VGET (ZSCREEN)"
  expdd = "EXPLIB" || ZSCREEN
  INCLUDE_LIBRARY_LIST_QUALIFIED = ""
  do i = 1 to words(INCLUDE_LIBRARY_LIST)
     thisLib = word(INCLUDE_LIBRARY_LIST,i)
     DSNCHECK = SYSDSN("'"thisLib"'") ;
     If DSNCHECK = 'OK' then,
       INCLUDE_LIBRARY_LIST_QUALIFIED = INCLUDE_LIBRARY_LIST_QUALIFIED,
        "'" || thisLib || "'"
  end
  INCLUDE_LIBRARY_LIST_QUALIFIED = strip(INCLUDE_LIBRARY_LIST_QUALIFIED,'L')

  /* try to allocate the file - no error trapping, allow user to see */
  ADDRESS TSO "alloc f("expdd") ds("INCLUDE_LIBRARY_LIST_QUALIFIED") SHR REU"

  If RC <> 0 then /* check alloc rc */
     Do
        ZERRLM   = "Allocation error RC:" RC "for DD:" EXPDD "DS:",
                   INCLUDE_LIBRARY_LIST_QUALIFIED
        ZERRSM   = "Alloc Error: RC:"RC
        ZERRALRM = "YES"
        ADDRESS ISPEXEC "SETMSG MSG(ISRZ002)"
        Exit(8)
     End

  /* still here - we have a library allocated - use ISRDDN to view it */
  ADDRESS ISPEXEC "SELECT CMD(ISRDDN ONLY "expdd") NOCHECK SCRNAME("expdd")"

  /* try to allocate the file - no error trapping, allow user to see */
  ADDRESS TSO "free f("expdd")" /* todo: consider checking if pre-allocated */

  exit 0

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

