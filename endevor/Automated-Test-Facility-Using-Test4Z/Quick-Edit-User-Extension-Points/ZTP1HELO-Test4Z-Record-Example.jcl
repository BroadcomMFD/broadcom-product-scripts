//*--------------------------------------------------------------------*        
//*  ** 'Your.TEST4Z.RECORD.MYJCLLIB(ZTP1HELO) **                               
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Execute TEST4Z program Record action                            
//*--------------------------------------------------------------------*        
//T4ZRECRD EXEC PGM=ZTESTEXE    ** Run the T4Z Record**    ZTP1HELO             
//ZLOPTS   DD *                                                                 
RUN(ZTP1HELO),COVERAGE                                                          
//INPUTS DD *            ** Unique Input for ZTP1HELO **                        
Chandru                                                                         
Olga                                                                            
Joseph                                                                          
PavanKumar                                                                      
Purusottam                                                                      
Richard                                                                         
Selvam                                                                          
//MESSAGES DD SYSOUT=*   ** Unique Output messages for for ZTP1HELO **          
//*----------------------------------------------------------                   
