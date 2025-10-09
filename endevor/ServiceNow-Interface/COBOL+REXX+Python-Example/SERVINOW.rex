/*  REXX */
/*  Validate the Ticket# with Service-Now                      */
/*  This routine can be used to validate a CCID or package     */
/*  name (for example) as valid Service-Now ticket numbers.    */
   Arg Caller Ticket# TSOorBatch .
   If TSOorBatch = 'B' then say "SERVINOW - validating" Ticket#
   NEWSTACK
   /* Designate how many validated Ticket Numbers to remember */
   Message = Caller'/SERVINOW - Ticket Number ' Ticket# ||,
                ' is defined to Service-Now'
/* Set up the variables for running Python */
 command = "sh cd /u/users/ibmuser;",
           "python python/ServiceNow.py" Ticket#
 stdout.0 = 0
 stderr.0 = 0
 stdin.0 = 0
 env.0 = 4
 env.1 = "PATH=" || ,
   "/usr/lpp/IBM/cyp/pyz/bin/:" || ,
   "/bin:/usslocation/usr/lpp/java/J8.0_64/bin:" || ,
   "/usr/lpp/IBM/cyp/v3r9/pyz/bin:" || ,
   "/usr/lpp/IBM/zoautil/bin:" || ,
   "/usr/lpp/IBM/zoautil/env/bin:" || ,
   "/u/users/cai/moi/v2001/s1801/bin:/u/users/nodejs/nodejs/bin:"
 env.2 = "LIBPATH=" || ,
   "/lib:" || ,
   "/usr/lib:" || ,
   "/usslocation/usr/lpp/java/J8.0_64/include:" || ,
   "/usr/lpp/IBM/cyp/v3r9/pyz/lib:" || ,
"/usslocation/forpython/python3.11/site-packages/pip/_vendor"
 env.3 = '_BPXK_AUTOCVT=ON'
 env.4 = '_CEE_RUNOPTS=FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'
/* Call Python to parse the data */
   call bpxwunix command,stdin.,stdout.,stderr.,env.
   lastrec#   = stdout.0
   lastrecord = Substr(stdout.lastrec#,1,40)
   whereExists = Pos("Exists",lastrecord)
   If whereExists = 0 then,
      Do
      Message = Caller'/SERVINOW - Ticket Number ' Ticket# ||,
                ' is **NOT** defined to Service-Now'
      /* Print the output from running Python */
      do i=1 to stderr.0
         say stderr.i
      end    /* Do.... */
      End /* If whereExists = 0  */
   DELSTACK
   Return Message;
