/*     REXX   */
   "ISREDIT MACRO" ;
    /* Format and Show the AIASK response         */
    /* Use Text Flow command to slim the response */
    /* to a 72-character-wide display.            */
    Sa=     '(AIASKMRS)'
   TRACE Off ;

   Address ISREDIT "RESET"
   Address ISREDIT "EXCLUDE ALL"
   Address ISREDIT "FIND p'#$' 1 all"
   Address ISREDIT "FIND p'##$' 1 all"
   Address ISREDIT "CURSOR = " 1 1
   Do 300
      Address ISREDIT "FIND NEXT P'#' 1 NX"
      If RC > 0 then Leave
      ADDRESS ISREDIT " LINE_AFTER .ZCSR = DATALINE ' '" ;
      If RC > 0 then Leave
   End;

   Address ISREDIT "FIND LAST  ' ' 1   "
   If RC > 0 then exit
   Address ISREDIT "FIND NEXT  p'^' 1   "
   If RC > 0 then Exit
   Do 300
      Address ISREDIT "TFLOW .ZCSR 72"
      Address ISREDIT "FIND PREV  '  ' 1   "
      If RC > 0 then Leave
      Address ISREDIT "FIND PREV  p'^' 1   "
      If RC > 0 then Leave
      Address ISREDIT "FIND PREV  '  ' 1   "
      If RC > 0 then Leave
      Address ISREDIT "FIND NEXT  p'^' 1   "
      If RC > 0 then Leave
      ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
      If LPOS1 < 3 then Leave
   End;
   Address ISREDIT "RESET"
   Address ISREDIT "CUT AIASK"

   EXIT

