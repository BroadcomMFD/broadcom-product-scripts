/* REXX */                                                                      
                                                                                
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
                                                                                
/* "execio * diskr REXXMOD (stem rexxmod. finis"                                
say '--------------BEGIN------------------'                                     
do i=1 to rexxmod.0                                                             
  say rexxmod.i                                                                 
end                                                                             
say '--------------END------------------'                                       
                                                                                
"execio" rexxmod.0 "diskw AHJOBIMG (STEM rexxmod. finis"                        
                                                                                
return */                                                                       
newahjob. = ''                                                                  
trace r                                                                         
"execio * diskr ahjob (stem ahjob. finis"                                       
                                                                                
do i = 1 to ahjob.0                                                             
                                                                                
                                                                                
  select                                                                        
                                                                                
    when pos('@@PKGID@@',ahjob.i) <> 0 then do                                  
                                                                                
       parse var ahjob.i head '@@PKGID@@' Tail                                  
       ahjob.i = Head ||strip(pkgID)||Tail                                      
       say '*eye* 'ahjob.i                                                      
       newahjob.i = substr(ahjob.i,1,80)                                        
                                                                                
    end                                                                         
                                                                                
    when pos('@@signedSBOMfile@@',ahjob.i) <> 0 then do                         
                                                                                
       parse var ahjob.i head '@@signedSBOMfile@@' Tail                         
       ahjob.i = Head ||strip(signedSBOMfile)||Tail                             
       say '*eye* 'ahjob.i                                                      
       newahjob.i = substr(ahjob.i,1,80)                                        
                                                                                
    end                                                                         
                                                                                
    otherwise                                                                   
      say '*eye* 'ahjob.i                                                       
      newahjob.i = substr(ahjob.i,1,80)                                         
                                                                                
  end /* select */                                                              
                                                                                
  say 'Length of ahjob.'i': 'LENGTH(ahjob.i)                                    
                                                                                
end /* i = 1 to ahjob.0  */                                                     
                                                                                
newahjob.0 = i - 1                                                              
                                                                                
"execio * diskw ahjob (stem newahjob. finis"                                    
                                                                                
say 'elementos encolados despues del write: 'newahjob.0                         
                                                                                
"execio * diskw ahjobimg (stem newahjob. finis"                                 
                                                                                
                                                                                
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
                                                                                
