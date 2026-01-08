/*     REXX   */
  "ISREDIT MACRO" ;
  /* While observing a panel (not in edit) invoke Ai Ask */
  TRACE Off
  myName =  'AIASKP'

  ADDRESS ISPEXEC "VGET (ZPANELID) SHARED"
  sa= "You are using ISPF panel" ZPANELID

  sa= 'Screen processing'
  ADDRESS ISPEXEC,
     "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"

  $delimiters = ' ,*="?'"'" ;
  Do forever
     if zscreenc = 1 then leave;
     char = Substr(zscreeni,zscreenc,1) ;
     if Pos(char,$delimiters) > 0 then leave
     if char = '.' | datatype(char,alphanumeric) = 1 then,
        zscreenc = zscreenc - 1;
     else leave;
  End; /* do forever */

  pointedWord = Word(Substr(ZSCREENI,(ZSCREENC+1),80),1)
  Upper pointedWord
  sa= "pointedWord=>>"pointedWord"<<    myName=" myName
  linestart  = 1 + (ZSCREENC % 80) * 80
  pointedLine = Substr(ZSCREENI,linestart,80)
  sa= "pointedLine=>> " Substr(ZSCREENI,linestart,65)


  IneedExpert = AIASKEXP()

  If IneedExpert = '?' then,
     Do
     Say 'Not finding the cursor being used as a pointer'
     Say 'Exiting with nothing selected'
     Exit
     End

  CALL BPXWDYN "INFO FI(QUERY)",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  if Substr(DSNVAR,1,1) > ' ' then,
     ADDRESS TSO "FREE  F(QUERY)"

  /* Allocate an empty dataset for the query */
  /* Leverages the pre-existing generic edit macro named WITHMSG */
  ADDRESS TSO,
    "ALLOC F(QUERY) LRECL(140) BLKSIZE(28000) SPACE(5,5)",
         "RECFM(F B) TRACKS ",
         "NEW UNCATALOG REUSE "

  Sa= pointedWord   myName

  If pointedWord = myName then,
     Do
     /* Capture the whole scren for the query */
     where = Pos('Command ',ZSCREENI)
     If where = 0 then where = Pos('COMMAND ==',ZSCREENI)
     If where = 0 then where = Pos('OPTION ===> ',ZSCREENI)
     If where = 0 then where = 83
     wherebegin = where % 80
     wherestart = 80 * (wherebegin + 1) + 2
     Do char# = wherestart by 80 to Length(ZSCREENI)
        thisline = Substr(ZSCREENI,char#,80)
        If Pos('****** Top of Data ****',thisline) > 0 then iterate
        If Pos(' -  -  -  -  -  -  -  -',thisline) > 0 then iterate
        If Pos('****** Bottom of Data *',thisline) > 0 then iterate
        Queue Substr(thisline,1,80)
     End /* Do char# = wherestart by 80 to ... */
     If Abbrev(ZPANELID,'ISREDDE') then,
        Push "Act like" IneedExpert "and explain",
             "what I am seeing here:"
     Else,
        Push "Act like" IneedExpert "and explain the details",
             "of the" ZPANELID "panel:"
     Address TSO "EXECIO" QUEUED() "DISKW QUERY ( Finis"
     End /* If pointedWord = myName  */
  Else,
     Do
     Push pointedLine
     If Abbrev(ZPANELID,'ISREDDE') then,
        Push "Act like" IneedExpert "and explain this message:"
     Else,
        Push "Act like" IneedExpert "and explain this portion",
             "of the" ZPANELID "panel:"
     ADDRESS TSO "EXECIO 2 DISKW QUERY (Finis"
     End

  ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(QUERY)"

  /* If text was selected (exposed not hidden) paste it here */
  If findRC = 0 then,
      ADDRESS ISPEXEC "EDIT DATAID(&DDID) MACRO(AIASKMPA)"

  /* Insert standard messages for AIASK                      */
  /* ... and allow user to enter text...                     */
  If IneedExpert /= '' then Push IneedExpert
  ADDRESS ISPEXEC "EDIT DATAID(&DDID) MACRO(AIASKMSG)"
  If RC > 0 then Exit

  ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"

  /* Now call the Rexx that calls Python
     and shows the results                   */
  Call AIASKPY

  ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"

  Exit
