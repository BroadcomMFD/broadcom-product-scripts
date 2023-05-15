/*  Create any type with the 1st four letters of 'FORM', then        */
/*     create a panel with the same name as the type.                */
/*     When you are done, persons who edit elements of the FORM*     */
/*     type will be directed to the panel of the same name, and not  */
/*     the typical ISPF edit session used by Quick Edit.             */
/*     You are on your own for processors for each type, but         */
/*     ENBPIU00  can help.                                           */
    IF SUBSTR(ENVBTYP,1,4) = 'FORM' THEN,
       DO
       IF LINE > 0 THEN,
          DO
          ADDRESS ISREDIT " CURSOR = 1 1 " ;
          IF RC > 0 THEN EXIT
          ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
          IF RC > 0 THEN EXIT
          DO FOREVER
             ADDRESS ISREDIT " (DLINE) = LINE "LPOS1
             IF SUBSTR(DLINE,1,1) /= "|" THEN,
                INTERPRET DLINE ;
             ADDRESS ISREDIT " FIND P'=' 1 NEXT" ;
             IF RC > 0 THEN LEAVE;
             ADDRESS ISREDIT " (LPOS1,CPOS1) = CURSOR " ;
          END;  /* DO FOREVER */
       END;  /*IF LINE = 0 */
       ADDRESS ISPEXEC,
           "DISPLAY PANEL ("ENVBTYP") "
       IF RC > 0 THEN MY_RC = 24 ;
       ELSE           MY_RC = 20 ;
       ADDRESS ISREDIT " DELETE ALL NX" ;
       ADDRESS ISREDIT " CAPS OFF "     ;
       WHERE = 'LINE_AFTER' ;
       TEMP = "|"COPIES("_",80) ;
       'ISREDIT ' WHERE '.ZLAST = DATALINE "'TEMP'"' ;
       ADDRESS ISPEXEC,
           "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"

       DO W# = 1 TO LENGTH(ZSCREENI) BY 80
          TEMP = "|"SUBSTR(ZSCREENI,W#,80) ;
         'ISREDIT ' WHERE '.ZLAST = DATALINE "'TEMP'"' ;
       END

       TEMP = "|"COPIES("_",80) ;
       'ISREDIT ' WHERE '.ZLAST = DATALINE "'TEMP'"' ;

       DO W# = 1 TO WORDS(FIELDS)
          TEMP = " "WORD(FIELDS,W#) "=",
             "'"VALUE(WORD(FIELDS,W#))"'" ;
         'ISREDIT ' WHERE '.ZLAST = DATALINE "'TEMP'"' ;
       END

       ADDRESS ISREDIT 'SAVE'
       EXIT(MY_RC) ;
       END; /* IF SUBSTR(ENVBTYP,1,4) = 'FORM' */
