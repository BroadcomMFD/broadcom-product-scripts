# Dynamic-SYSLIB

Items in this folder provide for a "Dyanamic SYSLIB" feature. Developement efforts conducted in parallel might need to share inputs, and these items provide for that kind of sharing. 

For example, a January release being developed in one sandbox (or environment) might be underway at the same time as a March release in another sandbox (or envieonment). This feature allows the March release to include libraries for the January release in its own SYSLIB concatenations. The result is that testing of the March release simulates the January release being in production - before the January release is Moved to production.

Endevor elements create library aliases are used to support this feature, which enables:
  - Library references can change quickly and easily by the reassignment of the alias
  - Endevor processors are impacted only for a 1-time setup of this feature. As alias names change, processors are not impacted
  - Endevor keeps a history (as deltas) of library concatenation changes
  - responsibility for library concatenations can be given to application teams
