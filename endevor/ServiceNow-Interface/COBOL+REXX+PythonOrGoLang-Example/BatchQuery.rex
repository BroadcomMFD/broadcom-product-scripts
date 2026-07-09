/*  REXX */                                                                     
   Trace ?R                                                                     
   Arg REQ_CCID .                                                               
   If Substr(REQ_CCID,1,3) = 'PRB' |,                                           
      Substr(REQ_CCID,1,3) = 'CHG' then Call Validate_CCID;                     
   Exit                                                                         
                                                                                
Validate_CCID:                                                                  
                                                                                
   /* build  STDENV input  */                                                   
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDENV) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",                 
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
   Queue "EXPORT PATH=$PATH:" ||,                                               
         "'/usr/lpp/IBM/cyp/v3r11/pyz/lib/python3.11/'"                         
   Queue "EXPORT VIRTUAL_ENV=" ||,                                              
         "'/u/users/NDVRTeam/venv/lib/python3.11/site-packages/'"               
   "EXECIO 2 DISKW STDENV (finis"                                               
                                                                                
   /* build  BPXBATCH inputs and outputs */                                     
   /* build  STDPARM input */                                                   
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDPARM) LRECL(080) BLKSIZE(24000) SPACE(1,1) ",                
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
   Queue "sh cd " ||,                                                           
         "/u/users/NDVRTeam/venv/lib/python3.11/site-packages;"                 
   Queue "python ServiceNow.py" REQ_CCID                                        
   "EXECIO 2 DISKW STDPARM (finis"                                              
                                                                                
   CALL BPXWDYN ,                                                               
      "ALLOC DD(STDOUT) LRECL(200) BLKSIZE(20000) SPACE(5,5) ",                 
             " RECFM(F,B) TRACKS ",                                             
             " NEW UNCATALOG REUSE ";                                           
   Notnow =,                                                                    
      "ALLOC DD(STDOUT) DA('IBMUSER.STDOUT') OLD REUSE "                        
                                                                                
   CALL BPXWDYN "ALLOC DD(STDIN)  DUMMY SHR REUSE"                              
   CALL BPXWDYN "ALLOC DD(STDERR) DA(*) SHR REUSE"                              
                                                                                
   ADDRESS LINK 'BPXBATCH'                                                      
                                                                                
   "EXECIO * DISKR STDOUT (Stem stdout. finis"                                  
   lastrec#   = stdout.0                                                        
   lastrecord = Substr(stdout.lastrec#,1,40)                                    
                                                                                
   If Pos("Exists",lastrecord) = 0 then,                                        
      Do                                                                        
      Message = 'C1UEXTR2 - CCID ' REQ_CCID ||,                                 
                ' is not defined to Service-Now'                                
      MessageCode = 'U012'                                                      
      MyRc        = 8                                                           
      End                                                                       
                                                                                
   CALL BPXWDYN "FREE  DD(STDENV) "                                             
   CALL BPXWDYN "FREE  DD(STDPARM)"                                             
   CALL BPXWDYN "FREE  DD(STDOUT) "                                             
   CALL BPXWDYN "FREE  DD(STDIN)  "                                             
   CALL BPXWDYN "FREE  DD(STDERR) "                                             
                                                                                
   Return;                                                                      
                                                                                
