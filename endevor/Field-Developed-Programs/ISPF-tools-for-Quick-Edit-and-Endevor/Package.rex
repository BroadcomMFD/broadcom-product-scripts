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
   If isItThere = 0 then Trace ?r
/* Variable settings for each site --->           */
   VCAPRN= '0'
   VCAPYN = 'N'
   ACTION = 'MOVE'    /* Default */
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
  UseCCID     = Strip(EEVCCID);
  ADDRESS ISPEXEC  "VGET (EEVCOMM) PROFILE"
  VARWKCMD =  "" ;
  Element_List = " " ;
  INPPKGE   = ' '
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
  Do forever
     show_ACTION =  ACTION
     Call Build_NOTES_Fields   ;
     Call Display_Panel;
     If ACTION = show_ACTION then Leave;
  End /* Do forever */
  Call Build_Package ;
  VARSPPKG = PACKAGE
  ADDRESS ISPEXEC "VPUT (VARSPPKG) SHARED "
  If CASTPKGE = "Y" then Call CAST_Package;
 Exit
Build_Entries_Endevor:
  HaveSonarQubeElms = 0
  Do row = 1 to rownum
     "TBSKIP "UseTable
     entry = element"/"environ"/"stage"/"system"/"subsys"/"type
     entry = EMKNAME"/"EMKENV"/"EMKSTGI"/" ||,
             EMKSYS"/"EMKSBS"/"EMKTYPE
     If row=1 then,
        Do
        FirstElmEnviron = EMKENV ;
        FirstElmStage   = EMKSTGI;
        Stage       = EMKSTGI  ;
        FirstElmSystem  = EMKSYS ;
        Call Get_Site_Variables
        FirstElmSubsys  = EMKSBS ;
        End; /* If row=1 then */
     Else,
     IF EMKENV   /= FirstElmEnviron |,
        EMKSTGI  /= FirstElmStage   |,
        EMKSYS   /= FirstElmSystem  |,
        EMKSBS   /= FirstElmSubsys  then,
        Do
        Say 'Inventory locations (Env/Stg/Sys/Sbs) must be the same'
        Exit (12)
        End; /* If ..... /= FirstElmEnviron .....  */
     C1ElType = EMKTYPE
     /* Is a listed element type is a SonarQube type for scanning  */
     If Words(SonarQube_Element_Types) > 0 &,
        HaveSonarQubeElms = 0 then,
          Call SonarQubeTypeCheck
     Element_List = Element_List entry
  End; /* do row = 1 to rownum */
  Return ;
Build_Entries_QuickEdit:
  HaveSonarQubeElms = 0
  Do row = 1 to rownum
     "TBSKIP "UseTable
     entry = element"/"environ"/"stage"/"system"/"subsys"/"type
     entry = EEVETKEL"/"EEVETKEN"/"EEVETKSI"/" ||,
             EEVETKSY"/"EEVETKSB"/"EEVETKTY
     If row=1 then,
        Do
        FirstElmEnviron = EEVETKEN
        FirstElmStage   = EEVETKSI
        Stage           = EEVETKSI
        FirstElmSystem  = EEVETKSY
        Call Get_Site_Variables
        FirstElmSubsys  = EEVETKSB
        PKGPRFIX    = EEVETKSY ;
        If FirstElmEnviron = 'ADMIN' then,
           PKGPRFIX    = EEVETKSB ;
        Else,
           PKGPRFIX    = EEVETKSY ;
        UseCCID     = Strip(EEVETCCI)
        End; /* If row=1 then */
     Else,
     IF EEVETKEN /= FirstElmEnviron |,
        EEVETKSI /= FirstElmStage   |,
        EEVETKSY /= FirstElmSystem  |,
        EEVETKSB /= FirstElmSubsys  then,
        Do
        Say 'Inventory locations (Env/Stg/Sys/Sbs) must be the same'
        Exit (12)
        End; /* If ..... /= FirstElmEnviron .....  */
     C1ElType = EEVETKTY
     /* Is a listed element type is a SonarQube type for scanning  */
     If Words(SonarQube_Element_Types) > 0 &,
        HaveSonarQubeElms = 0 then,
          Call SonarQubeTypeCheck
     Element_List = Element_List entry
  End; /* do row = 1 to rownum */
  Return ;
SonarQubeTypeCheck:
  Do w# = 1 to Words(SonarQube_Element_Types)
     HaveSonarQubeElms=,
        QMATCH(C1ElType Word(SonarQube_Element_Types,w#))
  If HaveSonarQubeElms = 1 then leave
  End
  Return ;
Get_Site_Variables:
  Call Get_Next_StgID ;
  /* Get the related site-level options */
  WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
  /* ShipSchedulingMethod can be set by C1System */
  interpret 'Call' WhereIam,
           "'ShipSchedulingMethod_"FirstElmSystem"'"
  ShipSchedulingMethod = Result
  If Wordpos(ShipSchedulingMethod,'Rules Notes One None') = 0 then,
    Do
    interpret 'Call' WhereIam "'ShipSchedulingMethod'"
    ShipSchedulingMethod = Result
    End
  /* identify Choices for SonarQube Scanning */
  /* Cast_Location_for_Sonarqube can be set by C1System */
  interpret 'Call' WhereIam,
           "'Cast_Location_for_Sonarqube_"FirstElmSystem"'"
  Cast_Location_for_Sonarqube = Result
  If Words(Cast_Location_for_Sonarqube) /= 2 then,
    Do
    interpret 'Call' WhereIam "'Cast_Location_for_Sonarqube'"
    Cast_Location_for_Sonarqube = Result
    End
  If Words(Cast_Location_for_Sonarqube)  = 2 then,
    Do
    interpret 'Call' WhereIam,
             "'Wait_for_SonarQube_"FirstElmSystem"'"
    Wait_for_SonarQube            = Result
    If Length(Wait_for_SonarQube) /= 1 then,
      Do
      interpret 'Call' WhereIam "'Wait_for_SonarQube'"
      Wait_for_SonarQube            = Result
      End
    interpret 'Call' WhereIam,
             "'SonarQube_Element_Types_"FirstElmSystem"'"
    SonarQube_Element_Types       = Result
    If SonarQube_Element_Types  = 'Not-valid' then,
      Do
      interpret 'Call' WhereIam "'SonarQube_Element_Types'"
      SonarQube_Element_Types       = Result
      End
    End /* If Words(Cast_Location_for_Sonarqube)  = 2 */
  interpret 'Call' WhereIam "'MyDATALibrary'"
  MyDATALibrary = Result
  NoteRules       = MyDATALibrary"(NOTERULE)"
  NoteRules       = MyDATALibrary"(SHIPRULE)"
  /* Used if ShipSchedulingMethod = 'Notes' */
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
 NextEnv@#StgId= GTNXTSTG(FirstElmEnviron FirstElmStage)
 Mapped_Next_environ = Word(NextEnv@#StgId,1)
 Mapped_Next_stage = Word(NextEnv@#StgId,2)
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
Display_Panel:
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
  COMMENT = Left(UseCCID||':' COMMENT,50)
*/
  PACKAGE = UseCCID || PKGUNIQ
  PKGPRFIX = Left(PKGPRFIX,4,'#')
  PACKAGE = Substr(PKGPRFIX,1,4)|| '#' || PKGUNIQ
  PACKAGE = Left(PACKAGE,16,'#')
  ADDRESS ISPEXEC,
     "DISPLAY  PANEL(PACKAGEP) "
  if rc > 0 then exit
  DESCRIPT = TRANSLATE(DESCRIPT,"'",'"');
  DATE = BTSTDATE ;
  CALL Validate_Date ;
  IF DATE_RC > 0 THEN SIGNAL Display_Panel;
  BATCH_START_DATE = NUMERIC_DATE  ;
  sa= "BATCH_START_DATE =" BATCH_START_DATE ;
  DATE = BTENDATE ;
  CALL Validate_Date ;
  IF DATE_RC > 0 THEN SIGNAL Display_Panel;
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
Validate_Date:
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
          "RECFM(F B) TRACKS DSORG(PS) ",
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
   ADDRESS TSO "ALLOC F(BSTERR) DA(*) REUSE"
   ADDRESS TSO "ALLOC F(BSTAPI) DUMMY REUSE"
   ADDRESS TSO,
      "EXECIO" QUEUED() "DISKW PKGESCL  (FINIS " ;
   ADDRESS TSO,
      "ALLOC F(C1MSGS1)",
          "LRECL(133) BLKSIZE(13300) SPACE(5,5)",
          "RECFM(V B) TRACKS DSORG(PS) ",
          "NEW UNCATALOG REUSE "     ;
   ADDRESS TSO,
      "ALLOC F(ENPSCLIN)",
          "LRECL(80) BLKSIZE(800) SPACE(5,5)",
          "RECFM(F B) TRACKS DSORG(PS) ",
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
   ADDRESS TSO "FREE  F(BSTERR)"
   ADDRESS TSO "FREE  F(BSTAPI)"
   ADDRESS ISPEXEC "SETMSG MSG(CIUU020I)" ;
   return;
Build_NOTES_Fields:
  VPHNOTE1 = " "
  VPHNOTE2 = " "
  VPHNOTE3 = " "
  VPHNOTE4 = " "
  VPHNOTE5 = " "
  VPHNOTE6 = " "
  VPHNOTE7 = " "
  VPHNOTE8 = " "
  entry = WORD(Element_List,1)
  entry = Translate(entry," ","/");
  elmEnviron = Word(entry,2)
  elmStage   = Word(entry,3)
  If ACTION = 'MOVE' then,
     Do
     elmEnviron = Mapped_Next_environ
     elmStage   = Mapped_Next_stage
     End
  elmSystem  = Word(entry,4)
  elmSubsys  = Word(entry,5)
  elmType    = Word(entry,6)
  If ShipSchedulingMethod = 'Notes' then,
     Do
     X = OUTTRAP(LINE.);
     DSNCHECK = SYSDSN("'"NoteRules"'") ;
     IF DSNCHECK /= OK Then Return  ;
     Tday = DATE('U');
     #days = DATE('B',Tday,'U');
      ADDRESS TSO,
        "ALLOC F(TABLE) DA('"NoteRules"') SHR REUSE "
     ADDRESS TSO,
        "EXECIO * DISKR TABLE (STEM $tbl. finis"
      ADDRESS TSO "FREE  F(TABLE)"
     List_Destinations = " " ;
     Time_Destinations = " " ;
     /* Determine where critical columns are located */
     $heading = ' ' Substr($tbl.1,2) ;
     $heading = Translate($heading,' ','-');
     EnvironWrdPos     = Wordpos('Environment',$heading);
     StageWrdPos       = Wordpos('Stage',$heading);
     SystemWrdPos      = Wordpos('System',$heading);
     SubSysWrdPos      = Wordpos('Subsys',$heading);
     DestinationWrdPos = Wordpos('Destination',$heading);
     DateWrdPos        = Wordpos('Date',$heading);
     TimeWrdPos        = Wordpos('Time',$heading);
     JobnameWrdPos     = Wordpos('Jobname',$heading);
     TyprunWrdPos      = Wordpos('Typrun',$heading);
     TypRunPosition    = Wordindex($heading,TyprunWrdPos);
      Do tbl# = 2 to $tbl.0
         env = Word($tbl.tbl#,EnvironWrdPos)
         stg = Word($tbl.tbl#,StageWrdPos)
         sys = Word($tbl.tbl#,SystemWrdPos);
         sub = Word($tbl.tbl#,SubSysWrdPos);
         If (env =elmEnviron | env = '*') &,
            (stg =elmStage | stg = '*')   &,
            (sys = elmSystem | sys = '*') &,
            (sub = elmSubsys | sub = '*') then,
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
      End; /* Do cnt# = 1 to Words(List_Destinations) */
     End; /* If ShipSchedulingMethod = 'Notes' */
  /* Expecting a SonarQube Analysis?  */
  If Words(SonarQube_Element_Types) > 0 &,
     HaveSonarQubeElms = 1 &,
       Cast_Location_for_Sonarqube = elmEnviron elmStage then,
         VPHNOTE1 =,
            Overlay(' Run SonarQube Analysis',VPHNOTE1,38);
  tmp = "Elm Cnt: "COUNT
  VPHNOTE8 = Overlay(tmp,VPHNOTE8,48);
  return;
CAST_Package:
  ADDRESS ISPEXEC "SETMSG MSG(CIUU021I)" ;
  ADDRESS ISPEXEC "DISPLAY PANEL(ENDIE700) "
  if rc > 0 then exit
  SCL_DSN = PkgsDsPrefix || "." || SUBSTR(PKGUNIQ,1,8)
  ADDRESS TSO,
  "ALLOC F(CASTSCL) DA('"SCL_DSN"')",
         "LRECL(80) BLKSIZE(800) SPACE(5,5)",
         "RECFM(F B) TRACKS DSORG(PS) ",
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
Create_PickList_Table:
  /* Allow user to select from original list of elements */
  ADDRESS ISPEXEC "VGET (ZSCREEN) SHARED"
  SA= "CREATE_SummaryLevels_Table SUM"ZSCREEN"LVL"
  ADDRESS ISPEXEC,
    "TBCREATE" PickLstTable,
    'NAMES(EEVETSEL EEVETKEL EEVETDMS EEVETKTY EEVETKEN EEVETKSI ',
          ' EEVETPRC EEVETNRC EEVETUID EEVETCCI ',
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
        EEVETPRC  = EPRC
        EEVETNRC  = EMRC
        EEVETUID  = EMLUID
        EEVETCCI  = ECTL#
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
