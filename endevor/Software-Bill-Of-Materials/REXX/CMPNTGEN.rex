/*REXX***************************************************************/          
/********************************************************************/          
/************/                                                                  
/* MAIN     */                                                                  
/************/                                                                  
parse upper arg packageID TransMethod                                           
trace off                                                                       
select                                                                          
  when TransMethod = 'LOCAL' then do                                            
    if ExistDDname('XLCC') Then Do                                              
      "execio * diskr xlcc (stem xlcc. finis"                                   
      if xlcc.0 = 0 then do                                                     
        say 'XLCC file is empty'                                                
        return 8                                                                
       End                                                                      
      parse var xlcc.1 . "'" ahjobdsn "'"                                       
     end                                                                        
    else do                                                                     
      Say 'CMPGEN01E DDname XLCC is not allocated.'                             
      Return 8                                                                  
     end                                                                        
  end /* when LOCAL */                                                          
  when TransMethod = 'NETVIEW_FTP' then do                                      
    if ExistDDname('XFTC') Then Do                                              
      "execio * diskr xftc (stem xftc. finis"                                   
      if xftc.0 = 0 then do                                                     
        say 'XFTC file is empty'                                                
        return 8                                                                
      End                                                                       
      do i = 1 to xftc.0                                                        
        if pos('PUT ',xftc.i)  <> 0 & ,                                         
           pos('AHJOB',xftc.i) <> 0 Then do                                     
            parse var xftc.i  . "PUT " ahjobdsn .                               
            parse var ahjobdsn "'" ahjobdsn "'"                                 
            ahjobdsn = strip(ahjobdsn)                                          
            leave                                                               
        end /* if pos */                                                        
      end /* do i */                                                            
     end                                                                        
    else do                                                                     
      Say 'CMPGEN01E DDname XFTC is not allocated.'                             
      Return 8                                                                  
     end                                                                        
  end /* when NETVIEW */                                                        
  when TransMethod = 'XCOM' then do                                             
    if ExistDDname('XXCC') Then Do                                              
      "execio * diskr xxcc (stem xxcc. finis"                                   
      if xxcc.0 = 0 then do                                                     
        say 'XXCC file is empty'                                                
        return 8                                                                
      End                                                                       
      do i = 1 to xxcc.0                                                        
        if pos('LFILE=',xxcc.i) <> 0 & ,                                        
           pos('AHJOB',xxcc.i)  <> 0  Then do                                   
           parse var xxcc.i  . "LFILE=" ahjobdsn .                              
           ahjobdsn = strip(ahjobdsn)                                           
           leave                                                                
        end /* if pos */                                                        
      end /* do i */                                                            
     end                                                                        
    else do                                                                     
      Say 'CMPGEN01E DDname XXCC is not allocated.'                             
      Return 8                                                                  
     end                                                                        
  end /* when XCOM */                                                           
  when TransMethod = 'NETWORK_DM' then do                                       
    if ExistDDname('XNWC') Then Do                                              
      "execio * diskr xnwc (stem xnwc. finis"                                   
      if xnwc.0 = 0 then do                                                     
        say 'xnwc file is empty'                                                
        return 8                                                                
      End                                                                       
      do i = 1 to xnwc.0                                                        
        if pos('DSN=',xnwc.i)  <> 0 & ,                                         
           pos('AHJOB',xnwc.i) <> 0  Then do                                    
           parse var xnwc.i  . "DSN=" ahjobdsn ")" .                            
           ahjobdsn = strip(ahjobdsn)                                           
           leave                                                                
        end /* if pos */                                                        
      end /* do i */                                                            
     end                                                                        
    else do                                                                     
      Say 'CMPGEN01E DDname xnwc is not allocated.'                             
      Return 8                                                                  
     end                                                                        
  end /* when NETWORK_DM */                                                     
  otherwise                                                                     
    say 'MODAHJOB01E Transmission method is not supported'                      
    return 12                                                                   
end /* Select */                                                                
/*                                                                              
  Alocation Check                                                               
*/                                                                              
if \ExistDDname('LISTPKGA') Then Do                                             
  Say 'CMPGEN01E DDname LISTPKGA is not allocated.'                             
  Return 8                                                                      
End                                                                             
if \ExistDDname('COMPTEMP') Then Do                                             
  Say 'CMPGEN01E DDname COMPTEMP is not allocated.'                             
  Return 8                                                                      
End                                                                             
if \ExistDDname('COMPNTS') Then Do                                              
  Say 'CMPGEN01E DDname COMPNTS is not allocated.'                              
  Return 8                                                                      
End                                                                             
if \ExistDDname('GENFILES') Then Do                                             
  Say 'CMPGEN01E DDname GENFILES is not allocated.'                             
  Return 8                                                                      
End                                                                             
if \ExistDDname('BOUTLST') Then Do                                              
  Say 'CMPGEN02E DDname BOUTLST is not allocated.'                              
  Return 8                                                                      
End                                                                             
if \ExistDDname('C1MSGS1') Then Do                                              
  Say 'CMPGEN02E DDname C1MSGS1 is not allocated.'                              
  Return 8                                                                      
End                                                                             
if \ExistDDname('bstipt01') Then Do                                             
  Say 'CMPGEN02E DDname bstipt01 is not allocated.'                             
  Return 8                                                                      
End                                                                             
if \ExistDDname('ahjobdsn') Then Do                                             
  Say 'CMPGEN02E DDname ahjobdsn is not allocated.'                             
  Return 8                                                                      
End                                                                             
"Execio * Diskr LISTPKGA (Stem listpkga. finis"                                 
ExecioRC = RC                                                                   
If ExecioRC > 0 Then Do                                                         
  Say 'CMPGEN04E Error reading file LISTPKGA. ',                                
      'rc: 'ExecioRC                                                            
  Return ExecioRC                                                               
End                                                                             
if listpkga.0 = 0 then Do                                                       
    Say 'CMPGEN05E Package Actions dataset is empty.'                           
    Return 12                                                                   
End                                                                             
delimiter = ',' /* Change to the C2D(...) function for                          
                   some characters like tab */                                  
quotation_mark = '"'                                                            
ndvrparm = 'C1BM3000'                                                           
NoBackout = 0                                                                   
GenFileDS. = ''                                                                 
GenIX = 0                                                                       
max_RC = 0                                                                      
/* integer_style = 1 */                                                         
/*                                                                              
  Get Host Staging data sets to be inclueded in the SBOM                        
*/                                                                              
rcHS = Generate_Host_Staging_ds(ahjobdsn)                                       
if rcHS <> 0 then do                                                            
  say 'CMPGEN07E Error during Host Staging data set processing'                 
  return rcHS                                                                   
end                                                                             
/*                                                                              
  Process the output generated by LIST PACKAGE ACTION                           
*/                                                                              
call parsecsv csv_file                                                          
if csv.0 > 0 then do                                                            
  /* total contain the name or number of the first column,                      
     we reuse the variable and dont use another */                              
  total = csv.1                                                                 
  /* we assume that every column contain equally many rows */                   
  total = value( 'csv.'total'.0' )                                              
end                                                                             
else return 0                                                                   
if  ListPackageBackouts(packageID) > 0 Then do                                  
  say 'An error ocurred while getting Package Backout using Endevor API. '      
end                                                                             
/*                                                                              
  Process every action included in the Package                                  
*/                                                                              
CompFound = 0                                                                   
do i = 1 to total                                                               
  "NEWSTACK"                                                                    
  queue 'SET STOPRC 12 . '                                                      
  queue 'PRINT ELEMENT "'csv.ELM__T_.i'" TO DDN COMPTEMP'                       
  queue '      FROM ENVIRONMENT "'csv.ENV_NAME__T_.i'"'                         
  queue '      SYSTEM "'csv.SYS_NAME__T_.i'"'                                   
  queue '      SUBSYSTEM "'csv.SBS_NAME__T_.i'"'                                
  queue '      TYPE "'csv.TYPE_NAME__T_.i'"'                                    
  queue '      STAGE 'csv.STG_#__T_.i                                           
  queue '      OPTIONS NOCC COMPONENTS'                                         
  queue '.'                                                                     
  "execio" queued() "diskw bstipt01 (finis"                                     
  "DELSTACK"                                                                    
  address TSO "call *(ndvrc1) '"||ndvrparm||"'"                                 
  ndvr_RC = rc                                                                  
  /*******************************************************************/         
  /* Validate RC from Endevor                                        */         
  /*******************************************************************/         
  select                                                                        
    when ndvr_RC = 0 then do                                                    
      "execio * diskr comptemp (stem comptemp. finis"                           
      do ix = 1 TO comptemp.0                                                   
        say strip(comptemp.ix,'T')                                              
      end                                                                       
      CompFound = 1                                                             
      OutputComponents. = ''                                                    
      call getOutputComponents                                                  
      call MatchBackout csv.ELM__T_.i                                           
      "execio * diskw COMPNTS (stem comptemp. "                                 
    end                                                                         
    when ndvr_RC = 4  then do                                                   
      max_RC = ndvr_RC                                                          
      "execio * diskr c1msgs1 (stem c1msgs1. finis"                             
      do ix = 1 TO c1msgs1.0                                                    
        say strip(c1msgs1.ix,'T')                                               
      end                                                                       
    end /* when ndvr_RC = 4 */                                                  
    otherwise                                                                   
      say ' PRINT ELEMENT COMPONENT rc higher than 4 'ndvr_RC                   
      return ndvr_RC                                                            
  end /* Select */                                                              
End /* do i = 1 to total */                                                     
/* Validate for Components in any elements included in the Pkg */               
if \CompFound Then DO                                                           
  queue '**********************************************************'            
  queue '**                                                      **'            
  queue '** No components found in any of the elements included  **'            
  queue '** in the Package.                                      **'            
  queue '**                                                      **'            
  queue '**********************************************************'            
  "execio" queued() "diskw COMPNTS (finis"                                      
end /* CompFound */                                                             
Do ix = 1 to boutlst.0                                                          
  If Bout.Used.ix = 'N' then do                                                 
    GenDS = '"//'strip(Bout.DataSetName.ix)'('Bout.elemName.ix')"'              
    queue '--generic-file-source 'GenDS                                         
  end                                                                           
end                                                                             
queue '/*'                                                                      
"execio * diskw GENFILES (finis"                                                
/*                                                                              
  write ahjob data set name for future use                                      
*/                                                                              
queue ahjobdsn                                                                  
"execio" queued() "diskw ahjobdsn (finis"                                       
return max_RC                                                                   
/**********************************************************/                    
/*                                                        */                    
/* Procedimientos y Funciones utilizados en el REXX       */                    
/*                                                        */                    
/**********************************************************/                    
/*                                                                              
  Procedure Generate_Host_Staging_ds: generate SBOM genfiles commands   nt      
  for every host staging data set in the package shipment                       
*/                                                                              
Generate_Host_Staging_ds:                                                       
arg ahjobdsn                                                                    
alloc = "alloc fi('AHJOB') "                                                    
alloc = alloc||"da('"ahjobdsn"') shr msg(2)"                                    
call bpxwdyn alloc                                                              
allocRc = Result                                                                
if allocRc <> 0 then do                                                         
  say 'CMPGEN06E allocation error ddname AHJOB. rc: 'allocRC                    
  return allocRC                                                                
End                                                                             
"execio * diskr ahjob (stem ahjob. finis"                                       
i = 1                                                                           
Found256 = 0                                                                    
do while i <= ahjob.0                                                           
 if pos('//SHIPRMAP',ahjob.i) <> 0 then do                                      
  Found256 = 1                                                                  
  Select                                                                        
   when pos('DD',ahjob.i)<>0 & pos('*',ahjob.i)<>0 then do                      
     j = 1                                                                      
     do while j < i                                                             
       newahjob.j = ahjob.j                                                     
       j = j + 1                                                                
     end                                                                        
     newahjob.j = '//SHIPRMAP DD   *'                                           
     GenSeq = 0                                                                 
     j = j +1                                                                   
     newahjob.j = '{'                                                           
     j = j +1                                                                   
     LastQual = LASTPOS('.',ahjobdsn)                                           
     Head_DS  = substr(ahjobdsn,1,LastQual-1)                                   
     Tail_DS  = substr(ahjobdsn,LastQual+1)                                     
     ahrefdsn = Head_DS||'.'||'AHREF'                                           
     alloc = "alloc fi('AHREF') "                                               
     alloc = alloc||"da('"ahrefdsn"') shr msg(2)"                               
     call bpxwdyn alloc                                                         
     allocRc = Result                                                           
     if allocRc <> 0 then do                                                    
       say 'CMPGEN06E allocation error ddname AHREF. rc: 'allocRC               
       return allocRC                                                           
     End                                                                        
     "execio * diskr ahref (stem ahref. finis"                                  
     if ahref.0 = 0 then do                                                     
       say 'CMPGEN10E AHREF Shipment data set is empty.'                        
       return 12                                                                
     End                                                                        
     refIx = 1                                                                  
     do while refIx < ahref.0                                                   
       if pos('SHIPMENT',ahref.refIx) <> 0 &,                                   
          pos('DATASETS',ahref.refIx) <> 0 then do                              
         if pos('HOST',VALUE('ahref.'refIx+1))     <> 0 &,                      
            pos('LIBRARY:',VALUE('ahref.'refIx+1)) <> 0 &,                      
            pos('HOST',VALUE('ahref.'refIx+2))     <> 0 &,                      
            pos('STAGING:',VALUE('ahref.'refIx+2)) <> 0 then do                 
           HSDS_Rec = VALUE('ahref.'refIx+2)                                    
           parse var HSDS_Rec . ,                                               
                     "HOST  STAGING:"  HostStagingDS .                          
           RSDS_Rec = VALUE('ahref.'refIx+3)                                    
           parse var RSDS_Rec . ,                                               
                     "REMOTE STAGING:"  RemoteStagingDS .                       
           RLDS_Rec = VALUE('ahref.'refIx+4)                                    
           parse var RLDS_Rec . ,                                               
                     "REMOTE LIBRARY:"  RemoteLibraryDS .                       
           refIx = refIx + 5                                                    
           /*                                                                   
             List Host Staging Data Set members                                 
           */                                                                   
           x = outtrap(dirList.)                                                
           address TSO "listds '"HostStagingDS"' members"                       
           x = outtrap(off)                                                     
           k = 1                                                                
           do while pos('--MEMBERS--',dirList.k) = 0                            
            k = k + 1                                                           
           end                                                                  
           do k = k + 1 to dirList.0                                            
            member = strip(dirList.k)                                           
            JSONKey_HSDS = '"'HostStagingDS'('member')"'                        
            newahjob.j = '    '||LEFT(JSONKey_HSDS,56)||' :'                    
            j = j + 1                                                           
            JSONVal_RSDS = '"'RemoteStagingDS'('member')",'                     
            newahjob.j = '    '||LEFT(JSONVal_RSDS,56)                          
            j = j + 1                                                           
           end /* K = 7 */                                                      
           /* */                                                                
           /*                                                                   
            Add HostStaging Data set as a generic option for sbomz              
           */                                                                   
           GENSeq  = GENSeq + 1                                                 
           GenericFile.GENSeq = '--generic-file-source "//'||,                  
                                HostStagingDS||'"'                              
          end /* pos('HOST',VALUE('ahref.'refIx+1)) */                          
         else do                                                                
           refIx = refIx + 1                                                    
          end /* else pos('HOST',VALUE('ahref.'refIx+1)) */                     
        end /* pos('SHIPMENT',ahref.refIx) */                                   
       else do                                                                  
         refIx = refIx + 1                                                      
        end /* else pos('SHIPMENT',ahref.refIx) */                              
     end /* while ref < ahref.0 */                                              
     tmpJ = j - 1                                                               
     newahjob.tmpJ = TRANSLATE(newahjob.tmpJ,'',',')                            
     newahjob.j = '}'                                                           
     j = j +1                                                                   
     i = i + 1                                                                  
     do while i <= ahjob.0                                                      
       newahjob.j = ahjob.i                                                     
       j = j + 1                                                                
       i = i + 1                                                                
     end /* while i <= ahjob.0 */                                               
     newahjob.0 = j - 1                                                         
     GenericFile.0 = GENSeq                                                     
     "execio * diskw ahjob (stem newahjob. finis"                               
     leave                                                                      
   end /* when  pos('DD',ahjob.i)<>0 */                                         
   Otherwise                                                                    
     say 'CMPGEN09E SHIPRMAP DDname bad format.'                                
     return 12                                                                  
  end /* Select */                                                              
 end /* if SHIPRMAP */                                                          
 i = i + 1                                                                      
end /* i = 1 to ahjob.0  */                                                     
if Found256 Then do                                                             
    "execio * diskw hoststg (stem GenericFile. finis"                           
    return 0                                                                    
 end                                                                            
else do                                                                         
   say 'CMPGEN08E DDNAME SHIPRMAP is not included in AHJOB file.'               
   return 8                                                                     
 end                                                                            
/*                                                                              
  Procedure parsegetOutputComponents: get output components for an element      
  from a file                                                                   
*/                                                                              
getOutputComponents:                                                            
OutNum = 0                                                                      
Do ik = 1 to comptemp.0                                                         
  If pos('OUTPUT COMPONENTS',comptemp.ik) <> 0 then do                          
    OutIX = ik + 1                                                              
    Do while OutIX <= comptemp.0                                                
      If pos('STEP:',comptemp.OutIX) <> 0 &,                                    
         pos('DD=',comptemp.OutIX)   <> 0 &,                                    
         pos('VOL=',comptemp.OutIX)  <> 0 &,                                    
         pos('DSN=',comptemp.OutIX)  <> 0 then do                               
          OutNum = OutNum + 1                                                   
          parse var comptemp.OutIx . 'DSN=' OutputComponentDSN                  
          OutputComponents.OutNum = strip(OutputComponentDSN)                   
      end                                                                       
      OutIx = OutIx + 1                                                         
    end /* do while*/                                                           
    OutputComponents.0 = OutNum                                                 
    leave                                                                       
  end                                                                           
end /* do ik */                                                                 
return                                                                          
/*                                                                              
  Procedure MatchBackout: match package backouts against element output         
  component                                                                     
*/                                                                              
MatchBackout:                                                                   
arg element                                                                     
Do OutCompIX = 1 to OutputComponents.0                                          
  Do backoutIX = 1 to boutlst.0                                                 
    if OutputComponents.OutCompIX = Bout.DataSetName.backoutIX & ,              
       element = Bout.elemName.backoutIX then do                                
       Bout.Used.backoutIX = 'Y'                                                
       leave                                                                    
    end                                                                         
  end                                                                           
end                                                                             
return                                                                          
/*                                                                              
  Procedure parsecsv file by column name in stem vars                           
*/                                                                              
parsecsv:                                 ,                                     
procedure expose csv. listpkga. delimiter quotation_mark integer_style          
/* trace i */                                                                   
f_name = arg(1)                                                                 
csv.0 = 0                                                                       
i = 0                                                                           
K = 1                                                                           
/*                                                                              
  Translate special character not accepted as part as a compound                
  variable.                                                                     
*/                                                                              
do while k <= listpkga.0                                                        
  if i = arg(2) then return 0                                                   
  /* only parse a few rows specified by arg(2) */                               
  input = Strip(listpkga.k)                                                     
  if k=1 then do                                                                
    input = Translate(input,'_',' ')                                            
    input = Translate(input,'_',')')                                            
    input = Translate(input,'_','(')                                            
    input = Translate(input,'_','/')                                            
  End                                                                           
  j = 0                                                                         
  do while length( input ) > 0                                                  
    parse value input with i_val(delimiter)input                                
    j = j + 1                                                                   
    if csv.0 = 0 then do                                                        
      /* build "header", use the names on the first row                         
         specifying the column names */                                         
      if value( integer_style ) <> 'INTEGER_STYLE' then do                      
         csv.j = j                                                              
         c_val = csv.j                                                          
      end                                                                       
      else do                                                                   
          csv.j = translate(strip(strip(i_val,,quotation_mark)))                
          c_val = csv.j                                                         
      end                                                                       
    end                                                                         
    else do                                                                     
    /* build the rows, use the names found on the first rows */                 
      c_val = translate( csv.j )                                                
      call value 'csv.'c_val'.'i, strip( i_val,, quotation_mark )               
    end                                                                         
    call value 'csv.'c_val'.0', i                                               
  end /* length( input ) */                                                     
  if csv.0 = 0 then                                                             
      csv.0 = j                                                                 
  i = i + 1                                                                     
  k = k + 1                                                                     
end /* while i < csvfile.0 */                                                   
return                                                                          
/*                                                                              
  Procedure ListPackageBackouts                                                 
*/                                                                              
ListPackageBackouts:                                                            
procedure expose boutlst. Bout.                                                 
arg packageID                                                                   
/* List Package Backout */                                                      
address attchmvs "c1lstbko packageID"                                           
API_rc = rc                                                                     
If API_rc <> 0 Then Do                                                          
  say 'No Backout information from Package 'packageID                           
  return API_rc                                                                 
 End                                                                            
Else Do                                                                         
  "execio * diskr boutlst (stem boutlst. finis"                                 
  do i = 1 TO boutlst.0                                                         
    parse var boutlst.i . ,                                                     
              62 Bout.elemName.i ,                                              
              70 . ,                                                            
              86 Bout.DataSetName.i ,                                           
              130 .                                                             
    Bout.Used.i = 'N'                                                           
   /* say strip(boutlst.i,'T') */                                               
  end                                                                           
  return 0                                                                      
 End                                                                            
/*                                                                              
  Procedure ExistDDname allocated                                               
*/                                                                              
ExistDDname: Procedure                                                          
arg search4dd                                                                   
last1 = 0                                                                       
dsnlist = ''                                                                    
Found = 0                                                                       
Do i = 1 by 1 Until (last1 /= 0)                                                
   Call bpxwdyn 'info inrelno('i') inrtddn(found_dd)',                          
                'inrtlst(last1)'                                                
   If found_dd = search4dd Then                                                 
     Do                                                                         
       Found = 1                                                                
       leave                                                                    
     End                                                                        
End                                                                             
Return found                                                                    
