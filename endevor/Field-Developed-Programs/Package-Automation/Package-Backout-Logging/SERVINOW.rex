/*  REXX */                                                                     
/*  Validate the Ticket# with Service-Now                      */               
/*  This routine can be used to validate a CCID or package     */               
/*  name (for example) as valid Service-Now ticket numbers.    */               
   CALL BPXWDYN "INFO FI(SERVINOW) INRTDSN(DSNVAR) INRDSNT(myDSNT)"             
   if RESULT = 0 then trace ?r                                                  
   Arg Caller Ticket# TSOorBatch                                                
   Message = Caller'/SERVINOW - Ticket Number ' Ticket# ||,                     
                ' is defined to Service-Now'                                    
   NEWSTACK                                                                     
   /* build  STDENV input  */                                                   
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDENV) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",                 
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
   Queue "EXPORT PATH=$PATH:" ||,                                               
         "'/usr/IBM/python/lib/python#.##/'"                                    
   Queue "EXPORT VIRTUAL_ENV=" ||,                                              
         "'u/your/venv/lib/python#.##/site-packages/'"                          
   "EXECIO 2 DISKW STDENV (finis"                                               
   /* build  BPXBATCH inputs and outputs */                                     
   /* build  STDPARM input */                                                   
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDPARM) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",                
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
   Queue "sh cd " ||,                                                           
         "u/your/venv/lib/python#.##/site-packages;"                            
   Queue "python ServiceNow.py" Ticket#                                         
   "EXECIO 2 DISKW STDPARM (finis"                                              
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDOUT) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",                 
             " RECFM(F,B) TRACKS DSORG(PS)",                                    
             " NEW UNCATALOG REUSE ";                                           
   CALL BPXWDYN "ALLOC DD(STDIN)  DUMMY SHR REUSE"                              
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDERR) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",                 
             " RECFM(F,B) TRACKS DSORG(PS)",                                    
             " NEW UNCATALOG REUSE ";                                           
   ADDRESS LINK 'BPXBATCH'                                                      
   myRC = RC                                                                    
   "EXECIO 0 DISKW STDOUT (finis"  /* ensure STDOUT is closed */                
   "EXECIO * DISKR STDOUT (Stem stdout. finis"                                  
   lastrec#   = stdout.0                                                        
   lastrecord = Substr(stdout.lastrec#,1,40)                                    
   If Pos("Exists",lastrecord) = 0 then,                                        
      Message = Caller'/SERVINOW - Ticket Number ' Ticket# ||,                  
                ' is **NOT** defined to Service-Now'                            
   Drop stdout.                                                                 
   CALL BPXWDYN "FREE  DD(STDENV) "                                             
   CALL BPXWDYN "FREE  DD(STDPARM)"                                             
   CALL BPXWDYN "FREE  DD(STDOUT) "                                             
   CALL BPXWDYN "FREE  DD(STDIN)  "                                             
   CALL BPXWDYN "FREE  DD(STDERR) "                                             
   DELSTACK                                                                     
   Return Message;                                                              
