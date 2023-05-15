//*----------------------------------------------------------
//*   Set the Return code to 1 for this step
//*---------------------------------------------------------- 
//SR2   EXEC PGM=IDCAMS                                      
//SYSIN    DD *                                              
  SET LASTCC=1                                               
//AMSDUMP  DD DUMMY                                          
//SYSPRINT DD DUMMY                                          
