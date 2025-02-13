//*--------------------------------------------------------------------*        
//*********INCLUDES(T4ZOPTNS)****************************************           
//*--------------------------------------------------------------------*        
//* TEST FOR MEMBER NAME MATCHING ELEMENT NAME IN THE OPTION LIBS *             
//* RC=4 IF MEMBER NOT FOUND                                      *             
//*--------------------------------------------------------------------*        
//GETOPTNS EXEC PGM=IEBUPDTE,MAXRC=4,                                           
//         COND=(4,LT)                                                          
//SYSPRINT DD DUMMY                                                             
//SYSIN    DD *                                                                 
./  REPRO NEW=PS,NAME=&C1ELEMENT                                                
//  IF (&C1ACTION = 'GENERATE') THEN                                            
//SYSUT1   DD DSN=&OPTIONS,                                                     
//            DISP=SHR,ALLOC=LMAP,MONITOR=COMPONENTS                            
//  ELSE                                                                        
//SYSUT1   DD DSN=&OPTIONS,                                                     
//            DISP=SHR,ALLOC=LMAP                                               
//  ENDIF                                                                       
//SYSUT2   DD DISP=(NEW,PASS),DSN=&&EOPTIONS,                                   
//            SPACE=(TRK,(10,10)),                                              
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=27920)                             
//*                                                                             
//*--------------------------------------------------------------------*        
//* T4ZOPTNS PARM CREATION FROM OPTIONS ELEMENT                                 
//*--------------------------------------------------------------------*        
//T4ZOPTNS EXEC PGM=IKJEFT1B,     **Examine T4Z Options**  T4ZOPTNS             
//         PARM='ENBPIU00 1',                                                   
//         COND=(4,LT)                                                          
//  IF (GETOPTNS.RC > 0) THEN                                                   
//OPTIONS  DD  *                                                                
    EXIT(0)                                                                     
//  ELSE                                                                        
//OPTIONS  DD  *                                                                
  $nomessages = 'Y'                                                             
  If $row# < 1 then $SkipRow = 'Y'                                              
  &C1STAGE._Tst_Suite       = ''                                                
  &C1STAGE._Allow_test_fails = 'N'                                              
  X = IncludeQuotedOptions(TEST4OPT)                                            
  Tst_Suite = &C1STAGE._Tst_Suite                                               
  Allow_test_fails = &C1STAGE._Allow_test_fails                                 
  If Tst_Suite = '' then Exit(0)                                                
  x= BuildFromMODEL(MODEL)                                                      
  If Tst_Suite = '*REPLAY*' then Exit(1)                                        
* Unit Testing .....                                                            
  MODEL = "MODEL2"                                                              
  TBLOUT = "TBLOUT2"                                                            
  $my_rc = 2                                                                    
* normal processing from here expands MODEL2 into TBLOUT2                       
//  ENDIF                                                                       
//TEST4OPT DD DSN=&&EOPTIONS,DISP=(OLD,DELETE)                                  
//TABLE    DD *     <- Table Tool requires a TABLE. Little value here           
* Tst_Suite                                                                     
  *                                                                             
//MODEL    DD *                  *Reporting output                              
  Tst_Suite = '&Tst_Suite'                                                      
  Allow_test_fails = '&Allow_test_fails'                                        
//MODEL2   DD *                  *UnitTest  output                              
ZESTPARM(D=&T4ZLOAD.,M=&Tst_Suite)                                              
COVERAGE,DEEP                                                                   
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                            
//         DD DISP=SHR,DSN=&USERCLS0                                            
//TBLOUT2  DD DSN=&&ZLOPTION,DISP=(,PASS,DELETE),                               
//            UNIT=SYSDA,SPACE=(TRK,(1,1)),                                     
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)                              
//TBLOUT   DD DSN=&&TOPTIONS,DISP=(,PASS,DELETE),                               
//            UNIT=SYSDA,SPACE=(TRK,(1,1)),                                     
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)                              
//**********************************************************************        
//* Show the intermediate results                                               
//**********************************************************************        
//SHOWOPTS EXEC PGM=IEBGENER,     **Show Results**         T4ZOPTNS             
//         COND=(4,LT)                                                          
//SYSPRINT DD DUMMY                                                             
//SYSUT1   DD DISP=SHR,DSN=&&TOPTIONS                                           
//  IF (T4ZOPTNS.RC = 2) THEN                                                   
//         DD DISP=SHR,DSN=&&ZLOPTION                                           
//  ENDIF                                                                       
//SYSUT2   DD SYSOUT=*                                                          
//SYSIN    DD DUMMY                                                             
//*--------------------------------------------------------------------*        
//*********INCLUDES(T4ZOPTNS)****************************************           
//*--------------------------------------------------------------------*        
