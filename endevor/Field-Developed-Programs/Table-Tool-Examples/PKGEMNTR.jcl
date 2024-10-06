//IBMUSERT JOB (0000),                                                          
//         CLASS=A,MSGCLASS=X,REGION=4M,NOTIFY=&SYSUID                          
//*==================================================================*          
//*- To run the Package Monitory report                   -------               
//*--------------------------------------------------------------               
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL.CSV)                                   
//*==================================================================*          
//   EXPORT SYMLIST=(*)           <- make JCL symbols available                 
//*** STEP 1 -- EXECUTE CSV UTILITY to find APPROVED and EXEC packages          
//STEP1    EXEC PGM=NDVRC1,REGION=4M,                                           
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0' (EXEC FROM NON-AUTH LIB)          
//   INCLUDE MEMBER=STEPLIB                                                     
//CSVIPT01 DD *                                                                 
 LIST PACKAGE ID '*'                                                            
    WHERE STATUS = (APPROVED, EXECUTED, INAPPROVAL)                             
          OPTIONS QUALIFIER QUOTE                                               
          TO FILE APIEXTR .                                                     
//APIEXTR DD DSN=&&APIPKGE,                                                     
//        DCB=(DSORG=PS,RECFM=VB,LRECL=4092),                                   
//        DISP=(MOD,PASS,DELETE),UNIT=3390,                                     
//        SPACE=(CYL,(5,5),RLSE)                                                
//CSVMSGS1 DD SYSOUT=*                                                          
//DISPLAYS DD DUMMY                                                             
//C1MSGSA DD SYSOUT=*                                                           
//BSTERR  DD SYSOUT=*                                                           
//SYMDUMP DD DUMMY                                                              
//SYSUDUMP DD SYSOUT=*                                                          
//*-------------------------------------------------------------------          
//* Identify Packages to monitor                                                
//*   build additional package CSV utility commands for shipment rqsts          
//*-------------------------------------------------------------------          
//STEP3    EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'                             
//TABLE    DD DSN=&&APIPKGE,DISP=(OLD,PASS)                                     
//   INCLUDE MEMBER=CSIQCLS0                                                    
//PARMLIST DD  *                                                                
  MODELHD  TBLOUT1 SELECTS  1                                                   
  MODEL1   TBLOUT1 OPTIONS1 A                                                   
  MODEL2   TBLOUT2 OPTIONS2 A                                                   
//MODELHD  DD *                                                                 
*Note-----  Package--------- Date------ Time- Dest Env- Status-----             
//SELECTS  DD *                                                                 
  $Table_Type = "CSV"                                                           
  $StripData = 'N' ;                                                            
  DESTTABLusers='FCFE FCAE FCMA FCOG SWEF'                                      
  tday= DATE(S)                                                                 
  today = Substr(tday,1,4)'/'Substr(tday,5,2)'/'Substr(tday,7)                  
  BaseDate = DATE('B')                                                          
  NewBase  = BaseDate - 1;                                                      
  yester = DATE(S,NewBase,B)                                                    
  yestrday = Substr(yester,1,4)'/'Substr(yester,5,2)'/'Substr(yester,7)         
  NewBase  = BaseDate + 1;                                                      
  tomorw = DATE(S,NewBase,B)                                                    
  tomorrow = Substr(tomorw,1,4)'/'Substr(tomorw,5,2)'/'Substr(tomorw,7)         
  Say 'tomorrow='tomorrow                                                       
* for the second set of outputs                                                 
  ShipCount = 0                                                                 
  myOptions = ' '                                                               
  $my_rc = 4                                                                    
//OPTIONS1 DD *                                                                 
 if $row# < 1 then $SkipRow='Y'                                                 
 keeper = 'n'                                                                   
 Dest = '    '                                                                  
 PkgPrfx=Substr(PKG_ID,1,4)                                                     
 If WordPos(PkgPrfx,DESTTABLusers)>0 then Dest = 'Dest'                         
*If PROM_TGT_STGID = 'P' then keeper='Prod'                                     
 date=WINDOW_START_DATE                                                         
 time=WINDOW_START_TIME                                                         
 If STATUS='EXECUTED' then date=EXEC_BEGIN_DATE                                 
 If STATUS='EXECUTED' then time=EXEC_BEGIN_TIME                                 
 If date = today then keeper='Today'                                            
 If date = yestrday then keeper='yesterday'                                     
 If date = tomorrow then keeper='tomorrow '                                     
 If date > tomorrow then keeper='future   '                                     
 PROM_TGT_ENV = Left(PROM_TGT_ENV,4)                                            
*If PROM_TGT_ENV='    ' then PROM_TGT_ENV=Substr(NOTE8,8,4)                     
 If keeper = 'n' then $SkipRow = 'Y'                                            
 $my_rc = 0                                                                     
 STATUS = Left(STATUS,14)                                                       
 keeper = left(keeper,10)                                                       
 MyKeeper.PKG_ID = keeper                                                       
 PKG_ID = Left(PKG_ID,16)                                                       
//OPTIONS2 DD *                                                                 
 if $row# < 1 then $SkipRow='Y'                                                 
 If MyKeeper.PKG_ID = 'n' then $SkipRow='Y'                                     
 ShipCount = ShipCount + 1                                                      
 PKG_ID = Left(PKG_ID,16)                                                       
//MODEL1   DD *                                                                 
 &keeper &PKG_ID &date &time &Dest &PROM_TGT_ENV &STATUS                        
//MODEL2   DD *                                                                 
  LIST PACKAGE SHIP                                                             
    FROM PACKAGE '&PKG_ID'                                                      
    OPTIONS &myOptions                                                          
    TO FILE APISHIP .                                                           
//SYSPRINT DD SYSOUT=*                                                          
//NOTHING  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//TBLOUT1  DD DSN=&&LISTPKGS,                                                   
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),                                    
//         DISP=(NEW,PASS),UNIT=3390,                                           
//         SPACE=(TRK,(5,5),RLSE)                                               
//TBLOUT2  DD DSN=&&CSVALSHP,                                                   
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),                                    
//         DISP=(NEW,PASS),UNIT=3390,                                           
//         SPACE=(TRK,(5,5),RLSE)                                               
//*-------------------------------------------------------------------          
//*   EXECUTE CSV UTILITY to capture package Shipment data                      
//*             for packages identified/selected in prev step                   
//*-------------------------------------------------------------------          
//STEP4    EXEC PGM=NDVRC1,REGION=4M,                                           
//         COND=(0,NE,STEP3),                                                   
//         PARM='CONCALL,DDN:CONLIB,BC1PCSV0' (EXEC FROM NON-AUTH LIB)          
//CSVIPT01 DD DSN=&&CSVALSHP,DISP=(OLD,DELETE)                                  
//   INCLUDE MEMBER=STEPLIB                                                     
//APISHIP  DD DSN=&&APISHIP,                                                    
//         DCB=(DSORG=PS,RECFM=VB,LRECL=4092),                                  
//         DISP=(MOD,PASS,DELETE),UNIT=3390,                                    
//         SPACE=(CYL,(5,5),RLSE)                                               
//*   EXECUTION MESSAGES (CSV LOG MESSAGES)                                     
//CSVMSGS1 DD SYSOUT=*                                                          
//*   EXECUTION MESSAGES (API LOG MESSAGES)                                     
//C1MSGSA  DD SYSOUT=*                                                          
//*   ERROR FILE                                                                
//BSTERR   DD SYSOUT=*                                                          
//SYMDUMP  DD DUMMY                                                             
//DISPLAYS DD DUMMY                                                             
//SYSUDUMP DD SYSOUT=*                                                          
//*---------------------------------------------------------------------        
//*--  Save Shipment info in a format for next step                             
//*---------------------------------------------------------------------        
//STEP6    EXEC PGM=IRXJCL,PARM='ENBPIU00 A',                                   
//         COND=(0,NE,STEP3)                                                    
//TABLE    DD DSN=&&APISHIP,DISP=(OLD,DELETE)                                   
//   INCLUDE MEMBER=CSIQCLS0                                                    
//OPTIONS  DD *                                                                 
  $Table_Type = "CSV"                                                           
//MODEL    DD *                                                                 
  Shipment.&PKG_ID = "&DEST_ID &RMT_MOVE_RC"                                    
//SYSPRINT DD SYSOUT=*                                                          
//SYSTSPRT DD SYSOUT=*                                                          
//TBLOUT   DD DSN=&&SHIPDATA,                                                   
//         DCB=(DSORG=PS,RECFM=FB,LRECL=80),                                    
//         DISP=(NEW,PASS),UNIT=3390,                                           
//         SPACE=(TRK,(1,1),RLSE)                                               
//*---------------------------------------------------------------------        
//*--  Write report from all collected data                                     
//*---------------------------------------------------------------------        
//STEP7    EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST',                            
//         COND=(0,NE,STEP3)                                                    
//TABLE    DD DSN=&&LISTPKGS,DISP=(OLD,DELETE)                                  
//   INCLUDE MEMBER=CSIQCLS0                                                    
//SYSTSPRT DD  SYSOUT=*                                                         
//PARMLIST DD  *                                                                
  NOTHING  NOTHING SELECTS  0                                                   
  MODEL    REPORT  SHIPDATA 0                                                   
  HEADINGS REPORT  HEADINGS 1                                                   
  MODEL    REPORT  DETAILS  A                                                   
//SELECTS  DD  *                                                                
  Shipment. = ' '                                                               
//SHIPDATA DD DSN=&&SHIPDATA,DISP=(OLD,DELETE)                                  
//MODELSEL DD  *                                                                
** Selection Date range &StrDte - &EndDte                                       
//HEADINGS DD  *                                                                
*Note----- Package--------- Date------ Time- Status----- Shipment               
//DETAILS  DD  *                                                                
  $StripData = 'N' ;                                                            
*                                                                               
  Dest = Left(Dest,4)                                                           
  Env = Left(Env,4)                                                             
  Shipment = Shipment.Package                                                   
  Package = Left(Package,16)                                                    
//MODEL    DD *                                                                 
 &Note &Package &Date &Time &Status &Shipment                                   
//SYSPRINT DD SYSOUT=*                                                          
//REPORT   DD SYSOUT=*                                                          
                                                                                
