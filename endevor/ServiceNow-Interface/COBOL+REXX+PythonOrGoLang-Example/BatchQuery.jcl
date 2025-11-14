//IBMUSERS JOB (0000),                                                          
//         CLASS=A,MSGCLASS=X,REGION=4M,                                        
//         NOTIFY=&SYSUID                                                       
//*==================================================================*          
// SET C1CCID=PRB0000014                                                        
// SET C1CCID=CHG0040007                                                        
//*==================================================================*          
//*   STEP 1 -- Execute REXX  -> Python  -> ServiceNow                          
//*-------------------------------------------------------------------          
//STEP1    EXEC PGM=IRXJCL,PARM='SNOWQERY &C1CCID'                              
//SYSEXEC  DD DISP=SHR,DSN=YOURSITE.NDVR.TEAM.REXX                              
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//STDERR   DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
