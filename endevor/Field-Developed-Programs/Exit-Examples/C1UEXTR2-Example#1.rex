/*        rexx         */

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

   /* If C1UEXTR2 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR2'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) /= = ' ' then Trace ?r

   Sa= 'You called ....CLSTREXX(C1UEXTR2) '

   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)

   /* Parms from C1UEXT02 is a string of REXX statements   */
   Interpret Parms
   MyRc = 0
   Message =''
   MessageCode = '    '

   /* If CCID is left blank, then apply last used CCID  */
   If REQ_CCID = COPIES(' ',12) then Call Update_CCID;

   /* If COMMENT is left blank, then apply last used COMMENT */
   If REQ_COMMENT = COPIES(' ',40) then Call Update_COMMENT;

   sa= 'MyRc =' MyRc

   If REQ_SISO_INDICATOR = 'Y' then
      Do
      Message = 'Remember that you have set OVERRIDE SIGNOUT'
      MyRc        = 4
      End

   If ECB_USER_ID = '???JO11' then,
      Do
      Message = 'Hello There.  You have a msg'
      MessageCode = '0920'
      MyRc        = 4
      End

   If MyRc = 0 then Exit

   If Message /= '' then,
      Do
      hexAddress = D2X(Address_ECB_MESSAGE_TEXT)
      storrep = STORAGE(hexAddress,,Message)
      hexAddress = D2X(Address_ECB_MESSAGE_LENGTH)
      storrep = STORAGE(hexAddress,,'0084'X)
      End

   If MessageCode /= '    ' then,
      Do
      hexAddress = D2X(Address_ECB_MESSAGE_CODE)
      storrep = STORAGE(hexAddress,,MessageCode)
      End

   /* Tell Endevor something changed or something failed */
   hexAddress = D2X(Address_ECB_RETURN_CODE)
   If MyRc = 4 then,
      storrep = STORAGE(hexAddress,,'00000004'X)
   Else,
      storrep = STORAGE(hexAddress,,'00000008'X)

   Exit

Update_CCID:

   IF SRC_ENV_TYPE_OF_BLOCK = 'C' then,
      Replace_CCID = SRC_ELM_ACTION_CCID
   Else,
      Replace_CCID = TGT_ELM_ACTION_CCID

   If Substr(Replace_CCID,1,1) < 'A' then Return;

   hexAddress = D2X(Address_REQ_CCID)
   storrep = STORAGE(hexAddress,,Replace_CCID)
   MyRc = 4

   Return;

Update_COMMENT:

   IF SRC_ENV_TYPE_OF_BLOCK = 'C' then,
      Replace_COMMENT = SRC_ELM_LEVEL_COMMENT
   Else,
      Replace_COMMENT = TGT_ELM_LEVEL_COMMENT

   If Substr(Replace_COMMENT,1,1) < 'A' then Return;

   hexAddress = D2X(Address_REQ_COMMENT)
   storrep = STORAGE(hexAddress,,Replace_COMMENT)
   MyRc = 4

   Return;