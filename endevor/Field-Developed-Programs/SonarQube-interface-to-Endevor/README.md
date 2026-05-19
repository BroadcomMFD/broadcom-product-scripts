#  SonarQube Interface to Endevor

This folder provides example assets demonstrating the integration of SonarQube and Endevor.

The integration enables Endevor to automatically trigger a SonarQube analysis when an Endevor package is CAST. To avoid tying up the user's session, any ISPF foreground CAST action is resubmitted to run in batch.

Optionally, based on user configuration, the CAST job can be set to wait for the SonarQube results. If this option is chosen, the final package status csn be updated to reflect the outcome of the analysis. Additionally, whether or not there is wait for the results, they can be placed into Endevor as elements, where the element name is given to match the package name.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).


## What Endevor Packages are to be processed with SonarQube?

By examining the element Types for elements within a package, it can be determined whether the package should be submitted for a SonarQube Analysis.  If a package only contains PARM elements, for example, there is no need to scan the package. 

### Optional use of the Package Builder

Package creation is an ideal time to assess if package content requires a SonarQube scan. By utilizing the [Package Builder](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor) (refer to **PACKAGE PACKAGEP** and [Package.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/Package.rex)), you can automate this evaluation.

During construction, the package builder identifies element locations and types, and detects those that should be scanned. Upon discovery, it automatically updates the package Notes, for example:

        1. RUN SONARQUBE ANALYSIS                           
        2.                                                  
        3.                                                  
        4.                                                  
        5.                                                  
        6.                                                  
        7.                                                  
        8. ELM CNT: 2                                      

 Then, the items in this folder can use the description text to know whether the package is elligible for scanning at CAST time                          

### CAST time Determination                              

The SONRQUBE.rex member can determine whether package content should be scanned. Within it, you can provide Endevor Type masks for the elements you wish to analyze. Here is an example:

    /* Provide Endevor Type masks for element to be analyzed   */    
    SonarQube_Element_Types = 'COB* CBL* CPP* '                      



For each approach, SONRQUBE.rexx must identify the Generate processor steps where your site's ACM can collect input component relationships. If you intend to scan COBOL, for instance, you should specify the processor steps that reference COPYBOOKs. Consider this example:

    /* Provide Endevor processor steps which show ACM inputs   */    
    GenerateProcessorStepnames = 'COMPILE COMP CMP COB'  


## Transmission Methods

Once the right kind of elements and optionally input components are found in a package, they must be transmitted to the platform where SonarQube is found. Indicate what transmission method you will use. The name you choose will also be a prefix for Transmission member names in the configuration.  

The value you give to **TransmitMethod** is used to locate members that contribute to the submitted SonarQube Analysis JCL. Member names are:

- &TransmitMethod.#INC - for sending members to the SonarQube server
- &TransmitMethod.#JOB - JCL for using the Transmission tool to send items to the SonarQube folders
- &TransmitMethod.#RUN - JCL for using the Tansmission tool to initiating the execution of the SonarQube analysis
- &TransmitMethod.#RCV - JCL for receiving the RESULTS of the SonarQube analysis

The examples in this folder show the TransmitMethod  assigned to 'XCOM' and the three JCL members are XCOM#JOB, XCOM#RUN, and XCOM#RCV accordingly. If necessary, you can mix methods within the 3 members, and not use the same tool for all of them, but the names for all 3 must use the same prefix.


## XCOM for Transmission and Submission

XCOM is an excellent choice for the file transmissions, and remote submission of the SonarQube process. 
See the [XCOM folder on this GitHub](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/XCOM). 

Within the C1UEXTR7 item, designate that XCOM is your choice, by setting the TransmitMethod value:

    TransmitMethod = 'XCOM'     

Find the XCOM#INC item in the current folder.

Also locate these items from the XCOM folder and place them into the library you designate as your 
**MySEN2Library** library. See the **@SITE.rex** section below.

- [XCOM#JOB](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23JOB.skl)
- [XCOM#RCV](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23RCV.skl)
- [XCOM#RUN](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/XCOM/XCOM%23RUN.skl)




## SSH  for Transmission and Submission

Within the C1UEXTR7 item, designate that SSH is your choice, by setting the TransmitMethod value:

    TransmitMethod = 'SSH'     

Also locate these items from the SSH folder and place them into the library you designate as your **MySEN2Library** library. See the **@SITE.rex** section below.

- **SSH#INC.skl**                                                                
- **SSH#JOB.skl**                                                                    
- **SSH#RCV.skl**                                                                   
- **SSH#RUN.skl**  


## SonarQube Options

As you implement the items in this folder, you can establish default values for these options in the C1UEXTR7.rex program:

- **Cast_Location_for_Sonarqube** when elements are found with the Type matching your selection criteria, should they be submitted for a SonarQube Analysis by default? (Y/N)

- **Wait_for_SonarQube** when a SonarQube analysis job is submitted, should the Endevor CAST job wait for it? (Y/N). If you indicate that the Cast job should wait, then the results of the Analysis impact the Success or Failure of the CAST. Otherwise, there is no impact. 

- **SonarQube_Element_Types** to designate Endevor type masks for those elements elligible for SonarQube analysis.  Assign a value like 'COB* CBL*' to indicate that your COBOL types are to be scanned.

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

Within **C1UEXTR7.rex**, you can easily adopt the requesting text strings you prefer to support.


## Python item

The Python script, **SonarDriver.py**, serves as the primary orchestrator for SonarQube scanning. While these examples utilize XCOM for file transmissions, the logic is modular, allowing you to easily substitute components to accommodate your preferred transmission utility.


## Other items

The functional characteristics of this solution are designed to easily align with your site's specific requirements. Several utility components or shared items are maintained independently of this folder. These resources are accessible at the following GitHub locations:

**[@SITE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/%40site.rex)** the member to be renamed with an "@" and your lpar name. Its content has Lpar-specific details, allowing other software items to be void of details, and able to run anywhere unchanged. See the description for **[@siteMult.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Shipments-for-Multiple-Destinations%2-0(zowe))** 

It is within this renamed member where values must be given for:

  - **MySENULibrary** - the Endevor Skeleton (CSIQSENU) library name
  - **MySEN2Library** - a Secondary Skeleton library where XCOM* or SSH* members are found
  - **MyCLS0Library** - the Endevor Clist/REXX (CSIQCLS0) library
  - **MyCLS2Library** - a Secondary Clist/REXX where REXX components of this solution can be found

Your site's SonarQube selections can be placeed in the @SITE member too, and may include site-level defaiults as well as values for specific System names. For example:

        /*   REXX  */                                                        
        PARSE ARG Parm                                                       
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 17 Line(s) not Displayed 
        MyCLS2Library = 'YourHLQ.ENDEVOR.REXX'                           
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  6 Line(s) not Displayed 
        MySENULibrary = 'YourHLQ.CSIQSENU'                                      
        MySEN2Library = 'YourHLQ.ENDEVOR.SKELS'                          
        -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 13 Line(s) not Displayed 
       
        /* Optional Entries  for SonarQube processing:                 */          
        Cast_Location_for_Sonarqube = 'QAS Q' /* <= env stgid or empty */       
        Cast_Location_for_Sonarqube = '' /* <= env stgid or empty      */        
        /* you can give values at the system level, for example:       */  
        Cast_Location_for_Sonarqube_FINANCE = 'COB* CBL*'                       
        Wait_for_SonarQube = 'N'       /* wait?  Y/N                   */          
        Wait_for_SonarQube_FINANCE = 'N'                                        
        SonarQube_Element_Types = ''                                            
        SonarQube_Element_Types_FINANCE = 'COB* CBL*'                           
        GenerateProcessorStepnames = 'COMPILE COMP CMP COB'            
        SonarTransmitMethod = 'XCOM'   /* FTP / SSH / XOM .....  
        /*************************************************************/          


Remember to rename the @SITE member to reflect the name of your Lpar. For example, if your Lpar name is DEV1, then rename @SITE to @DEV1.



**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex )** for bumping an existing jobname to render a new job name
**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GETACCTC.rex)** for obtaining and re-using the users accounting code information
**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GTUNIQUE.rex )** for obtaining a unique 8-byte name from the current date and time.
**[QMATCH.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/QMATCH.rex )** for comparing two text strings, where one or both may have wild-carded values.
**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 
**[WHERE@M1](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/WHERE%40M1.rex)** the utility used for supporting diversity of dataset names, and other differences, by Lpar.

As a SonarQube job runs, it places members into a "work" dataset you name as the **SonarWorkfile**. You can View the members to see actions performed, and to help resolve issues.  



 
