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
/* SHLQ='YourhlqENDV.RUN' */
   SHLQ='Yourhlq.NDVR.R1801'
   AHLQ='Yourhlq.NDVR'   /* APPLICATIONS HIGH LEVEL QUALIFIER */
/* Enter the name of the main Libraries for CA Services tools */

/* Name Endevor's APF Authorized libraries:      */
MyAUTULibrary = SHLQ'.CSIQAUTU'
MyAUTULibrary = 'Yourhlq.NDVR.R1801.CSIQAUTU'
MyAUTHLibrary = SHLQ'.CSIQAUTH'
MyLOADLibrary = SHLQ'.CSIQLOAD'
/* Non-APF Authorized library:     */
   MyUTILLibrary = 'Yourhlq.NDVR.ADMIN.ENDEVOR.LOADLIB'
MyCLS0Library = SHLQ'.CSIQCLS0'
MyOPTNLibrary = SHLQ'.CSIQOPTN'
/* For Rexx items in your bundle, name a MyCLS2Library     */
   MyCLS2Library = 'Yourhlq.NDVR.ADMIN.ENDEVOR.CLSTREXX'
   MyUTILLibrary = 'Yourhlq..CSIQOPTN.OVERRIDE'
   MyOPT2Library = 'Yourhlq.NDVR.ADMIN.ENDEVOR.ISPS'
MyMENULibrary = SHLQ'.CSIQMENU'
/* For Message (ISPMLIB) items in your bundle, name a MyMEN2Library */
   MyMEN2Library = 'YourISPF.ISPMLIB'
MyPENULibrary = SHLQ'.CSIQPENU'
/* For Panel (ISPPLIB) items in your bundle, name a MyPEN2Library */
   MyPEN2Library = 'YourISPF.ISPPLIB'
MySENULibrary = SHLQ'.CSIQSENU'
/* For Skeleton (ISPSLIB) items in your bundle, name a MySEN2Library */
   MySEN2Library = 'Yourhlq.NDVR.ADMIN.ENDEVOR.ISPS'
MyTENULibrary = SHLQ'.CSIQSENU'
MyTEN2Library = SHLQ'.CSIQSEN2'
/* Some bundles use a Table. Name the library in MyDATALibrary       */
/* If shipping to one destination, a Table is unnecessary.           */
/* If shipping to multiple destinations a table dataset is required  */
/*   for naming the "Rules" that govern automated package shipments. */
/* Physically the MyDATALibrary should resemble Endevor's CSIQDATA   */
   MyDATALibrary = 'Yourhlq.NDVR.ADMIN.ENDEVOR.TABLES'
MyJCLLibrary  = SHLQ'.CSIQJCL'
MyJCL2Library = SHLQ'.CSIQJCL'
/* For JCL items in your bundle, name the library in MySRC2Library   */
MySRC2Library = SHLQ'.CSIQJCL'
/************************************************************/
/* Required for the Package Functions bundle :   */
   SchedulingPackageShipBundle = 'Y'  ;/* Auto/Sched Shipping */
   /* If SchedulingPackageShipBundle, list Transmission methods  */
   TransmissionMethods = 'NETVIEW_FTP LOCAL   '
   /* If SchedulingPackageShipBundle, list Shipment Models (JCL) */
   TransmissionModels  = 'SHIP#FTP    SHIPLOCL'
/* Package Shipping info.... */
/* Select one of the following automated package shipping methods:   */

    ShipSchedulingMethod = 'None '     ;/* No Shipping               */
    ShipSchedulingMethod = 'One'       ;/* only 1 destinaation       */
    ShipSchedulingMethod = 'Notes'     ;/* Notes - mult destinations */
    ShipSchedulingMethod = 'Rules'     ;/* Rules - mult destinations */

   TriggerFileName = 'Yourhlq.NDVR.SHIPMENT.TRIGGER'

   /* Provide details when there is only One shipping destination    */
/* Destination = 'MTS32'   ;    */ /* The oneShipment Destination   */
/* Hostprefix =  'Yourhlq.NDVR';*/ /* Host staging file prefix      */
/* Rmteprefix =  'PUBLIC.NDVR' ;*/ /* Remote staging file prefix    */
/* ModelMember = 'SHIP#FTP'     */ /* Jcl image for shipment job    */

/* MyHomeAddress  = 'myEndevor@mysite.com' */
                 /*   \ your Endevor site's return address */
   MyHomeAddress  = 'lpar.mainframe.net'   /*  */

/* JOB INFO FOR ALTERNATE ID */
AltIDAcctCode = '0000'
AltIDAcctCode = GETACCTC()    /* get the current account code*/ 
AltIDJobClass = 'A'
AltIDMsgClass = 'Z'

/************************************************************/
/************************************************************/
/************************************************************/
/************************************************************/
/************************************************************/
/************************************************************/
/* do not alter following - required for all bundle processing */
IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)
ELSE RETURN 'Not-valid'
EXIT