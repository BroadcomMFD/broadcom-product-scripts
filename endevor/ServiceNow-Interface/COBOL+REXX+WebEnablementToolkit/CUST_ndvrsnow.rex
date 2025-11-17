/* REXX */                                                                      
/*********************************************************************/         
/*  AUTHOR.    (C) 2025 Broadcom                                      */        
/*             Jose Benigno Gonzalez for CUST.                        */        
/*                                                                    */        
/* Validates Endevor CCID against ServiceNow change request  and      */        
/* Incident Management Module  - Called from Endevor Exit 2           */        
/*                                                                    */        
/* Currently in Dev Phase:                                            */        
/* Validates the first ten characters of the packageID  against       */        
/* ServiceNow change request and Incident Management Module - Called  */        
/* from Endevor Exit 7                                                */        
/*                                                                    */        
/*------------------------------------------------------------------- */        
/* Obtenemos las direcciones y longitudes los paametros de entrada    */        
/*-------------------------------------------------------------------*/         
    trace R                                                                     
                                                                                
/* Validate parameter passed to the REXX testsno9*/                             
/**/                                                                            
                                                                                
/*-------------------------------------------------------------------*/         
/* Obtenemos las direcciones y longitudes los paametros de entrada   */         
/*-------------------------------------------------------------------*/         
argstr = ARG(1)                                                                 
                                                                                
                                                                                
parse var argstr 1 A_parm1 ,        /* servicenow change request  */            
                 9 L_parm1 ,                                                    
                13 A_parm2 ,        /* Auth Type (BASIC or OAUTH) */            
                21 L_parm2 ,                                                    
                25 A_parm3 ,        /* Action from Endevor        */            
                33 L_parm3 ,                                                    
                37 A_parm4 ,        /* CR/INC  State              */            
                45 L_parm4 ,                                                    
                49 .                                                            
                                                                                
parm1_d = X2D(L_parm1)   /* decimal length of servicenow CR field */            
parm2_d = X2D(L_parm2)   /* decimal length of AUTHTYPE field      */            
parm3_d = X2D(L_parm3)   /* decimal length of Action field        */            
parm4_d = X2D(L_parm4)   /* decimal length of CR/INC State        */            
                                                                                
                                                                                
snowObjNumber  = strip(storage(A_parm1,parm1_d))                                
AuthType       = strip(STORAGE(A_parm2,parm2_d))                                
Action         = strip(STORAGE(A_parm3,parm3_d))                                
snowObjState   = strip(STORAGE(A_parm4,parm4_d))                                
                                                                                
                                                                                
verbose= 0                                                                      
                                                                                
SnowTrc_RC = bpxwdyn("info fi(snowtrc) INRTTYP(DSType)")                        
If SnowTrc_RC = 0 Then do                                                       
  Verbose = 1                                                                   
end                                                                             
                                                                                
/* Get Web Enablement Toolkit REXX constants */                                 
 call HTTP_getToolkitConstants                                                  
 if RESULT <> 0 then                                                            
    exit fatalError( '** Environment error **' )                                
                                                                                
/* Indicate Program start  */                                                   
 say '************************************************'                         
 say '** HTTP Web Enablement Toolkit Sample (Begin) **'                         
 say '************************************************'                         
                                                                                
/* Initialize variables in program */                                           
 call InitializeVars                                                            
                                                                                
 /* get a connection handle  */                                                 
 call HTTP_init HWTH_HANDLETYPE_CONNECTION                                      
 if RESULT <> 0 then                                                            
   call fatalError('** Connection could not be initialized **')                 
                                                                                
 /* Set the necessary options before connecting to the server  */               
 call HTTP_setupConnection                                                      
 if RESULT <> 0 then                                                            
   cleanup('CON','** Connection failed to be set up **')                        
                                                                                
 /* Connect to the HTTP server  */                                              
 call HTTP_connect                                                              
 if RESULT <> 0 then                                                            
   cleanup('CON','** Connection failed **')                                     
                                                                                
 /* Obtain a request handle  */                                                 
 call HTTP_init HWTH_HANDLETYPE_HTTPREQUEST                                     
 if RESULT <> 0 then                                                            
   cleanup('CON','** Request could not be initialized **')                      
                                                                                
select                                                                          
                                                                                
   when Action = 'VALINC' then do                                               
                                                                                
      queryParms = '?sysparm_display_value=true'                                
      queryParms = queryParms || '&' ||'sysparm_query=number='                  
      queryParms = queryParms ||snowObjNumber                                   
                                                                                
      requestURI = IncidentPath || queryParms                                   
                                                                                
      call HTTP_setupRequest "GET", RequestURI, "GETINC"                        
                                                                                
      if RESULT <> 0 then                                                       
         cleanup('CONREQ','** Submit job request failed to be setup **')        
                                                                                
      /* Make the request to ServiceNow */                                      
      call HTTP_request                                                         
      if RESULT <> 0 then                                                       
         cleanup('CONREQ','** ServiceNow request failed **')                    
                                                                                
      /* Analyze ServiceNow Incident (Response Body) json */                    
      if VERBOSE then                                                           
         say "response body GETINC: "||ResponseBody                             
                                                                                
      if ResponseStatusCode == HTTP_OK & ResponseBody <> '{"result":çŸ}' then   
      Do                                                                        
         call correlateData ResponseBody, "INC"                                 
         if result <> 0 Then do                                                 
           say '*** Error during JSON correlation ***'                          
         end                                                                    
         else do                                                                
                                                                                
            SnowCR_state = left(Incident.state,parm4_d)                         
            IntRC = STORAGE(A_parm4,,SnowCR_state)                              
                                                                                
            programRc = 0                                                       
                                                                                
         end                                                                    
                                                                                
      End                                                                       
      else Do                                                                   
         If ResponseStatusCode <> HTTP_OK  then do                              
            say '***Bad resp received: 'ResponseStatusCode'.'                   
          end                                                                   
         else do                                                                
            say '*** Object does not exist in servicenow application *** '      
            programRc = 8                                                       
         end                                                                    
      end                                                                       
                                                                                
   end                                                                          
                                                                                
                                                                                
   when Action = 'VALCHG' then do                                               
                                                                                
      queryParms = '?sysparm_display_value=true'                                
      queryParms = queryParms || '&' ||'sysparm_query=number='                  
      queryParms = queryParms ||snowObjNumber                                   
                                                                                
      requestURI = ChangeRequestPath || queryParms                              
                                                                                
      call HTTP_setupRequest "GET", requestURI, "GETCHG"                        
                                                                                
      if RESULT <> 0 then                                                       
         cleanup('CONREQ','** Submit job request failed to be setup **')        
                                                                                
      /* Make the request to ServiceNow */                                      
      call HTTP_request                                                         
      if RESULT <> 0 then                                                       
         cleanup('CONREQ','** ServiceNow request failed **')                    
                                                                                
      /* Analyze ServiceNow Incident (Response Body) json */                    
      if VERBOSE then                                                           
         say "response body GETCHG: "||ResponseBody                             
                                                                                
      if ResponseStatusCode == HTTP_OK & ResponseBody <> '{"result":çŸ}' then   
      Do                                                                        
         call correlateData ResponseBody, "CHG"                                 
         if result <> 0 Then do                                                 
           say '*** Error during JSON correlation ***'                          
         end                                                                    
         else do                                                                
                                                                                
            SnowCR_state = left(ChgRequest.state,parm4_d)                       
            IntRC = STORAGE(A_parm4,,SnowCR_state)                              
                                                                                
            programRc = 0                                                       
                                                                                
         end                                                                    
                                                                                
      End                                                                       
      else Do                                                                   
            If ResponseStatusCode <> HTTP_OK  then do                           
                say '***Bad resp received: 'ResponseStatusCode'.'               
             end                                                                
            else do                                                             
               say '*** Object does not exist in servicenow application *** '   
               programRc = 8                                                    
            end                                                                 
      end                                                                       
                                                                                
   end                                                                          
                                                                                
   otherwise                                                                    
      say '***Action not implememented yet ***'                                 
                                                                                
end /* select */                                                                
                                                                                
cleanup('CONREQ','HTTP Web Enablement Toolkit Sample (Ends)')                   
                                                                                
return programRc                                                                
                                                                                
                                                                                
/*******************************************************/                       
/* Function:  InitalizeVars                            */                       
/*                                                     */                       
/* Initialize global vars used throughout the program  */                       
/*******************************************************/                       
InitializeVars:                                                                 
                                                                                
 programRc = -1                                                                 
                                                                                
/* Initialize Connection and Request handle */                                  
 ConnectionHandle = ''                                                          
 RequestHandle = ''                                                             
                                                                                
/* Initialize response-related variables  */                                    
 HTTP_OK = 200                                                                  
 HTTP_Created = 201                                                             
 HTTP_Accepted = 202                                                            
 StatCode = ''                                                                  
 ResponseStatusCode = ''                                                        
 ResponseReason = ''                                                            
 ResponseHeaders. = ''                                                          
 ResponseBody = ''                                                              
                                                                                
/* Servicenow specific variables  */                                            
 ServicenowURI = 'https://dev&&&&&&.service-now.com'        /* <== '***CHANGE***
                                                                                
 RingName= '<keyring.name>'                                 /* <== '***CHANGE***
                                                                                
/* BASIC Authentication */                                                      
                                                                                
 BASIC_UserName = 'admin'                                   /* <== '***CHANGE***
 BASIC_Password = '%%%%%%%%%%%%'                            /* <== '***CHANGE***
                                                                                
 /* PATH for GET Request*/                                                      
 ChangeRequestPath = '/api/now/table/change_request'                            
 IncidentPath = '/api/now/table/incident'                                       
 AffectedCIPath = '/api/now/table/task_ci'                                      
                                                                                
  /* PATH for POST Request*/                                                    
 OAuthPath = '/oauth_token.do'                                                  
 NewChangeRequestPath='/api/sn_chg_rest/change'                                 
                                                                                
/* Servicenow specific variables for API Json Response */                       
                                                                                
 Incident. = ''                                                                 
 ChgRequest. =''                                                                
 AffectedCI. =''                                                                
                                                                                
                                                                                
return                                                                          
                                                                                
                                                                                
/*******************************************************************/           
/* Function:  correlateData()                                      */           
/*                                                                 */           
/* Use JSON Parser services to process the data returned           */           
/* by the web server.                                              */           
/*                                                                 */           
/* Return 0 if all parsing activity was performed successfully,    */           
/* -1 if otherwise.                                                */           
/*******************************************************************/           
correlateData:                                                                  
 snowJSONResponse = arg(1)                                                      
 snowObjectType = arg(2) /* INC, CHG, TASK */                                   
 parserHandle = ''                                                              
 isJSON = 0;                                                                    
 jRespHead = "application/json"                                                 
 l = length(jRespHead)                                                          
 /******************************************************************/           
 /* Check to make sure that the data coming back is in JSON format */           
 /* Loop thru all of the response headers and see if any of them   */           
 /* say Content-Type=application/json                              */           
 /******************************************************************/           
 if VERBOSE then                                                                
   say "CHECKING HEADERS"                                                       
                                                                                
 do i = 1 to ResponseHeaders.0           /* 1 to total # of headers*/           
   /* Header Name check */                                                      
   if ResponseHeaders.i = "Content-Type" then                                   
     /* Header value check */                                                   
     if substr(ResponseHeaders.i.1,1,l) = jRespHead then                        
       isJSON = 1;                                                              
 end                                                                            
                                                                                
 /* if none of the headers was JSON, then don't call parser */                  
 if isJSON = 0 Then do                                                          
   return fatalError( '** Data did not come back in JSON format ** ')           
 end                                                                            
                                                                                
 /***********************************/                                          
 /* Obtain a JSON Parser instance.  */                                          
 /***********************************/                                          
 call JSON_initParser                                                           
 if RESULT <> 0 then                                                            
    return fatalError( '** Pre-processing error (parser init failure) **' )     
 /****************************/                                                 
 /* Parse the response data. */                                                 
 /****************************/                                                 
 call JSON_parse snowJSONResponse                                               
 if RESULT <> 0 then                                                            
    do                                                                          
    call JSON_termParser                                                        
    return fatalError( '** Error while parsing SN Incident data **' )           
    end                                                                         
 /*****************************************/                                    
 /* Extract specific data and surface it, */                                    
 /* then release the parser instance.     */                                    
 /*****************************************/                                    
 call JSON_searchAndDeserializeData snowObjectType                              
 call JSON_termParser                                                           
                                                                                
 return 0                                                                       
                                                                                
/*******************************************************/                       
/* Function:  cleanup                                  */                       
/*                                                     */                       
/* Cleanup a connection and possibly a request         */                       
/* depending on the parameters pasted in.              */                       
/*******************************************************/                       
cleanup:                                                                        
 cleanupType = arg(1)                                                           
 errorMsg = arg(2)                                                              
                                                                                
 if cleanupType = 'CONREQ' then                                                 
   call HTTP_terminate RequestHandle, HWTH_NOFORCE                              
                                                                                
 /* Unconditionally release the connection handle  */                           
 call HTTP_terminate ConnectionHandle, HWTH_NOFORCE                             
                                                                                
 /* Say error message */                                                        
 say errorMsg                                                                   
                                                                                
 call closeToolkitTrace traceDD                                                 
                                                                                
exit programRC                                                                  
                                                                                
/*****************************************************/                         
/*            HTTP-related functions                 */                         
/*                                                   */                         
/* These { HTTP_xxx } functions are located together */                         
/* for ease of reference and are used to demonstrate */                         
/* how this portion of the Web Enablement Toolkit    */                         
/* can be used.                                      */                         
/*****************************************************/                         
                                                                                
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
 address hwthttp "hwtconst ",                                                   
                 "ReturnCode ",                                                 
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwtconst', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwtconst (hwthttp) failure **' )                     
    end /* endif hwtconst failure */                                            
 return 0  /* end function */                                                   
                                                                                
                                                                                
/*************************************************/                             
/* Function: HTTP_init                           */                             
/*                                               */                             
/* Create a handle of the designated type, via   */                             
/* the HWTHINIT toolkit api.  Populate the       */                             
/* corresponding global variable with the result */                             
/*                                               */                             
/* Returns: 0 if successful, -1 if not           */                             
/*************************************************/                             
HTTP_init:                                                                      
 HandleType = arg(1)                                                            
 /***********************************/                                          
 /* Call the HWTHINIT toolkit api.  */                                          
 /***********************************/                                          
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthinit ",                                                   
                 "ReturnCode ",                                                 
                 "HandleType ",                                                 
                 "HandleOut ",                                                  
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthinit', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwthinit failure **' )                               
    end                                                                         
 if HandleType == HWTH_HANDLETYPE_CONNECTION then                               
    ConnectionHandle = HandleOut                                                
 else                                                                           
    RequestHandle = HandleOut                                                   
 return 0  /* end Function */                                                   
                                                                                
                                                                                
/****************************************************/                          
/* Function: HTTP_setupConnection                   */                          
/*                                                  */                          
/* Sets the necessary connection options, via the   */                          
/* HWTHSET toolkit api.  The global variable        */                          
/* ConnectionHandle orients the api as to the scope */                          
/* of the option(s).                                */                          
/*                                                  */                          
/* Returns: 0 if successful, -1 if not              */                          
/****************************************************/                          
HTTP_setupConnection:                                                           
 if VERBOSE then                                                                
    do                                                                          
    /*****************************************************************/         
    /* Set the HWT_OPT_VERBOSE option, if appropriate.               */         
    /* This option is handy when developing an application (but may  */         
    /* be undesirable once development is complete).  Inner workings */         
    /* of the toolkit are traced by messages written to standard     */         
    /* output, or optionally redirected to file (by use of the       */         
    /* HWTH_OPT_VERBOSE_OUTPUT option).                              */         
    /*****************************************************************/         
    say '**** Set HWTH_OPT_VERBOSE for connection ****'                         
    ReturnCode = -1                                                             
    DiagArea. = ''                                                              
    address hwthttp "hwthset ",                                                 
                    "ReturnCode ",                                              
                    "ConnectionHandle ",                                        
                    "HWTH_OPT_VERBOSE ",                                        
                    "HWTH_VERBOSE_ON ",                                         
                    "DiagArea."                                                 
    RexxRC = RC                                                                 
    if HTTP_isError(RexxRC,ReturnCode) then                                     
       do                                                                       
       call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.           
       return fatalError( '** hwthset (HWTH_OPT_VERBOSE) failure **' )          
       end /* endif hwthset failure */                                          
                                                                                
     Call TurnOnVerboseOutput                                                   
                                                                                
    end /* endif script invocation requested (-V) VERBOSE */                    
                                                                                
 /***********************************************************************/      
 /* Set HWTH_OPT_USE_SSL                                                */      
 /***********************************************************************/      
 if VERBOSE then                                                                
    say '****** Set WTH_OPT_USE_SSL fot SSL  ******'                            
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_USE_SSL ",                                           
                 "HWTH_SSL_USE  ",                                              
                 "DiagArea."                                                    
 /*              "HWTH_SSL_NONE ", */                                           
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_USE_SSL) failure **' )             
    end  /* endif hwthset failure */                                            
                                                                                
 /***********************************************************************/      
 /* Set HWTH_OPT_SSLVERSION                                             */      
 /***********************************************************************/      
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_SSLVERSION ***'                                    
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_SSLVERSION ",                                        
                 "HWTH_SSLVERSION_TLSv12  ",                                    
                 "DiagArea."                                                    
 /*              "HWTH_SSLVERSION_TLSv13 ",                                     
                 "HWTH_SSLVERSION_DEFAULT ",*/                                  
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_SSLVERSION) failure **' )          
    end  /* endif hwthset failure */                                            
                                                                                
 /***********************************************************************/      
 /* Set HWTH_OPT_SSLKEYTYPE                                             */      
 /***********************************************************************/      
 /**/                                                                           
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_SSLKEYTYPE ***'                                    
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_SSLKEYTYPE ",                                        
                 "HWTH_SSLKEYTYPE_KEYRINGNAME ",                                
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_SSLKEYTYPE) failure **' )          
    end  /* endif hwthset failure */                                            
                                                                                
 /***********************************************************************/      
 /* Set HWTH_OPT_SSLKEY                                                 */      
 /***********************************************************************/      
 /**/                                                                           
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_SSLKEY ***'                                        
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_SSLKEY ",                                            
                 "RingName ",                                                   
                 "DiagArea."                                                    
 /*              "IZUSVR.ZOSMF02 ", */                                          
 /*              "IZUSVR.KEYR01 ", */                                           
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_SSLKEY) failure **' )              
    end  /* endif hwthset failure */                                            
                                                                                
 /****************************************************************************/ 
 /* Set URI for connection to Service Now Cloud SaaS                         */ 
 /****************************************************************************/ 
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_URI for connection ******'                         
                                                                                
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_URI ",                                               
                 "ServicenowURI ",                                              
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_URI) failure **' )                 
    end  /* endif hwthset failure */                                            
                                                                                
 /***********************************************************************/      
 /* Set HWTH_OPT_COOKIETYPE                                             */      
 /*   Enable the cookie engine for this connection.  Any "eligible"     */      
 /*   stored cookies will be resent to the host on subsequent           */      
 /*   interactions automatically.                                       */      
 /***********************************************************************/      
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_COOKIETYPE for session cookies ******'             
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_COOKIETYPE ",                                        
                 "HWTH_COOKIETYPE_SESSION ",                                    
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_COOKIETYPE) failure **' )          
    end  /* endif hwthset failure */                                            
                                                                                
                                                                                
 if VERBOSE then                                                                
    say 'Connection setup successful'                                           
 return 0  /* end subroutine */                                                 
                                                                                
                                                                                
/*************************************************************/                 
/* Function: HTTP_connect                                    */                 
/*                                                           */                 
/* Connect to the configured domain (host) via the HWTHCONN  */                 
/* toolkit api.                                              */                 
/*                                                           */                 
/* Returns: 0 if successful, -1 if not                       */                 
/*************************************************************/                 
HTTP_connect:                                                                   
 if VERBOSE then                                                                
    say 'Issue Connect'                                                         
 /**********************************/                                           
 /* Call the HWTHCONN toolkit api  */                                           
 /**********************************/                                           
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthconn ",                                                   
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthconn', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwthconn failure **' )                               
    end                                                                         
 if VERBOSE then                                                                
    say 'Connect (hwthconn) successful'                                         
 return 0  /* end function */                                                   
                                                                                
                                                                                
/************************************************************/                  
/* Function: HTTP_setupRequest                              */                  
/*                                                          */                  
/* Sets the necessary request options.  The global variable */                  
/* RequestHandle orients the api as to the scope of the     */                  
/* option(s).                                               */                  
/*                                                          */                  
/* Returns: 0 if successful, -1 if not                      */                  
/************************************************************/                  
HTTP_setupRequest:                                                              
HTTP_Method = arg(1)                                                            
RequestURI  = arg(2)                                                            
Action      = arg(3)                                                            
                                                                                
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_REQUESTMETHOD for request **'                      
 /**************************************************************/               
 /* Set HTTP Request method.                                   */               
 /* A ??? request method is used to modify a resource on server*/               
 /**************************************************************/               
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
                                                                                
 select                                                                         
   when HTTP_Method = 'GET' then do                                             
       address hwthttp "hwthset ",                                              
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_REQUESTMETHOD ",                                     
                 "HWTH_HTTP_REQUEST_GET ",                                      
                 "DiagArea."                                                    
   end                                                                          
                                                                                
   when HTTP_Method = 'POST' then do                                            
      address hwthttp "hwthset ",                                               
            "ReturnCode ",                                                      
            "RequestHandle ",                                                   
            "HWTH_OPT_REQUESTMETHOD ",                                          
            "HWTH_HTTP_REQUEST_POST ",                                          
            "DiagArea."                                                         
   end                                                                          
                                                                                
   when HTTP_Method = 'PATCH' then do                                           
      address hwthttp "hwthset ",                                               
            "ReturnCode ",                                                      
            "RequestHandle ",                                                   
            "HWTH_OPT_REQUESTMETHOD ",                                          
            "HWTH_HTTP_REQUEST_PATCH ",                                         
            "DiagArea."                                                         
   end                                                                          
                                                                                
   Otherwise                                                                    
      return fatalError( '** hwthset (HWTH_OPT_REQUESTMETHOD) invalid **' )     
 end                                                                            
                                                                                
                                                                                
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
      call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.            
      return fatalError('hwthset (HWTH_OPT_REQUESTMETHOD) failure **' )         
    end  /* endif hwthset failure */                                            
/*****************************************************************/             
/* Set the request URI                                           */             
/*  Set the URN URI that identifies a resource by name that is   */             
/*    the target of our request.                                 */             
/*****************************************************************/             
 if VERBOSE then                                                                
    say'****** Set HWTH_OPT_URI for request ******'                             
                                                                                
                                                                                
 if VERBOSE then                                                                
    say 'request URI:' requestURI                                               
                                                                                
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_URI ",                                               
                 "requestURI ",                                                 
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_URI) failure **' )                 
    end  /* endif hwthset failure */                                            
                                                                                
/*****************************************************************/             
/* Authenticating to the ServiceNow Instance                     */             
/*  Single sign-on uses HTTP basic authentication to fulfill the */             
/*    request.  Set the authentication level to basic and        */             
/*    specify userid and password                                */             
/*****************************************************************/             
                                                                                
 /* Set Authentication Type based on AUTHType parameter */                      
 If AuthType /= 'OAUTH' Then do                                                 
                                                                                
   if VERBOSE then                                                              
      say'****** Set HWTH_OPT_HTTPAUTH for request ******'                      
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   address hwthttp "hwthset ",                                                  
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_OPT_HTTPAUTH ",                                         
                  "HWTH_HTTPAUTH_BASIC ",                                       
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.            
      return fatalError( '** hwthset (HWTH_OPT_HTTPAUTH) failure **' )          
      end  /* endif hwthset failure */                                          
                                                                                
   /* Set username */                                                           
   if VERBOSE then                                                              
      say'****** Set HWTH_OPT_USERNAME for request ******'                      
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   address hwthttp "hwthset ",                                                  
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_OPT_USERNAME ",                                         
                  "BASIC_UserName ",                                            
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.            
      return fatalError( '** hwthset (HWTH_OPT_USERNAME) failure **' )          
      end  /* endif hwthset failure */                                          
                                                                                
   /* Set password */                                                           
   if VERBOSE then                                                              
      say'****** Set HWTH_OPT_PASSWORD for request ******'                      
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   address hwthttp "hwthset ",                                                  
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_OPT_PASSWORD ",                                         
                  "BASIC_Password ",                                            
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.            
      return fatalError( '** hwthset (HWTH_OPT_PASSWORD) failure **' )          
      end  /* endif hwthset failure */                                          
  end                                                                           
                                                                                
 Else do                                                                        
                                                                                
   if VERBOSE then                                                              
      say'****** Set HWTH_OPT_HTTPAUTH for request ******'                      
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   address hwthttp "hwthset ",                                                  
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_OPT_HTTPAUTH ",                                         
                  "HWTH_HTTPAUTH_NONE ",                                        
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.            
      return fatalError( '** hwthset (HWTH_OPT_HTTPAUTH) failure **' )          
      end  /* endif hwthset failure */                                          
                                                                                
 end                                                                            
 /* */                                                                          
 /*********************************************************/                    
 /* Set the stem variable for receiving response headers  */                    
 /*********************************************************/                    
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 ResponseHeaders. = ''                                                          
                                                                                
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_RESPONSEHDR_USERDATA for request ******'           
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_RESPONSEHDR_USERDATA ",                              
                 "ResponseHeaders. ",                                           
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_RESPONSEHDR_USERDATA) failure **') 
    end /* endif hwthset failure */                                             
                                                                                
 /*******************************************************************/          
 /* Have the toolkit convert the response body from ASCII to EBCDIC */          
 /* (so that we may pass it to our parser in a form that the latter */          
 /* will understand)                                                */          
 /*******************************************************************/          
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_TRANSLATE_RESPBODY for request ******'             
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_TRANSLATE_RESPBODY ",                                
                 "HWTH_XLATE_RESPBODY_A2E ",                                    
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_TRANSLATE_RESPBODY) failure **' )  
    end /* endif hwthset failure */                                             
                                                                                
 /*******************************************************************/          
 /* Have the toolkit convert the request  body from EBCDIC TO ASCII */          
 /*******************************************************************/          
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_TRANSLATE_REQBODY for request'                     
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_TRANSLATE_REQBODY ",                                 
                 "HWTH_XLATE_REQBODY_E2A ",                                     
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_TRANSLATE_REQBODY) failure  **' )  
    end /* endif hwthset failure */                                             
                                                                                
 /**************************************************/                           
 /* Set Request body                               */                           
 /**************************************************/                           
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
                                                                                
 select                                                                         
                                                                                
    when Action = 'NEWCHG' then do                                              
      RequestBody =  '{"short_description":"Change Request created on behalf of 
    end                                                                         
                                                                                
    when Action = 'ADDCHGNT' then do                                            
      Notes = 'Endevor Package ID ' Ndvr_Pkg_id ' has been created for this Chan
      RequestBody =  '{"work_notes":"' || Notes || '"}'                         
    end                                                                         
                                                                                
    otherwise RequestBody =  ""                                                 
                                                                                
 end                                                                            
                                                                                
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_REQUESTBODY for request ******'                    
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_REQUESTBODY ",                                       
                 "RequestBody ",                                                
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_REQUESTBODY) failure **')          
    end /* endif hwthset failure */                                             
                                                                                
                                                                                
 /*************************************************/                            
 /* Set the variable for receiving response body  */                            
 /**************************************************/                           
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 ResponseBody. = ''                                                             
                                                                                
 if VERBOSE then                                                                
    say '****** Set HWTH_OPT_RESPONSEBODY_USERDATA for request ******'          
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_RESPONSEBODY_USERDATA ",                             
                 "ResponseBody ",                                               
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_RESPONSEBODY_USERDATA) failure **')
    end /* endif hwthset failure */                                             
                                                                                
 /*************************************************************/                
 /* Set any request header(s) we may have.  This depends upon */                
 /* the Http request (often we might not have any).           */                
 /*************************************************************/                
 call HTTP_setRequestHeaders                                                    
 if RESULT <> 0 then                                                            
    return fatalError( '** Unable to set Request Headers **' )                  
                                                                                
 if VERBOSE then                                                                
    say 'Request setup successful'                                              
 return 0   /* end function */                                                  
                                                                                
/****************************************************************/              
/* Function: HTTP_terminate                                     */              
/*                                                              */              
/* Release the designated Connection or Request handle via the  */              
/* HWTHTERM toolkit api.                                        */              
/*                                                              */              
/* Returns:                                                     */              
/* 0 if successful, -1 if not                                   */              
/****************************************************************/              
HTTP_terminate:                                                                 
                                                                                
 handleIn = arg(1)                                                              
 forceOption = arg(2)                                                           
 if VERBOSE then                                                                
    say 'Terminate'                                                             
 /***********************************/                                          
 /* Call the HWTHTERM toolkit api.  */                                          
 /***********************************/                                          
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthterm ",                                                   
                 "ReturnCode ",                                                 
                 "handleIn ",                                                   
                 "forceOption ",                                                
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthterm', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwthterm failure **' )                               
    end  /* endif hwthterm failure */                                           
 if VERBOSE then                                                                
    say 'Terminate (hwthterm) succeeded'                                        
 return 0  /* end function */                                                   
                                                                                
                                                                                
/****************************************************************/              
/* Function: HTTP_request                                       */              
/*                                                              */              
/* Make the configured Http request via the HWTHRQST toolkit    */              
/* api.                                                         */              
/*                                                              */              
/* Returns: 0 if successful, -1 if not                          */              
/****************************************************************/              
HTTP_request:                                                                   
 if VERBOSE then                                                                
   say 'Making Http Request'                                                    
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 /***********************************/                                          
 /* Call the HWTHRQST toolkit api.  */                                          
 /***********************************/                                          
 address hwthttp "hwthrqst ",                                                   
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "RequestHandle ",                                              
                 "HttpStatusCode ",                                             
                 "HttpReasonCode ",                                             
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthrqst', RexxRC, ReturnCode, DiagArea.             
    return fatalError( '** hwthrqst failure **' )                               
    end  /* endif hwthrqst failure */                                           
 /****************************************************************/             
 /* The ReturnCode indicates merely whether the request was made */             
 /* (and response received) without error.  The origin server's  */             
 /* response, of course, is another matter.  The HttpStatusCode  */             
 /* and HttpReasonCode record how the server responded.  Any     */             
 /* header(s) and/or body included in that response are to be    */             
 /* found in the variables which we established earlier.         */             
 /****************************************************************/             
 ResponseStatusCode = strip(HttpStatusCode,'L',0)                               
 ResponseReasonCode = strip(HttpReasonCode)                                     
 if VERBOSE then                                                                
   do                                                                           
     say 'Request completed'                                                    
     say 'HTTP Status Code: '||StatCode                                         
     say 'HTTP Response Reason Code: '||ResponseReasonCode                      
   end                                                                          
                                                                                
 return 0  /* end function */                                                   
                                                                                
/*************************************************************/                 
/* Function:  HTTP_setRequestHeaders                         */                 
/*                                                           */                 
/* Add appropriate Request Headers, by first building an     */                 
/* "SList", and then setting the HWTH_OPT_HTTPHEADERS        */                 
/* option of the Request with that list.                     */                 
/*                                                           */                 
/* Returns: 0 if successful, -1 if not                       */                 
/*************************************************************/                 
HTTP_setRequestHeaders:                                                         
                                                                                
                                                                                
If Action = 'NEWCHG' Then do                                                    
                                                                                
   SList = ''                                                                   
   acceptHeader = 'Accept: */*'                                                 
   Authorization = 'Authorization: Bearer'                                      
                                                                                
                                                                                
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   if VERBOSE then                                                              
      say 'Create new SList'                                                    
   address hwthttp "hwthslst ",                                                 
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_SLST_NEW ",                                             
                  "SList ",                                                     
                  "acceptHeader ",                                              
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwthslst (HWTH_SLST_NEW) failure **' )             
      end  /* endif hwthslst failure */                                         
                                                                                
end                                                                             
                                                                                
Else do                                                                         
                                                                                
   SList = ''                                                                   
   acceptJsonHeader = 'Accept: application/json'                                
   acceptLanguageHeader = 'Accept-Language: en-US'                              
   contentTypeHeader = 'Content-Type: application/json'                         
   Authorization = 'Authorization: Bearer'                                      
                                                                                
   /**********************************************************************/     
   /* Create a brand new SList and specify the first header to be an     */     
   /* "Accept" header that requests that the server return any response  */     
   /* body text in JSON format.                                          */     
   /**********************************************************************/     
   ReturnCode = -1                                                              
   DiagArea. = ''                                                               
   if VERBOSE then                                                              
      say 'Create new SList'                                                    
   address hwthttp "hwthslst ",                                                 
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_SLST_NEW ",                                             
                  "SList ",                                                     
                  "acceptJsonHeader ",                                          
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwthslst (HWTH_SLST_NEW) failure **' )             
      end  /* endif hwthslst failure */                                         
   /***********************************************************/                
   /* Append the Accept-Language request header to the SList  */                
   /* to infer to the server the regional settings which are  */                
   /* preferred by this application.                          */                
   /***********************************************************/                
   if VERBOSE then                                                              
      say 'Append to SList'                                                     
   address hwthttp "hwthslst ",                                                 
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_SLST_APPEND ",                                          
                  "SList ",                                                     
                  "acceptLanguageHeader ",                                      
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )          
      end /* endif hwthslst failure */                                          
   /***********************************************************/                
   /* Append the Content-Type request header to the SList     */                
   /* to specify that the data sent on the put request is in  */                
   /* JSON format                                             */                
   /***********************************************************/                
   if VERBOSE then                                                              
      say 'Append to SList'                                                     
   address hwthttp "hwthslst ",                                                 
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_SLST_APPEND ",                                          
                  "SList ",                                                     
                  "contentTypeHeader ",                                         
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )          
      end /* endif hwthslst failure */                                          
                                                                                
end                                                                             
  /**********************************************************/                  
 /* ADD the Authorization Request Header if OAUTH           */                  
 /***********************************************************/                  
 If AuthType= 'OAUTH' then do                                                   
                                                                                
   BearerToken = Authorization || ' ' || snow_access_token                      
                                                                                
   if VERBOSE then                                                              
      say 'Append to SList'                                                     
   address hwthttp "hwthslst ",                                                 
                  "ReturnCode ",                                                
                  "RequestHandle ",                                             
                  "HWTH_SLST_APPEND ",                                          
                  "SList ",                                                     
                  "BearerToken ",                                               
                  "DiagArea."                                                   
   RexxRC = RC                                                                  
   if HTTP_isError(RexxRC,ReturnCode) then                                      
      do                                                                        
      call HTTP_surfaceDiag 'hwthslst', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwthslst (HWTH_SLST_APPEND) failure **' )          
      end /* endif hwthslst failure */                                          
                                                                                
 end                                                                            
                                                                                
 /************************************/                                         
 /* Set the request headers with the */                                         
 /* just-produced list               */                                         
 /************************************/                                         
 if VERBOSE then                                                                
    say 'Set HWTH_OPT_HTTPHEADERS for request'                                  
 ReturnCode = -1                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "RequestHandle ",                                              
                 "HWTH_OPT_HTTPHEADERS ",                                       
                 "SList ",                                                      
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_HTTPHEADERS) failure **' )         
    end  /* endif hwthset failure */                                            
                                                                                
                                                                                
 return 0  /* end function */                                                   
                                                                                
                                                                                
                                                                                
                                                                                
/*************************************************************/                 
/* Function:  HTTP_isError                                   */                 
/*                                                           */                 
/* Check the input processing codes. Note that if the input  */                 
/* RexxRC is nonzero, then the toolkit return code is moot   */                 
/* (the toolkit function was likely not even invoked). If    */                 
/* the toolkit return code is relevant, check it against the */                 
/* set of { HWTH_xx } return codes for evidence of error.    */                 
/* This set is ordered: HWTH_OK < HWTH_WARNING < ...         */                 
/* with remaining codes indicating error, so we may check    */                 
/* via single inequality.                                    */                 
/*                                                           */                 
/* Returns:  1 if any toolkit error is indicated, 0          */                 
/* otherwise.                                                */                 
/*************************************************************/                 
HTTP_isError:                                                                   
 RexxRC = arg(1)                                                                
 if RexxRC <> 0 then                                                            
    return 1                                                                    
 ToolkitRC = strip(arg(2),'L',0)                                                
 if ToolkitRC == '' then                                                        
       return 0                                                                 
 if ToolkitRC <= HWTH_WARNING then                                              
       return 0                                                                 
 return 1  /* end function */                                                   
                                                                                
                                                                                
/*************************************************************/                 
/* Function:  HTTP_isWarning                                 */                 
/*                                                           */                 
/* Check the input processing codes. Note that if the input  */                 
/* RexxRC is nonzero, then the toolkit return code is moot   */                 
/* (the toolkit function was likely not even invoked). If    */                 
/* the toolkit return code is relevant, check it against the */                 
/* specific HWTH_WARNING return code.                        */                 
/*                                                           */                 
/* Returns:  1 if toolkit rc HWTH_WARNING is indicated, 0    */                 
/* otherwise.                                                */                 
/*************************************************************/                 
HTTP_isWarning:                                                                 
 RexxRC = arg(1)                                                                
 if RexxRC <> 0 then                                                            
    return 0                                                                    
 ToolkitRC = strip(arg(2),'L',0)                                                
 if ToolkitRC == '' then                                                        
    return 0                                                                    
 if ToolkitRC <> HWTH_WARNING then                                              
    return 0                                                                    
 return 1 /* end function */                                                    
                                                                                
                                                                                
/***********************************************/                               
/* Procedure: HTTP_surfaceDiag()               */                               
/*                                             */                               
/* Surface input error information.  Note that */                               
/* when the RexxRC is nonzero, the ToolkitRC   */                               
/* and DiagArea content are moot and are       */                               
/* suppressed (so as to not mislead).          */                               
/***********************************************/                               
HTTP_surfaceDiag: procedure expose DiagArea.                                    
  say                                                                           
  say '*ERROR* ('||arg(1)||') at time: '||Time()                                
  say 'Rexx RC: '||arg(2)', Toolkit ReturnCode: '||arg(3)                       
  say 'DiagArea.Service: '||DiagArea.HWTH_service                               
  say 'DiagArea.ReasonCode: '||DiagArea.HWTH_reasonCode                         
  say 'DiagArea.ReasonDesc: '||DiagArea.HWTH_reasonDesc                         
  say                                                                           
 return /* end procedure */                                                     
                                                                                
                                                                                
/***********************************************/                               
/* Function:  fatalError                       */                               
/*                                             */                               
/* Surfaces the input message, and returns     */                               
/* a canonical failure code.                   */                               
/*                                             */                               
/* Returns: -1 to indicate fatal script error. */                               
/***********************************************/                               
 fatalError:                                                                    
 errorMsg = arg(1)                                                              
 say errorMsg                                                                   
 return -1  /* end function */                                                  
                                                                                
/***********************************************/                               
/* Function:  TurnOnVerboseOutput              */                               
/*                                             */                               
/* Sets the zFS UNIX file where the toolkit    */                               
/* trace will be written                       */                               
/***********************************************/                               
TurnOnVerboseOutput:                                                            
 /**********************************************************/                   
 say '**** Set HWTH_OPT_VERBOSE_OUTPUT for connection ****'                     
                                                                                
 traceDataSetName = '<TRACE Data set name>'                                     
 traceDD = 'HWTTRACE'                                                           
                                                                                
 call closeToolkitTrace traceDD                                                 
                                                                                
 allocRc = allocateTracefile(traceDataSetName,traceDD)                          
                                                                                
 DiagArea. = ''                                                                 
 address hwthttp "hwthset ",                                                    
                 "ReturnCode ",                                                 
                 "ConnectionHandle ",                                           
                 "HWTH_OPT_VERBOSE_OUTPUT ",                                    
                 "traceDD ",                                                    
                 "DiagArea."                                                    
 RexxRC = RC                                                                    
 if HTTP_isError(RexxRC,ReturnCode) then                                        
    do                                                                          
    call HTTP_surfaceDiag 'hwthset', RexxRC, ReturnCode, DiagArea.              
    return fatalError( '** hwthset (HWTH_OPT_VERBOSE) failure **' )             
    end /* endif hwthset failure */                                             
 return                                                                         
                                                                                
                                                                                
 /*************************************************/                            
 /* Procedure:  allocateTracefile                 */                            
 /*                                               */                            
 /* Allocate a previously created trace data set  */                            
 /* with the required attributes (which           */                            
 /* must already exist), and a known DDname.      */                            
 /*************************************************/                            
 allocateTracefile: procedure expose (PROC_GLOBALS)                             
  datasetName = arg(1)                                                          
  DDname = arg(2)                                                               
                                                                                
  /* allocates datasetName to DDName and directs messages */                    
  /* to z/OS UNIX standard error (sdterr)                 */                    
                                                                                
  alloc = 'alloc fi('||DDname||') '                                             
  /* alloc = alloc||'da('||quoted(datasetName)||') old msg(2)' */               
  alloc = alloc || 'sysout recfm(v)'                                            
                                                                                
  call bpxwdyn alloc                                                            
  allocRc = Result                                                              
                                                                                
  return allocRc  /* end procedure */                                           
                                                                                
 /***********************************************************/                  
 /* Procedure:  closeToolkitTrace                           */                  
 /*                                                         */                  
 /* Free the ddname which an earlier redirectToolkitTraceXX */                  
 /* caused allocation to associate with an HFS file.        */                  
 /***********************************************************/                  
 closeToolkitTrace: procedure expose (PROC_GLOBALS)                             
  DDname = arg(1)                                                               
  call bpxwdyn 'free fi('DDname')'                                              
  return /* end procedure */                                                    
                                                                                
 /*******************************************************/                      
 /* Function:  quoted                                   */                      
 /*******************************************************/                      
 quoted:                                                                        
  stringIn = arg(1)                                                             
 return "'"||stringIn||"'"                                                      
                                                                                
/*****************************************************/                         
/*            JSON-related functions                 */                         
/*                                                   */                         
/* These { JSON_xxx } functions are located together */                         
/* for ease of reference and are used to demonstrate */                         
/* how this portion of the Web Enablement Toolkit    */                         
/* can be used in conjunction with the Http-related  */                         
/* toolkit functions.                                */                         
/*****************************************************/                         
                                                                                
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
                                                                                
                                                                                
/*******************************************************************/           
/* Subroutine: JSON_searchAndDeserializeData                       */           
/*                                                                 */           
/* Search for specific values and objects in the parsed response   */           
/* body, and deserialize them into the distanceData. stem variable */           
/*                                                                 */           
/*******************************************************************/           
JSON_searchAndDeserializeData:                                                  
snowObjectType = arg(1)                                                         
                                                                                
/*-------------------------------------------------------------------*/         
/* Borramos el area del parametro de salida antes de modificarlo     */         
/*-------------------------------------------------------------------*/         
 Incident. = ''                                                                 
 ChgRequest. =''                                                                
 AffectedCI. =''                                                                
 SNData. = ''                                                                   
                                                                                
 select                                                                         
 /*******************************************************************/          
 /* return incident attributes got from JSON                        */          
 /*******************************************************************/          
   when snowObjectType = 'INC' then do                                          
                                                                                
       /***************************************/                                
       /* Get Open Date                       */                                
       /***************************************/                                
       Incident.OpenedAt = JSON_findValue( 0, "opened_at", HWTJ_STRING_TYPE )   
       Incident.state    = JSON_findValue( 0, "state", HWTJ_STRING_TYPE )       
       Incident.Active   = JSON_findValue( 0, "active", HWTJ_STRING_TYPE )      
       Incident.Priority = JSON_findValue( 0, "priority", HWTJ_STRING_TYPE )    
                                                                                
                                                                                
   end                                                                          
                                                                                
   when snowObjectType = 'CHG' then do                                          
                                                                                
       /***************************************/                                
       /* Get Open Date                       */                                
       /***************************************/                                
       ChgRequest.start_date= JSON_findValue( 0,"start_date", HWTJ_STRING_TYPE) 
       ChgRequest.end_date  = JSON_findValue( 0,"end_date", HWTJ_STRING_TYPE)   
       ChgRequest.state     = JSON_findValue( 0,"state", HWTJ_STRING_TYPE )     
       ChgRequest.Active    = JSON_findValue( 0,"active", HWTJ_STRING_TYPE )    
       ChgRequest.sys_id    = JSON_findValue( 0,"sys_id", HWTJ_STRING_TYPE )    
       ChgRequest.number    = JSON_findValue( 0,"number", HWTJ_STRING_TYPE )    
       ChgRequest.approval  = JSON_findValue( 0,"approval", HWTJ_STRING_TYPE )  
                                                                                
   end                                                                          
                                                                                
   when snowObjectType = 'NEWCHG' then do                                       
                                                                                
       /***************************************/                                
       /* Get Open Date                       */                                
       /***************************************/                                
       CHG_Obj  = JSON_findValue( 0, "result", HWTJ_OBJECT_TYPE )               
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"number", HWTJ_OBJECT_TYPE )        
       ChgRequest.number = JSON_findValue(CHG_Num_obj,,                         
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"state", HWTJ_OBJECT_TYPE )         
       ChgRequest.state = JSON_findValue(CHG_Num_obj,,                          
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"active", HWTJ_OBJECT_TYPE )        
       ChgRequest.active = JSON_findValue(CHG_Num_obj,,                         
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"sys_id", HWTJ_OBJECT_TYPE )        
       ChgRequest.sys_id = JSON_findValue(CHG_Num_obj,,                         
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"approval", HWTJ_OBJECT_TYPE )      
       ChgRequest.approval = JSON_findValue(CHG_Num_obj,,                       
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"start_date", HWTJ_OBJECT_TYPE )    
       ChgRequest.start_date = JSON_findValue(CHG_Num_obj,,                     
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
       CHG_Num_obj = JSON_findValue(CHG_Obj,"end_date", HWTJ_OBJECT_TYPE )      
       ChgRequest.start_date = JSON_findValue(CHG_Num_obj,,                     
                          "display_value",,                                     
                           HWTJ_STRING_TYPE)                                    
                                                                                
   end                                                                          
                                                                                
   when snowObjectType = 'TASK' then do                                         
   end                                                                          
                                                                                
   otherwise                                                                    
      nop                                                                       
 end                                                                            
                                                                                
 return  /* end subroutine */                                                   
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
                                                                                
                                                                                
/*******************************************************/                       
/* Function:  quoted                                   */                       
/*******************************************************/                       
quoted:                                                                         
 stringIn = arg(1)                                                              
return "'"||stringIn||"'"                                                       
/*******************************************************/                       
/* Function:  delay                                    */                       
/*******************************************************/                       
delay:                                                                          
 /* Rexx Delay */                                                               
 DelaySec = 0.250000 /* readable width */                                       
 elapsed = TIME(R)                                                              
 do until elapsed >= DelaySec                                                   
 elapsed = TIME('E')                                                            
 end                                                                            
return                                                                          
                                                                                
/***********************************************/                               
/* Function: usage                             */                               
/*                                             */                               
/* Provide usage guidance to the invoker.      */                               
/*                                             */                               
/* Returns: -1 to indicate fatal script error. */                               
/***********************************************/                               
usage:                                                                          
 whyString = arg(1)                                                             
 say                                                                            
 say 'usage:'                                                                   
 say 'ex SNOWOAUT <AuthType> <Action> <snowNumber> <JsonDebug>'                 
 say '<dest city,state,code> <optional -V for verbose>'                         
 say                                                                            
 say '('||whyString||')'                                                        
 say                                                                            
 return -1  /* end function */                                                  
                                                                                
 /***********************************************/                              
/* Function:  GetArgs                          */                               
/*                                             */                               
/* Parse script arguments and make appropriate */                               
/* variable assignments, or return fatal error */                               
/* code via usage() invocation.                */                               
/*                                             */                               
/* Returns: 0 if successful, -1 if not.        */                               
/***********************************************/                               
GetArgs:                                                                        
 S = arg(1)                                                                     
 argCount = words(S)                                                            
 if argCount == 0 | argCount < 3 | argCount > 4 then                            
    return usage( 'Wrong number of arguments' )                                 
                                                                                
 do i = 1 to argCount                                                           
   localArg = word(S,i)                                                         
   select                                                                       
     when (i == 1) then                                                         
       do                                                                       
         apikey = localArg                                                      
       end                                                                      
     when (i == 2) | (i == 3) then                                              
       call parseLocation                                                       
     otherwise                                                                  
       if localArg == '-v' then                                                 
         VERBOSE = 1                                                            
   end                                                                          
 end                                                                            
return 0  /* end function */                                                    
                                                                                
                                                                                
/***********************************************/                               
/* Function:  get_AffectedCI_List              */                               
/*                                             */                               
/* get the Affecte CI list of a CHG Request    */                               
/***********************************************/                               
get_AffectedCI_List:                                                            
   sys_id = arg(1)                                                              
   ACI_List. = arg(2)                                                           
                                                                                
call HTTP_setupRequest "TASK", sys_id, "TASK"                                   
if RESULT <> 0 then                                                             
cleanup('CONREQ','** Submit job request failed to be setup **')                 
                                                                                
/* Make the request to ServiceNow */                                            
call HTTP_request                                                               
if RESULT <> 0 then                                                             
cleanup('CONREQ','** ServiceNow request failed **')                             
                                                                                
/* Analyze ServiceNow ChanheRequest (Response Body) json */                     
if VERBOSE then                                                                 
   say 'response body snow TASK 'sys_id': ' ||ResponseBody                      
                                                                                
if ResponseStatusCode == HTTP_OK then                                           
Do                                                                              
   call Process_task_ci_json ResponseBody, ACI_List.                            
                                                                                
   if result <> 0 Then do                                                       
      say '*** Error during JSON correlation ***'                               
   end                                                                          
   else do                                                                      
      programRc = 0                                                             
   end                                                                          
End                                                                             
else Do                                                                         
   say '***Bad resp received: 'ResponseStatusCode'.'                            
end                                                                             
                                                                                
return programRc                                                                
                                                                                
                                                                                
/***********************************************/                               
/* Function:  Process_task_ci_json             */                               
/*                                             */                               
/* help implementing new functionalities       */                               
/* using as example a json text read from a    */                               
/* file.                                       */                               
/*                                             */                               
/* Returns: 0 if successful, -1 if not.        */                               
/***********************************************/                               
                                                                                
Process_task_ci_json:                                                           
   jsonTEXT = arg(1)                                                            
   ACI_List. = arg(2)                                                           
                                                                                
say 'Response Body received at Process_task_ci_json: 'jsonTEXT                  
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
/*****************************************/                                     
/* Extract specific data and surface it, */                                     
/* then release the parser instance.     */                                     
/*****************************************/                                     
if VERBOSE then                                                                 
   say 'Getting number of elements returned in the array of objects'            
                                                                                
AffectedCIsList = JSON_findValue( 0, "result", HWTJ_ARRAY_TYPE )                
                                                                                
/* NumOfElements = 0 */                                                         
                                                                                
address hwtjson "hwtjgnue ",                                                    
               "ReturnCode ",                                                   
               "parserHandle ",                                                 
               "AffectedCIsList ",                                              
               "NumOfAffectedCIs ",                                             
               "DiagArea."                                                      
                                                                                
RexxRC = RC                                                                     
if JSON_isError(RexxRC,ReturnCode) then                                         
do                                                                              
   call JSON_surfaceDiag 'hwtjgnue', RexxRC, ReturnCode, DiagArea.              
   return fatalError( '** hwtjgnue failure **' )                                
end  /* endif hwtjinit failure */                                               
                                                                                
/*Say 'Number of affected CIs in the Change Request: 'NumOfAffectedCIs          
say '' */                                                                       
                                                                                
/* Process each element of the array of objects */                              
                                                                                
ACI_List.0 = NumOfAffectedCIs                                                   
                                                                                
do AffectedCI=0 to  NumOfAffectedCIs-1                                          
                                                                                
address hwtjson  "hwtjgaen ",                                                   
                  "ReturnCode ",                                                
                  "ParserHandle ",                                              
                  "AffectedCIsList ",                                           
                  "AffectedCI",                                                 
                  "EntryValueHandle",                                           
                  "DiagArea."                                                   
                                                                                
RexxRC = RC                                                                     
if JSON_isError(RexxRC,ReturnCode) then                                         
   do                                                                           
      call JSON_surfaceDiag 'hwtjgaen', RexxRC, ReturnCode, DiagArea.           
      return fatalError( '** hwtjgaen failure **' )                             
   end  /* endif hwtjinit failure */                                            
                                                                                
   Entry = AffectedCI+1                                                         
   display_val = JSON_findValue( EntryValueHandle,                              
                                  ,"display_value" ,                            
                                  ,HWTJ_STRING_TYPE)                            
                                                                                
   ACI_List.Entry.display_value = display_val                                   
                                                                                
                                                                                
   created_on = JSON_findValue( EntryValueHandle,                               
                                    ,"sys_created_on" ,                         
                                    ,HWTJ_STRING_TYPE)                          
                                                                                
   ACI_List.Entry.sys_created_on = created_on                                   
                                                                                
                                                                                
                                                                                
   /* say '   Affected CI 'AffectedCI+1': 'ACI_List.Entry.display_value         
   say '   Affected CI 'AffectedCI+1': 'ACI_List.Entry.sys_created_on */        
                                                                                
                                                                                
end /* do AffectedCI */                                                         
                                                                                
call JSON_termParser                                                            
                                                                                
return 0                                                                        
                                                                                
/*****************************************************************************/ 
/*****************************************************************************/ 
/*****************************************************************************/ 
/*****************************************************************************/ 
/*****************************************************************************/ 
/*****************************************************************************/ 
                                                                                
/***********************************************/                               
/* Function:  debug_json_text                  */                               
/*                                             */                               
/* help implementing new functionalities       */                               
/* using as example a json text read from a    */                               
/* file.                                       */                               
/*                                             */                               
/* Returns: 0 if successful, -1 if not.        */                               
/***********************************************/                               
                                                                                
debug_json_text:                                                                
                                                                                
/* Validate the JSON Text read from ddname JSONIN         */                    
/* and copied in responsebody */                                                
                                                                                
"execio 1 diskr JSONIN (stem jsonIN."                                           
                                                                                
jsonTEXT = strip(jsonIN.1)                                                      
say ''                                                                          
say 'JSON Text read from File: '                                                
say ''                                                                          
say jsonTEXT                                                                    
say ''                                                                          
                                                                                
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
/*****************************************/                                     
/* Extract specific data and surface it, */                                     
/* then release the parser instance.     */                                     
/*****************************************/                                     
if VERBOSE then                                                                 
say 'Getting number of elements returned in the array of objects'               
                                                                                
AffectedCIsList = JSON_findValue( 0, "result", HWTJ_ARRAY_TYPE )                
                                                                                
/* NumOfElements = 0 */                                                         
                                                                                
address hwtjson "hwtjgnue ",                                                    
               "ReturnCode ",                                                   
               "parserHandle ",                                                 
               "AffectedCIsList ",                                              
               "NumOfAffectedCIs ",                                             
               "DiagArea."                                                      
                                                                                
RexxRC = RC                                                                     
if JSON_isError(RexxRC,ReturnCode) then                                         
do                                                                              
   call JSON_surfaceDiag 'hwtjgnue', RexxRC, ReturnCode, DiagArea.              
   return fatalError( '** hwtjgnue failure **' )                                
end  /* endif hwtjinit failure */                                               
                                                                                
Say 'Number of affected CIs in the Change Request: 'NumOfAffectedCIs            
say ''                                                                          
                                                                                
/* Process each element of the array of objects */                              
                                                                                
do AffectedCI=0 to  NumOfAffectedCIs-1                                          
                                                                                
address hwtjson  "hwtjgaen ",                                                   
                  "ReturnCode ",                                                
                  "ParserHandle ",                                              
                  "AffectedCIsList ",                                           
                  "AffectedCI",                                                 
                  "EntryValueHandle",                                           
                  "DiagArea."                                                   
                                                                                
RexxRC = RC                                                                     
if JSON_isError(RexxRC,ReturnCode) then                                         
   do                                                                           
   call JSON_surfaceDiag 'hwtjgaen', RexxRC, ReturnCode, DiagArea.              
   return fatalError( '** hwtjgaen failure **' )                                
   end  /* endif hwtjinit failure */                                            
                                                                                
   disp_val=JSON_findValue( EntryValueHandle,"display_value" ,                  
                           ,HWTJ_STRING_TYPE)                                   
                                                                                
   say '   Affected CI 'AffectedCI+1': 'disp_val                                
                                                                                
end /* do AffectedCI */                                                         
                                                                                
call JSON_termParser                                                            
                                                                                
return 100                                                                      
                                                                                
