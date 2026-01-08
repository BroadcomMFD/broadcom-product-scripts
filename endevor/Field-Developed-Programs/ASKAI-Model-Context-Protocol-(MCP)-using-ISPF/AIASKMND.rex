/*     REXX   */
   "ISREDIT MACRO" ;

   Sa=     'PSP.CLIST(AIASKM02)'
   ADDRESS ISPEXEC
       'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN ',
             'ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN ',
             'ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN) ',
       'PROFILE'
   If RC > 0 then,
      Do
      ADDRESS ISREDIT " CANCEL "
      Exit
      End

   ADDRESS ISREDIT "CAPS OFF"
   ndvr.1 = "..."
   ndvr.1 = "I am working on Endevor element" ENVELM,
            "in Environment" ENVSENV "System" ENVSSYS
   ndvr.1 = "Act like an Endevor admin and",
             "explain the following:"
   ndvr.2 = "  Subsystem" ENVSSBS,
             "Type" ENVSTYP "with processor group" ENVPRGRP "."
   ndvr.3 = "..."

   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '"ndvr.1"'" ;
/*
   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '"ndvr.2"'" ;
   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '"ndvr.3"'" ;
   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '"ndvr.4"'" ;
   ADDRESS ISREDIT " LINE_AFTER .ZLAST =",
            "DATALINE '"ndvr.5"'" ;
*/
   ADDRESS ISREDIT " SAVE "
   ADDRESS ISREDIT " CANCEL "
   EXIT

