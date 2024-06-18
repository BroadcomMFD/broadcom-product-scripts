# Package Shipping Model and Script examples 

Package shipping can submit a lot of jobs - up to 4 jobs per shipment. If you are shipping from multiple host sites to remote sites, it becomes easy to lose track of which sending host and package name relates to the job.

Items in this folder are intended to complement the contents of [Shipping and Post Ship Scripts demysfied](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie) .
Included in this folder are:

 - Items to comment your package shipping jobs
 - Miscenaleous examples of tips and techniques for package shipping


## Commenting Package Shipment Jobs

 help you to connect jobs to their originations, commenting your remote jobs with backward pointers as demonstrated in this example.

    //SHIPJOBR  JOB (123000),'FROM DEV1',CLASS=A,PRTY=6,               
    //  MSGCLASS=X,REGION=0M                                              
    //***=======Remote Shipping JCL for Site SOMWHER===================* *
    //* Package   := FINA#YEDN0607479                                      
    //* Destin    := SOMWHER                                               
    //* From      := DEVBOX1    240506  091612                        
    //* HostLibs  := PUBLIC.HOST.D240506.T091612.SOMWHER
    //* RmotLibs  := PUBLIC.RMOT.D240506.T091612.SOMWHER 
    //* *==============================================================* *

Moreover, the variables used for the commenting can be also be leveraged for other things you might need to do in the remote shipping job.
In the **C1BMXIN** member values for package shipping variables can be captured and expanded within the reamining package shpping job.

There is an unlimited number of ways to leverage these variables, so for the most part this folder offers examples and alternatives. 

### Package Shipping Variables

VDDHSPFX  - Host staging dataset name prefix                       
VDDRSPFX  - Rmot staging dataset name prefix                       
VNBCPARM  - Endevor parameter string with Date and time values     
VNBSQDSP  - The Package ship command containing package name, Destinati#on and the Out/Back option
VNB6DATE  - Six character shipping Date                            
VNB6TIME  - Six character shipping Time                            
VPHPKGID  - Package ID                                             



### Skeleton / Model / Script example members

Here are members in this folder:

__C1BMXIN.skl__  is a modified version of the C1BMXIN skeleton found in your CSIQSENU library. This version captures values for some of the package shipping variables, and makes it possible for these values be available in your remote JCL. to include references such as the Package name, Destination and others. 

Package shipments for all transmission methods use the C1BMXIN member. This example shows capturing variables, usng Table Tool to expand those variables that mignt be found in subsequent jobs.

__#RJICPY1.skl__ is a modified version of the #RJICPY1 "model" found in your CSIQOPTN library. This version shows how to comment the remote shipment job as shown above.

__C1BMXJOB.skl__  is a modified version of the C1BMXJOB skeleton found in your CSIQSENU library. This version is an example for inserting one or more "override" libraries into your package shipping procedure.  See the topic on the Override library in [Package Shipping Demystified](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie
). The example C1BMXJOB.skl member in this folder shows three "override" libraries, any one of which might contain modified versions of C1BMXIN and #RJICPY1.

    BST.QA.FS.ADMIN1.ENDEVOR.ISPS
    BST.QA.FS.ADMIN2.ENDEVOR.ISPS
    BST.QA.FS.$SKELS


## Tips and Techniques

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





If you are running multiple Endevors at your site, you need a way to allow all of them to execute the same package shipping code, and at the same time support site-specific differences for them. Dataset names and jobcard variations must be different from one Endevor to the next. 

You can leverage the REXX method depicted in the **@DBOX** example in this folder. Name your member(S) after the Lpar name (or other) name, so that each one can operate with its own unique values. A section like this one can be used in a skeleton member, such as the C1BMXIN member to support site-specific variables designated for your multiple Lpars or Endevor images.



    )CM ---------- This section shows accessing Site-Specific variables  
    )CM ----------      Longer variable names must be assigned to        
    )CM ----------      valid 8-byte ISPF variable names                 
    )REXX  ORDERDSN JOBCLASS ACCTCODE MSGCLASS                           
    TRACE ?R                                                           
    WHERE = 'C1BMXIN Get local variables '                             
    WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;                    
                                                                        
    interpret 'Call' WhereIam "'AltIDAcctCode'"                        
    ACCTCODE  = Result                                                 
    interpret 'Call' WhereIam "'AltIDJobClass'"                        
    JOBCLASS  = Result                                                 
    interpret 'Call' WhereIam "'AltIDMsgClass'"                        
    MSGCLASS  = Result                                                 
    interpret 'Call' WhereIam "'AltIDOrderfile'"                       
    ORDERDSN  = Result                                                 
                                                                        
    )ENDREXX                                                                                                                

The example shows the Trace turn on. If you submit a package shipment before turning the Trace option off, will see trace output such as this example: 



    13 *-*  WHERE = 'C1BMXIN Get local variables '                            
    >>>    "C1BMXIN Get local variables "                                  
    14 *-*  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8))                     
    >>>    "@DBOX"                                                         
    16 *-*  interpret 'Call' WhereIam "'AltIDAcctCode'"                       
    >>>    "Call @DBOX 'AltIDAcctCode'"                                    
    17 *-*  ACCTCODE  = Result                                                
    >>>    "0012300"                                                          
    18 *-*  interpret 'Call' WhereIam "'AltIDJobClass'"                       
    >>>    "Call @DBOX 'AltIDJobClass'"                                    
    19 *-*  JOBCLASS  = Result                                    
    >>>    "A"                                                 
    20 *-*  interpret 'Call' WhereIam "'AltIDMsgClass'"           
    >>>    "Call @DBOX 'AltIDMsgClass'"                        
    21 *-*  MSGCLASS  = Result                                    
    >>>    "Z"                                                 
    22 *-*  interpret 'Call' WhereIam "'AltIDOrderfile'"          
    >>>    "Call @DBOX 'AltIDOrderfile'"                       
    23 *-*  ORDERDSN  = Result       
    >>>   "SYSDBOX.NDVR.JCL"         

Lines 13 and 14 show the REXX code identifying where it is running. The REXX "MVSVAR(SYSNAME) tells you "the name of the system your REXX exec is running on". Our "bundles" process assumes it also names a REXX module (like **DBOX** in the folode) that contains site-specific information.

The remainder of the trace output shows various calls to @DBOX to fetch site values.
















