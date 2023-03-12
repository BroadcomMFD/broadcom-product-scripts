/*    REXX  - Convert YAML to REXX.                                  */
/*     in some cases Stem arrays, to support Mainframe processing    */
   isItThere = ,
     BPXWDYN("INFO FI(YAML2REX) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then TraceRc = 1
   Arg  WhatDD .
   /*                                                                */
   /* Process the input YAML file identified by Whatdd.              */
   /* Queue REXX equivalent statements onto the stack                */
   /* The value of each statement is either numeric                  */
   /* or quoted with double quotes.                                  */
   /*                                                                */
   /* Caller can then safely Interpret them.                         */
   /*                                                                */

   /* Read the YAML data, stor into yaml. stem array     */
   "EXECIO * DISKR" WhatDD "( Stem yaml. finis"

   /* Set initial/default values    */
   $Numbers   = '0123456789.' ;
   Call InitializeRexxVariables ;

   /* Process each YAML record -2nd pass - create REXX     variables */
   Do y# = 1 to yaml.0
      yamlrec = yaml.y#
      /* Previous indent becomes what we just processed */
      PreviousIndent# = Word(IndentTrail,1)
      CallingFrom = 'DoLoop'
      validrec = FirstLookAtIndentation() ;
      if validrec = 0 then Iterate
      validrec = CloserLookAtYamlrecall() ;
      Call  YAMLRecordToRexx
   End /* Do y# = 1 to yaml.0  */

   /* Place Rexx statements onto the stack for caller */
   RexxCounter =  newRexx.0
   Do rx# = 1 to RexxCounter
      If TraceRc = 1 then,
         Say 'YAML2REX:' newRexx.rx#
      Queue  newRexx.rx#
   End

   If TraceRc = 1 then,
         Say 'YAML2REX: exiting '
   Exit

InitializeRexxVariables:

   /* Set initial/default values    */
   PreviousIndent# = 0;             /* Assume text starts in col 1 */
   IndentLevel_Rexxnodes.   = ''    /* node to use with REXX stmts */
   IndentLevel_UpperIndent. = 0     /* Level of upper    indentation*/
   IndentTrail = '0 '               /* Hist of indents old to new   */

   ListRexxVariables = ' '     /* Identify each unique Rexx variable */
   ListRexxVarCounts. = 0      /* Counts for    unique Rexx variable */
   Verbose = 'N'               /* Can be set/reset in yaml           */
   listing = 'na'
   newRexx.     = ''           /* Replacement REXX stmts to be here  */
   newRexx.0    = 0

   indent#     =  0
   YamlListCounter. = 0        /* 0=> not a list >0 counting listed  */
   multindent# =  0

   Return;

FirstLookAtIndentation:

   /* Bypass blank lines and comment lines */
   if Words(yamlrec) = 0 then Return 0 ; /* Blank line */
   whereComment = FindCommentPosition()
   if whereComment = 1 then Return 0 ;   /* Comment line */
   else
   if whereComment = 0 then NOP
   Else,     /* Eliminate comment portion of Yaml line */
     Do
     yamlrec = Substr(yamlrec,1,(whereComment -1))
     if Words(yamlrec) = 0 then Return 0
     End

   /* Find where no-blank text starts */
   indent# = WordIndex(yamlrec,1)
   startChar = Substr(yamlrec,indent#,1)   /*First char on YAML line */

   If CallingFrom = 'ConvertListedText' then Return 1

   /* If there is a leading '-' then in a Yaml list    */
   If startChar = '-' then,
      Do
      /* Replace the '-' with a space */
      yamlrec = Overlay(' ',yamlrec,indent#)
      indent# = WordIndex(yamlrec,1)
      End

   Return 1

FindCommentPosition:

   Start =1
   Do forever
      If Start >= length(yamlrec) then Return 0
      foundComment = Pos('#',yamlrec,Start);
      if foundComment = 0 then Return 0
      OpenSingleQt = Pos("'",yamlrec,Start);
      ClosSingleQt = Pos("'",yamlrec,OpenSingleQt+1)
      OpenDoubleQt = Pos('"',yamlrec,Start);
      ClosDoubleQt = Pos('"',yamlrec,OpenDoubleQt+1)
      If foundComment > OpenSingleQt &,
         foundComment < ClosSingleQt then,
         Start = ClosSingleQt + 1
      Else,
      If foundComment > OpenDoubleQt &,
         foundComment < ClosDoubleQt then,
         Start = ClosDoubleQt + 1
      Else Return foundComment
   End /* Do forever */

   Return foundComment

CloserLookAtYamlrecall:

   /* If there is a change in indentation, then record the change */
   PreviousIndent# = Word(IndentTrail,1)
   If indent# /=  PreviousIndent#  then, /* changed indentation */
      IndentTrail = indent# IndentTrail

   /* If there is just a Yaml listed item, return      */
   If startChar /= '-' & pos(': ',yamlrec) = 0 then Return 1 then,

   /* Parse the Yaml entry, capturing YamlObect and YamlValue   */
   Parse VAR yamlrec  YamlObject ": " YamlValue

   /* Replace spaces in YamlObect with underscore chars '_'     */
   YamlObject    = Translate(Strip(YamlObject),'_',' ')

   /* Special handling of quote characters here.....            */
   YamlValue = Strip(YamlValue)
   $firstchar = Substr(YamlValue,1,1)
   $nextQuote = 0
   If ($firstchar = "'" | $firstchar = '"') then,
      $nextQuote = Pos($firstchar,YamlValue,2)
   /* A quote character at beginning and end ?  */
   If ($nextQuote  = Length(YamlValue)) then,
      YamlValue = Strip(YamlValue,'B',$firstchar)
   Else,
      YamlValue = Translate(YamlValue,"'",'"')

   /* You can selectively turn on the trace here.......         */
   If YamlObject = 'Insert??t'   then Trace ?r

   /* Manage the tracking of Yaml indentations */
   If indent# < PreviousIndent# then, /* decreased indentation */
      Call DecreasingIndentation ;
   Else,
   If indent# > PreviousIndent# then, /* increased indentation */
      Call IncreasingIndentation
   Else,
   If indent# = PreviousIndent# then, /* matching  indentation */
      Call MatchingIndentation /* same indentation level  */

   Return 1

DecreasingIndentation:

   /*  Indentation just Increased     */

   /* Use IndentTrail to find upper indentation for this one */
   upperIndent# = GetUpperIndent#()
   /* What did we find looking upward ?*/
   IndentLevel_UpperIndent.indent# = upperIndent#
   /* Get the Rexx nodes from upward locations  */
   UpperVarb = Word(IndentLevel_Rexxnodes.upperIndent#,1)
   /* Make this YamlObject 1st in the list here  */
   If upperIndent# = 0 then,
      CurrentVarb = YamlObject
   Else,
      CurrentVarb = UpperVarb'.'YamlObject
   CurrentNodes = IndentLevel_Rexxnodes.indent#
   If WordPos(CurrentVarb,CurrentNodes) = 0 then,
      IndentLevel_Rexxnodes.indent# =,
         CurrentVarb IndentLevel_Rexxnodes.indent#
   Else,
      Do
      If startChar = '-' |,                      /* YAML starting list*/
         YamlListCounter.indent# > 0 then,
         YamlListCounter.indent# = YamlListCounter.indent# + 1 ;
      IndentLevel_Rexxnodes.indent# = CurrentVarb
      End
   /* If previousIndent was listing, it will have to start over */
   YamlListCounter.PreviousIndent# = 0
   IndentLevel_UpperIndent.PreviousIndent# = indent#

   Return

IncreasingIndentation:

   /*  Indentation just Increased     */
   upperIndent# = PreviousIndent#
   If startChar = '-' then,                   /* YAML starting list*/
      YamlListCounter.indent# = 1 ;           /* count listed items*/

   /*  Assume prev indentation is upper indentation     */
   UpperVarb = Word(IndentLevel_Rexxnodes.PreviousIndent#,1)
   /* Make this YamlObject 1st in the list here  */
   If PreviousIndent# = 0 then,
      CurrentVarb = YamlObject
   Else,
      CurrentVarb = UpperVarb'.'YamlObject
   If PreviousIndent# = 0 then,
      IndentLevel_Rexxnodes.indent# =  YamlObject
   Else,
      IndentLevel_Rexxnodes.indent# =,
         CurrentVarb IndentLevel_Rexxnodes.indent#
   /* At this level, capture reference to upper level  */
   IndentLevel_UpperIndent.indent# = PreviousIndent#

   Return

MatchingIndentation:

   /*  Indentation remainded the same */

   upperIndent# = IndentLevel_UpperIndent.indent#
   /* Get the Rexx nodes from upward locations  */
   UpperVarb = Word(IndentLevel_Rexxnodes.upperIndent#,1)
   /* Make this YamlObject 1st in the list here  */
   If upperIndent# = 0 then,
      CurrentVarb = YamlObject
   Else,
      CurrentVarb = UpperVarb'.'YamlObject
   CurrentNodes = IndentLevel_Rexxnodes.indent#
   /* If the variable a repeating variable at this level? */
   If WordPos(CurrentVarb,CurrentNodes) = 0 then, /* no  */
      IndentLevel_Rexxnodes.indent# =,
         CurrentVarb CurrentNodes                 /* yes*/
   Else,
      Do /* Repeating a YamlObject name, increment */
      IndentLevel_Rexxnodes.indent# = CurrentVarb
      If YamlListCounter.indent# > 0 then,
         YamlListCounter.indent# = YamlListCounter.indent# + 1 ;
      End /* If YamlListCounter.indent# > 0 */

   Return

GetupperIndent#:

   /* Use IndentTrail to find upper indent value for just found */
   /*     Yaml line with changed indentation.                   */
   Do trl# =  1 to Words(IndentTrail)  /* find its outer indent*/
      happyTrails = Word(IndentTrail,trl#)
      If happyTrails < indent# then Return happyTrails
   End /* Do Forever.... search for next upper indentation */

   Return 0


ConvertListedText:

   /* Finding text listed in Yaml. Use Rexx YamlListCounter in output */
   RexxCounter =  newRexx.0 + 1
   peek_y# = next_y# + 1
   /* Multi-lines ? if value is |  or   >       */
   multindent# = WordIndex(yaml.peek_y#,1)
   IndentLevel_UpperIndent.multindent# = indent#
   upperIndent# = indent#
   endLinechar = '15'x  /* Ebcdic end-of-line char */
   TextCounter =  1
   CallingFrom = 'ConvertListedText'
   Do Forever
      next_y# = next_y# + 1
      if next_y# > yaml.0 then Leave
      yamlrec     = Strip( yaml.next_y#,'T')
      validrec = FirstLookAtIndentation() ;
      if indent# < multindent# then leave;
      if validrec = 0 then Iterate
      yamlrec     = Substr(yamlrec,multindent#)
      RexxCounter = RexxCounter + 1
      $firstchar = Substr(yamlrec,1,1)
      If $firstchar = '"' then,
         newRexx.RexxCounter =,
            RexxVarb'.'TextCounter '='yamlrec
      Else,
         newRexx.RexxCounter =,
            RexxVarb'.'TextCounter '="'yamlrec'"'
      TextCounter = TextCounter + 1
   End /* Do Forever */

   newRexx.0 = RexxCounter

   Return next_y# -1


YAMLRecordToRexx:

   RexxVarb = ''
   /* if not listing and no value, then no REXX  (yet)               */
   If Length(YamlValue) = 0 &,
      YamlListCounter.indent# = 0 then  RETURN;

   /* Yaml is listing objects or text */
   If PreviousIndent# = 0 & YamlListCounter.indent# > 0 then,
      Do
      Say 'YAML2REX: starting a list in column 1 is invalid'
      Exit 12
      End                                                          x
   RexxCounter =  newRexx.0
   /* Yaml allows these values to indicate listed data on + lines*/
   If YamlValue = "|" | YamlValue = '>' then,
      Do
      Call DetermineRexxVarb ;
      /* Use YamlListCounter and build Rexx Stem array stmts */
      next_y# = y#
      y# = ConvertListedText() ;
      Return;
      End

   next_y# = y# - 1

   /* Yaml list/ojb  with YamlValue...  Write 1 Rexx equal .  */
   If Length(YamlValue) > 0 then, /* we have a Yaml value  */
      Do /* Since there is a value, write Rexx 1 for 1:    */
      /* Write a line of Rexx output, using YamlListCounter */
      RexxCounter =  newRexx.0 + 1
      Call DetermineRexxVarb ;

      /* if Value is numeric, do not quote it               */
      numericValue = Verify(YamlValue,$Numbers)
      If numericValue > 0 then,
         newRexx.RexxCounter = RexxVarb '="'YamlValue'"'
      Else,
         newRexx.RexxCounter = RexxVarb '='YamlValue
      newRexx.0    = RexxCounter

      Return;
      End /* If listing = 'Objects' */

   /* Yaml list / no   YamlValue...  Save YamlObject     */
   /* This is the indentation level for the 1st in list. */
   multindent# = WordIndex(yamlrec,1)  /* level for the list */
   Return;

   /* Continue through Yaml for remainder of list */
   /*   Loop for all found like this one and Write Rexx equal. */
    Do Forever  /* until the indentation decreases */
       next_y# = next_y# + 1
       if next_y# > yaml.0 then Leave
       yamlrec     = yaml.next_y#
       /* Do the normal scrub of the Yaml input lines */
       validrec = FirstLookAtIndentation() ;
       /* Skip Blank lines and Comment lines */
       If validrec = 0 then Iterate
       /* indentation decreased  ?           */
       if indent# < multindent# then Leave
       RexxVarb = Word(UpperVarb,1)
       Call WriteRexxWithYamlListCounter ;

    End /* Do Forever */

   newRexx.0    = RexxCounter
   y# = next_y# - 1
   /* Initialize these for the next Yaml List */
   IndentLevel_Rexxnodes.multindent# = ''
   listing = 'na'
   next_y# = 0
   Return;

   /* Not a YAML list.....                */
   Return;

   /* Is the Indentation changing ? ...   */
   if indent#  = PreviousIndent# then,
      Call MatchingIndentation /* same indentation level  */
   Else,
   if indent#  > PreviousIndent# then,
      Call IncreasingIndentation
   Else,
   if indent#  < PreviousIndent# then,
      Call DecreasingIndentation ;

   /* The found indentation is now the previous indentation */
   /* Is this a new Object/Word, or repeating one ? */

   If Length(YamlValue) = 0 then, /* we have a Yaml Object */
      Return ;

   /* Multi-lines ? if value is |  or   >       */
   If YamlValue = "|" | YamlValue = '>' then,
      Do
      next_y# = y#
      RexxVarb = Word(UpperVarb,1)'.'YamlObject
      y# = ConvertListedText() ;
      Return;
      End

   RexxVarb = IndentLevel_Rexxnodes.indent#

   If RexxVarb = '' then Return;

   /* contribute to the new Rexx statements  */

   where = Wordpos(RexxVarb,ListRexxVariables)

   thisVariableCount  = ListRexxVarCounts.where
   if thisVariableCount > 0 then,
      Do
      RexxVarb = RexxVarb'.'thisVariableCount
      ListRexxVarCounts.where = ListRexxVarCounts.where +1
      End

   /* If value not numeric, surround with double quotes */
   RexxCounter =  newRexx.0 + 1
   numericValue = Verify(YamlValue,$Numbers)
   If numericValue > 0 then,
      newRexx.RexxCounter =  RexxVarb'="'YamlValue'"'
   Else,
      newRexx.RexxCounter =  RexxVarb'='YamlValue

   newRexx.0    = RexxCounter

   Return

DetermineRexxVarb:

   /* Determine REXX variable from upper and this indentation */
   upperIndent# = IndentLevel_UpperIndent.indent#
   UpperVarb = Word(IndentLevel_Rexxnodes.upperIndent#,1)

   If upperIndent# = 0 then RexxVarb = YamlObject
   Else,
   If YamlListCounter.upperIndent# > 0 then, /* a Yaml List   */
      RexxVarb = Word(UpperVarb,1)'.' ||,
                 YamlListCounter.upperIndent#'.'YamlObject
   Else,                                     /* a Yaml Object */
      RexxVarb = Word(UpperVarb,1)'.'YamlObject

   /* Determine REXX variable also from      this indentation */
   If YamlListCounter.indent# > 0 then,    /* a Yaml List   */
      RexxVarb = RexxVarb'.'YamlListCounter.indent#

   Return

