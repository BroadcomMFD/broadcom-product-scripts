//**                                                                            
//*******************************************************************           
//**                                                               **           
//**    COBOL2 AND COBOL/MVS COMPILE AND LINK-EDIT PROCESSOR                    
//**                                                               **           
//*******************************************************************           
//GC1COB  PROC LISTLIB='&PROJECT..SMPL&C1SSTAGE1..LISTLIB',                     
//             CLECOMP='IGY.SIGYCOMP',                                          
//             CLERUN='CEE.SCEERUN',                                            
//             CLELKED='CEE.SCEELKED',                                          
//             CIILIB='SYS1.COB2LIB',                                           
//             CIICOMP='SYS1.COB2COMP',                                         
//             CSIQCLS0='Your.NDVR.TARGET.CSIQCLS0',                            
//             PROJECT='Your.NDVR.V1##',                                        
//             COPYLIB='&PROJECT..SMPL&C1ST..COPYLIB',                          
//             EXPINC=N,                                                        
//             OPTIONS='Your.NDVR.V1##.SMPL&C1ST..OPTIONS',                     
//             LOADLIB='&PROJECT..SMPL&C1ST..LOADLIB',                          
       ++INCLUDE T4ZVARBS  Test4Z processor variables                           
//             MEMBER=&C1ELEMENT,                                               
//             MONITOR=COMPONENTS,                                              
//             CPARMA='',                                                       
//             CPARMZ='',                                                       
//             PARMCOB='LIB,NOSEQ,OBJECT,APOST,TEST(SEPARATE,DWARF)',           
//             PARMLNK='LIST,MAP,XREF',                                         
//             SYSOUT=*,                                                        
//             WRKUNIT=3390                                                     
//*********************************************************************         
//*   ALLOCATE TEMPORARY LISTING DATASETS                                       
//INITCOB  EXEC PGM=BC1PDSIN,MAXRC=0                       GC1COB               
//C1INIT01 DD DSN=&&COBLIST,DISP=(,PASS),                                       
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),                                
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)                      
//C1INIT02 DD DSN=&&LNKLIST,DISP=(,PASS),                                       
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),                                
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)                      
//C1INIT03 DD DSN=&&ZLRESLT,DISP=(,PASS),                                       
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),                                
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                       
//C1INIT04 DD DSN=&&ZLMESG,DISP=(,PASS),                                        
//            UNIT=&WRKUNIT,SPACE=(TRK,(10,10)),                                
//            DCB=(RECFM=FBA,LRECL=133,BLKSIZE=0,DSORG=PS)                      
//********************************************************************          
//* SEND SOURCE TO SONARQUBE FOR SCAN                                           
//*********************************************************************         
//  IF (&C1USERID = 'ibmuser') THEN                                             
       ++INCLUDE SQSCANER  Scan for code issues                                 
//  ENDIF                                                                       
//********************************************************************          
//* READ SOURCE AND EXPAND INCLUDES                                             
//*********************************************************************         
//CONWRITE EXEC PGM=CONWRITE,COND=(0,LT),MAXRC=0,          GC1COB               
// PARM='EXPINCL(&EXPINC)'                                                      
//ELMOUT   DD DSN=&&ELMOUT,DISP=(,PASS),                                        
//            UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),                         
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=0),                                
//            MONITOR=&MONITOR                                                  
//*******************************************************************           
//**    COMPILE THE ELEMENT                                        **           
//*******************************************************************           
//COMPILE  EXEC PGM=CONPARMX,COND=(4,LT),MAXRC=4,          GCOBOL               
//             PARM=(IGYCRCTL,'(&CPARMA)','&C1SYSTEM','&C1PRGRP',               
//             '&C1ELEMENT','(&CPARMZ)','N','N')                                
//* TEST PROCESSOR GROUP IF CIINBL THEN ALLOCATE COBOL2 LIBRARIES               
//*                      IF CLENBL ALLOCATE COBOL/MVS RUNTIME LIBS              
//* PROCESSOR GROUP IS COBOL/LE                                                 
//STEPLIB  DD  DSN=&CLECOMP,DISP=SHR                                            
//         DD  DSN=&CLERUN,DISP=SHR                                             
//PARMSDEF DD  DSN=&OPTIONS,                                                    
//             MONITOR=&MONITOR,ALLOC=LMAP,                                     
//             DISP=SHR                                                         
//*******************************************************************           
//*     COPYLIB CONCATENATIONS                                     **           
//*******************************************************************           
//SYSLIB   DD  DSN=&COPYLIB,ALLOC=PMAP,                                         
//             MONITOR=&MONITOR,                                                
//             DISP=SHR                                                         
//SYSIN    DD  DSN=&&ELMOUT,DISP=(OLD,PASS)                                     
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(,PASS,DELETE),                                
//             UNIT=&WRKUNIT,SPACE=(TRK,(100,100),RLSE),                        
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=0),                               
//             FOOTPRNT=CREATE                                                  
//SYSUT1   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT2   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT3   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT4   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT5   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT6   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT7   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT8   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT9   DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT10  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT11  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT12  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT13  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT14  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSUT15  DD  UNIT=&WRKUNIT,SPACE=(CYL,(5,3))                                  
//SYSMDECK DD  UNIT=&WRKUNIT,SPACE=(CYL,(1,1))                                  
//SYSPRINT DD  DSN=&&COBLIST,DISP=(OLD,PASS)                                    
//*******************************************************************           
//**    LINK EDIT THE ELEMENT                                      **           
//*******************************************************************           
//LKED     EXEC PGM=IEWL,COND=(4,LT),MAXRC=4,              GC1COB               
// PARM='&PARMLNK'                                                              
//SYSLIN   DD  DSN=&&SYSLIN,DISP=(OLD,DELETE)                                   
//SYSLMOD  DD  DSN=&LOADLIB(&MEMBER),                                           
//             MONITOR=&MONITOR,                                                
//             FOOTPRNT=CREATE,                                                 
//             DISP=SHR                                                         
//SYSLIB   DD  DSN=&LOADLIB,ALLOC=PMAP,                                         
//             MONITOR=&MONITOR,                                                
//             DISP=SHR                                                         
//         DD  DSN=&CLELKED,                                                    
//             DISP=SHR                                                         
//SYSUT1   DD  UNIT=&WRKUNIT,SPACE=(CYL,(1,1))                                  
//SYSPRINT DD  DSN=&&LNKLIST,DISP=(OLD,PASS)                                    
//*********************************************************************         
//*** for Test4z processing\                                                    
//*********INCLUDES(TEST4Z)***(include 1st and either/both others)*      M      
       ++INCLUDE T4ZOPTNS  Test4Z Examine OPTIONS                               
       ++INCLUDE T4ZUNIT   Test4Z Unit Testing for COBOL                        
       ++INCLUDE T4ZRPLA2  Test4Z REPLAY from Recorded data                     
//*    ++EXCLUDE T4ZRPLAY  Test4Z REPLAY from Recorded data                     
//*** for Test4z processing/                                                    
//*********INCLUDES(TEST4Z)****************************************      M      
//  IF (&C1USERID = 'ibmuser') THEN                                             
//*******************************************************************           
//*     STORE THE TEST RESULTS IN USS                                           
//*******************************************************************           
       ++INCLUDE T4ZCUSS   Test4Z Test results store in USS                     
       ++INCLUDE T4ZJNKNO  Test4Z Test results from USS to Jenkins              
//  ENDIF                                                                       
//*******************************************************************           
//*     STORE THE LISTINGS                                                      
//*******************************************************************           
//STORLIST EXEC PGM=CONLIST,MAXRC=0,PARM=STORE,COND=EVEN,  GC1COB               
//           EXECIF=(&LISTLIB,NE,NO)                                            
//C1LLIBO  DD DSN=&LISTLIB,DISP=SHR,                                            
//            MONITOR=&MONITOR                                                  
//C1BANNER DD UNIT=&WRKUNIT,SPACE=(TRK,(1,1)),                                  
//            DCB=(RECFM=FBA,LRECL=121,BLKSIZE=0)                               
//LIST01   DD *                                                                 
************Compile and Link Listing*************                               
//LIST02   DD DSN=&&COBLIST,DISP=(OLD,DELETE)                                   
//LIST03   DD DSN=&&LNKLIST,DISP=(OLD,DELETE)                                   
//LIST04   DD *                                                                 
************TEST4Z ZLRESULT in JSON*************                                
//LIST05   DD DSN=&&ZLRESLT,DISP=(OLD,DELETE)                                   
//LIST06   DD DSN=&&ZLMESG,DISP=(OLD,DELETE)                                    
//LIST07   DD *                                                                 
************END OF TEST4Z RESULTS **************                                
//                                                                              
//**                                                                            
