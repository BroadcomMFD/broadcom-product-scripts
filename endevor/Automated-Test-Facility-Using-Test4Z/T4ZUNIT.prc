//*--------------------------------------------------------------------*        
//*********INCLUDES(T4ZUNI)****************************************             
//*--------------------------------------------------------------------*        
//**********************************************************************        
//*     Run T4ZUNI                                                              
//**********************************************************************        
//T4ZUNI#1 EXEC PGM=ZESTRUN,      **Run T4Z unit Test**    T4ZUNIT              
//         COND=((4,LT),(2,NE,T4ZOPTNS))                                        
//STEPLIB  DD DISP=SHR,DSN=YOUR.V190.T4Z.T4ZLOAD                                
//         DD DISP=SHR,DSN=&LOADLIB,                                            
//            ALLOC=LMAP                                                        
//         DD DISP=SHR,DSN=&T4ZLOAD,                                            
//            ALLOC=LMAP                                                        
//ZLOPTS   DD DSN=&&ZLOPTION,DISP=(OLD,DELETE)                                  
//CEEOPTS  DD *                                                                 
TRAP(ON,NOSPIE)                                                                 
TERMTHDACT(UADUMP)                                                              
ALL31(ON)                                                                       
PROFILE(OFF)                                                                    
//ZLDATA   DD DISP=SHR,DSN=Your.NDVR.V1##.SMPLTEST.T4ZLDATA                     
//* output\                                                                     
//ZLRESULT DD DISP=SHR,DSN=&T4ZLJSON(&C1ELEMENT),                               
//            MONITOR=COMPONENTS                                                
//ZLCOVER  DD SYSOUT=*                                                          
//ZLMSG    DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT1  DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//**********************************************************************        
//* Show the intermediate results                                               
//**********************************************************************        
//SHOWJSON EXEC PGM=IEBGENER,     **Show Results**         T4ZUNIT              
//         COND=((4,LT),(2,NE,T4ZOPTNS)),                                       
//         EXECIF=(&C1ACTION,EQ,GENERATE)                                       
//SYSPRINT DD DUMMY                                                             
//SYSUT1   DD DISP=SHR,DSN=&T4ZLJSON(&C1ELEMENT)                                
//SYSUT2   DD DSN=&&ZLRESLT,DISP=(OLD,PASS)                                     
//SYSIN    DD DUMMY                                                             
//**********************************************************************        
//* Indicate a PASS or FAIL condition onto the Element                          
//**********************************************************************        
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  T4ZUNIT              
//         PARM='  ',  <- '00'x                                                 
//         COND=((4,LT),(2,NE,T4ZOPTNS)),                                       
//         MAXRC=2                                                              
//SYSEXEC  DD DSN=&&TOPTIONS,DISP=(OLD,PASS)                                    
//         DD *                                                                 
  CALL BPXWDYN "ALLOC FI(UNITTEST) ",                                           
       "DA(&T4ZLJSON(&C1ELEMENT)) SHR REUSE"                                    
  If RESULT /= 0 then,                                                          
     Do; Queue "Cannot find json results in",                                   
         "&T4ZLJSON(&C1ELEMENT)" ; $my_rc =3 ;                                  
     End                                                                        
  Else,                                                                         
     Do; $my_rc =1 ;                                                            
     Queue "Found UnitTest results in &T4ZLJSON(&C1ELEMENT)"                    
     "EXECIO * DISKR UNITTEST (Stem json. Finis"                                
     CALL BPXWDYN "FREE FI(UNITTEST)"                                           
     Do j# = 1 to json.0                                                        
        jsontext = json.j#                                                      
        If pos('"testSuite":',jsontext)> 0 then,                                
           Queue "UNITTEST:" jsontext ;                                         
        where = Pos('"failed":',jsontext)                                       
        If where = 0 then iterate;                                              
        Queue "UNITTEST:" jsontext                                              
        unittestRc = Word(substr(jsontext,where),2)                             
        If unittestRc /= "0," then Do; $my_rc =3; Leave; End                    
     End; /* Do j# = 1 to json.0 */                                             
     End; /* ELSE... */                                                         
                                                                                
  if $my_rc =1 then,                                                            
     Queue "Unit Test was successful"                                           
                                                                                
  if $my_rc =3 then,                                                            
     Queue "Test Failed"                                                        
                                                                                
  If Allow_test_fails = 'Y' then,                                               
     Do; Queue "The Allow_test_fails = 'Y' is set"; $my_rc =2 ; End             
                                                                                
  MessageDD  = Word("SUCCESS WARNING FAILURE",$my_rc)                           
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "                               
  "EXECIO " QUEUED() "DISKW" MessageDD "( Finis"                                
  CALL BPXWDYN "Free  DD("MessageDD")"                                          
                                                                                
  exit($my_rc)                                                                  
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//*--------------------------------------------------------------------*        
//**********************************************************************        
//**********************************************************************        
//*******************************************************************           
