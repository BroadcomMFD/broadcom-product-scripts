//IBMUSER2 JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*-------------------------------------------------------------------          
// SET SYSEXEC=CAPRD.NDVR.PROD.CATSNDVR.CEXEC                                   
//*--------------------------------------------------------------               
//*- To Report Packages created over nnn days ago     -----------               
//*--------------------------------------------------------------               
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Execute CSV Utility to gather Package information               
//*--------------------------------------------------------------------*        
//STEP1    EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='BC1PCSV0'                                                      
//STEPLIB  DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTU                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTH                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD                         
//BSTIPT01 DD *                                                                 
LIST PACKAGE ID '*'                                                             
     WHERE DATE TYPE CR IS OLDER THAN 20 DAYS                                   
     TO DDNAME 'CSVOUTPT' .                                                     
//C1MSGS1  DD SYSOUT=*                                                          
//BSTERR   DD SYSOUT=*                                                          
//CSVOUTPT DD DSN=&&CSVFILE,                                                    
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                        
//      DISP=(MOD,PASS),                                                        
//      SPACE=(CYL,(5,5),RLSE)                                                  
//*--------------------------------------------------------------------         
//*   SHOWME -- Show the API call  results                                      
//*--------------------------------------------------------------------         
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K,COND=(4,EQ,STEP1)                      
//SYSPRINT  DD SYSOUT=*                           MESSAGES                      
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)                                    
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE                   
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//REPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                               
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)                                  
//PARMLIST DD *                                                                 
  MODEL   TBLOUT  OPTION0  0                                                    
  MODEL   TBLOUT  OPTIONS  A                                                    
//HEADING  DD *                                                                 
* Package--------- Status----- CreateDate UpdateDate CreatorId- PackageAge      
//*-+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
//MODEL    DD *                                                                 
&DetailLine                                                                     
//OPTION0  DD *                                                                 
  LinesPerPage = 15                                                             
  LineCount = LinesPerPage + 1                                                  
  DaysAgo = 60          /* Number of days for cutoff */                         
//OPTIONS  DD *                                                                 
* Bypass processing for Table header                                            
  If $row# < 1 then $SkipRow = 'Y'                                              
* Calculate age of Package creation                                             
  BaseDate = DATE('B')  /* Today in Base format */                              
  UpdateDate = Substr(UPDT_DATE,1,4) || Substr(UPDT_DATE,6,2)                   
  UpdateDate = UpdateDate || Substr(UPDT_DATE,9,2)                              
  If DATATYPE(UpdateDate) /= 'NUM' then $SkipRow = 'Y'                          
  BaseOld  = DATE(B,UpdateDate,S)  /* Convert Upd date to Base fmt */           
  PackageAge = BaseDate - BaseOld  /* Determine how many days ago  */           
  If PackageAge < DaysAgo then $SkipRow = 'Y'  /* Skip if recent */             
* Build report detail line ....                                                 
  DetailLine = Copies(' ',120);                                                 
  DetailLine = Overlay(PKG_ID,DetailLine,03)                                    
  DetailLine = Overlay(STATUS,DetailLine,20)                                    
  DetailLine = Overlay(CREATE_DATE,DetailLine,32)                               
  DetailLine = Overlay(UPDT_DATE,DetailLine,43)                                 
  DetailLine = Overlay(CREATE_USRID,DetailLine,54)                              
  DetailLine = Overlay(PackageAge,DetailLine,65)                                
* Determine whether it is time for page heading                                 
  LineCount = LineCount + 1                                                     
  If LineCount > LinesPerPage then x = BuildFromMODEL(HEADING)                  
  If LineCount > LinesPerPage then LineCount = 1                                
//SYSEXEC DD DSN=&SYSEXEC,DISP=SHR                                              
//SYSTSPRT DD  SYSOUT=*                                                         
//SYSPRINT  DD SYSOUT=*                                                         
//SYSIN     DD DUMMY                                                            
//TBLOUT   DD SYSOUT=*                                                          
//*-------------------------------------------------------------------          
                                                                                
