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
   AltIDAcctCode = '55800000'
   AltIDJobClass = 'B'
   AltIDMsgClass = 'X'

/* Bundle Switch Area  */
   PackageBundle = 'N'
   ParallelDevelopmentBundle = 'N'
   QuickEditBundle = 'N'

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

  /* If you want to schedule production moves                   */
  /* or package shipping, use the SchedulingOption              */
   SchedulingOption  = ' '      ;  /* no scheduling of any kind */
  /*    The 'Move to' option causes the execution window to be  */
  /*              automatically updated for named Env and stage */
   SchedulingOption  = 'MOVE TO   SMPLPROD P'
  /*    The 'SHIP FROM' option causes automated shipments for   */
  /*              packages that delivered to the  Env and stage */
   SchedulingOption  = 'SHIP FROM SMPLPROD P'

/************************************************************/
/* Required for the Parallel Development Support bundle :   */
   /* For XFER processing (Parallel Bundle)      :   */
   /* Select one line and comment out or delete the other: */
   XFER_AutoExecute = 'Y' ;  /* Auto Execute XFER packages     */
   XFER_AutoExecute = 'N' ;  /* Manual or Other Package Execution */
     /*Note: Other Package Execution requires the              */
     /*      Package Bundle Implementation                     */
     /*  This option should be 'N' if Package Bundle is installed */

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
   /*  Note: Applicable only if ALIASE_Generate_Process = 'Y'  */
   /*        If blank, ALIAS elements will be placed   */
   /*           into the same Subsystem they relate to.*/
   /*        If non-blank, Alias elements will be      */
   /*           placed into the named Subsystem.       */
/************************************************************/
/* Required for the Quick-Edit bundle :   */
   AlertRexxProgram = 'PDA'  ; /* Use PDA or PDNF3 or BC1PPDNR */
   /* Verify the name of the Endevor Element Catalog file */
   ElementCatalogName = 'CAPRD.END40.SMPL.ELMCATL'
   /* Enter one or more mapping representations  (not Prod)    */
   /*       where PDA should search for inventory.             */
   PDAMaplist = ,        /* required only for PDA  */
      " SMPLTEST/T-SMPLTEST/Q ",
      " SMPLPROD/E-SMPLPROD/E "
   /* Enter a value for the temporary element name used by     */
   /* RETRO actions:                                           */
   /*  '1'   Use the original element name and '##' suffix.    */
   /*        You must support 10-char element names with this  */
   /*        option                                            */
   /* 'user' Use the userid of the person executing the RETRO  */
   /*        extended to 8 characters with the use of '#'      */
   /*        extended to 8 characters with the use of '#'      */
   /*'<name>'Use the designated name - one that is not used for*/
   /*        any real elements in the Endevor inventory.       */
   /* Select one and enter value...                            */
   RetroTempName ='1'      ;  /*original element name and '##' */
   RetroTempName ='QQQQQQQQ'  /*replace 'QQQQQQQ' with name    */
   RetroTempName ='user'   ;  /*userid and '##'                */

/************************************************************/
/* Required for the SnapMon (Endevor Activity feature:      */
/************************************************************/
   SNAPMOND = "Y,,0,*,*,IS ACTIVE IN SCREEN*,"  || ,
          "Y,XSYS,0,*,CTLIELEM,*,"              || ,
              "Y,,0,*,LSERVDSN,*,"              || ,
              "Y,,0,*,FDPDSN,"MyCLS2Library","  || ,
              "Y,,0,*,SYSDSN,"AHLQ"*,"          || ,
              "Y,,0,*,SYSDSN,"SHLQ".CSIQPLD*,"  || ,
              "N,,0,*,SYSDSN,SYS7.ENDEVOR.*,"
   /*
     The SanpMon defaults are set as a single value
     that is in effect a comma delimited table.
     Each row contains:
       * Yes/No Flag to indicate if this line is active
       * XSYS value or blank to indicate if XSYS is searched
       * Limit (or zero for none) to limit the Enqueues returned
       * Resource fliter (or * for all)
       * Queue Name (or * for all)
       * Resource Name (or * for all)

     The default entries include ENQueue searches for the
     Endevor ISPF sessions, Element enqueus (CTLIELEM),
     L-Serv enqueus (used by Endevor to searlialise L-Serv access)
     and a few sample SYSDSN entries which are filtered to find
     the ACMROOT, Elelmet Catalog and Package files. A special
     entry with Queue Name FDPDSN will be counted to hilite
     users with the FDP clist dataset allocated.

     Note: Because comma is used as the delimiter, each row should
           contain exactly six(6) commas. i.e. no commas in the "data"
           The current limit is nine(9) rows.
   */
/***************************************************************/
/* REQUIRED FOR ENDEVOR HILITE SYSVIEW SUPPORT                 */
/* SPECIFY THE HIGH LEVEL QUALIFIER FOR SYSVIEW (.CMN4BLOD)    */
/* MySysviewPref = 'CAIPROD.SYSVW.R150S2' */
   MySysviewPref = 'CAIPROD.SYSVW.R1600.CAR2001'
/***************************************************************/
 /* do not alter following - required for all bundle processing */
/************************************************************/
 /* do not alter following - required for all bundle processing */
   IF   SYMBOL(Parm)='VAR' THEN RETURN VALUE(Parm)
   ELSE RETURN 'Not-valid:'||Parm
   EXIT
