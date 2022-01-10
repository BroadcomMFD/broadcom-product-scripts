//*---------------------------------------------------------------      
//**  Get program specific OPTIONS for ELEMENT (IF one EXISTS)  **      
//*---------------------------------------------------------------      
//GET#OPTE EXEC PGM=IEBUPDTE,COND=(4,LT),MAXRC=4                        
//SYSPRINT DD DUMMY                                                     
//SYSIN    DD  *                                                        
./  REPRO NEW=PS,NAME=&C1ELEMENT                                        
//SYSUT1   DD DISP=SHR,DSN=&OPTIONS,                                    
//            MONITOR=COMPONENTS,ALLOC=LMAP                             
//SYSUT2   DD DSN=&&OPTIONE,DISP=(OLD,PASS)                             
//*-------------------------------------------------------------------- 