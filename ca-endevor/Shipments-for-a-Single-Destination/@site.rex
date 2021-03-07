/*   REXX  */
PARSE ARG Parm
/* It is expected that this member be renamed to a name like :         */
/*     '@' <Lpar-name>                                                 */
/* For example, if running on the TEST lpar, rename to @TEST           */
/* If a DDNAME of @site  is allocated, then turn on Trace */
WhatDDName = '@site'
CALL BPXWDYN "INFO FI("WhatDDName")",
"INRTDSN(DSNVAR) INRDSNT(myDSNT)"
if Substr(DSNVAR,1,1) /= ' ' then TraceRc = 1;
IF TraceRc = 1 then Trace R
/*--+----1----+----2----+----3----+----4----+----5----+----6----+----7--*/
/* Required for all Bundles :   */
/* Enter High Level Qualifiers */
/* SHLQ='CADEMO.ENDV.RUN' */
SHLQ='SHARE.NDVR.R181'
AHLQ='SHARE.NDVR.R181'   /* Applications High Level Qualifier */
/* Enter the name of the main Libraries for CA Services tools */
/* Name Endevor's APF Authorized libraries:      */
MyAUTULibrary = SHLQ'.CSIQAUTU'
MyAUTHLibrary = SHLQ'.CSIQAUTH'
MyLOADLibrary = SHLQ'.CSIQLOAD'
/* Non-APF Authorized library:     */
MyCLS0Library = SHLQ'.CSIQCLS0'
/* For Rexx items in your bundle, name a MyCLS2Library     */
MyCLS2Library = 'UKDEMO.CA66.COMMON.CLIST'
MyCLS2Library = 'PSP.ENDV.TEAM.REXX'        /* Last one wins */
MyOPTNLibrary = SHLQ'.CSIQOPTN'
MyOPT2Library = 'PSP.ENDV.TEAM.OPTIONS'
MyOPT2Library = 'PSP.ENDV.TEAM.ISPSLIB'
MyMENULibrary = SHLQ'.CSIQMENU'
/* For Message (ISPMLIB) items in your bundle, name a MyMEN2Library */
MyMEN2Library = 'SYS2.ISPMLIB'
MyPENULibrary = SHLQ'.CSIQPENU'
/* For Panel (ISPPLIB) items in your bundle, name a MyPEN2Library */
MyPEN2Library = 'SYS2.ISPPLIB'
MySENULibrary = SHLQ'.CSIQSENU'
/* For Skeleton (ISPSLIB) items in your bundle, name a MySEN2Library */
MySEN2Library = 'PSP.ENDV.TEAM.MODELS'
MyTENULibrary = SHLQ'.CSIQSENU'
MyTEN2Library = SHLQ'.CSIQSEN2'
/* Some bundles use a Table. Name the library in MyDATALibrary       */
/* If shipping to one destination, a Table is unnecessary.           */
/* If shipping to multiple destinations a table dataset is required  */
/*   for naming the "Rules" that govern automated package shipments. */
/* Physically the MyDATALibrary should resemble Endevor's CSIQDATA   */ 
MyDATALibrary = 'PSP.ENDV.TEAM.TABLES'
MyJCLLibrary  = SHLQ'.CSIQJCL'
MyJCL2Library = SHLQ'.CSIQJCL'
/* For JCL items in your bundle, name the library in MySRC2Library   */
MySRC2Library = SHLQ'.CSIQJCL'
/* Package Shipping info.... */
/* Select one of the following automated package shipping methods:   */               
    ShipSchedulingMethod = 'None '     ;/* No Shipping               */            
    ShipSchedulingMethod = 'One'       ;/* only 1 destinaation       */         
    ShipSchedulingMethod = 'Rules'     ;/* Rules - mult destinations */         
ShipSchedulingMethod = 'One'
   /* Provide details when there is only One shipping destination    */
   Destination = 'TSO32'   ;     /* The oneShipment Destination   */
   Hostprefix =  'PSP.ENDV';     /* Host staging file prefix      */
   Rmteprefix =  'PUBLIC.NDVR' ; /* Remote staging file prefix    */
   ModelMember = 'SHIP#FTP'      /* Jcl image for shipment job    */
   MyHomeAddress  = 'myEndevor@yoursite.com'  
                 /*   \ your Endevor site's return address */
/* JOB INFO FOR ALTERNATE ID */
AltIDAcctCode = '1'
AltIDJobClass = 'A'
AltIDMsgClass = '?'
/************************************************************/
/* do not alter following - required for all bundle processing */
IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)
ELSE RETURN 'Not-valid'
EXIT

