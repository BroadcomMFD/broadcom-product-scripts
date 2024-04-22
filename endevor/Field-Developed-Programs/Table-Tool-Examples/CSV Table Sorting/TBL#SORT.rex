/*     REXX                                                           */
/* Sort a CSV file, where sort fields are named in the SORTPARM       */
/* input file, using "Table Tool" names of variables.                 */
/* See:                                                               */
/* https://www.ibm.com/docs/en/zos/3.1.0?topic=rrape-example-13       */
/*--------------------------------------------------------------------*/

   CALL BPXWDYN "INFO FI(TBL#SORT) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then trace R

   /*  Set Default values */
   $MaxFieldWidth.    = 0  /* For each Sort Field, max length       */
   $MaxRecordlen      = 0  /* Longest CSV record, including heading */
   $IncrementalLength = 0  /* length of fixed fields for sorting    */
   $MaxRecStripped    = 0  /* Longest rec excluding trailing blanks */
   $ortFieldENDBEFR.  = 0  /* DFSORT ENDBEFR field number           */
   $ortParameters = ''     /* List sort parm names from SORTPARM    */
   $ortDirections = ''     /* A or D for Ascending or Descending    */
   $ortHeaderPosition. = 0 /* Word position in the $table_variables */
   $LastSortPosition   = 0 /* Number of last heading var for sort   */

   /* Ensure the SORTIN Input is using CSV format  */
   "EXECIO * DISKR SORTIN (STEM $tablerec. FINIS"
   CALL DetermineTableTypeAndLocateHeading ;

   /* Read and Validate the Sort parameters in SORTPARM */
   "EXECIO * DISKR SORTPARM (STEM $sortparms. FINIS"
   If $sortparms.0 = 0 then,
      Do
      Say 'TBL#SORT- Please enter at least one SORTPARM entry:'
      Say 'TBL#SORT-  <tableVariableName> A/D    '
      Say 'TBL#SORT- For example, "ELM_NAME  A  "'
      Exit (12)
      End;
   DO $srt = 1 TO $sortparms.0           /* Search SORTPARMs */
      $thisSortparm = Word($sortparms.$srt,1)
      $ortHeaderPosition.$thisSortparm = ,
        Wordpos($thisSortparm,$table_variables)
      IF $ortHeaderPosition.$thisSortparm > $LastSortPosition then,
         $LastSortPosition = $ortHeaderPosition.$thisSortparm
      IF $ortHeaderPosition.$thisSortparm = 0 then,
         Do
         Say "TBL#SORT- Requested sort field" $thisSortparm,
             " is not found in the CSV heading"
         Exit (12)
         End
      $thisDirection= Word($sortparms.$srt,2)
      IF $thisDirection /= 'A' & $thisDirection /= 'D' then,
         Do
         Say "TBL#SORT- Requested sort field order",
             "'"$thisDirection"'",
             "is neither 'A' (ascending)",
             "nor 'D' (descending)"
         Exit (12)
         End
      $ortParameters = $ortParameters $thisSortparm
      $ortDirections = $ortDirections $thisDirection
   END; /* DO $tbl = 1 .... */

   /* Free files                                          */
   CALL BPXWDYN "FREE DD(SORTPARM)"


   /* Determine the ENDBEFR values (order within Heading) */
   /* (must be done after capturing all Sort parms)       */
   DO $srt = 1 TO Words($ortParameters)
      $thisSortparm = Word($sortparms.$srt,1)
      $HeaderPosition = $ortHeaderPosition.$thisSortparm
      $this_ENDBEFR  = 1
      If $srt <= Words($ortParameters) then,
         Do $wrd# = 1 to Words($ortParameters)
         if $wrd# = $srt then Iterate
         $nextSortparm = Word($sortparms.$wrd#,1)
         $nextPosition = $ortHeaderPosition.$nextSortparm
         If $nextPosition < $HeaderPosition then,
            $this_ENDBEFR  = $this_ENDBEFR + 1
         End;   /* If $srt < Words($ortParameters) */
      $ortFieldENDBEFR.$thisSortparm = $this_ENDBEFR ;
   END; /* DO $srt = 1 .... */

   /* Process remaining rows to get Sort field lengths */
   DO $tbl = 2 TO $tablerec.0           /* Search Table */
      $tmpLen = Length($tablerec.$tbl)
      If $tmpLen  > $MaxRecordlen then,
         $MaxRecordlen = $tmpLen
      $detail  = Strip($tablerec.$tbl) || ','
      $Len$detail = length($detail)
      If $Len$detail > $MaxRecStripped then,
         $MaxRecStripped = $Len$detail
      Call Evaluate_Table_row ;
   END; /* DO $tbl = 2 TO $tablerec.0 */

   /* Report found Sort Field sizes ....      */
   /* Calculate Sort input file lrecl size    */
   Do $wrd# = 1 to Words($ortParameters)
      $thisSortparm = Word($ortParameters,$wrd#)
      $thisDirection= Word($ortDirections,$wrd#)
      $thisFieldLen = $MaxFieldWidth.$thisSortparm
      $IncrementalLength = $IncrementalLength + $thisFieldLen
      Say "TBL#SORT- Sorting with field",
           $thisSortparm $thisDirection,
           "(length=" || $thisFieldLen || ")"
      Say "         ",
           "- heading word" $ortHeaderPosition.$thisSortparm
   END; /* Do $wrd# = 1 to Words($ortParameters) */

   /* Provide informative messages about findings */
   $Words_$table_variables = Words($table_variables)
   $Words_$ortParameters = Words($ortParameters)
   Say "TBL#SORT- Sorting with",
       $Words_$ortParameters "of",
       $Words_$table_variables "fields in the CSV heading"
   Say "TBL#SORT- Sort data length:",
               $IncrementalLength"+"$MaxRecStripped,
       "=(" || $IncrementalLength + $MaxRecStripped || ")",
       " of" $MaxRecordlen "characters"
   if ($IncrementalLength + $MaxRecStripped) > $MaxRecordlen then,
      Do
      Say "TBL#SORT- A longer LRECL is required!!"
      Exit(12)
      End

   Call Build_SORTIN_cards

   Drop $tablerec.

   Queue $CSVheading
   "EXECIO 1 DISKW SORTOUT (Finis"
/*
   ADDRESS LINK 'SORT'  ; $my_rc = RC ;
   Address TSO "call *(SORT) "
   "SORT"

   Say "Calling Sort"
   ADDRESS LINK 'SORT'  ; $my_rc = RC ;
*/

   Exit


DetermineTableTypeAndLocateHeading :

/* Look for heading record. Determine what kind of Table we have */

   $tbl = 1

      IF SUBSTR($tablerec.$tbl,1,1) = '"' |,
         SUBSTR($tablerec.$tbl,1,1) = ',' |,
         ( SUBSTR($tablerec.$tbl,1,1) = ' ' &,
            Pos(',',$tablerec.$tbl) > 0 ) |,
         SUBSTR($tablerec.$tbl,1,2) = ' "' then,
         Do
         CALL Process_CSV_Line1 ;
         RETURN;
         End
      Else,             /* See if POSITION data is provided */
         Do
         say "TBL#SORT- Expecting a CSV table, "
         say " and not finding a CSV format.   "
         exit (12)
         end; /* else */

   Return ;

Process_CSV_Line1 :

   $MaxRecordlen = Length($tablerec.$tbl)

   $heading = Strip($tablerec.$tbl) ;
   $CSVheading = $heading
/* Length of $heading is not considered, since it is excluded  */
/*   .. during sorting                                         */
/* $MaxRecordlen = Length($CSVheading)  */
   $tablerec.$tbl = Space(Translate($heading,' ',"/'-")) ;

   $heading = TRANSLATE($heading,'@@$$##','()/\%.') ;
   $table_variables = "" ;
   $repeaters = "" ;

   DO FOREVER
      PARSE VAR $heading $value ',' $heading ;
      $value = STRIP($value) ;
      $value = TRANSLATE($value,'_',' ') ;
      $value = STRIP($value,B,'"');
      SAY "CSV Variable:" $value ;
      if WordPOS($value,$table_variables) > 0 &,
         Wordpos($value,$repeaters) = 0 then,
           $repeaters = $repeaters $value ;
      $table_variables = $table_variables $value       ;
      IF WORDS($heading) = 0 THEN LEAVE;
   END; /* DO FOREVER */

   If Words($repeaters) > 0 then,
      DO
      $new_list = " " ;
      $count. = 0 ;
        Do $cnt = 1 TO WORDS($table_variables)
           $value = WORD($table_variables,$cnt)
           If WORDPOS($value,$repeaters) > 0 then,
              Do
              $count.$value = $count.$value + 1;
              $value = $value"#"$count.$value ;
              End;
           $new_list = $new_list $value;
        End ; /* Do $cnt = 1 to Words($table_variables) */
      $table_variables = $new_list ;
      End ; /* If Words($repeaters) = 0 */

   $Heading_Variable_count = WORDS($table_variables) ;
   $Table_Type = "CSV" ;

   return ;

Evaluate_Table_row :
/*    Assign heading variables to values from next table record      */

   DO $column = 1 TO $Heading_Variable_count
      $table_variable = WORD($table_variables,$column) ;

      /* Table is a CSV file */
      If $Table_Type = "CSV"       then,
         Do
         DROP $word. ;
         /* Find the data for the current $column */
         $dlmchar = Substr($detail,1,1);

         If $dlmchar = "'" then,
            Do
            /* parsing with single quote  */
            PARSE VAR $detail "'" $temp_value "'," $detail ;
            /* replace single quotes with double quotes */
            $temp_value = Translate($temp_value,'"',$dlmchar);
            End
         Else,
         If $dlmchar = '"' then,
            Do
            /* parsing with double quote  */
            PARSE VAR $detail '"' $temp_value '",' $detail ;
            /* replace double quotes with single quotes */
            $temp_value = Translate($temp_value,"'",$dlmchar);
            End
         Else,
            Do
            /* parsing with comma chars   */  ,
            PARSE VAR $detail $temp_value ',' $detail ;
            $dlmchar = '"'
            End

         if Length($temp_value) < 1 then $temp_value = ' '
         $rslt = $dlmchar || $temp_value || $dlmchar
         $temp = WORD($table_variables,$column) "=" $rslt
         If Wordpos($table_variable,$ortParameters) > 0 then,
            Do
            Sa=       $temp;
            INTERPRET $temp;
            If Length($rslt) > $MaxFieldWidth.$table_variable then,
               $MaxFieldWidth.$table_variable = Length($rslt)
            End; /*If Wordpos($table_variable,$ortParameters) > 0*/

         End; /* If $Table_Type = "CSV"  */

   END; /* DO $column = ... */

   RETURN;

Build_SORTIN_cards:

   /* In sort fields, change double quotes to spaces   */
   QUEUE '  ALTSEQ CODE=(7F40)'

   $Next_ENDBEFR = 1
   $leading = "  INREC PARSE=("
   $tail = ','
   /* Build ENDBEFR statements for the SORTIN  */
   Do $wrd# = 1 to Words($table_variables)
      $thisVariable = Word($table_variables,$wrd#)
      If $wrd# >= $LastSortPosition then $tail = '),'
      If WOrdpos($thisVariable,$ortParameters) = 0 then,
         Queue $leading || "%=(ENDBEFR=C',')" || $tail
      Else,
         Do
         $thisFieldLen = $MaxFieldWidth.$thisVariable
         Queue $leading || "%"Right($Next_ENDBEFR,3,'0') ||,
             "=(ENDBEFR=C',',FIXLEN="$thisFieldLen")" || $tail
         $Next_ENDBEFR = $Next_ENDBEFR + 1
         End
      $leading = Copies(' ',15)
      If $wrd# >= $LastSortPosition then Leave
   End; /* Do $wrd# = 1 to Words($table_variables) */

   /* Build OVERLAY statements for the SORTIN  */
   /* Also build SORT FIELD statement....      */
   $SortOverlay = '   OVERLAY=('
   $SortOverlayTail = ',TRAN=ALTSEQ,'
   $sortFieldTail   = ','
   $OverlayPointer = $MaxRecStripped + 1
   $sortField.  = '                '
   $sortField.1 = '   SORT FIELDS=('
   Do $wrd# = 1 to Words($ortParameters)
      $thisSortparm  = Word($ortParameters,$wrd#)
      $thisDirection = Word($ortDirections,$wrd#)
      $thisFieldLen  = $MaxFieldWidth.$thisSortparm
      $thisHeaderPos = $ortHeaderPosition.$thisSortparm
      $this_ENDBEFR  = $ortFieldENDBEFR.$thisSortparm
      $this_ENDBEFR  = Right($this_ENDBEFR,3,'0')
      If $wrd# = Words($ortParameters) then,
         Do
         $SortOverlayTail = ',TRAN=ALTSEQ)'
         $sortFieldTail = '),SKIPREC=1'
         End
      $SortOverlay = $SortOverlay || $OverlayPointer ||,
         ':%'$this_ENDBEFR||$SortOverlayTail
      Queue $SortOverlay
      $SortOverlay = '            '
      $sortField.$wrd# = $sortField.$wrd# || $OverlayPointer',' ||,
         $thisFieldLen',CH,'$thisDirection|| $sortFieldTail
      $OverlayPointer = $OverlayPointer + $thisFieldLen
   End; /* Do $wrd# = 1 to Words($ortParameters) */

   Do $wrd# = 1 to Words($ortParameters)
      Queue $sortField.$wrd#
   End; /* Do $wrd# = 1 to Words($ortParameters) */

   $SpacesPadding = 4095
   Queue '   OUTREC BUILD=(1,'$MaxRecStripped','$SpacesPadding'X)'

   "EXECIO" QUEUED() "DISKW SYSIN (Finis"
   "EXECIO * DISKR SYSIN  ( Stem  sortcmd. Finis"
   "EXECIO * DISKW SHOWME ( Stem  sortcmd. Finis"

   Return
