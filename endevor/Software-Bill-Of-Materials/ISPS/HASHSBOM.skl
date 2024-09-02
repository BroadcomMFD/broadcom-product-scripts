/* REXX */                                                                      
trace r                                                                         
VERBOSE = 0                                                                     
/* Get Web Enablement Toolkit REXX constants */                                 
 call HTTP_getToolkitConstants                                                  
 if RESULT <> 0 then                                                            
    exit fatalError( '** SBOMHASH90E Environment error **' )                    
                                                                                
/* Initialize variables used in program */                                      
 call InitializeVars                                                            
                                                                                
 return main()                                                                  
                                                                                
                                                                                
/***********************************************/                               
/* Function:  main                             */                               
/*                                             */                               
/* help implementing new functionalities       */                               
/* using as example a json text read from a    */                               
/* file.                                       */                               
/*                                             */                               
/* Returns: 0 if successful, -1 if not.        */                               
/***********************************************/                               
                                                                                
main:                                                                           
                                                                                
/* Validate the JSON Text read from ddname JSONIN         */                    
                                                                                
address mvs "execio * diskr hash256 (stem hash256. finis"                       
                                                                                
i = 1                                                                           
j = 1                                                                           
Do while i<= hash256.0                                                          
                                                                                
  parse var hash256.i shipRef HostStagingDS                                     
                                                                                
  shipRef = strip(shipRef)                                                      
  HostStagingDS = strip(HostStagingDS)                                          
                                                                                
  if pos('HASH',shipRef) <> 0 then do                                           
   if HostStagingDS <> '' then do                                               
      RemoteStagingDS = strip(value('hash256.'i+1))                             
      RemoteProdDS = strip(value('hash256.'i+2))                                
                                                                                
      If RemoteStagingDS <> '' & RemoteProdDS <> '' then do                     
         ShipHostStagingDS.j   = HostStagingDS                                  
         ShipRemoteStagingDS.j = RemoteStagingDS                                
         ShipRemoteProdDS.j    = RemoteProdDS                                   
         j = j + 1                                                              
         i = i + 3                                                              
       end                                                                      
      else do                                                                   
         say 'SBOMHASH01E Host staging Data Set is not included in the' ,       
             'HSAH256 ddname'                                                   
         return 8                                                               
      end                                                                       
                                                                                
    end                                                                         
   Else do                                                                      
     say 'SBOMHASH01E Host staging Data Set is not included in the',            
         'HSAH256 ddname'                                                       
     return 8                                                                   
    end                                                                         
   end                                                                          
  Else do                                                                       
     say 'SBOMHASH02E There is not shipping reference in this line of',         
         'hash256 ddname.'                                                      
     return 8                                                                   
   end                                                                          
                                                                                
End /*do while i<= hash256.0*/                                                  
                                                                                
j = j - 1                                                                       
ShipHostStagingDS.0   = j                                                       
ShipRemoteStagingDS.0 = j                                                       
ShipRemoteProdDS.0    = j                                                       
                                                                                
                                                                                
/* Validate the JSON Text read from ddname JSONIN         */                    
                                                                                
address mvs "execio * diskr JSONIN (stem jsonIN. finis"                         
                                                                                
jsonTEXT = ''                                                                   
Do I=1 to jsonIN.0                                                              
  jsonTEXT = jsonText || strip(jsonIN.i)                                        
End                                                                             
                                                                                
/* write JSON string to an output dataset */                                    
/* queue jsontext                                                               
queue ''                                                                        
"execio * diskw JSONOUT (finis" */                                              
                                                                                
/* say ''                                                                       
say 'JSON Text read from File: '                                                
say ''                                                                          
say jsonTEXT                                                                    
say '' */                                                                       
                                                                                
/*                                                        */                    
/*                                                        */                    
call JSON_initParser                                                            
                                                                                
if RESULT <> 0 then                                                             
   return fatalError( '** Pre-processing error (parser init failure) **' )      
                                                                                
/****************************/                                                  
/* Parse the response data. */                                                  
/****************************/                                                  
call JSON_parse jsonTEXT                                                        
if RESULT <> 0 then                                                             
   do                                                                           
      call JSON_termParser                                                      
      return fatalError( '** Error while parsing Input JSON Text **' )          
   end                                                                          
                                                                                
call get_SBOM_HASHES jsonTEXT                                                   
if RESULT <> 0 then                                                             
   do                                                                           
      call JSON_termParser                                                      
      return fatalError( '** Error while processing SBOM  **' )                 
   end                                                                          
                                                                                
call JSON_termParser                                                            
                                                                                
/*do i=1 to ShipHostStagingDS.0                                                 
   say ''                                                                       
   say 'ShipHostStagingDS.'i':   'ShipHostStagingDS.i                           
   say 'ShipRemoteStagingDS.'i': 'ShipRemoteStagingDS.i                         
   say 'ShipRemoteProdDS.'i':    'ShipRemoteProdDS.i                            
end                                                                             
                                                                                
do i=1 to SBOMHostStaging_DS.0                                                  
   say ''                                                                       
   say 'SBOMHostStaging_DS.'i':   'SBOMHostStaging_DS.i                         
   say 'SBOMHostStagingDS_HASH.'i': 'SBOMHostStagingDS_HASH.i                   
   say ''                                                                       
end */                                                                          
                                                                                
call build_HASH_Table                                                           
if RESULT <> 0 then                                                             
   do                                                                           
      return fatalError( '** Error found while building HASH Table **' )        
   end                                                                          
                                                                                
address mvs "execio * diskw hashout (stem HASH_Table. finis"                    
                                                                                
/* do i = 1 to  HASH_Table.0                                                    
   say 'Hash Table.'i': ' HASH_Table.i                                          
end */                                                                          
                                                                                
return 0                                                                        
                                                                                
                                                                                
/**********************************************************/                    
/* Function: build_HASH_Table                             */                    
/*                                                        */                    
/* Initializes the global parserHandle variable via       */                    
/* call to toolkit service HWTJINIT.                      */                    
/*                                                        */                    
/* Returns: 0 if successful, -1 if unsuccessful           */                    
/**********************************************************/                    
build_HASH_Table:                                                               
                                                                                
ix = 0                                                                          
do i=1 to ShipRemoteStagingDS.0                                                 
                                                                                
   x = outtrap(dirList.)                                                        
    address TSO "listds '"ShipRemoteStagingDS.i"' members"                      
   x = outtrap(off)                                                             
                                                                                
   k = 1                                                                        
   do while pos('--MEMBERS--',dirList.k) = 0                                    
    k = k + 1                                                                   
   end                                                                          
                                                                                
   do k = k + 1 to dirList.0 /* 1 to 6 contains info abt the pds */             
                                                                                
      member = strip(dirList.k)                                                 
                                                                                
      j=1                                                                       
      Found = 0                                                                 
      do while j <= SBOMHostStaging_DS.0                                        
                                                                                
      /* say ''                                                                 
         say 'ShipHostStagingDS.'i': 'ShipHostStagingDS.i||'('||member||')'     
         say 'SBOMHostStaging_DS.'j':'SBOMHostStaging_DS.j                      
         say '' */                                                              
         if ShipHostStagingDS.i||'('||member||')' = ,                           
            SBOMHostStaging_DS.j then do                                        
                                                                                
            Found = 1                                                           
            leave                                                               
                                                                                
         end                                                                    
         j = j + 1                                                              
      end /* do j=1 */                                                          
                                                                                
      If Found then do                                                          
                                                                                
         ix = ix + 1                                                            
         HASH_Table.ix = "SHA256 (//'"||,                                       
                         ShipRemoteStagingDS.i||"("||member||")') = "||,        
                         SBOMHostStagingDS_HASH.j                               
                                                                                
       end                                                                      
      else do                                                                   
         say 'No HASH value found for 'ShipHostStagingDS.i||'('||member||,      
              ') in the SBOM.'                                                  
         return 8                                                               
       end                                                                      
                                                                                
   end /* K = 7 */                                                              
                                                                                
end /* i=1 */                                                                   
                                                                                
HASH_Table.0 = ix                                                               
                                                                                
return 0                                                                        
/**********************************************************/                    
/* Function: JSON_initParser                              */                    
/*                                                        */                    
/* Initializes the global parserHandle variable via       */                    
/* call to toolkit service HWTJINIT.                      */                    
/*                                                        */                    
/* Returns: 0 if successful, -1 if unsuccessful           */                    
/**********************************************************/                    
JSON_initParser:                                                                
 if VERBOSE then                                                                
    say 'Initializing Json Parser'                                              
 /***********************************/                                          
 /* Call the HWTJINIT toolkit api.  */                                          
 /***********************************/                                          
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwtjson "hwtjinit ",                                                   
                 "ReturnCode ",                                                 
                 "handleOut ",                                                  
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call JSON_surfaceDiag 'hwtjinit', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtjinit failure **' )                               
    end  /* endif hwtjinit failure */                                           
 parserHandle = handleOut                                                       
 if VERBOSE then                                                                
    say 'Json Parser init (hwtjinit) succeeded'                                 
 return 0  /* end function */                                                   
                                                                                
                                                                                
/**********************************************************************/        
/* Function:  JSON_parse                                              */        
/*                                                                    */        
/* Parses the input text body (which should be syntactically correct  */        
/* JSON text) via call to toolkit service HWTJPARS.                   */        
/*                                                                    */        
 /* Returns: 0 if successful, -1 if unsuccessful                      */        
/**********************************************************************/        
JSON_parse:                                                                     
 jsonTextBody = arg(1)                                                          
  if VERBOSE then                                                               
    say 'Invoke Json Parser'                                                    
 /**************************************************/                           
 /* Call the HWTJPARS toolkit api.                 */                           
 /* Parse scans the input text body and creates an */                           
 /* internal representation of the JSON data,      */                           
 /* suitable for search and create operations.     */                           
 /**************************************************/                           
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwtjson "hwtjpars ",                                                   
                 "ReturnCode ",                                                 
                 "parserHandle ",                                               
                 "jsonTextBody ",                                               
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call JSON_surfaceDiag 'hwtjpars', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtjpars failure **' )                               
    end  /* endif hwtjpars failure */                                           
 if VERBOSE then                                                                
    say 'JSON data parsed successfully'                                         
 return 0  /* end function */                                                   
                                                                                
                                                                                
/**********************************************************************/        
/* Function:  get_SBOM_HASHES                                         */        
/*                                                                    */        
/* Process the sbom parsed by json parser                             */        
/**********************************************************************/        
get_SBOM_HASHES:                                                                
jsonTextBody = arg(1)                                                           
                                                                                
if VERBOSE then                                                                 
   say 'Process_SBOM'                                                           
                                                                                
metadata        = JSON_findValue(0,,                                            
                                 "metadata",,                                   
                                 HWTJ_OBJECT_TYPE)                              
                                                                                
component       = JSON_findValue(metadata,,                                     
                                 "component",,                                  
                                 HWTJ_OBJECT_TYPE)                              
                                                                                
componentsList  = JSON_findValue(component,,                                    
                                 "components",,                                 
                                 HWTJ_ARRAY_TYPE)                               
                                                                                
                                                                                
address hwtjson "hwtjgnue ",                                                    
                "ReturnCode ",                                                  
                "parserHandle ",                                                
                "ComponentsList ",                                              
                "NumOfComponents ",                                             
                "DiagArea."                                                     
                                                                                
RexxRC = RC                                                                     
                                                                                
if JSON_isError(RexxRC,ReturnCode) then do                                      
   call JSON_surfaceDiag 'hwtjgnue', RexxRC, ReturnCode, DiagArea.              
   return fatalError( '** hwtjgnue failure **' )                                
 end  /* endif hwtjinit failure */                                              
                                                                                
/* Say 'Number of Components Element in SBOM: 'NumOfComponents                  
say '' */                                                                       
                                                                                
/* Process each element of the array of objects */                              
trace off                                                                       
                                                                                
J = 1                                                                           
do component#=0 to  NumOfComponents-1                                           
                                                                                
  address hwtjson  "hwtjgaen ",                                                 
                    "ReturnCode ",                                              
                    "ParserHandle ",                                            
                    "componentsList ",                                          
                    "component# ",                                              
                    "EntryValueHandle",                                         
                    "DiagArea."                                                 
                                                                                
  RexxRC = RC                                                                   
  if JSON_isError(RexxRC,ReturnCode) then do                                    
       call JSON_surfaceDiag 'hwtjgaen', RexxRC, ReturnCode, DiagArea.          
       return fatalError( '** hwtjgaen failure **' )                            
   end  /* endif hwtjinit failure */                                            
                                                                                
                                                                                
  /* Bom_Ref     = JSON_findValue( EntryValueHandle,                            
                               ,"bom-ref" ,                                     
                               ,HWTJ_STRING_TYPE)                               
                                                                                
  say 'bom-ref: 'Bom_Ref */                                                     
                                                                                
  hashesList = JSON_findValue(EntryValueHandle,,                                
                             "hashes",,                                         
                             HWTJ_ARRAY_TYPE)                                   
                                                                                
  if hashesList <> '(not found)' & hashesList <> '' Then do                     
                                                                                
      address hwtjson "hwtjgnue ",                                              
                        "ReturnCode ",                                          
                        "parserHandle ",                                        
                        "hashesList ",                                          
                        "NumOfhashes ",                                         
                        "DiagArea."                                             
                                                                                
      RexxRC = RC                                                               
                                                                                
      if JSON_isError(RexxRC,ReturnCode) then do                                
         call JSON_surfaceDiag 'hwtjgnue', RexxRC, ReturnCode, DiagArea.        
         return fatalError( '** hwtjgnue failure **' )                          
         end  /* endif hwtjinit failure */                                      
                                                                                
                                                                                
      /* Say 'Number of hashes for component: 'NumOfhashes                      
      say '' */                                                                 
                                                                                
      do hash#=0 to NumOfHashes-1                                               
                                                                                
         address hwtjson  "hwtjgaen ",                                          
                           "ReturnCode ",                                       
                           "ParserHandle ",                                     
                           "hashesList ",                                       
                           "hash# ",                                            
                           "EntryValueHandle1 ",                                
                           "DiagArea."                                          
                                                                                
         RexxRC = RC                                                            
         if JSON_isError(RexxRC,ReturnCode) then do                             
               call JSON_surfaceDiag 'hwtjgaen', RexxRC, ReturnCode, DiagArea.  
               return fatalError( '** hwtjgaen failure **' )                    
         end  /* endif hwtjinit failure */                                      
                                                                                
         algorithm = JSON_findValue( EntryValueHandle1,                         
                                    ,"alg" ,                                    
                                    ,HWTJ_STRING_TYPE)                          
                                                                                
         HASH      = JSON_findValue( EntryValueHandle1,                         
                                    ,"content" ,                                
                                    ,HWTJ_STRING_TYPE)                          
         /* say ''                                                              
         say 'algorithm: 'algorithm                                             
         say 'HASH: ' HASH */                                                   
         SBOMHostStagingDS_HASH.j = HASH                                        
                                                                                
      end /* do hash */                                                         
                                                                                
      DS_Name     = JSON_findValue( EntryValueHandle,                           
                                  ,"name" ,                                     
                                  ,HWTJ_STRING_TYPE)                            
                                                                                
      /* say 'name: 'DS_Name */                                                 
      parse var DS_Name "//'" DS_Name "'"                                       
      SBOMHostStaging_DS.j = DS_Name                                            
      j = j + 1                                                                 
   end                                                                          
  Else do                                                                       
    If hashesList = '' then do                                                  
       call JSON_surfaceDiag 'hwtjsrch', RexxRC, ReturnCode, DiagArea.          
       return fatalError( '** hwtjsrch hashes failure **' )                     
    end                                                                         
  end                                                                           
                                                                                
end /*component# */                                                             
                                                                                
j = J - 1                                                                       
SBOMHostStaging_DS.0 = J                                                        
SBOMHostStagingDS_HASH.0 = J                                                    
                                                                                
                                                                                
return 0                                                                        
                                                                                
/******************************************************************/            
/* Function:  JSON_findValue                                      */            
/*                                                                */            
/* Searches the appropriate portion of the parsed JSON data (that */            
/* designated by the objectToSearch argument) for an entry whose  */            
/* name matches the designated searchName argument.  Returns a    */            
/* value or handle, depending on the expectedType.                */            
/*                                                                */            
/* Returns: value or handle as described above, or  a null result */            
/* if no suitable value or handle is found.                       */            
/******************************************************************/            
JSON_findValue:                                                                 
 objectToSearch = arg(1) /* 0 */                                                
 searchName = arg(2)     /* label */                                            
 expectedType = arg(3)   /* tipo de dato */                                     
                                                                                
/*********************************************************/                     
/* Trying to find a value for a null entry is perhaps a  */                     
/* bit nonsensical, but for completeness we include the  */                     
/* possibility.  We make an arbitrary choice on what to  */                     
/* return, and do this first, to avoid wasted processing */                     
/*********************************************************/                     
 if expectedType == HWTJ_NULL_TYPE then                                         
    return '(null)'                                                             
 if VERBOSE then                                                                
    say 'Invoke Json Search'                                                    
 /********************************************************/                     
 /* Search the specified object for the specified name.  */                     
 /* The value 0 is specified (for the "startingHandle")  */                     
 /* to indicate that the search should start at the      */                     
 /* beginning of the designated object.                  */                     
 /********************************************************/                     
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwtjson "hwtjsrch ",                                                   
                 "ReturnCode ",                                                 
                 "parserHandle ",                                               
                 "HWTJ_SEARCHTYPE_OBJECT ",                                     
                 "searchName ",                                                 
                 "objectToSearch ",                                             
                 "0 ",                                                          
                 "searchResult ",                                               
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 /************************************************************/                 
 /* Differentiate a not found condition from an error, and   */                 
 /* tolerate the former.  Note the order dependency here,    */                 
 /* at least as the called routines are currently written.   */                 
 /************************************************************/                 
 if JSON_isNotFound(RexxRC,ReturnCode) then                                     
    return '(not found)'                                                        
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call JSON_surfaceDiag 'hwtjsrch', RexxRC, ReturnCode, DiagArea.             
    say '** hwtjsrch failure **'                                                
    return ''                                                                   
    end /* endif hwtjsrch failed */                                             
 /******************************************/                                   
 /* Verify the type of the search result   */                                   
 /******************************************/                                   
 resultType = JSON_getType( searchResult )                                      
 if resultType <> expectedType then                                             
    do                                                                          
    say '** Type mismatch ('||resultType||','||expectedType||') **'             
    return ''                                                                   
    end /* endif unexpected type */                                             
 /******************************************************/                       
 /* Return the located object or array, as appropriate */                       
 /******************************************************/                       
 if expectedType == HWTJ_OBJECT_TYPE | expectedType == HWTJ_ARRAY_TYPE then     
    do                                                                          
    return searchResult                                                         
    end /* endif object or array type */                                        
 /*******************************************************/                      
 /* Return the located string or number, as appropriate */                      
 /*******************************************************/                      
 if expectedType == HWTJ_STRING_TYPE | expectedType == HWTJ_NUMBER_TYPE then    
    do                                                                          
    if VERBOSE then                                                             
       say 'Invoke Json Get Value'                                              
    ReturnCode = -1                                                             
    DiagArea. = ''                                                              
    address hwtjson "hwtjgval ",                                                
                    "ReturnCode ",                                              
                    "parserHandle ",                                            
                    "searchResult ",                                            
                    "result ",                                                  
                    "DiagArea."                                                 
    RexxRC = RC                                                                 
    if JSON_isError(RexxRC,ReturnCode) then                                     
       do                                                                       
       call JSON_surfaceDiag 'hwtjgval', RexxRC, ReturnCode, DiagArea.          
       say '** hwtjgval failure **'                                             
       return ''                                                                
       end /* endif hwtjgval failed */                                          
                                                                                
    return result                                                               
    end /* endif string or number type */                                       
 /****************************************************/                         
 /* Return the located boolean value, as appropriate */                         
 /****************************************************/                         
  if expectedType == HWTJ_BOOLEAN_TYPE then                                     
    do                                                                          
    if VERBOSE then                                                             
       say 'Invoke Json Get Boolean Value'                                      
    ReturnCode = -1                                                             
    DiagArea. = ''                                                              
    address hwtjson "hwtjgbov ",                                                
                    "ReturnCode ",                                              
                    "parserHandle ",                                            
                    "searchResult ",                                            
                    "result ",                                                  
                    "DiagArea."                                                 
    RexxRC = RC                                                                 
    if JSON_isError(RexxRC,ReturnCode) then                                     
       do                                                                       
       call JSON_surfaceDiag 'hwtjgbov', RexxRC, ReturnCode, DiagArea.          
       say '** hwtjgbov failure **'                                             
       return ''                                                                
       end /* endif hwtjgbov failed */                                          
    return result                                                               
    end /* endif boolean type */                                                
 if VERBOSE then                                                                
    say '** No return value found **'                                           
 return ''  /* end function */                                                  
                                                                                
                                                                                
/***********************************************************/                   
/* Function:  JSON_getType                                 */                   
/*                                                         */                   
/* Determine the Json type of the designated search result */                   
/* via the HWTJGJST toolkit api.                           */                   
/*                                                         */                   
/* Returns: Non-negative integral number indicating type   */                   
/* if successful, -1 if not.                               */                   
/***********************************************************/                   
JSON_getType:                                                                   
 searchResult = arg(1)                                                          
 if VERBOSE then                                                                
    say 'Invoke Json Get Type'                                                  
 /*********************************/                                            
 /* Call the HWTHGJST toolkit api */                                            
 /*********************************/                                            
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwtjson "hwtjgjst ",                                                   
                 "ReturnCode ",                                                 
                 "parserHandle ",                                               
                 "searchResult ",                                               
                 "resultTypeName ",                                             
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call JSON_surfaceDiag 'hwtjgjst', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtjgjst failure **' )                               
    end /* endif hwtjgjst failure */                                            
 else                                                                           
    do                                                                          
    /******************************************************/                    
    /* Convert the returned type name into its equivalent */                    
    /* constant, and return that more convenient value.   */                    
    /* Note that the interpret instruction might more     */                    
    /* typically be used here, but the goal here is to    */                    
    /* familiarize the reader with these types.           */                    
    /******************************************************/                    
    type = strip(resultTypeName)                                                
    if type == 'HWTJ_STRING_TYPE' then                                          
       return HWTJ_STRING_TYPE                                                  
    if type == 'HWTJ_NUMBER_TYPE' then                                          
       return HWTJ_NUMBER_TYPE                                                  
    if type == 'HWTJ_BOOLEAN_TYPE' then                                         
       return HWTJ_BOOLEAN_TYPE                                                 
    if type == 'HWTJ_ARRAY_TYPE' then                                           
       return HWTJ_ARRAY_TYPE                                                   
    if type == 'HWTJ_OBJECT_TYPE' then                                          
       return HWTJ_OBJECT_TYPE                                                  
    if type == 'HWTJ_NULL_TYPE' then                                            
       return HWTJ_NULL_TYPE                                                    
    end                                                                         
 /***********************************************/                              
 /* This return should not occur, in practice.  */                              
 /***********************************************/                              
 return fatalError( 'Unsupported Type ('||type||') from hwtjgjst' )             
                                                                                
                                                                                
/**********************************************************/                    
/* Function:  JSON_termParser                             */                    
/*                                                        */                    
/* Cleans up parser resources and invalidates the parser  */                    
/* instance handle, via call to the HWTJTERM toolkit api. */                    
/* Note that as the REXX environment is single-threaded,  */                    
/* no consideration of any "busy" outcome from the api is */                    
/* done (as it would be in other language environments).  */                    
/*                                                        */                    
/* Returns: 0 if successful, -1 if not.                   */                    
/**********************************************************/                    
JSON_termParser:                                                                
 if VERBOSE then                                                                
    say 'Terminate Json Parser'                                                 
 /**********************************/                                           
 /* Call the HWTJTERM toolkit api  */                                           
 /**********************************/                                           
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwtjson "hwtjterm ",                                                   
                 "ReturnCode ",                                                 
                 "parserHandle ",                                               
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call JSON_surfaceDiag 'hwtjterm', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtjterm failure **' )                               
    end /* endif hwtjterm failure */                                            
 if VERBOSE then                                                                
    say 'Json Parser terminated'                                                
 return 0  /* end function */                                                   
                                                                                
                                                                                
/*************************************************************/                 
/* Function:  JSON_isNotFound                                */                 
/*                                                           */                 
/* Check the input processing codes. Note that if the input  */                 
/* RexxRC is nonzero, then the toolkit return code is moot   */                 
/* (the toolkit function was likely not even invoked). If    */                 
/* the toolkit return code is relevant, check it against the */                 
/* specific return code for a "not found" condition.         */                 
/*                                                           */                 
/* Returns:  1 if a HWTJ_JSRCH_SRCHSTR_NOT_FOUND condition   */                 
/* is indicated, 0 otherwise.                                */                 
/*************************************************************/                 
JSON_isNotFound:                                                                
 RexxRC = arg(1)                                                                
 if RexxRC <> 0 then                                                            
    return 0                                                                    
 ToolkitRC = strip(arg(2),'L',0)                                                
 if ToolkitRC == HWTJ_JSRCH_SRCHSTR_NOT_FOUND then                              
    return 1                                                                    
 return 0  /* end function */                                                   
                                                                                
                                                                                
/*************************************************************/                 
/* Function:  JSON_isError                                   */                 
/*                                                           */                 
/* Check the input processing codes. Note that if the input  */                 
/* RexxRC is nonzero, then the toolkit return code is moot   */                 
/* (the toolkit function was likely not even invoked). If    */                 
/* the toolkit return code is relevant, check it against the */                 
/* set of { HWTJ_xx } return codes for evidence of error.    */                 
/* This set is ordered: HWTJ_OK < HWTJ_WARNING < ...         */                 
/* with remaining codes indicating error, so we may check    */                 
/* via single inequality.                                    */                 
/*                                                           */                 
/* Returns:  1 if any toolkit error is indicated, 0          */                 
/* otherwise.                                                */                 
/*************************************************************/                 
JSON_isError:                                                                   
 RexxRC = arg(1)                                                                
 if RexxRC <> 0 then                                                            
    return 1                                                                    
 ToolkitRC = strip(arg(2),'L',0)                                                
 if ToolkitRC == '' then                                                        
       return 0                                                                 
 if ToolkitRC <= HWTJ_WARNING then                                              
       return 0                                                                 
 return 1  /* end function */                                                   
                                                                                
                                                                                
/***********************************************/                               
/* Procedure: JSON_surfaceDiag                 */                               
/*                                             */                               
/* Surface input error information.  Note that */                               
/* when the RexxRC is nonzero, the ToolkitRC   */                               
/* and DiagArea content are moot and are       */                               
/* suppressed (so as to not mislead).          */                               
/*                                             */                               
/***********************************************/                               
JSON_surfaceDiag: procedure expose DiagArea.                                    
  who = arg(1)                                                                  
  RexxRC = arg(2)                                                               
  ToolkitRC = arg(3)                                                            
  say                                                                           
  say '*ERROR* ('||who||') at time: '||Time()                                   
  say 'Rexx RC: '||RexxRC||', Toolkit ReturnCode: '||ToolkitRC                  
  if RexxRC == 0 then                                                           
     do                                                                         
     say 'DiagArea.ReasonCode: '||DiagArea.ReasonCode                           
     say 'DiagArea.ReasonDesc: '||DiagArea.ReasonDesc                           
     end                                                                        
  say                                                                           
 return  /* end procedure */                                                    
                                                                                
                                                                                
/*****************************************************************************/ 
/* Function:  fatalError                                                     */ 
/*****************************************************************************/ 
fatalError:                                                                     
 errorMsg = arg(1)                                                              
 say errorMsg                                                                   
 return -1  /* end function */                                                  
                                                                                
/*******************************************************/                       
/* Function:  HTTP_getToolkitConstants                 */                       
/*                                                     */                       
/* Access constants used by the toolkit (for return    */                       
/* codes, etc), via the HWTCONST toolkit api.          */                       
/*                                                     */                       
/* Returns: 0 if toolkit constants accessed, -1 if not */                       
/*******************************************************/                       
HTTP_getToolkitConstants:                                                       
 /***********************************************/                              
 /* Ensure that the toolkit host command is     */                              
 /* available in your REXX environment (no harm */                              
 /* done if already present).  Do this before   */                              
 /* your first toolkit api invocation.  Also,   */                              
 /* ensure no conflicting signal-handling in    */                              
 /* cases of running in USS environments.       */                              
 /***********************************************/                              
  if VERBOSE then                                                               
    say 'Setting hwtcalls on, syscalls sigoff'                                  
  call hwtcalls 'on'                                                            
  call syscalls 'SIGOFF'                                                        
 /************************************************/                             
 /* Call the HWTCONST toolkit api.  This should  */                             
 /* make all toolkit-related constants available */                             
 /* to procedures via (expose of) HWT_CONSTANTS  */                             
 /************************************************/                             
 if VERBOSE then                                                                
    say 'Including HWT Constants...'                                            
 address hwtjson "hwtconst ",                                                   
                 "ReturnCode ",                                                 
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if JSON_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwtconst', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtconst (hwtjson) failure **' )                     
    end /* endif hwtconst failure */                                            
 return 0  /* end function */                                                   
                                                                                
/*******************************************************/                       
/* Function:  InitializeVars                           */                       
/*                                                     */                       
/*******************************************************/                       
InitializeVars:                                                                 
                                                                                
 programRc = -1                                                                 
                                                                                
return                                                                          
