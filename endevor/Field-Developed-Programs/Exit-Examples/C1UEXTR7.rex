/*   rexx    */
   /* Values to be set for your site......                     */
   CastPackageModel = 'WALJO11.BOFA.CASE(CASTPKGE)'
   CastPackageJCL   = USERID()".C1UEXTR7.SUBMIT"

   /* If wanting to limit the use of this exit, uncomment...   */
   If USERID() /= 'WALJO11' then exit

   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(SYSTSIN) DUMMY"
   CALL BPXWDYN STRING;

   MyRc = 0

   /* If C1UEXTR7 is allocated to anything, turn on Trace  */
   WhatDDName = 'C1UEXTR7'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) /= ' ' then Trace ?r

   Arg Parms
   sa= 'Parms len=' Length(Parms)
   SA= 'BOFA VERSION'

   /* Parms from C1UEXT07 is a string of REXX statements   */
   Interpret Parms

   Message = ''
   MessageCode = '    '

   If Substr(PHDR_PKG_NOTE5,1,5) = 'TRACE' then TraceRc = 1


   Sa= 'You called SYSDE32.NDVR.TEAM.REXX(C1UEXTR7) '

   Sa= "PECB_PACKAGE_ID=" PECB_PACKAGE_ID
   Sa= "PECB_MODE = " PECB_MODE

   If PECB_MODE = "T" then,       /* TSO foreground  */
      Do
      Call SubmitBatchCAST
      Exit
      End


   /* Enforce packages to be Backout Enabled              */
   IF PREQ_BACKOUT_ENABLED /= 'Y' then,
      Do
      Message = 'Package made to be Backout enabled'
      MyRc        = 4
      hexAddress = D2X(Address_PREQ_BACKOUT_ENABLED)
      storrep = STORAGE(hexAddress,,'Y')
      Call SetExitReturnInfo
      End;

   sa= EEVCCID EEVCOMM
   /* from the next CSV extract, use only these variables */
   /* ... and build usable Stem array data for mapping    */
   WantedCSVVariables= ,
    'ENV_NAME STG_NAME STG_ID STG_# ENTRY_STG NEXT_ENV NEXT_STG_# '
   Call CSV_to_List_Endevor_Stages

   /* from the next CSV extract, use only these variables */
   /* Build a list of stage.system.type.element entries   */
   /* representing source and target impacted locations   */
   ImpactedEntries = ""
   WantedCSVVariables= ,
    '#_STMTS SCL1 SCL2 SCL3 SCL4 SCL5 SCL6 SCL7 SCL8 SCL9 SCL10'
   Call CSV_to_List_Package_SCL
   If TraceRc = 1 then,
      Do imp# = 1 to Words(impactedEntries)
      Say 'ImpactedEntry=' Word(impactedEntries,imp#)
      End;

   /* from the next CSV extract, use only these variables */
   WantedCSVVariables= ,
      'ENV_NAME SYS_NAME SBS_NAME ELM_NAME           ',
      'FULL_ELM_NAME TYPE_NAME STG_NAME STG_ID STG_# ',
      'STG_SEQ_# PROC_GRP_NAME                       ',
      'PKG_EXEC_DATE_@S@ PKG_EXEC_TIME_@S@           ',
      'BACKED_OUT_@O@ PKG_ID_@O@ PKG_EXEC_DATE_@O@   ',
      'ENV_NAME_@F@ SYS_NAME_@F@ SBS_NAME_@F@ ELM_@F@ ',
      'TYPE_NAME_@F@ STG_#_@F@ PKG_ID_@S@ PKG_ID_@S@  ',
      'PKG_ID_@S@ PKG_ID_@O@ PKG_ID LOCKED_DATE LOCKED_TIME '

   Call CSV_to_List_Packaged_Elements

   STRING = "FREE  DD(BSTIPT01) "
   CALL BPXWDYN STRING;

   If MyRC > 4 then,
      Do
      Message = 'Package overlaps other packages '
      Call SetExitReturnInfo
      End

   Exit

SubmitBatchCAST:

   "ALLOC F(CASTPKGE) DA('"CastPackageModel"') SHR REUSE"
   "Execio * DISKR CASTPKGE (Stem jcl. Finis"
   "FREE  F(CASTPKGE)"
   jcl.1 = Overlay(USERID(),jcl.1,3)
   "ALLOC F(SUBMTJCL) DA('"CastPackageJCL"') ",
          "LRECL(80) BLKSIZE(16800) SPACE(5,5)",
          "RECFM(F B) TRACKS ",
         "MOD CATALOG REUSE "     ;
   "Execio * DISKW SUBMTJCL (Stem jcl. "

   /* Push Cast command (in reverse order).  */
   If PREQ_PKG_CAST_COMPVAL = 'Y' then,
      PUSH  '    OPTION VALIDATE COMPONENTS .'
   Else,
   If PREQ_PKG_CAST_COMPVAL = 'W' then,
      PUSH  '    OPTION VALIDATE COMPONENT WITH WARNING .'
   Else,
      PUSH  '    OPTION DO NOT VALIDATE COMPONENT .'
   PUSH  "  CAST PACKAGE '" || PECB_PACKAGE_ID || "'"
   "Execio 2 DISKW SUBMTJCL ( finis"

   Call Submit_n_save_jobInfo ;
   "FREE  F(SUBMTJCL) DELETE "
   Message = JobData
   MyRc        = 8
   PACKAGE = PECB_PACKAGE_ID
   MessageCode = 'U033'
   Call SetExitReturnInfo

   Return;

Submit_n_save_jobInfo: /* submit CastPackageModel job and save job info */

   If TraceRc = 1 then Say 'Submit_n_save_jobInfo:'

   Address TSO "PROFILE NOINTERCOM"     /* turn off msg notific      */
   CALL MSG "ON"
   CALL OUTTRAP "out."
   ADDRESS TSO "SUBMIT '"CastPackageJCL"'" ;
   If RC > 4 then,
      Do
      MyRC = 8
      Message = 'Cannot find Element member to submit.'
      Call SetExitReturnInfo
      Exit(12)
      End
   CALL OUTTRAP "OFF"
   JobData   = Strip(out.1);
   jobinfo         = Word(JobData,2) ;
   If jobinfo = 'JOB' then,
      jobinfo   = Word(JobData,3) ;
   SelectJobName   = Word(Translate(jobinfo,' ',')('),1) ;
   SelectJobNumber = Word(Translate(jobinfo,' ',')('),2) ;

   Return;

SetExitReturnInfo:

   If TraceRc = 1 then Say 'SetExitReturnInfo:    '

   hexAddress = D2X(Address_PECB_MESSAGE)
   storrep = STORAGE(hexAddress,,Message)
   hexAddress = D2X(Address_PECB_ERROR_MESS_LENGTH)
   storrep = STORAGE(hexAddress,,'0084'X)
   hexAddress = D2X(ADDRESS_PECB_MODS_MADE_TO_PREQ)
   storrep = STORAGE(hexAddress,,'Y')

   If MessageCode /= '    ' then,
      Do
      hexAddress = D2X(Address_PECB_MESSAGE_ID)
      storrep = STORAGE(hexAddress,,MessageCode)
      End


/* Set the return code for the exit                */
/*  for PECB-NDVR-EXIT-RC                          */
   hexAddress = D2X(Address_PECB_NDVR_EXIT_RC)
   If MyRc = 4 then,
      storrep = STORAGE(hexAddress,,'00000004'X)
   Else,
      storrep = STORAGE(hexAddress,,'00000008'X)

   RETURN ;

CSV_to_List_Endevor_Stages:

   If TraceRc = 1 then Say 'CSV_to_List_Endevor_Stages: '

  /* To Search the package shipping table, we need the Entry       */
  /*    Environment information as a search criteria.              */
  /*    Get it from the USER-DATA field on the 1st element.        */

   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) DUMMY "
   CALL BPXWDYN STRING;

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

   call_rc = rc ;

  "EXECIO * DISKR EXTRACTS (STEM CSV. finis"

   STRING = "FREE DD(EXTRACTM)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTERR)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTAPI)" ;
   CALL BPXWDYN STRING;

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
     Environ.ENV_NAME.MapNext.STG_ID = NEXT_ENV NEXT_STG_#
     Environ.ENV_NAME.Stgid.STG_# =  STG_ID
     If ENTRY_STG = "Y" then,
        Environ.ENV_NAME.Entry  = STG_# STG_ID
     If TraceRc = 1 then,
        Say Environ'.'ENV_NAME'.'Entry'=' Environ.ENV_NAME.Entry
  End; /* Do rec# = 2 to CSV.0 */

  Drop CSV.

  RETURN ;

CSV_to_List_Package_SCL:

   If TraceRc = 1 then Say 'CSV_to_List_Package_SCL:    '

  /* To Search the package shipping table, we need the Entry       */
  /*    Environment information as a search criteria.              */
  /*    Get it from the USER-DATA field on the 1st element.        */

   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTAPI) DUMMY "
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(EXTRACTM) LRECL(2000) BLKSIZE(32000) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(BSTIPT01) .... already allocated "

   QUEUE "LIST PACKAGE SCL FROM PACKAGE '"PECB_PACKAGE_ID"'"
   QUEUE "     TO DDNAME 'EXTRACTM' "
   QUEUE "     ."

   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";

   CSVParm = 'DDN:CONLIB,BC1PCSV0'
   ADDRESS LINKMVS 'CONCALL' "CSVParm"

   call_rc = rc ;

  "EXECIO * DISKR EXTRACTM (STEM CSV. finis"

   STRING = "FREE DD(EXTRACTM)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTERR)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTAPI)" ;
   CALL BPXWDYN STRING;

  /* To Search the package action data in CSV format.              */
  /* Identify matches with Rules file, determining Ship Dests      */

  IF CSV.0 < 2 THEN RETURN;

  /* CSV data heading - showing CSV variables */
  $table_variables= Strip(CSV.1,'T')

  $table_variables = translate($table_variables,"_"," ") ;
  $table_variables = translate($table_variables," ",',"') ;
  $table_variables = translate($table_variables,"@","/") ;
  $table_variables = translate($table_variables,"@",")") ;
  $table_variables = translate($table_variables,"@","(") ;

  /* From the groups of 10-line SCL segments, accumulate  */
  /* a single string into SCL_String.                     */
  SCL_String = ''
  Csv_Options = ''
  Do rec# = 2 to CSV.0
     $detail = CSV.rec#
     /* Parse the Detail record until done */
     Do $column =  1 to Words($table_variables)
        /* For each CSV record, get SCL1 thru SCL10             */
        Call ParseDetailCSVline
     End
     Call BuildSCLString ;
  End; /* Do rec# = 2 to CSV.0 */

  /* From collected SCL, Build element-level CSV commands */

  sa= 'SCL_String =' SCL_String
  Call Parse_SCL_String ;

  Drop CSV.

  RETURN ;

BuildSCLString :

  If TraceRc = 1 then Say 'BuildSCLString :            '

  Do scl# = 1 to 10
     SCLline   = Strip(value(SCL||scl#))
     If TraceRc = 1 then,
        Say 'SCLline=' SCLline
     lineLen   = Length(SCLline)
     If Substr(SCLline,1,1) = '*' then Iterate;
     If lineLen             = 0   then Iterate;
     Do forever
        quoteChar = "'"
        whereQuote = Pos(quoteChar,SCLline)
        If whereQuote = 0 then,
           Do
           quoteChar = '"'
           whereQuote = Pos(quoteChar,SCLline)
           End; /* If whereQuote = 0 */
        If whereQuote = 0 then Leave;
        whereNextQuote = Pos(quoteChar,SCLline,(whereQuote+1))
        If whereNextQuote = 0 then,
           Do
           SCLline = Overlay(' ',SCLLine,whereQuote)
           Leave;
           End; /* If whereNextQuote = 0 */
        thisLen  =  whereNextQuote - whereQuote + 1
        thisText =  Substr(SCLline,whereQuote,thisLen)
        thisText =  Translate(thisText,'_',' ')
        thisText =  Overlay(' ',thisText,1)
        thisText =  Overlay(' ',thisText,thisLen)
        SCLline  =  Overlay(thisText,SCLLine,whereQuote)
     End; /* Do forever */
     SCL_String = SCL_String Strip(SCLline)
  End

  Return;

Parse_SCL_String :

  If TraceRc = 1 then Say 'Parse_SCL_String :' SCL_String

  SCL_Action =  ''
  SCL_Element=  ''

  Do Forever
     Word1 = Word(SCL_String,1)
     If Length(Word1) > 1 & Substr(Word1,Length(Word1)) = '.' then,
        Do
        Word1 = Strip(Word1,'T','.')
        SCL_String = Word1 '. ',
            Substr(SCL_String,Wordindex(SCL_String,2))
        End

     If Words(SCL_String) > 1 then Word2 = Word(SCL_String,2)
     Else                          Word2 = ' '
     If Words(SCL_String) > 2 then Word3 = Word(SCL_String,3)
     Else                          Word3 = ' '

     If Word2 = 'ELEMENT' then,
        Do
        SCL_Action = Word1
        SCL_Element= Word3
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,4))
        End
     Else,
     If Word1 = 'ENVIRONMENT' |,
        Word2 = 'ENV' then,
        Do
        SCL_Environ = Word2
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,3))
        End
     Else,
     If Word1 = 'SYSTEM' |,
        Word2 = 'SYS' then,
        Do
        SCL_System = Word2
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,3))
        End
     Else,
     If Word1 = 'SUBSYSTEM' | ,
        Word2 = 'SYS' then,
        Do
        SCL_Subsys = Word2
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,3))
        End
     Else,
     If Word1 = 'TYPE' then,
        Do
        SCL_Type   = Word2
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,3))
        End
     Else,
     If Word1 = 'STAGE' |,
        Word2 = 'STG' then,
        Do
        SCL_Stg    = Word2
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,3))
        End
     Else,
     If Word1 = '.' then,
        Do
        If SCL_Element /= '' then,
            Call Write_CSVRequest
        If Words(SCL_String) > 1 then,
           SCL_String = Substr(SCL_String,WordIndex(SCL_String,2))
        Else Leave;
        SCL_Action =  ''
        SCL_Element=  ''
        End
     Else,
        SCL_String = Substr(SCL_String,WordIndex(SCL_String,2))

     Sa= 'SCL_String=' Substr(SCL_String,1,60)
     If Words(SCL_String) < 1 then Leave;
  End; /* Do Forever */

  Return;

Write_CSVRequest:       /* Also builds ImpactedEntries */

  If TraceRc = 1 then Say 'Write_CSVRequest:   '
  If TraceRc = 1 then,
     Do
     Say "LIST ELEMENT" SCL_Element
     Say "       FROM ENVIRONMENT" SCL_Environ  "STAGE" SCL_Stg
     Say "            SYSTEM" SCL_System "SUBSYSTEM" SCL_Subsys
     Say "            TYPE" SCL_Type
     Say "       TO FILE 'PACKAGED' "
     Say "       OPTIONS SEARCH RETURN ALL" Csv_Options "."
     End

  /* Prepare Element-lvl CSV calls for packaged elements */
  Queue "LIST ELEMENT" SCL_Element
  Queue "     FROM ENVIRONMENT" SCL_Environ  "STAGE" SCL_Stg
  Queue "          SYSTEM" SCL_System "SUBSYSTEM" SCL_Subsys
  Queue "          TYPE" SCL_Type
  Queue "     TO FILE 'PACKAGED' "
  Queue "     OPTIONS SEARCH RETURN ALL" Csv_Options "."

  entry= SCL_Environ'_'SCL_Stg'_'SCL_System'_'SCL_Type'_'SCL_Element
  ImpactedEntries = ImpactedEntries entry
  next_info  =  Environ.SCL_Environ.MapNext.SCL_Stg
  NEXT_ENV   =  Word(next_info,1)
  NEXT_STG_# =  Word(next_info,2)
  NEXT_STG_ID=  Environ.NEXT_ENV.NEXT_STG_#
  entry= NEXT_ENV'_'NEXT_STG_ID'_'SCL_System'_'SCL_Type'_'SCL_Element
  ImpactedEntries = ImpactedEntries entry

  Csv_Options = 'NOTITLE'
  Return;

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

CSV_to_List_Packaged_Elements:

   If TraceRc = 1 then Say "CSV_to_List_Packaged_Elements:"
  /* To Search the package shipping table, we need the Entry       */
  /*    Environment information as a search criteria.              */
  /*    Get it from the USER-DATA field on the 1st element.        */

   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   STRING = "ALLOC DD(C1MSGS1) LRECL(133) BLKSIZE(13300) ",
              " DSORG(PS) ",
              " SPACE(1,1) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) DUMMY "
   STRING = "ALLOC DD(BSTERR) DA(*) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTAPI) DUMMY "
   STRING = "ALLOC DD(BSTAPI) DA(*) "
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(PACKAGED) LRECL(4000) BLKSIZE(32000) ",
              " DSORG(PS) ",
              " SPACE(1,5) RECFM(F,B) TRACKS ",
              " MOD UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(BSTIPT01) .... already allocated "

   /* List Element actions were built queued in the  */
   /* CSV_to_List_Package_Actions section.           */
   "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";

   CSVParm = 'DDN:CONLIB,BC1PCSV0'
   ADDRESS LINKMVS 'CONCALL' "CSVParm"

   call_rc = rc ;
   If call_rc > 4 then,
      Do
      Say 'CSV_to_List_Packaged_Elements CSV call failed' call_rc
      exit(12)
      End

   Drop CSV.
   "EXECIO * DISKR PACKAGED (STEM CSV. finis"
   If TraceRc = 1 then Say "call_rc=" call_rc "recs=" CSV.0
   Trace off

   STRING = "FREE DD(PACKAGED)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTERR)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTAPI)" ;
   CALL BPXWDYN STRING;

  /* To Search the package action data in CSV format.              */
  /* Identify matches with Rules file, determining Ship Dests      */

  IF CSV.0 < 2 THEN RETURN;

  /* CSV data heading - showing CSV variables */
  $table_variables= Strip(CSV.1,'T')

  $table_variables = translate($table_variables,"_"," ") ;
  $table_variables = translate($table_variables," ",',"') ;
  $table_variables = translate($table_variables,"@","/") ;
  $table_variables = translate($table_variables,"@",")") ;
  $table_variables = translate($table_variables,"@","(") ;
  If TraceRc = 1 then Say "$table_variables=" $table_variables

  If TraceRc = 1 then Trace r
  rec# =1
  Do rec# = 2 to CSV.0
     $detail = CSV.rec#
     /* Parse the Detail record until done */
     Do $column =  1 to Words($table_variables)
        Call ParseDetailCSVline
     End ; /*Do $column =  1 to Words($table_variables) */

     entry = ENV_NAME'_'STG_ID'_'SYS_NAME'_'TYPE_NAME'_'ELM_NAME
     If WordPos(entry,ImpactedEntries) > 0 &,
        LOCKED_DATE > " " then,
        Do
        Showentry = Translate(entry,'/','_')
        If QUEUED() = 0 then,
           Do
           STRING = "ALLOC DD(ERRORS) SYSOUT(A) "
           CALL BPXWDYN STRING;
           End /* If QUEUED() = 0 */
        If PECB_MODE = 'B' then,
           Do
           queue ' ******************************************'
           queue '  Entry' Showentry 'in the Casting Package ',
                    '>' PECB_PACKAGE_ID '<'
           queue '   > is already locked by package',
                 '   >' PKG_ID LOCKED_DATE LOCKED_TIME
           queue ' ******************************************'
           End  /* If PECB_MODE = 'B' */
        Else,
           Do
           Say ' ******************************************'
           Say '  Entry' Showentry 'in the Casting Package ',
                    '>' PECB_PACKAGE_ID '<'
           Say '   > is already locked by package',
                 '   >' PKG_ID LOCKED_DATE LOCKED_TIME
           Say ' ******************************************'
           End  /* Else               */
        MyRc = 8
        End /* If WordPos(entry,ImpactedEntries) > 0 ...   */

     next_info  =  Environ.ENV_NAME.MapNext.STG_ID
     NEXT_ENV   =  Word(next_info,1)
     NEXT_STG_# =  Word(next_info,2)
     NEXT_STG_ID=  Environ.NEXT_ENV.Stgid.NEXT_STG_#
     entry= NEXT_ENV'_'NEXT_STG_ID'_'SYS_NAME'_'TYPE_NAME'_'ELM_NAME

  End; /* Do rec# = 2 to CSV.0 */

  Drop CSV.
  If QUEUED() > 0 then "EXECIO" QUEUED() "DISKW ERRORS (Finis "

  RETURN ;

