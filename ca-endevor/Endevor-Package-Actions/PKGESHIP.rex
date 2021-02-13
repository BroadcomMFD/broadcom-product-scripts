/*  REXX  */                                                                    
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF                  
   "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE                  
   FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES                
   ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE                    
   CORRECTED.                                                                   
*/                                                                              
/*                                                                              
   This REXX submits automatically 0 or more package shipping                   
   jobs.                                                                        
*/                                                                              
/*  WRITTEN BY DAN WALTHER */                                                   
                                                                                
/* Runs only 4 userid = WALJO11     (if uncommented)  */                        
/*                                                                              
   If USERID() /= 'WALJO11' then Exit                                           
*/                                                                              
   /* <---- Variable settings for each site          */                         
                                                                                
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
   Trace Off                                                                    
                                                                                
   /* If a DDNAME of PKGESHIP is allocated, then Trace */                       
   WhatDDName = 'PKGESHIP'                                                      
   CALL BPXWDYN "INFO FI("WhatDDName")",                                        
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"                                 
   if Substr(DSNVAR,1,1) /= ' ' then TraceRc = 1;                               
   IF TraceRc = 1 then Trace R                                                  
                                                                                
   STRING = "ALLOC DD(SYSPRINT) SYSOUT(A) "                                     
   CALL BPXWDYN STRING;                                                         
                                                                                
/* Variable settings for each site --->           */                            
   WhereIam =  WHERE@M1()                                                       
   RunUnderAltid  = 'N' ;   /* Y/N  */                                          
                                                                                
   /* The site determines whether to engage Endevor hooks */                    
   EndevorHooks = 'N'                                                           
                                                                                
   /* If just shipping to one destination, then use          */                 
   /* ShipSchedulingMethod = 'One  '                         */                 
   /* if there only a few  destinations (in notes), then use */                 
   /* ShipSchedulingMethod = 'Notes'                         */                 
   /* if using a RULES file and Trigger, then use            */                 
   /* ShipSchedulingMethod = 'Rules'                         */                 
   interpret 'Call' WhereIam "'ShipSchedulingMethod'"                           
   ShipSchedulingMethod = Result                                                
                                                                                
   If ShipSchedulingMethod = 'One'   then,                                      
      Do                                                                        
      interpret 'Call' WhereIam "'Destination'"                                 
      Destination          = Result                                             
      interpret 'Call' WhereIam "'Destination'"                                 
      Destination          = Result                                             
      interpret 'Call' WhereIam "'Hostprefix'"                                  
      Hostprefix           = Result                                             
      interpret 'Call' WhereIam "'Rmteprefix'"                                  
      Rmteprefix           = Result                                             
      interpret 'Call' WhereIam "'ModelMember'"                                 
      ModelMember          = Result                                             
      End                                                                       
   interpret 'Call' WhereIam "'SHLQ'"                                           
   SHLQ = Result                                                                
                                                                                
   interpret 'Call' WhereIam "'MyAUTHLibrary'"                                  
   MyAUTHLibrary = Result                                                       
   interpret 'Call' WhereIam "'MyAUTULibrary'"                                  
   MyAUTULibrary = Result                                                       
   interpret 'Call' WhereIam "'MyLOADLibrary'"                                  
   MyLOADLibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MySEN2Library'"                                  
   MySEN2Library = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MySENULibrary'"                                  
   MySENULibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MyOPT2Library'"                                  
   MyOPT2Library = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MyOPTNLibrary'"                                  
   MyOPTNLibrary = Result                                                       
                                                                                
   interpret 'Call' WhereIam "'MyCLS0Library'"                                  
   HSYSEXEC  = Result                                                           
   MyCLS0Library = HSYSEXEC                                                     
                                                                                
   interpret 'Call' WhereIam "'MyCLS2Library'"                                  
   HSYSEXEC  = Result                                                           
   MyCLS2Library = HSYSEXEC                                                     
   Say 'Running PKGESHIP in' MyCLS2Library                                      
                                                                                
   interpret 'Call' WhereIam "'AltIDAcctCode'"                                  
   AltIDAcctCode= Result                                                        
                                                                                
   interpret 'Call' WhereIam "'AltIDJobClass'"                                  
   AltIDJobClass= Result                                                        
                                                                                
   interpret 'Call' WhereIam "'AltIDMsgClass'"                                  
   AltIDMsgClass= Result                                                        
                                                                                
   interpret 'Call' WhereIam "'TransmissionModels'"                             
   TransmissionModels = Result                                                  
                                                                                
   interpret 'Call' WhereIam "'MyHomeAddress'"                                  
   MyHomeAddress      = Result                                                  
                                                                                
   ARG Parms ;                                                                  
                                                                                
/* if called by zowe, then this  is  the Argument ....   */                     
   If Length(Parms) < 18 then,                                                  
      Do                                                                        
      Package = Translate(Parms,' ',"'")                                        
      Package = Strip(Package)                                                  
      Say Length(Package) Package                                               
      PkgExecJobname = USERID() || 'S'           /*Userid + S      */           
      End /* If Length(Parms) < 18 */                                           
   Else                                                                         
      Do                                                                        
      /* if called by exit, then these are the Arguments.... */                 
      Notes.7  = Substr(PARMS,414,60) ;                                         
      If Substr(Notes.7,1,5) = 'TRACE' then Trace r                             
      Package = Substr(PARMS,1,16) ;                                            
                                                                                
      Environ = Substr(PARMS,18,08) ;                                           
      Stage   = Substr(PARMS,27,01) ;                                           
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
      PkgExecJobname = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */           
      End /*  Else  */                                                          
                                                                                
/* If ShipOutput /= 'BAC' THEN ShipOutput = 'OUT' */                            
   TYPRUN = ' '                                                                 
                                                                                
/* IF you want to use the package prefix to select packages          */         
/*     for shipments, then tailor and uncomment the next line:       */         
/* If Substr(Package,1,2) /= 'PR' then exit                          */         
                                                                                
/* If ShipOutput /= 'BAC' THEN ShipOutput = 'OUT' */                            
   TYPRUN = ' '                                                                 
/*                                                                    */        
/* This Rexx participates in the submission of Endevor Package        */        
/* Shipment jobs. It is called by the Endevor exit program C1UEXT07   */        
/*                                                                    */        
/* First. See if the package has any package backouts ...             */        
/*                                                                    */        
   Call CSV_to_List_Package_Id                                                  
   If BACKOUT_RCD_EXIST = 'N' then Exit                                         
/* Allocate and prepare files for updating the shipment transaction   */        
/* file, and submitting package shipments for those scheduled for     */        
/* immediate submission.                                              */        
/*                                                                    */        
                                                                                
   Userid = USERID()                                                            
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
                                                                                
   TodaysDate = DATE('S') ;                                                     
   NOW  = TIME(L);                                                              
   HOUR = SUBSTR(NOW,1,2) ;                                                     
   IF HOUR = '00' THEN HOUR = '0'                                               
   MINUTE = SUBSTR(NOW,4,2) ;                                                   
   CurrentTime= HOUR || MINUTE ;                                                
   SENDNODE =  MVSVAR(SYSNAME)                                                  
   ShipOutput = 'OUT'                                                           
   VDDRSPFX   = 'PSP.ENDV'                                                      
                                                                                
   $All_VARIABLES = "Jobname Destination Userid ",                              
         "PkgExecJobname MyOPTNLibrary MyAUTULibrary ",                         
         "MyAUTHLibrary MyLOADLibrary MyCLS0Library ",                          
         "MyHomeAddress ",                                                      
         "Package Date8 Date6 Time8 Time6 Notify ",                             
         "Typrun SENDNODE $delimiter ShipOutput  ",                             
         "SHLQ MySEN2Library MySENULibrary MyOPT2Library ",                     
         "MyCLS2Library AltIDAcctCode AltIDJobClass ",                          
         "AltIDMsgClass VDDRSPFX HSYSEXEC OUT"                                  
                                                                                
   Trace R                                                                      
   sa= 'Back to PKGESHIP'                                                       
   /* If Scheduling Package Shipments, then BILDTGGR             */             
   /* determines sites and updates the Trigger file  .           */             
   /* If any Sites can receive Shipments immediately, then       */             
   /* BILDTGGR indicates so in its Return code.                  */             
   If ShipSchedulingMethod = 'Rules' then,                                      
      Do                                                                        
      BildRC = BILDTGGR(Parms)                                                  
      /* The immediate shipments are queued by BILDTGGR in a Table  */          
      If BildRC = 1 then,                                                       
         Do                                                                     
         Userid = USERID() ;                                                    
         PULLTGGRParms = Userid'.PULLTGGR' MySEN2Library                        
         Call PULLTGGR PULLTGGRParms ;                                          
         End                                                                    
      End /*  SchedulingPackageShipBundle */                                    
   Else,                                                                        
   If ShipSchedulingMethod = 'Notes' then,                                      
      Do n# = 8 to 1 by -1                                                      
      /* Pulling shipment data from package notes */                            
      /* Examine Package notes to find Destination and schedule info */         
      /* - Submit Package Shipments for those that can be submitted  */         
      /*       immeditely.                                           */         
      /*       (future submissions are not supported )               */         
         tmp = NOTES.n# ;                                                       
         if Substr(tmp,1,3)  /= "TO " then leave ;                              
         if Substr(tmp,12,2) /= ": "  then leave ;                              
         tmp = Substr(OVERLAY(" ",tmp,12),3) ;                                  
         Destination = Word(tmp,1) ;                                            
         /* Default to first model     */                                       
         ModelMember = Word(TransmissionModels,1)                               
         /* Get info for Destination   */                                       
         Call  GetDestinationInfo;                                              
         Hostprefix = Strip(Substr(apiDestinations.1,079,14))                   
         Rmteprefix = Strip(Substr(apiDestinations.1,113,14))                   
         /*                                                                     
         */                                                                     
         Date        = Word(tmp,2) ;                                            
         Time        = Word(tmp,3) ;                                            
         Jobname     = Word(tmp,4) ;                                            
         If Words(tmp) > 4 then,                                                
            If Word(tmp,5) = "HOLD" then,                                       
               Notify      = Notify",TYPRUN=HOLD"                               
         If Date <= TodaysDate &,                                               
            Time <= CurrentTime then,                                           
            Do                                                                  
            Call AllocateModel;                                                 
            Call SubmitPackageShipmentFromNotes;                                
            End ;                                                               
         tmp = Substr(OVERLAY(" ",tmp,12),3) ;                                  
      End;  /*  Do n# = 8 to 1 by -1   */                                       
   Else, /* Is there only one Destination etc        */                         
   If ShipSchedulingMethod = 'One'   then,                                      
      Do                                                                        
      JobName     = PkgExecJobname                                              
      Call AllocateModel;                                                       
      Call SubmitPackageShipmentFromNotes;                                      
      End;  /*  .. Else...             */                                       
                                                                                
/*                                                                    */        
/* All Done                                                           */        
/*                                                                    */        
                                                                                
   Exit                                                                         
                                                                                
AllocateModel:                                                                  
/*                                                                    */        
/* Submit immediate package shipment jobs                             */        
/*                                                                    */        
/*    Allocate files                                                  */        
/*                                                                    */        
/*    A Model is used for building Package Shipment JCL               */        
/*                                                                    */        
   STRING = 'ALLOC DD(MODEL) ',                                                 
            "DA('"MySEN2Library"("ModelMember")') SHR REUSE "                   
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return;                                                                      
                                                                                
SubmitPackageShipmentFromNotes:                                                 
/*                                                                    */        
/* This subroutine is modified from the TBL#TOOL                      */        
/*                                                                    */        
                                                                                
   "EXECIO * DISKR "MODEL "(STEM $Model. FINIS" ;                               
   $delimiter = "µ" ;                                                           
                                                                                
   DO $LINE = 1 TO $Model.0                                                     
      $PLACE_VARIABLE = 1;                                                      
      CALL EVALUATE_SYMBOLICS ;                                                 
      END; /* DO $LINE = 1 TO $Model.0 */                                       
                                                                                
   STRING = "ALLOC DD(SHIPJCL) LRECL(80) BLKSIZE(27920) ",                      
              " DSORG(PS) ",                                                    
              " SPACE(2,2) RECFM(F,B) TRACKS ",                                 
              " NEW UNCATALOG REUSE ";                                          
   CALL BPXWDYN STRING;                                                         
                                                                                
   "EXECIO * DISKW SHIPJCL (STEM $Model. FINIS" ;                               
                                                                                
   If RunUnderAltid  = 'Y' then CALL SWAP2ALT                                   
   Call Submit_Job ;                                                            
   If RunUnderAltid  = 'Y' then CALL SWAP2USR                                   
                                                                                
   Drop $Model. ;                                                               
                                                                                
   STRING = "FREE DD(SHIPJCL) DELETE"                                           
   CALL BPXWDYN STRING;                                                         
                                                                                
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
                                                                                
   "Execio * DISKR SHIPJCL  ( Stem jcl. finis"                                  
   "Execio * DISKW SYSTSPRT ( Stem jcl. "                                       
                                                                                
   STRING = "ALLOC DD(SUBMIT)",                                                 
               "SYSOUT(A) WRITER(INTRDR) REUSE " ;                              
   CALL BPXWDYN STRING;                                                         
   "Execio * DISKW SUBMIT   ( Stem jcl. finis"                                  
                                                                                
   STRING = "FREE  DD(SUBMIT)"                                                  
   CALL BPXWDYN STRING;                                                         
                                                                                
   RETURN;                                                                      
                                                                                
GetDestinationInfo:                                                             
                                                                                
   /* Set values for Hostprefix and Rmteprefix */                               
   /*     From the site definition             */                               
                                                                                
   /*  Call API to Get Destination information  */                              
                                                                                
                                                                                
   ADDRESS TSO                                                                  
   "ALLOC F(BSTAPI) DA(*) REUSE "                                               
   "ALLOC F(BSTERR) DA(*) REUSE "                                               
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
                                                                                
   ADDRESS TSO "CALL *(APIALDST) '"||parm||"'"                                  
   RETURN_RC = RC ;                                                             
   If RETURN_RC > 0 then,                                                       
      DO                                                                        
      SA= 'CANNOT GET INFORMATION FROM ENDEVOR' ;                               
      EXIT                                                                      
      END ;                                                                     
   "EXECIO * DISKR APILIST ( Stem apiDestinations. FINIS"                       
   STRING = "FREE  DD(APILIST)"                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(APIMSGS)"                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(BSTAPI) "                                                 
   CALL BPXWDYN STRING;                                                         
   STRING = "FREE  DD(BSTERR) "                                                 
   CALL BPXWDYN STRING;                                                         
                                                                                
   Return ;                                                                     
                                                                                
CSV_to_List_Package_Id:                                                         
                                                                                
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
                                                                                
   QUEUE "LIST PACKAGE ID '"Package"'"                                          
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
  $table_variables = translate($table_variables,"_","-") ;                      
                                                                                
  Do rec# = 2 to API.0                                                          
     $detail = API.rec#                                                         
                                                                                
     Trace off                                                                  
     /* Parse the Detail record until done */                                   
     Do $column =  1 to Words($table_variables)                                 
        Call ParseDetailCSVline                                                 
     End                                                                        
     Trace r                                                                    
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
  If rec# < 0 then Say $temp                                                    
  Say       $temp;                                                              
  Interpret $temp;                                                              
                                                                                
  RETURN ;                                                                      
                                                                                
