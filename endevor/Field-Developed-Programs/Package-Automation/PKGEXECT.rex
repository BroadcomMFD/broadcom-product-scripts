/*  REXX  */                                                                    
                                                                                
/*                                                                   */         
/*      https://github.com/BroadcomMFD/broadcom-product-scripts      */         
/*                                                                   */         
/* This rexx is called by a package exit program, receives a         */         
/* package name, and submits a job to EXECUTE the package.           */         
/*                                                                   */         
/* If uncommented, the exit Runs only 4 IBMUSER                      */         
/* If USERID() /= 'IBMUSER' then Exit                                */         
/*                                                                   */         
                                                                                
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
                                                                                
   WhatDDName = 'PKGEXECT'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if Substr(DSNVAR,1,1) = ' ' then Sa= WhatDDName 'Not allocated'              
   Else,                                                                        
     Do                                                                         
     Say 'Running PKGEXECT'                                                     
     Trace ?R                                                                   
     End                                                                        
                                                                                
   ARG Parms ;                                                                  
      Package = Substr(PARMS,1,16) ;                                            
      Environ = Substr(PARMS,18,08) ;                                           
      Stage   = Substr(PARMS,27,01) ;                                           
/*                                                                    */        
/* This Rexx participates in the submission of Endevor Package        */        
/* Shipment jobs. It is called by the Endevor exit program C1UEXT07   */        
/*                                                                    */        
/* If a RETROFIT package, get out                                     */        
/*                                                                              
   If Substr(Package,1,2) = 'RT' then Exit                                      
   If Substr(Package,1,2) = 'X#' then Exit                                      
*/                                                                              
/*                                                                   */         
/* Variable settings for each site --->           */                            
   WhereIam =  WHERE@M1()                                                       
   interpret 'Call' WhereIam "'MyDATALibrary'"                                  
   MyDATALibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MySEN2Library'"                                  
   MySEN2Library = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MySENULibrary'"                                  
   MySENULibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'AltIDAcctCode'"                                  
   AltIDAcctCode = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MySENULibrary'"                                  
   MySENULibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'AltIDJobClass'"                                  
   AltIDJobClass = Result                                                       
/* <---- Variable settings for each site          */                            
   Sa= 'Running PKGEXECT '                                                      
/*                                                                    */        
/* Allocate and prepare files for ENBPIU00 execution                  */        
/*                                                                    */        
/*                                                                    */        
   Package_Prefix = SUBSTR(Package,1,4)  /* You decide prefix length  */        
   Package_Prefix = SUBSTR(Package,1,5)  /* You decide prefix length  */        
                                                                                
   Date8  = DATE('S')                                                           
   Date6  = substr(Date8,3);                                                    
   Temp   = TIME('L')                                                           
                                                                                
   Time8  = Substr(Temp,1,2) ||,                                                
            Substr(Temp,4,2) ||,                                                
            Substr(Temp,7,2) ||,                                                
            Substr(Temp,10,2) ;                                                 
   Time6  = Substr(Temp,1,2) ||,                                                
            Substr(Temp,4,2) ||,                                                
            Substr(Temp,7,2) ;                                                  
                                                                                
                                                                                
/*                                                                    */        
/* OPTIONS will contain date and time values                          */        
/*                                                                    */        
                                                                                
   STRING = "ALLOC DD(OPTIONS) LRECL(80) BLKSIZE(27920) ",                      
              " DSORG(PS) ",                                                    
              " SPACE(1,1) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
   QUEUE "  $nomessages = 'Y' " ;                                               
   QUEUE "  Date8  = '"Date8"'"                                                 
   QUEUE "  Date6  = '"Date6"'"                                                 
   QUEUE "  Time8  = '"Time8"'"                                                 
   QUEUE "  Time6  = '"Time6"'"                                                 
   QUEUE "  Package = '"Package"'" ;                                            
   QUEUE "  Userid  = '"USERID()"'" ;                                           
   QUEUE "  Userjob = '"USERID()|| SUBSTR(Package,1,1)"'"                       
   QUEUE "  AltIDAcctCode = '"AltIDAcctCode"'"                                  
   QUEUE "  MySEN2Library     = '"MySEN2Library"'"                              
   QUEUE "  MySENULibrary     = '"MySENULibrary"'"                              
   QUEUE "  AltIDJobClass = '"AltIDJobClass"'"                                  
                                                                                
   "EXECIO " QUEUED() "DISKW OPTIONS (FINIS"                                    
                                                                                
   If Words(PARMS) = 1 then EXIT ;                                              
/*                                                                    */        
/* TBLOUT is assigned to a temporary dataset to receive the jcl       */        
/*                                                                    */        
   STRING = "ALLOC DD(TBLOUT) LRECL(80) BLKSIZE(27920) ",                       
              " DSORG(PS) ",                                                    
              " SPACE(1,1) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
                                                                                
   CALL BPXWDYN STRING;                                                         
                                                                                
/*                                                                    */        
/* TABLE is fixed by Endevor administrators                           */        
/* MODELS are SHIP and DELETE - separate JCL images                   */        
/*                                                                    */        
   STRING = 'ALLOC DD(TABLE) ',                                                 
            "DA('"MyDATALibrary"(PKGEEXEC)') SHR REUSE "                        
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = 'ALLOC DD(MODEL) ',                                                 
            "DA('"MySEN2Library"(PKG#MODL)') SHR REUSE "                        
   CALL BPXWDYN STRING;                                                         
                                                                                
/*                                                                    */        
/* Now call ENBPIU00 which does the rest                              */        
/*                                                                    */        
                                                                                
/* "ENBPIU00 1" Environ Stage          <- when only using prom pkgs   */        
   "ENBPIU00 M" Package                                                         
                                                                                
   "EXECIO 0 DISKW TBLOUT (FINIS"                                               
                                                                                
   "EXECIO * DISKR TBLOUT (STEM EXECJCL. FINIS "                                
/*                                                                    */        
/* "EXECIO * DISKW DISPLAYS (STEM EXECJCL. FINIS "                    */        
/*                                                                    */        
                                                                                
   STRING = "ALLOC DD(READER)",                                                 
              " RECFM(F) BLKSIZE(80) LRECL(80)",                                
               "SYSOUT(A) WRITER(INTRDR) REUSE " ;                              
   CALL BPXWDYN STRING;                                                         
/*                                                                    */        
   "EXECIO * DISKW READER (STEM EXECJCL. FINIS "                                
/*                                                                    */        
                                                                                
   STRING = "FREE DD(READER)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(OPTIONS)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(TBLOUT)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = 'FREE DD(TABLE) ' ;                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
                                                                                
   Exit                                                                         
