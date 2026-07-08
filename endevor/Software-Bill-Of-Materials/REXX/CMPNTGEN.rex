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
                                                                                
                                                                                
max_RC = 0                                                                      
                                                                                
/*                                                                              
  Get Host Staging data sets to be inclueded in the SBOM                        
*/                                                                              
                                                                                
rcHS = Generate_Host_Staging_ds(ahjobdsn)                                       
if rcHS <> 0 then do                                                            
  say 'CMPGEN07E Error during Host Staging data set processing'                 
  return rcHS                                                                   
end                                                                             
                                                                                
ListBOUT_RC = ListPackageBackouts(packageID)                                    
                                                                                
if  ListBOUT_RC > 0 Then do                                                     
                                                                                
  say 'An error ocurred while getting Package Backout using Endevor API. '      
  return ListBOUT_RC                                                            
                                                                                
end                                                                             
                                                                                
/*                                                                              
  Create --generic-file-source for each Backout available in the                
  the Package                                                                   
*/                                                                              
Do ix = 1 to boutlst.0                                                          
                                                                                
  If Bout.FileType.ix = 'USS' Then Do                                           
                                                                                
    GenDS = Bout.USSPath.ix||Bout.USSFileName.ix                                
    Call SplitUSSPath(GenDS)                                                    
                                                                                
    queue "--generic-file-source "'"'"$(printf '%s'"                            
    do i = 1 TO SubDir.0                                                        
     queue '/'subdir.i                                                          
    end                                                                         
    queue ')"'                                                                  
                                                                                
   end /* if Bout.FileTYpe */                                                   
                                                                                
  else Do                                                                       
                                                                                
    GenDS = '"//'Bout.DataSetName.ix'('Bout.elemName.ix')"'                     
    queue '--generic-file-source 'GenDS                                         
                                                                                
  End /* else Bout.FileTYpe */                                                  
                                                                                
end /* Do ix */                                                                 
                                                                                
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
/* Procedures and Functions used in this REXX             */                    
/*                                                        */                    
/**********************************************************/                    
                                                                                
SplitUSSPath:                                                                   
/*                                                                              
  split a USSFile Path in subdirectories (SubDir. compound)                     
*/                                                                              
procedure expose SubDir.                                                        
parse arg USSFile                                                               
                                                                                
i = 0                                                                           
Do While length(USSFile) > 0                                                    
  i = i + 1                                                                     
  parse var USSFile  '/' SubDir.i '/'                                           
  USSFile = substr(USSFile,length(SubDir.i)+2)                                  
end                                                                             
SubDir.0 = i                                                                    
                                                                                
return                                                                          
                                                                                
                                                                                
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
                                                                                
      Select                                                                    
                                                                                
       When pos('SHIPMENT',ahref.refIx) <> 0 &,                                 
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
            newahjob.j = ' '||LEFT(JSONKey_HSDS,56)||' :'                       
                                                                                
            j = j + 1                                                           
            JSONVal_RSDS = '"'RemoteStagingDS'('member')",'                     
            newahjob.j = ' '||LEFT(JSONVal_RSDS,56)                             
                                                                                
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
                                                                                
        end /* SHIPMENT DATASETS  */                                            
                                                                                
       When pos('SHIPMENT',ahref.refIx) <> 0 &,                                 
            pos('USS',ahref.refIx)      <> 0 &,                                 
            pos('DIRECTORIES',ahref.refIx) <> 0 then do                         
                                                                                
         if pos('HOST',VALUE('ahref.'refIx+1))     <> 0 &,                      
            pos('PATH:',VALUE('ahref.'refIx+1))    <> 0 &,                      
            pos('HOST',VALUE('ahref.'refIx+2))     <> 0 &,                      
            pos('STAGING:',VALUE('ahref.'refIx+2)) <> 0 then do                 
                                                                                
                                                                                
                                                                                
           HSPath_Rec = VALUE('ahref.'refIx+2)                                  
           parse var HSPath_Rec . ,                                             
                     "HOST STAGING:" HostStagingPath .                          
                                                                                
           RSPath_Rec = VALUE('ahref.'refIx+3)                                  
           parse var RSPath_Rec . ,                                             
                     "REMO STAGING:"  RemoteStagingPath .                       
                                                                                
           RPath_Rec = VALUE('ahref.'refIx+4)                                   
           parse var RPath_Rec . ,                                              
                     "REMOTE PATH:"   RemotePath .                              
                                                                                
           refIx = refIx + 5                                                    
                                                                                
           /*                                                                   
             Get Files from Host Staging Path                                   
           */                                                                   
           dirCmd = 'ls 'HostStagingPath                                        
           call bpxwunix dirCmd,,files.                                         
                                                                                
           do k=1 to files.0                                                    
                                                                                
            file = strip(files.k)                                               
                                                                                
            JSONKey_HSPath = HostStagingPath||file                              
            Call SplitUSSPath(JSONKey_HSPath)                                   
                                                                                
            do jx = 1 TO SubDir.0                                               
                                                                                
             Select                                                             
                                                                                
              when jx = 1 Then Do                                               
                newahjob.j = ' "/'subdir.jx                                     
              end                                                               
                                                                                
              when jx = SubDir.0 then do                                        
                newahjob.j = '  /'subdir.jx'"   :'                              
              end                                                               
                                                                                
              otherwise                                                         
                newahjob.j = '  /'subdir.jx                                     
                                                                                
             end /* jx */                                                       
                                                                                
             j = j + 1                                                          
                                                                                
            end /* jx= 1 */                                                     
                                                                                
            JSONVal_RSPath = RemoteStagingPath||file                            
            Call SplitUSSPath(JSONVal_RSPath)                                   
                                                                                
            do jx = 1 TO SubDir.0                                               
                                                                                
             Select                                                             
                                                                                
              when jx = 1 Then Do                                               
                newahjob.j = ' "/'subdir.jx                                     
              end                                                               
                                                                                
              when jx = SubDir.0 then do                                        
                newahjob.j = '  /'subdir.jx'",'                                 
              end                                                               
                                                                                
              otherwise                                                         
                newahjob.j = '  /'subdir.jx                                     
                                                                                
             end /* jx */                                                       
                                                                                
             j = j + 1                                                          
                                                                                
            end /* jx= 1 */                                                     
                                                                                
                                                                                
           end /* Do k=1 */                                                     
                                                                                
           /*                                                                   
            Add HostStaging Path as a generic option for sbomz                  
           */                                                                   
           GENSeq  = GENSeq + 1                                                 
                                                                                
           GenericFile.GENSeq = '--generic-file-source "'||,                    
                                HostStagingPath||'"'                            
                                                                                
          end /* pos('HOST',VALUE('ahref.'refIx+1)) */                          
                                                                                
         else do                                                                
                                                                                
           refIx = refIx + 1                                                    
                                                                                
          end /* else pos('HOST',VALUE('ahref.'refIx+1)) */                     
                                                                                
       end /* SHIPMENT USS DIRECTORIES */                                       
                                                                                
       Otherwise                                                                
                                                                                
         refIx = refIx + 1                                                      
                                                                                
      end /* select */                                                          
                                                                                
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
              130 . ,                                                           
              133 Bout.FileType.i ,                                             
              136 . ,                                                           
              139 Bout.USSFileName.i ,/* if FileType = USS */                   
              394 . ,                                                           
              663 Bout.USSPath.i     ,/* if FileType = USS */                   
             1431 .                                                             
                                                                                
    Bout.elemName.i    = strip(Bout.elemName.i)                                 
    Bout.DataSetName.i = strip(Bout.DataSetName.i)                              
    Bout.FileType.i    = strip(Bout.FileType.i)                                 
    Bout.USSFileName.i = strip(Bout.USSFileName.i)                              
    Bout.USSPath.i     = strip(Bout.USSPath.i)                                  
                                                                                
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
