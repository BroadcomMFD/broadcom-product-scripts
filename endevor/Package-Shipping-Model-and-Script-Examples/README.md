# Package Shipping Model and Script examples 

One Package shipmet can submit up to 4 jobs, depending on the transmission tool used. If you are shipping from multiple host sites to remote sites, it becomes challenging to track which sending host and package relates to the local and remote job outputs. Each job consists of members from Endevor's CSIQOPTN and CSIQSENU libraries. Determining which member you need to change can be quite difficult.   

Items in this folder are intended to help with these challenges, and to complement the [Shipping and Post Ship Scripts demysfied](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie) content.

Included in this folder are:

 - Items to comment your package shipping jobs
 - Miscellaneous examples of tips and techniques 

## Commenting Package Shipment Jobs

Generous commenting of your package shipping objects helps you to connect jobs to their originations.
For example, a remote shipment job might be commented this way, giving you backward pointers to the origin of the package shipment. 
 
    //SHIPJOBR  JOB (123000),'FROM DEV1',CLASS=A,PRTY=6,               
    //  MSGCLASS=X,REGION=0M                                              
    //***=======Remote Shipping JCL for Site SOMWHER===================* *
    //* Package   := FINA#YEDN0607479                                      
    //* Destin    := SOMWHER             
    //* Submitter := LEWIS                                            
    //* From      := DEVBOX1    240506  091612                        
    //* HostLibs  := PUBLIC.HOST.D240506.T091612.SOMWHER
    //* RmotLibs  := PUBLIC.RMOT.D240506.T091612.SOMWHER 
    //* *==============================================================* *

Additionally, the steps in your shipping jobs may contain backward pointers, such as:


    Command ===>                                                  Scroll ===> CSR 
    ****** ***************************** Top of Data *****************************
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 35 Line(s) not Displayed
    ==CHG> //SCL1     EXEC PGM=IEBPTPCH   * THEN PUNCH OUT MEMBERS    QBOXB       
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 12 Line(s) not Displayed
    ==CHG> //COPIES   EXEC PGM=NDVRC1,DYNAMNBR=1500,PARM='C1BM3000'   QBOXB       
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 20 Line(s) not Displayed
    ==CHG> //ALTERS1  EXEC PGM=IEBPTPCH   * THEN PUNCH OUT MEMBERS    QBOXB       
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 11 Line(s) not Displayed
    ==CHG> //SHOWME   EXEC PGM=IEBGENER,REGION=1024K                  QBOXB       
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 40 Line(s) not Displayed
    000121 //CONFGT12 EXEC PGM=IEBGENER                               C1BMXRCN    
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 11 Line(s) not Displayed
    000133 //CONFCOPY EXEC PGM=NDVRC1,                                C1BMXRCN    
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 24 Line(s) not Displayed
    000158 //CONFGT04 EXEC PGM=IEBGENER                               C1BMXRCN    
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 11 Line(s) not Displayed
    000170 //CONFCOPY EXEC PGM=NDVRC1,                                C1BMXRCN    
    - - -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 24 Line(s) not Displayed
    000195 //CONFGT00 EXEC PGM=IEBGENER                               C1BMXRCN    

Where QBOXB, C1BMXRCM are package shipping members or elements in your Endevor Admin area.

Package Shipping variables quickly appear and then disappear, making it difficult to apply them. Examples in this folder show a timely capture of shipping variables, allowing you to embellish them with your own, and rendering them to be avaiable across all the related package shipping jobs. Member **C1BMXIN** and others in this folder serve as examples and alternatives.

These are some of the variables, briefly made available by package shipping, and captured by the examples and alternatives in this folder:

- VDDHSPFX  - Host staging dataset name prefix                       
- VDDRSPFX  - Rmot staging dataset name prefix                       
- VNBCPARM  - Endevor parameter string with Date and time values     
- VNBSQDSP  - The Package ship command containing package name, Destinati#on and the Out/Back option
- VNB6DATE  - Six character shipping Date                            
- VNB6TIME  - Six character shipping Time                            
- VPHPKGID  - Package ID                                             



### Skeleton / Model / Script example members for commenting

Members in this folder that help with commenting include:

__C1BMXIN.skl__  is a version of the C1BMXIN skeleton found in your CSIQSENU library. This version captures values for some of the package shipping variables, and makes it possible for them to be available in your shipping JCL. Package shipments for all transmission methods use the C1BMXIN member. The example shows capturing and expanding variables using Table Tool for subsequent shipping jobs.

__#RJICPY1.skl__ is a modified version of the #RJICPY1 "model" found in your CSIQOPTN library. This version shows how to comment the remote shipment job as shown above. 

For commenting the steps within a shipment object, the edit maccro __JCLCOMMNT__ can help. 

## Tips and Techniques

Miscellaneous tips and techniques for package shipping are given here.


### Preparing a library for your Shipping software members

By default, Endevor builds package shipping JCL from members of the Endevor CSIQOPTN and CSIQSENU libraries. You do not need to place your modified objects into these libraries. Instead, you can create one or more "override" libraries, and place your modified members into them. **C1BMXJOB.skl** is where that is done, and an example is provided. See the topic on the Override library in [Package Shipping Demystified](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie
). The example **C1BMXJOB.skl** member in this folder shows three "override" libraries, any one of which might contain modified versions of package shipping objects. 

    BST.QA.FS.ADMIN1.ENDEVOR.ISPS
    BST.QA.FS.ADMIN2.ENDEVOR.ISPS
    BST.QA.FS.$SKELS

It is not necessary to maintain the separation of CSIQOPTN and CSIQSEUN members. You can place override members into one library, regardless of their original locations. It is strongly recommended, though that you comment them generously with their names in the comments, so that you have the backward pointers in your shipping JCL.

 
### Using your Transmission tool for the Confirmation job

Package Shipping assumes that a remote submission of JCL will cause the "Notification" job to run on the Host system. An IEBGENER is used, requiring a "ROUTE XEQ" card in the JCL and a connection between systems. Sometimes it is necessary to replace the IEBGENER with a file transmission to submit the Notification job. You can capture and use variables to create a new dataset (From the IEBGENER) and transmit it to the capture HOST system. 


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



### IEBPTPCH 

IEBPTPCH is an IBM utility program that is used to print or punch records from a sequential or partitioned dataset. The utility can perform various tasks, including copying members from a partitioned dataset (PDS) into a sequential dataset (PS). If you have shipped members of a datset that contain commands, such as DB2 Binds or CICS newcopies, then IEBPTPCH is useful for writing all the shipped members into a sequential file for subsequent processing.

See the __#RJNDVRA__ member example.
 
### Multiple Endevors


If you are running multiple Endevors, it would be unreasonable to assume they use the same dateaset names and jobcard values. Rather, it might be preferable to allow them to execute the same package shipping software, while allowing for site-specific differences. Dataset names,  jobcard variations, and anything that must be different from one Endevor to the next can be supported, using a "callable Rexx" service described here. Where there might be something different from one Endevor to the next, you can create and place variable names into the package shipping objects, and expect variable substitutions to occur differently at each site.

On the mainframe, REXX can run in many places - including within an ISPF skeleton. Moreover, a REXX module can serve as a simple database of information. You can leverage this REXX versatility by adopting the methods of the **@DBOX** member in this folder. It supports variables whose values depend on the site. Name your copies of  **@DBOX** after the Lpar (or other) names, so that each one can operate with its own unique values based on common variable names. You can add your own variables as needed. A section like this one can be used in a skeleton member, such as the C1BMXIN member to support site-specific variables designated for your multiple Lpars or Endevor images.


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

Engaging the "callable REXX" service can be made from any running REXX. The example above shows calls from an ISPF panel. The process that automates package shipments can use the "calleble REXX" service from an Endevor REXX exit, or from REXX executions from zowe.









