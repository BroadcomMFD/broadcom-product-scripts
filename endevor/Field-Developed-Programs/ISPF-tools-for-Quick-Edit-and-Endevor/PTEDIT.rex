 /* REXX   */
   'ISREDIT MACRO ' ;
   TRACE  o ;
   ADDRESS ISREDIT;
   ADDRESS ISPEXEC,
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"
   DELIMITERS = ' ,/*="?'"'" ;
   Do forever
      if zscreenc = 1 then leave;
      char = substr(zscreeni,zscreenc,1) ;
      if char = " " then leave;
      if char = '.' | datatype(char,alphanumeric) = 1 then,
         zscreenc = zscreenc - 1;
      else leave;
   end; /* do forever */
   wheredsn = SUBSTR(ZSCREENI,(ZSCREENC+1),80)
   sa= "wheredsn=>>>"wheredsn"<<<"
   END_POSITION = 80 ;
   left_paren_POSITION  = POS("(",wheredsn) ;
   POSITION  = POS("'",wheredsn)
   IF POSITION > 0 & POSITION < END_POSITION THEN,
      END_POSITION = POSITION - 1 ;
   POSITION  = POS(")",wheredsn)
   IF POSITION > 0 & POSITION <= END_POSITION THEN,
      END_POSITION = POSITION ;
   DO DLM = 1 TO LENGTH(DELIMITERS)
      DELIMITER = SUBSTR(DELIMITERS,DLM,1);
      POSITION  = POS("'"DELIMITER"'",wheredsn)
      POSITION  = POS(DELIMITER,wheredsn)
      IF POSITION > 0 & POSITION < END_POSITION THEN,
         END_POSITION = POSITION - 1;
   END; /* DO DLM = 1 TO LENGTH(DELIMITERS) */
   wheredsn = substr(wheredsn,1,end_position) ;
   DSNCHECK = SYSDSN("'"wheredsn"'") ;
   IF DSNCHECK /= OK &,
      left_paren_POSITION > 0 &,
      left_paren_POSITION < END_POSITION then,
         do
         wheredsn = substr(wheredsn,1,(left_paren_POSITION -1)) ;
         DSNCHECK = SYSDSN("'"wheredsn"'") ;
         end ;
   TEMP = LISTDSI("'"wheredsn"'" RECALL DIRECTORY)
   If Substr(SYSDSORG,1,2) = 'PO' &,
      SYSMEMBERS = 0 then,
        Do
        Say wheredsn "has no members"
        Exit
        end;
   IF DSNCHECK = OK then,
      do
      ADDRESS ISPEXEC "EDIT DATASET('"wheredsn"')" ;
      if rc > 4 then say "rc=" rc
      end;
   else say wheredsn "-" dsncheck ;
   EXIT
