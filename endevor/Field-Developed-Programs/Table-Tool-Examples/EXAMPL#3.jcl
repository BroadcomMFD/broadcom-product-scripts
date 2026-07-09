//IBMUSER3 JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*-------------------------------------------------------------------          
// SET SYSEXEC=YOUR.NDVR.PROD.ADMINSYS.CEXEC                                    
//*--------------------------------------------------------------               
//*- Add members of a PDS into Endevor                -----------               
//*--------------------------------------------------------------               
//*-------------------------------------------------------------------          
//*   STEP 1 - Get a list of members in the dataset                             
//*-------------------------------------------------------------------          
//STEP01   EXEC PGM=IKJEFT1B                                                    
//SYSTSIN   DD *                                                                
 LISTDS 'IBMUSER.ENDEVOR.SOURCE' MEMBERS                                        
//SYSPRINT  DD SYSOUT=*                                                         
//SYSTSPRT  DD DSN=&&MBRLIST,DISP=(,PASS),                                      
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,                                            
//     LRECL=120,RECFM=FB,BLKSIZE=0                                             
//*                                                                             
//*--------------------------------------------------------------------*        
//*   STEP 2 -- Update Rexx Stem array for each member                          
//*--------------------------------------------------------------------*        
//STEP02 EXEC PGM=IRXJCL,PARM='ENBPIU00 A'                                      
//TABLE    DD DSN=&&MBRLIST,DISP=(OLD,DELETE)                                   
//POSITION DD  *                                                                
  Member  3 10                                                                  
//MODEL    DD  *                                                                
  FoundMember.&Member = 'Y'                                                     
//OPTIONS  DD *                                                                 
  If $row#  < 8 then CSVoption = ' '                                            
  If $row#  < 8 then $SkipRow = 'Y'  /* Skip if recent */                       
  Member = Strip(Member)                                                        
  firstchar = Substr(Member,1,1)                                                
  if firstchar < 'A' | firstchar > 'Z' then $SkipRow = 'Y'                      
  If $row#  > 8 then CSVoption = 'NOCSV'                                        
//SYSEXEC  DD DSN=&SYSEXEC,DISP=SHR                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSIN    DD DUMMY                                                             
//SYSPRINT DD SYSOUT=*                                                          
//TBLOUT   DD DSN=&&STEMARRY,DISP=(MOD,PASS),                                   
//         SPACE=(CYL,(1,1)),UNIT=SYSDA,                                        
//         LRECL=80,RECFM=FB,BLKSIZE=0                                          
//*                                                                             
//*--------------------------------------------------------------------         
//*   SHOWME -- Show the Stem array settings                                    
//*--------------------------------------------------------------------         
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K                                        
//SYSPRINT DD SYSOUT=*                           MESSAGES                       
//SYSUT1   DD DSN=&&STEMARRY,DISP=(OLD,PASS)                                    
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE                    
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*--------------------------------------------------------------------*        
//*   STEP 3 -- Execute CSV Utility to locate inventory                         
//*--------------------------------------------------------------------*        
//STEP03   EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='BC1PCSV0'                                                      
//STEPLIB  DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQAUTU                          
//         DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQAUTH                          
//         DD  DISP=SHR,DSN=YOUR.NDVR.V160PRD.CSIQLOAD                          
//BSTIPT01 DD *                                                                 
  LIST ELEMENT '*'     FROM ENVIRONMENT SMPLPROD STAGE P                        
       SYSTEM '*'  SUBSYSTEM '*'  TYPE "*"                                      
       OPTIONS NOSEARCH TO FILE CSVOUTPT .                                      
//C1MSGS1  DD SYSOUT=*                                                          
//BSTERR   DD SYSOUT=*                                                          
//CSVOUTPT DD DSN=&&CSVFILE,                                                    
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                        
//      DISP=(MOD,PASS),                                                        
//      SPACE=(CYL,(5,5),RLSE)                                                  
//*--------------------------------------------------------------------         
//*   SHOWME -- Show the API call  results                                      
//*--------------------------------------------------------------------         
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K                                        
//SYSPRINT DD SYSOUT=*                           MESSAGES                       
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)                                    
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE                    
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//*                                                                             
//STEP04 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                               
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)                                  
//PARMLIST DD  *                                                                
  NOTHING  NOTHING  STEMARRY  0                                                 
  MODEL    TBLOUT   OPTIONS   A                                                 
//STEMARRY DD *    < Build Stem Array FoundMember.                              
  FoundMember.        = 'N'                                                     
//         DD DSN=&&STEMARRY,DISP=(OLD,DELETE)                                  
//NOTHING  DD DUMMY                                                             
//MODEL    DD  *                                                                
** &ELM_NAME &SYS_NAME &SBS_NAME &TYPE_NAME &SIGNOUT_ID                         
  ADD ELEMENT &ELM_NAME                                                         
         TO   ENVIRONMENT SMPLTEST                                              
              SYSTEM &SYS_NAME SUBSYSTEM &SBS_NAME                              
              TYPE &TYPE_NAME.                                                  
//OPTIONS  DD *                                                                 
  ELM_NAME = Strip(ELM_NAME)                                                    
  If FoundMember.ELM_NAME /= 'Y' then $SkipRow = 'Y'                            
//SYSEXEC DD DSN=&SYSEXEC,DISP=SHR                                              
//SYSTSPRT DD  SYSOUT=*                                                         
//SYSPRINT  DD SYSOUT=*                                                         
//SYSIN     DD DUMMY                                                            
//TBLOUT   DD SYSOUT=*                                                          
//*-------------------------------------------------------------------          
                                                                                
