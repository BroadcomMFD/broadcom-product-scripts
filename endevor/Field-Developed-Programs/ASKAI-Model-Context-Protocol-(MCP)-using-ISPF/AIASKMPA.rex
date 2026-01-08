/*     REXX   */                                                        00000100
   "ISREDIT MACRO" ;                                                    00000200
    /* Save the Selected Text snippets */                               00000300
    Trace Off                                                           00000400
    Sa=     'PSP.CLIST(AIASKMPA)'                                       00000500
    ADDRESS ISREDIT " PASTE AIASK AFTER .ZLAST  DELETE"                 00000600
    ADDRESS ISREDIT " SAVE "                                            00000700
    ADDRESS ISREDIT " CANCEL "                                          00000800
    EXIT                                                                00000900
                                                                        00001000
