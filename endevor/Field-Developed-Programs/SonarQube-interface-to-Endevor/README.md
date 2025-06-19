#  SonarQube Interface to Endevor

Items in this folder demonstrate an example method for interfacing SonarQube with Endevor. They support the automated execution of a SonarQube analysis during the CAST of an Endevor Package. If the SonarQube analysis returns a "failure", then the Endevor CAST action is made to fail.

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

REXX, Python and "skeleton" components are found in this folder. 

Items not found in this folder are found in other locations of this GitHub, including:

**[GETACCT.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Automated-Test-Facility-Using-Test4Z/GETACCTC.rex)** for obtaining and re-using the users accounting code information

**[BUMPJOB.rex](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Automated-Test-Facility-Using-Test4Z/BUMPJOB.rex)** for bumping an existing jobname to render a new job name


Use the SonarQube.bat commmand to bring the items together for your mainframe.
