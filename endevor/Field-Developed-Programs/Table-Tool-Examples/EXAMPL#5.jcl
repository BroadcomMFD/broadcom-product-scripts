//IBMUSER5 JOB (0000),'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,                     
//      REGION=0M,MSGCLASS=A,NOTIFY=&SYSUID                                     
//*--------------------------------------------------------------------         
//*- Report the total Track consumption of a list of datasets ---------         
//*- in a list created from a saved TSO 3.4 list.             ---------         
//*- Also identify and delete old datasets      .             ---------         
//*- (RC=0004 is OK)                                          ---------         
//*--------------------------------------------------------------------         
//  SET TABLE=IBMUSER.NDVR.DATASETS         <- Saved 3.4 data                   
//  SET TABLE=IBMUSER.PUBLIC.DATASETS       <- Saved 3.4 data                   
//  SET SYSEXEC=YOUR.REXX.EXEC                   <- Rexx library                
//  SET SYSEXEC=YOUR.NDVR.EMER.ADMINSYS.CSIQCLS0                                
//*--------------------------------------------------------------------         
//TEST001  EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                             
//TABLE    DD DISP=SHR,DSN=&TABLE                                               
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
  Total = Right(Total,8,'0')   /* For fixed width */                            
  Tracks = Right(Tracks,6,'0') /* For fixed width */                            
  If Total > 1000 then $my_rc = 2                                               
  If Total > 5000 then $my_rc = 4                                               
//MODEL1   DD *                                                                 
&Dataset  Date=&CreateDate DaysOld=&ElementAge                                  
//MODEL2   DD *                                                                 
&Dataset Total=&Total Tracks=&Tracks                                            
//TBLOUT1  DD SYSOUT=*                                                          
//SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC                                             
//TBLOUT2  DD SYSOUT=*                                                          
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//DISPLAYS DD SYSOUT=*                                                          
//SYSTSIN  DD DUMMY                                                             
//*--------------------------------------------------------------------         
                                                                                
