#  SonarQube Interface to Endevor

Items in this folder provide an example method for interfacing SonarQube with Endevor. They allow Endevor to initiate a SonarQube analysis for an Endevor package, receive the quality gates response from the SonarQube analysis, and pass or fail the CAST of the package depending on the results.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

Features of this solution are easily tailorable to the requirements at your site. By default they include:

1. During a package CAST, an analysis of the pckage content and package notes is done.
   -  It is determined whether the Package has at least one COBOL element. Element types of COB* or CBL* make the determination, but you can designate your own manner of recognition.
   -  If any of the Package note lines can begin with the text "BYPASS SONARQUBE", no SonarQube analysis will be done. If it becomes necessary to bypass the SonarQube processing, then a simple update of the package notes will bypass the SonarQube analysis.
2.  If package contains COBOL elements, and the BYPASS is not selected, and the package is being CAST in TSO foreground, then the CAST action is resubmitted in Batch. Since it may be necessary to wait for time-consuming actions to complete, it is best for this process to run in batch.
3. All COBOL programs in the package are identified, and ACM queries are used for identifying input components. Input components such as copybooks, do not need to be included in the package. Rather, the ACM information for packaged COBOL elements will bring copybooks into the SonarQube analysis.
4. Packaged COBOL elements are RETRIEVEd into a PDS.
5. A separate (second) JOB is constructed and submitted. The steps of the separate job include:
    - Reports back to the Endevor exit (running as job #1 doing a CAST) that the second job is running
    - COBOL and copybook members are transmittted to the SonarQube server. Cobol members are transmitted from the RETRIEVE dataset. Copybook members are transmitted from datasets named in the ACM references.  
    - Reports back to the Endevor exit that the member transmissions are completed
    - Executes a SonarQube analysis.
    - Transmits the SonarQube results back to the site running the Endevor CAST.

6. The Endevor exit waits for confirmation that the separate job is running, and displays messages accordingly
7. The Endevor exit waits for confirmation that the file transmissions are done, and displays messages accordingly.
8. The Endevor exit waits for the return of the SonarQube analysis, and displays messages accordingly.
9. If any of the expected results are not returned, or the analysis indicates a code analysis failure, the package CAST is made to Fail.

Processing logic is primarily found in REXX, JCL and Python members. The Python member orchestrates the SonarQube activity. File transmissions are performed using XCOM, in these examples, but they easily be swapped out for members that use your transmission tool. 



Some supporting items are not found in this folder, since they are utilities, or already contribute to other solutions. They can be found in other locations of this GitHub, including:

**[@SITE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/%40site.rex)** the member to be renamed with an "@" and your lpar name. Its content has Lpar-specific details, allowing other software items to be void of details, and able to run anywhere unchanged. See the description for **[@siteMult.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Shipments-for-Multiple-Destinations%20(zowe))** 


**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex )** for bumping an existing jobname to render a new job name

**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Automated-Test-Facility-Using-Test4Z/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GTUNIQUE.rex )** for obtaining a unique 8-byte name from the current date and time.

**[QMATCH.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/QMATCH.rex )** for comparing two text strings, where one or both may have wild-carded values.


**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 

**[WHERE@M1](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/WHERE%40M1.rex)** the utility used for supporting diversity of dataset names, and other differences, by Lpar.

This code in the SONRQUBE.rexx  is used for identifying COBOL elements and copybooks. You might need to tweak it for your site:

The cobol element type is expected to begin with COB or CBL

    COBOL_Element_Types     = 'COB* CBL*'
    COBOL_Compile_StepNames = 'COMPILE COMP CMP COB'

Then the compile step should be one of those above. 

The ProcessCopybookMembers routine looks for Input components from SYSLIB in a compile step. 

When the process runs, it places members into the dataset you name as the **SonarWorkfile**. You can use the members to see details of actions performed, and to help resolve issues.  

Use the SonarQube.bat commmand to bring the items together for your mainframe.

 
