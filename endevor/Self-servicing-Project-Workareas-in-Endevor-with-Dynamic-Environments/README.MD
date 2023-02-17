## Self-servicing Project Workareas in Endevor with Dynamic Environments
This project contains artifacts described in the [Self-servicing Project Workareas in Endevor with Dynamic Environments](https://medium.com/modern-mainframe/self-service-developer-workspaces-in-endevor-3b83c72bdc14) blog on Medium.  

These tools are useful in building new Dynamic Environments in Endevor. Two methods are provided:
1. __The use of Endevor processors__ - Items GDYNENV.PROCESS and DDYNENV.PROCESS are Generate and Delete processors respectively that can be defined to an Endevor type and made available to developers to create their own developement areas.

2. __Batch JCL submission__ - Items in the Batch folder operate as a part of a batch process that can dynamically build a list of new Environments. Using a "Table Tool maneuver" a job can be converted into a "model", and then used for the creation of a list of new dynamic Environments. New Environment names can be simply entered into a table of a job with a Table Tool step. The Table Tool job submits an additional job for each table row to create a new Dynamic Environment.

Both methods depend on the use of the Deferred File Creation (DFC) feature for the automated allocation of datasets, and can be used for building hybrids for building dynamic environments.
