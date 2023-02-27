//*--------------------------------------------------------------- 
//* Check if a DDNAME is found Allocated. In Endevor, 
//* Files allocated as "Additional JCL" are checked to.     
//* This example is checking for the TESTING ddname
//*---------------------------------------------------------------      
//ISITHERE EXEC PGM=IRXJCL,PARM='ENBPIU00 1'                            
//OPTIONS   DD * Use BPXWDYN to see if TESTING is allocated             
  CALL BPXWDYN 'INFO DD(TESTING)'                                       
  If RESULT/= 0 then Exit(0)                                            
  say 'TESTING is  allocated'                                           
  Exit(1)                                                               
//SYSEXEC   DD DISP=SHR,DSN=<your-CSIQCLS0-lib>                     
//SYSTSPRT  DD SYSOUT=*                                                 