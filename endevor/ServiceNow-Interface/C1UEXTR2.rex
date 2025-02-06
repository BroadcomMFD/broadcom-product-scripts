/*        rexx                                                    */            
/* -------------------------------------------------------------- */            
/* This is a simple version that:                                 */            
/*  o Reuses a CCID value already on the element if CCID is blank */            
/*  o Validates a CCID with Service-Now                           */            
/*  o Reuses a comment value from element    if comment is blank  */            
/*  o Gives a friendly reminder if the SIGNOUT OVERRIDE is on     */            
/* -------------------------------------------------------------- */            
                                                                                
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(SYSTSIN) DUMMY"                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
   /* If C1UEXTR2 is allocated to anything, turn on Trace  */                   
   WhatDDName = 'C1UEXTR2'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if Substr(DSNVAR,1,1) /= = ' ' then Trace ?r                                 
                                                                                
   Sa= 'You called ....CLSTREXX(C1UEXTR2) '                                     
                                                                                
   /* In case these are not provided by the Exit */                             
   SRC_ELM_ACTION_CCID = ' '                                                    
   SRC_ELM_LEVEL_COMMENT = ' '                                                  
   TGT_ELM_ACTION_CCID = ' '                                                    
   TGT_ELM_LEVEL_COMMENT = ' '                                                  
   /* These Element Actions determine whehter to */                             
   /* use SRC or TGT variables                   */                             
   ActionsThatUse_SRC = 'RETRIEVE MOVE DELETE GENERATE'                         
   ActionsThatUse_TGT = 'UPDATE '                                               
                                                                                
   Arg Parms                                                                    
   Parms = Strip(Parms)                                                         
   sa= 'Parms len=' Length(Parms)                                               
                                                                                
   /* Parms from C1UEXT02 is a string of REXX statements   */                   
   Interpret Parms                                                              
   MyRc = 0                                                                     
   Message =''                                                                  
   MessageCode = '    '                                                         
                                                                                
   /* If CCID is left blank, then apply last used CCID        */                
   /* otherwise if it appears to be a ServiceNow  - validate  */                
   If REQ_CCID = COPIES(' ',12) then Call Update_CCID;                          
   Else,                                                                        
   If Substr(REQ_CCID,1,3) = 'PRB' |,                                           
      Substr(REQ_CCID,1,3) = 'CHG' then Call Validate_CCID;                     
                                                                                
   /* If COMMENT is left blank, then apply last used COMMENT */                 
   If MyRc < 8 &,                                                               
      REQ_COMMENT = COPIES(' ',40) then Call Update_COMMENT;                    
                                                                                
   sa= 'MyRc =' MyRc                                                            
                                                                                
   /* Did user specify OVERRIDE SIGNOUT ?                    */                 
   If MyRc = 0 & REQ_SISO_INDICATOR = 'Y' then                                  
      Do                                                                        
      Message = 'Remember that you have set OVERRIDE SIGNOUT'                   
      MyRc        = 4                                                           
      End                                                                       
                                                                                
   If MyRc = 0 then Exit                                                        
                                                                                
   If Message /= '' then,                                                       
      Do                                                                        
      hexAddress = D2X(Address_ECB_MESSAGE_TEXT)                                
      storrep = STORAGE(hexAddress,,Message)                                    
      hexAddress = D2X(Address_ECB_MESSAGE_LENGTH)                              
      storrep = STORAGE(hexAddress,,'0084'X)                                    
      End                                                                       
                                                                                
   If MessageCode /= '    ' then,                                               
      Do                                                                        
      hexAddress = D2X(Address_ECB_MESSAGE_CODE)                                
      storrep = STORAGE(hexAddress,,MessageCode)                                
      End                                                                       
                                                                                
   /* Tell Endevor something changed or something failed */                     
   hexAddress = D2X(Address_ECB_RETURN_CODE)                                    
   If MyRc = 4 then,                                                            
      storrep = STORAGE(hexAddress,,'00000004'X)                                
   Else,                                                                        
      storrep = STORAGE(hexAddress,,'00000008'X)                                
                                                                                
   Exit                                                                         
                                                                                
Update_CCID:                                                                    
                                                                                
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_SRC) > 0 then,                     
      Replace_CCID = SRC_ELM_ACTION_CCID                                        
   Else,                                                                        
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_TGT) > 0 then,                     
      Replace_CCID = TGT_ELM_ACTION_CCID                                        
                                                                                
   /* Still missing a CCID?                      */                             
   If Substr(Replace_CCID,1,1) < 'a' then,                                      
      Do                                                                        
      MyRc = 8                                                                  
      Message = '** A CCID value is required **'                                
      MessageCode = 'U012'                                                      
      Return;                                                                   
      End                                                                       
                                                                                
   hexAddress = D2X(Address_REQ_CCID)                                           
   storrep = STORAGE(hexAddress,,Replace_CCID)                                  
   MyRc = 4                                                                     
                                                                                
   Return;                                                                      
                                                                                
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
                                                                                
Update_COMMENT:                                                                 
                                                                                
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_SRC) > 0 then,                     
      Replace_COMMENT = SRC_ELM_LEVEL_COMMENT                                   
   Else,                                                                        
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_TGT) > 0 then,                     
      Replace_COMMENT = TGT_ELM_LEVEL_COMMENT                                   
                                                                                
   If Substr(Replace_COMMENT,1,1) < 'a' then,                                   
      Do                                                                        
      MyRc = 8                                                                  
      Message = '** A COMMENT value is required **'                             
      MessageCode = 'U011'                                                      
      Return;                                                                   
      End                                                                       
                                                                                
   hexAddress = D2X(Address_REQ_COMMENT)                                        
   storrep = STORAGE(hexAddress,,Replace_COMMENT)                               
   MyRc = 4                                                                     
                                                                                
   Return;                                                                      
                                                                                
