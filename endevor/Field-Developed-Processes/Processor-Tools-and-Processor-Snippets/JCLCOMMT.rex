/* REXX */                                                              
/* Can be used as an edit macro when editing a PROCESS or INC */        
/*   or JCL                                                   */        
/* Just enter JCLCOMMT  on the command line while in QuickEdit*/        
/* It gets the                                                */        
/* name of the element and places the element name onto       */        
/* each line that contains 'PGM=' and is blank in col 60.     */        
   ADDRESS ISREDIT                                                      
   "ISREDIT MACRO "                                                     
   TRACE off                                                            
   ADDRESS ISPEXEC,                                                     
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"                         
   C1Element = Word(ZSCREENI,1)                                         
   "EXCLUDE ALL"                                                        
   "FIND 'PGM=' ALL "                                                   
   "EXCLUDE P'@' 1 ALL "                                                
   "EXCLUDE  ' ' 1 ALL "                                                
   "CHANGE '        ' '"C1Element"' 60 all nx"                          
   Exit                                                                 