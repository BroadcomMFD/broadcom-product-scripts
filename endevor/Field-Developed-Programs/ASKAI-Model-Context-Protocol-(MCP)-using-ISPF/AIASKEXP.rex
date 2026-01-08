  /*   REXX  */
  /* Use the Application ID or the panel name   */
  /* to determine what MCP expert is needed  .  */

  ADDRESS ISPEXEC "VGET (ZPANELID) SHARED"
  ADDRESS ISPEXEC "VGET (ZAPPLID) SHARED"
  sa= "You are using ISPF panel Applid " ZPANELID ZAPPLID

  ShortApplid = Substr(ZAPPLID,1,4)
  /*IneedExpert = 'an Endevor Admin' */
  ApplIDmap. = '?'
  ApplIDmap.CTLI       = 'an Endevor Admin'
  ApplIDmap.CAWA       = 'a File Master expert'
  ApplIDmap.CA7@       = 'a CA7 expert'
  ApplIDmap.CAMR       = 'an InterTest expert'
  ApplIDmap.GSVX       = 'a SYSVIEW expert'
  ApplIDmap.JCK0       = 'a JCLCheck expert'
  ApplIDmap.TUNT       = 'a Mainframe Application Tuner expert'
  IneedExpert = ApplIDmap.ShortApplid
  If IneedExpert /= '?' then Return IneedExpert

  thisPanelPrefix = Substr(ZPANELID,1,4)
  EndevorPanelPrefixes = 'EN BC1 C1T C1P C1S ND PACM'
  Do w# = 1 to Words(EndevorPanelPrefixes)
     If Abbrev(ZPANELID,Word(EndevorPanelPrefixes,w#)) then,
        Do
        IneedExpert = 'an Endevor Admin'
        Leave;
        End /* If Abbrev(ZPANELID,Word ... */
  End /* Do w# = 1 to Words( .... */

  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'ISREDDE') then,
        IneedExpert = 'a COBOL expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'OP'     ) then,
        IneedExpert = 'an OPS/MVS expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'GSV'    ) then,
        IneedExpert = 'a SYSVIEW expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'TUN'    ) then,
        IneedExpert = 'a Mainframe Application Tuner expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'JCK'    ) then,
        IneedExpert = 'a JCLCheck expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'CSW'    ) then,
        IneedExpert = 'a File Master expert'
  If IneedExpert = '' then,
     If Abbrev(ZPANELID,'CAW'    ) then,
        IneedExpert = 'a File Master expert'
  Return  IneedExpert

