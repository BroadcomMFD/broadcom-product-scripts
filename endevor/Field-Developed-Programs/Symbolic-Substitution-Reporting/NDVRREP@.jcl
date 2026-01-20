//WALJO11T JOB (301000000),'WALTHER',REGION=0M,                         JOB70892
//   RESTART=STEP#02,
//         CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*  RESTART=STEP#02,
//*-------------------------------------------------------------------*
//  EXPORT SYMLIST=(*)
//  JCLLIB ORDER=(BST.ENDEVOR.CA32.JCL,WALJO11.JCL)
//  SET TRACE=#CONC1                T/Y/N/variable-name
//  SET TRACE=T                     T/Y/N/variable-name
//  SET TRACE=N                     T/Y/N/variable-name
//*==================================================================*
//STEP#01  EXEC PGM=IKJEFT1B,PARM='ENBPIU00 A'
//TABLE    DD *
*C1EN C1ST C1SI C1S# C1SY    C1SU C1TY   C1SENVMNT C1SSTGNUM C1SSUBSYS
 QA   QA   2    2    ESCM190 GA   ASMPGM DEV       1         SIQ07150
 PRD  PRD  2    2    ESCM190 GA   ASMPGM QA        2         GA
//MODEL    DD *
  RecordCount = &$row#
//MODEL1   DD *
C1EN      = &C1EN
C1ST      = &C1ST
C1SI      = &C1SI
C1S#      = &C1S#
C1SY      = &C1SY
C1SU      = &C1SU
C1TY      = &C1TY
C1SENVMNT = &C1SENVMNT
C1SSTGNUM = &C1SSTGNUM
//OPTIONS  DD *
  if $row# < 1 then $SkipRow = 'Y'
  TBLOUT  = 'C1VARS'
  x =  BuildFromMODEL(MODEL1)
  cmd = "EXECIO 0 DISKW C1VARS ( Finis"; say cmd; cmd
  cmd = "EXECIO * DISKR C1VARS   ( Finis"; say cmd; cmd
  cmd = "EXECIO * DISKR ESYMBOLS ( Finis"; say cmd; cmd
  cmd = "EXECIO * DISKR PROCSYMS ( Finis"; say cmd; cmd
  cmd = "EXECIO" QUEUED() "DISKW INPUT ( Finis"; say cmd; cmd

  Topt# = 'T#' || Right($row#,6,'0')
  reportDSN = 'WALJO11.WORK(' || Topt# || ')'
  STRING = "ALLOC DD("Topt#") DA("reportDSN") SHR REUSE"
  Say STRING; CALL BPXWDYN STRING;
  CALL NDVRREPT N
  STRING = "FREE DD("Topt#")"
  If $tbl < $tablerec.0 then $SkipRow = 'Y'
  TBLOUT  = 'COUNT'
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//   INCLUDE MEMBER=SYSEXEC
//ESYMBOLS DD DISP=SHR,DSN=WALJO11.MODELS(ESYMBOLS)
//PROCSYMS DD DISP=SHR,DSN=WALJO11.MODELS(PROCSYMS)
//INPUT    DD DISP=SHR,DSN=WALJO11.WORK(INPUT)
//C1VARS   DD DISP=SHR,DSN=WALJO11.WORK(C1VARS)
//COUNT    DD DISP=SHR,DSN=WALJO11.WORK(COUNT)
//TBLOUT2  DD SYSOUT=*
//*==================================================================*
//STEP#02  EXEC PGM=IKJEFT1B,PARM='ENBPIU00 PARMLIST'
//PARMLIST DD *
  NOTHING  NOTHING  COUNT   0
  MODEL    REPORT   OPTIONS A
//TABLE    DD *
* Do
  *
//COUNT    DD DISP=SHR,DSN=WALJO11.WORK(COUNT)
//OPTIONS  DD *
  If $row# < 1 then $SkipRow = 'Y'
  Say "RecordCount=" RecordCount
  Do r# = 1 to RecordCount; +
     Topt# = 'T#' || Right(r#,6,'0') ; +
     reportDSN = 'WALJO11.WORK(' || Topt# || ')'; +
     STRING = "ALLOC DD("Topt#") DA("reportDSN") SHR REUSE" ; +
     Say STRING; CALL BPXWDYN STRING; +
     x = IncludeQuotedOptions(Topt#) ; +
     $row# = r#; +
     say "-73"; Trace O; x = BuildFromMODEL(MODEL); say "+73";+
     STRING = "FREE DD("Topt#")"; Say STRING; CALL BPXWDYN STRING; +
  End;
  Exit
//MODEL    DD *   < format of the report for one row
*- &C1EN &C1SI &C1SY &C1SU
      #LISTLIB#S1 = &#LISTLIB#S1
      ADATADSN    = &ADATADSN
      ASMERR      = &ASMERR
      #HFSBASE1   = &#HFSBASE1
      OBJLIB      = &OBJLIB
      PARMSDEF    = &PARMSDEF
      SYSLIB1     = &SYSLIB1
      SYSUT1      = &SYSUT1
//NOTHING  DD DUMMY
//   INCLUDE MEMBER=SYSEXEC
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//REPORT   DD SYSOUT=*
//*==================================================================*
