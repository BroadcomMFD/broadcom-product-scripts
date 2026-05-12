/*  REXX */
  /* Get the Jobid / Jobnumber for the running job */
  TCB_Addr = C2D(Storage(21C,4)) /* Current TCB Addr */
  JSCB_Addr = C2D(Storage(D2X(TCB_Addr+180),4)) /* JSCB Addr */
  SSIB_Addr = C2D(Storage(D2X(JSCB_Addr+316),4)) /* SSIB Addr */
  JobID = Storage(D2X(SSIB_Addr+12),8)
  say "Jobid:"  JobID
  Return JobId
