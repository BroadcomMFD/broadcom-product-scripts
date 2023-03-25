/*  REXX   */
/* Options built by others might not be trustworthy.                  */
/* Use this routine in such conditions to interpret only those that   */
/* have values contained in quotes, or values that are numeric.       */
/* (this routine is borrowed from ENBPIU00)                           */

/* WantQueued = Y means return valid statements in stack.             */
   Parse Arg $USROPTS WantQueued

   /* Is OPTVALDT is allocated? If yes, then be verbose ...*/
   CALL BPXWDYN "INFO FI(OPTVALDT) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then Trace r
   sa= 'in OPTVALDT'

   /*  Read the input - DDName provided in Arg  */
   "EXECIO * DISKR" $USROPTS "(Stem $Opts."$options#". Finis"
   IF RC > 8 THEN,
      DO
      STRING = "ALLOC DD(ERRORS) SYSOUT(A) "
      CALL BPXWDYN STRING;
      Push 'Cannot find OPTIONS File' $USROPTS
      "EXECIO 1 DISKW ERRORS (Finis"
      Return 12
      END;

   my_rc = 0
   $OptionCommentChars = '* #'

   /*  Process only quoted Rexx assignment statements from User */
   DO $Uop# = 1 TO $Opts.$options#.0
      $UserOption = STRIP($Opts.$options#.$Uop#) ;
      $firstchar = Substr($UserOption,1,1)
      If Pos($firstchar,$OptionCommentChars) > 0 then Iterate
      IF SUBSTR($UserOption,1,1) = $OptionCommentChars then Iterate ;
      If Words($UserOption) < 1                   then Iterate ;
      Do 20;    /* Supporting only 20 quoted lines wi continuations */
         $lastchar = Substr($UserOption,Length($UserOption))
         If Pos($lastchar,',-+') = 0 then Leave;
         $UserOption = STRIP(STRIP($UserOption,'T',$lastchar))
         $lastchar = Substr($UserOption,Length($UserOption))
         $Uop# = $Uop# + 1
         $continueOption = STRIP($Opts.$options#.$Uop#) ;
         $firstchar = Substr($continueOption,1,1)
         If ($lastchar  = "'" | $lastchar  = "'") &,
             $firstchar = $lastchar then,
             $UserOption = Strip($UserOption,'T',$lastchar) ||,
                       Strip($continueOption,'L',$firstchar)
         Else,
             $UserOption = $UserOption $continueOption
      End /* Do 20 */

      If TraceRc = 'Y' then,
         Say 'OPTVALDT: $UserOption' $Uop# '=' $UserOption

      PARSE VAR $UserOption $keyword '=' $UserOptionValue ;
      $UserOptionValue = Strip($UserOptionValue)

      If length($UserOptionValue) > 256 then,
         Do
         STRING = "ALLOC DD(ERRORS) SYSOUT(A) "
         CALL BPXWDYN STRING;
         Push 'Finding this string -'
         Push  Substr($UserOptionValue,1,70) '...'
         Push 'Value cannot exceed 256 characters.'
         "EXECIO 3 DISKW ERRORS (Finis"
         Return 12
         End

      sa= '$keyword =' $keyword
      Sa= '$UserOptionValue= ' $UserOptionValue

      $firstchar = Substr($UserOptionValue,1,1)
      $nextQuote = 0
      If ($firstchar = "'" | $firstchar = '"') then,
         $nextQuote = Pos($firstchar,$UserOptionValue,2)
      /* Only statements in acceptable format are iterpreted.  */
      /*        keyword = 'value'                              */
      /*        keyword = "value"                              */
      /*        keyword = <number>                             */
      $rslt =  VERIFY($UserOptionValue,$numbers)
      If $rslt = 0 then Nop;
      Else,
      if Words($keyword) /= 1 |,
         ($firstchar /= "'" & $firstchar /= '"') |,
         ($nextQuote /= Length($UserOptionValue)) then,
         Do
         If my_rc = 0 then,
            DO
            my_rc = 8
            STRING = "ALLOC DD(ERRORS) SYSOUT(A) "
            CALL BPXWDYN STRING;
            End;  /* If my_rc = 0 */
         Push $keyword'='$UserOptionValue
         Push 'OPTVALDT- Invalid to Interpret next line:'
         "EXECIO 2 DISKW ERRORS "
         Iterate ;
         End /* If Words.....   */

      If TraceRc = 'Y' then,
         Say 'OPTVALDT:' $UserOption

      If WantQueued = 'Y' then Queue $UserOption
      Interpret $UserOption

   End /* DO $Uop# = 1 TO $Opts.$options#.0 */

   If TraceRc = 'Y' then,
      Say 'OPTVALDT: exiting '

   RETURN my_rc

