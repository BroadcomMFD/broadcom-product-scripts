       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID. SNINCQRY.                                                    
       DATA DIVISION.                                                           
                                                                                
       WORKING-STORAGE SECTION.                                                 
                                                                                
      * Global vars required for majority of HTTP services                      
       01 Conn-Handle   Pic X(12) Value Zeros.                                  
       01 Rqst-Handle   Pic X(12) Value Zeros.                                  
       01 Diag-Area     Pic X(136) Value Zeros.                                 
                                                                                
      * Slist is used to pass custom HTTP headers on request                    
       01 Slist-Handle  Pic 9(9) Binary Value 0.                                
                                                                                
      * Dummy vars used by HWTHSET service                                      
       01 option-val-char    Pic X(999) Value Spaces.                           
       01 option-val-numeric Pic 9(9) Binary Value 0.                           
       01 option-val-addr    Pointer Value Null.                                
       01 option-val-len     Pic 9(9) Binary Value 0.                           
                                                                                
      * Function pointers used to setup response exit routines                  
       01 header-cb-ptr Function-Pointer Value Null.                            
       01 rspbdy-cb-ptr Function-Pointer Value Null.                            
                                                                                
      * Data passed to the response header exit routine                         
       01 hdr-udata.                                                            
         05 hdr-udata-eye   Pic X(8) Value 'HDRUDATA'.                          
         05 hdr-rspcode-ptr Pointer Value Null.                                 
         05 hdr-count-ptr   Pointer value Null.                                 
         05 hdr-flags-ptr   Pointer Value Null.                                 
                                                                                
      * Response status code returned from the server                           
      * This gets passed to the response header exit                            
      * through the header user data structure                                  
       01 http-resp-code Pic 9(9) Binary Value 0.                               
                                                                                
      * Count of HTTP headers processed by our exit                             
       01 http-hdr-count Pic 9(9) Binary Value 0.                               
                                                                                
      * Data passed to the response body exit routine                           
       01 body-udata.                                                           
         05 body-udata-eye     Pic X(8) Value 'BDYUDATA'.                       
         05 hdr-flags-ptr      Pointer Value Null.                              
         05 resp-body-data-ptr Pointer Value Null.                              
                                                                                
      * Flag shared between response body and response header exits             
      * Used by the response header exit to indicate that the response          
      * body is JSON.                                                           
       01 hdr-flags.                                                            
         05 json-response-flag    Pic 9.                                        
           88 json-response-true  Value 1.                                      
           88 json-response-false Value 0.                                      
                                                                                
       01 request-status-flag Pic 9.                                            
         88 request-successful   Value 1.                                       
         88 request-unsuccessful Value 0.                                       
                                                                                
      * Structure for storing data returned from ServiceNow website             
      * Filled out by the response body exit                                    
       01 resp-body-data.                                                       
         05 resp-body-data-eye Pic X(8) Value 'INCIDENT'.                       
         05 Incident-info.                                                      
           10 Incident-number       Pic X(10).                                  
           10 Incident-state        Pic X(1).                                   
           10 Incident-active       Pic X(5).                                   
           10 Incident-priority     Pic X(1).                                   
           10 Incident-openedat     Pic X(19).                                  
                                                                                
      * Temp variables for storing data                                         
       77 Debug                     PIC X(3).                                   
       77 WK-TALLY                  PIC 9(2).                                   
       77 UserName                  PIC X(32) Value Spaces.                     
       77 UserName-LEN              PIC 9(9) USAGE BINARY VALUE 0.              
       77 UserPassword              PIC X(32) Value Spaces.                     
       77 UserPassword-LEN          PIC 9(9) USAGE BINARY VALUE 0.              
       77 TRACE-DD                  PIC X(8) Value Spaces.                      
                                                                                
                                                                                
                                                                                
      *                                                                         
         COPY HWTHICOB.                                                         
      *                                                                         
       LINKAGE SECTION.                                                         
                                                                                
      * User-supplied parameter: expecting a 3-char IATA airport code           
      *01 jcl-parm.                                                             
      *  05 parm-len    Pic S9(3) binary.                                       
      *  05 parm-string.                                                        
      *    10 parm-char Pic X occurs 0 to 100 times                             
      *               depending on parm-len.                                    
       01 INC-NUMBER    PIC X(11).                                              
       01 INC-IS-ACTIVE PIC x(5).                                               
       01 INC-STATE     PIC x(1).                                               
                                                                                
       PROCEDURE DIVISION using INC-NUMBER                                      
                                INC-IS-ACTIVE                                   
                                INC-STATE.                                      
       Begin.                                                                   
           MOVE 'NO' to Debug                                                   
                                                                                
           If Debug = 'YES'                                                     
                                                                                
           Display "***********************************************"            
           Display "** HTTP Web Enablement Toolkit Sample Begins **"            
           Display "*                                             *"            
           Display "Incident: " INC-NUMBER                                      
                                                                                
           End-if                                                               
                                                                                
           *> Initialize and set up a connection handle                         
           Perform HTTP-Init-Connection                                         
                                                                                
           If (HWTH-OK)                                                         
                                                                                
             *> Set the required options before connecting to the server        
             Perform HTTP-Setup-Connection                                      
                                                                                
             If (HWTH-OK)                                                       
                                                                                
               *> Connect to the HTTP server                                    
               Perform HTTP-Connect                                             
                                                                                
               If (HWTH-OK)                                                     
                                                                                
                 *> Initialize and set up a request                             
                 Perform HTTP-Init-Request                                      
                                                                                
                 If (HWTH-OK)                                                   
                                                                                
                   *> Set the necessary options before connecting               
                   *> to the server.                                            
                   Perform HTTP-Setup-Request                                   
                                                                                
                   If (HWTH-OK)                                                 
                                                                                
                     *> Send the request                                        
                     Perform HTTP-Issue-Request                                 
                                                                                
                     If (HWTH-OK)                                               
                                                                                
                       *> If the response code was ok, write the data           
                       If http-resp-code equal 200 then                         
                         Perform Display-Incident-Data                          
                         Set request-successful to true                         
                       End-If                                                   
                     End-If                                                     
                   End-If                                                       
                                                                                
                   *> Terminate the request                                     
                   Perform HTTP-Terminate-Request                               
                 End-If                                                         
                                                                                
                 *> Disconnect the connection                                   
                 Perform HTTP-Disconnect                                        
               End-If                                                           
             End-If                                                             
                                                                                
             *> Terminate the connection                                        
             Perform HTTP-Terminate-Connection                                  
           End-If                                                               
                                                                                
           *> If the last service was successful and the request                
           *> completed successfully, then put successful message               
           If HWTH-OK AND request-successful then                               
            If Debug = 'YES'                                                    
             Display "** Program Ended Successfully                **"          
            End-if                                                              
             MOVE 0 TO RETURN-CODE                                              
           else                                                                 
            If Debug = 'YES'                                                    
             Display "** Program Ended Unsuccessfully              **"          
            End-if                                                              
             MOVE 4095 TO RETURN-CODE                                           
           End-if                                                               
                                                                                
           If Debug = 'YES'                                                     
           Display "** HTTP Web Enablement Toolkit Sample Ends   **"            
           Display "***********************************************"            
           END-IF                                                               
           GOBACK.                                                              
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Init-Connection                               *          
      *   Initializes a connection handle using the HWTHINIT service *          
      *                                                              *          
      ****************************************************************          
       HTTP-Init-Connection.                                                    
                                                                                
           Set HWTH-HANDLETYPE-CONNECTION to true.                              
                                                                                
           Call "HWTHINIT" using                                                
             HWTH-RETURN-CODE                                                   
             HWTH-HANDLETYPE                                                    
             Conn-Handle                                                        
             HWTH-DIAG-AREA                                                     
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
             Display "** Initialize succeeded (HWTHINIT)"                       
            End-if                                                              
           else                                                                 
             Display "HWTHINIT FAILED: "                                        
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Init-Request                                  *          
      *   Initializes a request handle using the HWTHINIT service    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Init-Request.                                                       
                                                                                
           Set HWTH-HANDLETYPE-HTTPREQUEST to true.                             
                                                                                
           Call "HWTHINIT" using                                                
             HWTH-RETURN-CODE                                                   
             HWTH-HANDLETYPE                                                    
             Rqst-Handle                                                        
             HWTH-DIAG-AREA                                                     
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
             Display "** Initialize succeeded (HWTHINIT)"                       
            End-if                                                              
           else                                                                 
             Display "HWTHINIT FAILED: "                                        
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
      * Function: HTTP-Setup-Connection                                *        
      *           Sets the necessary connection options                *        
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
       HTTP-Setup-Connection.                                                   
                                                                                
           *>  ______________________________________________________           
           *> |                                                      |          
           *> | First, set the verbose option on. This option is     |          
           *> | handy when developing an application. Lots of        |          
           *> | informational error messages are written to          |          
           *> | standard output to help in debugging efforts.        |          
           *> | This option should likely be turned off with         |          
           *> | HWTH_VERBOSE_OFF or just not set at all (default is  |          
           *> | off) when the application goes into production.      |          
           *> |______________________________________________________|          
           Set HWTH-OPT-VERBOSE to true.                                        
           Set HWTH-VERBOSE-ON to true.                                         
           Set option-val-addr to address of HWTH-VERBOSE.                      
           Compute option-val-len = function length (HWTH-VERBOSE).             
                                                                                
           If Debug = 'YES'                                                     
            Display "** Set HWTH-OPT-VERBOSE for connection"                    
           End-if                                                               
           Call "HWTHSET" using                                                 
                          HWTH-RETURN-CODE                                      
                          Conn-Handle                                           
                          HWTH-Set-OPTION                                       
                          option-val-addr                                       
                          option-val-len                                        
                          HWTH-DIAG-AREA.                                       
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH-OPT-VERBOSE-OUTPUT                          |        
             *> |______________________________________________________|        
             Set HWTH-OPT-VERBOSE-OUTPUT to true                                
             Move "HWTTRACE" To TRACE-DD                                        
                                                                                
             Set option-val-addr to address of TRACE-DD                         
             Compute option-val-len =                                           
                 function length (TRACE-DD)                                     
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-VERBOSE-OUTPUT for connection **"        
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH_OPT_USE_SSL.                                |        
             *> |______________________________________________________|        
             Set HWTH-OPT-USE-SSL to true                                       
             Set HWTH-SSL-USE to true                                           
                                                                                
             Set option-val-addr to address of HWTH-USESSL                      
             Compute option-val-len =                                           
                 function length (HWTH-USESSL)                                  
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-USE-SSL for connection"                  
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH_OPT_SSLVERSION.                             |        
             *> |______________________________________________________|        
             Set HWTH-OPT-SSLVERSION to true                                    
             Set HWTH-SSLVERSION-TLSV12 to true                                 
                                                                                
             Set option-val-addr to address of HWTH-SSLVERSION                  
             Compute option-val-len =                                           
                 function length (HWTH-SSLVERSION)                              
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-SSLVERSION for connection"               
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH_OPT_SSLVERSION.                             |        
             *> |______________________________________________________|        
             Set HWTH-OPT-SSLKEYTYPE to true                                    
             Set HWTH-SSLKEYTYPE-KEYRINGNAME to true                            
                                                                                
             Set option-val-addr to address of HWTH-SSLKEYTYPE                  
             Compute option-val-len =                                           
                 function length (HWTH-SSLKEYTYPE)                              
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-SSLKEYTYPE for connection"               
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH_OPT_SSLKEY.                                 |        
             *> |______________________________________________________|        
             Set HWTH-OPT-SSLKEY to true                                        
                                                                                
             Move "**CHANGE** KEYRING NAME" to  option-val-char                 
             Move 16 to option-val-len                                          
                                                                                
             Set option-val-addr to address of option-val-char                  
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-SSLKEY for connection"                   
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set URI for connection handle to ServiceNow app      |        
             *> |______________________________________________________|        
             Set HWTH-OPT-URI to true                                           
                                                                                
             Move "**CHANGE** SERVICENOW INSTANCE URL"                          
                  to option-val-char                                            
             Move 33 to option-val-len                                          
                                                                                
             Set option-val-addr to address of option-val-char                  
                                                                                
             If Debug = 'YES'                                                   
               Display "** Set HWTH-OPT-URI for connection"                     
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set HWTH_OPT_COOKIETYPE                              |        
             *> |   Enable the cookie engine for this connection.  Any |        
             *> |   "eligible" stored cookies will be resent to the    |        
             *> |   host on subsequent interactions automatically.     |        
             *> |   interactions automatically.                        |        
             *> |______________________________________________________|        
             Set HWTH-OPT-COOKIETYPE to true                                    
             Set HWTH-COOKIETYPE-SESSION to true                                
             Set option-val-addr to address of HWTH-COOKIETYPE                  
             Compute option-val-len =                                           
                 function length (HWTH-COOKIETYPE)                              
                                                                                
             If Debug = 'YES'                                                   
               Display "** Set HWTH-OPT-COOKIETYPE for connection"              
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            Conn-Handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           else                                                                 
             Display "HWTHSET FAILED: "                                         
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Connect                                       *          
      *   Issues the hwthconn service and performs error checking    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Connect.                                                            
                                                                                
           Call "HWTHCONN" using                                                
             HWTH-RETURN-CODE                                                   
             Conn-Handle                                                        
             HWTH-DIAG-AREA                                                     
                                                                                
           If (HWTH-OK)                                                         
                                                                                
            If Debug = 'YES'                                                    
             Display "** Connect succeeded (HWTHCONN)"                          
            End-if                                                              
                                                                                
           else                                                                 
             Display "Connect failed (HWTHCONN)."                               
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Issue-Request                                 *          
      *   Issues the hwthrqst service and performs error checking    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Issue-Request.                                                      
                                                                                
           Call "HWTHRQST" using                                                
             HWTH-RETURN-CODE                                                   
             Conn-Handle                                                        
             Rqst-Handle                                                        
             HWTH-DIAG-AREA                                                     
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
              Display "** Request succeeded (HWTHRQST)"                         
            End-if                                                              
           else                                                                 
             Display "Request failed (HWTHRQST)."                               
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
      * Function: HTTP-Setup-Request                                   *        
      *           Sets the necessary request options                   *        
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
       HTTP-Setup-Request.                                                      
                                                                                
           *>  ______________________________________________________           
           *> |                                                      |          
           *> | Set HTTP Request method.                             |          
           *> |   A GET request method is used to get data from      |          
           *> |   the server.                                        |          
           *> |______________________________________________________|          
           Set HWTH-OPT-REQUESTMETHOD to true                                   
           Set HWTH-HTTP-REQUEST-GET to true                                    
           Set option-val-addr to address of HWTH-REQUESTMETHOD                 
           Compute option-val-len =                                             
               function length (HWTH-REQUESTMETHOD)                             
                                                                                
           If Debug = 'YES'                                                     
             Display "** Set HWTH-REQUESTMETHOD for request"                    
           End-if                                                               
           Call "HWTHSET" using                                                 
                          HWTH-RETURN-CODE                                      
                          rqst-handle                                           
                          HWTH-Set-OPTION                                       
                          option-val-addr                                       
                          option-val-len                                        
                          HWTH-DIAG-AREA                                        
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set the request URI                                  |        
             *> |   Set the URI that identifies a resource by name     |        
             *> |   that is the target of our request.                 |        
             *> |______________________________________________________|        
             Set HWTH-OPT-URI to true                                           
             Move 1 to option-val-len                                           
             STRING "/api/now/table/incident?sysparm_query=number="             
                    DELIMITED BY SIZE                                           
                    INC-NUMBER DELIMITED BY SIZE                                
                    INTO                                                        
                    option-val-char WITH POINTER option-val-len                 
                                                                                
             Set option-val-addr to address of option-val-char                  
             SUBTRACT 1 FROM option-val-len                                     
                                                                                
             If Debug = 'YES'                                                   
               Display "** Set HWTH-OPT-URI for request"                        
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             Move "**CHANGE** ADMIN USERID"   to UserName                       
             Move "**CHANGE** ADMIN PASSWORD" to UserPassword                   
                                                                                
             Move ZERO TO WK-TALLY                                              
             Inspect Function Reverse(UserName)                                 
                     TALLYING WK-TALLY FOR LEADING SPACES                       
             COMPUTE UserName-LEN = 32 - WK-TALLY                               
                                                                                
             Move ZERO TO WK-TALLY                                              
             Inspect Function Reverse(UserPassword)                             
                     TALLYING WK-TALLY FOR LEADING SPACES                       
             COMPUTE UserPassword-LEN = 32 - WK-TALLY                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | ServiceNow Instance Authentication                   |        
             *> |  Single sign-on uses HTTP basic authentication       |        
             *> |______________________________________________________|        
             Set HWTH-OPT-HTTPAUTH to true                                      
             Set HWTH-HTTPAUTH-BASIC to true                                    
                                                                                
             Set option-val-addr to address of HWTH-HTTPAUTH                    
             Compute option-val-len =                                           
               function length (HWTH-HTTPAUTH)                                  
                                                                                
             If Debug = 'YES'                                                   
               Display "** HWTH-OPT-HTTPAUTH for request"                       
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | ServiceNow Instance UserName                         |        
             *> |______________________________________________________|        
             Set HWTH-OPT-USERNAME to true                                      
                                                                                
             Set option-val-addr to address of UserName                         
                                                                                
             If Debug = 'YES'                                                   
               Display "** HWTH-OPT-USERNAME for request"                       
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            USERNAME-LEN                                        
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | ServiceNow Instance UserPassword                     |        
             *> |______________________________________________________|        
             Set HWTH-OPT-PASSWORD to true                                      
                                                                                
             Set option-val-addr to address of UserPassword                     
                                                                                
             If Debug = 'YES'                                                   
               Display "** HWTH-OPT-USRNAME for request"                        
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            USERPASSWORD-LEN                                    
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
                                                                                
           If HWTH-OK                                                           
                                                                                
             *> Create a list of HTTP headers                                   
             Perform Build-Slist                                                
                                                                                
             *> Specify the HTTP request headers                                
             Set HWTH-OPT-HTTPHEADERS to true                                   
             Set option-val-addr to address of Slist-Handle                     
             Compute option-val-len = function length(Slist-Handle)             
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-HTTPHEADERS for request"                 
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *> Direct the toolkit to convert the response body                 
             *> from ASCII to EBCDIC                                            
             Set HWTH-OPT-TRANSLATE-RESPBODY to true                            
             Set HWTH-XLATE-RESPBODY-A2E to true                                
             Set option-val-addr to address of HWTH-XLATE-RESPBODY              
             Compute option-val-len =                                           
                 function length (HWTH-XLATE-RESPBODY)                          
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-TRANSLATE-RESPBODY for request"          
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set the response header callback routine             |        
             *> |   Set the address of the routine that is to receive  |        
             *> |   control once for every response header that we     |        
             *> |   receive                                            |        
             *> |______________________________________________________|        
             Set HWTH-OPT-RESPONSEHDR-EXIT to true                              
             Set header-cb-ptr to ENTRY "HWTHHDRX"                              
             Set option-val-addr to address of header-cb-ptr                    
             Compute option-val-len =                                           
                 function length (header-cb-ptr)                                
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-RESPONSEHDR-EXIT for request"            
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *> Initialize the header user data pointers to allow               
             *> the response header exit to communicate the HTTP status         
             *> code and hdr-flags to the main program                          
             Set hdr-rspcode-ptr to address of http-resp-code                   
             Set hdr-count-ptr to address of http-hdr-count                     
             Set hdr-flags-ptr of hdr-udata to address of hdr-flags             
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set the response header callback routine user data   |        
             *> |   Example to show how data can be passed to the      |        
             *> |   response header callback routine to allow the      |        
             *> |   routine to customize its processing.               |        
             *> |______________________________________________________|        
             Set HWTH-OPT-RESPONSEHDR-USERDATA to true                          
             Set option-val-addr to address of hdr-udata                        
             Compute option-val-len = function length(hdr-udata)                
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-RESPONSEHDR-USERDATA for request"        
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set the response body callback routine               |        
             *> |   Set the address of the routine that is to receive  |        
             *> |   control if there is a response body returned by    |        
             *> |   the server                                         |        
             *> |______________________________________________________|        
             Set HWTH-OPT-RESPONSEBODY-EXIT to true                             
             Set rspbdy-cb-ptr to ENTRY "HWTHBDYX"                              
             Set option-val-addr to address of rspbdy-cb-ptr                    
             Compute option-val-len =                                           
                 function length (rspbdy-cb-ptr)                                
                                                                                
             If Debug = 'YES'                                                   
              Display "** Set HWTH-OPT-RESPONSEBODY-EXIT for request"           
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
                                                                                
           If HWTH-OK                                                           
                                                                                
             *>  ______________________________________________________         
             *> |                                                      |        
             *> | Set the response body callback routine user data     |        
             *> |   Example to show how data can be passed to the      |        
             *> |   response body callback routine to allow the routine|        
             *> |   to customize its processing.                       |        
             *> |______________________________________________________|        
             Set hdr-flags-ptr of body-udata to address of hdr-flags            
             Set resp-body-data-ptr to address of resp-body-data                
                                                                                
             Set HWTH-OPT-RESPONSEBODY-USERDATA to true                         
             Set option-val-addr to address of body-udata                       
             Compute option-val-len = function length(body-udata)               
                                                                                
             If Debug = 'YES'                                                   
             Display "** Set HWTH-OPT-RESPONSEBODY-USERDATA for request"        
             End-if                                                             
             Call "HWTHSET" using                                               
                            HWTH-RETURN-CODE                                    
                            rqst-handle                                         
                            HWTH-Set-OPTION                                     
                            option-val-addr                                     
                            option-val-len                                      
                            HWTH-DIAG-AREA                                      
           End-If                                                               
           .                                                                    
                                                                                
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
      * Function: Build-Slist                                          *        
      *           Sets the necessary request options                   *        
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
       Build-Slist.                                                             
                                                                                
                                                                                
                                                                                
           *>  ______________________________________________________           
           *> |                                                      |          
           *> | Add the Accept request header                        |          
           *> |   Create a brand new SLST and specify the first      |          
           *> |   header to be an "ACCEPT" header that requests that |          
           *> |   the server return the data requested by the GET    |          
           *> |   request to be in JSON format.                      |          
           *> |______________________________________________________|          
           Move 1 to option-val-len.                                            
           String "Accept: application/json" delimited by size                  
                  into option-val-char with pointer                             
                  option-val-len.                                               
           Subtract 1 from option-val-len.                                      
                                                                                
           Set option-val-addr to address of option-val-char.                   
           Set HWTH-SLST-NEW to true.                                           
                                                                                
           Call "HWTHSLST" using                                                
                           HWTH-RETURN-CODE                                     
                           rqst-handle                                          
                           HWTH-SLST-function                                   
                           Slist-Handle                                         
                           option-val-addr                                      
                           option-val-len                                       
                           HWTH-DIAG-AREA.                                      
           If HWTH-OK                                                           
                                                                                
           *>  ______________________________________________________           
           *> |                                                      |          
           *> | Add the Accept-Language request header               |          
           *> |   Append to the just-created SLST and specify an     |          
           *> |   additional option "Accept-Language" to infer to    |          
           *> |   the server the regional settings preferred by this |          
           *> |   application.                                       |          
           *> |______________________________________________________|          
             Move 1 to option-val-len                                           
             String "Accept-Language: en-US" delimited by size                  
                    into option-val-char with pointer                           
                    option-val-len                                              
             Subtract 1 from option-val-len                                     
                                                                                
             Set option-val-addr to address of option-val-char                  
             Set HWTH-SLST-APPEND to true                                       
                                                                                
             If Debug = 'YES'                                                   
              Display "** Adding SLIST APPEND"                                  
             End-if                                                             
             Call "HWTHSLST" using                                              
                             HWTH-RETURN-CODE                                   
                             rqst-handle                                        
                             HWTH-SLST-function                                 
                             Slist-Handle                                       
                             option-val-addr                                    
                             option-val-len                                     
                             HWTH-DIAG-AREA                                     
           else                                                                 
             Display "Slist service failed (HWTHSLST)."                         
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Display-Incident-Data                                        *          
      *                                                              *          
      *                                                              *          
      ****************************************************************          
      *     10 Incident-number       Pic X(11).                                 
      *     10 Incident-state        Pic X(1).                                  
      *     10 Incident-active       Pic X(5).                                  
      *     10 Incident-priority     Pic X(1).                                  
      *     10 Incident-openedat     Pic X(19).                                 
                                                                                
       Display-Incident-Data.                                                   
                                                                                
           If Debug = 'YES'                                                     
            Display "***********************************"                       
            Display "Incident data for " INC-NUMBER                             
            Display "***********************************"                       
                                                                                
            Display "Incident Number: " Incident-number                         
            Display "Incident state: " Incident-state                           
                                                                                
            Display "Inicident Active: " Incident-active                        
                                                                                
            Display "Incident Priority: " Incident-priority                     
            Display "Incident Open Date: " Incident-openedat                    
            Display "-----------------------------------"                       
           End-if                                                               
            MOVE Incident-state to INC-STATE                                    
            Move Incident-active to INC-IS-ACTIVE                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Disconnect                                    *          
      *   Issues the hwthdisc service and performs error checking    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Disconnect.                                                         
                                                                                
           Call "HWTHDISC" using                                                
             HWTH-RETURN-CODE                                                   
             Conn-Handle                                                        
             HWTH-DIAG-AREA                                                     
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
             Display "** Disconnect succeeded (HWTHDISC)"                       
            End-if                                                              
           else                                                                 
             Display "Disconnect failed (HWTHDISC)."                            
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Terminate-Connection                          *          
      *   Issues the hwthterm service and performs error checking    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Terminate-Connection.                                               
                                                                                
           Set HWTH-NOFORCE to true.                                            
                                                                                
           Call "HWTHTERM" using                                                
             HWTH-RETURN-CODE                                                   
             Conn-Handle                                                        
             HWTH-FORCETYPE                                                     
             HWTH-DIAG-AREA.                                                    
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
             Display "** Terminate succeeded (HWTHTERM)"                        
            End-if                                                              
           else                                                                 
             Display "Terminate failed (HWTHTERM)."                             
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
      ****************************************************************          
      *                                                              *          
      * Function: HTTP-Terminate-Request                             *          
      *   Issues the hwthterm service and performs error checking    *          
      *                                                              *          
      ****************************************************************          
       HTTP-Terminate-Request.                                                  
                                                                                
           Set HWTH-NOFORCE to true.                                            
                                                                                
           Call "HWTHTERM" using                                                
             HWTH-RETURN-CODE                                                   
             Rqst-Handle                                                        
             HWTH-FORCETYPE                                                     
             HWTH-DIAG-AREA.                                                    
                                                                                
           If (HWTH-OK)                                                         
            If Debug = 'YES'                                                    
             Display "** Terminate succeeded (HWTHTERM)"                        
            End-if                                                              
           else                                                                 
             Display "Terminate failed (HWTHTERM)."                             
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
                                                                                
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
      * Function: Set-Http-Option                                      *        
      *           Sets the specified HTTP option                       *        
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID Set-Http-Option COMMON.                                       
       DATA DIVISION.                                                           
                                                                                
       LINKAGE SECTION.                                                         
       01 handle                      Pic X(12).                                
       01 option                      Pic 9(9) Binary.                          
       01 option-val-addr             USAGE POINTER.                            
       01 option-val-len              Pic 9(9) Binary.                          
                                                                                
       PROCEDURE DIVISION using handle,                                         
                                option,                                         
                                option-val-addr,                                
                                option-val-len.                                 
        Begin.                                                                  
                                                                                
           Call "HWTHSET" using                                                 
                        HWTH-RETURN-CODE                                        
                        handle                                                  
                        option                                                  
                        option-val-addr                                         
                        option-val-len                                          
                        HWTH-DIAG-AREA.                                         
                                                                                
           If (HWTH-OK)                                                         
             Display "** Set succeeded (HWTHSET)"                               
           else                                                                 
             Display "Set failed (HWTHSET)."                                    
             Call "DSPHDIAG" using                                              
                             HWTH-RETURN-CODE                                   
                             HWTH-DIAG-AREA                                     
           End-If                                                               
           .                                                                    
                                                                                
       End Program Set-Http-Option.                                             
                                                                                
       END PROGRAM SNINCQRY.                                                    
                                                                                
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
      * Function: HWTHHDRX                                             *        
      *           Sample Response Header Callback Routine (Exit)       *        
      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * **        
       IDENTIFICATION DIVISION.                                                 
       PROGRAM-ID HWTHHDRX.                                                     
       DATA DIVISION.                                                           
                                                                                
       WORKING-STORAGE SECTION.                                                 
       01 Content-Type Pic X(12) Value "CONTENT-TYPE".                          
       01 Json-Content Pic X(16) Value "APPLICATION/JSON".                      
       01 Max-Display-Size Pic 9(9) Binary Value 30.                            
       01 rsp-status-code  Pic 9(9) Binary Value 0.                             
       01 Debug            Pic x(3).                                            
                                                                                
       LOCAL-STORAGE SECTION.                                                   
       01 name-max-len     Pic 9(9) Binary Value 0.                             
       01 value-max-len    Pic 9(9) Binary Value 0.                             
       01 name-ucase       Pic X(999) Value Spaces.                             
       01 value-ucase      Pic X(999) Value Spaces.                             
       01 Content-Type-Len Pic 9(9) Binary Value 0.                             
       01 Json-Content-Len Pic 9(9) Binary Value 0.                             
                                                                                
       01  HWTH-RESP-EXIT-FLAGS Global Pic 9(9) Binary.                         
           88  HWTH-EXITFLAG-COOKIESTORE-FULL Value 1.                          
                                                                                
       01  HWTH-RESP-EXIT-RC             GLOBAL PIC 9(9) BINARY.                
           88  HWTH-RESP-EXIT-RC-OK             VALUE 0.                        
           88  HWTH-RESP-EXIT-RC-ABORT          VALUE 1.                        
                                                                                
       LINKAGE SECTION.                                                         
       01 http-resp-line  Pic X(20).                                            
       01 exit-flags      Pic 9(9) Binary.                                      
       01 hdr-name-ptr    Usage Pointer.                                        
       01 hdr-name-len    Pic 9(9) Binary.                                      
       01 hdr-value-ptr   Usage Pointer.                                        
       01 hdr-value-len   Pic 9(9) Binary.                                      
       01 hdr-udata-ptr   Usage Pointer.                                        
       01 hdr-udata-len   Pic 9(9) Binary.                                      
                                                                                
       01 hdr-name-dsect  Pic X(999).                                           
       01 hdr-value-dsect Pic X(999).                                           
       01 reason-dsect    Pic X(128).                                           
                                                                                
       01 hdr-udata.                                                            
         05 hdr-udata-eye   Pic X(8).                                           
         05 hdr-rspcode-ptr Pointer.                                            
         05 hdr-count-ptr   Pointer.                                            
         05 hdr-flags-ptr   Pointer.                                            
                                                                                
       01 http-resp-code Pic 9(9) Binary.                                       
       01 http-hdr-count Pic 9(9) Binary.                                       
                                                                                
       01 hdr-flags.                                                            
         05 json-response-flag    Pic 9.                                        
           88 json-response-true  Value 1.                                      
           88 json-response-false Value 0.                                      
                                                                                
       01  HWTH-RESP-STATUS-MAP.                                                
           05  HWTH-STATUS-CODE       Pic 9(9) Binary.                          
           05  HWTH-STATUS-VERS-PTR   Pointer.                                  
           05  HWTH-STATUS-VERS-LEN   Pic 9(9) Binary.                          
           05  HWTH-STATUS-REASON-PTR Pointer.                                  
           05  HWTH-STATUS-REASON-LEN Pic 9(9) Binary.                          
                                                                                
       PROCEDURE DIVISION using http-resp-line,                                 
                                exit-flags                                      
                                hdr-name-ptr,                                   
                                hdr-name-len,                                   
                                hdr-value-ptr,                                  
                                hdr-value-len,                                  
                                hdr-udata-ptr,                                  
                                hdr-udata-len.                                  
       Begin.                                                                   
                                                                                
           Move 'NO' to Debug                                                   
                                                                                
           If Debug = 'YES'                                                     
            Display "*******************************************"               
            Display "** Response Header Exit Receives Control **"               
           End-if                                                               
                                                                                
                                                                                
