   /*  REXX  */           
   /*  This snippet contains an example of a strongly recommended REXX        */
   /*  practice. That is to enable any REXX program to identify and respond   */
   /*  to a request to turn on its REXX trace.                                */
   /*  If the name of the REXX program is 'REXXPGM' for example, here is how  */                                            
   Trace OFf                               

/* Is REXXPGM is allocated? If yes, then turn on Trace  */         
   isItThere = ,                                                   
     BPXWDYN("INFO FI(REXXPGM) INRTDSN(DSNVAR) INRDSNT(myDSNT)")   
   If isItThere = 0 then Trace r                                   


/* When the name of the REXX program is found alloceted, the the REXX        */
/* Trace is turned on. For example if this is found on the step              */
/* that runs the REXX                                                        */
/*    //REXXPGM   DD DUMMY                                                   */
