 /* REXX   */
 /* While Editing a member in of a dataset,                    */
 /* invoke NDVRA as an edit macro, to ADD/UPDATE them member   */
 /* into Endevor. Panel options entered on the first occasion  */
 /* are saved for subsequent uses.                             */
 /*                                                            */
 /* Be sure to adjust the LIBDEF commands for your libraries.. */
   'ISREDIT MACRO ' ;
   CALL BPXWDYN "INFO FI(NDVRA) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If RESULT = 0 then trace ?R
   ADDRESS ISREDIT;
   howManyToKeep = 3
   howManyToKeep = 30
   /* Get values for the ADD panel  */
   ADDRESS ISPEXEC " CONTROL RETURN ERRORS " ;
   PREFIXLN = LENGTH(PREFIX) ;
   ADDRESS ISREDIT " (MEMBER) = MEMBER " ;
   VNT2ENME = MEMBER
   ADDRESS ISREDIT " (DATASET) = DATASET " ;
   OTHDSN   = "'" || DATASET || "'"
   VNTDSTYP = 'D'     /* force dataset type to D   */
   C1SISOFR = 'Y'     /*OVERRIDE SIGNOUT */
   VARADDUP = 'Y'     /*UPDATE IF PRESENT*/
   VARNOGEN = 'Y'     /*GENERATE ELEMENT*/
   VNTUPPER = 'Y'     /*FORCE UPPER to Yes*/
   VARDELIP = 'N'     /*DELETE INPUT SOURCE*/
   VARWKLST = 'N'     /*DISPLAY LIST       */
   VAROAUTG = 'N'     /*AUTOGEN (BATCH ONLY)*/
   VAROSPAN = 'N'     /*AUTOGEN SPAN        */
   ADDRESS ISPEXEC "VGET (CTLNBR DESCRPT1) PROFILE"
   ADDRESS ISPEXEC "VGET (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "
   ADDRESS ISPEXEC "VGET (NDVRLIST) PROFILE"
   If RC = 0 then Call ScanPreviousADDs
   Else,
      Do
      ADDRESS ISPEXEC "VGET (VAREVNME SYS SBS TYPEN) PROFILE"
      ADDRESS ISREDIT ANL#VIEW Y
      Pull Answer
      TYPEN = Word(Answer,1)
      End
   /* Enable the referencing of Endevor libraries */
   ADDRESS ISPEXEC "LIBDEF ISPPLIB DATASET ID(",
           "'YOUR.NDVR.CSIQPENU'",
           "'YOURSITE.YOUR.NDVR.NODES1.ISPP')"
   ADDRESS ISPEXEC "LIBDEF ISPSLIB DATASET ID(",
           "'YOURSITE.YOUR.NDVR.NODES1.ISPS'",
           "'YOUR.NDVR.CSIQSENU')"
   Do 3
      ADDRESS ISPEXEC "DISPLAY PANEL(C1SF1000)"
      If RC > 0 then Exit
      If VAREVNME /= " " & TYPEN /= " " & SYS /= " " & SBS /= " " then,
         Leave
      Say "Please enter missing Env/System/Subsystem/Type fields"
   End
   ADDRESS ISPEXEC "DISPLAY PANEL(ENDIE700)"
   If RC > 0 then Exit
   /* Build ADD Scl Statement */
   EEVGENS1 = "ADD ELEMENT" MEMBER
   EEVGENS2 = "    FROM DSN '"DATASET"'"
   EEVGENS3 = "    TO ENVIRONMENT" VAREVNME "TYPE " TYPEN
   EEVGENS4 = "       SYSTEM     " SYS "SUBSYSTEM  " SBS
   EEVGENS5 = "    OPTIONS CCID  " CTLNBR
   EEVGENS6 = "         COMMENT  '" || DESCRPT1 || "'"
   Options  = " "
   If VARDELIP = 'Y' then Options = "DELETE" Options
   If VARNOGEN = 'N' then Options = "BYPASS GEN PRO" Options
   If VARADDUP = 'Y' then Options = "UPDATE" Options
   If C1SISOFR = 'Y' then Options = "OVERRIDE SIGNOUT" Options
   EEVGENS7    = "   " Options
   Options  = "."
   If VARFPGRP /= ' ' then,
      Options = "PROCESSOR GROUP" VARFPGRP "."
   EEVGENS8    = "   " Options
   ADDRESS ISPEXEC "FTOPEN TEMP"
   ADDRESS ISPEXEC "FTINCL ENDES000"
   ADDRESS ISPEXEC "FTCLOSE " ;
   ADDRESS ISPEXEC "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;
   DEBUG = 'YES' ;
   DEBUG = 'NAW' ;
   IF DEBUG = 'YES' THEN,
      DO
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(&ZTEMPN)"
      ADDRESS ISPEXEC "EDIT DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      END;
   ELSE,
      ADDRESS TSO "SUBMIT '"ZTEMPF"'" ;
   ADDRESS ISPEXEC "VPUT (VAREVNME SYS SBS TYPEN) PROFILE"
   ADDRESS ISPEXEC "VPUT (CTLNBR DESCRPT1) PROFILE"
   ADDRESS ISPEXEC "VPUT (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "
   ADDRESS ISPEXEC "LIBDEF ISPPLIB"
   ADDRESS ISPEXEC "LIBDEF ISPSLIB"
   Call BulidPreviousADDsList
   Exit
ScanPreviousADDs:
   FormerADD  = 'N'
   Do w# = 1 to Words(NDVRLIST)
      previousADD = Word(NDVRLIST,w#)
      prevSpecs   = Translate(previousADD," ","-")
      Element     = Word(prevSpecs,1)
      If Element /= MEMBER then Iterate
      VAREVNME    = Word(prevSpecs,2)
      SYS         = Word(prevSpecs,3)
      SBS         = Word(prevSpecs,4)
      TYPEN       = Word(prevSpecs,5)
      FormerADD  = 'Y'
      previousADDword = w#
      IF Words(prevSpecs) > 5 then,
         VARFPGRP = Word(prevSpecs,6)
      Else,
         VARFPGRP = ""
      Return;
   End
   /* At least try to determine the Type */
   ADDRESS ISREDIT ANL#VIEW Y
   Pull Answer
   TYPEN = Word(Answer,1)
   Return
BulidPreviousADDsList:
   entry = MEMBER"-"VAREVNME"-"SYS"-"SBS"-"TYPEN"-"VARFPGRP
   If FormerADD  = 'Y' then,
      Do
      If entry /= previousADD then,
         NDVRLIST = entry DelWord(NDVRLIST,previousADDword,1)
      End
   Else,
      NDVRLIST = entry NDVRLIST
   /* Just keep howManyToKeep ADD details for now */
   If Words(NDVRLIST) > howManyToKeep then,
      NDVRLIST = DelWord(NDVRLIST,howManyToKeep)
   ADDRESS ISPEXEC "VPUT (NDVRLIST) PROFILE"
   Return
