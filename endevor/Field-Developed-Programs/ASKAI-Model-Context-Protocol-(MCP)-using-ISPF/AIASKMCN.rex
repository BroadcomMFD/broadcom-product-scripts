/*     REXX   */                                                        00000100
   "ISREDIT MACRO" ;                                                    00000200
    /* Save the Selected Text snippets */                               00000300
    Trace Off                                                           00000400
    Sa=     '(AIASKMCN)'                                                00000500
    ADDRESS ISREDIT " CUT AIASK "                                       00000600
    ADDRESS ISREDIT " CANCEL "                                          00000700
    EXIT                                                                00000800
                                                                        00000900
