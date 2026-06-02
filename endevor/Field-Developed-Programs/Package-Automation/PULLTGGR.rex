/*  REXX                                                             */
/*                                                                   */
/*      https://github.com/BroadcomMFD/broadcom-product-scripts      */
/*                                                                   */
/* This rexx is a called subroutine.                                 */
/* It can be called by PKGESHIP during exit processing, or           */
/* by a package Sweep job. (See SWEEPJOB) .                          */
/*                                                                   */
/* From data in SHIPRULE, BILDTGGR updates the Trigger file          */
/* for each expected shipment. PULLTGGR submits package ship jobs.   */
/*                                                                   */
   Trace r
   /* If a DDNAME of PULLTGGR is allocated, then Trace */
   CALL BPXWDYN "INFO FI(PULLTGGR) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then TraceRc = 1;
   /* If a DDNAME of ISPPLIB  is allocated, we are in foreground */
   CALL BPXWDYN "INFO FI(ISPPLIB)  INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if RESULT = 0 then runMode = 'FORE'
   Else               runMode = 'BACK'
/* PkgExecJobname = MVSVAR('SYMDEF',JOBNAME )   Returns JOBNAME */
/* Variable settings for each site --->           */
   WhereIam =  WHERE@M1()
   interpret 'Call' WhereIam "'MyCLS2Library'"
   MyCLS2Library = Result
   Say 'Running PULLTGGR in' MyCLS2Library
   interpret 'Call' WhereIam "'TriggerFileName'"
   TriggerFileName = Result
   interpret 'Call' WhereIam "'MyAUTULibrary'"
   MyAUTULibrary = Result
   interpret 'Call' WhereIam "'MyHomeAddress'"
   MyHomeAddress = Result
   interpret 'Call' WhereIam "'MyAUTHLibrary'"
   MyAUTHLibrary = Result
   interpret 'Call' WhereIam "'MyLOADLibrary'"
   MyLOADLibrary = Result
   interpret 'Call' WhereIam "'MyDATALibrary'"
   MyDATALibrary = Result
   ShipRules       = MyDATALibrary"(SHIPRULE)"
   interpret 'Call' WhereIam "'MyOPT2Library'"
   MyOPT2Library = Result
   interpret 'Call' WhereIam "'MyOPTNLibrary'"
   MyOPTNLibrary = Result
   interpret 'Call' WhereIam "'MySENULibrary'"
   MySENULibrary = Result
   interpret 'Call' WhereIam "'MySEN2Library'"
   MySEN2Library = Result
   interpret 'Call' WhereIam "'AltIDOrderfile'"
   AltIDOrderfile= Result
   interpret 'Call' WhereIam "'MyCLS0Library'"
   MyCLS0Library  = Result
   interpret 'Call' WhereIam "'MyCLS2Library'"
   MyCLS2Library  = Result
   interpret 'Call' WhereIam "'AltIDAcctCode'"
   AltIDAcctCode = Result
   interpret 'Call' WhereIam "'AltIDJobClass'"
   AltIDJobClass = Result
   interpret 'Call' WhereIam "'TransmissionMethods'"
   TransmissionMethods  = Result
   interpret 'Call' WhereIam "'TransmissionModels'"
   TransmissionModels   = Result
   interpret 'Call' WhereIam "'SHLQ'"
   SHLQ = Result
   sa= 'TransmissionMethods =' TransmissionMethods
   sa= 'TransmissionModels  =' TransmissionModels
/* <---- Variable settings for each site          */
   Arg DSN_Prefix ModelDSN . ;
   DSN_Prefix = Strip(DSN_Prefix,'B',',') ;
   ModelDSN   = Strip(ModelDSN,'B',',') ;
   ModelDSN   = Strip(ModelDSN)
   Sa= "DSN_Prefix =" DSN_Prefix
   Sa= "ModelDSN =" ModelDSN
   Jobnbr = '   '
/*                                                                    */
/* This Rexx participates in the submission of Endevor Package        */
/* Shipment jobs. It is called by the Endevor sweep job.              */
/*                                                                    */
/*                                                                    */
/* Allocate and prepare files for TBL#TOOL execution                  */
/*                                                                    */
/*                                                                    */
   Submit_RC = 0  ;
   Last_Submit_RC = 0  ;
   TodaysDate = DATE('S') ;
   NOW  = TIME(L);
   HOUR = SUBSTR(NOW,1,2) ;
   IF HOUR = '00' THEN HOUR = '0'
   MINUTE = SUBSTR(NOW,4,2) ;
   CurrentTime= HOUR || MINUTE ;
   SENDNODE =  MVSVAR(SYSNAME)
   HSYSEXEC = MyCLS2Library
   Userid = USERID()
   Call AllocateTriggerForUpdate ;
   "EXECIO * DISKR TRIGGER (STEM $tablerec. FINIS" ;
   /* Build all the ...pos variables from heading */
   Call ProcessTriggerFileHeading;
/*                                                                    */
   $All_VARIABLES = $table_variables,
        " PkgExecJobname ParmVal",
        " Jobname Userid Date8 Date6 Time8 Time6 Destination",
        " MyCLS0Library MyCLS2Library MyHomeAddress",
        " MyAUTULibrary MyAUTHLibrary MyLOADLibrary ",
        " MyOPT2Library MyOPTNLibrary MySEN2Library MySENULibrary",
        " AltIDOrderfile",
        " HSYSEXEC DB2DSN MODE SHPHLQ STEPLIB",
        " ShipOutput SHLQ ",
        " AltIDAcctCode AltIDJobClass ",
        " Hostprefix Rmteprefix Transmissn ",
        " HOSTHLQ    RMOTHLQ    XMITMETH   ",
        " Destin VNBLSDST SENDNODE Typrun Notify TARGnode "
/*                                                                    */
   Do trg# = 1 to $tablerec.0
      status      = Substr($tablerec.trg#,Stpos,1) ;
      If status /= "_" & status /= " " &,
         status /= "B"                 then iterate;
      ShipOutput = 'OUT'
      If status  = "B" then ShipOutput = 'BAC' ;
      Package     = Substr($tablerec.trg#,Packagepos,16) ;
      System      = Strip(Substr($tablerec.trg#,Systempos,08));
      Destination = Strip(Substr($tablerec.trg#,Destinationpos,08));
      Date        = Substr($tablerec.trg#,Datepos,08) ;
      IF Date > TodaysDate then iterate ;
      Time        = Substr($tablerec.trg#,Timepos,04) ;
      IF Date = TodaysDate &,
         Time > CurrentTime then iterate ;
      Call  GetDestinationInfoViaCSV;
      Jobname     = Strip(Substr($tablerec.trg#,Jobnamepos,08)) ;
      If Jobname  = 'useridX' then Jobname = USERID() || 'X'
      PkgExecJobname = Jobname ;
/*
      OwnerMask   = Strip(Substr($tablerec.trg#,OwnerMaskpos,08)) ;
      QualifierMask =,
         Strip(Substr($tablerec.trg#,QualifierMaskpos,08)) ;
      BindPackageMask =,
         Strip(Substr($tablerec.trg#,BindPackageMaskpos,08)) ;
      PathMask =,
         Strip(Substr($tablerec.trg#,PathMaskpos,08)) ;
*/
      TYPRUN      = Strip(Substr($tablerec.trg#,TYPRUNpos,6)) ;
      if Length(Typrun) > 0 then,
         Typrun = ',TYPRUN='Typrun
/*
      Notify      = Strip(Substr($tablerec.trg#,Notifypos,8)) ;
      if Length(Notify) < 2 then,
         Notify = '&SYSUID'
*/
      seconds = '000001' /* Wait 1 second before submitting next*/
      Call WaitAwhile ;
      Date8  = DATE('S')
      Date6  = substr(Date8,3);
      Temp   = TIME('L')
      Time8  = Substr(Temp,1,2) ||,
               Substr(Temp,4,2) ||,
               Substr(Temp,7,2) ||,
               Substr(Temp,10,2) ;
      Time6  = Substr(Temp,1,2) ||,
               Substr(Temp,4,2) ||,
               Substr(Temp,7,2) ;
      ParmVal = Date8 Time8
      NewStatus = 's' ;
      Call UPDATE_MODEL_FROM_VARIABLES ; /* Submits Shipment job */
      $headingVariable = 'St'
      pos= $Starting_$position.$headingVariable
      if Last_Submit_RC = 0 then,
         Do
         $tablerec.trg# = Overlay(NewStatus,$tablerec.trg#,Stpos) ;
         $tablerec.trg# = ,
            Overlay(CurrentTime,$tablerec.trg#,Timepos) ;
         pos= $Starting_$position.$headingVariable
         If Substr(Jobnbr,1,1) > ' ' then,
            $tablerec.trg# = ,
               Overlay(Jobnbr,$tablerec.trg#,Jobnumbpos);
         End
      Else,
         $tablerec.trg# = Overlay("?",$tablerec.trg#,Stpos) ;
      Last_Submit_RC = 0  ;
   End ;  /* Do trg# = 1 to $tablerec.0 */
   "EXECIO * DISKW TRIGGER (STEM $tablerec. FINIS" ;
   Call FreeTriggerFile ;
   if TraceRc = 1 then Say "PULLTGGR- exiting....  "
   Exit(Submit_RC) ;
/*                                                                    */
/* The subroutine below is modified from the TBL#TOOL                 */
/*                                                                    */
UPDATE_MODEL_FROM_VARIABLES:
   if TraceRc = 1 then Say "UPDATE_MODEL_FROM_VARIABLES:      "
   Sa= "UPDATE_MODEL_FROM_VARIABLES:       "
   Method# = Wordpos(Transmissn,TransmissionMethods) ;
   If Method# = 0 then,
      Do
      NewStatus = 'R' ;
      Return ;
      End;
   /* If Destination has its own model, use it      */
   /* Otherwise, use the one from TransmissionModels*/
   ShipModel = Word(TransmissionModels,Method#);
   interpret 'Call' WhereIam "'UseModel."Destination"'"
   OverRideModel   = Result
   If OverRideModel /= '' &,
      Substr(OverRideModel,1,09) /= 'UseModel.' then,
      ShipModel = OverRideModel
   /* Determine Shipment JCL Model */
   STRING = "ALLOC DD(MODEL) ",
              " DA('"ModelDSN"("ShipModel")')",
              " SHR REUSE ";
   sa= 'Destination' Destination 'is' ShipModel
   CALL BPXWDYN STRING;
   MyResult = RESULT ;
   If MyResult > 0 then,
      Do
      Say 'PULLTGGR- Cannot find Shipment Model' ShipModel
      Return ;
      End;
   "EXECIO * DISKR "MODEL "(STEM $Model. FINIS" ;
   $delimiter = "|" ;
   STRING = "FREE DD(MODEL) "
   CALL BPXWDYN STRING;
   DO $LINE = 1 TO $Model.0
      $PLACE_VARIABLE = 1;
      CALL EVALUATE_SYMBOLICS ;
   END; /* DO $LINE = 1 TO $Model.0 */
   IF TraceRc = 1 then Trace R
   CALL BPXWDYN ,
    "ALLOC DD(SYSUT1) LRECL(80) BLKSIZE(27920) SPACE(5,5) ",
           " RECFM(F,B) TRACKS ",
           " NEW UNCATALOG REUSE ";
   "EXECIO * DISKW SYSUT1 (STEM $Model. FINIS" ;
   Call Submit_Job ;
   Drop $Model. ;
   RETURN;
/*                                                                    */
/* The subroutine below is borrowed from the TBL#TOOL                 */
/*                                                                    */
EVALUATE_SYMBOLICS:
   if TraceRc = 1 then Say "EVALUATE_SYMBOLICS:               "
   DO FOREVER;
      $PLACE_VARIABLE = POS('&',$Model.$LINE,$PLACE_VARIABLE)
      IF $PLACE_VARIABLE = 0 THEN LEAVE;
      $temp_$LINE = TRANSLATE($Model.$LINE,' ',',.()"/\+-*|');
      $temp_$LINE = TRANSLATE($temp_$LINE,' ',"'"$delimiter);
      $table_word = WORD(SUBSTR($temp_$LINE,($PLACE_VARIABLE+1)),1);
      $table_word = TRANSLATE($table_word,'_','-') ;
      $varlen = LENGTH($table_word) + 1 ;
      if WORDPOS($table_word,$All_VARIABLES) = 0 then,
         do
         $PLACE_VARIABLE = $PLACE_VARIABLE + 1 ;
         iterate;
         end;
      $temp_word = VALUE($table_word) ;
      IF DATATYPE($temp_word,S) = 9 THEN,
         $temp = 'SYMBVALUE = ' $temp_word ;
      ELSE,
         $temp = "SYMBVALUE = '"$temp_word"'" ;
      IF TraceRc = 1 then say $temp
      INTERPRET $temp;
      SA= 'SYMBVALUE  = ' SYMBVALUE ;
      $tail = SUBSTR($Model.$LINE,($PLACE_VARIABLE+$varlen)) ;
      if Substr($tail,1,1) = $delimiter then,
         $tail = SUBSTR($tail,2) ;
      IF $PLACE_VARIABLE > 1 THEN,
         $Model.$LINE = ,
            SUBSTR($Model.$LINE,1,($PLACE_VARIABLE-1)) ||,
            SYMBVALUE || $tail ;
      else,
         $Model.$LINE = ,
            SYMBVALUE || $tail ;
      END; /* DO FOREVER */
   RETURN;
Submit_Job:
   if TraceRc = 1 then Say "Submit_Job:                       "
   CALL BPXWDYN "ALLOC DD(SHOWJCL) SYSOUT(A) "
   "Execio * DISKR SYSUT1   ( Stem jcl. finis"
   "Execio * DISKW SHOWJCL  ( Stem jcl. finis"
   STRING = "ALLOC DD(SUBMIT)",
               "SYSOUT(A) WRITER(INTRDR) REUSE " ;
   CALL BPXWDYN STRING;
   "Execio * DISKW SUBMIT   ( Stem jcl. finis"
   CALL BPXWDYN "FREE DD(SHOWJCL)"
   CALL BPXWDYN "FREE DD(SUBMIT)"
   CALL BPXWDYN "FREE DD(SYSUT1)"
   RETURN;
AllocateTriggerForUpdate:
   if TraceRc = 1 then Say "AllocateTriggerForUpdate:         "
   STRING = "ALLOC DD(TRIGGER)",
              " DA('"TriggerFileName"') OLD REUSE"
   seconds = '000001' /* Number of Seconds to wait if needed */
   Do Forever  /* or at least until the file is available */
      CALL BPXWDYN STRING;
      MyRC = RC
      MyResult = RESULT ;
      If MyResult = 0 then Leave
      Call WaitAwhile
   End /* Do Forever */
   Return ;
FreeTriggerFile:
   if TraceRc = 1 then Say "AllocateTriggerForUpdate:         "
   STRING = "FREE DD(TRIGGER)"
   CALL BPXWDYN STRING  ;
   Return ;
/*                                                                    */
/* Convert Date formats                                               */
/*                                                                    */
WaitAwhile:
   if TraceRc = 1 then Say "WaitAwhile: " seconds
  /*                                                               */
  /* A resource is unavailable. Wait awhile and try                */
  /*   accessing the resource again.                               */
  /*                                                               */
  /*   The length of the wait is designated in the parameter       */
  /*   value which specifies a number of seconds.                  */
  /*   A parameter value of '000003' causes a wait for 3 seconds.  */
  /*                                                               */
  seconds = Abs(seconds)
  seconds = Trunc(seconds,0)
  If runMode = 'BACK' | TraceRc = 1 then,
     Say "PULLTGGR- Waiting for" seconds "seconds at " DATE(S) TIME()
  /* AOPBATCH and BPXWDYN are IBM programs */
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"
  /* AOPBATCH and BPXWDYN are IBM programs */
  parm = "sleep "seconds
  Address LINKMVS "AOPBATCH parm"
  Return
ProcessTriggerFileHeading :
   if TraceRc = 1 then Say "ProcessTriggerFileHeading : "
/* The subroutine below is modified from the TBL#TOOL                 */
   $tbl = 1 ;
   $TableHeadingChar = '*'
   $LastWord = Word($tablerec.$tbl,Words($tablerec.$tbl));
   If DATATYPE($LastWord) = 'NUM' then,
      Do
      Say 'PULLTGGR- Please remove sequence numbers from the Table'
      Exit(12)
      End
   $tmprec = Substr($tablerec.$tbl,2) ;
   $PositionSpclChar = POS('-',$tmprec) ;
   If $PositionSpclChar = 0 then,
      $PositionSpclChar = POS('*',$tmprec) ;
   $tmpreplaces = '-,.'$TableHeadingChar ;
   $tmprec = TRANSLATE($tmprec,' ',$tmpreplaces);
   $table_variables = strip($tmprec);
   $Heading_Variable_count = WORDS($table_variables) ;
   If $Heading_Variable_count /=,
      Words(Substr($tablerec.$tbl,2)) then,
      Do
      Say 'PULLTGGR- Invalid table Heading:' $tablerec.$tbl
      exit(12)
      End
   $heading = Overlay(' ',$tablerec.$tbl,1); /* Space leading * */
   Do $pos = 1 to $Heading_Variable_count
      $HeadingVariable = Word($table_variables,$pos) ;
      $tmp = Wordindex($Heading,$pos) ;
      $Starting_$position.$HeadingVariable = $tmp
      $tmp = $tmp + Length(Word($Heading,$pos)) -1 ;
      $Ending_$position.$HeadingVariable = $tmp
      /* Build ...pos variables and values */
      tmp = ""$HeadingVariable"pos =",
             $Starting_$position.$HeadingVariable
      Sa= tmp
      Interpret tmp
   end; /* DO $pos = 1 to $Heading_Variable_count */
   $Heading = Translate($Heading,' ','-*')
   Return ;
GetDestinationInfoViaCSV:
   if TraceRc = 1 then Say "GetDestinationInfoViaCSV:   "
   Hostprefix  = "?"
   Rmteprefix  = "?"
   Transmissn  = "?"
   TARGnodeix  = "?"
   /* Set values for Hostprefix and Rmteprefix */
   /*     From the site definition             */
   /*  Call CSV to Get Destination information  */
   SiteVariables = GTDESTIN(Destination)
   If Words(SiteVariables) < 3 then Return
   Hostprefix  = Word(SiteVariables,1)
   Rmteprefix  = Word(SiteVariables,2)
   Transmissn  = Word(SiteVariables,3)
   TARGnode    = Word(SiteVariables,4)
   Return
