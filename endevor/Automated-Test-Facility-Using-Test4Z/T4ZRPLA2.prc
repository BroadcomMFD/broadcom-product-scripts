//*--------------------------------------------------------------------*        
//*********INCLUDES(T4ZRPLA2)****************************************           
//*--------------------------------------------------------------------*        
//* T4ZRPLA2 PARM CREATION FROM OPTIONS ELEMENT                                 
//*--------------------------------------------------------------------*        
//*     FETCH   REPLAY                                                          
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Retrieve T4ZLDATA                                               
//*--------------------------------------------------------------------*        
//*   Retrieve T4ZLDAta into a work TL4Zdata file                     *         
//*--------------------------------------------------------------------*        
//T4ZPLA#1 EXEC PGM=C1BM3000,     **Retrve T4Z recording** T4ZRPLA2             
//          PARM='SCLIN,MSGOUT1,,MSGOUT2',                                      
//          COND=((4,LT),(1,NE,T4ZOPTNS)),MAXRC=4                               
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
//ZLMSGSAV DD DSN=&T4ZHLQTM..&C1ELEMENT..ZLMSG,                                 
//            DISP=(NEW,CATLG,KEEP),                                            
//            SPACE=(CYL,(1,15)),UNIT=3390,DSNTYPE=LIBRARY,                     
//            DCB=(RECFM=FB,LRECL=120,BLKSIZE=24000,DSORG=PS)                   
//*--------------------------------------------------------------------*        
//* Relate the T4ZRPLA2 recording to this program.                              
//*--------------------------------------------------------------------*        
//T4ZPLA#2 EXEC PGM=CONRELE,      **Relate T4Z recording** T4ZRPLA2             
//          COND=((4,LT),(1,NE,T4ZOPTNS),(4,LT,T4ZPLA#1))                       
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
//*     Create a REPLAY JCL                                                     
//*--------------------------------------------------------------------*        
//T4ZPLA#3 EXEC PGM=IRXJCL,       **Create REPLAY JCL      T4ZRPLA2             
//         PARM='ENBPIU00 1',                                                   
//         COND=((4,LT),(1,NE,T4ZOPTNS),(4,LT,T4ZPLA#1))                        
//TABLE    DD *                                                                 
* Any                                                                           
  *                                                                             
//SYSEXEC  DD DISP=SHR,DSN=Your.NDVR.V1##.USERCLS0                              
//         DD DISP=SHR,DSN=Your.NDVR.V1##.CSIQCLS0                              
//OPTIONS  DD *  Bump jobcard and fetch Accounting code                         
  whoAmI = USERID()                                                             
* Accounting value fetch may not be necessary at your site                      
  myJobAccountingCode = GETACCTC(whoAmI)                                        
  myJobName = MVSVAR('SYMDEF',JOBNAME )                                         
  BumpedJobname = BUMPJOB(myJobName)                                            
//MODEL    DD DATA,DLM=QQ                                                       
//&BumpedJobname JOB (&myJobAccountingCode),'&whoAmI T4Z',              JOB31783
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID                                    
//*----------------------------------------------------------                   
//  SET LOADLIB=&LOADLIB                                                        
//  SET T4ZLDATA=&T4ZLDATA                                                      
//*----------------------------------------------------------                   
//RUNTEST  EXEC PGM=ZTESTEXE      **runs as submitted job  T4ZRPLA2             
//STEPLIB  DD DISP=SHR,DSN=Your.TEST4Z.CT4ZLOAD                                 
//         DD DISP=SHR,DSN=&LOADLIB                                             
//*        DD DISP=SHR,DSN=YOUR.V190.STG1.LOADLIB                               
//*        DD DISP=SHR,DSN=YOUR.V190.STG1.T4ZLOAD                               
//ZLDATA   DD DSN=&T4ZLDATA,                                                    
//         DISP=SHR                                                             
//ZLOPTS   DD *                                                                 
RUN(&C1ELEMENT),REPLAY                                                          
COVERAGE,DEEP                                                                   
//*                                                                             
//CEEOPTS  DD *                                                                 
TRAP(ON,NOSPIE)                                                                 
//ZLCOVER  DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT   DD SYSOUT=*                                                          
//***                      /  ** captured+examined by processor                 
//ZLMSG    DD DSN=&T4ZHLQTM..&C1ELEMENT..ZLMSG,                                 
//         DISP=SHR                                                             
//*----------------------------------------------------------                   
QQ                                                                              
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSTSPRT DD SYSOUT=*                                                          
//TBLOUT   DD DSN=&T4ZHLQTM..&C1ELEMENT..REPLAY,                                
//            DISP=(NEW,CATLG,KEEP),                                            
//            SPACE=(CYL,(1,01)),UNIT=3390,DSNTYPE=LIBRARY,                     
//            DCB=(RECFM=FB,LRECL=080,BLKSIZE=24000,DSORG=PS)                   
//*                                                                             
//*--------------------------------------------------------------------*        
//*     Submit and wait for Replay job, and get ZLMSGS.                         
//*--------------------------------------------------------------------*        
//SUBMITRP EXEC PGM=IKJEFT1B,     **Submit REPLAY JCL      T4ZRPLA2             
//          COND=((4,LT),(1,NE,T4ZOPTNS),(4,LT,T4ZPLA#1)),                      
//   PARM='SUBMITST &T4ZHLQTM..&C1ELEMENT..REPLAY 10 01'                        
//*  PARM='SUBMITST <SubmitJCL> <NumberWaits> <SecondsPerWait>'                 
//SYSEXEC  DD DISP=SHR,DSN=Your.NDVR.V1##.USERCLS0                              
//SYSTSPRT DD SYSOUT=*                                                          
//SYSTSIN  DD DUMMY                                                             
//**********************************************************************        
//* Indicate a PASS or FAIL condition onto the Element                          
//**********************************************************************        
//PASSFAIL EXEC PGM=IRXJCL,       **Determine Pass/Fail**  T4ZRPLA2             
//         PARM=' ',    (null char)                                             
//         COND=((8,LT),(1,NE,T4ZOPTNS)),MAXRC=2                                
//ZLMSGIN  DD DSN=&T4ZHLQTM..&C1ELEMENT..ZLMSG,                                 
//            DISP=SHR                                                          
//ZLMSG    DD SYSOUT=*                                                          
//SYSEXEC  DD DSN=&&TOPTIONS,DISP=(OLD,PASS)                                    
//         DD *                                                                 
  $my_rc =3                                                                     
  "EXECIO * DISKR ZLMSGIN  (Stem zmsg. Finis"                                   
  "EXECIO * DISKW ZLMSG    (Stem zmsg. Finis"                                   
  Do j# = 1 to zmsg.0                                                           
     msgtext = zmsg.j#                                                          
     If Pos('Testing passed on',msgtext) /= 0 then,                             
        Do;  Queue msgtext; $my_rc =1; Leave; End                               
     If Pos('Code coverage for',msgtext) /= 0 then,                             
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
//**********************************************************************        
//  IF (SUBMITRP.RUN AND RC < 5) THEN                                           
//**********************************************************************        
//T4ZPLA#4 EXEC PGM=IEFBR14       **Delete temp datasets** T4ZRPLA2             
//ZLDATA   DD DSN=&T4ZLDATA,                                                    
//            DISP=(OLD,DELETE)                                                 
//REPLAY   DD DSN=&T4ZHLQTM..&C1ELEMENT..REPLAY,                                
//            DISP=(OLD,DELETE)                                                 
//**********************************************************************        
//  ENDIF                                                                       
//**********************************************************************        
