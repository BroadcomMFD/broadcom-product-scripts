//JNKPUSH  EXEC PGM=IRXJCL,REGION=0M,PARM=' '                                   
//SYSTSPRT DD SYSOUT=*                                                          
//SYSTSIN  DD DUMMY                                                             
//SYSEXEC  DD *                                                                 
  /*REXX Script to assing USS File Name*/                                       
TRACE ?I                                                                        
CALL BPXWDYN ,                                                                  
   "ALLOC DD(STDENV) LRECL(80) BLKSIZE(24000) SPACE(1,1) ",                     
   "RECFM(F,B) TRACKS NEW UNCATALOG REUSE"                                      
                                                                                
Queue "EXPORT PATH=$PATH:'/usr/bin:/usr/lpp/IBM/cyp/v3r12/pyz/lib/python3.12/'" 
Queue "EXPORT VIRTUAL_ENV=" ||,                                                 
      "'/z/ibmuser/pydir/venv/lib/python3.12/site-packages/'"                   
                                                                                
"EXECIO " QUEUED() " DISKW STDENV (FINIS"                                       
                                                                                
CALL BPXWDYN ,                                                                  
   "ALLOC DD(STDPARM) LRECL(80) BLKSIZE(24000) SPACE(1,1) ",                    
   "RECFM(F,B) TRACKS NEW UNCATALOG REUSE"                                      
                                                                                
Queue "sh cd " ||,                                                              
      "/z/ibmuser/pydir/venv/lib/python3.12/site-packages;"                     
Queue ". /z/ibmuser/pydir/venv/bin/activate;"                                   
Queue "python /z/ibmuser/pydir/jenkins_push.py" &MEMBER..".json"                
                                                                                
"EXECIO " QUEUED() " DISKW STDPARM (FINIS"                                      
                                                                                
CALL BPXWDYN ,                                                                  
   "ALLOC DD(STDOUT) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",                    
   "RECFM(F,B) TRACKS NEW UNCATALOG REUSE"                                      
                                                                                
CALL BPXWDYN "ALLOC DD(STDIN) DUMMY SHR REUSE"                                  
CALL BPXWDYN "ALLOC DD(STDERR) DUMMY SHR REUSE"                                 
                                                                                
ADDRESS LINK 'BPXBATCH'                                                         
                                                                                
"EXECIO * DISKR STDOUT (STEM stdout. FINIS"                                     
"EXECIO * DISKR STDOUT (STEM stderr. FINIS"                                     
                                                                                
Do i = 1 to stdout.0                                                            
   SAY "STDOUT: " stdout.i                                                      
End                                                                             
                                                                                
Do i = 1 to stderr.0                                                            
   SAY "STDERR: " stderr.i                                                      
End                                                                             
                                                                                
CALL BPXWDYN "FREE DD(STDENV)"                                                  
CALL BPXWDYN "FREE DD(STDPARM)"                                                 
CALL BPXWDYN "FREE DD(STDOUT)"                                                  
CALL BPXWDYN "FREE DD(STDIN)"                                                   
CALL BPXWDYN "FREE DD(STDERR)"                                                  
                                                                                
EXIT 0                                                                          
                                                                                
