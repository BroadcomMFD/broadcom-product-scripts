/*        REXX                                                    */
/* -------------------------------------------------------------- */
/* This is a simple version that:                                 */
/*  o Collects activity by processor and by user                  */
/* -------------------------------------------------------------- */

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

/* Indicate your choices here.....                                */
   LoggingPrefix = 'SYSDE32.NDVR.LOGGING'
   HowManyEntries= 20

   /* If C1UEXTR3 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR3'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) /= = ' ' then Trace ?r

   Sa= 'You called ....CLSTREXX(C1UEXTR3) '

   /* In case these are not provided by the Exit */
   SRC_ELM_ACTION_CCID = ' '
   SRC_ELM_LEVEL_COMMENT = ' '
   TGT_ELM_ACTION_CCID = ' '
   TGT_ELM_LEVEL_COMMENT = ' '
   /* These Element Actions determine whehter to */
   /* use SRC or TGT variables                   */
   ActionsThatUse_SRC = 'RETRIEVE MOVE DELETE GENERATE'
   ActionsThatUse_TGT = 'UPDATE '

   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)

   /* Parms from C1UEXT02 is a string of REXX statements   */
   Interpret Parms
   MyRc = 0
   Message =''
   MessageCode = '    '
/*
   If TGT_ENV_TYPE_OF_BLOCK = 'C' then,
   If SRC_ENV_IO_TYPE = 'I' then,
*/

   sa= SRC_ENV_TYPE_OF_BLOCK
   sa= TGT_ENV_TYPE_OF_BLOCK
   sa= SRC_ENV_IO_TYPE
   sa= TGT_ENV_IO_TYPE

   If WordPos(ECB_ACTION_NAME,ActionsThatUse_TGT) > 0 then,
      thisElement   = TGT_ENV_ELEMENT_NAME
   Else,
      thisElement   = SRC_ENV_ELEMENT_NAME

   If Substr(SRC_ELM_PROCESSOR_NAME,1,1) >= 'A' &,
      Substr(SRC_ELM_PROCESSOR_NAME,1,1) <= 'Z' then,
      Do
      thisProcessor = Strip(SRC_ELM_PROCESSOR_NAME)
      If Length(thisProcessor) = 0  then
         thisProcessor = Strip(TGT_ELM_PROCESSOR_NAME)
      End
   Else,
      thisProcessor = Strip(TGT_ELM_PROCESSOR_NAME)

   If Length(thisProcessor) = 0 |,
      Substr(thisProcessor,1,1) <  'A' |,
      Substr(thisProcessor,1,1) >  'Z' then Exit
   If Substr(thisElement,1,1) <  '$' |,
      Substr(thisElement,1,1) >  'Z' then Exit

/* X = OUTTRAP(LINE.); */
   Call EnterLOGForUSers
   Call EnterLOGForProcessors

   Exit

EnterLOGForUsers:

   UsersLog = LoggingPrefix'.'USERS'('USERID()')'
   CALL BPXWDYN "ALLOC DD(USERLOG) DA("UsersLog") SHR"
   usr.0 = 0
   "Execio * DISKR USERLOG (Stem usr. Finis"
   WriteThismany = Min(HowManyEntries, usr.0)
   sa= 'Have' WriteThismany
   Push thisElement "@"DATE('S') TIME(),
        "Processor="thisProcessor REQ_ACTION_RC
   "Execio 1 DISKW USERLOG "
   "Execio" WriteThismany,
               "DISKW USERLOG (Stem usr. Finis"
   CALL BPXWDYN "FREE DD(USERLOG)"
   Return

EnterLOGForProcessors:

   ProcessorLog = LoggingPrefix'.'PROCESS'('Strip(thisProcessor)')'
   CALL BPXWDYN "ALLOC DD(PROCLOG) DA("ProcessorLog") SHR"
   prc.0 = 0
   "Execio * DISKR PROCLOG (Stem prc. Finis"
   WriteThismany = Min(HowManyEntries, prc.0)
   sa= 'Have' WriteThismany
   Push Userid() "@"DATE('S') TIME(),
        "Element="thisElement REQ_ACTION_RC
   "Execio 1 DISKW PROCLOG "
   "Execio" WriteThismany,
               "DISKW PROCLOG (Stem prc. Finis"
   CALL BPXWDYN "FREE DD(PROCLOG)"

   Return

