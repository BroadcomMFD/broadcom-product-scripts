/* REXX - User Routine Sample to display Alterable Fields in a pop-up screen
   Kick off a Test4Z job
*/
Trace Off
/*
   THESE SAMPLE ROUTINES ARE DISTRIBUTED BY BROADCOM "AS IS".
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.
   BROADCOM CANNOT GUARANTEE THAT THE ROUTINES ARE
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.

*/

/* Common Preamble */
if ARG(1) == "DESCRIPTION" THEN
   RETURN "Sample routine to display Test4Z contents"
/* End of Preamble */

parse arg PassParm                                /* Get parm that contains   */
PassName = strip(PassParm,,"'")                   /* ...all the names         */
ADDRESS ISPEXEC "VGET ("PassName") SHARED"        /* Retrieve it's value      */
interpret 'ALLVALS = 'PassName                    /* Use it to retrieve names */
ADDRESS ISPEXEC "VGET ("ALLVALS") SHARED"         /* ...and retrieve them     */
ADDRESS ISPEXEC "VGET (ZSCREEN) SHARED"           /* Get current screen       */
DDNAME = 'DUMPOUT' || ZSCREEN                     /* use screen in DDName     */
address TSO "ALLOC DD("DDNAME") SP(1,0) ",        /* Allocate temp file       */
   "TR NEW RELEASE LRECL(512) BLKSIZE(0)",
     "DSORG(PS)",
     "RECFM(V,B) NEW REU UNCATALOG"
Queue "*** Test4z QE User routines ***"  /* Write a Title        */
Queue " "
Queue "Use TR to submit a Test4Z Record job "
Queue "     The JCL LIB must have input and output references    "
Queue " "
Queue "Use TP to submit a Test4Z Replay Job "
Queue "     You must run the Record (TR) job first               "
Queue " "
Queue "Use TU to submit a Test4Z Unit Test Job "
Queue "     You must have a COBOLTST element for the test.       "
Queue " "
Queue "Your OPTIONS may direct the Endevor processor to          "
Queue "     perform TU and TP actions with a COBOL Generate.     "
Queue ""                                          /* null line to terminate   */
address TSO "EXECIO * DISKW "DDNAME" (FINIS"      /* Write queued lines       */
zedsmsg = 'Selected Row Dumped'                   /* Set a user message       */
zedlmsg = 'All variables for row have been collected'
address ispexec "SETMSG MSG(ISRZ000)"
ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME("DDNAME")"
ADDRESS ISPEXEC "VIEW DATAID(&DDID)"              /* invoke View to Browse    */
ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
address TSO "FREE FILE("DDNAME")"                 /* Free the file we're done */
USERMSG = '*Dumped'                               /* Tell user what happened  */
ADDRESS ISPEXEC "VPUT (USERMSG) SHARED"           /* and store the message    */
EXIT 0
   Exit
