/*     REXX   */
/*                                                                     */
   "ISREDIT MACRO (PREFIX) " ;
   /* WRITTEN BY DAN WALTHER */
/* EDIT or View a new member, then use MOVEIN on the command line      */
/*  All other members of the dataset are copied into your new member.  */
/*  with an IEBUPDTE delimiter between them.                           */
/*  If you only want selected members then use a member prefix         */
/*  For example if only wanting members whose names begin with AB*     */
/*   then enter      MOVEIN AB                                         */
/* TRACE  R;                                                           */
   ADDRESS ISPEXEC " CONTROL RETURN ERRORS " ;
   PREFIXLN = LENGTH(PREFIX) ;
   ADDRESS ISREDIT " UNNUM " ;
   ADDRESS ISREDIT " (MEMBER) = MEMBER " ;
   ADDRESS ISREDIT " (DATASET) = DATASET " ;
   ADDRESS ISPEXEC " LMINIT DATAID(MYPDS) DATASET('"DATASET"') " ;
   ADDRESS ISPEXEC " LMOPEN DATAID("MYPDS") OPTION(INPUT) " ;
   TEMP_STRING = PREFIX ;
   RCODE = RC
   CNT = 0
   DO WHILE RCODE = 0
      ADDRESS ISPEXEC " LMMLIST DATAID("MYPDS") OPTION(LIST) ",
                     "MEMBER(MYMBR) STATS(NO) "  ;
      RCODE = RC ;
      MYMBR = STRIP(MYMBR); 
      IF PREFIXLN > 0 THEN ,
         TEMP        = MYMBR || '        ' ;
         TEMP_STRING = STRIP(SUBSTR(TEMP,1,PREFIXLN),B) ;
      IF RCODE = 0 THEN ,
       IF MYMBR /= MEMBER THEN ,
         DO
         IF PREFIX = TEMP_STRING THEN CALL DO_INSERT;
         ELSE ,
         IF PREFIXLN = 0 THEN CALL DO_INSERT ;
         END ;
      END;
   ADDRESS ISPEXEC " LMCLOSE DATAID(MYPDS) ";
   ADDRESS ISREDIT " EXCLUDE ALL " ;
   ADDRESS ISREDIT " FIND './  ADD  NAME=' 1 ALL " ;
   IF SYSVAR(SYSENV) = BACK THEN ,
      DO
      ADDRESS ISREDIT " SAVE
      ADDRESS ISREDIT " CANCEL
      END
   EXIT 0
DO_INSERT:
   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE './  ADD  NAME="MYMBR"'" ;
   ADDRESS ISREDIT " COPY "MYMBR"  AFTER .ZL " ;
   RX = RC ;
   RETURN ;
