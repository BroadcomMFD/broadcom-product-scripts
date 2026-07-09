//CASTPKGE JOB (1),                                                             
//   'CAST PACKAGE',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID                           
//*==================================================================*          
// JCLLIB  ORDER=(YOURSITE.NDVR.TEAM.JCL)                                       
//*==================================================================*          
//*===== If you want all package CAST actions to be performed        *          
//*===== in batch, then set the Force_CAST_in_Batch option in        *          
//*===== C1UEXTR7, and this JCL will submit a batch CAST.            *          
//*==================================================================*          
//ENBP1000 EXEC PGM=NDVRC1,PARM=ENBP1000,                  CASTPKGE             
//         DYNAMNBR=1500,REGION=4096K                                           
//   INCLUDE MEMBER=STEPLIB                                                     
//C1MSGS1  DD SYSOUT=*                                                          
//C1MSGS2  DD SYSOUT=*                                                          
//SYSUDUMP DD SYSOUT=*                                                          
//SYMDUMP  DD DUMMY                                                             
//JCLOUT   DD DUMMY                                                             
//C1UEXTR7 DD DUMMY     <- Trace REXX exit                                      
//*C1UEXTR7 DD DUMMY     <- Trace REXX exit                                     
//ENPSCLIN DD *                                                                 
