/*  REXX  */
/* See CA's  Tech Document
   Document ID:    TEC315509
   Title:  Alternate ID Swapping for DB2 Binds, Under CA Endevor Change
         Switch to User's id

   Can be called from either a TSO or non-TSO environment
*/
  "Execio 0 Diskr LGNT$$$I (Finis"   /*  Switch to User's id */
  "Execio 0 Diskr LGNT$$$O (Open "
  "Execio 0 Diskr LGNT$$$O (Finis"
   STRING = "FREE DD(LGNT$$$I)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(LGNT$$$O)" ;
   CALL BPXWDYN STRING;

   Exit

