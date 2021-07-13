/*  REXX  */                                                                    
/* Submit package shipment jobs from entry(ies) on Trigger */                   
                                                                                
   /* If a DDNAME of PULLTGGR is allocated, then Trace */                       
   WhatDDName = 'PULLTGGR'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if Substr(DSNVAR,1,1) /= ' ' then TraceRc = 1;                               
   IF TraceRc = 1 then Trace R                                                  
                                                                                
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
        " HSYSEXEC DB2DSN MODE SHPHLQ STEPLIB",                                 
        " ShipOutput SHLQ ",                                                    
        " AltIDAcctCode AltIDJobClass ",                                        
        " Hostprefix Rmteprefix Transmissn ",                                   
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
      /* Get Endevor Destination Definition */                                  
      /*  for file names and transmission  method */                            
                                                                                
      /*                                                                        
      Do one of these:                                                          
      Call  GetDestinationInfoViaAPI;                                           
         -- or --                                                               
      Call  GetDestinationInfoViaCSV;                                           
      */                                                                        
                                                                                
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
                                                                                
      Notify      = Strip(Substr($tablerec.trg#,Notifypos,8)) ;                 
      if Length(Notify) < 2 then,                                               
         Notify = '&SYSUID'                                                     
                                                                                
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
               Overlay(Jobnbr,$tablerec.trg#,Jobnumberpos);                     
         End                                                                    
      Else,                                                                     
         $tablerec.trg# = Overlay("?",$tablerec.trg#,Stpos) ;                   
      Last_Submit_RC = 0  ;                                                     
                                                                                
   End ;  /* Do trg# = 1 to $tablerec.0 */                                      
                                                                                
   "EXECIO * DISKW TRIGGER (STEM $tablerec. FINIS" ;                            
                                                                                
   Call FreeTriggerFile ;                                                       
                                                                                
   Exit(Submit_RC) ;                                                            
                                                                                
/*                                                                    */        
/* The subroutine below is modified from the TBL#TOOL                 */        
/*                                                                    */        
UPDATE_MODEL_FROM_VARIABLES:                                                    
                                                                                
   Method# = Wordpos(Transmissn,TransmissionMethods) ;                          
   If Method# = 0 then,                                                         
      Do                                                                        
      NewStatus = 'R' ;                                                         
      Return ;                                                                  
      End;                                                                      
   ShipModel = Word(TransmissionModels,Method#);                                
                                                                                
   /* Determine Shipment JCL Model */                                           
   STRING = "ALLOC DD(MODEL) ",                                                 
              " DA('"ModelDSN"("ShipModel")')",                                 
              " SHR REUSE ";                                                    
   sa= 'Destination' Destination 'is' ShipModel                                 
   CALL BPXWDYN STRING;                                                         
   MyResult = RESULT ;                                                          
   If MyResult > 0 then,                                                        
      Do                                                                        
      Say 'Cannot find Shipment Model' ShipModel                                
      Return ;                                                                  
      End;                                                                      
                                                                                
   "EXECIO * DISKR "MODEL "(STEM $Model. FINIS" ;                               
   $delimiter = "µ" ;                                                           
   STRING = "FREE DD(MODEL) "                                                   
   CALL BPXWDYN STRING;                                                         
                                                                                
   Trace off                                                                    
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
                                                                                
      STRING = "ALLOC DD(SYSIN) DUMMY"                                          
      CALL BPXWDYN STRING;                                                      
/*                                                                              
      STRING = "ALLOC DD(SYSPRINT) DUMMY"                                       
      CALL BPXWDYN STRING;                                                      
*/                                                                              
                                                                                
      STRING = "ALLOC DD(SYSUT2)",                                              
                  "SYSOUT(A) WRITER(INTRDR) REUSE " ;                           
      CALL BPXWDYN STRING;                                                      
                                                                                
      ADDRESS LINK 'IEBGENER'                                                   
                                                                                
      "EXECIO * DISKR SYSUT1 (STEM $SUBS. FINIS" ;                              
      "EXECIO * DISKW SYSPRINT (STEM $SUBS. FINIS" ;                            
                                                                                
      STRING = "FREE DD(SYSUT1)"                                                
      CALL BPXWDYN STRING;                                                      
                                                                                
      STRING = "FREE DD(SYSUT2)"                                                
      CALL BPXWDYN STRING;                                                      
                                                                                
      return;                                                                   
                                                                                
AllocateTriggerForUpdate:                                                       
                                                                                
   STRING = "ALLOC DD(TRIGGER)",                                                
              " DA('"TriggerFileName"') OLD REUSE"                              
   seconds = '000007' /* Number of Seconds to wait if needed */                 
                                                                                
   Do Forever  /* or at least until the file is available */                    
      CALL BPXWDYN STRING;                                                      
      MyRC = RC                                                                 
      MyResult = RESULT ;                                                       
      If MyResult = 0 then Leave                                                
      Call WaitAwhile                                                           
   End /* Do Forever */                                                         
                                                                                
   Return ;                                                                     
                                                                                
FreeTriggerFile:                                                                
                                                                                
   STRING = "FREE DD(TRIGGER)"                                                  
   CALL BPXWDYN STRING  ;                                                       
                                                                                
   Return ;                                                                     
                                                                                
/*                                                                    */        
/* Convert Date formats                                               */        
/*                                                                    */        
                                                                                
WaitAwhile:                                                                     
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
  Say "Waiting for" seconds "seconds at " DATE(S) TIME()                        
                                                                                
  /* AOPBATCH and BPXWDYN are IBM programs */                                   
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"                              
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"                              
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"                               
                                                                                
  /* AOPBATCH and BPXWDYN are IBM programs */                                   
  parm = "sleep "seconds                                                        
  Address LINKMVS "AOPBATCH parm"                                               
                                                                                
  Return                                                                        
                                                                                
ProcessTriggerFileHeading :                                                     
/* The subroutine below is modified from the TBL#TOOL                 */        
                                                                                
   $tbl = 1 ;                                                                   
   $TableHeadingChar = '*'                                                      
                                                                                
   $LastWord = Word($tablerec.$tbl,Words($tablerec.$tbl));                      
   If DATATYPE($LastWord) = 'NUM' then,                                         
      Do                                                                        
      Say 'Please remove sequence numbers from the Table'                       
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
      Say 'Invalid table Heading:' $tablerec.$tbl                               
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
                                                                                
GetDestinationInfoViaAPI:                                                       
                                                                                
   /* Set values for Hostprefix and Rmteprefix */                               
   /*     From the site definition             */                               
                                                                                
   /*  Call API to Get Destination information  */                              
                                                                                
                                                                                
   STRING = "ALLOC DD(BSTAPI)   SYSOUT(J) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(BSTERR)   SYSOUT(J) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(APIMSGS) LRECL(133) BLKSIZE(13300) ",                     
              " DSORG(PS) ",                                                    
              " SPACE(1,1) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(APILIST) LRECL(2048) BLKSIZE(22800) ",                    
              " DSORG(PS) ",                                                    
              " SPACE(1,1) RECFM(V,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   /*  Call API to Get Destination information  */                              
   parm =    Left(Destination'*',7)                                             
                                                                                
/*                                                                              
   ADDRESS TSO "CALL *(APIALDST) '"||parm||"'"                                  
*/                                                                              
                                                                                
   ADDRESS LINKMVS "APIALDST parm"                                              
   RETURN_RC = RC ;                                                             
   If RETURN_RC > 0 then,                                                       
      DO                                                                        
      SA= 'CANNOT GET INFORMATION FROM ENDEVOR' ;                               
      EXIT                                                                      
      END ;                                                                     
   "EXECIO * DISKR APILIST ( Stem apiDestinations. FINIS"                       
   Sa= 'Messages from PULLTGGR:'                                                
   Hostprefix = Strip(Substr(apiDestinations.1,079,14))                         
   Rmteprefix = Strip(Substr(apiDestinations.1,113,14))                         
   Transmissn = Strip(Substr(apiDestinations.1,051,11))                         
   TARGnode   = Strip(Substr(apiDestinations.1,062,08))                         
                                                                                
   STRING = "FREE  DD(APILIST)"                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(APIMSGS)"                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(BSTAPI) "                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(BSTERR) "                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return ;                                                                     
                                                                                
GetDestinationInfoViaCSV:                                                       
                                                                                
   /* Set values for Hostprefix and Rmteprefix */                               
   /*     From the site definition             */                               
                                                                                
   /*  Call CSV to Get Destination information  */                              
                                                                                
   STRING = "ALLOC DD(C1MSGS1) DUMMY "                                          
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTERR) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTAPI) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(CSVDEST) LRECL(4000) BLKSIZE(32000) ",                    
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",                       
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   Push  "LIST DESTINATION '"Destination"'",                                    
         " TO FILE CSVDEST OPTIONS ."                                           
                                                                                
   "EXECIO 1 DISKW BSTIPT01 (FINIS ";                                           
                                                                                
   ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */                         
   call_rc = rc ;                                                               
/* ADDRESS TSO  'ISRDDN' */                                                     
                                                                                
  "EXECIO * DISKR CSVDEST (STEM API. finis"                                     
                                                                                
   STRING = "FREE DD(CSVDEST)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTIPT01)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS1)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTERR)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTAPI)" ;                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
  IF API.0 < 2 THEN,                                                            
     Do                                                                         
     Say 'Cannot find Definition for Destination' Destination                   
     EXIT(12)                                                                   
     End                                                                        
                                                                                
  $table_variables= Strip(API.1,'T')                                            
                                                                                
  $table_variables = translate($table_variables,"_"," ") ;                      
  $table_variables = translate($table_variables," ",',"') ;                     
  $table_variables = translate($table_variables,"@","/") ;                      
  $table_variables = translate($table_variables,"@",")") ;                      
  $table_variables = translate($table_variables,"@","(") ;                      
                                                                                
  Do rec# = 2 to API.0                                                          
     $detail = API.rec#                                                         
                                                                                
     /* Parse the Detail record until done */                                   
     Do $column =  1 to Words($table_variables)                                 
        Call ParseDetailCSVline                                                 
     End                                                                        
                                                                                
     Sa= 'Messages from PULLTGGR:'                                              
     Hostprefix = HOST_DSN_PREFIX                                               
     Rmteprefix = REMOTE_DSN_PREFIX                                             
     Transmissn = TRANS_DESC                                                    
     TARGnode   = TRANS_NODE                                                    
  End; /* Do rec# = 1 to API.0 */                                               
                                                                                
  RETURN ;                                                                      
                                                                                
ParseDetailCSVline:                                                             
                                                                                
  /* Find the data for the current $column */                                   
                                                                                
  $dlmchar = Substr($detail,1,1);                                               
                                                                                
  If $dlmchar = "'" then,                                                       
     Do                                                                         
     SA= 'parsing with single quote '                                           
     PARSE VAR $detail "'" $temp_value "'" $detail ;                            
     If Substr($detail,1,1) = ',' then,                                         
        $detail = Strip(Substr($detail,2),'L')                                  
     End                                                                        
  Else,                                                                         
  If $dlmchar = '"' then,                                                       
     Do                                                                         
     SA= 'parsing with double quote '                                           
     PARSE VAR $detail '"' $temp_value '"' $detail ;                            
     If Substr($detail,1,1) = ',' then,                                         
        $detail = Strip(Substr($detail,2),'L')                                  
     End                                                                        
  Else,                                                                         
  If $dlmchar = ',' then,                                                       
     Do                                                                         
     SA= 'parsing with comma        '                                           
     PARSE VAR $detail ',' $temp_value ',' $detail ;                            
     If Substr($detail,1,1)/= ',' then,                                         
        $detail = "," || $detail                                                
        $detail = Strip(Substr($detail,2),'L')   */                             
     End                                                                        
  Else,                                                                         
  If Words($detail) = 0 then,                                                   
     $temp_value = ' '                                                          
  Else,                                                                         
     Do                                                                         
     SA= 'parsing with comma        '                                           
     PARSE VAR $detail $temp_value ',' $detail ;                                
     Sa= '$temp_value=>' $temp_value '<'                                        
     End                                                                        
  $temp_value = STRIP($temp_value) ;                                            
  $rslt = $temp_value                                                           
  $rslt = Strip($rslt,'B','"')                             ;                    
  $rslt = Strip($rslt,'B',"'")                             ;                    
  if Length($rslt) < 1 then $rslt = ' '                                         
  if Length($rslt) < 250 then,                                                  
     $temp = WORD($table_variables,$column) '= "'$rslt'"';                      
  Else,                                                                         
     $temp = WORD($table_variables,$column) "=$rslt"                            
  INTERPRET $temp;                                                              
  If rec# < 3 then Say $temp                                                    
                                                                                
  RETURN ;                                                                      
                                                                                
