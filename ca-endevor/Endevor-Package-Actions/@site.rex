/*   REXX  */
PARSE ARG Parm

/* If a DDNAME of @CA06  is allocated, then Trace */
WhatDDName = '@CA66'
CALL BPXWDYN "INFO FI("WhatDDName")",
"INRTDSN(DSNVAR) INRDSNT(myDSNT)"
if Substr(DSNVAR,1,1) /= ' ' then TraceRc = 1;
IF TraceRc = 1 then Trace R


/* Required for all Bundles :   */
/* Enter High Level Qualifiers */
/* SHLQ='CADEMO.ENDV.RUN' */
SHLQ='SHARE.NDVR.R181'
AHLQ='SHARE.NDVR.R181'   /* Applications High Level Qualifier */
/* Enter the name of the main Libraries for CA Services tools */
/* APF Authorized libraries:   \    */
MyAUTULibrary = SHLQ'.CSIQAUTU'
MyAUTHLibrary = SHLQ'.CSIQAUTH'
MyLOADLibrary = SHLQ'.CSIQLOAD'
/* Non-APF Authorized library: \    */
MyUTILLibrary = 'SHARE.NDVR.R181.CSIQAUTU'
MyCLS0Library = SHLQ'.CSIQCLS0'
MyCLS2Library = 'UKDEMO.CA66.COMMON.CLIST'
MyCLS2Library = 'PSP.ENDV.TEAM.REXX'        /* Last one wins */
MyOPTNLibrary = SHLQ'.CSIQOPTN'
MyOPT2Library = 'PSP.ENDV.TEAM.OPTIONS'
MyOPT2Library = 'PSP.ENDV.TEAM.ISPSLIB'
MyMENULibrary = SHLQ'.CSIQMENU'
MyMEN2Library = 'SYS2.ISPMLIB'
MyPENULibrary = SHLQ'.CSIQPENU'
MyPEN2Library = 'SYS2.ISPPLIB'
MySENULibrary = SHLQ'.CSIQSENU'
MySEN2Library = 'PSP.ENDV.TEAM.MODELS'
MyTENULibrary = SHLQ'.CSIQSENU'
MyTEN2Library = SHLQ'.CSIQSEN2'
MyDATALibrary = 'PSP.ENDV.TEAM.TABLES'
MyJCLLibrary  = SHLQ'.CSIQJCL'
MyJCL2Library = SHLQ'.CSIQJCL'
MySRC2Library = SHLQ'.CSIQSRC'
/* Package Shipping info.... */
ShipSchedulingMethod = 'One'
   /* Indicate the FTP address for Notification return    */
   Destination = 'TSO32'   ;     /* Valid only if 'One'   */
   Hostprefix =  'PSP.ENDV';     /* Valid only if 'One'   */
   Rmteprefix =  'PUBLIC.NDVR' ; /* Valid only if 'One'   */
   ModelMember = 'SHIP#FTP'      /* Valid only if 'One'   */
   MyHomeAddress  = 'myEndevor@wyoursite.com'  /* your Endevor site's return address */
/* JOB INFO FOR ALTERNATE ID */
AltIDAcctCode = '1'
AltIDJobClass = 'A'
AltIDMsgClass = '?'
/************************************************************/
/* do not alter following - required for all bundle processing */
IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)
ELSE RETURN 'Not-valid'
EXIT

