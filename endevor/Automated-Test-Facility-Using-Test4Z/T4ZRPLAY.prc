//*--------------------------------------------------------------------*        
//*********INCLUDES(T4ZRPLAY)****************************************           
//*--------------------------------------------------------------------*        
//* T4ZRPLAY PARM CREATION FROM OPTIONS ELEMENT                                 
//**********************************************************************        
//*     Find REPLAY element output                                              
//**********************************************************************        
//T4ZPLA#2 EXEC PGM=CONAPI,       **find T4Z recording**   T4ZRPLAY             
//          PARM='CONCALL,DDN:CONLIB,BC1PCSV0', (EXEC FROM CONLIB )             
//          COND=((4,LT),(1,NE,T4ZOPTNS))                                       
//CSVIPT01 DD *                                                                 
LIST ELEMENT &C1ELEMENT                                                         
     FROM ENVIRONMENT &C1EN SYSTEM &C1SY  SUBSYSTEM &C1SU                       
          TYPE  T4ZLDATA STAGE NUMBER '&C1S#'                                   
     TO DDNAME 'TABLE'                                                          
     OPTIONS   SEARCH   RETURN FIRST PATH PHYSICAL .                            
//CSVMSGS1 DD SYSOUT=*                                                          
//C1MSGSA  DD SYSOUT=*                                                          
//TABLE    DD DSN=&&EXTRACTM,                                                   
//      DCB=(RECFM=FB,LRECL=3000,BLKSIZE=24000,DSORG=PS),                       
//      DISP=(NEW,CATLG,DELETE),SPACE=(CYL,(1,1),RLSE)                          
//BSTERR   DD SYSOUT=*                                                          
//*--------------------------------------------------------------------*        
//* Relate the T4ZRPLAY recording to this program.                              
//*--------------------------------------------------------------------*        
//T4ZPLA#3 EXEC PGM=CONRELE,      **Relate T4Z recording** T4ZRPLAY             
//          COND=((4,LT),(1,NE,T4ZOPTNS),(4,EQ,T4ZPLA#2))                       
//NDVRIPT  DD  *                                                                
RELATE ELEMENT &C1ELEMENT                                                       
   LOCATION                                                                     
   ENVIRONMENT = &C1EN                                                          
   SYSTEM      = &C1SY                                                          
   SUBSYSTEM   = &C1SU                                                          
   TYPE        = T4ZLDATA                                                       
   STAGE       = &C1STGID                                                       
   INPUT VALIDATE.                                                              
//*--------------------------------------------------------------------*        
//*     FETCH   REPLAY                                                          
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Retrieve T4ZLDATA                                               
//*--------------------------------------------------------------------*        
//*   Retrieve T4ZLDAta into a work TL4Zdata file                     *         
//*--------------------------------------------------------------------*        
//C1BM3000  EXEC PGM=C1BM3000,    **Retrve T4Z recording** T4ZRPLAY             
//          PARM='SCLIN,MSGOUT1,,MSGOUT2',                                      
//          COND=((4,LT),(1,NE,T4ZOPTNS)),MAXRC=0                               
//MSGOUT1   DD  SYSOUT=*                                                        
//MSGOUT2   DD  SYSOUT=*                                                        
//SYSABEND  DD  SYSOUT=*                                                        
//SCLIN     DD  *                                                               
 RETRIEVE ELEMENT &C1ELEMENT                                                    
    FROM ENVIRONMENT &C1EN  SYSTEM &C1SY SUBSYSTEM &C1SU                        
         TYPE T4ZLDATA  STAGE &C1STGID                                          
    TO DSN '&T4ZLDATA'                                                          
    OPTIONS SEARCH NO SIGNOUT REPLACE.                                          
//T4ZLDATA DD DSN=&T4ZLDATA,                                                    
//            DISP=(MOD,CATLG,KEEP),                                            
//            SPACE=(CYL,(1,15)),UNIT=3390,DSNTYPE=LIBRARY,                     
//            DCB=(RECFM=VB,LRECL=32000,BLKSIZE=32004,DSORG=PO)                 
//*--------------------------------------------------------------------*        
//*--------------------------------------------------------------------*        
//*     Execute REPLAY                                                          
//*----------------------------------------------------------                   
//T4ZPLA#5 EXEC PGM=ZTESTEXE,     **Run    T4Z replay   ** T4ZRPLAY             
//          COND=((4,LT),(1,NE,T4ZOPTNS))                                       
//STEPLIB   DD DISP=SHR,DSN=Your.TEST4Z.CT4ZLOAD                                
//          DD DISP=SHR,DSN=&LOADLIB                                            
//*         DD DISP=SHR,DSN=YOUR.V190.STG1.LOADLIB                              
//          DD DISP=SHR,DSN=YOUR.V190.STG1.T4ZLOAD                              
//ZLOPTS    DD *                                                                
RUN(&C1ELEMENT),REPLAY                                                          
COVERAGE,DEEP                                                                   
//CEEOPTS  DD *                                                                 
TRAP(ON,NOSPIE)                                                                 
//ZLDATA   DD DSN=&T4ZLDATA,                                                    
//            DISP=SHR                                                          
//ZLCOVER  DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT   DD SYSOUT=*                                                          
//ZLMSG    DD DSN=&&T4ZLMSG,                                                    
//            DISP=(NEW,PASS),                                                  
//            SPACE=(CYL,(1,15)),UNIT=3390,                                     
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=24000,DSORG=PS)                   
//**********************************************************************        
//* Indicate a PASS or FAIL condition onto the Element                          
//**********************************************************************        
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  T4ZREPLA             
//         PARM=' ',    (null char)                                             
//         COND=((8,LT),(1,NE,T4ZOPTNS)),MAXRC=2                                
//ZLMSGIN  DD DSN=&&T4ZLMSG,DISP=(OLD,DELETE)                                   
//ZLMSG    DD SYSOUT=*                                                          
//SYSEXEC  DD *                                                                 
  $my_rc =3                                                                     
  "EXECIO * DISKR ZLMSGIN  (Stem zmsg. Finis"                                   
  "EXECIO * DISKW ZLMSG    (Stem zmsg. Finis"                                   
  Do j# = 1 to zmsg.0                                                           
     msgtext = zmsg.j#                                                          
     If Pos('Testing passed on',msgtext) /= 0 then,                             
        Do;  Queue msgtext; $my_rc =1; Leave; End                               
  End; /* Do j# = 1 to zmsg.0 */                                                
                                                                                
  if $my_rc =1 then,                                                            
     Queue "Replay Test was successful"                                         
  if $my_rc =3 then,                                                            
     Queue "Test Failed"                                                        
  If Allow_test_fails = 'Y' then,                                               
     Do; Queue "The Allow_test_fails = 'Y' is set"; $my_rc =2 ; End             
                                                                                
  MessageDD  = Word("SUCCESS WARNING FAILURE",$my_rc)                           
  Call BPXWDYN "ALLOC DD("MessageDD") SYSOUT(A) "                               
  "EXECIO " QUEUED() "DISKW" MessageDD "( Finis"                                
  CALL BPXWDYN "Free  DD("MessageDD")"                                          
  if $my_rc =3 then $my_rc =8                                                   
                                                                                
  exit($my_rc)                                                                  
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//*--------------------------------------------------------------------*        
//**********************************************************************        
//*----------------------------------------------------------                   
//T4ZPLA#6 EXEC PGM=IEFBR14,      **Delete temp dataset ** T4ZRPLAY             
//          COND=((4,LT),(1,NE,T4ZOPTNS),(0,NE,T4ZPLA#5))                       
//ZLDATA   DD DSN=&T4ZLDATA,                                                    
//            DISP=(OLD,DELETE)                                                 
//*----------------------------------------------------------                   
