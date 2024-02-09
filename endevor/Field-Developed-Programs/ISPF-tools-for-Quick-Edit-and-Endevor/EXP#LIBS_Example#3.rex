/* REXX  - set Site Specific search words and library names */

/* Use the VGET variables to know the Endevor Classification  */
/* for the element being Edited or Viewed                     */
ADDRESS ISPEXEC ,
    "VGET (EN$BENV EN$BSYS EN$BSBS EN$BTYP EN$BSTGI EN$BSTGN",
          "EN$SENV EN$SSYS EN$SSBS EN$STYP EN$SSTGI EN$SSTGN",
          "EN$ELM DOTRACE",
         ") SHARED"

/* Assign one or more space  delimited dataset names */
/* to the value of INCLUDE_LIBRARY_LIST.             */

/* Start with an Empty list of Library names & search words */
INCLUDE_LIBRARY_LIST = ''
Search_Words = ''

/* Optionally assign a list of space delimited values*/
/* to the Search_Words variable.                     */
/* If You are editing a COBOL element for example    */
/* and you support ++INCLUDE references, then        */
/* you could assign Search_Words to 'COPY ++INCLUDE'.*/

If EN$BTYP = 'JCL',     /* jobs and JCL search PROCLIBs */
 | EN$BTYP = 'JOB' then do
      lastnode = 'PROCLIB'
      Search_Words = "PROC= INCLUDE= -INC EXEC"
   end
ELSE do
      lastnode = 'COPYLIB' /* everything else uses COPYLIB */
      Search_Words = "COPY ++INCLUDE -INC INCLUDE PROC"
   end

/* Set up map stageid search order depending on stage  */
select
   When EN$BENV = 'TEST'  & EN$BSTGI = 'T' THEN UPMAP =  "TCAP"
   When EN$BENV = 'TEST'  & EN$BSTGI = 'C' THEN UPMAP =   "CAP"
   When EN$BENV = 'QA'    & EN$BSTGI = 'A' THEN UPMAP =    "AP"
   When EN$BENV = 'PROD'  & EN$BSTGI = 'Z' THEN UPMAP =    "ZP"
   When EN$BENV = 'PROD'  & EN$BSTGI = 'P' THEN UPMAP =     "P"
   When EN$BENV = 'PREP'  & EN$BSTGI = 'S' THEN UPMAP = "SJYAP"
   When EN$BENV = 'PREP'  & EN$BSTGI = 'J' THEN UPMAP =  "JYAP"
   When EN$BENV = 'PARQA' & EN$BSTGI = 'Y' THEN UPMAP =   "YAP"
   When EN$BENV = 'MAINT' & EN$BSTGI = 'M' THEN UPMAP =  "MIAP"
   When EN$BENV = 'MAINT' & EN$BSTGI = 'I' THEN UPMAP =   "IAP"
   When EN$BENV = 'ADMIN' & EN$BSTGI = 'D' THEN UPMAP =    "DP"
   When EN$BENV = 'ADMIN' & EN$BSTGI = 'P' THEN UPMAP =     "P"
   otherwise do
      say " "
      Say "EXP#LIBS - unexpected Environment/Stage"
      Say "EXP#LIBS - Please contact Endevor Admin"
      UPMAP = EN$BSTGI /* we can try same stage only */
   end
end

/* Work out libraray concatenation based on map */
if INCLUDE_LIBRARY_LIST == '' then do /* if no override */
   do i = 1 to length(upmap)
      INCLUDE_LIBRARY_LIST = INCLUDE_LIBRARY_LIST,
          'NDVR.'||substr(upmap,i,1)||EN$BSYS||'.'||lastnode
   end
end

/* Return both lists separated by double bar */
return strip(Search_Words,'B')'||'strip(INCLUDE_LIBRARY_LIST,'B')

