/*     REXX  OPTions syntax checker                                   */
/*                                                                    */
/* Validate OPTions: Ensure each is formatted as one of these:        */
/*     keyword = 'value'                                              */
/*     keyword = "value"                                              */
/* Flag each violation with an error message into SYSPRINT            */
/*                                                                    */
   Trace Off
/* If my name is allocated to anything (included DUMMY) then Trace    */
   WhatDDName = 'ROPTIONS'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) /= ' ' then Trace R

/* Get from Processor/JCL the allowed keywords for use in OPTions     */
/* (can remain empty, to imply any keyword is allowed)                */
   ValidKeywords = ''
   "EXECIO * DISKR VALIDOPT (STEM $ValidOpts. FINIS" ;
   Do opt# = 1 to $ValidOpts.0
      ValidKeywords = Strip($ValidOpts.opt#) ValidKeywords;
   End
/*                                                                    */
   $UserOptionCommentChar = '*'

/* Call routine to validate options  (similar to Table Tool routine)  */
   x = IncludeQuotedOptions(USEROPTS)

/* Show Syntax listing - in SYSPRINT                                  */
   "EXECIO" QUEUED() "DISKW SYSPRINT (Finis"

   Exit(MyRc)

IncludeQuotedOptions:

   Arg $UserOptDDname;

   "EXECIO * DISKR "$UserOptDDname "(STEM $UserOpts. FINIS" ;
   MyRc = 0

   DO $Uop# = 1 TO $UserOpts.0
      $UserOption = STRIP($UserOpts.$Uop#) ;
      IF SUBSTR($UserOption,1,1) = $UserOptionCommentChar then ITERATE ;
      If Words($UserOption) < 1                   then ITERATE ;
      Do 20;    /* Supporting only 20 quoted lines wi continuations */
         $lastchar = Substr($UserOption,Length($UserOption))
         If Pos($lastchar,',-+') = 0 then Leave;
         $UserOption = STRIP(STRIP($UserOption,'T',$lastchar))
         $lastchar = Substr($UserOption,Length($UserOption))
         $Uop# = $Uop# + 1
         $continueOption = STRIP($UserOpts.$Uop#) ;
         $firstchar = Substr($continueOption,1,1)
         If ($lastchar  = "'" | $lastchar  = '"') &,
             $firstchar = $lastchar then,
             $UserOption = Strip($UserOption,'T',$lastchar) ||,
                       Strip($continueOption,'L',$firstchar)
         Else,
             $UserOption = $UserOption $continueOption
      End /* Do 20 */

      PARSE VAR $UserOption $keyword '=' $UserOptionValue ;
      $keyword         = Strip($keyword)
      $UserOptionValue = Strip($UserOptionValue)
      sa= '$keyword =' $keyword
      Sa= '$UserOptionValue= ' $UserOptionValue

      $UserOption = Strip($UserOption)
      QUEUE $UserOption
      $firstchar = Substr($UserOptionValue,1,1)
      $nextQuote = 0
      If ($firstchar = "'" | $firstchar = '"') then,
         $nextQuote = Pos($firstchar,$UserOptionValue,2)
      /* Only statements in acceptable format are iterpreted:  */
      /*        keyword = 'value'                              */
      /*        keyword = "value"                              */
      If Pos('=',$UserOption) = 0 then,
            Do
            MyRc = 8
            QUEUE " \\\ OPTIONS: Invalid syntax - ",
                  "Expecting: keyword = 'value' "
            End
      Else,
      If Words($keyword) /= 1 then,
            Do
            MyRc = 8
            QUEUE " \\\ OPTIONS: Invalid syntax - ",
                  "keyword is invalid"
            End
      Else,
      If Words(ValidKeywords) > 1 &,
         Wordpos($keyword,ValidKeywords) = 0 then,
            Do
            MyRc = 8
            QUEUE ' \\\ OPTIONS: Keyword not valid'
            End
      Else,
      If DATATYPE($keyword,SYMBOL) /= 1 then,
            Do
            MyRc = 8
            QUEUE ' \\\ OPTIONS: Keyword not valid'
            End
      Else,
      If ($firstchar /= "'" & $firstchar /= '"') |,
         ($nextQuote /= Length($UserOptionValue)) then,
            Do
            MyRc = 8
            QUEUE ' \\\ OPTIONS: Value not properly quoted'
            End

   End /* DO $Uop# = 1 TO $UserOpts.0 */

   RETURN MyRc


