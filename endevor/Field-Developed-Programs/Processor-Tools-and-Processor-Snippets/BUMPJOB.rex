/*  REXX */                                                                     
/*  Bump the last character on a Jobname to next value */                       
/*  select is either empty/next for next character     */                       
/*                or     j/jump for a big gap          */                       
 Trace O                                                                        
 Arg jobname select                                                             
 Rotation = '12345678901',                                                      
            'ABCDEFGHIJKLMNOPQRSTUVWXYZA',                                      
            '@#$@'                                                              
 jobname = word(jobname,1)                                                      
 lastchar = Substr(jobname,Length(jobname))                                     
 locatchar = Pos(lastchar,Rotation)                                             
 If select = 'j' | select = 'jump' then,                                        
    wherenext = (locatchar + length(Rotataton) // 2                             
 Else,                                                                          
    wherenext = locatchar + 1                                                   
 overlaychar = Substr(Rotation,wherenext,1)                                     
 wheretohit  = Min(Length(jobname)+1,8)                                         
 nextJobname = overlay(overlaychar,jobname,wheretohit)                          
 Return nextJobname                                                             
