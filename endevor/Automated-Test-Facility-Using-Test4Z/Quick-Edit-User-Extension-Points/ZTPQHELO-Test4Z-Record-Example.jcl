//*--------------------------------------------------------------------*        
//*  ** 'Your.TEST4Z.RECORD.MYJCLLIB(ZTPQHELO) **                               
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Execute TEST4Z program Record action                            
//*--------------------------------------------------------------------*        
//T4ZRECRD EXEC PGM=ZTESTEXE    ** Run the T4Z Record**    ZTPQHELO             
//ZLOPTS   DD *                                                                 
RUN(ZTPQHELO),COVERAGE                                                          
//SYSIN1 DD *                                                                   
Vamsy                                                                           
Ashwin                                                                          
David                                                                           
PavanKumar                                                                      
Purusottam                                                                      
Richard                                                                         
Selvam                                                                          
//SYSOUT1  DD SYSOUT=*                                                          
//*----------------------------------------------------------                   
