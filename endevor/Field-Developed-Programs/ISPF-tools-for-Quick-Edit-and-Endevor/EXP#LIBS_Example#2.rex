/* REXX  */

   ADDRESS ISPEXEC
            'VGET (EN$BENV EN$BSYS EN$BSBS EN$BTYP EN$BSTGI EN$BSTGN ',
                 ' EN$SENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$SSTGN ',
                 ' EN$ELM DOTRACE) ',
            'SHARED'

   if DoTrace = 'Y' then Trace ?r

   /* Start with an Empty list of Library names */
   INCLUDE_LIBRARY_LIST = ' ' ;

   /* Use the VGET variables to know the Endevor Classification  */
   /* for the element being Edited or Viewed                     */

   /* Assign one or more space  delimited dataset names */
   /* to the value of INCLUDE_LIBRARY_LIST.             */

   /* Optionally assign a list of space delimited values*/
   /* to the Search_Words variable.                     */
   /* If You are editing a COBOL element for example    */
   /* and you support ++INCLUDE references, then        */
   /* you could assign Search_Words to 'COPY ++INCLUDE'.*/

   Search_Words = 'COPY' ;
   IF EN$STYP = 'PROCESS' | EN$BTYP = 'PROCESS' THEN,
      do
      Search_Words = '-INC' ;
      INCLUDE_LIBRARY_LIST =,
            'NDVR.DEN.COPYLIB',
            'NDVR.PEN.COPYLIB'
      end;

   If EN$BTYP = 'JCL' | EN$BTYP = 'JOB' then lastnode = 'PROCLIB'
   ELSE                                      lastnode = 'COPYLIB'

   /* Looking at the DEV Environment  ?   */
   IF EN$BENV = 'TEST' & EN$BSTGI = 'T' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.T'EN$BSYS'.'lastnode,
            'NDVR.C'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'TEST' & EN$BSTGI = 'C' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.C'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'QA'  & EN$BSTGI = 'A' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'PROD' & EN$BSTGI = 'Z' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.Z'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'PROD' & EN$BSTGI = 'P' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'PREP'  & EN$BSTGI = 'S' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.S'EN$BSYS'.'lastnode,
            'NDVR.J'EN$BSYS'.'lastnode,
            'NDVR.Y'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'PREP'  & EN$BSTGI = 'J' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.S'EN$BSYS'.'lastnode,
            'NDVR.J'EN$BSYS'.'lastnode,
            'NDVR.Y'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'PARQA' & EN$BSTGI = 'Y' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.Y'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'MAINT' & EN$BSTGI = 'M' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.M'EN$BSYS'.'lastnode,
            'NDVR.I'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'MAINT' & EN$BSTGI = 'I' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.I'EN$BSYS'.'lastnode,
            'NDVR.A'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'ADMIN' & EN$BSTGI = 'D' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.D'EN$BSYS'.'lastnode,
            'NDVR.P'EN$BSYS'.'lastnode
   Else,
   IF EN$BENV = 'ADMIN' & EN$BSTGI = 'P' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.P'EN$BSYS'.'lastnode

  If lastnode = 'COPYLIB' then,
    Search_Words = "COPY ++INCLUDE -INC INCLUDE PROC" ;
  If lastnode = 'PROCLIB' then,
    Search_Words = "PROC= ++INCLUDE -INC EXEC   " ;

  return Search_Words ' || ' INCLUDE_LIBRARY_LIST

