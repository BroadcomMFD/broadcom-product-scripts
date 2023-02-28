/*     REXX   */
/*                                                                    */
   "ISREDIT MACRO" ;
   /* WRITTEN BY DAN WALTHER */
   TRACE  o  ;
     ADDRESS ISREDIT;
     " CURSOR = 1 1 " ;
     DO forever;
        "FIND p'=' 72 nx next " ;
        if rc > 0 then leave;
        ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
        ADDRESS ISREDIT "findwrd1 UP DEFINE "
        "CURSOR = "LPOS1 1  ;
        ADDRESS ISREDIT "findwrd1 down . "
        ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
        "CURSOR = "LPOS1 72 ;
        end;
   EXIT 0
