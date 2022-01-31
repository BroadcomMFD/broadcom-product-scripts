/*     REXX    */                                                       03840000
/* Examine a 'Table Tool' table and extract its content               */03850000
/*   into a REXX stem array format. This allows validation            */03850000
/*   of Tables to consider content of multiple tables.                */03850000
/*                                                                    */03850000
   /* WRITTEN BY DAN WALTHER */                                         03870000

   Arg DSN Request HeadingChar ;
   tmp = Translate(DSN,' ','()')
   MEMBER = Word(tmp,Words(tmp))
   Sa= 'Request='REQUEST

   STRING = "ALLOC DD(TABLE) DA('"DSN"') SHR REUSE"
   CALL BPXWDYN STRING;
   "EXECIO * DISKR TABLE (STEM $tablerec. FINIS"

   $TableCommentPrefix = "**";  /* For TABLE   comments   */

   $TableHeadingChar  = "*" ;   /* For TABLE   heading    */
   If Substr(HeadingChar,1,1) /= ' ' then,
      $TableHeadingChar = HeadingChar ;

   /* Find Heading for Table */
   DO $tbl = 1 TO $tablerec.0      /* Look for header or CSV format*/
      /* If not finding a heading, just get out */
      If Substr($tablerec.$tbl,1,2) = $TableCommentPrefix then Iterate ;
      If Substr($tablerec.$tbl,1,1) /= $TableHeadingChar then Iterate ;
      Leave
   End

   If Substr($tablerec.$tbl,1,1) /= $TableHeadingChar then Exit(8) ;

   /* A Heading was found, get column info for Table */
   Call Process_Heading
   Call CaptureVariablePositions
   If REQUEST = 'ALL' then,
      Call CaptureTableContent

   Exit

/* This routine copied from ENBPUI00   */
Process_Heading :

   $LastWord = Word($tablerec.$tbl,Words($tablerec.$tbl));
   If DATATYPE($LastWord) = 'NUM' then,
      Do
      Say 'Please remove sequence numbers from the Table'
      Exit(12)
      End

   $tmprec = Substr($tablerec.$tbl,2) ;
   $PositionSpclChar = POS('-',$tmprec) ;
   If $PositionSpclChar = 0 then,
      $PositionSpclChar = POS('*',$tmprec) ;
   $tmpreplaces = '-,.'$TableHeadingChar ;
   $tmprec = TRANSLATE($tmprec,' ',$tmpreplaces);
   $table_variables = strip($tmprec);
   $Heading_Variable_count = WORDS($table_variables) ;
   If $PositionSpclChar = 0 then,
      return ;
   If $Heading_Variable_count /=,
      Words(Substr($tablerec.$tbl,2)) then,
      Do
      Say 'Invalid table Heading:' $tablerec.$tbl
      exit(12)
      End

   $heading = Overlay(' ',$tablerec.$tbl,1); /* Space leading * */
   Do $pos = 1 to $Heading_Variable_count
      $headingVariable = Word($table_variables,$pos) ;
      If $headingVariable = "$my_rc" then,
         $headingVariable = "$Temp_RC"
      $tmp = Wordindex($heading,$pos) ;
      $Starting_$position.$headingVariable = $tmp
      $tmp = $tmp + Length(Word($heading,$pos)) -1 ;
      $Ending_$position.$headingVariable = $tmp
   end; /* DO $pos = 1 to $Heading_Variable_count */

   $Table_Type = "positions" ;
   Return ;

CaptureVariablePositions:

   $headingvariables = Translate($heading,' ','-*')
   Queue "$heading."MEMBER,
               "='"Space($headingvariables)"'"

   Do $pos = 1 to $Heading_Variable_count
      $headingVariable = Word($table_variables,$pos) ;
      Starts=$Starting_$position.$headingVariable
      Ends  =$Ending_$position.$headingVariable
      Queue "Start."MEMBER"."$headingVariable"="Starts
      Queue "End."MEMBER"."$headingVariable"="Ends
      If REQUEST = 'ALL' then,
         Do
         Start.MEMBER.$headingVariable=Starts
         Ends.MEMBER.$headingVariable=Ends
         End
   end; /* DO $pos = 1 to $Heading_Variable_count */

   Return ;

CaptureTableContent:

   DO $tbl = 1 TO $tablerec.0      /* Capture content of deail recs*/
      Queue "Char@1."MEMBER"."$tbl"= '"Substr($tablerec.$tbl,1,1)"'"
      If Substr($tablerec.$tbl,1,2) = $TableCommentPrefix then Iterate ;
      If Substr($tablerec.$tbl,1,1) = $TableHeadingChar then Iterate ;
      Do $pos = 1 to $Heading_Variable_count
         $headingVariable = Word($table_variables,$pos) ;
         Starts=$Starting_$position.$headingVariable
         Ends  =$Ending_$position.$headingVariable
         len = Ends - Starts +1
         value = Strip(Substr($tablerec.$tbl,Starts,len))
         $delim = "'"
         If Pos("'",value) > 0 then,
            Do
            $delim = '"'
            value = Translate(value,"'",'"')
            End
         Queue "Value."MEMBER"."$headingVariable"."$tbl"=",
             $delim || value ||$delim
      end; /* DO $pos = 1 to $Heading_Variable_count */

   End /* Do Forever */

   Queue "LastRecord."MEMBER"="$tablerec.0

   Return ;

