//IBMUSERA JOB (0000),                                                  JOB01236
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//*-------------------------------------------------------------------*         
//* Setup job.                                                      --*         
//* https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/*         
//*  To run a PRINT and Scan on all your inventory would be too     --*         
//*  much to expect. This job identifies inventory to scan and      --*         
//*  breaks up the complete list into "groups" .                    --*         
//*-------------------------------------------------------------------*         
//*-      Modify the SET statements ----------------------------------*         
//*-      Modify the TABLE of input components in BILDACM3 step ------*         
//*-      Modify the TABLE of input users      in BILDACM9 step ------*         
//*-------------------------------------------------------------------*         
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)      <-Where is STEPLIB incl          
//*==================================================================*          
//  EXPORT SYMLIST=(*)                                                          
//*-------------------------------------------------------------------*         
//  SET HLQ=&SYSUID..ACM#BILD          Intermediate files HLQ                   
//  SET ENVMNT='PRD     '              Environment to scan (8)                  
//  SET STAGE='2'                        last stage in environment              
//  SET MODELLIB=&SYSUID..ACM#BILD.WORK       <-  WorkLib                       
//  SET CSIQCLS0=YOUR.NDVR.CSIQCLS0    <-Where is ENBPIU00                      
//*-------------------------------------------------------------------*         
//*---- Remove files from last run -----------------------------------*         
//*-------------------------------------------------------------------*         
//CLEANUP  EXEC PGM=IEFBR14                                ACM#LOD1             
//SYSUT2   DD DSN=&HLQ..ACMTABLE,                                               
//         DISP=(MOD,DELETE,DELETE),                                            
//         UNIT=SYSALLDA,SPACE=(TRK,(01,01),RLSE),                              
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS)                           
//SORTOUT  DD DSN=&HLQ..ACM#LOAD.ELEMLIST,                                      
//             DISP=(MOD,DELETE,DELETE),                                        
//             UNIT=SYSDA,SPACE=(CYL,(5,5)),                                    
//             DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000)                          
//COMPONTS DD DSN=&HLQ..ACM#LOAD.COMPONTS,                                      
//             DISP=(MOD,DELETE,DELETE),                                        
//         UNIT=SYSALLDA,SPACE=(CYL,(01,01),RLSE),                              
//         DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                          
//*-------------------------------------------------------------------*         
//*---- Format and Save JCL variables --------------------------------*         
//*-------------------------------------------------------------------*         
//ENV@STG  EXEC PGM=IRXJCL,                                ACM#LOD1             
//          PARM='ENBPIU00 M &ENVMNT &STAGE'                                    
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//TABLE   DD   *                                                                
* ENVMNT-- STAGE                                                                
  *        *                                                                    
//OPTIONS DD   *                                                                
  ENVMNT_8 = Left(ENVMNT,8)                                                     
//MODEL   DD   *                                                                
  ENVMNT = '&ENVMNT_8'                                                          
  STAGE  = '&STAGE'                                                             
//SYSTSPRT DD DUMMY                                                             
//TBLOUT   DD DISP=SHR,DSN=&MODELLIB(ENV@STG)                                   
//*-------------------------------------------------------------------*         
//*---- Create a Header for the output Table--------------------------*         
//*-------------------------------------------------------------------*         
//HEADER   EXEC PGM=IEBGENER                               ACM#LOD1             
//SYSPRINT DD DUMMY                                                             
//SYSIN    DD DUMMY                                                             
//SYSUT1   DD *                                                                 
* Group  Start       Stop       JobChar                                         
//SYSUT2   DD DSN=&HLQ..ACMTABLE,                                               
//         DISP=(MOD,CATLG,KEEP),                                               
//         UNIT=SYSALLDA,SPACE=(TRK,(01,01),RLSE),                              
//         DCB=(RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PS)                           
//*-------------------------------------------------------------------*         
//*                                                                             
//*-This job must be tailored so that all element types which can ----*         
//*-be considered as 'input components' in Endevor are listed in  ----*         
//*-the API program data. Element information for each type is    ----*         
//*-captured into these outputs:                                                
//*-  &HLQ..ACM#LOAD.COMPONTS a list of input components          ----*         
//*-  &HLQ..ACM#LOAD.ELEMLIST is an temporary work dataset).   ----*            
//*-  &HLQ..ENDEVOR.NOTES(ACMQLIST) a list of element groups   ----*            
//* Addition tailoring must be done for component users.--------------*         
//*-------------------------------------------------------------------*         
//*---- List elements of input-component Types  1/2 ------------------*         
//*-------------------------------------------------------------------*         
//BILDACM3 EXEC PGM=IRXJCL,PARM='ENBPIU00  A '    '        ACM#LOD1             
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//* List element types that might be input components                           
//TABLE   DD   * /                                                              
* TYPE----                                                                      
  ASMMAC                                                                        
  COPYBOOK                                                                      
  COPY                                                                          
  MACRO                                                                         
  PROC                                                                          
//OPTIONS DD   *,SYMBOLS=JCLONLY                                                
  $nomessages = 'Y'                                                             
  ENVMNT = Left('&ENVMNT',8)                                                    
  STAGE="&STAGE"                                                                
//MODEL   DD   *                                                                
AACTL MSGFILE ELEMLIST                                                          
ALELM AA &ENVMNT *       *                 &TYPE                                
RUN                                                                             
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//TBLOUT   DD DSN=&&INTYPES,DISP=(NEW,PASS),                                    
//            UNIT=SYSDA,SPACE=(TRK,(1,1)),                                     
//            DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)                              
//*-------------------------------------------------------------------*         
//*-------------------------------------------------------------------*         
//*---- List elements of input-component Types  2/2 ------------------*         
//*-------------------------------------------------------------------*         
//BILDACM4 EXEC PGM=NDVRC1,PARM='ENTBJAPI',REGION=4096K    ACM#LOD1             
//   INCLUDE MEMBER=STEPLIB      <-Endevor STEPLIB,CONLIB etc                   
//MSGFILE  DD SYSOUT=*                                                          
//ELEMLIST DD DSN=&HLQ..ACM#LOAD.ELEMLIST,                                      
//            DISP=(MOD,CATLG,KEEP),                                            
//            UNIT=SYSDA,SPACE=(CYL,(20,20)),                                   
//            DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000)                           
//SYSINX   DD  *                                                                
***** ALELM = LIST ELEMENT STRUCTURE INFORMATION                                
*    V - COLUMN 6 = PATH SETTING                                                
*     V - COLUMN 7 = RETURN SETTING                                             
*      V - COLUMN 8 = SEARCH SETTING                                            
*       V - COLUMN 9 = UNUSED                                                   
*        VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                               
*                V - COLUMN 18 = STAGE ID                                       
*                 VVVVVVVV - COLUMN 19-26 SYSTEM NAME                           
*                         VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME                
*    COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                                    
*    COLUMN 45-52 = TYPE NAME               VVVVVVVV                            
*    COLUMN 53-60 = TO-ENV NAME                     VVVVVVVV                    
*    COLUMN 61    = TO-STAGE ID                             V                   
*    COLUMN 62-71 = THRU-ELEMENT NAME                        VVVVVVVVVV         
*---+----1----+----2----+----3----+----4----+----5----+----6----+----7--        
//SYSIN    DD  DSN=&&INTYPES,DISP=(OLD,DELETE)                                  
//         DD  *                                                                
AACTLY                                                                          
RUN                                                                             
QUIT                                                                            
//SYSOUT   DD  SYSOUT=*                                                         
//SYSPRINT DD  SYSOUT=*                                                         
//BSTERR   DD  SYSOUT=*                                                         
//BSTAPI   DD  SYSOUT=*                                                         
//SYMDUMP  DD DUMMY                                                             
//SYSUDUMP DD SYSOUT=*                                                          
//*                                                                             
//*  PRINT EXTRACTED ELEMENT                                                    
//SHOWME   EXEC PGM=IEBGENER                               ACM#LOD1             
//SYSPRINT DD DUMMY                                                             
//SYSIN    DD DUMMY                                                             
//SYSUT1   DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=SHR                              
//SYSUT2   DD SYSOUT=*                                                          
//*                                                                             
//*-------------------------------------------------------------------*         
//*---- Write list of input-component elements into COMPONTS ----*              
//*-------------------------------------------------------------------*         
//BILDACM6 EXEC PGM=IRXJCL,PARM='ENBPIU00  A '             ACM#LOD1             
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//OPTIONS  DD  *                                                                
  $nomessages = 'Y'                                                             
  MODEL = "MODELC"                                                              
  TBLOUT= "COMPONTS"                                                            
  COMPLINE = COPIES(" ",80)                                                     
  COMPLINE = OVERLAY(ELEMENT,COMPLINE,01);                                      
  COMPLINE = OVERLAY(SYSTEM,COMPLINE,12);                                       
  COMPLINE = OVERLAY(SUBSYS,COMPLINE,22);                                       
  COMPLINE = OVERLAY(TYPE,COMPLINE,32);                                         
  COMPLINE = OVERLAY(EDLT_DATE,COMPLINE,42);                                    
  COMPLINE = OVERLAY(GEN_DATE,COMPLINE,52);                                     
  COMPLINE = OVERLAY(GEN_TIME,COMPLINE,62);                                     
  COMPLINE = OVERLAY(ENV,COMPLINE,73);                                          
  COMPLINE = OVERLAY(STG_NUM,COMPLINE,83);                                      
//MODELC   DD  *                                                                
 &COMPLINE                                                                      
//POSITION DD  *                                                                
    ALELM_RS_EDLT_CCID            333 344                                       
    ALELM_RS_LACT_CCID            156 167                                       
    ELEMENT                        39  48                                       
    ENV                            15  22                                       
    STG_NUM                        66  66                                       
    SYSTEM                         23  30                                       
    SUBSYS                         31  38                                       
    TYPE                           49  56                                       
    EDLT_DATE                     301 308                                       
    GEN_DATE                      578 585                                       
    GEN_TIME                      586 593                                       
//SYSTSIN  DD  DUMMY                                                            
//TABLE    DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=(OLD,DELETE)                     
//NOTHING  DD SYSOUT=*                                                          
//SKIPPING DD DUMMY                                                             
//COMPONTS DD DSN=&HLQ..ACM#LOAD.COMPONTS,                                      
//             DISP=(MOD,CATLG,KEEP),                                           
//         UNIT=SYSALLDA,SPACE=(CYL,(01,01),RLSE),                              
//         DCB=(RECFM=FB,LRECL=120,BLKSIZE=0,DSORG=PS)                          
//*                                                                             
//SYSTSPRT DD  SYSOUT=*                                                         
//*-------------------------------------------------------------------          
//*    SORT COMPONENT LIST                                            *         
//*-------------------------------------------------------------------          
//BILDACM7 EXEC PGM=SORT,COND=(4,LT)                       ACM#LOD1             
//SYSPRT   DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT   DD SYSOUT=*                                                          
//SORTIN   DD DISP=SHR,DSN=&HLQ..ACM#LOAD.COMPONTS                              
//SORTOUT  DD DISP=SHR,DSN=&HLQ..ACM#LOAD.COMPONTS                              
//SYSIN    DD *                                                                 
 SORT FIELDS=(002,10,CH,A,32,9,CH,A)                                            
//*                                                                             
//*-------------------------------------------------------------------*         
//*  IDENTIFY component user elements   1/2                           *         
//*-------------------------------------------------------------------*         
//BILDACM9 EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'        ACM#LOD1             
//PARMLIST DD  *                                                                
  MODEL1  TBLOUT1  OPTIONS A                                                    
  MODEL2  TBLOUT2  OPTIONS A                                                    
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//* List element types that might use input components                          
//TABLE   DD   * /                                                              
* TYPE----                                                                      
  COBOL                                                                         
  COBPGM                                                                        
  ASM                                                                           
  ASMPGM                                                                        
  JCL                                                                           
//OPTIONS DD   *,SYMBOLS=JCLONLY                                                
  $nomessages = 'Y'                                                             
  ENVMNT = Left('&ENVMNT',8)                                                    
  STAGE="&STAGE"                                                                
//MODEL1  DD   *                                                                
AACTL MSGFILE ELEMLIST                                                          
ALELM AA &ENVMNT *       *                 &TYPE                                
RUN                                                                             
//MODEL2  DD   *                                                                
 UserType.&TYPE = 'Y'                                                           
//SYSTSIN  DD DUMMY                                                             
//SYSTSPRT DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//TBLOUT2  DD DSN=&HLQ..ACM#LOAD.USERTYPS,                                      
//             DISP=(MOD,CATLG,KEEP),                                           
//         UNIT=SYSALLDA,SPACE=(CYL,(01,01),RLSE),                              
//         DCB=(RECFM=FB,LRECL=080,BLKSIZE=0,DSORG=PS)                          
//*                                                                             
//TBLOUT1  DD  DSN=&&TYPES,DISP=(NEW,PASS),                                     
//             UNIT=SYSDA,SPACE=(TRK,(1,1)),                                    
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=8000)                             
//*-------------------------------------------------------------------*         
//*  IDENTIFY component user elements   2/2                           *         
//*-------------------------------------------------------------------*         
//BILDACMA EXEC PGM=NDVRC1,PARM='ENTBJAPI',REGION=4096K    ACM#LOD1             
//   INCLUDE MEMBER=STEPLIB      <-Endevor STEPLIB,CONLIB etc                   
//MSGFILE  DD SYSOUT=*                                                          
//ELEMLIST DD DSN=&HLQ..ACM#LOAD.ELEMLIST,                                      
//             DISP=(MOD,CATLG,KEEP),                                           
//             UNIT=SYSDA,SPACE=(CYL,(5,5)),                                    
//             DCB=(RECFM=FB,LRECL=2000,BLKSIZE=24000)                          
//SYSINX   DD  *                                                                
***** ALELM = LIST ELEMENT STRUCTURE INFORMATION                                
*    V - COLUMN 6 = PATH SETTING                                                
*     V - COLUMN 7 = RETURN SETTING                                             
*      V - COLUMN 8 = SEARCH SETTING                                            
*       V - COLUMN 9 = UNUSED                                                   
*        VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                               
*                V - COLUMN 18 = STAGE ID                                       
*                 VVVVVVVV - COLUMN 19-26 SYSTEM NAME                           
*                         VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME                
*    COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                                    
*    COLUMN 45-52 = TYPE NAME               VVVVVVVV                            
*    COLUMN 53-60 = TO-ENV NAME                     VVVVVVVV                    
*    COLUMN 61    = TO-STAGE ID                             V                   
*    COLUMN 62-71 = THRU-ELEMENT NAME                        VVVVVVVVVV         
//SYSIN    DD  DSN=&&TYPES,DISP=(OLD,DELETE)                                    
//         DD  *                                                                
AACTLY                                                                          
RUN                                                                             
QUIT                                                                            
//SYSOUT   DD  SYSOUT=*                                                         
//SYSPRINT DD  SYSOUT=*                                                         
//BSTERR   DD  SYSOUT=*                                                         
//BSTAPI   DD  SYSOUT=*                                                         
//SYMDUMP  DD DUMMY                                                             
//SYSUDUMP DD SYSOUT=*                                                          
//*                                                                             
//*  PRINT EXTRACTED ELEMENT                                                    
//SHOWA2   EXEC PGM=IEBGENER                               ACM#LOD1             
//SYSPRINT DD DUMMY                                                             
//SYSIN    DD DUMMY                                                             
//SYSUT1   DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=SHR                              
//SYSUT2   DD SYSOUT=*                                                          
//*                                                                             
//*-------------------------------------------------------------------          
//*    SORT element user list                                         *         
//*********************************************************************         
//BILDACMB EXEC PGM=SORT,COND=(4,LT)                       ACM#LOD1             
//SYSPRT   DD SYSOUT=*                                                          
//SYSPRINT DD SYSOUT=*                                                          
//SYSOUT   DD SYSOUT=*                                                          
//SORTIN   DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=SHR                              
//SORTOUT  DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=SHR                              
//SYSIN    DD *                                                                 
 SORT FIELDS=(039,10,CH,A)                                                      
//*                                                                             
//*-------------------------------------------------------------------*         
//*  Create Table of element Groups in &HLQ..ACMTABLE                           
//*-------------------------------------------------------------------*         
//BILDACMC EXEC PGM=IRXJCL,PARM='ENBPIU00  A '             ACM#LOD1             
//SYSEXEC  DD  DISP=SHR,DSN=&CSIQCLS0                                           
//TABLE    DD DSN=&HLQ..ACM#LOAD.ELEMLIST,DISP=SHR                              
//MODEL    DD  *                                                                
 &GROUP     &START     &STOP   &JobChar                                         
//POSITION DD  *                                                                
  ELEMENT      39 48                                                            
//SYSTSIN  DD  DUMMY                                                            
//NOTHING  DD  DUMMY                                                            
//OPTIONS  DD  *                                                                
  $nomessages = 'Y'                                                             
  lastrecord = $tablerec.0                                                      
  Break = 30                                                                    
  if $row# = 0 then $SkipRow='Y';                                               
  BreakTime = $row# // Break                                                    
  if BreakTime = 1 then START = ELEMENT                                         
  if $row# >= lastrecord then BreakTime = 0                                     
  Say '&row#='$row# '$row#//Break='BreakTime 'lastrecord='lastrecord            
  if BreakTime > 0 then $SkipRow='Y'                                            
  STOP = ELEMENT;                                                               
  GROUP = "GRP" || ($row# % Break)                                              
  if $row# >= lastrecord then, +                                                
     GROUP = "GRP" || ($row# + Break) % Break                                   
  JobChar = Substr(GROUP,Length(GROUP),1)                                       
//TBLOUT   DD  DISP=MOD,DSN=&HLQ..ACMTABLE                                      
//SYSTSPRT DD  SYSOUT=*                                                         
