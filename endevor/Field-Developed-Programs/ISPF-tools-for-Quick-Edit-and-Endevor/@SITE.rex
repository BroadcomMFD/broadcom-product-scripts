   /*   REXX  */                                                                
   PARSE ARG Parm                                                               
                                                                                
/* Required for all Bundles :   */                                              
   /* Enter High Level Qualifiers */                                            
   SHLQ='IPRFX.IQUAL'   /* Systems High Level Qualifier */                      
   FHLQ='IPRFX.IQUAL'   /* Field Developed Program (FDP) HLQ */                 
   AHLQ='UPRFX.UQUAL'   /* Applications High Level Qualifier */                 
   /* Enter the name of the main Libraries for CA Services tools */             
/* APF Authorized libraries:   \    */                                          
   MyAUTULibrary = SHLQ'.CSIQAUTU'                                              
   MyAUTHLibrary = SHLQ'.CSIQAUTH'                                              
   MyLOADLibrary = SHLQ'.CSIQLOAD'                                              
   MyLOA2Library = FHLQ'.CSIQLOA2'                                              
/* Non-APF Authorized library: \    */                                          
   MyUTILLibrary = FHLQ'.CSIQLOA2'                                              
   MyCLS0Library = SHLQ'.CSIQCLS0'                                              
   MyCLS2Library = FHLQ'.CSIQCLS2'                                              
   MyOPTNLibrary = SHLQ'.CSIQOPTN'                                              
   MyOPT2Library = FHLQ'.CSIQOPT2'                                              
   MyMENULibrary = SHLQ'.CSIQMENU'                                              
   MyMEN2Library = FHLQ'.CSIQMEN2'                                              
   MyPENULibrary = SHLQ'.CSIQPENU'                                              
   MyPEN2Library = FHLQ'.CSIQPEN2'                                              
   MySENULibrary = SHLQ'.CSIQSENU'                                              
   MySEN2Library = FHLQ'.CSIQSEN2'                                              
   MyTENULibrary = SHLQ'.CSIQTENU'                                              
   MyTEN2Library = FHLQ'.CSIQTEN2'                                              
   MySampLibrary = SHLQ'.CSIQSAMP'                                              
   MyDATALibrary = SHLQ'.CSIQDATA'                                              
   MyJCLLibrary  = SHLQ'.CSIQJCL'                                               
   MyJCL2Library = FHLQ'.CSIQJCL2'                                              
   MySRC2Library = FHLQ'.CSIQSRC2'                                              
   /* JOB INFO FOR ALTERNATE ID & CONVERSION JOBS*/                             
   JnmPfx        = userid() /* default job name prefix */                       
   AltIDAcctCode = '00000000'                                                   
   AltIDJobClass = 'A'                                                          
   AltIDMsgClass = 'X'                                                          
                                                                                
/************************************************************/                  
/* Required for the Package Functions bundle :   */                             
   SchedulingPackageShipBundle = 'Y'  ;/* Auto/Sched Shipping */                
   MyHomeAddress  = '?????' ; /* Use HOMETEST for ip address */                 
   /* If SchedulingPackageShipBundle, list Transmission methods  */             
   TransmissionMethods = 'NETVIEW_FTP LOCAL   '                                 
   /* If SchedulingPackageShipBundle, list Shipment Models (JCL) */             
   TransmissionModels  = 'SHIP#FTP    SHIPLOCL'                                 
                                                                                
   /* Select one of the following - Usually 'Rules' */                          
   ShipSchedulingMethod = 'One  '     ;/* 1  Destination  */                    
   ShipSchedulingMethod = 'None '     ;/* No Shipping     */                    
   ShipSchedulingMethod = 'Notes'     ;/* Use PKG Notes   */                    
   ShipSchedulingMethod = 'Rules'     ;/* Rules / Notes   */                    
   /* Verify the name of the Trigger File - must be allocated */                
   TriggerFileName = AHLQ'.SHIPMENT.TRIGGER'                                    
                                                                                
                                                                                
/************************************************************/                  
/***************************************************************/               
/***************************************************************/               
 /* do not alter following - required for all bundle processing */              
/************************************************************/                  
 /* do not alter following - required for all bundle processing */              
   IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)                              
   ELSE RETURN 'Not-valid:'||Parm                                               
   EXIT                                                                         
