/*     REXX   */
  "ISREDIT MACRO" ;
  TRACE Off ;

  /* AIASK - construct a Query and call MCP for Results       */

  IneedExpert = ''
  /* Determine whether user has selected text                 */
  /* by excluding unwanted text                               */
  Address ISREDIT "FLIP"
  Address ISREDIT "FIND p'=' 1 NX"
  findRC = RC
  If findRC = 0 then,
     Do
     Address ISREDIT "FIND 'IDENTIFICATION' WORD FIRST"
     If RC = 0 then IneedExpert = 'a COBOL Expert'
     If IneedExpert = '' then,
        Do
        Address ISREDIT "FIND 'C1G0202I' WORD FIRST"
        If RC = 0 then IneedExpert = 'an Endevor Admin'
        End
     If IneedExpert = '' then,
        Do
        Address ISREDIT "FIND ' E N D E V O R ' FIRST"
        If RC = 0 then IneedExpert = 'an Endevor Admin'
        End
     End
  Address ISREDIT "FLIP"
  If findRC = 0 then,
     Do
     Address ISREDIT "CUT NX AIASK REPLACE "
     cutRC = RC
     End
  If IneedExpert = '' then,
     Do
     Address ISREDIT "FIND 'IDENTIFICATION' WORD FIRST NX"
     If RC = 0 then IneedExpert = 'a COBOL Expert'
     End


  CALL BPXWDYN "INFO FI(QUERY)",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  if Substr(DSNVAR,1,1) > ' ' then,
     ADDRESS TSO "FREE  F(QUERY)"

  /* Allocate an empty dataset for the query */
  /* Leverages the pre-existing generic edit macro named WITHMSG */
  ADDRESS TSO,
    "ALLOC F(QUERY) LRECL(140) BLKSIZE(28000) SPACE(5,5)",
         "RECFM(F B) TRACKS ",
         "NEW UNCATALOG REUSE "
  Push "Act like **AnExpert** and explain the following:"
  ADDRESS TSO "EXECIO 1 DISKW QUERY (Finis"

  ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(QUERY)"

  /* If text was selected (exposed not hidden) paste it here */
  If findRC = 0 then,
      ADDRESS ISPEXEC "EDIT DATAID(&DDID) MACRO(AIASKMPA)"

  /* Insert standard messages for AIASK                      */
  /* ... and allow user to enter text...                     */
  If IneedExpert /= '' then Push IneedExpert
  ADDRESS ISPEXEC "EDIT DATAID(&DDID) MACRO(AIASKMSG)"
  If RC > 0 then Exit

  ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"

  /* Now call the Rexx that calls Python
     and shows the results                   */
  Call AIASKPY

  ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"

  Exit

