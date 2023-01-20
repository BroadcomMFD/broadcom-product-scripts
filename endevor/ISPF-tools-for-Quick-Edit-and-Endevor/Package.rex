 /* REXX   */
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF
   "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE
   FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES
   ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE
   CORRECTED.
*/
  TRACE o  ;
/* Is PACKAGE is allocated? If yes, then turn on Trace  */
   isItThere = ,
     BPXWDYN("INFO FI(PACKAGE) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then Trace r
/*                                                                   */
/* Variable settings for each site --->           */
   VCAPRN= '0'
   VCAPYN = 'N'

   WhereIam =  WHERE@M1()

   interpret 'Call' WhereIam "'SchedulingPackageShipBundle'"
   SchedulingPackageShipBundle = Result

   interpret 'Call' WhereIam "'SchedulingOption'"
   SchedulingOption = Result

   interpret 'Call' WhereIam "'ShipSchedulingMethod'"
   ShipSchedulingMethod = Result

   interpret 'Call' WhereIam "'MyCLS2Library'"
   HSYSEXEC  = Result
   MyCLS2Library = HSYSEXEC

   interpret 'Call' WhereIam "'MyDATALibrary'"
   MyDATALibrary = Result
   ShipRules       = MyDATALibrary"(SHIPRULE)"

   /* Decide on Temporary Dataset name prefix...                         */
   ADDRESS ISPEXEC "VGET (ZSCREEN zUSER zSYSID zPREFIX)"
   if zSYSID = SPECIAL then do              /* is this a special system? */
      /* insert system specific logic if required here                   */
      PkgsDsPrefix = left(zUSER,3)||'.'||zUser'.'|| ,
         STRIP(LEFT('E'||ZSYSID,8))||'.PKGE'||ZSCREEN
      end
   else /* otherwise we use some sensible defautls                       */
     if zPrefix \= '',                      /* is Prefix set?  and NOT.. */
      & zPrefix \= zUSER then do            /* the same as userid?       */
        PkgsDsPrefix = zPrefix ||'.'|| zUser'.' || ,
           STRIP(LEFT('E'||ZSYSID,8)) || '.PKGE'||ZSCREEN
        end
     else do                                /* otherwise use user name   */
        PkgsDsPrefix = zUser ||'.'|| ,
           STRIP(LEFT('E'||ZSYSID,8)) || '.PKGE' || ZSCREEN
     end

/*    No additional changes are required.         */
/*       However, if you wish to modify the       */
/*       structure of package names, find below   */
/*      "Examples for  building the package name" */
/* <---- Variable settings for each site          */
/* Initialize vars for WideScreen Support         */
  LONGPANL = "PKGESELS"                     /* Default to pri scrn */

  ADDRESS ISPEXEC,
     "VGET (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "
  ADDRESS ISPEXEC  "VGET (EEVCCID) PROFILE"
  ADDRESS ISPEXEC  "VGET (EEVCOMM) PROFILE"

  VARWKCMD =  "" ;
  Element_List = " " ;
   System_List = " " ;

  INPPKGE   = ' '
/*
  Call Check_For_Package_Execution ;
  ADDRESS ISPEXEC,
     "VPUT (INPPKGE) SHARED"

  If INPPKGE /= ' ' then, /* Package Processing */
     Do
     Mode = 'package'
     Call Build_Package_Suffix ;
     Call Calculate_Date_Fields ;
     Call Process_Input_Package ;
     Call Build_Package ;
     If CASTPKGE = "Y" then Call CAST_Package;
     Exit
     End                  /* Package Processing */
 */

  Mode = 'element'
/* Variable settings for each site --->           */
/* <---- Variable settings for each site          */
/*                                                                 */
/* Use Table Status to work out which interface we're in...        */
/*                                                                 */
/* for table status...                                             */
/*  1 = table exists in the table input library chain              */
/*  2 = table does not exist in the table input library chain      */
/*  3 = table input library is not allocated.                      */
/*                                                                 */
/*  1 = table is not open in this logical screen                   */
/*  2 = table is open in NOWRITE mode in this logical screen       */
/*  3 = table is open in WRITE mode in this logical screen         */
/*  4 = table is open in SHARED NOWRITE mode in this logical screen*/
/*  5 = table is open in SHARED WRITE mode in this logical screen. */
/*                                                                 */
/* In Quick Edit ?                                */

  UseTable = "EN"ZSCREEN"IE250"
  ADDRESS ISPEXEC
     "TBSTATS" UseTable "STATUS1(STATUS1) STATUS2(STATUS2)"

     IF STATUS2 /= 2 & STATUS2 /= 3 & STATUS2 /= 4 then,
        do
/* no, so try LongName ???                                */
        UseTable = "LN"ZSCREEN"IE250"
        ADDRESS ISPEXEC
        "TBSTATS" UseTable "STATUS1(STATUS1) STATUS2(STATUS2)"
        IF STATUS2 /= 2 & STATUS2 /= 3 & STATUS2 /= 4 then,
           do
/* finally, try In Endevor  ???                                */
           UseTable = "CIELMSL"ZSCREEN
           ADDRESS ISPEXEC
           "TBSTATS" UseTable "STATUS1(STATUS1) STATUS2(STATUS2)"
           IF STATUS2 /= 2 & STATUS2 /= 3 & STATUS2 /= 4 then,
              do
              say "Must invoke Package from an",
                  "Element list "
              exit ;
              end;
           END
        END

  "TBQUERY "UseTable " KEYS(KEYLIST) NAMES(VARLIST) ROWNUM(ROWNUM)"
  IF RC > 0 THEN EXIT

  "TBTOP   "UseTable


  If Substr(UseTable,1,7) = 'CIELMSL' then,
     Call Build_Entries_Endevor
  Else,
     Call Build_Entries_QuickEdit   ;

  COUNT = Words(Element_List) ;
  Call Build_Package_Suffix ;
  Call Calculate_Date_Fields ;
  System_List = Strip(System_List) ;
  If ShipSchedulingMethod = 'Notes' then,
     Call Build_NOTES_Fields   ;
  If ShipSchedulingMethod = 'Rules' then nop
  VPHNOTE8 = SchedulingOption'>' BTSTDATE '00:00' ;
  ACTION = 'MOVE'
  Call SHOW_PANEL;
  Call Build_Package ;
  If CASTPKGE = "Y" then Call CAST_Package;

 exit

Build_Entries_Endevor:

  Do row = 1 to rownum
     "TBSKIP "UseTable
     entry = element"/"environ"/"stage"/"system"/"subsys"/"type
     entry = EMKNAME"/"EMKENV"/"EMKSTGI"/" ||,
             EMKSYS"/"EMKSBS"/"EMKTYPE
     If row=1 then,
        Do
        Environment = EMKENV   ;
        Stage       = EMKSTGI  ;
        If Environment = 'ADMIN' then,
           PKGPRFIX    = EMKSBS   ;
        Else,
           PKGPRFIX    = EMKSYS   ;
        Call Get_Next_StgID ;
        End;
     Element_List = Element_List entry
     if Wordpos(EMKSYS,System_List) = 0 then,
                System_List = System_List EMKSYS ;

  End; /* do row = 1 to rownum */

 Return ;

Build_Entries_QuickEdit:

  Do row = 1 to rownum
     "TBSKIP "UseTable
     entry = element"/"environ"/"stage"/"system"/"subsys"/"type
     entry = EEVETKEL"/"EEVETKEN"/"EEVETKSI"/" ||,
             EEVETKSY"/"EEVETKSB"/"EEVETKTY
     If row=1 then,
        Do
        Environment = EEVETKEN ;
        Stage       = EEVETKSI ;
        PKGPRFIX    = EEVETKSY ;
        If Environment = 'ADMIN' then,
           PKGPRFIX    = EEVETKSB ;
        Else,
           PKGPRFIX    = EEVETKSY ;
        Call Get_Next_StgID ;
        End;
     Element_List = Element_List entry
     if Wordpos(EEVETKSY,System_List) = 0 then,
                System_List = System_List EEVETKSY ;

  End; /* do row = 1 to rownum */

 Return ;

Build_Package_Suffix:

   PKGSTAGE   = Stage          /* Package Prefix */

   NUMBERS    = '123456789' ;
   CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;
   TODAY = DATE(O) ;
   YEAR = SUBSTR(TODAY,1,2) + 1;
   YEAR = SUBSTR(CHARACTERS||CHARACTERS||CHARACTERS||CHARACTERS,YEAR,1)
   MONTH = SUBSTR(TODAY,4,2) ;
   MONTH = SUBSTR(CHARACTERS,MONTH,1) ;
   DAY = SUBSTR(TODAY,7,2) ;
   DAY = SUBSTR(CHARACTERS || NUMBERS,DAY,1) ;
   NOW  = TIME(L);
   HOUR = SUBSTR(NOW,1,2) ;
   IF HOUR = '00' THEN HOUR = '0'
   ELSE
   HOUR = SUBSTR(CHARACTERS,HOUR,1) ;

   MINUTE = SUBSTR(NOW,4,2) ;
   SECOND = SUBSTR(NOW,7,2) ;
   Fractn = SUBSTR(NOW,10,6) ;
   PKGUNIQ = YEAR || MONTH || DAY || HOUR ||,
         MINUTE || SECOND || Fractn ;

   Return ;

Get_Next_StgID:
/*                                                                   */
 NEXT_STG = Stage ;
 RETURN
 SA= "CALLING LOADTABLE"
/* IF USING MULTIPLE DEFAULTS TABLES...                              */
/*    SET THE VALUE OF THE DEFAULTS TABLE NAME:                      */
/*
 C1DEFLTS = 'C1DEFLTS'
 ADDRESS LINKMVS 'LOADTBLE' C1DEFLTS  ;
*/
/* IF NOT USING MULTIPLE DEFAULTS TABLES...                          */
 ADDRESS LINKMVS 'LOADTABL' 'C1DEFLTS' ;
 C1DEFLTS_ADDR = C2X(TBLADDR) ;
 POINTER_ADDR = D2X(    X2D(C1DEFLTS_ADDR) + X2D(055)      )
 NUMBER_OF_ENVIRONMENTS = C2D(STORAGE(POINTER_ADDR,01));
 POINTER_ADDR = D2X(    X2D(C1DEFLTS_ADDR) + X2D(22E)      )
 SITE_SYMBOLICS_TABLE_NAME = STORAGE(POINTER_ADDR,08) ;
/*                                                                   */
 POINTER_ADDR = D2X(    X2D(C1DEFLTS_ADDR) + X2D(400)      )
/*                                                                   */
 DO CNT = 1 TO NUMBER_OF_ENVIRONMENTS
    ENV_NAME_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(074)      )
    NEXT_ENV_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(07C)      )
    NEXT_STG_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(073)      )
    C1STAGE1_ADDR = POINTER_ADDR
    C1STAGE2_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(08A)      )
    C1STGID1_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(0BE)      )
    C1STGID2_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(0D3)      )
    STAGE_1_ENTRY_ADDR = D2X( X2D(POINTER_ADDR)+ X2D(0F0))
    STAGE_2_ENTRY_ADDR = D2X( X2D(POINTER_ADDR)+ X2D(0F1))
    ENV_NAME   = STORAGE(ENV_NAME_ADDR,08) ;
    NEXT_ENV   = STORAGE(NEXT_ENV_ADDR,08) ;
    NEXT_STG   = STORAGE(NEXT_STG_ADDR,01) ;
    C1STAGE1   = STORAGE(POINTER_ADDR,08) ;
    C1STAGE2   = STORAGE(C1STAGE2_ADDR,08) ;
    C1STGID1   = STORAGE(C1STGID1_ADDR,01) ;
    C1STGID2   = STORAGE(C1STGID2_ADDR,01) ;
    STAGE_1_ENTRY_INDICATOR = STORAGE(STAGE_1_ENTRY_ADDR,01) ;
    STAGE_2_ENTRY_INDICATOR = STORAGE(STAGE_2_ENTRY_ADDR,01) ;

    IF ENV_NAME = Environment then,
       DO
       If Stage = C1STGID1 then NEXT_STG = C1STGID2 ;
       /* Otherwise user the value already in NEXT_STG  */
       Leave ;
       End;  /* IF NEXT_ENV /= " "  */

    POINTER_ADDR = D2X(    X2D(POINTER_ADDR) + X2D(100)      )
 END  /* DO CNT = 1 TO NUMBER_OF_ENVIRONMENTS */

 Return ;

Calculate_Date_Fields:

  GENERATE = "Y" ;


  TEMP     = DATE('N')
  DAY      = WORD(TEMP,1)
  IF LENGTH(DAY) < 2 THEN DAY = "0"DAY ;
  MON      = WORD(TEMP,2)
  YEAR     = SUBSTR(WORD(TEMP,3),3,2) ;
  IF LENGTH(YEAR) < 2 THEN YEAR = "0"YEAR ;
  BTSTDATE = DAY || MON || YEAR;
  ONSTDATE = DAY || MON || YEAR;

  TEMP     = TIME('N')
  BTSTTIME = SUBSTR(TEMP,1,5)
  BTSTTIME = "00:00"

  BTENDATE = "31DEC79"
  BTENTIME = "00:00"

  Return ;

SHOW_PANEL:

  /* These are valid if we are in Quick Edit */
  CCID = EEVCCID
  COMMENT = EEVCOMM

  If Substr(UseTable,1,7) = 'CIELMSL' then,
     Do
     CCID = ECTL#
     COMMENT = EMCCOM
     End
/*
  Examples for  building the package name......
  PACKAGE = PKGSTAGE||"#"     ||Substr(PKGPRFIX,1,4)||PKGUNIQ ;
  PACKAGE = STAGE   ||"#" || PKGUNIQ ;
  PACKAGE = PKGSTAGE ||"#" || PKGUNIQ ;
*/
  PACKAGE = Substr(PKGPRFIX,1,4)|| '#' || PKGUNIQ
  PACKAGE = Left(PACKAGE,16,'#')

  ADDRESS ISPEXEC,
     "DISPLAY  PANEL(PACKAGEP) "
  if rc > 0 then exit
  DESCRIPT = TRANSLATE(DESCRIPT,"'",'"');

  DATE = BTSTDATE ;
  CALL VALIDATE_DATE ;
  IF DATE_RC > 0 THEN SIGNAL SHOW_PANEL;
  BATCH_START_DATE = NUMERIC_DATE  ;
  sa= "BATCH_START_DATE =" BATCH_START_DATE ;

  DATE = BTENDATE ;
  CALL VALIDATE_DATE ;
  IF DATE_RC > 0 THEN SIGNAL SHOW_PANEL;

  /*
  If Words(SchedulingOption) > 3 then,
     Do
     place = Pos('>',VPHNOTE8) + 1
     DATE = Strip(Substr(VPHNOTE8,place)) ;
     CALL VALIDATE_DATE ;
     IF DATE_RC > 0 THEN,
        Do
        ADDRESS ISPEXEC "SETMSG MSG(CIUU027E)" ;
        SIGNAL SHOW_PANEL;
        End;
     End;
  */

  ADDRESS ISPEXEC,
     "VPUT (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "

  IF Mode /= 'element' |,
     PICKLIST /= 'Y' THEN RETURN ;

  PickLstTable = "EN"ZSCREEN"PKLST"; /*  Use Pick List table  */
  "ISPEXEC CONTROL DISPLAY SAVE"
  Call Create_PickList_Table ;
  "ISPEXEC CONTROL DISPLAY RESTORE"
  If Selection = 0 then exit ;

  Return

VALIDATE_DATE:

  DATE_RC = 0 ;

  /*  BTENDATE = "31DEC79"  */
  DAY  = SUBSTR(DATE,1,2) ;
  MON  = SUBSTR(DATE,3,3) ;
  YEAR = SUBSTR(DATE,6,2) ;
  LIST_OF_MONTHS = "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" ;
  NUMERIC_MON = WORDPOS(MON,LIST_OF_MONTHS) ;
  IF LENGTH(NUMERIC_MON) < 2 THEN NUMERIC_MON = "0"NUMERIC_MON ;

  NUMERIC_DATE = YEAR || NUMERIC_MON || DAY ;

  IF DAY < "01" | DAY > "31" THEN DATE_RC = 8 ;
  IF NUMERIC_MON = 0 THEN DATE_RC = 8 ;
  IF YEAR < "01" | YEAR > "99" THEN DATE_RC = 8 ;

  IF DATE_RC > 0 THEN,
     ADDRESS ISPEXEC "SETMSG MSG(CIUU026E)" ;

  return;

Build_Package:

   ADDRESS TSO,
   "ALLOC F(PKGESCL)",
          "LRECL(80) BLKSIZE(800) SPACE(5,5)",
          "RECFM(F B) TRACKS ",
          "NEW UNCATALOG REUSE "     ;

   Queue "SET OPTIONS CCID '"CCID"'"
   Queue "    COMMENT '"COMMENT"' "
   ADDRESS ISPEXEC  "VGET (EEVOOSGN) SHARED "
   IF EEVOOSGN = "Y" THEN,
      Queue "      OVERRIDE SIGNOUT."
   ELSE,
      Queue "      . "

   Do cnt = 1 to Words(Element_List) ;
      entry = WORD(Element_List,cnt) ;
      entry = Translate(entry," ","/");
      Queue ACTION "ELEMENT"
      Queue  "'"WORD(entry,1)"'"
      Queue "       FROM ENVIRONMENT" WORD(entry,2)
      Queue "            SYSTEM" WORD(entry,4) "SUBSYSTEM" WORD(entry,5)
      Queue "            TYPE" WORD(entry,6) "STAGE" WORD(entry,3) "."
   End;

   ADDRESS TSO,
      "EXECIO" QUEUED() "DISKW PKGESCL  (FINIS " ;

   ADDRESS TSO,
      "ALLOC F(C1MSGS1)",
          "LRECL(133) BLKSIZE(13300) SPACE(5,5)",
          "RECFM(V B) TRACKS ",
          "NEW UNCATALOG REUSE "     ;

   ADDRESS TSO,
      "ALLOC F(ENPSCLIN)",
          "LRECL(80) BLKSIZE(800) SPACE(5,5)",
          "RECFM(F B) TRACKS ",
          "NEW UNCATALOG REUSE "     ;

   QUEUE " DEFINE PACKAGE '"PACKAGE"'"
   QUEUE "        IMPORT SCL FROM DDNAME 'PKGESCL'"
   If APPEND   = "Y" then,
      QUEUE "        APPEND "
   QUEUE "  DESCRIPTION '"DESCRIPT"'"
   QUEUE "        OPTIONS STANDARD SHARABLE BACKOUT ENABLED "
   QUEUE "          EXECUTION WINDOW FROM " BTSTDATE BTSTTIME
   QUEUE "                           TO   " BTENDATE BTENTIME
   If PROMOTE = "Y" & ACTION = 'MOVE' then,
      QUEUE "                PROMOTION PACKAGE "
   QUEUE " NOTES=('"VPHNOTE1"',"
   QUEUE "        '"VPHNOTE2"',"
   QUEUE "        '"VPHNOTE3"',"
   QUEUE "        '"VPHNOTE4"',"
   QUEUE "        '"VPHNOTE5"',"
   QUEUE "        '"VPHNOTE6"',"
   QUEUE "        '"VPHNOTE7"',"
   QUEUE "        '"VPHNOTE8"') . "
   ADDRESS TSO,
      "EXECIO" QUEUED() "DISKW ENPSCLIN (FINIS " ;

   ADDRESS LINK "ENBP1000" ;
   IF RC > 4 THEN,
      Do
      Say "Could not build the package "PACKAGE
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(C1MSGS1)"
      ADDRESS ISPEXEC "VIEW DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      EXIT(8)
      End

   ADDRESS TSO "FREE  F(C1MSGS1)"
   ADDRESS TSO "FREE  F(PKGESCL)"
   ADDRESS TSO "FREE  F(ENPSCLIN)"

   ADDRESS ISPEXEC "SETMSG MSG(CIUU020I)" ;

   return;

CAST_Package:

  ADDRESS ISPEXEC "SETMSG MSG(CIUU021I)" ;
  ADDRESS ISPEXEC "DISPLAY PANEL(ENDIE700) "
  if rc > 0 then exit

  SCL_DSN = PkgsDsPrefix || "." || SUBSTR(PKGUNIQ,1,8)

  ADDRESS TSO,
  "ALLOC F(CASTSCL) DA('"SCL_DSN"')",
         "LRECL(80) BLKSIZE(800) SPACE(5,5)",
         "RECFM(F B) TRACKS ",
         "NEW CATALOG REUSE "     ;

  If VALIDATE /= "Y" then,
     Do
     QUEUE " CAST PACKAGE '"PACKAGE"'  "
     QUEUE "    OPTION DO NOT VALIDATE COMPONENT ."
     End
  Else,
     QUEUE " CAST PACKAGE '"PACKAGE"' ."
  /*
  */
  pkg = Overlay('*',PACKAGE,Length(PACKAGE))
  If EXECUTE   = "Y" then,
     Do
     QUEUE " EXECUTE PACKAGE '"pkg"'  "
     QUEUE "    OPTIONS WHERE PACKAGE STATUS IS APPROVED    . "
     End
  ADDRESS TSO,
     "EXECIO" QUEUED() "DISKW CASTSCL (FINIS " ;
  ADDRESS TSO "FREE  F(CASTSCL)"

  ADDRESS ISPEXEC  "VGET (VCAPRN) ASIS   "
  If VCAPRN > '1' then VCAPYN = 'Y'

  PDVINCJC = "Y"        /* for ENSP1000 */
  PDVSCLDS = SCL_DSN ;  /* for ENSP1000 */
  PDVDD01  = "//DELETEME DD DSN="SCL_DSN",DISP=(OLD,DELETE)"

  ADDRESS ISPEXEC "FTOPEN TEMP"

  ADDRESS ISPEXEC "FTINCL ENSP1000"

  ADDRESS ISPEXEC "FTCLOSE "

  ADDRESS ISPEXEC "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;
   DEBUG = 'YES' ;
   DEBUG = 'NAW' ;
   X = OUTTRAP("OFF")
   IF DEBUG = 'YES' THEN,
      DO
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(&ZTEMPN)"
      ADDRESS ISPEXEC "EDIT DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      END;
   ELSE,
      DO
      ADDRESS TSO "SUBMIT '"ZTEMPF"'" ;
      END;

   return;

Build_NOTES_Fields:

  If SchedulingPackageShipBundle /= 'Y' then return;
  X = OUTTRAP(LINE.);
  DSNCHECK = SYSDSN("'"ShipRules"'") ;
  IF DSNCHECK /= OK Then Return  ;

  Tday = DATE('U');
  #days = DATE('B',Tday,'U');
   ADDRESS TSO,
     "ALLOC F(TABLE) DA('"ShipRules"') SHR REUSE "

  ADDRESS TSO,
     "EXECIO * DISKR TABLE (STEM $tbl. finis"
   ADDRESS TSO,
     "FREE  F(TABLE)"
  List_Destinations = " " ;
  Time_Destinations = " " ;

  /* Determine where critical columns are located */
  $heading = ' ' Substr($tbl.1,2) ;
  $heading = Translate($heading,' ','-');
  EnvironmentWrdPos = Wordpos('Environment',$heading);
  StageWrdPos       = Wordpos('Stage',$heading);
  SystemWrdPos      = Wordpos('System',$heading);
  DestinationWrdPos = Wordpos('Destination',$heading);
  DateWrdPos        = Wordpos('Date',$heading);
  TimeWrdPos        = Wordpos('Time',$heading);
  JobnameWrdPos     = Wordpos('Jobname',$heading);
  TyprunWrdPos      = Wordpos('Typrun',$heading);
  TypRunPosition    = Wordindex($heading,TyprunWrdPos);

  Do cnt# = 1 to Words(System_List)
     srch = Word(System_list,cnt#) ;
     Do tbl# = 2 to $tbl.0
        env = Word($tbl.tbl#,EnvironmentWrdPos)
        stg = Word($tbl.tbl#,StageWrdPos)
        sys = Word($tbl.tbl#,SystemWrdPos);
        If (env =ProductionEnvironment | env = '*') &,
           (stg =ProductionStage | stg = '*') &,
           (sys = srch | sys = '*') then,
           Do
           Destination = Word($tbl.tbl#,DestinationWrdPos)
           If Wordpos(Destination,List_Destinations) > 0 then,
              iterate ;
           tmp         = Word($tbl.tbl#,DateWrdPos)
           tmp = Strip(tmp,'L','+') ;
           Tday = DATE('U');
           #days = DATE('B',Tday,'U');
           #days = #days + tmp ;
           Date = DATE('S',#days,'B') ;
           Time_Str    = Word($tbl.tbl#,TimeWrdPos)
           Jobname     = Word($tbl.tbl#,JobnameWrdPos)
           Hold_Str    = Strip(Substr($tbl.tbl#,TypRunPosition,8))
           Time_Entry = Date"\"Time_Str"\"Hold_Str ;
           entry = Strip(Destination)'/'Strip(Jobname)
           List_Destinations = entry List_Destinations;
           Time_Destinations = Time_Entry Time_Destinations ;
           End;
     End;  /* Do tbl# = 2 to $tbl.0  */
  End ; /* Do cnt# = 1 to Words(System_List)  */
  VPHNOTE8 = " "
  Do cnt# = 1 to Words(List_Destinations)
     Time_Entry = Word(Time_Destinations,cnt#) ;
     Time_Entry = Translate(Time_Entry," ","\") ;
     Date     = Word(Time_Entry,1) ;
     Time_Str = Word(Time_Entry,2) ;
     Hold_Str = Word(Time_Entry,3) ;
     entry       = Word(List_Destinations,cnt#)
     entry       = Translate(entry,' ','/')
     Destination = Word(entry,1)
     Jobname     = Word(entry,2)
     nbr = 9 - cnt# ;
     If Hold_Str /= "HOLD" then Hold_Str = " "
     tmp = "VPHNOTE"nbr" = 'To "Left(Destination,8)":",
        Date  Time_Str LEFT(Jobname,8) Hold_Str "'"
     interpret tmp ;
  End;

  tmp = "Elm Cnt: "COUNT
  VPHNOTE8 = Overlay(tmp,VPHNOTE8,48);

  return;

Create_PickList_Table:

  /* Allow user to select from original list of elements */
  ADDRESS ISPEXEC "VGET (ZSCREEN) SHARED"
  SA= "CREATE_SummaryLevels_Table SUM"ZSCREEN"LVL"
  ADDRESS ISPEXEC,
    "TBCREATE" PickLstTable,
    'NAMES(EEVETSEL EEVETKEL EEVETDMS EEVETKTY EEVETKEN EEVETKSI ',
          ' EEVETKSY EEVETKSB EEVETDVL) WRITE ' ;

  ADDRESS ISPEXEC "TBTOP   "UseTable   ;

  Do row = 1 to ROWNUM
     ADDRESS ISPEXEC "TBSKIP "UseTable
     If Substr(UseTable,1,7) = 'CIELMSL' then,
        Do
        /* We are using an Endevor table - not a QE table */
        EEVETKEL  = EMKNAME
        EEVETKTY  = EMKTYPE
        EEVETKEN  = EMKENV
        EEVETKSI  = EMKSTGI
        EEVETKSY  = EMKSYS
        EEVETKSB  = EMKSBS
        EEVETDVL  = ECVL
        End;

     IF TOSUBSYS = EEVETKSB THEN ITERATE ;
     EEVETSEL = ' '
     EEVETDMS = ' '
     ADDRESS ISPEXEC "TBADD" PickLstTable "ORDER ";
  End; /* do row = 1 to rownum */

  ADDRESS ISPEXEC "TBSORT" PickLstTable,
          "FIELDS(EEVETKEL,C,A) ";
  SA= 'COMPLETED TBSORT  ' ;
  ADDRESS ISPEXEC "TBTOP" PickLstTable       ;

  ADDRESS ISPEXEC "SETMSG MSG(CIUU025I)" ;
  Selection = 0 ;

  VARC1LR = PASSTHRU /* enable Left/Right commands */
  DO FOREVER         /* Till user presses END or CANCEL */
     ADDRESS ISPEXEC "TBDISPL" PickLstTable "PANEL("LONGPANL")"
     TBDRC = RC
     IF TBDRC >= 8 THEN,   /* user want's out */
        DO
        address ispexec "vget (zverb)" /* Cancel, End or Return? */
        if ZVERB == 'CANCEL' then Selection = 0 /* clear selection */
        VARC1LR = ''       /* Allow standard Left/Right  */
        If Selection = 0 then
           Do
           ADDRESS ISPEXEC "TBEND" PickLstTable ;
           Return
           End
        Leave
        end;
     THISTOPR = ZTDTOP      /* save the top row so we can restore it */
     DO WHILE ZTDSELS > 0   /* process any modified rows */
        SA= 'ZTDSELS=' ZTDSELS 'ZTDTOP=' ZTDTOP
        sa= "PROCESSING ELEMENT " EEVETKEL C1ELTYPE
        IF Strip(EEVETSEL) = "S" then,
           Do
           EEVETSEL = ' '
           If EEVETDMS /= '*SELECTED*' then Selection = Selection + 1 ;
           EEVETDMS = '*SELECTED*'
           ADDRESS ISPEXEC "TBPUT" PickLstTable  ;
           End;
        IF Strip(EEVETSEL) = "U" then,
           Do
           EEVETSEL = ' '
           If EEVETDMS /= '          ' then Selection = Selection - 1 ;
           EEVETDMS = '          '
           ADDRESS ISPEXEC "TBPUT" PickLstTable  ;
           End;
        IF ZTDSELS = 1 then leave /* we got em all get out now */
        ADDRESS ISPEXEC "TBDISPL" PickLstTable ; /* get next */
        sa= 'ZTDSELS=' ZTDSELS 'RC=' rc
     end
     /* now process any primary commands */
     THISCMD = VARWKCMD;                /* get any command */
     VARWKCMD = "";                     /* reset the command */
     parse upper var THISCMD THISCMDW THISCMDP

     select
       when THISCMDW == ''              then NOP;
       when THISCMDW == 'LEFT'          then call Toggle_Screen;
       when THISCMDW == 'RIGHT'         then call Toggle_Screen;
     otherwise
       do
          VARWKCMD = THISCMD /* restore command so it can be corrected */
          ADDRESS ISPEXEC "SETMSG MSG(LONG013E)" ; /* Cmd Not Recognized */
       end
  End /* Do Forever */

  /* re-position table */
  ADDRESS ISPEXEC "TBTOP   "PickLstTable ;
  ADDRESS ISPEXEC "TBSKIP  "PickLstTable" NUMBER("THISTOPR")"
  END;               /* DO until user presses End or cancel    */
  VARC1LR = ''       /* Allow standard Left/Right  */

  If Selection = 0 then,
     Do
     ADDRESS ISPEXEC "TBEND" PickLstTable ;
     Return ;
     End

  ADDRESS ISPEXEC "TBTOP" PickLstTable ;

  Element_List = " " ;
  COUNT = 0
  Do row = 1 to ROWNUM
     ADDRESS ISPEXEC "TBSKIP" PickLstTable ;
     If EEVETDMS /= '*SELECTED*' then iterate ;
     entry = EEVETKEL"/"EEVETKEN"/"EEVETKSI"/" ||,
             EEVETKSY"/"EEVETKSB"/"EEVETKTY
     Element_List = Element_List entry;

     COUNT = COUNT + 1;
     Sa= 'Adding 'EEVETKEL COUNT
  End; /* do row = 1 to rownum */

  ADDRESS ISPEXEC "TBEND" PickLstTable ;
  if Count = 0 then
     Selection = 0 /* nothing to do */
  else
     UseTable = PickLstTable ; /*  Use Pick List table now */
  Return ;

Toggle_Screen:

   IF LONGPANL == PKGESELS THEN LONGPANL = "PKGESEL2"
   ELSE LONGPANL = "PKGESELS"

   Return;

Check_For_Package_Execution:

   ADDRESS ISPEXEC,
      "VGET (ZSCREEN ZSCREENC ZSCREENI) SHARED"

   position = zscreenc;
   Do forever
      If position < 2 then exit(8)
      If substr(zscreeni,(position-1),1) < '$' then leave;
      position = position - 1;
   End ;

   pkg       = Strip(substr(zscreeni,position,16)) ;
   SA= "Package =" pkg
   if Length(pkg) < 16 then Return ;
   INPPKGE   = pkg

   Return

Process_Input_Package:
  SAY "GETTING CURRENT LOCATIONS FROM ENDEVOR" ;
  ADDRESS TSO "ALLOC FI(C1MSGS1)  DUMMY SHR REUSE"
  ADDRESS TSO;

  "ALLOC FI(C1MSGS1) DUMMY SHR REUSE"
  "ALLOC FI(C1MSGS2) DUMMY SHR REUSE"
/*'ALLOC F(BSTERR)   DUMMY SHR REUSE '   */
/*'ALLOC F(BSTAPI)   DUMMY SHR REUSE '   */

  'ALLOC F(APILIST) LRECL(2048) BLKSIZE(22800) SPACE(5,5) ',
    'RECFM(V B) TRACKS NEW UNCATALOG REUSE ' ;

  'ALLOC F(APIMSGS) LRECL(133) BLKSIZE(13300) SPACE(5,5) ',
    'RECFM(F B) TRACKS NEW UNCATALOG REUSE ' ;

  ADDRESS LINKMVS 'APIALPKG' INPPKGE ;  /*  Get pkg header */
  ADDRESS TSO "EXECIO * DISKR APILIST (STEM pkghdr. finis"
  InpPackageStatus = Substr(pkghdr.1,116,12) ;
  InpPackageDescription = Substr(pkghdr.1,30,50) ;

  'ALLOC F(APILIST) LRECL(2048) BLKSIZE(22800) SPACE(5,5) ',
    'RECFM(V B) TRACKS NEW UNCATALOG REUSE ' ;
  ADDRESS LINKMVS 'APIALSUM' INPPKGE ;  /*  Get pkg Actions*/

  ADDRESS TSO "EXECIO * DISKR APILIST (STEM pkglst. finis"
  IF pkglst.0 = 0 then,
     Do
     Say 'Package' INPPKGE ' is not-found or not-CAST '
     Exit (8)
     End;

  ADDRESS ISPEXEC "VGET (ZSCREEN) SHARED"
  PickLstTable = "EN"ZSCREEN"PKLST"; /*  Use Pick List table  */

  ADDRESS ISPEXEC,
    "TBCREATE" PickLstTable,
    'NAMES(EEVETSEL EEVETKEL EEVETDMS EEVETKTY EEVETKEN EEVETKSI ',
          ' EEVETKSY EEVETKSB EEVETDVL) WRITE ' ;
  plc = 191 ;  /* Assume Source fields */
  If STRIP(InpPackageStatus) = 'EXECUTED'  then  plc = 304 ;
  If STRIP(InpPackageStatus) = 'COMMITTED' then  plc = 304 ;
  If Substr(InpPackageDescription,47,4) = 'XFER' then plc = 191;
  If Substr(pkglst.ROWNUM,304,1) < '$' then plc = 191;
  Do ROWNUM = 1 to pkglst.0
     EEVETKEL = Substr(pkglst.ROWNUM,415,8) ;
     EEVETKEN = Substr(pkglst.ROWNUM,plc,8) ;
     EEVETKSY = Substr(pkglst.ROWNUM,(plc+8),8) ;
     EEVETKSB = Substr(pkglst.ROWNUM,(plc+16),8) ;
     EEVETKTY = Substr(pkglst.ROWNUM,(plc+26),8) ;
     EEVETKSI = Substr(pkglst.ROWNUM,(plc+43),1) ;
     EEVETSEL = ' '
     EEVETDMS = ' '
     If ROWNUM = 1 then,
        Do
        Environment = EEVETKEN ;
        Stage       = EEVETKSI ;
        PKGPRFIX    = EEVETKSY ;
        If Environment = 'ADMIN' then,
           PKGPRFIX    = EEVETKSB ;
        Else,
           PKGPRFIX    = EEVETKSY ;
        Call Get_Next_StgID ;
        End;
     ADDRESS ISPEXEC "TBADD" PickLstTable "ORDER ";
  End; /*  Do ROWNUM = 1 to pkglst.0 */
  COUNT = pkglst.0

  ADDRESS ISPEXEC "TBSORT" PickLstTable,
          "FIELDS(EEVETKEL,C,A) ";
  SA= 'COMPLETED TBSORT  ' ;
  ADDRESS ISPEXEC "TBTOP" PickLstTable       ;

  Call SHOW_PANEL ;

  If PICKLIST = 'Y' THEN,
     Do
     VARC1LR = PASSTHRU /* enable Left/Right commands */
     ADDRESS ISPEXEC "SETMSG MSG(CIUU025I)" ;
     ADDRESS ISPEXEC "TBDISPL" PickLstTable "PANEL("LONGPANL")";
     IF RC > 4 THEN,
        DO
        VARC1LR = ''       /* Allow standard Left/Right  */
        ADDRESS ISPEXEC "TBEND" PickLstTable ;
        EXIT
        end;
     TBDISPL_RC = RC ;
     DO FOREVER
        ADDRESS ISPEXEC "SETMSG MSG(CIUU025I)" ;
        SA= 'ZTDSELS=' ZTDSELS
        sa= "PROCESSING ELEMENT " EEVETKEL C1ELTYPE
        IF Strip(EEVETSEL) = "S" then,
           Do
           EEVETSEL = ' '
           EEVETDMS = '*SELECTED*'
           ADDRESS ISPEXEC "TBPUT" PickLstTable  ;
           End;
        IF Strip(EEVETSEL) = "U" then,
           Do
           EEVETSEL = ' '
           EEVETDMS = ' '
           ADDRESS ISPEXEC "TBPUT" PickLstTable  ;
           End;
        If ZTDSELS > 0 then do
           ADDRESS ISPEXEC "TBDISPL" PickLstTable ;
           if RC > 4 then leave;
        end
        If ZTDSELS < 1 then leave ;
     END; /* DO FOREVER           */
  END; /* If PICKLIST = 'Y'    */
  VARC1LR = ''       /* Allow standard Left/Right  */

  ADDRESS ISPEXEC "TBTOP" PickLstTable ;

  Element_List = " " ;
  COUNT = 0
  Do row = 1 to ROWNUM
     ADDRESS ISPEXEC "TBSKIP" PickLstTable ;
     If PICKLIST =  'Y' &,
        EEVETDMS /= '*SELECTED*' then iterate ;
     entry = EEVETKEL"/"EEVETKEN"/"EEVETKSI"/" ||,
             EEVETKSY"/"EEVETKSB"/"EEVETKTY
     Element_List = Element_List entry;

     COUNT = COUNT + 1;
  End; /* do row = 1 to rownum */

  ADDRESS ISPEXEC "TBEND" PickLstTable ;
  UseTable = PickLstTable ; /*  Use Pick List table now */

  Return ;

