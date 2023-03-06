/*    REXX     */
   'ISREDIT MACRO (STRT STOP)'
/* ARG START_COL STOP_COL ;                                          */
   ADDRESS ISREDIT;
/*                                                                   */
/* TRACE R;                                                          */
   START_COL = STRT;
   STOP_COL  = STOP ;
   IF START_COL < 1 THEN START_COL = 1 ;
   IF STOP_COL  < 1 THEN STOP_COL = 80 ;
   IF STOP_COL  < START_COL THEN STOP_COL = START_COL ;
   LEN = STOP_COL - START_COL + 1;
   RC = 0;
   LASTLINE = '' ;
    "FIND P'=' 1 FIRST "
   XCOUNT = 0 ;
   DO UNTIL RC > 0
     "(LP CP)=CURSOR"
     "(DATALINE)=LINE" LP
     IF SUBSTR(LASTLINE,START_COL,LEN) =,
        SUBSTR(DATALINE,START_COL,LEN) THEN,
        DO
        XCOUNT = XCOUNT + 1;
        "EXCLUDE P'=' "
        IF XCOUNT = 1 THEN,
           DO
           "FIND P'=' 1 NX PREV"
           "EXCLUDE P'=' "
           END;
        END;
     ELSE,
        XCOUNT = 0 ;
    LASTLINE = DATALINE ;
    "FIND P'=' 1 NX NEXT"
     END;