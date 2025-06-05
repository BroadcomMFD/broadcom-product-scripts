/* REXX  */
/* Get the running-job's accounting code  */
/* Job can be batch or User's tso session */
  CALL BPXWDYN ,
    "ALLOC DD(JOBINFO) LRECL(80) BLKSIZE(8000) SPACE(1,1) ",
       " RECFM(F,B) TRACKS ",
       " NEW UNCATALOG REUSE ";
  GETJOBNM
  "EXECIO * DISKR JOBINFO  (stem job. FINIS ";
  CALL BPXWDYN "FREE  DD(JOBINFO)"
  Do j# = 1 to job.0
     If Substr(job.j#,1,15) = 'accounting_code' then,
        Return Strip(Word(Substr(job.j#,17),1),"B","'")
  End
  Return '0'
