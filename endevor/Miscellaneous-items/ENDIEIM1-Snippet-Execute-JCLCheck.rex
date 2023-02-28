/*  Use LINE to determine whether/not CReating a new element         */ 
/*      LINE=0 if new                                                                               */ 
       "ISREDIT (LINE) = CURSOR"                                        

   IF SUBSTR(ENVBTYP,1,3) = "JCL" &,                
      LINE > 0 THEN,                                
        ADDRESS ISREDIT "EJCK"  ;             
        