/*  REXX  */

/* This Rexx participates in processing of manifestations (sboms)     */
/* for Endevor packages. Each package should include a                */
/* Software Build of Materials (sbom) for the package content.        */
/* This Rxx is called by the Endevor exit program C1UEXT07 .          */

/*                                                                    */
/* If uncommented, the exit Runs only 4 one user    */
/* If USERID() /= 'XALJO99' then Exit  */

/* Here are the Endevor values for where the manifest typ is defined  */
/* Env and Stg are determined from SCL in package.                    */
/* Keep tight security on these, but no approval requirements, as     */
/* they are dynamically built and ADDed into Entry-stages of Endevor. */
   MSYSTEM = 'MANIFEST'
   MSUBSYS = 'SBOM'
   MELTYPE = 'MANIFEST'

   STRING = "ALLOC DD(SYSTSIN) DUMMY      "
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;

   WhatDDName = 'PKGESBOM'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) > ' ' then TraceRc = 1
   If TraceRc = 1 then Trace ?R

   /* Parameters passed from Endevor exit */
   ARG Parms ;
    Package = Substr(PARMS,1,16) ;
    AutoCast= Substr(PARMS,17,01) ;
    Environ = Substr(PARMS,18,08) ;
    Stage   = Substr(PARMS,27,01) ;
    TSOmode = Substr(PARMS,28,01) ;

   my_RC = 0
   Link_RC = 0

   Trace off
   /* You can recode this section to reduce processing time     */
   /* or just let the Rexx do the work for you.                 */
   /* See the notes in the Capture_Endevor_Stages section.      */
   Call Capture_Endevor_Stages

   Call Allocate_Files;
   If TraceRc = 1 then Trace ?R

   Call ExportPackageSCL;

   Call SCAN#SCL;

   Call Does_Package_Already_Have_SBOM;
   /*   my_RC=0 - sbom already in package + autocasting */
   /*   my_RC=1 - Update_SBOM_Source only               */
   /*   my_RC=2 - Update_SBOM_Source + update package   */
   /*   my_RC=8 - Not at an Entry stage. Needs help     */

   If my_RC > 0 & my_RC < 8 then
      Call Update_SBOM_Source;

   If my_RC > 1 & my_RC < 8 then
      Call AppendSBOMSCL;

   Call Free_Files;

   Exit (my_RC)

Allocate_Files:

   If TraceRc = 1 then Say 'Allocate_Files:  '
    If TSOmode = 'T' then,
       Do
       STRING = "ALLOC DD(C1MSGS1) LRECL(133)",
              " BLKSIZE(26600) SPACE(15,15) ",
              " RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
       CALL BPXWDYN STRING;
       End

   STRING = "ALLOC DD(SCL) LRECL(80)",
          " BLKSIZE(24000) SPACE(5,15) ",
          " RECFM(F,B) TRACKS ",
          " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(RESULTS) LRECL(200)",
          " BLKSIZE(24000) SPACE(5,15) ",
          " RECFM(F,B) TRACKS ",
          " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(ENPSCLIN) LRECL(80)",
          " BLKSIZE(16000) SPACE(1,1) ",
          " RECFM(F,B) TRACKS ",
          " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   CALL BPXWDYN "ALLOC DD(APIMSGS) SYSOUT(A) "
   CALL BPXWDYN "ALLOC DD(APILIST) SYSOUT(A) "
   CALL BPXWDYN "ALLOC DD(SYSOUT)  SYSOUT(A) "

   STRING = "ALLOC DD(SBOMSCL)  LRECL(80)",
          " BLKSIZE(8000) SPACE(1,1) ",
          " RECFM(F,B) TRACKS ",
          " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   Return

ExportPackageSCL:

   If TraceRc = 1 then Say 'ExportPackageSCL:'
   QUEUE "EXPORT PACKAGE '"Package"'"
   QUEUE "  TO DDNAME 'SCL' .       "
   "EXECIO" QUEUED() "DISKW ENPSCLIN (FINIS"

   ADDRESS LINK "ENBP1000"
   Link_RC = RC

   If Link_RC > 4 Then my_RC = 8

   If TSOmode = 'T' & Link_RC > 4 THEN,
      Do
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      End; /* If TSOmode = 'T' & Link_RC > 4 */

   Return

Does_Package_Already_Have_SBOM:

   If TraceRc = 1 then Say 'Does_Package_Already_Have_SBOM:'
   If TraceRc = 1 then Trace r
   /* SCL is reformatted into fixed values here */
   "EXECIO * DISKR RESULTS  ( Stem pkg. FINIS"
   /* 1st record is a Heading                   */
   $heading = Substr(pkg.1,14)
   $heading = Strip($heading)
   $heading = Strip($heading,'B',"'");
   $Heading_Variable_count = WORDS($heading) ;
   /* The position for Environment entries here */
   whereEnv = Pos('Envmnt',$heading)
   wordpEnv = WordPos('Envmnt',$heading)
   wordpStg = wordpEnv +  1;
   whereStg = WordIndex($heading,wordpStg);

   whereTyp = Pos('Type',$heading)
   whereEle = Pos('Element',$heading)
   /* Look for the 1st Environment reference    */
   /*  (first detail record is record #2  )     */
   packagedItem = Strip(Translate(Substr(pkg.2,14),' ',"'"));
   firstEnv    = Word(Substr(packagedItem,whereEnv),1)
   firstStg    = Word(Substr(packagedItem,whereStg),1)
   firstType   = Word(Substr(packagedItem,whereTyp),1)
   firstElement = Word(Substr(packagedItem,whereEle),1)

   FromEntryStage = EntryStage.firstEnv.Entry

   /* Examine package SCL for consistency....           */
   /* Set my_RC to reflect what needs to be done:       */
   /*-- Already found within package ------             */
   /*   my_RC=0 - do nothing (promotion package)        */
   /*   my_RC=1 - Update_SBOM_Source only               */
   /*   my_RC=2 - Update_SBOM_Source only / ADD+MOVE    */
   /*-- Not yet found within package -----              */
   /*   my_RC=3 - Update_SBOM_Source + update package   */
   /*   my_RC=4 - Update_SBOM_Source + MOVE + package   */
   /*   my_RC=8 - Not at an Entry stage. Needs help     */
   my_RC = -1 ;
   Do pk# = 2 to pkg.0
      packagedItem = Strip(Translate(Substr(pkg.pk#,14),' ',"'"));
      thisEnv     = Word(Substr(packagedItem,whereEnv),1)
      thisStg     = Word(Substr(packagedItem,whereStg),1)
      thisType    = Word(Substr(packagedItem,whereTyp),1)
      thisElement = Word(Substr(packagedItem,whereEle),1)
      If thisType = 'MANIFEST' & thisElement=Package then,
         Do
         If AutoCast='Y' then my_RC = 0
         Else,
         If FromEntryStage=thisStg then my_RC = 1
         Else                           my_RC = 2
         Leave;
         End;  /* If thisType = 'MANIFEST' & thisElement=Package */
   End; /* Do pk# = 1 to pkg.0 */

   If my_RC = -1 then,
      Do
      If FromEntryStage = thisStg then my_RC = 3
      Else                             my_RC = 4
      End  /* If my_RC = -1 */

   Sa = 'For Package' Package 'my_RC = ' my_RC
   Trace off

   RETURN;

Update_SBOM_Source:

   If TraceRc = 1 then Say 'Update_SBOM_Source:  '
   MY_PARMS = COPIES(' ',720) ;      /*     80 * 9(LINES OF SCL) */
   TEMP1 = " SET OPTIONS UPDATE OVERRIDE SIGNOUT "
   TEMP2 = "        COMMENT 'Automated SBOM' CCID 'MANIFEST'."
   TEMP3 = " ADD ELEMENT '"Package"'"
   TEMP4 = "  TO   ENVIRONMENT "firstEnv " SYSTEM "MSYSTEM
   TEMP5 = "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE
   TEMP6 = "  FROM DDNAME 'RESULTS' ."
   If my_RC = 2 | my_RC = 4 then,
      Do
      TEMP7 = " MOVE  ELEMENT '"Package"'"
      TEMP8 = "  FROM  ENVIRONMENT "firstEnv " SYSTEM "MSYSTEM
      TEMP9 = "    SUBSYSTEM "MSUBSYS " TYPE "MELTYPE,
                 " STAGE NUM 1."
      End /* If my_RC = 2 | my_RC = 4 */
   Else,
      Do
      TEMP7 = "  EOF.  "
      TEMP8 = "  "
      TEMP9 = "  "
      End /*  Else... If my_RC = 2 | my_RC = 4 */

   MY_PARMS = OVERLAY(TEMP1,MY_PARMS,001) ;
   MY_PARMS = OVERLAY(TEMP2,MY_PARMS,081) ;
   MY_PARMS = OVERLAY(TEMP3,MY_PARMS,161) ;
   MY_PARMS = OVERLAY(TEMP4,MY_PARMS,241) ;
   MY_PARMS = OVERLAY(TEMP5,MY_PARMS,321) ;
   MY_PARMS = OVERLAY(TEMP6,MY_PARMS,401) ;
   MY_PARMS = OVERLAY(TEMP7,MY_PARMS,481) ;
   MY_PARMS = OVERLAY(TEMP8,MY_PARMS,561) ;
   MY_PARMS = OVERLAY(TEMP9,MY_PARMS,641) ;
   SA= my_parms ;

   ADDRESS LINKMVS 'APIAESCL MY_PARMS'
   if RC > 0 then Link_RC = RC

   If Link_RC > 4 Then my_RC = 8

   If TSOmode = 'T' & Link_RC > 4 THEN,
      Do
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      End; /* If TSOmode = 'T' & Link_RC > 4 */

   RETURN;

AppendSBOMSCL:

   If TraceRc = 1 then Say 'AppendSBOMSCL:   '
   Queue "* Exit 7 inserted SCL:"
   Queue "MOVE ELEMENT '"Package"'"
   Queue "      FROM ENVIRONMENT" firstEnv "STAGE" firstStg,
                     "SYSTEM" MSYSTEM
   Queue "           SUBSYSTEM " MSUBSYS "TYPE " MELTYPE
   Queue "  OPTIONS COMMENT 'Automated SBOM' CCID 'MANIFEST'."
   "EXECIO" QUEUED() "DISKW SBOMSCL  (FINIS"

   QUEUE " DEFINE PACKAGE '"Package"'"
   QUEUE "        IMPORT SCL FROM DDNAME 'SBOMSCL'"
   QUEUE "        APPEND."
   "EXECIO" QUEUED() "DISKW ENPSCLIN (FINIS"

   ADDRESS LINK "ENBP1000" ;
   if RC > 0 then Link_RC = RC

   If Link_RC > 4 Then my_RC = 8

   If TSOmode = 'T' & Link_RC > 4 THEN,
      Do
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      End; /* If TSOmode = 'T' & Link_RC > 4 */

   Return

FREE_Files:

   If TSOmode = 'T' THEN,
      CALL BPXWDYN "FREE  DD(C1MSGS1)"

   CALL BPXWDYN "FREE DD(SCL)"
   CALL BPXWDYN "FREE DD(RESULTS)"
   CALL BPXWDYN "FREE DD(ENPSCLIN)"
   CALL BPXWDYN "FREE DD(APIMSGS)"
   CALL BPXWDYN "FREE DD(APILIST)"
   CALL BPXWDYN "FREE DD(SYSOUT)"
   CALL BPXWDYN "FREE DD(SBOMSCL)"

   Return

Capture_Endevor_Stages:

  /*                                                               */
  /* To capture the Environment and Stage definitions so that      */
  /*    subsequent processing can know whether a stage is an       */
  /*    entry stage or not.                                        */
  /* You can simplify this section if you want, to allow           */
  /* Endevor to not have to run this section for every package.    */
  /*                                                               */
  /* Endevor to not have to run this section for every package.    */
  /*                                                               */
  /* from the next CSV extract, use only these variables */
  /* ... and build usable Stem array data for mapping    */
  /*                                                               */

   If TraceRc = 1 then Say 'Capture_Endevor_Stages: '

   WantedCSVVariables= ,
    'ENV_NAME STG_NAME STG_ID STG_# ENTRY_STG NEXT_ENV NEXT_STG_# '

   If TSOmode = 'T' then,
      Do
      STRING = "ALLOC DD(C1MSGS1) LRECL(133)",
             " BLKSIZE(26600) SPACE(15,15) ",
             " RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
      CALL BPXWDYN STRING;
      End

   CALL BPXWDYN "ALLOC DD(BSTERR) DUMMY "

   STRING = "ALLOC DD(EXTRACTS) LRECL(1000) BLKSIZE(32000) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(BSTIPT01) LRECL(80)   BLKSIZE(24000) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   QUEUE "LIST STAGE '*' FROM ENVIRONMENT '*' "
   QUEUE "   TO DDNAME 'EXTRACTS'             "
   QUEUE "   OPTIONS   RETURN ALL.            "

   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";

   CSVParm = 'DDN:CONLIB,BC1PCSV0'
   ADDRESS LINKMVS 'CONCALL' "CSVParm"

   Link_RC = RC

   If Link_RC > 4 Then my_RC = 8

   If TSOmode = 'T' & Link_RC > 4 THEN,
      Do
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      End; /* If TSOmode = 'T' & Link_RC > 4 */

  "EXECIO * DISKR EXTRACTS (STEM CSV. finis"

   CALL BPXWDYN "FREE DD(BSTERR)"
   CALL BPXWDYN "FREE DD(C1MSGS1)"
   CALL BPXWDYN "FREE DD(BSTIPT01)"
   CALL BPXWDYN "FREE DD(EXTRACTS)"

  /* To Search the package action data in CSV format.              */
  /* Identify matches with Rules file, determining Ship Dests      */

  /* CSV data heading - showing CSV variables */
  $table_variables= Strip(CSV.1,'T')

  $table_variables = translate($table_variables,"_"," ") ;
  $table_variables = translate($table_variables," ",',"') ;
  $table_variables = translate($table_variables,"@","/") ;
  $table_variables = translate($table_variables,"@",")") ;
  $table_variables = translate($table_variables,"@","(") ;

  Do rec# = 2 to CSV.0
     $detail = CSV.rec#
     /* Parse the Detail record until done */
     Do $column =  1 to Words($table_variables)
        /* For each CSV record, get SCL1 thru SCL10             */
        Call ParseDetailCSVline
     End

     /* Convert CSV data into REXX stems for mapping            */
     StageIDfor.ENV_NAME.STG_# =  STG_ID
     StageNofor.ENV_NAME.STG_ID=  STG_#
     If ENTRY_STG = "Y" then,
        EntryStage.ENV_NAME.Entry  = STG_ID
     If TraceRc = 1 then,
        Do
        Say 'StageIDfor.'ENV_NAME'.'STG_# '=',
             StageIDfor.ENV_NAME.STG_#
        Say 'ENTRY_STG = ',
           ENTRY_STG EntryStage.ENV_NAME.Entry
        End
  End; /* Do rec# = 2 to CSV.0 */

  Drop CSV.

  RETURN ;

ParseDetailCSVline:

  /* Find the data for the current $column */

  $dlmchar = Substr($detail,1,1);

  If $dlmchar = "'" then,
     Do
     SA= 'parsing with single quote '
     PARSE VAR $detail "'" $temp_value "'" $detail ;
     If Substr($detail,1,1) = ',' then,
        $detail = Strip(Substr($detail,2),'L')
     End
  Else,
  If $dlmchar = '"' then,
     Do
     SA= 'parsing with double quote '
     PARSE VAR $detail '"' $temp_value '"' $detail ;
     If Substr($detail,1,1) = ',' then,
        $detail = Strip(Substr($detail,2),'L')
     End
  Else,
  If $dlmchar = ',' then,
     Do
     SA= 'parsing with comma        '
     PARSE VAR $detail ',' $temp_value ',' $detail ;
     If Substr($detail,1,1)/= ',' then,
        $detail = "," || $detail
        $detail = Strip(Substr($detail,2),'L')   */
     End
  Else,
  If Words($detail) = 0 then,
     $temp_value = ' '
  Else,
     Do
     SA= 'parsing with comma        '
     PARSE VAR $detail $temp_value ',' $detail ;
     Sa= '$temp_value=>' $temp_value '<'
     End
  $temp_value = STRIP($temp_value) ;
  $rslt = $temp_value
  $rslt = Translate($rslt,"'",'"') ;
/*$rslt = Strip($rslt,'B','"')  */
/*$rslt = Strip($rslt,'B',"'")  */
  if Length($rslt) < 1 then $rslt = ' '

  thisVariable = WORD($table_variables,$column)
  If Wordpos(thisVariable,WantedCSVVariables) > 0 then,
     Do
     if Length($rslt) < 250 then,
        $temp = WORD($table_variables,$column) '= "'$rslt'"';
     Else,
        $temp = WORD($table_variables,$column) "=$rslt"
     If TraceRc = 1 then,
        Say'ParseDetailCSVline:' $temp
     INTERPRET $temp;
     End ; /*If Wordpos(thisVariable,WantedCSVVariables) > 0 */

  RETURN ;


