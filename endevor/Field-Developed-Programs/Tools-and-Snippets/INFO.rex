   /*  REXX  */                                                       
   Trace OFf                               

/* Is EDCHKDD is allocated? If yes, then turn on Trace  */         
   isItThere = ,                                                   
     BPXWDYN("INFO FI(EDCHKDD) INRTDSN(DSNVAR) INRDSNT(myDSNT)")   
   If isItThere = 0 then Trace r                                   


/* Other examples */
                       
   WhatDDName = 'CONLIB'                                              
   CALL BPXWDYN "INFO FI("WhatDDName")",                              
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                       
   if Substr(DSNVAR,1,1) = ' ' then Say WhatDDName 'Not allocated'    
   Else,                                                              
   Say WhatDDName  DSNVAR myDSNT                                      
                                                                      
   WhatDDName = 'SYSOUT'                                              
   CALL BPXWDYN "INFO FI("WhatDDName")",                              
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                       
   if Substr(DSNVAR,1,1) = ' ' then Say WhatDDName 'Not allocated'    
   Else,                                                              
   Say WhatDDName  DSNVAR myDSNT                                      
                                                                      
   WhatDDName = 'NOTHING'                                             
   CALL BPXWDYN "INFO FI("WhatDDName")",                              
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"      
   EXIT                 