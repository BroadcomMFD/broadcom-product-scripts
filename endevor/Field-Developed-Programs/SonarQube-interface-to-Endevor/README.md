#  SonarQube Interface to Endevor

Items in this folder provide an example method for interfacing SonarQube with Endevor. They allow Endevor to initiate a SonarQube analysis for an Endevor package, receive the quality gates response from the SonarQube analysis, and pass or fail the CAST of the package depening on the results.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

Features of this solution are easily tailorable to fit your site. By default they include:

1. Makes some initial analysis of a CASTing package to 
determine whether to initiate the SonarQube 
analysis:
   -  The Package must have at least one COBOL element. Element types of COB* or CBL* are selected, but you can designate your own choice.
   -  If any of rhe Package note lines can begin with the text "BYPASS SONARQUBE", no SonarQube analysis is done. 
2.  If conditions are met, and the package is being CAST in TSO foreground, the CAST action is resubmitted in Batch. Since it may be necessary to wait for time-consuming actions to run, it is best for this process to run in batch.
3. COBOL programs in the package are identified.
4. ACM is referenced to identify input components for  packaged COBOL elements. Input components such as copybooks, do not need to be included in the package. Rather, the ACM information for COBOL elements will caulse copybooks to be included in the SonarQube analysis.
5. A separate (second) JOB is constructed and submitted. The steps of the separate job include:
    - Report back to the Endevor exit (running as job #1 doing a CAST) that the second job is running
    - COBOL elements are RETRIEVEd into a PDS dataset
    - COBOL and copybook members are transmittted to the server that runs SonarQube. Cobol members are transmitted from the RETRIEVE dataset. Copybook members are transmitted from  datasets named in the ACM references.  
    - Report back to the Endevor exit that the member transmissions are done
    - A SonarQube analysis is executed
    - The SonarQube results are transmitted back to the site running the Endevor CAST.
    - Report back to the Endevor exit the SonarQube results. 
6. The Endevor exit waits for confirmation that the separate job is running, and displays messages accordingly
7. The Endevor exit waits for confirmation that the file transmissions are done, and displays messages accordingly.
8. The Endevor exit waits for the return of the SonarQube analysis, and displays messages accordingly.
9. If any of the expected results are not returned, or the analysis indicates a code analysis failure, the package CAST is made to Fail.

The COBOL exit is constructed to rely on a REXX subroutine to perform the main processing. A Python member orchestrates the SonarQube activity. The Python itself. File transmissions are performed with XCOM, in these examples, but can easily be swapped out with members that run your transmission tool. 

Some supporting items not found in this folder, since they are utilities, or already contribute to other solutions. They can be found in other locations of this GitHub, including:


**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex)** for bumping an existing jobname to render a new job name


**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Automated-Test-Facility-Using-Test4Z/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GTUNIQUE.rex)** for obtaining a unique 8-byte name from the current date and time.

**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 

Use the SonarQube.bat commmand to bring the items together for your mainframe.



