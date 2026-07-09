//IBMUSERS JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*==================================================================*          
//*     https://github.com/BroadcomMFD/broadcom-product-scripts      */         
//* This version of a "Sweep Job" goes beyond traditional functions: */         
//*   - It submits jobs to execute packages ( traditional function)  */         
//*   - It submits jobs to ship    packages ("Package Automation" )  */         
//*     The Trigger file is scanned to find packages whose           */         
//*     scheduled shipment date-time has arrived.                    */         
//*     A shipment job is submitted for each one found.              */         
//*     The MODELDSN is the name of the dataset where your           */         
//*     Shipment models are found.                                   */         
//*     Packages that can be shipped immediately after Execution     */         
//*     are submitted by the Exit and not by this job.               */         
//*==================================================================*          
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)      <-Where are INCLUDES             
// EXPORT SYMLIST=(*)                                                           
//*--                                                                -*         
//  SET PKGPREFX='FINA*'                      <- Execute for Stg                
//*--                                                                -*         
//  SET SUBMITDS=IBMUSER.PULLTGGR             <- Work  datasets                 
//  SET MODELDSN=YOURSITE.YOUR.NDVR.NODES1.ISPS                                 
//*==================================================================*          
//*-------------------------------------------------------------------*         
//* SWEEP PACKAGE DATABASE AND ESTABLISH RUNJCL FOR PACKAGES THAT   *   JOB02096
//* ARE APPROVED AND MEET SUBMIT TIMES                              *   JOB02096
//*-------------------------------------------------------------------*         
//EXECUTE  EXEC PGM=NDVRC1,PARM='ENBP1000',REGION=0M                            
//   INCLUDE MEMBER=STEPLIB      <-Endevor STEPLIB,CONLIB etc                   
//JCLIN    DD   DATA,DLM=QQ                                                     
//PACKAGEX JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID TYPRUN=HOLD                                              
// JCLLIB  ORDER=(YOUR.NDVR.CSIQJCL)  <-Where is ENDEVOR proc                   
//*-- Execute Endevor Package -----------------------------------------         
QQ                                                                              
//JCLOUT   DD   SYSOUT=(A,INTRDR),DCB=(BLKSIZE=80,LRECL=80,RECFM=F)             
//ENPSCLIN  DD *,SYMBOLS=JCLONLY                                                
 SUBMIT PACKAGE *                                                               
 JOBCARD DDNAME JCLIN                                                           
    TO INTERNAL READER DDNAME JCLOUT                                            
    OPTION WHERE PACKAGE STATUS IS APPROVED                                     
           INCREMENT JOBNAME                                                    
           JCL PROCEDURE NAME IS ENDEVOR                                        
 .                                                                              
//C1MSGS1  DD   SYSOUT=*                                                        
//C1MSGS2  DD   SYSOUT=*                                                        
//SYSTERM  DD   SYSOUT=*                                                        
//SYSPRINT DD   SYSOUT=*                                                        
//SYSABEND DD   SYSOUT=*                                                        
//*-------------------------------------------------------------------*         
//*  Run the step below to Sweep Package Shipments.                  -*         
//*-------------------------------------------------------------------*         
//SHIPMENT EXEC PGM=IKJEFT1B,COND=(4,LE),                                       
//   PARM=('PULLTGGR &SUBMITDS',                                                
//         ' &MODELDSN')                                                        
//   INCLUDE MEMBER=STEPLIB      <-Endevor STEPLIB,CONLIB etc                   
//   INCLUDE MEMBER=SYSEXEC      <- where is PULLTGGR + CSIQCLS0                
//SYSTSPRT DD SYSOUT=*                                                          
//PULLTGGR DD DUMMY                                                             
//SYSPRINT DD SYSOUT=*                                                          
//*  Trigger file is dynamically allocated                                      
//SUBFAILS DD SYSOUT=*                                                          
//SYSTSIN  DD DUMMY                                                             
//*-------------------------------------------------------------------*         
