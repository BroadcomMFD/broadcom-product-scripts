//*********************************************************************
//GUSS     PROC AAA=,                     first variable
//   USSPATH='/u/users/Endevor/&C1ENVMNT',
//   EXTSION='java',
//   ZZZZZZZ=
//**********************************************************************
//CONW1 EXEC PGM=CONWRITE,MAXRC=0                                       
//ELMOUT1 DD PATH='&USSPATH',                                           
// PATHOPTS=(OWRONLY,OCREAT),                                           
// PATHMODE=(SIRWXU,SIRWXG,SIRWXO)                                      
//CONWIN DD *                                                           
WRITE ELEMENT &C1ELMNT255                                               
   FROM ENV &C1EN SYSTEM &C1SY SUBSYSTEM &C1SU                          
   TYPE &C1TY STAGE &C1SI                                               
TO DDN ELMOUT1                                                          
HFSFILE &C1ELMNT255..tmp                                                
.                                                                       
//**********************************************************************
//ENUSS1 EXEC PGM=ENUSSUTL,MAXRC=4,COND=(4,LT)                          
//INPUT DD PATH='&USSPATH'                                              
//OUTPUT DD PATH='&USSPATH',                                            
// PATHMODE=(SIRWXU,SIRWXG,SIRWXO)                                      
//ENUSSIN DD *                                                          
 COPY INDD 'INPUT' OUTDD 'OUTPUT' .                                     
 SELECT FILE '&C1ELMNT255..tmp'                                         
   NEWF '&C1ELMNT255..&EXTSION'                                         
 .                                                                      
//**********************************************************************
//BPXB1 EXEC PGM=BPXBATCH,MAXRC=0,COND=(4,LT),                          
//   PARM='SH rm -r &USSPATH./&C1ELMNT255..tmp'                         
//STDOUT DD SYSOUT=*                                                    
//STDERR DD SYSOUT=*                                                    
//*                                                                     
//**********************************************************************
//**********************************************************************
