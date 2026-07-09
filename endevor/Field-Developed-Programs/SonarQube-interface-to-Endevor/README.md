#  SonarQube Interface to Endevor

This folder provides example assets demonstrating the integration of SonarQube and Endevor.

The integration enables Endevor to automatically trigger a SonarQube analysis when an Endevor package is CAST. To avoid tying up the user's session, any ISPF foreground CAST action is resubmitted to run in batch.

Optionally, based on user configuration, the CAST job can be set to wait for the SonarQube results. If this option is chosen, the final package status csn be updated to reflect the outcome of the analysis. Additionally, whether or not there is wait for the results, they can be placed into Endevor as elements, where the element name is given to match the package name.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).


## What Endevor Packages are to be processed with SonarQube?

By examining the element Types for elements within a package, it can be determined whether the package should be submitted for a SonarQube Analysis.  If a package only contains PARM elements, for example, there is no need to run a SonarQube Analysis. The configuration lets you identify the types to be scanned at your site.

### Optional use of the Package Builder

Package creation is an ideal time to assess if package content requires a SonarQube scan. By utilizing the [Package Builder](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor) (refer to **PACKAGE PACKAGEP** and [Package.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/Package.rex)), you can automate the selection of packages for SonarQube scanning.

During construction of a package, the package builder looks at the locations and types for each element selected. It can then detect whether selected elements are those that should be scanned, and automatically update the package Notes, for example:

        1. RUN SONARQUBE ANALYSIS                           
        2.                                                  
        3.                                                  
        4.                                                  
        5.                                                  
        6.                                                  
        7.                                                  
        8. ELM CNT: 2                                      

 Then, when the package is CAST, it also runs a SonarQube Analysis.                           

### CAST time Determination                              

Alternativley, you can use the @SITE.rex member to determine at Cast time, whether package content should be scanned. You can provide Endevor Type masks for the elements you wish to analyze. Here is an example:

    /* Provide Endevor Type masks for element to be analyzed   */    
    SonarQube_Element_Types = 'COB* CBL* CPP* '                      

(The Package Builder also accesses the @SITE.rex member)

Also identify the Generate processor steps where ACM input component relationships are collected. If you intend to scan COBOL, for instance, you should specify the processor steps that reference COPYBOOKs. Consider this example:

    /* Provide Endevor processor steps which show ACM inputs   */    
    GenerateProcessorStepnames = 'COMPILE COMP CMP COB'  


## SonarQube Transmission Methods

Elements selected for SonarQube scanning, must be transmitted to the server where SonarQube runs. Within the @SITE.rex member indicate what transmission method to use. The name of the transmission method must be assigned to the variable **SonarTransmitMethod**, which also names other members in the configuration.  
 

- &SonarTransmitMethod.#INC - for sending members to the SonarQube server
- &SonarTransmitMethod.#JOB - JCL for using the Transmission tool to send items to the SonarQube folders
- &SonarTransmitMethod.#RUN - JCL for using the Tansmission tool to initiating the execution of the SonarQube analysis
- &SonarTransmitMethod.#RCV - JCL for receiving the RESULTS of the SonarQube analysis

The examples in this folder show the SonarTransmitMethod assigned to 'XCOM'. It is expected that each transmit method have its own syntax for sending and receiving files, and for running remote tasks. 


## XCOM for Transmission and Submission

XCOM is an excellent choice for the file transmissions, and remote submission of the SonarQube process. 
See the [XCOM folder on this GitHub](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/XCOM). 

Within the @SITE.rex item, designate that XCOM is your choice, by setting the SonarTransmitMethod value:

    SonarTransmitMethod = 'XCOM'     

Find the XCOM#INC item in the current folder.

Also locate these items from the XCOM folder and place them into the library you designate as your 
**MySEN2Library** library. See the **@SITE.rex** section below.

- [XCOM#JOB](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23JOB.skl)
- [XCOM#RCV](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23RCV.skl)
- [XCOM#RUN](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23RUN.skl)




## SSH  for Transmission and Submission

Within the @SITE.rex item, designate that SSH is your choice, by setting the SonarTransmitMethod value:

    SonarTransmitMethod = 'SSH'     

Also locate these items from the SSH folder and place them into the library you designate as your **MySEN2Library** library. See the **@SITE.rex** section below.

- **SSH#INC.skl**                                                                
- **SSH#JOB.skl**                                                                    
- **SSH#RCV.skl**                                                                   
- **SSH#RUN.skl**  


## SonarQube Options

As you implement the items in this folder, you can establish default values for these options in the @SITE.rex program:

- **Cast_Location_for_Sonarqube** only elements found in an Endevor Environment and stageid location should be submitted for a SonarQube Analysis. Enter a value containing an Environment name, a space, and a StageID.

- **SonarQube_Element_Types** designate Endevor type masks for those elements elligible for SonarQube analysis.  For example, assign one or more values like 'COB* CBL*' to indicate that your COBOL types are to be scanned. 

- **Wait_for_SonarQube** when a SonarQube analysis job is submitted, should the Endevor CAST job wait for its completion? (Y/N). If 'Y', then the Cast job will  wait, and the results of the Analysis will impact the impact the Success or Failure of the package CAST. 

Note that persons who create, and CAST Endevor packages can override the default values by entering text into the package notes.


## Package Notes Overrides

The Notes section within each package provides a flexible mechanism to select or override SonarQube options. These preferences can be specified anywhere within the Notes, utilizing any combination of casing and separators such as underscores, dashes, or spaces. Your C1UEXTR7 utility can support the keywords you want to use for directing processing logic. Consider these examples of a notes section where both options have been defined:

        .........1.........2.........3.........4.........5.........6
    1.  This package is very special. Hanlde with care.             
    2.  ____________________________________________________________
    3.  ____________________________________________________________
    4.  ____________________________________________________________              
    5.  ____________________________________________________________
    6.  ____________________________________________________________
    7.  Run SonarQube Analysis                                                            
    8.  Bypass SonarQube waiting                                                            

The **C1UEXTR7.rex** member supports the examples shown, but you can adopt support for your own text strings to turn on or off requests. 

## Python item

The Python script, **SonarDriver.py**, serves as the primary orchestrator for SonarQube scanning. While these examples utilize XCOM for file transmissions, the logic is modular, allowing you to easily substitute components to accommodate your preferred transmission utility.

## Site Varaiables


**[@SITE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/%40site.rex)** the member to be renamed with an "@" and your lpar name. Its content has Lpar-specific details, allowing other software items to run anywhere unchanged. 

Assign your values for variables at your site:

  - **MySENULibrary** - the Endevor Skeleton (CSIQSENU) library name
  - **MySEN2Library** - a Secondary Skeleton library where XCOM* or SSH* members are found
  - **MyCLS0Library** - the Endevor Clist/REXX (CSIQCLS0) library
  - **MyCLS2Library** - a Secondary Clist/REXX where REXX components of this solution can be found

Your site's SonarQube selections should also be placeed in the @SITE member, and may specify site-level defaults and override values for specific System names. In this example, the system FINANCE has its own values:

        /*   REXX  */                                                        
        PARSE ARG Parm                                                       
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 17 Line(s) not Displayed 
        MyCLS2Library = 'YourHLQ.ENDEVOR.REXX'                           
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  6 Line(s) not Displayed 
        MySENULibrary = 'YourHLQ.CSIQSENU'                                      
        MySEN2Library = 'YourHLQ.ENDEVOR.SKELS'                          
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 13 Line(s) not Displayed 
       
        /* Optional Entries  for SonarQube processing:                 */          
        Cast_Location_for_Sonarqube = 'DEV 2' /* <= env stgid or empty */       
        Cast_Location_for_Sonarqube = '' /* <= env stgid or empty      */        
        /* you can give values at the system level, for example:       */  
        Cast_Location_for_Sonarqube_FINANCE = 'QAS Q'                       
        Wait_for_SonarQube = 'Y'       /* wait?  Y/N                   */          
        Wait_for_SonarQube_FINANCE = 'N'                                        
        SonarQube_Element_Types = 'COBOL JAVA CPP'                             
        SonarQube_Element_Types_FINANCE = 'COB* CBL*'                           
        GenerateProcessorStepnames = 'COMPILE COMP CMP COB'            
        SonarTransmitMethod = 'XCOM'   /* FTP / SSH / XOM .....*/        


Remember to rename the @SITE member to reflect the name of your Lpar. For example, if your Lpar name is DEV1, then rename @SITE to @DEV1. You can run **[WHEREIAM.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/WHEREIAM.rex)** to discover the new name to use for your @SITE member. 

## Other items

The functional characteristics of this solution are designed to easily align with your site's specific requirements. Several utility components or shared items are maintained independently of this folder. These resources are accessible at the following GitHub locations:

**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex )** for bumping an existing jobname to render a new job name

**[GETACCTC.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GTUNIQUE.rex)** for obtaining a unique 8-byte name from the current date and time.

**[QMATCH.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/QMATCH.rex )** for comparing two text strings, where one or both may have wild-carded values.

**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 



As a SonarQube job runs, it places members into a "work" dataset you name as the **SonarWorkfile**. You can View the members to see actions performed, and to help resolve issues.  



 
