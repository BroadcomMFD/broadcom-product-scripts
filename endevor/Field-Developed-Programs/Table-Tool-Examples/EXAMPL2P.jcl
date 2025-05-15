//IBMUSERA JOB (0000),                                                  JOB01236
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*-------------------------------------------------------------------          
// SET SYSEXEC=YOUR.NDVR.PROD.ADMINSYS.CEXEC                                    
//*--------------------------------------------------------------               
//*- To Report Packages created over nnn days ago     -----------               
//*--------------------------------------------------------------               
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Execute CSV Utility to gather Package information               
//*--------------------------------------------------------------------*        
//STEP1    EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='BC1PCSV0'                                                      
//STEPLIB  DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQAUTU                          
//         DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQAUTH                          
//         DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQLOAD                          
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
  HEADING TBLOUT  OPTIONS  1                                                    
  MODEL   TBLOUT  OPTIONS  A                                                    
//HEADING  DD *                                                                 
 Package--------- Status-----                                                   
   \CreateDate UpdateDate CreatorId- Description------------------------        
//MODEL    DD *                                                                 
 &PKG_ID &STATUS                                                                
    &CREATE_DATE &UPDT_DATE &CREATE_USRID    *** &DESCRIPTION ***               
//OPTIONS  DD DUMMY                                                             
//SYSEXEC  DD DSN=&SYSEXEC,DISP=SHR                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSIN    DD DUMMY                                                             
//TBLOUT   DD SYSOUT=*                                                          
//*-------------------------------------------------------------------          
                                                                                
