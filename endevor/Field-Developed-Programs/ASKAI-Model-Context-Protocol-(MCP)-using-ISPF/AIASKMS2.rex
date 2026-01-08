/*     REXX   */
  /* Insert AIASK instruction messages */
  "ISREDIT MACRO" ;

  ndvr.1 = '"END" to continue / "CANCEL" to quit'
  ndvr.2 = "Learn about AIASK here....            "
  ndvr.3 = "      https://techdocs.broadcom.com/endevor "
  ndvr.4 = "Adjust or Enter your query above ... "
  ndvr.5 = "   "
  Sa=     'PSP.CLIST(AIASKM03)'
  ADDRESS ISREDIT " RESET "
  "ISREDIT (LINE) = CURSOR"
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZLAST = NOTELINE '"ndvr.5"'"
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZLAST = NOTELINE '"ndvr.4"'"
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZLAST = NOTELINE '"ndvr.3"'"
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZLAST = NOTELINE '"ndvr.2"'"
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZLAST = NOTELINE '"ndvr.1"'"

  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;

  ADDRESS ISPEXEC "VGET (ZPANELID ZSCRNAME ZAPPLID) SHARED"
  sa= "You are using:" ZPANELID ZSCRNAME ZAPPLID

  ADDRESS ISPEXEC 'VGET (ZVERB ZCMD) ASIS'
  Sa= ZVERB ZCMD ZERRFLD ZERRMSG
   ADDRESS ISPEXEC
       'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN ',
             'ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN ',
             'ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN) ',
       'PROFILE'
   If Queued() > 0 then Parse pull IneedExpert
   Else,
   If ENVSTYP = 'COBOL' then IneedExpert = 'a COBOL Expert'
   Else,
   If ZAPPLID = 'CTLI'  then IneedExpert = 'an Endevor Admin'
   Else,
   IneedExpert = 'a COBOL Expert'

   ADDRESS ISREDIT "Change First '**AnExpert**'" ,
                          "'"IneedExpert"'"
   EXIT

