/* REXX */                                                                      
trace off                                                                       
                                                                                
parse arg pkgID ,                                                               
          signedSBOMfile                                                        
                                                                                
                                                                                
pkgID          = strip(pkgID)                                                   
signedSBOMfile = strip(signedSBOMfile)                                          
                                                                                
/*                                                                              
  Parm validation                                                               
*/                                                                              
                                                                                
if ExistDDname('AHJOBDSN') Then Do                                              
                                                                                
  "execio * diskr ahjobdsn (stem ahjobdsn. finis"                               
                                                                                
  if ahjobdsn.0 = 0 then do                                                     
    say 'MODAHJOB2E ahjobdsn file is empty'                                     
    return 8                                                                    
   End                                                                          
                                                                                
   dsname = strip(ahjobdsn.1)                                                   
                                                                                
 end                                                                            
                                                                                
else do                                                                         
  Say 'MODAHJOB1E DDname AHJOBDSN is not allocated.'                            
  Return 8                                                                      
 end                                                                            
                                                                                
alloc = "alloc fi('AHJOB') "                                                    
alloc = alloc||"da('"dsname"') shr msg(2)"                                      
call bpxwdyn alloc                                                              
allocRc = Result                                                                
                                                                                
if allocRc <> 0 then do                                                         
  say 'MODAHJOB03E Allocation error ddname AHJOB. rc: 'allocRC                  
  return allocRC                                                                
End                                                                             
                                                                                
"execio * diskr ahjob (stem ahjob. finis"                                       
                                                                                
RJCLROOT = 0                                                                    
                                                                                
do i = 1 to ahjob.0                                                             
  select                                                                        
      when pos('@@PKGID@@',ahjob.i) <> 0 then do                                
        parse var ahjob.i head '@@PKGID@@' Tail                                 
        ahjob.i = Head ||strip(pkgID)||Tail                                     
      end                                                                       
                                                                                
      when pos('@@signedSBOMfile@@',ahjob.i) <> 0 then do                       
        parse var ahjob.i head '@@signedSBOMfile@@' Tail                        
        ahjob.i = Head ||strip(signedSBOMfile)||Tail                            
      end                                                                       
                                                                                
      when  pos('//STDPARM',ahjob.i) <> 0 & ,                                   
            pos('.ARUCD',ahjob.i) <> 0 then do                                  
        RJCLROOT=1                                                              
        parse var ahjob.i . 'DSN=' ARUCDdsn  .                                  
        ARUCDdsn = strip(ARUCDdsn)                                              
      end                                                                       
                                                                                
    otherwise                                                                   
      NOP                                                                       
  end /* select */                                                              
end /* i = 1 to ahjob.0  */                                                     
                                                                                
If RJCLROOT Then do                                                             
  /* Add support for USS Artifacts when C1DEFLTS parameter 'RJCLROOT=,'         
    An UNPAX step is added to AHJOB dataset in oreder to uncompress the         
    artifacts in the temp directory before the actual copy to the               
    production PATH                                                             
  */                                                                            
                                                                                
  FirstExec=0                                                                   
  do i = 1 to ahjob.0                                                           
                                                                                
    if pos("EXEC ",ahjob.i) <> 0 & ,                                            
      pos("PGM=",ahjob.i) <> 0 & ,                                              
      \FirstExec  then do                                                       
                                                                                
      FirstExec = 1                                                             
      queue substr( ,                                                           
      "//*########################################"||,                          
      "############################",                                           
            ,1,80)                                                              
      queue substr("//*",1,80)                                                  
      queue substr( ,                                                           
      "//* Temporarily expand pax file to get USS elements "||,                 
      "for HASH validation",                                                    
            ,1,80)                                                              
      queue substr("//*",1,80)                                                  
      queue substr( ,                                                           
      "//*########################################"||,                          
      "############################",                                           
            ,1,80)                                                              
      queue substr("//XPANDPAX EXEC PGM=BPXBATCH,COND=(0,NE)",1,80)             
                                                                                
      queue substr("//STDOUT   DD   SYSOUT=*",1,80)                             
      queue substr("//STDERR   DD   SYSOUT=*",1,80)                             
      queue substr("//STDPARM  DD *,SYMBOLS=JCLONLY",1,80)                      
      queue substr("SH",1,80)                                                   
      queue substr( ,                                                           
        ' cp "'"//'"ARUCDdsn"'"'"',1,80)                                        
      queue substr( ,                                                           
        "    /tmp/&USER._D&DATE._T&TIME..&PKGID._ARPAX.txt ;",1,80)             
      queue substr( ,                                                           
      " paxcmd=$(cat /tmp/&USER._D&DATE._T&TIME..&PKGID._ARPAX.txt |",          
            ,1,80)                                                              
      queue substr('       grep "ARPAX");',1,80)                                
      queue substr( ,                                                           
      ' new_paxcmd=$(echo "$paxcmd"'" | sed 's/-rvzk/-rvz/');",                 
           ,1,80)                                                               
      queue substr(' eval "$new_paxcmd";',1,80)                                 
                                                                                
    end /* if pos */                                                            
    queue substr(ahjob.i,1,80)                                                  
                                                                                
  end /* do i=1 */                                                              
  "execio" queued() "diskw ahjob (finis"                                        
                                                                                
end /* if RJCLROOT yes */                                                       
                                                                                
else do                                                                         
  "execio" ahjob.0 "diskw ahjob (stem ahjob. finis"                             
                                                                                
end /* not RJCLROOT */                                                          
                                                                                
Return 0                                                                        
                                                                                
/*                                                                              
  Procedure ExistDDname allocated                                               
*/                                                                              
ExistDDname: Procedure                                                          
arg search4dd                                                                   
last1 = 0                                                                       
dsnlist = ''                                                                    
Found = 0                                                                       
Do i = 1 by 1 Until (last1 /= 0)                                                
   Call bpxwdyn 'info inrelno('i') inrtddn(found_dd)',                          
                'inrtlst(last1)'                                                
   If found_dd = search4dd Then                                                 
     Do                                                                         
       Found = 1                                                                
       leave                                                                    
     End                                                                        
End                                                                             
Return found                                                                    
                                                                                
