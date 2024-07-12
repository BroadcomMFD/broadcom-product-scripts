/*   REXX     */
/*                                                                    */
    "ISREDIT MACRO"
     /*Lets put our standard comment here */
/*   TRACE R ;                                                        */
/*   ADDRESS ISREXEC " CONTROL RETURN ERRORS " ;                      */
     ADDRESS ISREDIT " CURSOR = 1 1 " ;
     RETCODE = 0  ;
     ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
     DO WHILE RETCODE = 0
        ADDRESS ISREDIT " (DLINE) = LINE "LPOS1
         MYMBR = STRIP(SUBSTR(DLINE,15,22),T) ;
        ADDRESS ISREDIT " FIND './  ADD  NAME=' 1 "
         RETCODE = RC
        IF RETCODE > 0 THEN ,
           DO
           ADDRESS ISREDIT " CURSOR = .ZLAST " ;
           ADDRESS ISREDIT " (LPOS2,CPOS2) = CURSOR " ;
           IF LPOS2 > LPOS1 THEN,
              ADDRESS ISREDIT " REPLACE "MYMBR LPOS1+1 LPOS2
           REPRC = RC ;
           END ; /* IF RETCODE > 0 THEN */
        ELSE,
           DO
           ADDRESS ISREDIT " (LPOS2,CPOS2) = CURSOR " ;
           LPOS2 = LPOS2 - 1  ;
           IF LPOS1 < LPOS2 THEN,
              ADDRESS ISREDIT " REPLACE "MYMBR LPOS1+1 LPOS2
           REPRC = RC
           LPOS1 = 1
           IF SYSVAR(SYSENV) = 'BACK' THEN SAY MYMBR
           END;  /* ELSE (RETCODE ...) */
        IF REPRC = 0 THEN ,
           ADDRESS ISREDIT " DELETE "LPOS1  LPOS2 ;
      END;  /* DO WHILE RETCODE = 0 */
     ADDRESS ISREDIT " EXCLUDE ALL ";
     ADDRESS ISREDIT " FIND './  ADD  NAME=' 1 ALL" ;
     IF SYSVAR(SYSENV) = 'BACK' THEN ,
        ADDRESS ISREDIT " CANCEL "
     EXIT 0
