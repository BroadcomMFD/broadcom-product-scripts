//EXAMPL2A JOB (0000),                                                  JOB0    
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*-------------------------------------------------------------------          
//*- To Report Element changes within  a date range   -----------               
//*-------------------------------------------------------------------          
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)                                       
//   EXPORT SYMLIST=(*)           <- make JCL symbols available                 
//   SET STRTDATE='280 DAYS AGO'  <- Specify date or # Days ago                 
//   SET STOPDATE=2999/12/30      <- Specify stop/end date                      
//   SET ENVIRON=PRD              <- Specify Environment                        
//   SET SYSTEM=*                 <- Specify System                             
//*--------------------------------------------------------------------*        
//*   STEP 1 -- Execute CSV Utility to gather Element information               
//*--------------------------------------------------------------------*        
//STEP1    EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='BC1PCSV0'                                                      
//   INCLUDE MEMBER=STEPLIB                                                     
//BSTIPT01 DD *,SYMBOLS=JCLONLY     <- Permits JCL variables here               
LIST ELEMENT '*'                                                                
     FROM ENVIRONMENT &ENVIRON SYSTEM &SYSTEM SUBSYSTEM '*'                     
          TYPE  '*'                                                             
          STAGE NUMBER 2                                                        
     DATA ALL                                                                   
     TO DDNAME 'CSVOUTPT'                                                       
     OPTIONS NOSEARCH .                                                         
//C1MSGS1  DD SYSOUT=*                                                          
//BSTERR   DD SYSOUT=*                                                          
//CSVOUTPT DD DSN=&&CSVFILE,                                                    
//      DCB=(RECFM=FB,LRECL=1800,BLKSIZE=9000,DSORG=PS),                        
//      DISP=(MOD,PASS),UNIT=3390,                                              
//      SPACE=(CYL,(5,5),RLSE)                                                  
//*-------------------------------------------------------------------*         
//*-(To Report Element Move dates, then change to MOVE CSV parms)               
//*-------------------------------------------------------------------*         
//REPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                               
//TABLE    DD  DSN=&&CSVFILE,DISP=(OLD,DELETE)                                  
//PARMLIST DD *                                                                 
  HEADING  REPORT   SETUP     1                                                 
  MODEL    REPORT   OPTIONS   A                                                 
//SETUP    DD *,SYMBOLS=JCLONLY     <- Permits JCL variables here               
  StartDate = '&STRTDATE'                                                       
  StopDate  = '&STOPDATE'                                                       
  today = DATE('S')                                                             
  TodaysDate =  +                                                               
    Substr(today,1,4)'/'||Substr(today,5,2)'/' || +                             
    Substr(today,7);                                                            
  If StopDate > TodaysDate then StopDate = TodaysDate ;                         
  If Words(StartDate) = 3 then, +                                               
     Do; daysago = Word(StartDate,1) ; BaseDate = DATE('B'); +                  
     NumDate = BaseDate - daysago; NewDate = DATE(S,NumDate,B); +               
     StartDate = +                                                              
       Substr(NewDate,1,4)'/'||Substr(NewDate,5,2)'/' || +                      
       Substr(NewDate,7); +                                                     
     End                                                                        
  HeadingText= 'ENV_NAME  ELM_NAME  SYS_NAME  SBS_NAME  TYPE_NAME'              
  HeadingText= HeadingText 'Date------ Time------- Userid '                     
  HeadingText= HeadingText 'Package--------'                                    
//OPTIONS  DD *                                                                 
  If ELM_LAST_LL_DATE < StartDate then $SkipRow = 'Y'                           
  If ELM_LAST_LL_DATE > StopDate then $SkipRow = 'Y'                            
  ENV_NAME   = Left(ENV_NAME,09)                                                
  ELM_NAME   = Left(ELM_NAME,09)                                                
  SYS_NAME   = Left(SYS_NAME,09)                                                
  SBS_NAME   = Left(SBS_NAME,09)                                                
  TYPE_NAME  = Left(TYPE_NAME,09)                                               
  Details=ELM_LAST_LL_DATE ELM_LAST_LL_TIME ELM_LAST_LL_USRID                   
  Details=Details PKG_ID_@O@                                                    
//   INCLUDE MEMBER=SYSEXEC                                                     
//SYSTSPRT DD SYSOUT=*                                                          
//HEADING  DD  *                                                                
  *** Report of Element Changes &StartDate thru &StopDate ******                
&HeadingText                                                                    
//MODEL    DD  *                                                                
&ENV_NAME &ELM_NAME &SYS_NAME &SBS_NAME &TYPE_NAME &Details                     
//REPORT    DD SYSOUT=*                                                         
                                                                                
