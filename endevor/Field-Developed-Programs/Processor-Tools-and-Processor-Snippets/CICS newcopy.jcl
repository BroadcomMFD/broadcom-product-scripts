//IBMUSERT JOB (55800000),                                             
//    'ENDEVOR BATCH',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,     
//    NOTIFY=&SYSUID TYPRUN=SCAN                                       
//*********************************************************************
//* This is a JCL to simulate steps of an Endevor processor        ****
//*********************************************************************
//  SET C1ENV=TEST                                                     
//  SET C1ENV=PROD                                                     
//******                                                               
//  SET C1SYS=FINANCE                                                  
//  SET C1SUB=ACCTREC                                                  
//  SET C1TYP=COBOL                                                    
//  SET C1PRG=CICS                                                     
//  SET C1ELM=ROBERTA                                                  
//*--------------------------------------------------------------------
//TEST001  EXEC PGM=IRXJCL, ENBPIU0C,                                  
// PARM='ENBPIU00 M &C1ENV &C1SYS &C1SUB &C1TYP &C1PRG &C1ELM'         
//TABLE    DD *                                                        
* C1ENV--- C1SYS--- C1SUB--- C1TYP--- C1PRG--- C1ELM---  CICSRegion    
  TEST     *        *        COBOL    CICS     *         CICSTEST      
  TEST     WHATEVER *        COBOL    CICS     *         CICSTSTW      
  PROD     FINANCE  *        COBOL    CICS     *         CICSPROD       
  PROD     FINANCE  *        COBOL    CICS     ROBERTA   CICSPRRB       
//SYSEXEC  DD  DISP=SHR,DSN=CAPRD.NDVR.V180CA06.CSIQCLS0     MM@LIB     
//MODEL    DD DATA,DLM=QQ                                               
/*$VS,'F &CICSRegion,CEMT SET PROG(&C1ELM)   NEW'                
QQ                                                                      
//SYSTSPRT DD SYSOUT=*                                                  
//OPTIONS  DD *                                                         
//TBLOUT   DD SYSOUT=*                                                  
//*-------------------------------------------------------------------- 



// COMMAND 'F &CICSRegion,CEMT S PROG(&C1ELE) PHASEIN'  
