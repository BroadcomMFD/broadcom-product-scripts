/*   REXX      WRITTEN BY DAN WALTHER                               
    Can be used to create a list of new datasets using existing  
    datasets as models. 
                                                              
     TO USE:  
      Create a list of dataset names you want to allocate.
      On each line ensure a new dataset name is followed by at least one
      space. and then the name of an existing dataset to use as a model.
 
       For example:                                                            
        USE TSO 3.4 TO GET A LIST OF DATASETS                       
        ENTER "SAVE" TO KEEP THE LIST OF DATASETS                   
        USE "RR" TO DUPLICATE THE LIST OF NAMES                     
        CHANGE THE SECOND LIST TO RENDER SLIGHTLY DIFFERENT NAMES   
        SHIFT AND MOVE WITH "OO" THE SECOND LIST ONTO THE FIRST     
        SAVE THE LIST WITH A NAME IE USERID.<NAMELIST>.DATASETS     
        ENTER ALLOLIST NAMELIST                                     
*/ 
/*   TRACE R;           */                                          
PARSE UPPER ARG NAMELIST .                                          
   ADDRESS TSO                                                      
    "ALLOC F(NAMELIST) DA("NAMELIST".DATASETS) SHR REUSE"                  
  "EXECIO * DISKR NAMELIST (STEM PAIR. FINIS"                              
   DO I = 1 TO PAIR.0                                                
      TEMP = PAIR.I                                                  
      NEWDSN = WORD(TEMP,1) ;                                        
      LIKEDSN = WORD(TEMP,2) ;                                       
      ADDRESS ISPEXEC  "SELECT CMD(ALLOLIKE "NEWDSN" "LIKEDSN")"     
      END;                 
   ADDRESS TSO             
     "FREE  F(NAMELIST)"                                              
EXIT                                                                 
