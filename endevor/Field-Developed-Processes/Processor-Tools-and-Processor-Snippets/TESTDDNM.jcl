//WALJO11T JOB (55800000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*--------------------------------------------------------------------
//WALJO11T JOB (0000),'Dan Walther',CLASS=A,MSGCLASS=Z,MSGLEVEL=(1,1), 
//         NOTIFY=&SYSUID,REGION=0M                                    
//*------------------------------------------------------------------- 
//  SET CSIQCLS0=CARSMINI.NDVR.R1801.CSIQCLS0                          
//*------------------------------------------------------------------- 
//*- If Item is allocated, show in Return code 1=Yes 0=No ------------ 
//*--------------------------------------------------------------------
//XPEDITER EXEC PGM=IRXJCL,PARM='ENBPIU00 A'                           
//OPTIONS  DD *                                                        
   WhatDDName = 'XPEDITER'                                             
   STRING = 'INFO FI('WhatDDName') INRTDSN(DSNVAR) INRDSNT(myDSNT)'    
   CALL BPXWDYN STRING;                                                
   if Substr(DSNVAR,1,1) > ' ' then,+                                  
      Do;Say WhatDDName 'allocated to' DSNVAR; EXIT(1); End            
   Exit(0)                                                             
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                   
//SYSTSPRT DD SYSOUT=*                                                 
//XPEDITER DD DISP=SHR,DSN=WALJO11.JCL(TESTDDN2)                       
//*-------------------------------------------------------------------- 
//PROTSYM  EXEC PGM=IRXJCL,PARM='ENBPIU00 A'                            
//OPTIONS  DD *                                                         
   WhatDDName = 'PROTSYM'                                               
   STRING = 'INFO FI('WhatDDName') INRTDSN(DSNVAR) INRDSNT(myDSNT)'     
   CALL BPXWDYN STRING;                                                 
   if Substr(DSNVAR,1,1) > ' ' then,+                                   
      Do;Say WhatDDName 'allocated to' DSNVAR; EXIT(1); End             
   Exit(0)                                                              
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                    
//SYSTSPRT DD SYSOUT=*                                                  
//*PROTSYM DD DISP=SHR,DSN=WALJO11.JCL(TESTDDN2)                        
//*-------------------------------------------------------------------* 
