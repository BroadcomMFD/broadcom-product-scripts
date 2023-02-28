/*     REXX   */                                                        02140000
/*                                                                    */02150000
   "ISREDIT MACRO (directn lit)" ;                                      02160000
   /* WRITTEN BY DAN WALTHER */                                         02170000
   TRACE o;                                                             02180000
     ADDRESS ISREDIT;                                                   02190000
     do forever ;                                                       02200000
       ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;                     02210000
       sa= 'at line ' LPOS1  ;                                          02220000
       ADDRESS ISREDIT " (DLINE) = LINE "LPOS1                          02230000
       temp = word(dline,1);                                            02240000
       if word(dline,1) = lit then leave;                               02250000
       if directn = 'UP' then,                                          02260000
          DO                                                            02270000
          'find p"=" 'CPOS1 'prev'                                      02280000
           if rc > 0 then leave;                                        02290000
          END; /* if directn = 'UP' then */                             02300000
        else,                                                           02310000
          DO                                                            02320000
          'find p"=" 1 '                                                02330000
           if rc > 0 then leave;                                        02340000
          END; /* else                   */                             02350000
     end; /* do forever */                                              02360000
   EXIT 0                                                               02370000
