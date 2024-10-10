//IBMUSER5 JOB (0000),'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,                     
//      REGION=0M,MSGCLASS=A,NOTIFY=&SYSUID                                     
//*--------------------------------------------------------------------         
//*- SYS1.EXEC(ALLOLIKE)                                                        
//*--------------------------------------------------------------------         
//  SET DSNLIST=IBMUSER.MYLIST.DATASETS     <-                                  
//  SET DSNLIST=IBMUSER.CAPRD.DATASETS      <-                                  
//  SET DSNLIST=IBMUSER.TESTING.DATASETS    <-                                  
//  SET SYSEXEC=SYS1.EXEC                   <-                                  
//*--------------------------------------------------------------------         
//*- IBMUSER.JCL(EXAMPL#5) --------------------------------------------         
//*--------------------------------------------------------------------         
//BUILDS   EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                             
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC                                             
//TABLE    DD DISP=SHR,DSN=&DSNLIST                                             
//PARMLIST DD *                                                                 
  MODEL1  TBLOUT1  OPTIONS  180                                                 
  MODEL2  TBLOUT2  OPTIONS  180                                                 
  MODEL3  TBLOUT3  OPTIONS  180                                                 
//MODEL1   DD *                                                                 
  ALLOC F(INDD) +                                                               
        DA('&Dataset') SHR REUSE                                                
  ALLOC F(OUTDD) +                                                              
        DA('&Dataset.NEW') +                                                    
        NEW LIKE ('&Dataset') +                                                 
        DSNTYPE(LIBRARY)                                                        
  CALL *(IEBCOPY)                                                               
  FREE  F(INDD)                                                                 
  FREE  F(OUTDD)                                                                
//MODEL2   DD *                                                                 
  RENAME '&Dataset' +                                                           
         '&Dataset.OLD'                                                         
  RENAME '&Dataset.NEW' +                                                       
         '&Dataset'                                                             
//MODEL3   DD *                                                                 
  DELETE '&Dataset.OLD'                                                         
//OPTIONS  DD *                                                                 
  If Dsorg /= 'PO'  then $SkipRow = 'Y'                                         
//POSITION DD *                                                                 
  Dataset     01 44                                                             
  Dsorg       53 56                                                             
  Tracks      80 88                                                             
  CreateDate 108 117                                                            
  AccessDate 130 139                                                            
//SYSTSPRT DD SYSOUT=*                                                          
//NOTUSED  DD DATA,DLM=QQ                                                       
//TBLOUT1  DD SYSOUT=*                                                          
//TBLOUT2  DD SYSOUT=*                                                          
//TBLOUT3  DD SYSOUT=*                                                          
//                                                                              
QQ                                                                              
//TBLOUT1  DD DSN=&&TBLOUT1,DISP=(NEW,PASS),                                    
//         SPACE=(CYL,(1,1)),UNIT=SYSDA,                                        
//         LRECL=80,RECFM=FB,BLKSIZE=0                                          
//TBLOUT2  DD DSN=&&TBLOUT2,DISP=(NEW,PASS),                                    
//         SPACE=(CYL,(1,1)),UNIT=SYSDA,                                        
//         LRECL=80,RECFM=FB,BLKSIZE=0                                          
//TBLOUT3  DD DSN=&&TBLOUT3,DISP=(NEW,PASS),                                    
//         SPACE=(CYL,(1,1)),UNIT=SYSDA,                                        
//         LRECL=80,RECFM=FB,BLKSIZE=0                                          
//*--------------------------------------------------------------------         
//ALLOCS   EXEC PGM=IKJEFT1B                                                    
//SYSTSIN  DD DSN=&&TBLOUT1,DISP=(OLD,DELETE)                                   
//SYSIN     DD *                                                                
  COPY INDD=INDD,OUTDD=OUTDD                                                    
//SYSUT2  DD  UNIT=SYSDA,SPACE=(CYL,(90,90))                                    
//SYSUT3  DD  UNIT=SYSDA,SPACE=(CYL,(90,90))                                    
//SYSUT4  DD  UNIT=SYSDA,SPACE=(CYL,(90,90))                                    
//SYSUT5  DD  UNIT=SYSDA,SPACE=(CYL,(90,90))                                    
//SYSUT6  DD  UNIT=SYSDA,SPACE=(CYL,(90,90))                                    
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//RENAMES  EXEC PGM=IKJEFT1B                                                    
//SYSTSIN  DD DSN=&&TBLOUT2,DISP=(OLD,DELETE)                                   
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//DELETES  EXEC PGM=IKJEFT1B                                                    
//SYSTSIN  DD DSN=&&TBLOUT3,DISP=(OLD,DELETE)                                   
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//                                                                              
//TEST001  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                             
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC                                             
//TABLE    DD DISP=SHR,DSN=IBMUSER.DSNLIST.DATASETS                             
//PARMLIST DD *                                                                 
  NOTHING NOTHING  OPTIONS0 0                                                   
  MODEL1  TBLOUT1  OPTIONS1 A                                                   
  MODEL2  TBLOUT2  OPTIONS2 A                                                   
//POSITION DD *                                                                 
  Dataset     01 44                                                             
  Dsorg       53 54                                                             
  Tracks      80 88                                                             
  CreateDate 108 117                                                            
  AccessDate 130 139                                                            
//OPTIONS0 DD *                                                                 
  $StripData = 'N' ;       /* Preserve spaces */                                
  BaseDate = DATE('B')  /* Today in Base format */                              
  DaysAgo = 240         /* Number of days for cutoff */                         
  Total=0  /* Initialize variable */                                            
//OPTIONS1 DD *                                                                 
* Determine how old is the dataset                                              
  Parse Var CreateDate yr '/' mo '/' da                                         
  date = yr || mo || da                                                         
  If DATATYPE(date) /= 'NUM' then $SkipRow = 'Y'                                
  BaseOld  = DATE(B,date,S)  /* Convert Upd date to Base fmt */                 
  ElementAge = BaseDate - BaseOld  /* Determine how many days ago  */           
  ElementAge = Right(ElementAge,4,'0') /* For fixed width */                    
  If ElementAge < DaysAgo then $SpitRow = 'Y'  /* Skip if recent */             
//OPTIONS2 DD *                                                                 
* Calculate a running count of Tracks consumed                                  
  If $row#<1 then $SkipRow = 'Y'                                                
  If DATATYPE(Tracks) /= 'NUM' Then $SkipRow = 'Y'                              
  Total = Total + Tracks                                                        
  Total = Right(Total,6,'0')   /* For fixed width */                            
  Tracks = Right(Tracks,6,'0') /* For fixed width */                            
  If Total > 1000 then $my_rc = 2                                               
  If Total > 5000 then $my_rc = 4                                               
//MODEL1   DD *                                                                 
&Dataset  Date=&CreateDate DaysOld=&ElementAge                                  
//MODEL2   DD *                                                                 
&Dataset Total=&Total Tracks=&Tracks                                            
//TBLOUT1  DD SYSOUT=*                                                          
//TBLOUT2  DD SYSOUT=*                                                          
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//DISPLAYS DD SYSOUT=*                                                          
//SYSTSIN  DD DUMMY                                                             
//*--------------------------------------------------------------------         
                                                                                
