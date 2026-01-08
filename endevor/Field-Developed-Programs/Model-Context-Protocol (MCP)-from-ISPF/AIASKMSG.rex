/*     REXX   */                                                        00000100
  /* Insert AIASK instruction messages */                               00000200
  "ISREDIT MACRO" ;                                                     00000300
                                                                        00000400
  ndvr.1 = '"END" to continue / "CANCEL" to quit'                       00000500
  ndvr.2 = "Learn about AIASK here....            "                     00000600
  ndvr.3 = "      https://techdocs.broadcom.com/endevor "               00000700
  ndvr.4 = "Adjust or Enter your query above ... "                      00000800
  ndvr.5 = "   "                                                        00000900
  Sa=     'PSP.CLIST(AIASKMSG)'                                         00001000
  ADDRESS ISREDIT " RESET "                                             00001100
  "ISREDIT (LINE) = CURSOR"                                             00001200
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZFIRST = NOTELINE '"ndvr.5"'"    00001300
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZFIRST = NOTELINE '"ndvr.4"'"    00001400
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZFIRST = NOTELINE '"ndvr.3"'"    00001500
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZFIRST = NOTELINE '"ndvr.2"'"    00001600
  ADDRESS ISREDIT "ISREDIT LINE_AFTER .ZFIRST = NOTELINE '"ndvr.1"'"    00001700
                                                                        00001800
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;              00001900
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;              00002000
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;              00002100
  ADDRESS ISREDIT " LINE_AFTER .ZLAST = DATALINE '"  "'" ;              00002200
                                                                        00002300
  ADDRESS ISPEXEC "VGET (ZPANELID ZSCRNAME ZAPPLID) SHARED"             00002400
  sa= "You are using:" ZPANELID ZSCRNAME ZAPPLID                        00002500
                                                                        00002600
  ADDRESS ISPEXEC 'VGET (ZVERB ZCMD) ASIS'                              00002700
  Sa= ZVERB ZCMD ZERRFLD ZERRMSG                                        00002800
   ADDRESS ISPEXEC                                                      00002900
       'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN ',      00003000
             'ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN ',      00003100
             'ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN) ',      00003200
       'PROFILE'                                                        00003300
   If Queued() > 0 then Parse pull IneedExpert                          00003400
   Else,                                                                00003500
   If ENVSTYP = 'COBOL' then IneedExpert = 'a COBOL Expert'             00003600
   Else,                                                                00003700
   If ZAPPLID = 'CTLI'  then IneedExpert = 'an Endevor Admin'           00003800
   Else,                                                                00003900
   IneedExpert = 'a COBOL Expert'                                       00004000
                                                                        00004100
   ADDRESS ISREDIT "Change First '**AnExpert**'" ,                      00004200
                          "'"IneedExpert"'"                             00004300
   EXIT                                                                 00004400
                                                                        00004500
