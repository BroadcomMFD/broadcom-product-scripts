## Self-servicing-Project-Workareas-in-Endevor-with-Dynamic-Environments

These tools are useful in building new Dynamic Environments in Endevor. Two methods are provided.
1. __The use of Endevor processors.__ Items GDYNENV.PROCESS and DDYNENV.PROCESS are Generate and Delete processors respectively that can be defined to an Endevor type and made available to developers to create their own developement areas.
2. __A Batch JCL submission.__ Items in the Batch folder operate as a part of a batch process that can dynamically build a list of new Environments. Environment names are to be entered into a table. This method also allows you to construct optional search and replace strings that can be applied to ensure that library names for each Environment are unique, and to make any other automated changes that make the new Environments ready for use.

Both methods depend on the use of the Deferred File Creation (DFC) feature for the automated allocation of datasets as they are needed.
