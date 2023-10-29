/* REXX  */

   ADDRESS ISPEXEC
         'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN
                ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN
                ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN)
          PROFILE'

   if DoTrace = 'Y' then Trace ?r

   /* Start with an Empty list of Library names */
   INCLUDE_LIBRARY_LIST = ' ' ;

   /* Use the VGET variables to know the Endevor Classification  */
   /* for the element being Edited or Viewed                     */

   /* Assign one or more space  delimited dataset names */
   /* to the value of INCLUDE_LIBRARY_LIST.             */

   /* Optionally assign a list of space delimited values*/
   /* to the Search_Words variable.                     */
   /* You are editing a COBOL element for example,      */
   /* and you support ++INCLUDE references, then        */
   /* you could assign Search_Words to 'COPY ++INCLUDE'.*/

   Search_Words = 'COPY' ;
   IF ENVSTYP = 'PROCESS' | ENVBTYP = 'PROCESS' THEN,
      do
      Search_Words = '-INC' ;
      INCLUDE_LIBRARY_LIST =,
            'NDVR.DEN.COPYLIB',
            'NDVR.PEN.COPYLIB'
      end;

   If ENVBTYP = 'JCL' | ENVBTYP = 'JOB' then lastnode = 'PROCLIB'
   ELSE                                      lastnode = 'COPYLIB'

   /* Looking at the DEV Environment  ?   */
   IF ENVBENV = 'TEST' & ENVBSTGI = 'T' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.T'ENVBSYS'.'lastnode,
            'NDVR.C'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'TEST' & ENVBSTGI = 'C' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.C'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'QA'  & ENVBSTGI = 'A' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'PROD' & ENVBSTGI = 'Z' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.Z'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'PROD' & ENVBSTGI = 'P' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'PREP'  & ENVBSTGI = 'S' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.S'ENVBSYS'.'lastnode,
            'NDVR.J'ENVBSYS'.'lastnode,
            'NDVR.Y'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'PREP'  & ENVBSTGI = 'J' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.S'ENVBSYS'.'lastnode,
            'NDVR.J'ENVBSYS'.'lastnode,
            'NDVR.Y'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'PARQA' & ENVBSTGI = 'Y' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.Y'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'MAINT' & ENVBSTGI = 'M' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.M'ENVBSYS'.'lastnode,
            'NDVR.I'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'MAINT' & ENVBSTGI = 'I' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.I'ENVBSYS'.'lastnode,
            'NDVR.A'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'ADMIN' & ENVBSTGI = 'D' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.D'ENVBSYS'.'lastnode,
            'NDVR.P'ENVBSYS'.'lastnode
   Else,
   IF ENVBENV = 'ADMIN' & ENVBSTGI = 'P' THEN,
      INCLUDE_LIBRARY_LIST =,
            'NDVR.P'ENVBSYS'.'lastnode

  If lastnode = 'COPYLIB' then,
    Search_Words = "COPY ++INCLUDE -INC INCLUDE PROC" ;
  If lastnode = 'PROCLIB' then,
    Search_Words = "PROC= ++INCLUDE -INC EXEC   " ;

  return Search_Words ' || ' INCLUDE_LIBRARY_LIST

