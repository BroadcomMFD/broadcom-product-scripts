/*  REXX */
/*  Find and return the Accounting code value for current user/job */
  start   = 540                    /* it starts here */
  start   = D2X(start)
  TCB_Addr = C2D(Storage(start,4)) /* Current TCB Addr */
  TCB_Area =     Storage(D2X(TCB_Addr),200)
/*TIOT_Addr =    Substr(TCB_Area,13,4)
  TIOT_jobname = Storage(C2X(TIOT_Addr),8)   */

  JSCB_Addr = Substr(TCB_Area,181,4)
  JSCB_Area = Storage(C2X(JSCB_Addr),280)
  JCT_Addr  = Substr(JSCB_Area,261,4)
  JCT_Area  = Storage(C2X(JCT_Addr),100)
  ACT_Addr  = C2D(Substr(JCT_Area,57,3))
  ACT_Area  = Storage(D2X(ACT_Addr),100)
  ACT_len   = C2D(Substr(ACT_Area,49,1))
  ACT_code  = Substr(ACT_Area,50,ACT_len)

  Return ACT_code
