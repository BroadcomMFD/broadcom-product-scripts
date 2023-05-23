//SIQA##W JOB (00124),'CMN2NDVR #07CM180',                            
//    CLASS=C,MSGCLASS=Z,NOTIFY=&SYSUID                               
//*--------------------------------------------------------------------
//***Schedule a job submission for designated time                    
//** -Morning-                                                        
//   SET START='06:31:00'                                             
//** -Evening-                                                         
//   SET START='18:01:00'                                             
//** -Latenite-                                                       
//   SET START='21:01:00'                                             
//   SET JCLSUBMT='NDVP.CA.TEAM.JCL(RERUNS)'                          
//   SET JCLSUBMT='NDVP.CA.TEAM.BUNDLE.CMN2NDVR(#07CM180)'            
//*--------------------------------------------------------------------
//WAIT#10  EXEC PGM=IRXJCL,PARM='WAITTILL &START'                     
//SYSEXEC  DD DISP=SHR,DSN=NDVP.CA.TEAM.BUNDLE.CMN2NDVR               
//         DD DISP=SHR,DSN=NDVP.CA.TEAM.REXX                          
//SYSTSPRT DD SYSOUT=*                                                
//*--------------------------------------------------------------------
//** Submit one or more jobs constructed                    ***********
//*--------------------------------------------------------------------
//SUBMIT   EXEC PGM=IEBGENER,REGION=1024K                  #07CM180    
//SYSPRINT DD SYSOUT=*                           MESSAGES              
//SYSUT1   DD DSN=&JCLSUBMT,DISP=SHR                                   
//SYSUT2   DD SYSOUT=(A,INTRDR)                  OUTPUT FILE           
//SYSIN    DD DUMMY                               CONTROL STATEMENTS   
