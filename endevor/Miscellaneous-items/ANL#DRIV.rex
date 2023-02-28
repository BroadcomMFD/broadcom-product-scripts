/*     REXX   */
/*                                                                    */
   /* WRITTEN BY DAN WALTHER */
/* CONTROL NOMSG NOSYMLIST NOCONLIST NOLIST NOPROMPT                  */
/* TRACE  R;                                                          */
   TRACE r   ;
/*                                                                    */
   ARG CONV#PDS START STOP ;

   PULL  SYSTEM
   PULL  SUBSYS
   PULL  TYPE
   SYSTEM = STRIP(SYSTEM)
   SUBSYS = STRIP(SUBSYS)
   TYPE   = STRIP(TYPE)

   /* Write Classification defaults based    */
   /* on received paramters ...              */
   /*  (SYSTEM, SUBSYSTEM, TYPe)             */
   Queue "SYSTEM. ='"SYSTEM"'"
   Queue "SUBSYS. ='"SUBSYS"'"
   If TYPE = '' then,
      Queue "TYPE.   ='UNKNOWN'"
   Else,
      Queue "TYPE.   ='"TYPE"'"
   "EXECIO" QUEUED() "DISKW CLASSIF"

/*                                                                   */
/* EXAMINE ALL MEMBERS OF CONV#PDS LIBRARY - EXECUTE ANL#VIEW TO     */
/*         DETERMINE A VALUE FOR ENDEVOR TYPE                        */
/*                                                                   */

   ADDRESS ISPEXEC " LMINIT DATAID(MYPDS) DATASET('"CONV#PDS"') ";
   IF RC > 0 THEN,
      DO
      SAY '***ERROR ATTEMPTING TO DO LMINIT'
      EXIT(8)
      END;

   ADDRESS ISPEXEC " LMOPEN DATAID("MYPDS") OPTION(INPUT) " ;

   DO FOREVER
      ADDRESS ISPEXEC " LMMLIST DATAID("MYPDS") OPTION(LIST) ",
                     "MEMBER(nextMbr) STATS(NO) " ;
      RCODE = RC ;
      IF RCODE > 0 THEN LEAVE;
      nextMbr = STRIP(nextMbr);
      IF nextMbr < START THEN SAY 'SKIPPING 'nextMbr;
      ELSE,
      IF nextMbr > STOP  THEN LEAVE ;
      ELSE,
         DO
         MapperRC = 0
         IF SYSTEM = '' | SUBSYS = '' then,
            Call Do_MAPPER;
         If TYPE /= ''   then Iterate ; /* All are the same type*/
         If MapperRC = 1 then Iterate ; /* Mapper assigned Type*/
         SAY '  VIEWING 'nextMbr ;
         ADDRESS ISPEXEC "VIEW DATASET('"CONV#PDS"("nextMbr")') ",
                    "MACRO(ANL#VIEW)" ;
         END;
      END; /* DO FOREVER */
/*                                                                   */
   ADDRESS ISPEXEC " LMCLOSE DATAID(MYPDS) ";

   ADDRESS ISPEXEC " LMFREE DATAID("MYPDS") " ;

/*                                                                   */
   "EXECIO 0 DISKW CLASSIF (Finis"

   EXIT ;
/*                                                                  */

Do_MAPPER:

      SAY '  Mapping 'nextMbr ;
      Call MAPPER CONV#PDS nextMbr
      MapperRC = RC

      /* Write To Endevor Classification info   */
      /*  (SYSTEM, SUBSYSTEM, TYPe)             */
      "EXECIO" QUEUED() "DISKW CLASSIF"

   Return
