# Package Shipping Model and Script examples 

There are a few challenges when working with Endevor's package shipping. 
One Package shipment can submit up to 4 jobs, depending on the transmission tool used. If you are shipping to and from multiple sites, there are some things you can do to make it easier to track job outputs to the site names and packages that spawned them.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

Items in this folder may help with these challenges, and to complement the material found in [Shipping and Post Ship Scripts demysfied](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie). Included are: 

 - Reminders for Setting up Package Shipments
 - Items to comment your package shipping jobs - a first step in keeping track of package shipping objects
 - Member inclusions
 - Miscellaneous tips and techniques

 ## Reminders for Setting up Package Shipments

 Objects from the Endevor CSIQSENU library are standard [IBM File Tailoring Skeletons](https://www.ibm.com/docs/en/zos/3.1.0?topic=reference-defining-file-tailoring-skeletons), whereas objects from Endevor's CSIQOPTN library use a syntax that is unique to package shipping. Here are some recommended steps for setting up Package Shipments: 

 - Check the RJCLROOT value on your Defaults table. Techdoc says...
 
    "The generation of the remote copy and delete job stream is controlled by the C1DEFLTS specification for RJCLROOT keyword. RJCLROOT specifies the member root for the package ship remote JCL model."

- If you modify any of the CSIQSENU or CSIQOPTN members, consider placing them into one or two override libraries, separate from the Endevor product libraries. Then, make sure your override libraries are concatenated in your C1BMXJOB, or whatever equivalent you are using. Where you see a reference to a CSIQOPTN or a CSIQSENU library, concatenate an override library above the one that is there. See also the **Tips and Techniques** section below for more.

- Comment the members you modify, so that when you are viewing package shipment jobs, you will be able to easily find the contributing objects that created them. 

## Commenting Package Shipment Jobs

Generous commenting of your package shipping objects helps you to connect jobs to their originations. Remote and confirmation jobs might be commented this way (after variable substitution), giving you backward pointers to the origin of each package shipment.
 
    //SHIPJOBR  JOB (123000),'FROM DEV1',CLASS=A,PRTY=6,               
    //  MSGCLASS=X,REGION=0M                                              
    //***=======Remote Shipping JCL for Site SOMWHER===================* *
    //* Package   := FINA#YEDN0607479                                      
    //* Destin    := SOMWHER             
    //* Submitter := LEWIS                                            
    //* From      := DEVBOX1    240506  091612                        
    //* HostLibs  := SHIP.HOST.D240506.T091612.SOMWHER
    //* RmotLibs  := SHIP.RMOT.D240506.T091612.SOMWHER 
    //* *==============================================================* *

Comment your Job steps to name the package shipment object that contributed the step to the JCL:


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

Where QBOXB, C1BMXRCN are package shipping members and/or elements in your Endevor Admin area.

Package Shipping variables are made available early in the shipment process. If you capture them at the appropriate time you can use them within the remaining shipping objects to better comment, and to enhance functionality. Objects in this folder serve as examples in capturing and leveraging variables such as those listed here.

- VDDHSPFX  - Host staging dataset name prefix                       
- VDDRSPFX  - Remote staging dataset name prefix                       
- VNBCPARM  - Endevor parameter string with 8-byte Date and time values
- VNBSQDSP  - The Package ship command containing package name, Destination and the Out/Back option
- VNB6DATE  - Six character shipping Date                            
- VNB6TIME  - Six character shipping Time                            
- VPHPKGID  - Package ID                                             

See the **)REXX** and **)ENDREXX** blocks within the **C1BMXIN** member as an example for capturing package shipment variables. 
The combination of the **@DBOX** and **C1BMXIN** members gives you the ability to capture shipping-time variables that you can use across your  shipping objects. See more in the topic on **Multiple Endevors**.


### Skeleton / Model / Capture and re-use of shipping variables

Members in this folder show how you can capture values for shipping variables and re-use them. 

__C1BMXIN.skl__  is a version of the C1BMXIN skeleton found in your CSIQSENU library. When C1BMXIN is referenced during the initiation of a package shipment, many of the variables related to the shipment are briefly available. Within the C1BMXIN member you will find a reference to the VNBSQDSP variable - SHIP statement itself whcih names the package, the destinaion the PKG/BACKOUT value. Other package shipping varibles are also briefly available, whcih you can use in the shipment skeleton and CSIQOPTN members to improve the commenting and to increase functionality.

This version captures values for some of the package shipping variables, and makes it possible for them to be available in your shipping JCL. Shipments for all transmission methods use the **C1BMXIN** member. The example uses Table Tool in a step named TAILOR to capture and expand variables for subsequent shipping jobs. 

Within the C1BMXIN example, you will find **)REXX** and **)ENDREXX** pairs that capture values for variables included on the **)REXX** statement. You can delete sections you do not need. For example, if do not need to capture the Transmission Method, then you can delete lines, starting with this line,

    )REXX DESTIN HOSTHLQ RMOTHLQ XMITMETH
to the line that contains this text

    )ENDREXX 

For variables captured, the example C1BMXIN uses Table Tool to replace values for those variables that you may have placed in your CSIQSENU and CSIQOPTN members.

The example tailors the content of C1BMXFTC, which Endevor builds for Netview FTP (or IBM FTP) commands. The inclusion or exclusion of the C1BMXFTC references in your version might depend on your transmission utility. You will need to tailor outputs for the transmission tool you are using.

__#RJICPY1.skl__ is a version of the #RJICPY1 showing commented steps.

The edit macro __JCLCOMMT__ can help insert comments for a member or element that contains JCL. While editing an element or member, enter **JCLCOMMT** on the Command line.  

Find JCLCOMMT.rex here - [ISPF-tools-for-Quick-Edit-and-Endevor](/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/JCLCOMMT.rex)

## Member Inclusions

Members in the CSIQSENU library(s) use the standard ISPF Skeleton method - )IM name - for including other skeleton members. 

Members of the CSIQOPTN library(s) and remote JCL PROCs and snippets may also include other members.

### For members of the CSIQOPTN library(s):

Within a member of a CSIQOPTN library, you can include other members, using this syntax.

    @INCLUDE=member_name      -   Required Inclusion of Specific Member
    @INCLUDE=(member-name)    -   Optional Inclusion of Specific Member

Inclusion can also be based on the presence of a member in a 3 tiered hierarchy of members. The hierarchy consists of a destination specific member, a transmission method specific member, and a non-specific member. The member names consist of a root and a one character suffix (alphabetic or national character).

    Destination Specific Members:          ddddddd.suffix     where "ddddddd" is a Destination 
    Transmission Method Specific:          #PSxxxx.suffix     where "xxxx" is a transmission method mnemonic
    Non-Specific Members:                  #PSNDVR.suffix

If a certain destination requires special processing, a destination specific member(s) can be created which will generate control statements for that destination only.

    @INCLUDE=suffix                             Required Inclusion of Hierarchical Member
    @INCLUDE=(suffix)                           Optional Inclusion of Hierarchical Member

### PROC and JCL inclusions

It might be useful to consider using a JES include, where an included member name includes the destination name, and the member itself resides in a library at the Destination site. The member may reside in a PROC library, or a library named by your JCLLIB ORDER statement. For Example:

    //*==================================================================*
    // JCLLIB  ORDER=(MY.REMOTE.JCL)                              
    //*==================================================================*

    //  INCLUDE MEMBER=#&DESTID       JES include from MY.REMOTE.JCL      


## Shipping "Delete Behind" actions

If you ship from Endevor locations in the middle of your map, and you want package shipments to replicate remote "delete behind" actions - to match what your processors are doing locally - consider members DELBHIND and DELETMBR. 

You can include or copy DELBHIND into your Move processor to create "delete behind transactions", based on your elements component list. Tailor the last step to identify which members and datasets from the component list you want to delete. Tailoring might also be necessary to adjust remote dataset names that differ from those listed in the component list. The "transactions" can be shipped to destinations where cleanup needs to occur.

If you place DELETMBR at each destination where needed, it can delete the members from the datasets identified in each "delete behind transaction". If the targeted member is already missing from the dataset, no action is done.


## Tips and Techniques

Miscellaneous tips and techniques for package shipping are given here.


### Preparing an Override library for your Shipping software members

By default, Endevor builds package shipping JCL from members of the CSIQOPTN and CSIQSENU libraries. You do not need to place your modified objects into these libraries. Instead, you can create one or more "Override" libraries, and place your modified members into them. Ideally, these libraries are managed in your admin area of Endevor. Within **C1BMXJOB.skl**, name your Override libraries. See the topic on the Override library in [Package Shipping Demystified](https://community.broadcom.com/blogs/joseph-walther/2023/11/27/package-shipping-and-post-ship-scripts-de-mystifie
). Member **C1BMXJOB.skl** gives an example by naming three "override" libraries. Any one of which may contain your modified objects.

    DBOX.OVER1.ENDEVOR.ISPS
    DBOX.OVER2.ENDEVOR.ISPS
    DBOX.PROD.ISPS


### Using your Transmission tool for the Confirmation job

The last package shipping job is the "Notification" job. It returns back to the host the overall status of a single package shipment. See the **C1BMXRCN** reference in the  [Shipment Tracking and Confirmation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/package-administration/package-ship-facility/build-track-and-confirm-package-shipments/shipment-tracking-and-confirmation.html)  documentation. Package Shipping assumes an IEBGENER can write the Notification JCL to the internal reader to submit the job on the Host system. In many cases a "ROUTE XEQ" statement on the jobcard is all that is necessary. However at some sites, the IEBGENER must be replaced with a file transmission step to submit the Notification job. You can submit the Notification job onto the host system, using this IBM FTP example:


Here is an example of using IBM's FTP within the C1BMXRCN skeleton member.

    //CONFCOPY EXEC PGM=IEBGENER           EXECUTED AT THE REMOTE SITE      
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  7 Line(s) not Displayed 
    //*YSUT2   DD SYSOUT=(A,INTRDR)                                         
    //SYSUT2   DD  DSN=&RMOTHLQ..D&DATE6..T&TIME6..NOTIFY,  
    //             DISP=(,CATLG),SPACE=(TRK,(1,0)),                         
    //             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120,DSORG=PS),           
    //             UNIT=SYSALLDA                                            
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  3 Line(s) not Displayed 
    //CONFABND EXEC PGM=IEBGENER,COND=ONLY EXECUTED AT THE REMOTE SITE      
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  8 Line(s) not Displayed 
    //*YSUT2   DD SYSOUT=(A,INTRDR)                                         
    //SYSUT2   DD  DSN=&RMOTHLQ..D&DATE6..T&TIME6..NOTIFY,  
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
    PUT '&RMOTHLQ..D&DATE6..T&TIME6..NOTIFY'           
    QUIT                                                                  
    //***--------------------------------------------* C1BMXRCN (CONT.)  *

Notice that the &RMOTHLQ, &DATE6 and &TIME6 variables are among those captured or created by the TAILOR step within C1BMXIN.

### IEBPTPCH 

IEBPTPCH is an IBM utility program that is used to print or punch records from a sequential or partitioned dataset. Our examples show using IEBPTPCH to write all members of a "Staging" dataset into a single output file. It is useful for shipped objects such as DB2 Binds or CICS newcopies. Then, the output is further processed in subsequent steps in the shipping job. 
See the __#RJNDVRA__ member example.
 
### Multiple Endevors

If you are running multiple Endevors, it would be unreasonable to expect that dataset names and jobcard values (for example) be the same on all of them. A more realistic expectation is for each Endevor (or Lpar) to use its own dataset names, jobcard values and other image-specific variations.

If **DBOX** is the name of an Lpar, then **@DBOX** is the name of a "callable Rexx" service, providing image-specific information for just that Lpar. Other Lpars can have their own "callable Rexx" services too. Then, the necessary differences from one Endevor to the next can be managed in "callable Rexx" service routines, and not managed in the common code. The example **C1BMXIN.skl**, paired with the **@DBOX** member, shows how this is done.

A "callable Rexx" service can be engaged anywhere REXX is run. One of the places is  within an ISPF skeleton. Member **C1BMXIN.skl** references a CSIQCLS0 library whose name might differ from one Lpar to the next. When running on the DBOX Lpar, it calls **@DBOX** for the value of **MyCLS0Library** and assigns the returned dataset name to a new variable named **CSIQCLS0**. Then, the **&CSIQCLS0** variable will be replaced with the datset name whenever it is found.

These lines of code come from  **C1BMXIN.skl**. Notice that the trace is turned on.


    )CM ---------- This section shows accessing Site-Specific variables    
    )CM ----------      Longer variable names must be assigned to          
    )CM ----------      valid 8-byte ISPF variable names                   
    )REXX  CSIQCLS0 ORDERDSN                                               
    TRACE ?R                                                             
    WHERE = 'C1BMXIN Get local variables '                               
    WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;                      
                                                                        
    interpret 'Call' WhereIam "'MyCLS0Library'"                          
    CSIQCLS0  = Result                                                   
    interpret 'Call' WhereIam "'AltIDOrderfile'"                         
    ORDERDSN  = Result                                                   
                                                                        
    )ENDREXX                                                                       

If you submit a package shipment leaving the trace turned on, the trace output will look something like this on your screen:

    13 *-*  WHERE = 'C1BMXIN Get local variables '                            
       >>>    "C1BMXIN Get local variables "                                  
    14 *-*  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8))                     
       >>>    "@DBOX"                                                         
    16 *-*  interpret 'Call' WhereIam "'MyCLS0Library'"                       
       >>>    "Call @DBOX 'MyCLS0Library'"                                    
       *-*   Call @DBOX 'MyCLS0Library'                                       
       >>>     "MyCLS0Library"                                                
       >>>     "SYSDBOX.R190.CSIQCLS0"                                    
    17 *-*  CSIQCLS0  = Result                                                
       >>>    "SYSDBOX.R190.CSIQCLS0"                                     
    18 *-*  interpret 'Call' WhereIam "'AltIDOrderfile'"                      
       >>>    "Call @DBOX 'AltIDOrderfile'"                                   
       *-*   Call @DBOX 'AltIDOrderfile'                                      
       >>>     "AltIDOrderfile"                                               
       >>>     "SYSDBOX.NDVR.JCL"       
    19 *-*  ORDERDSN  = Result               
       >>>    "SYSDBOX.NDVR.JCL"        


Lines 13 and 14 show the REXX code identifying where it is running. The **MVSVAR(SYSNAME)** tells you "the name of the system your REXX exec is running on". The remainder of the trace output shows various calls to @DBOX to fetch site values.

Engaging a "callable REXX" service may also be performed from other REXX programs, such as an Endevor REXX exit or from REXX zowe executions.

One final note about the CSIQCLS0 variable. The variable is created brand new in the REXX portion of the C1BMXIN skeleton, and is used as an ISPF variable later on the TAILOR step. You can make variables like CSIQCLS0 be both an ISPF variable and a Table Tool variable, if it is included in the OPTIONS of the TAILOR step.

### More from the Package Automation Folder

Find more examples and information on package Shipping in the [Package Automation folder](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/Package-Automation)    
