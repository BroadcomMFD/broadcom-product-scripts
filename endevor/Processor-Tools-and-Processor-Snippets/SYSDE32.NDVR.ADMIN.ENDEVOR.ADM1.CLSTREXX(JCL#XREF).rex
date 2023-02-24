  /*  REXX   */

  /* Scan JCLCheck SYSPRINT FOR PGM= and DSN= references  */

  /* If JCL#XREF is allocated, then turn on Trace         */
  WhatDDName = 'JCL#XREF'
  CALL BPXWDYN "INFO FI("WhatDDName")",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  if Substr(DSNVAR,1,1) /= ' ' then Trace R

  "EXECIO * DISKR MYJCL (Stem" JclRec.

  $All_VARIABLES = 'SYSUID'
  $delimiter = "." ;
  $LINE = 1
  SYSUID = USERID()

  Do jcl# = 1 to JclRec.0
     Jclrecord = Substr(JclRec.jcl#,47)
     SA= 'RECORD=' Jclrecord ;
     If Substr(Jclrecord,1,3) = 'XX*' THEN iterate
     Labelword = ' ';
     If Substr(Jclrecord,1,2) = 'XX' &,
        Substr(Jclrecord,3,1) /= ' ' then,
        Labelword = Word(Strip(Substr(Jclrecord,3,8)),1) ;
     FoundSET = POS(' SET ',Jclrecord);
     If FoundSET > 0 THEN,
        Call Process_SET_statement ;
     FoundPGM = POS('PGM=',Jclrecord);
     If FoundPGM > 0 THEN,
        DO
        PGM_NAME = Substr(Jclrecord,(FoundPGM+4));
        PGM_NAME = TRANSLATE(PGM_NAME,' ',',');
        PGM_NAME = WORD(PGM_NAME,1);
        Say 'Step:' Labelword 'PGM_NAME =' PGM_NAME ;
        Queue 'RELATE OBJECT' PGM_NAME '.'
        END ; /* If FoundPGM    .... */

     FoundDSN = POS('DSN=',Jclrecord);
     If FoundDSN > 0 THEN,
        DO
        DSN_NAME = Substr(Jclrecord,(FoundDSN+4));
        DSN_NAME = TRANSLATE(DSN_NAME,' ',',');
        DSN_NAME = WORD(DSN_NAME,1);
  /*    DatasetRef= 'DDNAM: before:' Labelword 'DSN=' DSN_NAME ; */
        If Substr(DSN_NAME,1,2) /= '5050'x then,
           Do
           $Model.1 = DSN_NAME ;
           $PLACE_VARIABLE = 1
           Call EVALUATE_SYMBOLICS;
           DSN_NAME= $Model.1
           End
        If Substr(DSN_NAME,1,1) /= '50'x then,
           Queue "RELATE OBJECT '"DSN_NAME"'."
        END ; /* If FoundDSN    .... */
/*                                                                    */
  End;  /*Do jcl# = 1 to JclRec.0 */

  "EXECIO" QUEUED() "DISKW RELATES (Finis"

  Exit

Process_SET_statement:

  pointer  = FoundSET+5
  Drop VariableName myQuoteChar tmp;
  whereEq  = Pos('=',Jclrecord,pointer)
  VariableName = Substr(Jclrecord,pointer)
  VariableName = Word(Translate(VariableName,' ','='),1)
  pointer  = whereEq +1
  myQuoteChar = Substr(Jclrecord,pointer,1)
  nextword = Word(Substr(Jclrecord,pointer),1)
  If myQuoteChar /= "'" & myQuoteChar /= '"' then,
     tmp = VariableName "='"nextword"'"
  Else,
     Do
     where1stQuote= pointer;
     tmp = VariableName "="
     where2ndQuote = Pos(myQuoteChar,Jclrecord,where1stQuote+1)
     valueLen = where2ndQuote - where1stQuote +1
     tmp = tmp || Substr(Jclrecord,where1stQuote,valueLen)
     End  /* value is quoted */
  Sa= 'SET:' tmp
  interpret tmp
  $All_VARIABLES = $All_VARIABLES VariableName

  Return


/*                                                                    */
/* The subroutine below is borrowed from the TBL#TOOL                 */
/*                                                                    */
EVALUATE_SYMBOLICS:

   DO FOREVER;
      $PLACE_VARIABLE = POS('&',$Model.$LINE,$PLACE_VARIABLE)
      IF $PLACE_VARIABLE = 0 THEN LEAVE;
      $temp_$LINE = TRANSLATE($Model.$LINE,' ',',.()"/\+-*|');
      $temp_$LINE = TRANSLATE($temp_$LINE,' ',"'"$delimiter);
      $table_word = WORD(SUBSTR($temp_$LINE,($PLACE_VARIABLE+1)),1);
      $table_word = TRANSLATE($table_word,'_','-') ;
      $varlen = LENGTH($table_word) + 1 ;

      if WORDPOS($table_word,$All_VARIABLES) = 0 then,
         do
         $PLACE_VARIABLE = $PLACE_VARIABLE + 1 ;
         iterate;
         end;

      $temp_word = VALUE($table_word) ;
      IF DATATYPE($temp_word,S) = 9 THEN,
         $temp = 'SYMBVALUE = ' $temp_word ;
      ELSE,
         $temp = "SYMBVALUE = '"$temp_word"'" ;
      INTERPRET $temp;
      SA= 'SYMBVALUE  = ' SYMBVALUE ;

      $tail = SUBSTR($Model.$LINE,($PLACE_VARIABLE+$varlen)) ;
      if Substr($tail,1,1) = $delimiter then,
         $tail = SUBSTR($tail,2) ;
      IF $PLACE_VARIABLE > 1 THEN,
         $Model.$LINE = ,
            SUBSTR($Model.$LINE,1,($PLACE_VARIABLE-1)) ||,
            SYMBVALUE || $tail ;
      else,
         $Model.$LINE = ,
            SYMBVALUE || $tail ;
      END; /* DO FOREVER */

   RETURN;

