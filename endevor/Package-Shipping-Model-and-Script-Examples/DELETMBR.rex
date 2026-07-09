/*  REXX  */
  Arg Dataset Member;
 "ALLOC DD(PDS) DSN('"Dataset"') SHR REUSE"
 QUEUE " DELETE "Dataset"("Member") FILE (PDS)"
 "Execio 1 DISKW SYSIN (Finis"
 ADDRESS LINK 'IDCAMS'
 Exit
