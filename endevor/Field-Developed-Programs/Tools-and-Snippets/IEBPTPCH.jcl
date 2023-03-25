//*-------------------------------------------------------------------
//*   Copies/Concatenates all members into a single ouput          
//*-------------------------------------------------------------------
//GETPKGS  EXEC PGM=IEBPTPCH                                                    
//SYSUT1   DD DISP=SHR,DSN=SACC.PROD.VPLSLPC.FFD.BINDDESA                       
//SYSPRINT DD  SYSOUT=*                                                         
//SYSIN    DD  *                                                                
  PUNCH TYPORG=PO,PREFORM=M,MAXFLDS=1                                           
  RECORD FIELD=(80)                                                             
//SYSUT2   DD DSN=&&BINDPKG,                                                    
//         DISP=(NEW,PASS),SPACE=(TRK,(30,10),RLSE),                            
//         UNIT=TEMP,DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)                       
//*-------------------------------------------------------------------          
//SHOWME  EXEC PGM=IEBGENER,REGION=1024K                                        
//SYSPRINT  DD SYSOUT=*                           MESSAGES                      
//SYSUT1   DD DSN=&&BINDPKG,DISP=(OLD,DELETE)                                   
//SYSUT2   DD SYSOUT=*                                                          
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//*                                                                             
