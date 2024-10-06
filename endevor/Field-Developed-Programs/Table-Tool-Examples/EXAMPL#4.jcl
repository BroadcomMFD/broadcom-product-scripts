//IBMUSER4 JOB (0000),                                                  JOB04207
//    'ENDEVOR BATCH',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//    NOTIFY=&SYSUID                                                            
//*-------------------------------------------------------------------*         
//*-- Execute PDM to update elements out of sync. --------------------*         
//*-- Outputs:  IBMUSER.ENDEVOR.WIPFILE           --------------------*         
//*-------------------------------------------------------------------*         
// SET SYSEXEC=SYS1.EXEC                                                        
// SET SYSEXEC=CAPRD.NDVR.PROD.CATSNDVR.CEXEC                                   
//*-------------------------------------------------------------------*         
//PDM#001  EXEC PGM=NDVRC1,                                                     
//             DYNAMNBR=1500,                                                   
//             REGION=4096K,                                                    
//             PARM='C1BM3000'                                                  
//STEPLIB  DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTU                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTH                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD                         
//CONLIB   DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD                         
//C1MSGS1  DD SYSOUT=*                                                          
//C1MSGS2  DD DSN=&&C1MSGS2,DISP=(NEW,PASS),                                    
//            UNIT=SYSDA,SPACE=(TRK,(5,5)),                                     
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=0)                                
//SYSUDUMP DD SYSOUT=*                                                          
//SYMDUMP  DD DUMMY                                                             
//SYSOUT   DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//BSTIPT01 DD *                                                                 
  VALIDATE ELEMENT "*"                                                          
    FROM ENVIRONMENT "SMPLTEST"                                                 
         SYSTEM "*" SUBSYSTEM "*"                                               
         TYPE "*" STAGE "T"                                                     
    .                                                                           
//*-------------------------------------------------------------------*         
//*                                                                             
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K                                        
//SYSPRINT  DD SYSOUT=*                           MESSAGES                      
//SYSUT1   DD  DSN=&&C1MSGS2,DISP=(OLD,PASS)                                    
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE                   
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*-------------------------------------------------------------------*         
//PDM#002 EXEC PGM=IRXJCL,PARM='ENBPIU00 M 0008'                                
//SYSEXEC  DD DSN=&SYSEXEC,DISP=SHR                                             
//TABLE    DD DSN=&&C1MSGS2,DISP=(OLD,DELETE)                                   
//POSITION DD  *                                                                
  NDVRrc   40 43                                                                
  Element  22 29                                                                
  Environ  47 54                                                                
  System   61 68                                                                
  SubSys   71 78                                                                
  Type     83 90                                                                
  Stage    94 94                                                                
//MODEL    DD  *                                                                
 LIST ELEMENT &Element FROM ENVIRONMENT &Environ STAGE &Stage                   
      SYSTEM '&System'  SUBSYSTEM '&SubSys'  TYPE "&Type"                       
      OPTIONS NOSEARCH TO FILE APIEXTR  .                                       
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//OPTIONS  DD DUMMY                                                             
//TBLOUT   DD  DSN=&&CSVLISTS,DISP=(NEW,PASS),                                  
//             UNIT=SYSDA,SPACE=(TRK,(1,1)),                                    
//             DCB=(RECFM=FB,LRECL=080,BLKSIZE=08000)                           
//*--------------------------------------------------------------------*        
//*   STEP 2 -- EXECUTE CSV UTILITY                                             
//*--------------------------------------------------------------------*        
//PDM#003  EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='BC1PCSV0'                                                      
//STEPLIB  DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTU                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQAUTH                         
//         DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD                         
//CONLIB   DD  DISP=SHR,DSN=CAPRD.NDVR.V160PRD.CSIQLOAD                         
//BSTIPT01 DD  DSN=&&CSVLISTS,DISP=(OLD,DELETE)                                 
//APIEXTR  DD DSN=&&CSVFILE,                                                    
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                        
//      DISP=(MOD,PASS),                                                        
//      SPACE=(TRK,(5,1),RLSE)                                                  
//C1MSGS1  DD SYSOUT=*                                                          
//BSTERR   DD SYSOUT=*                                                          
//*--------------------------------------------------------------------         
//*--------------------------------------------------------------------         
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K                                        
//SYSPRINT  DD SYSOUT=*                           MESSAGES                      
//SYSUT1   DD  DSN=&&CSVFILE,DISP=(OLD,PASS)                                    
//SYSUT2    DD SYSOUT=*                           OUTPUT FILE                   
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*-------------------------------------------------------------------*         
//PDM#004 EXEC PGM=IRXJCL,PARM='ENBPIU00 A'                                     
//SYSEXEC  DD DSN=&SYSEXEC,DISP=SHR                                             
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)                                  
//MODEL    DD DISP=SHR,DSN=IBMUSER.MODELS(PDM#ELM)                              
//OPTIONS  DD *                                                                 
  jobchar = Substr(ELM NAME,1,1)    /* First char of element name */            
  jobchar = 'P'                     /* for PDM                    */            
  Userid = USERID()                                                             
  $delimiter = '/'                                                              
//SYSTSPRT DD  SYSOUT=*                                                         
//TBLOUTX  DD  SYSOUT=*                                                         
//TBLOUT   DD  SYSOUT=(A,INTRDR)                                                
//*-------------------------------------------------------------------*         
                                                                                
