/*        rexx                                                    */
/* -------------------------------------------------------------- */
/* This is a simple version that:                                 */
/*  o Reuses a CCID value already on the element if CCID is blank */
/*  o Validates a CCID with Service-Now                           */
/*  o Reuses a comment value from element    if comment is blank  */
/*  o Gives a friendly reminder if the SIGNOUT OVERRIDE is on     */
/* -------------------------------------------------------------- */
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
   /* In case these are not provided by the Exit */
   SRC_ELM_ACTION_CCID = ' '
   SRC_ELM_LEVEL_COMMENT = ' '
   TGT_ELM_ACTION_CCID = ' '
   TGT_ELM_LEVEL_COMMENT = ' '
   /* These Element Actions determine whehter to */
   /* use SRC or TGT variables                   */
   ActionsThatUse_SRC = 'RETRIEVE MOVE DELETE GENERATE TRANSFER'
   ActionsThatUse_TGT = 'UPDATE '
   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)
   /* Parms from C1UEXT02 is a string of REXX statements   */
   Interpret Parms
   MyRc = 0
   Message =''
   MessageCode = '    '
   /* Find already used/validated CCID value from Element block */
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_SRC) > 0 then,
      Former_CCID = SRC_ELM_ACTION_CCID
   Else,
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_TGT) > 0 then,
      Former_CCID = TGT_ELM_ACTION_CCID
   /* If CCID is left blank, then apply last used CCID        */
   /* otherwise if it appears to be a ServiceNow  - validate  */
   If REQ_CCID = COPIES(' ',12) then Call Update_CCID;
   Else,
   If Substr(REQ_CCID,1,3) = 'PRB' |,
      Substr(REQ_CCID,1,3) = 'CHG' &,
      REQ_CCID /= Former_CCID      Then,
         Do
         Message = SERVINOW('C1UEXTR2' REQ_CCID ECB_TSO_BATCH_MODE)
         If POS('**NOT**', Message) > 0 then,
            Do
            MessageCode = 'U012'
            MyRc        = 8
            End;  /* If POS('**NOT**', Message) > 0 */
         End;  /* If Substr(REQ_CCID,1,3) = 'PRB' ... 'CHG' */
   /* If COMMENT is left blank, then apply last used COMMENT */
   If MyRc < 8 &,
      REQ_COMMENT = COPIES(' ',40) then Call Update_COMMENT;
   sa= 'MyRc =' MyRc
   /* Did user specify OVERRIDE SIGNOUT ?                    */
   If MyRc = 0 & REQ_SISO_INDICATOR = 'Y' then
      Do
      Message = 'Remember that you have set OVERRIDE SIGNOUT'
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
   /* Still missing a CCID?                      */
   If Substr(Former_CCID,1,1) < 'a' then,
      Do
      MyRc = 8
      Message = '** A CCID value is required **'
      MessageCode = 'U012'
      Return;
      End
   hexAddress = D2X(Address_REQ_CCID)
   storrep = STORAGE(hexAddress,,Former_CCID)
   MyRc = 4
   Return;
Update_COMMENT:
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_SRC) > 0 then,
      Replace_COMMENT = SRC_ELM_LEVEL_COMMENT
   Else,
   If Wordpos(ECB_ACTION_NAME,ActionsThatUse_TGT) > 0 then,
      Replace_COMMENT = TGT_ELM_LEVEL_COMMENT
   If Substr(Replace_COMMENT,1,1) < 'a' then,
      Do
      MyRc = 8
      Message = '** A COMMENT value is required **'
      MessageCode = 'U011'
      Return;
      End
   hexAddress = D2X(Address_REQ_COMMENT)
   storrep = STORAGE(hexAddress,,Replace_COMMENT)
   MyRc = 4
   Return;
