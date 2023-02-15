//*****************************************************************  
//* Fetch the element's Options from Endevor libraries up the map * 
//*  Evaluate the Element OPTIONS within a Generate processor     *
//*  Options also contain IGYCRCTL= and IEWL= statements          *
//*    for CONPARMX steps, For example:                           *
//*  IGYCRCTL ='OBJECT,APOST,AWO,DATA(31),FASTSRT,FLAG(W),'+   
//*            'OPT(1),LIST,RENT,TRUNC(BIN),'          
//*  IEWL='XREF,LIST,LET,AMODE(31),RMODE(ANY),RENT,REUS'   
//*  New_COBOL = 'Y'
//*  MQSeries  = 'Y' 
//*****************************************************************
//*   Use IEBUPDTE to fetch Element OPTIONS                       *
//*****************************************************************  
//GETOPTN  EXEC PGM=IEBUPDTE,MAXRC=4                                 
//SYSPRINT DD DUMMY                                                  
//SYSIN    DD *                                                      
./  REPRO NEW=PS,NAME=&C1ELEMENT                                     
//SYSUT1   DD DSN=<Endevor-dataset-that-contain-options>,         
//            DISP=SHR,ALLOC=LMAP                                    
//SYSUT2   DD DISP=(,PASS),DSN=&&OPTIONS,                            
//            SPACE=(TRK,(10,10)),                                   
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920)                  
//*                                                                  
//*****************************************************************  
//* Look through the fetched &&OPTIONS and see if a statement     *
//*  is found that says ...                                       *
//*     New_Cobol = 'Y'                                           *
//*  Give RC=1   if found. Otherwise  RC=0                        *
//*****************************************************************  
//COMPILER EXEC PGM=VALUECHK,PARM='New_COBOL Y'                    
//STEPLIB  DD DSN=<Load library where VALUECHK is found>,DISP=SHR    
//SYSPRINT DD SYSOUT=*                                                
//OPTIONS  DD DSN=&&OPTIONS,DISP=(OLD,PASS)                         
//*                                                  
//*****************************************************************  
//* Look through the fetched &&OPTIONS and see if a statement     *
//*  is found that says ...                                       *
//*     MQSeries = 'Y'                                            *
//*  Give RC=1   if found. Otherwise  RC=0                        * 
//***************************************************************** 
//MQ       EXEC PGM=VALUECHK,PARM='MQSeries Y'                    
//STEPLIB  DD DSN=<Load library where VALUECHK is found>,DISP=SHR    
//SYSPRINT DD SYSOUT=*                                                
//OPTIONS  DD DSN=&&OPTIONS,DISP=(OLD,DELETE)                         
//*            
//*   (downstream processor steps respond to Return codes )    