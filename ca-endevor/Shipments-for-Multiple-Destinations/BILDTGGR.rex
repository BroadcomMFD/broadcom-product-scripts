/*  REXX  */                                                                    
/* From Rules info, update Trigger file for each expected shipment */           
                                                                                
   /* If a DDNAME of BILDTGGR is allocated, then Trace */                       
   WhatDDName = 'BILDTGGR'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if Substr(DSNVAR,1,1) /= ' ' then TraceRc = 1;                               
   IF TraceRc = 1 then Trace R                                                  
                                                                                
/* Variable settings for each site --->           */                            
   /* Determine the DSORG for TriggerFileNAme     */                            
   /* x = LISTDSI("'"TriggerFileName"'" RECALL ); */                            
   TriggerFileDsorg = 'PS' ;     /* VS / PS .... */                             
                                                                                
   WhereIam =  WHERE@M1()                                                       
                                                                                
   interpret 'Call' WhereIam "'MyCLS2Library'"                                  
   MyCLS2Library = Result                                                       
   Say 'Running BILDTGGR in' MyCLS2Library                                      
                                                                                
   interpret 'Call' WhereIam "'TriggerFileName'"                                
   TriggerFileName = Result                                                     
                                                                                
   interpret 'Call' WhereIam "'MyDATALibrary'"                                  
   MyDATALibrary = Result                                                       
   ShipRules       = MyDATALibrary"(SHIPRULE)"                                  
                                                                                
   interpret 'Call' WhereIam "'MySEN2Library'"                                  
   MySEN2Library = Result                                                       
/* <---- Variable settings for each site          */                            
                                                                                
/*                                                                    */        
/* This Rexx creates Trigger entrires for a package just executed.    */        
/* It is called by the Endevor exit program C1UEXT07   */                       
/*                                                                    */        
/*                                                                    */        
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
   /* Do not allow the Trace to start until after the allocation                
      above for SYSTSPRT.                                                       
   */                                                                           
                                                                                
   ARG Parms ;                                                                  
                                                                                
/* if called by zowe, then this  is  the Argument ....   */                     
   If Length(Parms) < 18 then,                                                  
      Do                                                                        
      Package = Translate(Parms,' ',"'")                                        
      Package = Strip(Package)                                                  
      Say Length(Package) Package                                               
      End /* If Length(Parms) < 18 */                                           
   Else                                                                         
      Do                                                                        
      /* if called by exit, then these are the Arguments.... */                 
      Notes.7  = Substr(PARMS,414,60) ;                                         
      If Substr(Notes.7,1,5) = 'TRACE' then Trace r                             
      Package = Substr(PARMS,1,16) ;                                            
/*  No longer attempting to leverage promotion packages                         
      Environ = Substr(PARMS,18,08) ;                                           
     pkgStage = Substr(PARMS,27,01) ; */                                        
      CREATE_USER = Substr(PARMS,29,08) ;                                       
      UPDATE_USER = Substr(PARMS,37,08) ;                                       
      CAST_USER = Substr(PARMS,45,08) ;                                         
      Notes.1  = Substr(PARMS,054,60) ;                                         
      Notes.2  = Substr(PARMS,114,60) ;                                         
      Notes.3  = Substr(PARMS,174,60) ;                                         
      Notes.4  = Substr(PARMS,234,60) ;                                         
      Notes.5  = Substr(PARMS,294,60) ;                                         
      Notes.6  = Substr(PARMS,354,60) ;                                         
      Notes.7  = Substr(PARMS,414,60) ;                                         
      Notes.8  = Substr(PARMS,474,60) ;                                         
      ShipOutput = Substr(PARMS,584,03) ;                                       
      End /*  Else  */                                                          
                                                                                
                                                                                                                                                                
   Userid    = CAST_USER  ;                                                     
   MyRC = 0 ;                                                                   
   /* Intitialize a list of shipments for this package */                       
   Shipment_List = ''                                                           
                                                                                
                                                                                
   /*   Install Date 06 JUN 2013 15:22   */                                     
   /*   ----+----1----+----2----+----3-- */                                     
                                                                                
   rulSt  = '_'                                                                 
   InstallDate = Word(Notes.8,5) ;                                              
                                                                                
   If InstallDate = '' | Word(Notes.8,1) /= 'SHIP' then,                        
      Do                                                                        
      InstallDate = DATE('S')                                                   
      InstallTime = '0000'                                                      
      rulSt  = 'R' ; /* This Trigger file entry to be Reviewed */               
      End                                                                       
   Else,                                                                        
      Do                                                                        
      InstallTime = Word(Notes.8,6) ;                                           
      InstallTime = Substr(Installtime,1,2) || Substr(Installtime,4)            
      ListMonths =,                                                             
        "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" ;                     
      mon = Substr(InstallDate,3,3) ;                                           
      mon#= Right(Wordpos(mon,ListMonths),2,'0') ;                              
      year = Substr(InstallDate,6)                                              
      Century = '20'    ;                                                       
      day  = Substr(InstallDate,1,2) ;                                          
      InstallDate = Century || year || mon# || day                              
      End                                                                       
                                                                                
   Call DateConvert ;                                                           
                                                                                
   /* Capture Content of Rules into Rexx Stem array format */                   
   Call AllocateandReadRules;                                                   
   if TraceRc = 1 then Trace r                                                  
   $rulHeading_Variable_count = Words($heading.SHIPRULE)                        
                                                                                
/* Examine Package actions and                           */                     
/* compare each against the Rules stem array data        */                     
/* make an entry into the ImmediateTrigger stem array    */                     
/* Do one of these:                                                             
   Call APIALSUM_For_Package_Target_Info ;                                      
           -- or ---                                                            
   Call CSV_to_List_Package_Actions                                             
      **Note CSV_to_List_Package_Actions has a timing problem                   
        on the 18.0.12 release. The package shows it is not yet                 
        Executed. Use APIALSUM_For_Package_Target_Info                          
*/                                                                              
   Call CSV_to_List_Package_Actions                                             
                                                                                
   sa = ElmEnvironment ElmStage                                                 
                                                                                
   If Words(Shipment_List) > 0 then,                                            
      Do                                                                        
      Call FreeTriggerFile ;                                                    
      Say 'BILDTGGR: Found these destinations -' Shipment_List                  
      Exit(1)                                                                   
      End                                                                       
/*                                                                    */        
/* All Done                                                           */        
/*                                                                    */        
   Exit(0)                                                                      
                                                                                
/*                                                                    */        
/* Allocate the Rules member  for Read only                           */        
/*                                                                    */        
                                                                                
AllocateandReadRules:                                                           
                                                                                
   If TraceRc = 1 then Say 'AllocateandReadRules+             '                 
   /* Call utility to get SHIPRULE details */                                   
   /* Save ShipRule in stem array data         */                               
   Call TBLUNLOD  ShipRules "ALL"                                               
                                                                                
   LastRecord.T#SYSTMS = 0                                                      
   /* Capture results from utility */                                           
   qtotal = QUEUED()                                                            
   Trace Off                                                                    
                                                                                
   /* Capture contents of ShipRule table */                                     
   Value.SHIPRULE = ' '                                                         
   Do q# = 1 to qtotal                                                          
      Parse Pull something                                                      
      If TraceRc = 1 then Say "Rules+" something                                
      interpret something                                                       
   End;                                                                         
                                                                                
   Return ;                                                                     
                                                                                
/*                                                                    */        
/* Convert Date formats                                               */        
/*                                                                    */        
                                                                                
AllocateTriggerForMod:                                                          
                                                                                
   STRING = "ALLOC DD(TRIGGER)",                                                
              " DA('"TriggerFileName"') MOD REUSE"                              
   seconds = '000005' /* Number of Seconds to wait if needed */                 
                                                                                
   Do Forever  /* or at least until the file is available */                    
      CALL BPXWDYN STRING;                                                      
      MyResult = RESULT ;                                                       
      If MyResult = 0 then Leave                                                
      Say 'BILDTGGR is waiting for' TriggerFileName                             
      Call WaitAwhile                                                           
   End /* Do Forever */                                                         
                                                                                
   Return ;                                                                     
                                                                                
CreateNewTriggerEntry:                                                          
                                                                                
   If TraceRc = 1 then Say 'CreateNewTriggerEntry+            '                 
   If TraceRc = 1 then Trace r                                                  
   Jobnumber = '  ';                                                            
/* Time = TIME()                                                                
   Time = Substr(Time,1,2) || Substr(Time,4,2) */                               
   Time = rulTime ;                                                             
                                                                                
   Say 'My_BILDTGGR Creating new Trigger file Entry'                            
   rulAdjustDate = Strip(rulAdjustDate,'L','+') ;                               
   rulAdjustDate = Strip(rulAdjustDate)                                         
   #days = DATE('B')                                                            
   #days = DATE('B',InstallDate,'S') ;                                          
   if rulAdjustDate < '0' then rulAdjustDate = '0'                              
   #days = #days + rulAdjustDate ;                                              
   TriggerDate = DATE('S',#days,'B') ;                                          
   Date = DATE('S',#days,'B') ;                                                 
                                                                                
   Trigger = Copies(' ',400) ;                                                  
                                                                                
   $Heading_TriggerVar_count = WORDS($trigger_variables) ;                      
   Do $pos = 1 to $Heading_TriggerVar_count                                     
      $HeadingVariable = Word($trigger_variables,$pos) ;                        
      /* Build ...pos variables and values */                                   
                                                                                
      tmp = "Trigger = Overlay(",                                               
            $HeadingVariable",Trigger,"$HeadingVariable"pos)"                   
                                                                                
      Sa= tmp                                                                   
      Interpret tmp                                                             
   end; /* DO $pos = 1 to $Heading_TriggerVar_count */                          
                                                                                
   Sa= Trigger                                                                  
                                                                                
   Push Trigger                                                                 
                                                                                
   "EXECIO 1 DISKW TRIGGER (FINIS"                                              
                                                                                
   Trace Off                                                                    
   Return ;                                                                     
                                                                                
                                                                                
FreeTriggerFile:                                                                
                                                                                
   STRING = "FREE DD(TRIGGER)"                                                  
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return ;                                                                     
                                                                                
/*                                                                    */        
/* Convert Date formats                                               */        
/*                                                                    */        
                                                                                
DateConvert:                                                                    
                                                                                
  /* Date may be in this format  6/15/2013 */                                   
  tmpdate = Translate(InstallDate,' ','/') ;                                    
  If Wordlength(tmpdate,1) < '4' then do                                        
  InstallDatenumeric = Word(tmpdate,3)    ||,                                   
               Right(Word(tmpdate,1),2,'0') ||,                                 
                     Word(tmpdate,2)       ;                                    
  end                                                                           
  else do                                                                       
  InstallDatenumeric = Word(tmpdate,1) || ,                                     
                       Word(tmpdate,2) ||,                                      
                       Word(tmpdate,3)   ;                                      
  end                                                                           
  Return                                                                        
                                                                                
  if Substr(InstallDate,1,1) = '0' then                                         
     InstallDate = Substr(InstallDate,2)                                        
  MONTHSLISTUPPER = 'JAN FEB MAR APR MAY JUN JUL AUG SEP NOV DEC'               
  monthslistlower = 'Jan Feb Mar Apr May Jun Jul Aub Sep Nov Dec'               
  MONTHUPPER = Word(InstallDate,2) ;                                            
  pos = Wordpos(MONTHUPPER,MONTHSLISTUPPER)                                     
  monthlower = Word(monthslistlower,pos) ;                                      
  InstallDate = Word(InstallDate,1) monthlower Word(InstallDate,3)              
                                                                                
  InstallDatenumeric = DATE(S,InstallDate)                                      
  Sa= InstallDate  InstallDatenumeric                                           
                                                                                
  Return                                                                        
                                                                                
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
                                                                                
InitializeValuesFromRules:                                                      
   Sa=   InitializeValuesFromRules                                              
   Do $pos = 1 to $rulHeading_Variable_count                                    
      $rulHeadingVariable = Word(Rul$table_variables,$pos) ;                    
      $start = $rulStarting_$position.$rulHeadingVariable                       
      $stop  = $rulEnding_$position.$rulHeadingVariable                         
      $len   = $stop - $start + 1;                                              
      /* Assign values from the rules record  */                                
      tmp = $rulHeadingVariable" =",                                            
            "Strip(Substr(rules.rul#,"$start","$len"))"                         
      Sa= tmp                                                                   
      Sa= Value($rulHeadingVariable)                                            
      Interpret tmp                                                             
                                                                                
   end; /* DO $pos = 1 to $rulHeading_Variable_count */                         
                                                                                
   Return ;                                                                     
                                                                                
Process_Trigger_Heading :                                                       
                                                                                
   "EXECIO 1 DISKR TRIGGER (Stem $tablerec. FINIS"                              
/* Get layout of TRIGGER file from heading */                                   
                                                                                
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
   $trigger_variables = $Heading                                                
                                                                                
   Return ;                                                                     
                                                                                
APIALSUM_For_Package_Target_Info:                                               
                                                                                
  SA= "GETTING CURRENT LOCATIONS FROM ENDEVOR" ;                                
                                                                                
   STRING = "ALLOC DD(BSTAPI)   SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTERR)   SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(C1MSGS1)  SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(C1MSGS2)  SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(APILIST) LRECL(2048) BLKSIZE(22800) ",                    
              " DSORG(PS) ",                                                    
              " SPACE(5,5) RECFM(V,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(APIMSGS) LRECL(133) BLKSIZE(13300) ",                     
              " DSORG(PS) ",                                                    
              " SPACE(1,1) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
/*parm = 'DDN:STEPLIB,APIALSUM,'Package           */                            
/*                                                */                            
/*ADDRESS LINKMVS 'CONCALL' "parm"                */                            
                                                                                
  ADDRESS LINKMVS 'APIALSUM' Package                                            
                                                                                
  "EXECIO * DISKR APILIST (STEM pkglst. finis"                                  
  IF pkglst.0 = 0 then,                                                         
     Do                                                                         
     Say 'Package' Package ' is not-found or not-CAST '                         
     Exit(8)                                                                    
     End;                                                                       
                                                                                
   STRING = "FREE DD(BSTAPI)"                                                   
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTERR) "                                                  
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS1) "                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS2) "                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
   sa= pkglst.1                                                                 
   /* Get Target Endevor info   */                                              
                                                                                
     ALSUM_RS_TENV = Substr(pkglst.1,304,008)                                   
     ElmEnvironment = ALSUM_RS_TENV                                             
     If ElmEnvironment = ' ' then                                               
        Do                                                                      
        ALSUM_RS_SENV = Substr(pkglst.1,191,008)                                
        ALSUM_RS_SSTGI= Substr(pkglst.1,234,001)                                
        ALSUM_RS_SSYS = Substr(pkglst.1,199,008)                                
        ALSUM_RS_SSBS = Substr(pkglst.1,207,008)                                
        Sa= 'Messages from BILDTGGR:'                                           
        ElmEnvironment = ALSUM_RS_SENV                                          
        ElmStage = ALSUM_RS_SSTGI                                               
        ElmSystem = ALSUM_RS_SSYS                                               
        ElmSubsys = ALSUM_RS_SSBS                                               
        End                                                                     
     Else,                                                                      
        Do                                                                      
        ALSUM_RS_TSTGI= Substr(pkglst.1,347,001)                                
        ALSUM_RS_TSYS = Substr(pkglst.1,312,008)                                
        ALSUM_RS_TSBS = Substr(pkglst.1,320,008)                                
        Sa= 'Messages from BILDTGGR:'                                           
        ElmEnvironment = ALSUM_RS_TENV                                          
        ElmStage = ALSUM_RS_TSTGI                                               
        ElmSystem = ALSUM_RS_TSYS                                               
        ElmSubsys = ALSUM_RS_TSBS                                               
        End                                                                     
                                                                                
     If Substr(Description,1,12) = 'Deployed to ' |,                            
        Substr(Description,1,12) = 'DEPLOYED TO ' then,                         
        ElmSystem = ALSUM_RS_TSBS                                               
     ALSUM_RS_TTYP = Substr(pkglst.1,330,008)                                   
                                                                                
   sa= pkglst.2                                                                 
   sa= pkglst.3                                                                 
   sa= pkglst.4                                                                 
                                                                                
   STRING = "FREE DD(APIMSGS)"                                                  
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(APILIST)"                                                  
   CALL BPXWDYN STRING;                                                         
                                                                                
  Return ;                                                                      
                                                                                
CSV_to_List_Package_Actions:                                                    
                                                                                
  /* To Search the package shipping table, we need the Entry       */           
  /*    Environment information as a search criteria.              */           
  /*    Get it from the USER-DATA field on the 1st element.        */           
                                                                                
   STRING = "ALLOC DD(C1MSGS1) DUMMY "                                          
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTERR) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTAPI) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(EXTRACTM) LRECL(4000) BLKSIZE(32000) ",                   
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",                       
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   QUEUE "LIST PACKAGE ACTION FROM PACKAGE '"Package"'"                         
   QUEUE "     TO DDNAME 'EXTRACTM' "                                           
   QUEUE "     ."                                                               
                                                                                
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";                                  
                                                                                
   ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */                         
                                                                                
/* ADDRESS TSO  'ISRDDN' */                                                     
   call_rc = rc ;                                                               
                                                                                
  "EXECIO * DISKR EXTRACTM (STEM CSV. finis"                                    
                                                                                
   STRING = "FREE DD(EXTRACTM)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTIPT01)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS1)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTERR)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTAPI)" ;                                                 
   CALL BPXWDYN STRING;                                                         
  /* To Search the package action data in CSV format.              */           
  /* Identify matches with Rules file, determining Ship Dests      */           
                                                                                
  IF CSV.0 < 2 THEN RETURN;                                                     
                                                                                
  /* CSV data heading - showing CSV variables */                                
  $table_variables= Strip(CSV.1,'T')                                            
                                                                                
  $table_variables = translate($table_variables,"_"," ") ;                      
  $table_variables = translate($table_variables," ",',"') ;                     
  $table_variables = translate($table_variables,"@","/") ;                      
  $table_variables = translate($table_variables,"@",")") ;                      
  $table_variables = translate($table_variables,"@","(") ;                      
                                                                                
  Do rec# = 2 to CSV.0                                                          
     $detail = CSV.rec#                                                         
     Drop SBS_NAME_@T@                                                          
                                                                                
     Trace Off                                                                  
     /* Parse the Detail record until done */                                   
     Do $column =  1 to Words($table_variables)                                 
        Call ParseDetailCSVline                                                 
     End                                                                        
                                                                                
     If TraceRc =  1 then Trace r                                               
     IF Substr(ENV_NAME_@T@,1,1) = ' ' then,                                    
        Do                                                                      
        ENV_NAME_@T@ = ENV_NAME_@S@ ;                                           
        STG_#_@T@    = STG_#_@S@  ;                                             
        STG_NAME_@T@ = STG_NAME_@S@ ;                                           
        STG_ID_@T@   = STG_ID_@S@   ;                                           
        SYS_NAME_@T@ = SYS_NAME_@S@ ;                                           
        SBS_NAME_@T@ = SBS_NAME_@S@ ;                                           
        TYPE_NAME_@T@ = TYPE_NAME_@S@                                           
        End                                                                     
     IF Substr(SBS_NAME_@T@,1,1) = ' ' then,                                    
        SBS_NAME_@T@ = SBS_NAME_@S@ ;                                           
     Say 'ELM='ELM_@S@,                                                         
         'ENV_NAME='ENV_NAME_@T@,                                               
         'pkgStage='STG_#_@T@,                                                  
         'SYS_NAME='SYS_NAME_@T@,                                               
         'SBS_NAME='SBS_NAME_@T@,                                               
         'TYPE_NAME='TYPE_NAME_@S@,                                             
         'ELM_ACT='ELM_ACT                                                      
      pkgStage = STG_ID_@T@                                                     
                                                                                
     If TraceRc = 1 then Trace r                                                
     Sa= 'Messages from BILDTGGR:'                                              
     pkgElement = ELM_@S@                                                       
     pkgEnvironment = ENV_NAME_@T@                                              
     pkgStage       = STG_ID_@T@                                                
     pkgSystem      = SYS_NAME_@T@                                              
     pkgSubsys      = SBS_NAME_@T@                                              
     pkgType        = TYPE_NAME_@T@                                             
        Trace Off                                                               
     RuleMatch  = 'N'                                                           
     Call DoesCSVMatchRule;                                                     
/*   If Length(pkgStage) = 1 then leave; */                                     
  End; /* Do rec# = 1 to CSV.0 */                                               
                                                                                
  RETURN ;                                                                      
                                                                                
DoesCSVMatchRule:                                                               
                                                                                
  If TraceRc = 1 then Say 'DoesCSVMatchRule+                 '                  
                                                                                
  Do rul# = 2 to LastRecord.SHIPRULE                                            
                                                                                
     If TraceRc = 1 then TRACE R                                                
     Say 'BILDTGGR: Comparing pkg with rul#' rul# pkgElement,                   
               pkgEnvironment pkgStage pkgSystem                                
                                                                                
     Drop Environment ;                                                         
     rulEnvironment = Value.SHIPRULE.Environment.rul#                           
     If TestMatch(pkgEnvironment,rulEnvironment) /= 1 then Iterate;             
     Environment = pkgEnvironment                                               
                                                                                
     Drop Stage                                                                 
     rulStage = Value.SHIPRULE.Stage.rul#                                       
     If TestMatch(pkgStage,rulStage) /= 1 then Iterate;                         
     Stage  = pkgStage                                                          
                                                                                
     Drop System                                                                
     rulSystem= Value.SHIPRULE.System.rul#                                      
     If TestMatch(pkgSystem,rulSystem) /= 1 then Iterate;                       
     System = pkgSystem                                                         
                                                                                
     Drop Subsys                                                                
     rulSubsys= Value.SHIPRULE.Subsys.rul#                                      
     If TestMatch(pkgSubsys,rulSubsys) /= 1 then Iterate;                       
     Subsys = pkgSubsys                                                         
                                                                                
/*                                                                              
     Drop Type                                                                  
     rulType  = Value.SHIPRULE.Type.rul#                                        
     If TestMatch(pkgType,rulType) /= 1 then Iterate;                           
     Type   = pkgType                                                           
                                                                                
     Drop Element ElmPrefx                                                      
     rulElmPrefx= Value.SHIPRULE.ElmPrefx.rul#                                  
     If TestMatch(pkgElement,rulElmPrefx) /= 1 then Iterate;                    
     Element = pkgElement                                                       
*/                                                                              
                                                                                
     Drop Destination                                                           
     newDestination= Value.SHIPRULE.Destination.rul#                            
     If TraceRc = 1 then,                                                       
        Say 'found newDestination=' newDestination                              
                                                                                
     if Length(newDestination) > 7 |,                                           
        Pos('.',newDestination) > 0 |,                                          
        Wordpos(newDestination,Shipment_List) > 0 then,                         
        Iterate ;                                                               
                                                                                
     Shipment_List = newDestination Shipment_List                               
     If TraceRc = 1 then,                                                       
        Say 'Shipment_List =' Shipment_List                                     
                                                                                
     /* If finding first destination for shipping     */                        
     /* then, allocate Trigger file for DISP=MOD      */                        
     If Words(Shipment_List) = 1 then,                                          
        Do                                                                      
        Call AllocateTriggerForMod                                              
        Call Process_Trigger_Heading                                            
        End                                                                     
                                                                                
     Destination = newDestination                                               
                                                                                
     Drop Date                                                                  
     rulAdjustDate = Value.SHIPRULE.Date.rul#                                   
     If TraceRc = 1 then,                                                       
        Say 'found rulAdjustDate =' rulAdjustDate                               
     Drop Time                                                                  
     rulTime       = Value.SHIPRULE.Time.rul#                                   
     If TraceRc = 1 then,                                                       
        Say 'found rulTime       =' rulTime                                     
                                                                                
                                                                                
     /* Capture remaining values from Rules file ..    */                       
     AlreadyAssigned =,                                                         
        'Environment Stage System Subsys ',                                     
        'Type Destination Element Date Time '                                   
     Do w# = 1 to Words($heading.SHIPRULE)                                      
        rulWord =  Word($heading.SHIPRULE,w#)                                   
        If Wordpos(rulWord,AlreadyAssigned) > 0 then iterate;                   
        tmp = "Drop" rulWord                                                    
        interpret tmp                                                           
        rulValue = Value(Value.SHIPRULE.rulWord.rul#)                           
        If Substr(rulValue,1,15) = 'VALUE.SHIPRULE.' then,                      
           rulValue = ' '                                                       
        tmp = rulWord "= '"rulValue"'"                                          
        If TraceRc = 1 then,                                                    
           say 'From Rules+' tmp                                                
        interpret tmp                                                           
     End                                                                        
                                                                                
     /* Variables are now assigned values either from  */                       
     /*  the Endevor package or from the Rules File    */                       
     Call CreateNewTriggerEntry                                                 
                                                                                
     If TraceRc = 1 then Trace r                                                
     /* If the package shipment can be done now....    */                       
     /* Set the return code to 1               ....    */                       
     Drop Date                                                                  
     rulDate    = Value.SHIPRULE.Date.rul#                                      
     if rulDate = ' ' | Length(rulDate) > 5 then,                               
        rulDate = '+0'                                                          
     if rulTime = ' ' | Length(rulTime) > 5 then,                               
        rulTime = '0000'                                                        
     If rulDate = '+0' & rulTime = '0000' then,                                 
        MyRC = 1 ;                                                              
                                                                                
  End; /* Do rul# = 2 to LastRecord.SHIPRULE */                                 
                                                                                
  RETURN ;                                                                      
                                                                                
TestMatch:                                                                      
                                                                                
  Arg String,Mask ;                                                             
                                                                                
      If Mask  = '*' then Return(1)                                             
      Mask     = Strip(Mask,'T',"*")                                            
      lenMask  = Length(Mask)                                                   
      Return ABBREV(String,Mask)                                                
                                                                                
/*                                                                    */        
/* Allocate the Trigger File for MOD update                           */        
/*                                                                    */        
                                                                                
CSV_to_List_Package_Actions:                                                    
                                                                                
  /* To Search the package shipping table, we need the Entry       */           
  /*    Environment information as a search criteria.              */           
  /*    Get it from the USER-DATA field on the 1st element.        */           
                                                                                
                                                                                
   STRING = "ALLOC DD(C1MSGS1) DUMMY "                                          
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTERR) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
   STRING = "ALLOC DD(BSTAPI) DUMMY "                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(EXTRACTM) LRECL(4000) BLKSIZE(32000) ",                   
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",                       
              " DSORG(PS) ",                                                    
              " SPACE(1,5) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   QUEUE "LIST PACKAGE ACTION FROM PACKAGE '"Package"'"                         
   QUEUE "     TO DDNAME 'EXTRACTM' "                                           
   QUEUE "     ."                                                               
                                                                                
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";                                  
                                                                                
   ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */                         
                                                                                
/* ADDRESS TSO  'ISRDDN' */                                                     
   call_rc = rc ;                                                               
                                                                                
  "EXECIO * DISKR EXTRACTM (STEM API. finis"                                    
                                                                                
   STRING = "FREE DD(EXTRACTM)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTIPT01)" ;                                               
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(C1MSGS1)" ;                                                
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTERR)" ;                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE DD(BSTAPI)" ;                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
  IF API.0 < 2 THEN RETURN;                                                     
                                                                                
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
                                                                                
     IF Substr(ENV_NAME_@T@,1,1) = ' ' then,                                    
        Do                                                                      
        ENV_NAME_@T@ = ENV_NAME_@S@ ;                                           
        STG_#_@T@    = STG_#_@S@  ;                                             
        STG_NAME_@T@ = STG_NAME_@S@ ;                                           
        STG_ID_@T@   = STG_ID_@S@   ;                                           
        SYS_NAME_@T@ = SYS_NAME_@S@ ;                                           
        SBS_NAME_@T@ = SBS_NAME_@S@ ;                                           
        End                                                                     
     IF Substr(SBS_NAME_@T@,1,1) = ' ' then,                                    
        SBS_NAME_@T@ = SBS_NAME_@S@ ;                                           
     Say 'ELM='ELM_@S@,                                                         
         'ENV_NAME='ENV_NAME_@T@,                                               
         'STAGE='STG_#_@T@,                                                     
         'SYS_NAME='SYS_NAME_@T@,                                               
         'SBS_NAME='SBS_NAME_@T@,                                               
         'TYPE_NAME='TYPE_NAME_@S@,                                             
         'ELM_ACT='ELM_ACT                                                      
      Stage = STG_ID_@T@                                                        
                                                                                
     Trace r                                                                    
     Sa= 'Messages from BILDTGGR:'                                              
     ElmEnvironment = ENV_NAME_@T@                                              
     ElmStage       = STG_ID_@T@                                                
     ElmSystem      = SYS_NAME_@T@                                              
     ElmSubsys      = SBS_NAME_@T@                                              
     Trace Off                                                                  
     If Length(Stage) = 1 then leave;                                           
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
                                                                                
