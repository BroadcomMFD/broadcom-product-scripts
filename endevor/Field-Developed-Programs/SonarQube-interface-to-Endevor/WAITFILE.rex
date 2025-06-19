 /*  REXX   */                                                                  
 /* Loop in Wait status until named file appears   */                           
 /* Return 0 if file never appears after all waits */                           
 /* Return # for number of seconds used waiting    */                           
                                                                                
  Arg WaitForFilename MaxLoops WaitSeconds                                      
                                                                                
   STRING = "ALLOC DD(WAITFILE)",                                               
              " DA('"WaitForFilename"') SHR REUSE"                              
   seconds = WaitSeconds /* Number of Seconds to wait if needed */              
                                                                                
   Do MaxLoops                                                                  
   /*  or at least until the file is available */                               
   Do Loop# = 1 to MaxLoops                                                     
      CALL BPXWDYN STRING;                                                      
      MyResult = RESULT ;                                                       
      If MyResult = 0 then Return (Loop# * WaitSeconds)                         
      Say 'WAITFILE is waiting for' WaitForFilename                             
      Call WaitAwhile                                                           
   End /*  Do MaxLoops */                                                       
                                                                                
   Return 0                                                                     
                                                                                
WaitAwhile:                                                                     
  /*                                                               */           
  /* A resource is unavailable. Wait awhile and try                */           
  /*   accessing the resource again.                               */           
  /*                                                               */           
  /*   The length of the wait is designated in the parameter       */           
  /*   value which specifies a number of seconds.                  */           
  /*   A parameter value of '000003' causes a wait for 3 seconds.  */           
  /*                                                               */           
  /*seconds = Abs(seconds)                                         */           
  /*seconds = Trunc(seconds,0)                                     */           
  Say "Waiting for" seconds "seconds at " DATE(S) TIME()                        
  /* AOPBATCH and BPXWDYN are IBM programs */                                   
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"                              
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"                              
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"                               
                                                                                
  /* AOPBATCH and BPXWDYN are IBM programs */                                   
  parm = "sleep "seconds                                                        
  Address LINKMVS "AOPBATCH parm"                                               
                                                                                
  Return                                                                        
                                                                                
