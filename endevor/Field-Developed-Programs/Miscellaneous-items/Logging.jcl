//*-------------------------------------------------------------------* 
//*---- Include this step in a job to capture job outputs ------------* 
//*-------------------------------------------------------------------* 
//LOGRESLT  EXEC PGM=IKJEFT1B,                                          
//  PARM='LOGGING'  &SYSJOBNM                                           
//SYSTSIN   DD  DUMMY                                                   
//LOGGING  DD DSN=&SYSUID..LOGGING.&SYSJOBNM..&SYSJOBID,                
//  DISP=(MOD,CATLG,KEEP),                                              
//  UNIT=3390,SPACE=(CYL,(1,05)),                                       
//  DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0)                                 
//SYSEXEC   DD  DISP=SHR,DSN=Your.CLSTREXX   
//SHOWME    DD SYSOUT=*                                                 
//SYSPRINT  DD SYSOUT=*                                                 
//SYSTSPRT  DD SYSOUT=*                                                 
//*==================================================================*  