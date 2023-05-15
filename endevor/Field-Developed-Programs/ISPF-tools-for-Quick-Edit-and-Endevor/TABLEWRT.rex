 /* REXX   */
 /*THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED. */
   TRACE  o ;

   ADDRESS ISPEXEC,
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"
      where = POS('CALL ISPLINK(TBDISPL,',ZSCREENI)
      If where = 0 then,
         Do
         Say "What is the Table name ?"
         Pull Table;
         Table = Strip(Table) ;
         if Words(Table) /= 1 then Exit(8)
/*       ADDRESS ISPEXEC "TBEND   "Table */
         ADDRESS ISPEXEC "TBOPEN  "Table
         End ;
      Else,
         Do
         where = POS(",",ZSCREENI,where) ;
         what  = substr(ZSCREENI,where,70) ;
         what  = Translate(what," ",",");
         Table = Word(what,1) ;
         End ;

/*
   Pull Table ;
*/

  ADDRESS ISPEXEC
     "TBSTATS "Table" STATUS1(STATUS1) STATUS2(STATUS2)"
  /* FOR TABLE STATUS...                                             */
  /*  1 = TABLE EXISTS IN THE TABLE INPUT LIBRARY CHAIN              */
  /*  2 = TABLE DOES NOT EXIST IN THE TABLE INPUT LIBRARY CHAIN      */
  /*  3 = TABLE INPUT LIBRARY IS NOT ALLOCATED.                      */
  /*                                                                 */
  /*  1 = TABLE IS NOT OPEN IN THIS LOGICAL SCREEN                   */
  /*  2 = TABLE IS OPEN IN NOWRITE MODE IN THIS LOGICAL SCREEN       */
  /*  3 = TABLE IS OPEN IN WRITE MODE IN THIS LOGICAL SCREEN         */
  /*  4 = TABLE IS OPEN IN SHARED NOWRITE MODE IN THIS LOGICAL SCREEN*/
  /*  5 = TABLE IS OPEN IN SHARED WRITE MODE IN THIS LOGICAL SCREEN. */

  "TBQUERY "Table" KEYS(KEYLIST) NAMES(VARLIST) ROWNUM(ROWNUM)"
  IF RC > 0 THEN EXIT
  KEYLIST = TRANSLATE(KEYLIST," ","()',");
  VARLIST = TRANSLATE(VARLIST," ","()',");
  VARLIST = Strip(KEYLIST) STRIP(VARLIST);
  SA= "KEYLIST=" VARLIST;
  VariableCount = Words(VARLIST)

  "TBTOP   "Table
  VariableLength. = 8;

  DO Row# = 1 TO ROWNUM
     "TBSKIP "TABLE
     Do var# = 1 to VariableCount
        tmp = Value(Word(VARLIST,var#));
        tmpLen = Length(tmp)  ;
        If VariableLength.var# < tmpLen      then,
           VariableLength.var# = tmpLen   ;
        Var.Row#.var# = tmp
     End /* Do var# = 1 to VariableCount */
  End /* DO Row# = 1 TO ROWNUM */

  MyLrecl = 1;
  Do var# = 1 to VariableCount
     MyLrecl = MyLrecl + VariableLength.var# + 1;
  End /* Do var# = 1 to VariableCount */

  line = "*"
  Do var# = 1 to VariableCount
     line = line Left(Word(VARLIST,var#),VariableLength.var#,'-');
  End /* Do var# = 1 to VariableCount */
  Say line;
  Queue line;

  DO Row# = 1 TO ROWNUM
     line = " "
     Do var# = 1 to VariableCount
        line = line Left(Var.Row#.var#,VariableLength.var#);
     End /* Do var# = 1 to VariableCount */
     Sa= line;
     Queue line;
  End /* DO Row# = 1 TO ROWNUM */

  If where = 0 then,
     Do
     Say "Closing Table "
     ADDRESS ISPEXEC "TBEND   "Table
     End ;

  MyBlksz =  MyLrecl * 20 ;
  MyBlksz =  0 ;

  ADDRESS TSO,
    "ALLOC F(TBLSAVE)",
       "DA('SW.ENDV.SYQ.LIMA.TABLES("Table")')",
       "SHR REUSE "     ;

  ADDRESS TSO,
  "EXECIO" QUEUED() "DISKW TBLSAVE (FINIS"

   EXIT ;
  ADDRESS TSO,
    "ALLOC F(TBLSAVE) DA('"USERID()".SAVED."Table"')",
       "LRECL("MyLrecl") BLKSIZE("MyBlksz") SPACE(5,5)",
       "RECFM(F B) TRACKS ",
       "MOD CATALOG REUSE "     ;
