/* REXX - User Routine Sample to display Alterable Fields in a pop-up screen    
   Kick off a Test4Z job                                                        
*/                                                                              
Trace Off                                                                       
   Say "Use TR to submit a Test4Z Record job "                                  
   Say "       The JCL LIB must have input and output references    "           
   Say "  "                                                                     
   Say "Use TP to submit a Test4Z Replay Job "                                  
   Say "       You must run the Record (TR) job first               "           
   Say "  "                                                                     
   Say "Use TU to submit a Test4Z Unit Test Job "                               
   Say "       You must have a COBOLTST element for the test.       "           
   Say "  "                                                                     
   Say "Your OPTIONS may direct the Endevor processor to            "           
   Say "       perform TU and TP actions with a COBOL Generate.     "           
   Exit                                                                         
