# Package Shipping examples 

Package shipping can submit a lot of jobs - up to 4 jobs per shipment. If you are shipping from multiple host sites to remote sites, it becomes easy to lose track of which sending host and package name relates to the job. Items in this folder help you to connect jobs to their originations, commenting your remote jobs with backward pointers as demonstrated in this example.

    //SHIPJOBR  JOB (123000),'FROM DEV1',CLASS=A,PRTY=6,               
    //  MSGCLASS=X,REGION=0M                                              
    //***=======Remote Shipping JCL for Site SOMWHER===================* *
    //* Package   := FINA#YEDN0607479                                      
    //* Destin    := SOMWHER                                               
    //* From      := DEVBOX1    240506  091612                        
    //* HostLibs  := PUBLIC.HOST.D240506.T091612.SOMWHER
    //* RmotLibs  := PUBLIC.RMOT.D240506.T091612.SOMWHER 
    //* *==============================================================* *

Moreover, the variables used for the commenting can be also be leveraged for other things you might need to do in the remote shipping job. Here are members in this folder:

__C1BMXIN.skl__  is a modified version of the C1BMXIN skeleton found in your CSIQSENU library. This version captures values for some of the package shipping variables, and makes it possible for these values be available in your remote JCL. to include references such as the Package name, Destination and others.

__#RJICPY1.skl__ is a modified version of the #RJICPY1 "model" found in your CSIQOPTN library. This version shows how to comment the remote shipment job as shown above.

__C1BMXJOB.skl__  is a modified version of the C1BMXJOB skeleton found in your CSIQSENU library. This version is an example for inserting one or more "override" libraries into your package shipping procedure.  See the topic on the Override library in [Package Shipping Demystified](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie
). The example C1BMXJOB.skl member in this folder shows three "override" libraries, any one of which might contain modified versions of C1BMXIN and #RJICPY1.

    BST.QA.FS.ADMIN1.ENDEVOR.ISPS
    BST.QA.FS.ADMIN2.ENDEVOR.ISPS
    BST.QA.FS.$SKELS

Package shipping uses an IEBGENER to submit the "notification" job back to the Host system. The requires that you have a "ROUTE XEQ" card in the JCL and a connection between systems that can successfully route jobs. Sometimes it is necessary to replace the IEBGENER with a file transmission to submit the Notification job. You can use the RMOTLIB variable to create a new dataset (From the IEBGENER) and transmit it to the HOST system. 

Here is an example of using IBM's FTP within the C1BMXRCN skeleton member.

    //CONFCOPY EXEC PGM=IEBGENER           EXECUTED AT THE REMOTE SITE      
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  7 Line(s) not Displayed 
    //*YSUT2   DD SYSOUT=(A,INTRDR)                                         
    //SYSUT2   DD  DSN=&VDDRSPFX..D&VNB6DATE..T&VNB6TIME..&DESTIN..NOTIFY,  
    //             DISP=(,CATLG),SPACE=(TRK,(1,0)),                         
    //             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),           
    //             UNIT=SYSALLDA                                            
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  3 Line(s) not Displayed 
    //CONFABND EXEC PGM=IEBGENER,COND=ONLY EXECUTED AT THE REMOTE SITE      
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  8 Line(s) not Displayed 
    //*YSUT2   DD SYSOUT=(A,INTRDR)                                         
    //SYSUT2   DD  DSN=&VDDRSPFX..D&VNB6DATE..T&VNB6TIME..&DESTIN..NOTIFY,  
    //             DISP=(,CATLG),SPACE=(TRK,(1,0)),                         
    //             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),           
    //             UNIT=SYSALLDA                                            
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  2 Line(s) not Displayed 
    //* *--------------------------------------------* C1BMXRCN (CONT.)  *  
    //FTPSUBMT EXEC PGM=FTP,REGION=2048K,TIME=800                 C1BMXRCN
    //NETRC    DD DISP=SHR,DSN=&&SYSUID..ENDEVOR.NETRC(SHIPPING)          
    //SYSTSPRT DD SYSOUT=*                                                
    //SYSPRINT DD SYSOUT=*                                                
    //SYSUDUMP DD SYSOUT=Q                                                
    //OUTPUT   DD SYSOUT=*                                        C1BMXRCN
    //SYSIN    DD *      Transmit (FTP) the Notification job to Host      
    Devbox1.ndv.mycompany.net                                             
    MODE B                                                                
    EBCDIC                                                                
    SITE FILETYPE=JES                                                     
    PUT '&VDDRSPFX..D&VNB6DATE..T&VNB6TIME..&DESTIN..NOTIFY'              
    QUIT                                                                  
    //***--------------------------------------------* C1BMXRCN (CONT.)  *








