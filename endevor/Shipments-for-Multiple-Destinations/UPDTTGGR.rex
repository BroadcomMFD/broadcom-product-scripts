/*  REXX  */                                                                    
/* Update the Trigger file at the completion of package shipment */             
                                                                                
   trace  o                                                                     
                                                                                
/* Variable settings for each site --->           */                            
   WhereIam = WHERE@M1()                                                        
                                                                                
   interpret 'Call' WhereIam "'MyCLS2Library'"                                  
   MyCLS2Library = Result                                                       
   Say 'Running UPDTTGGR in' MyCLS2Library                                      
                                                                                
   interpret 'Call' WhereIam "'TriggerFileName'"                                
   TriggerFileName = Result                                                     
                                                                                
   interpret 'Call' WhereIam "'MyDATALibrary'"                                  
   MyDATALibrary = Result                                                       
   ShipRules       = MyDATALibrary"(SHIPRULE)"                                  
                                                                                
   interpret 'Call' WhereIam "'MySEN2Library'"                                  
   MySEN2Library = Result                                                       
/* <---- Variable settings for each site          */                            
                                                                                
/*                                                                    */        
/* This Rexx updates Trigger entries  for a package just submitted    */        
/* for package shipment.                                              */        
/* It also checks for 'Transfer completed successfully' text          */        
/* It is executed by a step in the #PSNFTPE shipment member .         */        
                                                                                
   ARG Destination Calltype Package ;                                           
                                                                                
   Jobnumber = '' ;     /* replace if one is found */                           
   If Calltype = '#PSNFTPE' then,                                               
      Do                                                                        
      /* Read the FTP output  */                                                
      MyRC= 0 ;                                                                 
      Call ScanFTPOutput ;                                                      
      If MyRC > 0 then Exit(MyRC) ;                                             
                                                                                
      If Jobnumber = '' then Exit(MyRC) ;                                       
      End /* If Calltype = '#PSNFTPE' */                                        
                                                                                
   Call AllocateTriggerForUpdate ;                                              
   Call UpdateTriggerEntry ;                                                    
   Call FreeTriggerFile ;                                                       
                                                                                
/*                                                                    */        
/* All Done                                                           */        
/*                                                                    */        
                                                                                
   Exit                                                                         
                                                                                
/*                                                                    */        
/* Allocate the Rules member  for Read only                           */        
/*                                                                    */        
                                                                                
ScanFTPOutput:                                                                  
                                                                                
   "Execio * DISKR FTPOUT (Stem ftp. finis "                                    
   IF RC > 0 then EXIT(8)                                                       
   If ftp.0 < 1 then EXIT(8)                                                    
                                                                                
   "Execio * DISKW OUTPUT (Stem ftp. finis "                                    
                                                                                
   MyRC= 8 ;                                                                    
   Do f# = 1 to ftp.0                                                           
      ftp@ = Substr(ftp.f#,2)                                                   
      w1 = Word(ftp@,1)                                                         
      w2 = Word(ftp@,2)                                                         
      w3 = Word(ftp@,3)                                                         
      w4 = Word(ftp@,4)                                                         
      if w2='Transfer' & w3='completed' & w4='Successfully' then,               
         Do                                                                     
         MyRC= 0 ;                                                              
         Leave ;                                                                
         End                                                                    
      w5 = Word(ftp@,5)                                                         
      w6 = Word(ftp@,6)                                                         
      w7 = Word(ftp@,7)                                                         
   /* 250-It is known to JES as JOB32058 */                                     
      if w3='known' & w4='to' & w5='JES' & w6='as' then,                        
         Do                                                                     
         Jobnumber = w7;                                                        
         MyRC= 0 ;                                                              
         Leave ;                                                                
         End                                                                    
   End ; /* Do f# = 1 to ftp.0   */                                             
                                                                                
   Return ;                                                                     
                                                                                
AllocateTriggerForUpdate:                                                       
                                                                                
   STRING = "ALLOC DD(TRIGGER)",                                                
              " DA('"TriggerFileName"') OLD REUSE"                              
   seconds = '000005' /* Number of Seconds to wait if needed */                 
                                                                                
   Do Forever  /* or at least until the file is available */                    
      CALL BPXWDYN STRING;                                                      
      MyRC = RC                                                                 
      MyResult = RESULT ;                                                       
      If MyResult = 0 then Leave                                                
      Call WaitAwhile                                                           
   End /* Do Forever */                                                         
                                                                                
   Return ;                                                                     
                                                                                
UpdateTriggerEntry:                                                             
                                                                                
                                                                                
   "Execio * DISKR TRIGGER (Stem $tablerec. finis "                             
                                                                                
   $tbl = 1 ;                                                                   
   $TableHeadingChar = '*'                                                      
   /* Build all the ...pos variables from heading */                            
   Call Process_Trigger_Heading ;                                               
                                                                                
   WeHaveAnUpdate = 'N'                                                         
   Do t# = $tablerec.0 to 1 by -1                                               
      Say 'Examining Trigger entry for ',                                       
           Substr($tablerec.t#,Packagepos,16),                                  
           Substr($tablerec.t#,Destinationpos,08)                               
      Say '          for match with... ',                                       
           Left(Package,16) Left(Destination,08)                                
      If (Calltype = '#PSNFTPE' & ,                                             
          Substr($tablerec.t#,Stpos,01) /= 's')   then iterate ;                
      If Substr($tablerec.t#,Packagepos,16) /=,                                 
         Left(Package,16) then iterate ;                                        
      If Substr($tablerec.t#,Destinationpos,08) /= ,                            
                  Left(Destination,08) then iterate ;                           
      /* We have a match */                                                     
      If Calltype = '#PSNFTPE' then,                                            
         Do                                                                     
         /* Update Job number */                                                
         $tablerec.t# = Overlay(Jobnumber' ',$tablerec.t#,Jobnumberpos)         
         /* Update status     */                                                
         $tablerec.t# = Overlay('S',$tablerec.t#,Stpos)                         
         End;                                                                   
      Else,                                                                     
         $tablerec.t# = Overlay(Calltype,$tablerec.t#,Stpos) ;                  
      WeHaveAnUpdate = 'Y'                                                      
      msg='Updating ...                ',                                       
           Left(Package,16) Left(Destination,08)                                
      If Jobnumber /= '' then msg = msg,                                        
           ' Submitted job' Jobnumber                                           
      Say msg ;                                                                 
      Leave ;                                                                   
   End /*  Do t# = 1 to $tablerec. */                                           
                                                                                
   If WeHaveAnUpdate = 'Y' then,                                                
      "Execio * DISKW TRIGGER (Stem $tablerec. finis "                          
                                                                                
   Return ;                                                                     
                                                                                
/*                                                                    */        
/* Free the Trigger File                                */                      
/*                                                                    */        
                                                                                
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
                                                                                
Process_Trigger_Heading :                                                       
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
                                                                                
