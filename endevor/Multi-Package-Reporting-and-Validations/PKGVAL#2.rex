/*            REXX                  */
/*  ----------------------------------------------------------      */
/*  Read package content and ACM content and determine              */
/*  whether any input components were not packaged.                 */
/*  ----------------------------------------------------------      */
/*                                                                  */
  /* If PKGVAL#2 is allocated to anything, turn on Trace  */
  WhatDDName = 'PKGVAL#2'
  CALL BPXWDYN "INFO FI("WhatDDName")",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If Substr(DSNVAR,1,1) /= ' ' then Trace_Opt = 'Y'
  my_rc = 0
  Arg thisEnv .
  /* Get Package Id info                */
  "EXECIO * DISKR PKGIDS (Stem pkg. Finis"
  /* Get Endevor Stage# to StageID data */
  "EXECIO * DISKR STAGEIDS (Stem stg. Finis"
  Call BuildEndevorMapping;
  "EXECIO * DISKR SCL (Stem scl. Finis"
  Call ConvertSCL2StemArray;
  /* Loop through the ACMQ data */
  "EXECIO * DISKR ACMQ (Stem acm. Finis"
  Call ScanACMandCompare;
  If my_rc = 0 then,
    Queue ' *** All input components are found packaged *** '
  Queue '  '
  Queue '   *** Return Code=' my_rc
  "EXECIO" QUEUED() "DISKW RESULTS (Finis"
  Exit(my_rc)
ConvertSCL2StemArray:
  SCLdet. = ''
  p# = 0
  Do s# = 1 to scl.0
     SCLdetail = Substr(scl.s#,14)
     SCLdetail = StriP(SCLdetail)
     SCLdetail = StriP(SCLdetail,'B',"'")
     Command   = Word(SCLdetail,01)
     Envmnt    = Word(SCLdetail,02)
     Stg       = Word(SCLdetail,03)
     System    = Word(SCLdetail,04)
     Subsys    = Word(SCLdetail,05)
     Type      = Word(SCLdetail,06)
     Element   = Word(SCLdetail,07)
/* MG modified this */
/*   entry = Element'_'Envmnt'_'Stg'_'Type'_'System'_'Subsys */
     entry = Element'_'Type'_'Envmnt'_'System'_'Subsys'_'Stg
     SCLdet.entry = Command
     If Command == 'Command' Then p# = p# + 2
     SCLdet.entry.pkgid = Substr(pkg.p#,19)
     If Trace_Opt = 'Y' then,
        Say 'SCLdet.'entry '=' Command
  End; /*  Do s# = 1 to scl.0 */
  Return
ScanACMandCompare:
  If Trace_Opt = 'Y' then Trace r
  /* Look for items in ACM data that are missing from Package SCL */
  Do a# = 1 to acm.0
     ACMDetail = acm.a#
     LVL       = Word(Substr(ACMDetail,6),1)
/* MG STG relocation, modification, and addition */
     ENVIRON   = Word(Substr(ACMDetail,36),1)
     STG#      = Word(Substr(ACMDetail,70),1)
     STG       = StageID.Environ.STG#
     If LVL =  '1' then,
        Do
/* MG modified this */
        entry1 = ELEMENT'_'TYPE'_'ENVIRON'_'SYSTEM'_'SUBSYS'_'STG
        Dependency = Strip(Substr(ACMDetail,12,58)||STG)
/*      Dependency = Strip(Substr(ACMDetail,12,70)) */
        End
     If LVL <  '2' then Iterate;
     ELEMENT   = Word(Substr(ACMDetail,12),1)
     If Pos('=',ELEMENT) > 0 then Iterate;
     TYPE      = Word(Substr(ACMDetail,25),1)
     If ENVIRON /= thisEnv then Iterate;
     SYSTEM    = Word(Substr(ACMDetail,47),1)
     SUBSYS    = Word(Substr(ACMDetail,58),1)
/* MG modified this */
/*   entry = ELEMENT'_'ENVIRON'_'STG'_'TYPE'_'SYSTEM'_'SUBSYS */
     entry = ELEMENT'_'TYPE'_'ENVIRON'_'SYSTEM'_'SUBSYS'_'STG
     If entry = Last_entry then iterate;
     Last_entry = entry
     Command = SCLdet.entry
    If Command = '' then,
       Do
* MG modified the text */
*      Queue entry '**Not packaged** input by:' */
       If Last_pkgid <> SCLdet.entry1.pkgid Then,
        Queue 'For package ID '||SCLdet.entry1.pkgid||':'
       Queue entry 'is non-packaged input used by:'
       Queue '  ' Dependency
       my_rc = 12
       Last_pkgid = SCLdet.entry1.pkgid
       End
  End;  /* Do a# = 1 to acm.0 */
  Return

BuildEndevorMapping:

  Mapping.  = ''
  NextMap.  = ''
  Locations = ''
  loc# = 0;
  Location. = ''

  Do st# = 1 to stg.0   /* Processing STAGEIDS data */
     interpret stg.st#
  End;  /* Do st# = 1 to stg.0 */

  /* Build a list of map Locations*/
  Do Forever;
     loc# = loc# + 1;
     mapLocation = Location.loc#
     If mapLocation = '' then leave;
     If Words(mapLocation) /= 2 then leave;
     thisEnv = Word(mapLocation,1)
     thisStg#= Word(mapLocation,2)
     entry     = thisEnv'.'thisStg#
     nextLoc   = NextMap.thisEnv.thisStg#
     If Substr(nextLoc,1,1) = ' ' then nextLoc = ''
     Locations = Locations entry
     Mapping.entry = entry nextLoc
  End; /* Do Forever */
  Sa= 'Locations=' Locations

  /* Build mapping                */
  Do Forever;
    makingChanges = 'N'
    Do loc1# = 1 to Words(Locations)
       thisentry  = Word(Locations,loc1#)
       thisMap    = Mapping.thisentry
       numwords   = Words(thismap)
       If numwords < 2 then iterate
       where = Wordindex(thismap,2)
       moreMap    = Substr(thismap,where)
       Do loc2# = 1 to Words(Locations)
          If loc2#   = loc1# then iterate;
          tmpentry   = Word(Locations,loc2#)
          tmpMap     = Mapping.tmpentry
          numwords   = Words(tmpMap)
          lastword   = Word(tmpMap,numwords)
          If lastword = thisentry then,
             Do
             Mapping.tmpentry = Mapping.tmpentry moreMap
             makingChanges = 'Y'
             End; /* If lastword = thisentry */
       End; /* Do loc2# = 1 to Words(Locations) */
    End; /* Do loc1# = 1 to Words(Locations) */
    If makingChanges = 'N' then leave;
  End; /*  Do Forever */;

  If Trace_Opt  = 'N' then Return

  Do loc1# = 1 to Words(Locations)
     thisentry  = Word(Locations,loc1#)
     thisMap    = Mapping.thisentry
     Say thisentry 'Mapping:' thisMap
  End; /* Do loc1# = 1 to Words(Locations) */

  Return;

