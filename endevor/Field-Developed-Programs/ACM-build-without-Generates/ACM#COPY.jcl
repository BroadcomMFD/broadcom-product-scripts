//IBMUSERC JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//**=================================================================**         
//** Find unused COPYbooks from the MERGED data     =================**         
//**=================================================================**         
//*  Input: &HLQ..*.MERGED                                                      
//* Output: &HLQ..COMBINED.MERGED                                               
//*  Input: &HLQ..COMBINED.MERGED                                               
//*  Input: &HLQ..ACM#LOAD.COMPONTS                                             
//* Output: Find suspected unused input components in SORTOF01                  
//**=================================================================**         
//  SET HLQ=IBMUSER.ACM#BILD           Intermediate files HLQ                   
//  SET MODELLIB=&SYSUID..ACM#BILD.WORK       <-  WorkLib                       
//  SET CSIQCLS0=YOUR.NDVR.CSIQCLS0    <-Where is ENBPIU00                      
//**=================================================================**         
//*-------------------------------------------------------------------*         
//*-- Use LISTCAT to list all **.MERGED datasets (1 of 2) ------------*         
//*     Output: IBMUSER.ACM#BILD.COMBINED.MERGED                                
//*-------------------------------------------------------------------*         
//LISTCAT1 EXEC PGM=IRXJCL,                                ACM#COPY             
//         PARM='ENBPIU00 M &HLQ'                                               
//SYSEXEC  DD DISP=SHR,DSN=&CSIQCLS0                                            
//* List element types that might be input components                           
//TABLE   DD   * /                                                              
* HighLevelQual----------------------------------                               
  *                                                                             
//OPTIONS DD   *                                                                
  $nomessages = 'Y'                                                             
//MODEL   DD   *                                                                
  LISTCAT LEVEL('&HighLevelQual.*.MERGED') NAME                                 
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//TBLOUT   DD DSN=&&SYSIN,DISP=(NEW,PASS),                                      
//            UNIT=SYSDA,SPACE=(TRK,(1,1)),                                     
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)                              
//*-------------------------------------------------------------------*         
//*-- Use LISTCAT to list all **.MERGED datasets (2 of 2) ------------*         
//*     Output: IBMUSER.ACM#BILD.COMBINED.MERGED                                
//*-------------------------------------------------------------------*         
//LISTCAT2 EXEC  PGM=IDCAMS                                ACM#COPY             
//SYSIN    DD DSN=&&SYSIN,DISP=(OLD,DELETE)                                     
//SYSPRINT DD  DSN=&&LISTCAT,DISP=(,PASS),                                      
//             SPACE=(TRK,(5,10)),                                              
//             RECFM=FB,LRECL=150,BLKSIZE=30000                                 
//**=================================================================**         
//*  Combine the MERGED files into one.                                         
//**=================================================================**         
//*                                                                             
//ALLOC1   EXEC PGM=IKJEFT1B,PARM='ENBPIU00 M NONVSAM'     ACM#COPY             
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//TABLE    DD  DSN=&&LISTCAT,DISP=(OLD,DELETE)                                  
//POSITION DD *                                                                 
  literal       02 08                                                           
  Dataset       18 61                                                           
//MODEL    DD *                                                                 
 CONCATENATING &Dataset                                                         
//OPTIONS  DD  *                                                                
  $QuietMessages = 'Y'         /* Bypass messages Y/N        */                 
* Say Dataset $row# $tbl                                                        
  If Pos('.GRP',Dataset) = 0 then $SkipRow = 'Y'                                
* If $row# < 1 then $SkipRow = 'Y'                                              
* If $tbl  < 1 then $SkipRow = 'Y'                                              
  Dataset = Strip(Dataset)                                                      
  alloc = 'ALLOC F(SYSUT1) DA('''Dataset''') SHR REUS'                          
  Say alloc                                                                     
  alloc                                                                         
  ADDRESS LINK 'IEBGENER'                                                       
  alloc = 'FREE F(SYSUT1)'                                                      
  alloc                                                                         
//SYSPRINT DD  SYSOUT=*                                                         
//SYSTSPRT DD  SYSOUT=*                                                         
//SYSTSIN  DD  DUMMY                                                            
//SYSIN    DD DUMMY                               CONTROL STATEMENTS            
//SYSUDUMP DD SYSOUT=*                                                          
//TBLOUT   DD  SYSOUT=*                                                         
//SYSUT2   DD  DSN=&&MERGED,DISP=(MOD,PASS),                                    
//             SPACE=(CYL,(5,25)),                                              
//             DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                      
//*-------------------------------------------------------------------          
//*    Delete old file if it exists                                   *         
//*********************************************************************         
//DELETOLD EXEC PGM=IEFBR14                                ACM#COPY             
//SORTOUT  DD DSN=&HLQ..COMBINED.MERGED,                                        
//         DISP=(MOD,DELETE,DELETE),                                            
//         UNIT=SYSALLDA,SPACE=(CYL,(1,2),RLSE),                                
//         DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                          
//*-------------------------------------------------------------------          
//*    SORT COMBINED  LIST - keep unique values only                  *         
//*********************************************************************         
//SORTACMQ EXEC PGM=SORT,COND=(4,LT)                       ACM#COPY             
//SORTIN   DD DSN=&&MERGED,DISP=(OLD,DELETE)                                    
//SYSIN    DD *                                                                 
  SORT FIELDS=(1,120,CH,A)                                                      
  SUM FIELDS=NONE                                                               
//SYSPRT   DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT   DD SYSOUT=*                                                          
//SORTOUT  DD DSN=&HLQ..COMBINED.MERGED,                                        
//         DISP=(MOD,CATLG,KEEP),                                               
//         UNIT=SYSALLDA,SPACE=(CYL,(10,25),RLSE),                              
//         DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                          
//*********************************************************************         
//**=================================================================**         
//*  Input: IBMUSER.ACM#BILD.*.MERGED                                           
//* Output: IBMUSER.ACM#BILD.COMBINED.MERGED                                    
//*  Input: IBMUSER.ACM#BILD.ACM#LOAD.COMPONTS                                  
//* Output: Find suspected unused items in SORTOF01                             
//REPORT EXEC PGM=SORT                                     ACM#COPY             
//SORTJNF1 DD DISP=SHR,DSN=IBMUSER.ACM#BILD.ACM#LOAD.COMPONTS                   
//SORTJNF2 DD DISP=SHR,DSN=IBMUSER.ACM#BILD.COMBINED.MERGED                     
//SYSIN    DD *                                                                 
  JOINKEYS FILE=F1,FIELDS=(2,11,A)                                              
  JOINKEYS FILE=F2,FIELDS=(2,11,A)                                              
* Keep the records in F1 that do not have a match in F2                         
  JOIN UNPAIRED,F1,ONLY                                                         
  REFORMAT FIELDS=(F1:1,40)                                                     
  SORT FIELDS=COPY                                                              
  OUTFIL FILES=01,SAVE,BUILD=(1,40)                                             
//SYSOUT   DD SYSOUT=*                                                          
//SORTOF01 DD SYSOUT=*  Unmatched.Records                                       
