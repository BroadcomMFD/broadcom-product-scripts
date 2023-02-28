# Dynamic-SYSLIB

Items in this folder provide for a "Dyanamic SYSLIB" feature. Developement efforts conducted in parallel might need to share inputs, and these items provide for that kind of sharing. 

For example, a January release being developed in one sandbox (or environment) might be underway at the same time as a March release in another sandbox (or envieonment). This feature allows the March release to include libraries for the January release in its own SYSLIB concatenations. The result is that testing of the March release simulates the January release being in production - before the January release is Moved to production.

<<<<<<< HEAD
Endevor elements create library aliases are used to support this feature, which enables:
  - Library references can change quickly and easily by the reassignment of the alias
  - Endevor processors are impacted only for a 1-time setup of this feature. As alias names change, processors are not impacted
  - Endevor keeps a history (as deltas) of library concatenation changes
  - responsibility for library concatenations can be given to application teams

The YAML2REXX routine is used by more than one solution, and can be found in the Processor-Tools-and-Processor-Snippets folder.
=======
A processor for a new type (ALIAS for example) creates library aliases to support this feature. Benefits include:
  - Library references can change quickly and easily by the reassignment of the alias pointers
  - Endevor keeps a history (as deltas) of library concatenation changes as reflected in ALIAS elements
  - Responsibility for library concatenations can be given to application teams by managing ALIAS elements in a simple YAML format
  - Language Generate processors (COBOL for example) are impacted only for a 1-time setup of this feature. As alias names change these processors are not impacted

>>>>>>> 40137022342f8103a7b1fc98d5198b63082dc59d
