/*   REXX     */
/*                                                                    */
    "ISREDIT MACRO"
     /* WRITTEN BY DAN Person */
/*   TRACE R ;                                                        */
/*   ADDRESS ISREXEC " CONTROL RETURN ERRORS " ;                      */
     ADDRESS ISREDIT " (MEMBER) = MEMBER " ;
     ADDRESS ISREDIT " RESET " ;
     ADDRESS ISREDIT " EXCLUDE '//*' 1 ALL ";
     ADDRESS ISREDIT " DELETE ALL X " ;
     ADDRESS ISREDIT " CURSOR = 1 1 " ;
     ADDRESS ISREDIT " FIND 'EXEC' WORD NEXT   "
     RETCODE = 0  ;
     STEPS.0 = 0 ;
     NUMBER_STEPS = 0;
     ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
     DO WHILE RETCODE = 0
        ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
        ADDRESS ISREDIT " (DLINE) = LINE "LPOS1
        DLINE = TRANSLATE(DLINE,' ',',');
        MYMBR = STRIP(WORD(SUBSTR(DLINE,3,8),1),T) ;
        MYMBR = STRIP(MYMBR,B,',') ;
        MYMBR = STRIP(MYMBR,B,' ') ;
        MYMBR = STRIP(MYMBR,B,',') ;
        IF LENGTH(MYMBR) = 0 THEN,
           DO
           ADDRESS ISREDIT " FIND 'EXEC' WORD NEXT   "
           ITERATE ;
           END;
        IF SYSVAR(SYSENV) = FORE THEN ,
           SA= 'PROCESSING MEMBER ' MYMBR ;
        NUMBER_STEPS = NUMBER_STEPS + 1 ;
        STEPS.NUMBER_STEPS = MYMBR ;
        ADDRESS ISREDIT " FIND 'EXEC' WORD NEXT   "
        RETCODE = RC ;
        IF RETCODE > 0 THEN ,
           ADDRESS ISREDIT " CURSOR = .ZLAST " ;
        ADDRESS ISREDIT " (LPOS2,CPOS2) = CURSOR " ;
        IF RETCODE = 0 THEN ,
           LPOS2 = LPOS2 - 1  ;
        ADDRESS ISREDIT " REPLACE "MYMBR LPOS1 LPOS2 ;
         REPRC = RC
        IF REPRC = 0 THEN ,
           ADDRESS ISREDIT " DELETE "LPOS1  LPOS2 ;
        IF RETCODE = 0 THEN ,
           DO
           ADDRESS ISREDIT " CURSOR = 1 1 " ;
           ADDRESS ISREDIT " FIND 'EXEC' WORD NEXT   "
           END;
        END ;
     ADDRESS ISREDIT " CURSOR = .ZLAST " ;
     ADDRESS ISREDIT " (LPOS2,CPOS2) = CURSOR " ;
     LPOS2 = LPOS2 + 1;
     IF NUMBER_STEPS > 0 THEN,
        DO
        ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
         "DATALINE '//SUPERCS EXEC SUPERCST,MEMBER="MEMBER"'" ;
        DO I = 1 TO NUMBER_STEPS
           OLD_PREFIX = SUBSTR(STEPS.I,1,4) ;
           OLD_PREFIX = STRIP(OLD_PREFIX) ;
           ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '//SUPERC1 EXEC SUPERC,MEMBER="STEPS.I ||,
            ",PROCESSR="MEMBER",OLD="OLD_PREFIX"'" ;
           END ;
        ADDRESS ISREDIT " REPLACE #STEPS "LPOS2 ".ZL" ;
        ADDRESS ISREDIT " DELETE "LPOS2 ".ZL" ;
        END ;
     ADDRESS ISREDIT " CANCEL " ;
     EXIT 0
