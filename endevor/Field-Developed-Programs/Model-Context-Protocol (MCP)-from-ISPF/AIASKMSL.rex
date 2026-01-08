/*     REXX   */
   "ISREDIT MACRO" ;
    /* Save the Selected Text snippets */
    Sa=     'PSP.CLIST(AIASKM01)'
    ADDRESS ISREDIT " PASTE AFTER .ZLAST  DELETE"
    ADDRESS ISREDIT " SAVE "
    ADDRESS ISREDIT " CANCEL "
    EXIT

