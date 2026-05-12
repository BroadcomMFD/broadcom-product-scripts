/*   REXX   */
   Arg thisEnv thisStg ;
  /*    For the given thisEnv and thisStg,                         */
  /*    Return the mapped next Env and Stage Id.                   */
   Trace o
   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(EXTRACTS) LRECL(1000) BLKSIZE(32000) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTIPT01) LRECL(80)   BLKSIZE(24000) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   QUEUE 'LIST STAGE' thisStg "FROM ENVIRONMENT '"thisEnv"'"
   QUEUE "   TO DDNAME 'EXTRACTS'             "
   QUEUE "   OPTIONS PATH LOGICAL SEARCH RETURN ALL NOCSV .   "
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";
   CSVParm = 'DDN:CONLIB,BC1PCSV0'
   ADDRESS LINKMVS 'CONCALL' "CSVParm"
   call_rc = rc ;
   "EXECIO * DISKR EXTRACTS (STEM NOCSV. finis"
   /* NOCSV.1 contains info for thisEnv and thisStg */
   /* the mapped location is found in NOCSV.2       */
   record = NOCSV.2
   NEXT_ENV   = Word(Substr(record,14),1)
   NEXT_STG_# = Substr(record,22,1)
   CALL BPXWDYN "FREE DD(EXTRACTS)" ;
   CALL BPXWDYN "FREE DD(BSTIPT01)" ;
   CALL BPXWDYN "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN "FREE DD(BSTERR)" ;
   Return NEXT_ENV NEXT_STG_#
