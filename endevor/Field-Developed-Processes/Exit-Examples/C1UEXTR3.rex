/*           rexx         */

   If USERID() /= 'XALJO11' then Exit

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

   /* References to external data (Dyanamically allocated)          */
   TableLib = 'SYSDE32.NDVR.TEAM.TABLES'      /* Table named        */
   TableMbr = 'C1UEXTR3'
   ModelLib = 'SYSDE32.NDVR.TEAM.MODELS'      /* JCL and SCL models */
   ModelMbr = ' multiple members are assigned'
   OptnsLib = 'SYSDE32.NDVR.TEAM.OPTIONS'     /* overrides info     */
   LreclxType = 'SYSDE32.NDVR.TEAM.OPTIONS'   /* where is LRECLS    */
   LreclMbr = 'LRECLS'
   WorkLibPfx = 'PUBLIC'                      /* Prefix for RET/ADD */
   StopDDname = 'ZZZZZZZZ'

   /* If StopDDname is allocated, stop here.               */
   CALL BPXWDYN "INFO FI("StopDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then Exit

   Sa= 'Running (C1UEXTR3)'

   /* If C1UEXTR3 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR3'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then TraceRc = 'Y'
   if TraceRc = 'Y' then Trace ?r

   Sa= 'You called SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX(C1UEXTR3) '

   Arg Parms
   Parms = Strip(Parms)
   sa= 'Parms len=' Length(Parms)

   /* Parms from C1UEXT02 is a string of REXX statements   */
   Interpret Parms

   /* Allow Trace be manually turned off, then automatically on here */
   if TraceRc = 'Y' then Trace ?r

   GoForThese = 'ADD UPDATE GENERATE MOVE TRANSFER'
   GoForThese = '           GENERATE MOVE TRANSFER DELETE'
   sa= ECB_ACTION_NAME
   If Wordpos(ECB_ACTION_NAME,GoForThese) = 0 then exit
   If (ECB_ACTION_NAME = 'ADD     ' | ECB_ACTION_NAME = 'UPDATE  ') &,
       REQ_BYPASS_GEN_PROC = 'Y' then exit

   Date8  = DATE('S')
   Date7  = 'D' || Substr(Date8,3)
   Temp   = TIME('L')

   Time7  = 'T' ||,
            Substr(Temp,1,2) ||,
            Substr(Temp,4,2) ||,
            Substr(Temp,7,2) ||,
            Substr(Temp,10,1) ;

   If TGT_ENV_STAGE_ID   > ' ' then,
      Do
      C1Stage  = TGT_ENV_STAGE_NAME
      C1Envmnt = Strip(TGT_ENV_ENVIRONMENT_NAME)
      C1System = Strip(TGT_ENV_SYSTEM_NAME)
      C1ElType = Strip(TGT_ENV_TYPE_NAME)
      C1Element= Strip(TGT_ENV_ELEMENT_NAME)
      End
   Else,
      Do
      C1Stage  = SRC_ENV_STAGE_NAME
      C1Envmnt = Strip(SRC_ENV_ENVIRONMENT_NAME)
      C1System = Strip(SRC_ENV_SYSTEM_NAME)
      C1ElType = Strip(SRC_ENV_TYPE_NAME)
      C1Element= Strip(SRC_ENV_ELEMENT_NAME)
      End

   /* Library name to be used for RETRIEVE/ADD/UPDATE actions  */
   SCLDsn = WorkLibPfx'.'Date7'.'Time7'.'C1ElType'.'C1Element

/*                                                                    */
/* Each Endevor Type can have its own source length (Lrecl).          */
/* Data must be already collected into this input for those lengths   */
/* that are not 0080. Anything not included is assumed to be 0080.    */
/*                                                                    */
   STRING = 'ALLOC DD(LRECLS) ',
            "DA("LreclxType"("LRECLMbr")) SHR REUSE "
   CALL BPXWDYN STRING;
   "EXECIO * DISKR LRECLS (Stem lrecls. Finis"
   CALL BPXWDYN "FREE DD(LRECLS)" ;
   Do lr# = 1 to lrecls.0
      if TraceRc = 'Y' then say lrecls.lr#
      interpret lrecls.lr#
   End;
   thisLrecl = lrecl.C1Envmnt.2.C1System.C1Eltype

/*                                                                    */
/* OPTIONS give values for variables found in MODELS                  */
/*                                                                    */
   STRING = "ALLOC DD(OPTIONS) LRECL(80) BLKSIZE(27920) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   QUEUE " $nomessages = 'Y' " ;
   QUEUE " SCLDsn = '"SCLDsn"'" ;
   QUEUE " thisLrecl =" thisLrecl
   /* Replicate most Parms into OPTIONS */
   where = 1
   WantOptsFor = 'ECB_ REQ_ TGT_ TGT_ SRC_'
   Do Forever
      newwhere = Pos(';',Parms,where)
      if newwhere = 0 then leave
      thisOpt = Strip(Substr(Parms,where,newwhere-where))
      thisOptPrefix = Substr(thisOpt,1,4)
      If Wordpos(thisOptPrefix,WantOptsFor) > 0 &,
         Substr(thisOpt,Length(thisOpt)) = '"'  then,
         Queue thisOpt
      Else,
         If TraceRc = 'Y' then say 'Skipping' thisOpt
      where = newwhere + 1
   End
   QUEUE "  Userid  = '"USERID()"'" ;
   JobName = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */
   JobName = Left(JobName || 'EEEEEEE',8)
   QUEUE "  JobName = '"JobName"'"
   QUEUE "  C1Stage  = '"C1Stage"'"
   QUEUE "  C1System = '"C1System"'"
   QUEUE "  C1ElType = '"C1ElType"'"
   QUEUE "  C1Element= '"C1Element"'"

   QUEUE "  x = BuildFromMODEL(LOCALJCL)"
   QUEUE "  x = BuildFromMODEL(LOCALSCL)"
   QUEUE "  x = BuildFromMODEL("StopDDname")"
/*                                                                    */
/* The Remote site can assign specific values as needed       l       */
/*                                                                    */
   STRING = 'ALLOC DD(OVERIDES) ',
            "DA("OptnsLib"(OVERIDES)) SHR REUSE "
   CALL BPXWDYN STRING;
   QUEUE "  x = IncludeQuotedOptions(OVERIDES) "

   QUEUE "  x = BuildFromMODEL(REMOTJCL)"
   QUEUE "  x = BuildFromMODEL(REMOTSCL)"
   QUEUE "  x = BuildFromMODEL("StopDDname")"
   QUEUE "  $SkipRow = 'Y'              "

   if TraceRc = 'Y' then Trace ?r
   "EXECIO " QUEUED() "DISKW OPTIONS (FINIS"

/*                                                                    */
/* StopDDname causes submitted jobs to now submit more jobs           */

   STRING = "ALLOC DD("StopDDname") LRECL(80) BLKSIZE(27920) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   QUEUE "//"StopDDname "DD DUMMY"
   "EXECIO 1 DISKW" StopDDname " (FINIS"

/*                                                                    */
/* TBLOUT is assigned to a temporary dataset to receive the jcl       */
/*                                                                    */
   STRING = "ALLOC DD(TBLOUT) LRECL(80) BLKSIZE(27920) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";

   CALL BPXWDYN STRING;

/*                                                                    */
/* TABLE is fixed by Endevor administrators                           */
/*                                                                    */
   STRING = 'ALLOC DD(TABLE) ',
            "DA("TableLib"("TableMbr")) SHR REUSE "
   CALL BPXWDYN STRING;

/*                                                                    */
/* The Model depends upon the Element Action that was performed       */
/* Models will be a @MD* members of SYSDE32.NDVR.TEAM.PARM            */
/*                                                                    */
   STRING = 'ALLOC DD(LOCALJCL)',
            "DA("ModelLib"(@LOCNDVR)) SHR REUSE "
   CALL BPXWDYN STRING;
/*                                                                    */
   ModelMbr = '@LOCGENR'
   STRING = 'ALLOC DD(LOCALSCL)',
            "DA("ModelLib"("ModelMbr")) SHR REUSE "
   CALL BPXWDYN STRING;
/*                                                                    */
   STRING = 'ALLOC DD(REMOTJCL)',
            "DA("ModelLib"(@RMTNDVR)) SHR REUSE "
   CALL BPXWDYN STRING;
/*                                                                    */
   ModelMbr = '@RMTGENR'
   STRING = 'ALLOC DD(REMOTSCL)',
            "DA("ModelLib"("ModelMbr")) SHR REUSE "
   CALL BPXWDYN STRING;
/*                                                                    */
   STRING = "ALLOC DD(NOTHING) DUMMY"
   CALL BPXWDYN STRING;

/*                                                                    */
/* Now call ENBPIU00 which does the rest                              */
/*                                                                    */
   "ENBPIU00 1" C1System C1Stage ECB_ACTION_NAME
   my_rc = RC

   "EXECIO 0 DISKW TBLOUT (FINIS"

   "EXECIO * DISKR TBLOUT (STEM EXECJCL. FINIS "

   CALL BPXWDYN "FREE DD(MODEL)"
   CALL BPXWDYN "FREE DD(TABLE)"
   CALL BPXWDYN "FREE DD(NOTHING)"
   CALL BPXWDYN "FREE DD(LOCALJCL)"
   CALL BPXWDYN "FREE DD(LOCALSCL)"
   CALL BPXWDYN "FREE DD(REMOTJCL)"
   CALL BPXWDYN "FREE DD(REMOTSCL)"
   CALL BPXWDYN "FREE DD(OVERIDES)"
   CALL BPXWDYN "FREE DD("StopDDname")"

   if TraceRc /= 'Y' | ECB_TSO_BATCH_MODE = 'B' then,
      Do
      CALL BPXWDYN "FREE DD(OPTIONS)" ;
      CALL BPXWDYN "FREE DD(TBLOUT)" ;
      End

   If my_rc > 0 then Exit

   "Execio * DISKW SYSPRINT ( Stem EXECJCL. finis"

   STRING = "ALLOC DD(SUBMIT)",
               "SYSOUT(A) WRITER(INTRDR) REUSE " ;
   CALL BPXWDYN STRING;
   "Execio * DISKW SUBMIT   ( Stem EXECJCL. finis"

   CALL BPXWDYN "FREE DD(SUBMIT)" ;

   Exit

