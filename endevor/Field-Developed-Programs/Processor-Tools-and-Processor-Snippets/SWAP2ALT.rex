/*  REXX  */
/* See CA's  Tech Document
   Document ID:    TEC315509
   Title:  Alternate ID Swapping for DB2 Binds, Under CA Endevor Change
         Switch to Endevor AltID

   Can be called from either a TSO or non-TSO environment
*/

   STRING = "ALLOC DD(LGNT$$$I) DUMMY REUSE"
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(LGNT$$$O) DUMMY REUSE"
   CALL BPXWDYN STRING;
  "Execio 0 Diskr LGNT$$$I (Open "   /*  Switch to Endevor AltID */
   STRING = "ALLOC DD(READER)",
              " RECFM(F) BLKSIZE(80) LRECL(80)",
               "SYSOUT(A) WRITER(INTRDR) REUSE " ;
   CALL BPXWDYN STRING;

   Exit

