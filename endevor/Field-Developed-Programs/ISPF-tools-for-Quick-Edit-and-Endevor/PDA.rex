/*  REXX   */
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.  */
   /* WRITTEN BY DAN WALTHER */
/*                                                                   */
   'ISREDIT MACRO'
    TRACE  Off
   /* If a DDNAME of PDA    is allocated, then turn on Trace */
   WhatDDName = 'PDA'
   CALL BPXWDYN "INFO FI("WhatDDName")",
   "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   If Substr(DSNVAR,1,1) /= ' ' then Trace ?R
/*                                                                   */
/* Variable settings for each site --->           */
   WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
   interpret 'Call' WhereIam "'PDAMapList'"
   PDAMapList = Result
/* <---- Variable settings for each site          */
/*                                                                   */

/* Get variables from Endevor. */

    ADDRESS ISPEXEC
            'VGET (ENVBENV ENVBSYS ENVBSBS ENVBTYP ENVBSTGI ENVBSTGN ',
                  'ENVSENV ENVSSYS ENVSSBS ENVSTYP ENVSSTGI ENVSSTGN ',
                  'ENVELM  ENVPRGRP ENVCCID ENVCOM ENVGENE ENVOSIGN) ',
            'PROFILE'

    ADDRESS ISPEXEC  'VGET (NOTIFYME) PROFILE '
    ADDRESS ISPEXEC  'VGET (ZUSER)'

    If NOTIFYME /= 'Y' then Exit

    Call Call_APIALELM ;

   ADDRESS TSO,
   "EXECIO * DISKR ELEMLIST (STEM LIST. FINIS" ;
    DISKR_rc = RC
    ADDRESS TSO,
       "FREE F(ELEMLIST) DELETE "
    IF DISK_rc > 0 THEN exit;
    If LIST.0 < 1 then exit


/* Initialize some variables */
rpt = 0
drop rsub.
drop ruser.
drop rccid.
drop rstg.
drop rvvll.

/* Inspect the output of the API call */
/* If no output, then the element doesn't exist in the inventory */
do i = 1 to list.0
  /* Get the environment where this copy of the element lives */
  env = substr(list.i,15,8)

  /* Get the subsystem and stage */
  sub = substr(list.i,31,8)
  stg = substr(list.i,65,1)

  /* We don't care about the copy of the element we're editing */
  if strip(sub) = strip(envbsbs) & stg = envbstgn then iterate i

  /* Anything else is something we should tell the user */
  rpt = rpt + 1
  ruser.rpt = substr(list.i,95,8)
  if strip(ruser.rpt) = '' then ruser.rpt = substr(list.i,325,8)
  rccid.rpt = substr(list.i,156,12)
  rstg.rpt = stg
  rsub.rpt = sub
  renv.rpt = env
  rvvll.rpt = substr(list.i,103,4)

end

/* If we found something to report, then report it */
if rpt > 0 then ,
  do
    address ISPEXEC

    /* save caps setting, then set caps off */
    "ISREDIT (MYCAPS) = CAPS"
    "ISREDIT CAPS OFF"

    /* Insert the heading */
    msg = 'Other inventory locations where' envelm 'was found:'
    "ISREDIT LINE_BEFORE 1 = NOTELINE '"msg"'"

    msg = '  USERID   CCID         ENVIRON  S SYSTEM   SUBSYS   VVLL'
    "ISREDIT LINE_BEFORE 1 = NOTELINE '"msg"'"

    msg = '  -------  ------------ -------- - -------- -------- ----'
    "ISREDIT LINE_BEFORE 1 = NOTELINE '"msg"'"

    do i = 1 to rpt
      /* Build the line to display */
      msg = '  '|| ,
            substr(ruser.i,1,9)|| ,
            substr(rccid.i,1,13)|| ,
            substr(renv.i,1,9)|| ,
            substr(rstg.i,1,2)|| ,
            substr(envbsys,1,9)||,
            substr(rsub.i,1,9)||,
            rvvll.i

      /* highlight lines for other users */
      if strip(ruser.i) = strip(zuser) then mtype = 'NOTELINE'
      else mtype = 'MSGLINE'

      "ISREDIT LINE_BEFORE 1 =" mtype "'"msg"'"
    end

    /* Restore caps setting */
    "ISREDIT CAPS" mycaps
  end

  EXIT

Call_APIALELM :

   ADDRESS TSO
/*                                                                   */
    "ALLOC F(SYSPRINT) DUMMY REUSE " ;
    "ALLOC F(SYSOUT) DUMMY REUSE " ;
/*  "ALLOC F(BSTERR) DUMMY REUSE " ;                                 */
/*  "ALLOC F(BSTAPI) DUMMY REUSE " ;                                 */
/*                                                                   */
/*  "ALLOC F(SYSPRINT) DA(*) REUSE " ;                               */
/*  "ALLOC F(SYSOUT) DA(*) REUSE " ;                                 */
/*  "ALLOC F(BSTERR) DA(*) REUSE " ;                                 */
/*  "ALLOC F(BSTAPI) DA(*) REUSE " ;                                 */
/*                                                                   */
    "ALLOC F(SYSIN) LRECL(80) BLKSIZE(0) SPACE(5,5)",
           "RECFM(F B) TRACKS ",
           "NEW UNCATALOG REUSE "     ;
    "ALLOC F(MSGFILE) LRECL(133) BLKSIZE(13300) SPACE(5,5)",
           "RECFM(F B) TRACKS ",
           "NEW UNCATALOG REUSE "     ;
    "ALLOC F(ELEMLIST) LRECL(2048) BLKSIZE(22800) SPACE(5,5)",
           "RECFM(V B) TRACKS DSORG(PS) ",
           "DA('"USERID()".PDA.NOTIFY."ENVELM"')",
           "MOD CATALOG REUSE "     ;
  /*                                                                */
  /*    V - COLUMN 6 = FORMAT SETTING                               */
  /*      = ' ' FOR NO FORMAT, JUST EXTRACT ELEMENT                 */
  /*      = 'B' FOR ENDEVOR BROWSE DISPLAY FORMAT                   */
  /*      = 'C' FOR ENDEVOR CHANGE DISPLAY FORMAT                   */
  /*      = 'H' FOR ENDEVOR HISTORY DISPLAY FORMAT                  */
  /*    V - COLUMN 7 = RECORD TYPE SETTING                          */
  /*      = 'E' FOR ELEMENT                                         */
  /*      = 'C' FOR COMPONENT                                       */
  /*       VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                 */
  /*               V - COLUMN 18 = STAGE ID                         */
  /*                VVVVVVVV - COLUMN 19-26 SYSTEM NAME             */
  /*                        VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME  */
  /*   COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                      */
  /*   COLUMN 45-52 = TYPE NAME               VVVVVVVV              */
  /*                                                                */

         SYSTEM  = ENVSSYS  ;
       SUBSYSTEM = '*       ' ;
            TYPE = ENVSTYP;
       ELEMENT   = ENVELM ;

       Do map# = 1 to Words(PDAMapList)
          QUEUE 'AACTL MSGFILE ELEMLIST'      /* Another search ... */
          Mapentry  = Word(PDAMapList,map#) /* One  map entry */
          Mapentry  = Translate(Mapentry," ","/-")
          FromEnv   = Word(Mapentry,1)
          FromStg   = Word(Mapentry,2)
          ThruEnv   = Word(Mapentry,3)
          ThruStg   = Word(Mapentry,4)
          TEMP= COPIES(" ",80);
          TEMP= Overlay('ALELMLAR ',TEMP,1) ;
          TEMP= Overlay(FromEnv,TEMP,10) ;       /* from Env        */
          TEMP= Overlay(FromStg,TEMP,18) ;       /* from stg id     */
          TEMP= Overlay(ThruEnv,TEMP,53) ;       /* thru ENV        */
          TEMP= Overlay(ThruStg,TEMP,61) ;       /* thru stg id     */
          TEMP= Overlay(SYSTEM,TEMP,19) ;
          TEMP= Overlay(SUBSYSTEM,TEMP,27) ;
          TEMP= Overlay(ELEMENT,TEMP,35) ;
          TEMP= Overlay(TYPE,TEMP,45) ;
          SA= TEMP;
          QUEUE TEMP ;
          QUEUE 'RUN' ;
       End /* Do map# = 2 to Words(PDAMapList) */

       QUEUE 'AACTLY ' ;
       QUEUE 'RUN' ;
       QUEUE 'QUIT' ;
       ADDRESS TSO,
       "EXECIO" QUEUED() "DISKW SYSIN (FINIS "
       RETURN_RC = 0  ;
       ADDRESS TSO "PROFILE NOWTPMSG " ;

       ADDRESS ISPEXEC "SELECT PGM(ENTBJAPI)" ;
       IF RC > 0 THEN,
          DO
          SA= 'CANNOT GET INFORMATION FROM ENDEVOR' ;
          EXIT
          END ;
       RETURN_RC = RC ;

   Return ;

Insert_Message :

  MESSAGE= COPIES(" ",80);
  MESSAGE =   Filler,
              userid,
              CCID,
                   environment,
                   stage ,
                   system ,
                   subsys ,
                   type ,
                   element ;
  'ISREDIT ' WHERE '.ZCSR = 'msgtype '"'MESSAGE'"' ;

  return ;
