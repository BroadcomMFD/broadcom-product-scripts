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
/* Enter High Level Qualifiers */
/* SHLQ='CADEMO.ENDV.RUN' */
   SHLQ='NDVR.R190'
   AHLQ='SYSDBOX.NDVR'   /* APPLICATIONS HIGH LEVEL QUALIFIER */

/* Name Endevor's APF Authorized libraries:      */
MyAUTULibrary = SHLQ'.CSIQAUTU'
MyAUTHLibrary = SHLQ'.CSIQAUTH'
MyLOADLibrary = SHLQ'.CSIQLOAD'
/* Non-APF Authorized library:     */
   MyUTILLibrary = 'SYSDBOX.NDVR.ADMIN.LOADLIB'
MyCLS0Library = SHLQ'.CSIQCLS0'
MyOPTNLibrary = SHLQ'.CSIQOPTN'
/* For Rexx items in your bundle, name a MyCLS2Library     */
   MyCLS2Library = 'SYSDBOX.NDVR.ADMIN.CLSTREXX'
   MyOPT2Library = 'SYSDBOX.NDVR.ADMIN.ISPS'
MyMENULibrary = SHLQ'.CSIQMENU'
/* For Message (ISPMLIB) items in your bundle, name a MyMEN2Library */
   MyMEN2Library = 'SYS2.ISPMLIB'
MyPENULibrary = SHLQ'.CSIQPENU'
/* For Panel (ISPPLIB) items in your bundle, name a MyPEN2Library */
   MyPEN2Library = 'SYS2.ISPPLIB'
MySENULibrary = SHLQ'.CSIQSENU'
/* For Skeleton (ISPSLIB) items in your bundle, name a MySEN2Library */
   MySEN2Library = 'SYSDBOX.NDVR.ADMIN.ISPS'
MyTENULibrary = SHLQ'.CSIQSENU'
MyTEN2Library = SHLQ'.CSIQSEN2'
/* Some bundles use a Table. Name the library in MyDATALibrary       */
/* If shipping to one destination, a Table is unnecessary.           */
/* If shipping to multiple destinations a table dataset is required  */
/*   for naming the "Rules" that govern automated package shipments. */
/* Physically the MyDATALibrary should resemble Endevor's CSIQDATA   */
   MyDATALibrary = 'SYSDBOX.NDVR.ADMIN.TABLES'
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
   TransmissionModels  = 'SHIPJOB     SHIPLOCL'
/* Package Shipping info.... */
/* Select one of the following automated package shipping methods:   */

    ShipSchedulingMethod = 'None '     ;/* No Shipping               */
    ShipSchedulingMethod = 'One'       ;/* only 1 destinaation       */
    ShipSchedulingMethod = 'Rules'     ;/* Rules - mult destinations */

   TriggerFileName = 'SYSDBOX.NDVR.SHIPMENT.TRIGGER'

   /* Provide details when there is only One shipping destination    */
/* Destination = 'TSO32'   ;    */ /* The oneShipment Destination   */
/* Hostprefix =  'SYSDBOX.NDVR';*/ /* Host staging file prefix      */
/* Rmteprefix =  'PUBLIC.NDVR' ;*/ /* Remote staging file prefix    */
/* ModelMember = 'SHIP#FTP'     */ /* Jcl image for shipment job    */

/* MyHomeAddress  = 'myEndevor@mysite.com' */
                 /*   \ your Endevor site's return address */
   MyHomeAddress  = 'DBOX.mycompany.com'   /* DBOX */

/* Enter one or more mapping representations  (not Prod)    */
/*       where PDA should search for inventory.             */
   PDAMaplist = ,        /* required only for PDA  */
      " DEV/D-QAS/Q ",
      " EMER/1-EMER/2 "
   /* " DEV/1-QAS/2 "        */
   /* " EMER/1-EMER/2 "                                        */
   /*                                                          */
/* JOB INFO FOR ALTERNATE ID */
AltIDAcctCode = '0000'
AltIDJobClass = 'A'
AltIDMsgClass = 'Z'
AltIDOrderfile = 'SYSDBOX.NDVR.JCL'
/************************************************************/
/************************************************************/

/* For ALIASE processing (Parallel Bundle)      :   */
   ALIASE_LibraryPrefix    = AHLQ  ; /* Lib and Alias prefix  */
     /*  Note: Required: Typically indicates the Application HLQ */
     /*        for COPY and LOAD datasets in the         */
     /*        Endevor development environment .       */
   ALIASE_Generate_Process = 'Y'  ; /* Use an Endevor processor */
     /*  Note: 'Y' requires installation of a processor, */
     /*        Like the GALIAS processor provided.       */
     /*        Addtionally, a type named ALIAS must be   */
     /*        defined in development Environment .    */
   ALIASE_Generate_Process = 'N'  ; /* Just make Aliases */
     /*  Note: 'N' is the typical and simple choice for  */
   /*        this option.                              */

   ALIASE_Subsystem        = ''   ;     /* Use related subsys    */
   ALIASE_Subsystem        = 'CONTROLL' /* Lib and Alias prefix  */
   /*  Note: Applicable only if ALIASE_Generate_Process = 'Y'  */
   /*        If blank, ALIAS elements will be placed   */
   /*           into the same Subsystem they relate to.*/
   /*        If non-blank, Alias elements will be      */
   /*           placed into the named Subsystem.       */
/************************************************************/
/************************************************************/
/************************************************************/
/************************************************************/
/* do not alter following - required for all bundle processing */
IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)
ELSE RETURN 'Not-valid'
EXIT

