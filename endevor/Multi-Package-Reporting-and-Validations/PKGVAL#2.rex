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
  PkgDependencies. = ''

  Arg thisEnv thisStg# CircleRc thisPath
  If Trace_Opt == 'Y' Then Say 'thisEnv='||thisEnv
  If Trace_Opt == 'Y' Then Say 'thisStg#='||thisStg#
  If Trace_Opt == 'Y' Then Say 'thisPath='||thisPath

  /* Get package ID info                */
  "EXECIO * DISKR PKGIDS (Stem pkg. Finis"
  /* Get Endevor Stage# to StageID data */
  "EXECIO * DISKR STAGEIDS (Stem stg. Finis"
  Call BuildEndevorMapping;

  Call PriorACMQStages;

  "EXECIO * DISKR SCL (Stem scl. Finis"
  Call ConvertSCL2StemArray;

  /* Loop through the ACMQ data */
  "EXECIO * DISKR ACMQ (Stem acm. Finis"
  Call ScanACMandCompare;

  Call ShowChronologicalOrder;

  If my_rc == 0 then,
    Queue ' *** All input components are found packaged *** '
  Queue '  '
  Queue '   *** Return Code=' my_rc

  "EXECIO" QUEUED() "DISKW RESULTS (Finis"

  /* Want to write the PKGORDER report ?                    */
  /* If PKGORDER is allocated to anything, write the report */
  WhatDDName = 'PKGORDER'
  CALL BPXWDYN "INFO FI("WhatDDName")",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If RESULT = 0 then,
     Do
     Queue '*** Potential Chronological order of packages: ***'
     Call ShowPKGORDER_Report
     "EXECIO" QUEUED() "DISKW PKGORDER (Finis"
     End


  Exit(my_rc)

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
     If mapLocation == '' then leave;
     If Words(mapLocation) /= 2 then leave;
     thisEnv2 = Word(mapLocation,1)
     thisStg2#= Word(mapLocation,2)
     entry     = thisEnv2'.'thisStg2#
     nextLoc   = NextMap.thisEnv2.thisStg2#
     If Substr(nextLoc,1,1) == ' ' then nextLoc = ''
     Locations = Locations entry
     Mapping.entry = entry nextLoc
  End; /* Do Forever */
  Sa= 'Locations=' Location

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
          If loc2# == loc1# then iterate;
          tmpentry   = Word(Locations,loc2#)
          tmpMap     = Mapping.tmpentry
          numwords   = Words(tmpMap)
          lastword   = Word(tmpMap,numwords)
          If lastword == thisentry then,
             Do
             Mapping.tmpentry = Mapping.tmpentry moreMap
             makingChanges = 'Y'
             End; /* If lastword = thisentry */
       End; /* Do loc2# = 1 to Words(Locations) */
    End; /* Do loc1# = 1 to Words(Locations) */
    If makingChanges == 'N' then leave;
  End; /*  Do Forever */;

  If Trace_Opt == 'N' then Return

  Do loc1# = 1 to Words(Locations)
     thisentry  = Word(Locations,loc1#)
     thisMap    = Mapping.thisentry
     If Trace_Opt == 'Y' Then Say thisentry 'Mapping:' thisMap
  End; /* Do loc1# = 1 to Words(Locations) */

  Return;

PriorACMQStages:

  thisStg = StageID.thisEnv.thisStg#
  curStage = thisEnv||'.'||thisStg#
  thisMap = ''
  priorstgs = ''
  y = Words(ThisPath)
  if y == 0 Then Do
   Say 'Error: INITPATH is missing but required'
   Exit(13)
  End
  Do p# = 1 to y
    Path = Word(thisPath,p#)
    thisMap = Mapping.Path
    x = WordPos(Path,thisMap)
    If x == 0 Then Do
     Say 'thisMap='||thisMap||' Path='||Path
     Say 'Error: thisPath not found within thisMap'
     Exit(13)
    End
    y = WordPos(curStage,thisMap)
    If y == 0 Then Do
     If Trace_Opt == 'Y' Then,
       Say 'curStage='||curStage||' not found within '||thisMap
     Iterate
    End
    If y < x Then Do
     Say 'Path='||Path||' curStage='||curStage
     Say 'Error: curStage earlier than thisPath in thisMap'
     Exit(13)
    End
    priorstgs = SubWord(thisMap,x,y-x)||' '||priorstgs
  End
  If Trace_Opt == 'Y' Then Say 'prior stages:' priorstgs
  Return;

ConvertSCL2StemArray:

  SCLdet. = ''
  p# = 0
  Do s# = 1 to scl.0
     SCLdetail = Substr(scl.s#,14)
     If Words(SCLdetail) < 7 Then Iterate
     SCLdetail = StriP(SCLdetail)
     SCLdetail = StriP(SCLdetail,'B',"'")
     Command   = Word(SCLdetail,01)
     Envmnt    = Word(SCLdetail,02)
     Stg       = Word(SCLdetail,03)
     System    = Word(SCLdetail,04)
     Subsys    = Word(SCLdetail,05)
     Type      = Word(SCLdetail,06)
     Element   = Word(SCLdetail,07)
     If Trace_Opt == 'Y' Then Trace r
     entry = Element'_'Type'_'Envmnt'_'System'_'Subsys'_'Stg
     SCLdet.entry = Command
     If Command == 'Command' Then p# = p# + 2
     Sa= pkg.p#
     SCLdet.entry.pkgid = Strip(Word(pkg.p#,3),'B',"'")
     Sa= 'SCLdet.'entry '=' Command
     If Trace_Opt == 'Y' Then Trace O

     If Command == 'MOVE' Then,
     If (Envmnt <> thisEnv) | (Stg <> thisStg) Then Do
       Say 'Warning: Invalid MOVE action FROM stage found in package:'
       Say SCLdet.entry.pkgid
       If Trace_Opt == 'Y' Then,
        Say ' Discarding the following MOVE action:'
       If Trace_Opt == 'Y' Then,
        Say entry
       Drop SCLdet.entry
       Drop SCLdet.entry.pkgid
       Iterate
     End
  End; /*  Do s# = 1 to scl.0 */
  Return

ScanACMandCompare:

  If Trace_Opt = 'Y' then Trace r
  /* Look for items in ACM data that are missing from Package SCL */
  Last_pkgid = ''
  Last_pkgid1 = ''
  Last_pkgid2 = ''
  Do a# = 1 to acm.0
     ACMDetail = acm.a#
     If Words(ACMDetail) < 7 Then Iterate
     LVL       = Word(Substr(ACMDetail,6),1)
     ELEMENT   = Word(Substr(ACMDetail,12),1)
     TYPE      = Word(Substr(ACMDetail,25),1)
     ENVIRON   = Word(Substr(ACMDetail,36),1)
     SYSTEM    = Word(Substr(ACMDetail,47),1)
     SUBSYS    = Word(Substr(ACMDetail,58),1)
     STG#      = Word(Substr(ACMDetail,70),1)
     STG       = StageID.Environ.STG#
     If LVL == '1' then Do
        entry1 = ELEMENT'_'TYPE'_'ENVIRON'_'SYSTEM'_'SUBSYS'_'STG
        Dependency = Strip(Substr(ACMDetail,12,58)||STG)
        Iterate
     End
     If LVL <> '2' then Iterate;
     If curstage <> ENVIRON||'.'||STG# Then Do
       x = WordPos(ENVIRON||'.'||STG#,priorstgs)
       If x > 0 Then Do
         ENVIRON = thisEnv
         STG# = thisStg#
         STG = thisStg
       End
       Else Iterate;
     End
/*   If ENVIRON /= thisEnv then Iterate; */
     entry = ELEMENT'_'TYPE'_'ENVIRON'_'SYSTEM'_'SUBSYS'_'STG
     If entry == Last_entry then iterate;
     Last_entry = entry
     Command = SCLdet.entry
     If Command == '' then Do
        If Last_pkgid <> SCLdet.entry1.pkgid Then,
        Queue 'For package ID '||Strip(SCLdet.entry1.pkgid)||':'
        Queue entry 'is non-packaged input used by:'
        Queue '  ' Dependency
        my_rc = 12
        Last_pkgid = SCLdet.entry1.pkgid
     End
     Else Do
       thisPkg      = Strip(SCLdet.entry1.pkgid)
       ComponentPkg = Strip(SCLdet.entry.pkgid)
       If ComponentPkg <> thisPkg Then Do
         /* reset dependent package carried over from last time */
         If Last_pkgid1 <> thisPkg Then Last_pkgid2 = ''
         /* if new dependency that was not previously identified */
         If WordPos(ComponentPkg,Last_pkgid2) == 0 Then Do
           /* if new package ID  not already identified */
           If Last_pkgid1 <> thisPkg Then Do
             Queue 'package ID '||thisPkg ||':'
             Last_pkgid1 = thisPkg
           End
           Queue ' depends on '||ComponentPkg
           If WordPos(ComponentPkg,PkgDependencies.thisPkg) == 0 then,
              PkgDependencies.thisPkg = PkgDependencies.thisPkg,
                                        ComponentPkg
           Last_pkgid2 = Last_pkgid2||' '||ComponentPkg
         End /* If WordPos(ComponentPkg,Last_pkgid2) == 0 Then Do */
       End /* If ComponentPkg <> thisPkg Then Do */
     End /* If Command == '' then ... Else Do */
  End;  /* Do a# = 1 to acm.0 */
  If Trace_Opt == 'Y' then Trace o
  Return

ShowChronologicalOrder:

   If Trace_Opt == 'Y' then Trace r
  /* Interpret Rexx Stem info on Packages      */
   Package4Row.     = ''
   Row4Package.     = ''
   PackageRow.     = 0
   maxrow = 0
   Do p# = 1 to pkg.0
      PackageRow.p# = Right(Strip(pkg.p#),4)
      If maxrow < PackageRow.p# Then maxrow = PackageRow.p#
      p# = p# + 1
      packageInfo = pkg.p#
      Interpret packageInfo
   End

   /* Start out assuming all pkgs can run at the same time  */
   Chronological.   = 1
   MaxChronologicalOrder = 1

   /* Use the PkgDependencies. stem array to reflect order */
   /* Loop until no more changes are being made */
    Do forever
      row# = 1
      ContinueLooping = 'N'
      /* Loop through all packages adjusting choronological orders */
      Do forever
         row# = row# + 1
         rowindx = Right(row#,4,'0')
         thisPkg =  Package4Row.rowindx
         If thisPkg == '' & row# < maxrow Then Iterate
         Else if thisPkg == '' Then ContinueLooping = 'E'
         If ContinueLooping == 'E' then,
            Do
            lastrow# = row#
            leave;
            End
         ComponentPackages = PkgDependencies.thisPkg
         if ComponentPackages == '' then Iterate;
         orderThisPkg = Chronological.thisPkg
         If orderThisPkg = 0 then Iterate; /* 0 means circular */
         Do chron# = 1 to Words(ComponentPackages)
            ComponentPkg = Word(ComponentPackages,chron#)
            orderComponentPkg = Chronological.ComponentPkg
            If orderComponentPkg = 0 then iterate ; /* circular */
            If orderThisPkg > orderComponentPkg then iterate;
            ComponentDependencies = PkgDependencies.ComponentPkg
            Call UpdateThisPkgDependencies
            If WordPos(thisPkg,ComponentDependencies) > 0 then,
               Do
               Queue 'Circular references for these packages:'
               Queue ComponentPkg '<->' thisPkg
               my_rc = CircleRc
               Chronological.thisPkg = 0 ; /* circular */
               Iterate;
               End
            ContinueLooping = 'Y'
            orderThisPkg = orderComponentPkg + 1
            If orderThisPkg > MaxChronologicalOrder then,
               MaxChronologicalOrder = orderThisPkg
            Chronological.thisPkg = orderThisPkg
            Say thisPkg orderThisPkg 'Af'
         End;  /* Do chron# = 1 to Words(ComponentPackages) */
       End; /* Do Forever */
       If ContinueLooping /= 'Y' then Leave
    End; /* Do Forever */

    lastrow# = lastrow# - 1
    Say 'lastrow# =' lastrow#
    Say 'MaxChronologicalOrder=' MaxChronologicalOrder

    Do thisOrder = MaxChronologicalOrder To 1 By -1
       If thisOrder == 1 Then,
       Queue 'Packages with no prerequisites'
       Else Queue 'Packages with level '||thisOrder-1||' prerequisites'
       Do row# = 1 to lastrow#
          rowindx = Right(row#,4,'0')
          thisPkg =  Package4Row.rowindx
          If thisPkg == '' Then Iterate
          orderThisPkg = Chronological.thisPkg
          if orderThisPkg /= thisOrder then Iterate ;
          Queue Copies(' ',(thisOrder-1)*2) thisPkg
       End; /* Do row# = 1 to lastrow# */
    End; /*  Do thisOrder = 1 to MaxChronologicalOrder */

    If Trace_Opt == 'Y' then Trace o
    Return


UpdateThisPkgDependencies:

   /* Component Pkgs might themselves have Component Pkgs   */
   /* that need to be included as components for using Pkgs */
   Do w# = 1 to Words(ComponentDependencies)
      tmpCompPkg = Word(ComponentDependencies,w#)
      If WordPos(tmpCompPkg,ComponentPackages) == 0 then,
         ComponentPackages = ComponentPackages tmpCompPkg
   End;  /* Do w# = 1 to Words(ComponentDependencies) */

   ContinueLooping = 'Y'

   PkgDependencies.thisPkg = ComponentPackages

   Return

ShowPKGORDER_Report:

   /* List packages implying possible order, using indentation */
   Do thisOrder = 1 to MaxChronologicalOrder
      Do row# = 2 to lastrow#
         rowindx = Right(row#,4,'0')
         thisPkg =  Package4Row.rowindx
         if thisPkg = ' ' then leave;
         orderThisPkg = Chronological.thisPkg
         if orderThisPkg /= thisOrder then Iterate ;
         Queue Copies(' ',(thisOrder-1)*2) thisPkg
      End; /* Do row# = 1 to lastrow# */
   End; /*  Do thisOrder = 1 to MaxChronologicalOrder */

   Return

