/* REXX  */

   ADDRESS ISPEXEC
            'VGET (EN$BENV EN$BSYS EN$BSBS EN$BTYP EN$BSTGI EN$BSTGN ',
                 ' EN$SENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$SSTGN ',
                 ' EN$ELM DOTRACE) ',
            'SHARED'

   if DoTrace = 'Y' then Trace ?r

   /* Start with an Empty list of Library names & search words */
   INCLUDE_LIBRARY_LIST = ''
   Search_Words = ''

   /* Use the VGET variables to know the Endevor Classification  */
   /* for the element being Edited or Viewed                     */

   /* Assign one or more space  delimited dataset names */
   /* to the value of INCLUDE_LIBRARY_LIST.             */

   /* Optionally assign a list of space delimited values*/
   /* to the Search_Words variable.                     */
   /* If You are editing a COBOL element for example    */
   /* and you support ++INCLUDE references, then        */
   /* you could assign Search_Words to 'COPY ++INCLUDE'.*/

   /* If we are editing a processor             */
   IF EN$STYP = 'PROCESS' | EN$BTYP = 'PROCESS' THEN,
      Do
      /* If editing a processor, look for these references */
      Search_Words = '++INCLUDE' ;
      INCLUDE_LIBRARY_LIST =,
            'SYSMD32.NDVR.ADMIN.ENDEVOR.ADM1.INCLUDE',
            'SYSMD32.NDVR.ADMIN.ENDEVOR.ADM2.INCLUDE'
      /* Return both lists separated by double bar */
      return strip(Search_Words,'B')'||'strip(INCLUDE_LIBRARY_LIST,'B')
      End;

   /* If editing a JCL element ...                                 */
   If EN$BTYP = 'JCL' | EN$BTYP = 'JOB' then,
      Do
      Search_Words = "PROC= ++INCLUDE -INC EXEC   " ;
      lastnode = 'PROC'
      End
   Else,
   /*     COBOL or ASM .....                                       */
      Do
      lastnode = 'COPYBOOK'
      Search_Words = "COPY ++INCLUDE -INC INCLUDE PROC" ;
      End

   /* Looking at the DEV ENvironment      */
   IF EN$BENV = 'DEV' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSMD32.NDVR.'EN$BENV'.'EN$BSYS'.'EN$BSBS'.'lastnode,
            'SYSMD32.NDVR.QAS.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.PRD.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.SHARED.PROD.'lastnode
   Else,
   IF EN$BENV = 'QAS' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSMD32.NDVR.QAS.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.PRD.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.SHARED.PROD.'lastnode
   Else,
   IF EN$BENV = 'EMER' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSMD32.NDVR.EMER.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.PRD.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.SHARED.PROD.'lastnode
   Else,
   IF EN$BENV = 'PRD' THEN,
      INCLUDE_LIBRARY_LIST =,
            'SYSMD32.NDVR.PRD.'EN$BSYS'.ACCTPAY.'lastnode,
            'SYSMD32.NDVR.SHARED.PROD.'lastnode

  /* Return both lists separated by double bar */
  return strip(Search_Words,'B')'||'strip(INCLUDE_LIBRARY_LIST,'B')
