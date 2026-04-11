#  SonarQube Interface to Endevor

This folder provides example assets demonstrating the integration of SonarQube and Endevor.

The integration enables Endevor to automatically trigger a SonarQube analysis when an Endevor package is CAST. To avoid tying up the user's session, any foreground CAST action is resubmitted to run in batch.

Optionally, based on user configuration, the CAST job can be set to wait for the SonarQube results. If this option is chosen, the final package status will be updated to reflect the outcome of the analysis.


These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

## What Endevor Packages are to be processed with SonarQube?

Within the SONRQUBE.rex member you can provide Endevor Type masks for the elements you wish to analyze. Here is an example:

    /* Provide Endevor Type masks for element to be analyzed   */    
    SonarQube_Element_Types = 'COB* CBL* CPP* '                      

Also within the SONRQUBE.rexx name the steps in your Generate processors, where input component relationships can be gathered by your site's ACM. Here is an example:

    /* Provide Endevor processor steps which show ACM inputs   */    
    GenerateProcessorStepnames = 'COMPILE COMP CMP COB'              
                                                        
## Transmission Methods

Once the right kind of elements and optionally input components are found in a package, they must be transmitted to the platform where SonarQube is found. Indicate what transmission method you will use. (The last one named is the one acutally used). Here are some examples:

    TransmitMethod = 'FTP'       /* **chose one ** Last one wins **/ 
    TransmitMethod = 'SSH'       /* **chose one ** Last one wins **/ 
    TransmitMethod = 'XCOM'      /* **chose one ** Last one wins **/ 

The name you choose will also be a prefix for Transmission member names in the configuration.  See the **Transmission Members** section below for details

##SonarQube Options

As you implement the items in this folder, you can establish default values for these two options in the C1UEXTR7.rex program:

- **Cast_with_SonarQube** when elements are found with the Type matching your selection criteria, should they be submitted for a SonarQube Analysis by default? (Y/N)

- **Wait_for_SonarQube** when a SonarQube analysis job is submitted, should the Endevor CAST job wait for it? (Y/N). If you indicate that the Cast job should wait, then the results of the Analysis impact the Success or Failure of the CAST. Otherwise, there is no impact. 

Note that persons who create, and CAST Endevor packages can override the default values by entering text into the package notes.


## Package Notes Overrides

The Notes in each package can select or override either or both of the two SonarQube options. Just reflect the choices for the package anywhere in the Notes section. You can use any case for the words, and you can use underscores, dashes or blanks between the words. The words are recognized by C1UEXTR7 and will be used to direct the processing. Here is an example notes section where both options are specified:

        .........1.........2.........3.........4.........5.........6
    1.  This package is very special. Hanlde with care.             
    2.  ____________________________________________________________
    3.  ____________________________________________________________
    4.  Cast_with_SonarQube= Y                                      
    5.  WAIT-FOR-SONARQUBE = Y                                      
    6.                                                              
    7.                                                              
    8.                                                              


## Transmission Members

The value you give to **TransmitMethod** is used to locate members that contribute to the submitted SonarQube Analysis JCL. The members, where &TransmitMethod is the value you assigned, are:

- &TransmitMethod.#JOB - JCL for using the Transmission tool to send items to the SonarQube folders
- &TransmitMethod.#RUN - JCL for using the Tansmission tool to initiating the execution of the SonarQube analysis
- &TransmitMethod.#RCV - JCL for receiving the RESULTS of the SonarQube analysis

The examples in this folder show the TransmitMethod  assigned to 'XCOM' and the three JCL members are XCOM#JOB, XCOM#RUN, and XCOM#RCV accordingly. If necessary, you can mix methods within the 3 members, and not use the same tool for all of them, but the names for all 3 must use the same prefix.

## Other items

Features of this solution are easily tailorable to the requirements at your site. By default they include:


Processing logic is primarily found in REXX, JCL and Python members. The Python member orchestrates the SonarQube activity. File transmissions are performed using XCOM, in these examples, but they easily be swapped out for members that use your transmission tool. 



Some supporting items are not found in this folder, since they are utilities, or already contribute to other solutions. They can be found in other locations of this GitHub, including:

**[@SITE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/%40site.rex)** the member to be renamed with an "@" and your lpar name. Its content has Lpar-specific details, allowing other software items to be void of details, and able to run anywhere unchanged. See the description for **[@siteMult.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Shipments-for-Multiple-Destinations%20(zowe))** 


**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex )** for bumping an existing jobname to render a new job name

**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GTUNIQUE.rex )** for obtaining a unique 8-byte name from the current date and time.

**[QMATCH.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/QMATCH.rex )** for comparing two text strings, where one or both may have wild-carded values.


**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 

**[WHERE@M1](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/WHERE%40M1.rex)** the utility used for supporting diversity of dataset names, and other differences, by Lpar.

As a SonarQube job runs, it places members into a "work" dataset you name as the **SonarWorkfile**. You can View the members to see actions performed, and to help resolve issues.  




Use the SonarQube.bat commmand to bring the items together for your mainframe.

 
