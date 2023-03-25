//*--------------------------------------------------------------- 
//* Check if your job or processor is running on one of the  
//* acceptable LPARS - as listed in theRightLpars.     
//* IF yes then RC=0. Otherwise RC=12 and you get a message.
//*---------------------------------------------------------------      
//LPARCHCK  EXEC PGM=IRXJCL,PARM='ENBPIU00 1'          
//OPTIONS   DD *                                                 
  where = MVSVAR(SYSNAME)                                        
* List names where this job is allowed to run.....                              
  theRightLparS = 'SYS1 DE32 DE57'                               
*                                             
  If Wordpos(where,theRightLpars) = 0  then, +                   
     Do; QUEUE '*****************************************'; +    
         QUEUE 'You must submit this job on' theRightLpars; +    
         QUEUE '*****************************************'; +    
     ADDRESS TSO 'Execio 3 DISKW ERRORS (Finis' ;+               
     Exit(12); +                                                 
     End;                                                        
*                                             
  Say 'You are in the right place...' where                      
  Exit(0)                                                        
//ERRORS    DD SYSOUT=*                                          
//SYSPRINT  DD SYSOUT=*                                                          
//SYSEXEC   DD DISP=SHR,DSN=<your-CSIQCLS0-lib>                     
//SYSTSPRT  DD SYSOUT=*                                                                              