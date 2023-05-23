# Dynamic-SYSLIB

Items in this folder provide for a "Dynamic SYSLIB" feature. Development efforts conducted in parallel might need to share inputs, and items in this folder provide for that kind of sharing.

For example, development for a January release might be underway in one sandbox (or environment) at the same time as development for a March release in another sandbox (or environment). This feature allows the March release to include libraries from the January release within its own SYSLIB concatenations, before the January release is Moved to production.

A processor for a new type (Examples: SYSLIB or ALIAS) creates library aliases to support this feature. Benefits include:

  - Library references can change quickly and easily by the reassignment of alias pointers
  - Endevor keeps a history (as deltas) of library concatenation changes as reflected in SYSLIB or ALIAS elements
  - Responsibility for library concatenations can be given to application teams by managing SYSLIB or ALIAS elements in a simple YAML format
  - Language Generate processors (COBOL for example) are impacted only for a 1-time setup of this feature. As alias names change these processors are not impacted

The YAML2REXX routine is used by more than one solution, and can be found in the **Processor-Tools-and-Processor-Snippets** folder.