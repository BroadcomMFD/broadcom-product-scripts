/*  REXX */                                                                     
/*  Find and return the Accounting code value for current user/job */           
                                                                                
  start   = 540                    /* it starts here */                         
  start   = D2X(start)                                                          
  TCB_Addr = C2D(Storage(start,4)) /* Current TCB Addr */                       
  JSCB_Addr = C2D(Storage(D2X(TCB_Addr+180),4))                                 
                                                                                
  JCT_Addr  = C2D(Storage(D2X(JSCB_Addr+260),4))                                
                                                                                
  ACT_Addr  = C2D(Storage(D2X(JCT_Addr+56),3))                                  
  ACT_Area  = Storage(D2X(ACT_Addr),110)                                        
  ACT_len   = C2D(Substr(ACT_Area,49,1))                                        
  ACT_code  = Substr(ACT_Area,50,ACT_len)                                       
                                                                                
  Return ACT_code                                                               
