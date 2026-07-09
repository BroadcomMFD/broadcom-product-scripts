//IBMUSERI JOB (0000),                                                          
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,              
//      NOTIFY=&SYSUID                                                          
//**=================================================================**         
//LISTDSNS EXEC PGM=IDCAMS                                                      
//SYSIN    DD  *                                                                
 LISTCAT LEVEL('YOURSITE.NDVR.TEAM') NAME                                       
//STEPLIB  DD DISP=SHR,DSN=SYS1.LINKLIB                                         
//AMSDUMP  DD SYSOUT=*                                                          
//SYSPRINT  DD DSN=&&LISTCAT,DISP=(,PASS),                                      
//     SPACE=(CYL,(1,1)),UNIT=SYSDA,                                            
//     LRECL=120,RECFM=FB,BLKSIZE=0                                             
//**=================================================================**         
//LISTDSI EXEC PGM=IKJEFT1B,PARM='ENBPIU00 A '                                  
//POSITION  DD *                                                                
  NonVSAM  2 8                                                                  
  Dataset 18 61                                                                 
//OPTIONS   DD *                                                                
  If $row# = 1 then x =BuildFromMODEL(HEADING)                                  
  If NonVSAM /= 'NONVSAM' then $SkipRow = 'Y'                                   
  x = LISTDSI("'"Dataset"'" DIRECTORY RECALL SMSINFO)                           
  DSN       = Left(Dataset,44)                                                  
  ThisDSORG = Right(SYSDSORG,3)                                                 
  ThisRECFM = Right(SYSRECFM,3)                                                 
  ThisLRECL = Right(SYSLRECL,5)                                                 
  ThisBLKSZ = Right(SYSBLKSIZE,5)                                               
  ThisMembs = Right(SYSMEMBERS,6)                                               
//HEADING   DD *                                                                
Dataset------------------------------------ DSorg Fmt Recz Blksz  Mmbrs         
//MODEL     DD *                                                                
&DSN &ThisDSORG &ThisRECFM &ThisLRECL &ThisBLKSZ &ThisMembs                     
//TABLE     DD DSN=&&LISTCAT,DISP=(OLD,DELETE)                                  
//SYSEXEC  DD DISP=SHR,DSN=YOURHLQ.NDVR.R1801.CSIQCLS0                          
//SYSTSIN   DD DUMMY                                                            
//SYSTSPRT  DD SYSOUT=*                                                         
//TBLOUT    DD SYSOUT=*                                                         
                                                                                
