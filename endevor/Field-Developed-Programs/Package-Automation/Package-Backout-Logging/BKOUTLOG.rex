 /* REXX   */                                                                   
/*-------------------------------------------------------------------*/         
/* Get Package Backout Information using APIALBKO for logging .      */         
/*     Package - comes from exit                                     */         
/*     Reason  - comes twice- 'Before' and 'After' backout/backin    */         
/*     CCID    - The CCID value entered onto the C1SP6000 panel      */         
/*     USER    - Userid of person backing in/out                     */         
/*-------------------------------------------------------------------*/         
  WhatDDName = 'BKOUTLOG'                                                       
  CALL BPXWDYN "INFO FI("WhatDDName")",                                         
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                  
  if RESULT = 0 then Trace ?R                                                   
  Arg Package Reason CCID User                                                  
  what = 'BKOUTLOG' Reason CCID User                                            
  Sa= what                                                                      
  MyBackOutInLog = 'YOURSITE.NDVR.TEAM.PACKPLOG'                                
  Months ="JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC"                     
  If Reason = 'BEFORE'  then,                                                   
     Do                                                                         
     Call GetPackageBackoutInfo                                                 
     MyDDname = 'CAPTURB4'                                                      
     Call RetainBackoutInfoSelectFields                                         
     Exit                                                                       
     End                                                                        
  If Reason = 'AFTER'   then,                                                   
     Do                                                                         
     Call GetPackageBackoutInfo                                                 
     MyDDname = 'CAPTURAF'                                                      
     Call RetainBackoutInfoSelectFields                                         
     Call CompareAndLogDiffernces                                               
     CALL BPXWDYN "FREE DD(CAPTURB4)"                                           
     CALL BPXWDYN "FREE DD(CAPTURAF)"                                           
     End                                                                        
  Exit                                                                          
GetPackageBackoutInfo:                                                          
  SA= "Getting current backout/backin conditions for package" ;                 
  STRING = "ALLOC FI(C1MSGS1)  DUMMY SHR REUSE"                                 
  STRING = "ALLOC DD(C1MSGS1) LRECL(133)",                                      
           " BLKSIZE(26600) SPACE(15,15) ",                                     
           " RECFM(F,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  STRING = "ALLOC FI(C1MSGS2)  DUMMY SHR REUSE"                                 
  STRING = "ALLOC DD(C1MSGS2) LRECL(133)",                                      
           " BLKSIZE(26600) SPACE(15,15) ",                                     
           " RECFM(F,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  STRING = "ALLOC DD(APILIST) LRECL(2048)",                                     
           " BLKSIZE(22800) SPACE(05,05) ",                                     
           " RECFM(V,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  STRING = "ALLOC DD(APIMSGS) LRECL(133)",                                      
           " BLKSIZE(26600) SPACE(15,15) ",                                     
           " RECFM(F,B) TRACKS ",                                               
           " NEW UNCATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
/*'ALLOC F(BSTERR)   DUMMY SHR REUSE '   */                                     
/*'ALLOC F(BSTAPI)   DUMMY SHR REUSE '   */                                     
  ADDRESS LINKMVS 'APIALBKO' Package ;  /*  Get pkg Backout info */             
  LinkRC = RC                                                                   
  ADDRESS TSO "EXECIO * DISKR APILIST (STEM pkgBak. finis"                      
  CALL BPXWDYN "FREE DD(C1MSGS1)"                                               
  CALL BPXWDYN "FREE DD(C1MSGS2)"                                               
  CALL BPXWDYN "FREE DD(APIMSGS)"                                               
  CALL BPXWDYN "FREE DD(APILIST)"                                               
  Return                                                                        
RetainBackoutInfoSelectFields:                                                  
  STRING = "ALLOC DD("MyDDname") LRECL(080)",                                   
           " BLKSIZE(24000) SPACE(05,15) ",                                     
           " RECFM(F,B) TRACKS ",                                               
           " MOD UNCATALOG REUSE ";                                             
  CALL BPXWDYN STRING;                                                          
  Do api# = 1 to pkgBak.0                                                       
     ALBKO =  pkgBak.api#                                                       
     Call WriteBackoutDetails                                                   
  End  /* Do api# = 1 to pkgBak.0  */                                           
  ADDRESS TSO "EXECIO 0 DISKW" myDDname "(Finis"                                
  Return                                                                        
WriteBackoutDetails:                                                            
  ALBKO_RS_RUD = Substr(ALBKO,30,7)                                             
  ALBKO_RS_RUT = Substr(ALBKO,37,5)                                             
  ALBKO_RS_RUU = Substr(ALBKO,42,8)                                             
  ALBKO_RS_LOC = Substr(ALBKO,50,1)                                             
  ALBKO_RS_DIR = Substr(ALBKO,51,1)                                             
  ALBKO_RS_DIRLIT = Substr(ALBKO,52,10)                                         
  ALBKO_RS_MBR = Substr(ALBKO,62,8)                                             
  ALBKO_RS_MBRNEW = Substr(ALBKO,70,8)                                          
  ALBKO_RS_MBRSAVE = Substr(ALBKO,78,8)                                         
  ALBKO_RS_DSN = Substr(ALBKO,86,44)                                            
  Call DateConversion                                                           
  capture = copies(" ",080)                                                     
  capture = Overlay(ALBKO_RS_MBR,   capture,001)                                
  capture = Overlay(ALBKO_RS_DIRLIT,capture,010)                                
  capture = Overlay(ALBKO_RS_DSN,   capture,021)                                
  capture = Overlay(ALBKO_RS_RUD,   capture,066)                                
  capture = Overlay(ALBKO_RS_RUT,   capture,076)                                
  Push capture                                                                  
  ADDRESS TSO "EXECIO 1 DISKW" myDDname                                         
  Return                                                                        
CompareAndLogDiffernces:                                                        
  Trace off                                                                     
  what = 'BKOUTLOG-  about to compare and log entries'                          
  Address TSO "EXECIO * DISKR CAPTURB4 (Stem befor. Finis"                      
  Address TSO "EXECIO * DISKR CAPTURAF (Stem after. Finis"                      
  MemberList = ''                                                               
  entrycount = 0                                                                
  Do rec# = 1 to after.0                                                        
     beforrec = befor.rec#                                                      
     afterrec = after.rec#                                                      
     If beforrec = afterrec then iterate;                                       
     element = Word(afterrec,1)                                                 
     if Wordpos(element,MemberList) > 0 then iterate                            
     entrycount = entrycount + 1                                                
     status  = Substr(afterrec,10,10)                                           
     Date    = Substr(afterrec,66,08)                                           
     Time    = Substr(afterrec,76,05)                                           
     MemberList = MemberList element                                            
     entry = Left(element,8) status Package,                                    
              CCID Left(USER,8) Date Time                                       
     Sa= "Changed:" entry                                                       
     queue       ' 'entry                                                       
  End;  /* Do rec# = 1 to after.0 */                                            
  If entrycount = 0 then Return                                                 
  Call AllocateBACKPLOGForAppend                                                
  ADDRESS TSO 'EXECIO' entrycount "DISKW BACKPLOG (Finis"                       
  CALL BPXWDYN "FREE  DD(BACKPLOG) "                                            
  Return                                                                        
DateConversion:                                                                 
  NDVRDay    = Substr(ALBKO_RS_RUD,1,2)                                         
  alphaMonth = Substr(ALBKO_RS_RUD,3,3)                                         
  NDVRMonth  = Wordpos(alphaMonth,Months)                                       
  NDVRYear = Substr(ALBKO_RS_RUD,6,2)                                           
  If NDVRYear < '70' then NDVRYear = '20' || NDVRYear                           
  Else                    NDVRYear = '19' || NDVRYear                           
  ALBKO_RS_RUD = NDVRYear || NDVRMonth || NDVRDay                               
  Return                                                                        
AllocateBACKPLOGForAppend:                                                      
   if TraceRc = 1 then Say "AllocateBACKPLOGForAppend         "                 
   STRING = "ALLOC DD(BACKPLOG) LRECL(120) BLKSIZE(24000) ",                    
               " DA("MyBackOutInLog")",                                         
               " SPACE(5,5) RECFM(F,B) TRACKS ",                                
               " DSORG(PS) MOD CATALOG REUSE ";                                 
   seconds = '000001' /* Number of Seconds to wait if needed */                 
   Do Forever  /* or at least until the file is available */                    
      CALL BPXWDYN STRING;                                                      
      MyRC = RC                                                                 
      MyResult = RESULT ;                                                       
      If MyResult = 0 then Leave                                                
      calling = 'AllocateBACKPLOGForAppend'                                     
      Call WaitAwhile                                                           
   End /* Do Forever */                                                         
   Return ;                                                                     
