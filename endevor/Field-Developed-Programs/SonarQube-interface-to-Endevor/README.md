#  SonarQube Interface to Endevor

Items in this folder demonstrate an example method for interfacing SonarQube with Endevor. They support the automated execution of a SonarQube analysis during the CAST of an Endevor Package. If the SonarQube analysis returns a "failure", then the Endevor CAST action is made to fail.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

REXX, Python and "skeleton" components are found in this folder. 

Items not found in this folder are found in other locations of this GitHub, including:


**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/BUMPJOB.rex)** for bumping an existing jobname to render a new job name


**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Automated-Test-Facility-Using-Test4Z/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[GTUNIQUE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GTUNIQUE.rex)** for obtaining a unique 8-byte name from the current date and time.

**[WAITFILE.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WAITFILE.rex)** for looping through wait periods of time, until a specific file becomes available. 

Use the SonarQube.bat commmand to bring the items together for your mainframe.



