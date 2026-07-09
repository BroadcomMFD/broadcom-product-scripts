/* REXX */                                                                      
/* Can be used as an edit macro when editing a PROCESS or INC */                
/*   or JCL while in Quick-Edit or any ISPF edit session.     */                
/* Just enter JCLCOMMT on the command line.                   */                
/* It gets the name of the element or member,                */                 
/* and places the name onto me onto each line that contains   */                
/* 'PGM=' and is blank in col 60.                             */                
   ADDRESS ISREDIT                                                              
   "ISREDIT MACRO "                                                             
   ADDRESS ISPEXEC,                                                             
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"                                 
/* ZSCREENI = Substr(ZSCREENI,161)  */                                          
   C1Element = Word(ZSCREENI,1)                                                 
   If C1Element = 'File' then,                                                  
      Do                                                                        
      ADDRESS ISREDIT " (MEMBER) = MEMBER " ;                                   
      C1Element = MEMBER                                                        
      End                                                                       
   "EXCLUDE ALL"                                                                
   "FIND 'PGM=' ALL "                                                           
   "EXCLUDE P'@' 1 ALL "                                                        
   "EXCLUDE  ' ' 1 ALL "                                                        
   "CHANGE p' ========' ' "C1Element"' 59 all nx"                               
   Exit                                                                         
