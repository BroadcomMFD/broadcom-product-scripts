//IBMUSER2 JOB (55800000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------
// SET CSVFILE=IBMUSER.PHONS.CSVFILE.#2
// SET CSVFILE=IBMUSER.PHONS.CSVFILE.#3
// SET CSVFILE=IBMUSER.PHONS.CSVFILE.#4
// SET CSVFILE=IBMUSER.PHONS.CSVFILE
// SET SYSEXEC=IBMUSER.REXX
// SET SYSEXEC=CAPRD.NDVR.PROD.CATSNDVR.CEXEC
//*--------------------------------------------------------------
//*- To Report Packages created over nnn days ago     -----------
//*--------------------------------------------------------------------*
//*   STEP 1 -- Execute CSV Utility to gather Package information
//*--------------------------------------------------------------------*
//REPORT EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'
//TABLE    DD  DSN=&CSVFILE,DISP=SHR
//PARMLIST DD *
  MODEL   TBLOUT  OPTION0  0
  MODEL   TBLOUT  OPTIONS  A
//HEADING  DD *
* Package--------- Status----- CreateDate UpdateDate CreatorId- PackageAge
//*-+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8
//MODEL    DD *
&DetailLine
//OPTION0  DD *
  LinesPerPage = 15
  LineCount = LinesPerPage + 1
  DaysAgo = 60          /* Number of days for cutoff */
//OPTIONS  DD *
* Bypass processing for Table header
  If $row# < 1 then $SkipRow = 'Y'
* Calculate age of Package creation
  BaseDate = DATE('B')  /* Today in Base format */
  UpdateDate = Substr(UPDT_DATE,1,4) || Substr(UPDT_DATE,6,2)
  UpdateDate = UpdateDate || Substr(UPDT_DATE,9,2)
  If DATATYPE(UpdateDate) /= 'NUM' then $SkipRow = 'Y'
  BaseOld  = DATE(B,UpdateDate,S)  /* Convert Upd date to Base fmt */
  PackageAge = BaseDate - BaseOld  /* Determine how many days ago  */
  If PackageAge < DaysAgo then $SkipRow = 'Y'  /* Skip if recent */
* Build report detail line ....
  DetailLine = Copies(' ',120);
  DetailLine = Overlay(PKG_ID,DetailLine,03)
  DetailLine = Overlay(STATUS,DetailLine,20)
  DetailLine = Overlay(CREATE_DATE,DetailLine,32)
  DetailLine = Overlay(UPDT_DATE,DetailLine,43)
  DetailLine = Overlay(CREATE_USRID,DetailLine,54)
  DetailLine = Overlay(PackageAge,DetailLine,65)
* Determine whether it is time for page heading
  LineCount = LineCount + 1
  If LineCount > LinesPerPage then x = BuildFromMODEL(HEADING)
  If LineCount > LinesPerPage then LineCount = 1
//SYSEXEC DD DSN=&SYSEXEC,DISP=SHR
//SYSTSPRT DD  SYSOUT=*
//SYSPRINT  DD SYSOUT=*
//SYSIN     DD DUMMY
//TBLOUT   DD SYSOUT=*
//*-------------------------------------------------------------------
