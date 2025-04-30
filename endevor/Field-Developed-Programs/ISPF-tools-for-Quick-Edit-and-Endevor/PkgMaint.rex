 /* REXX   */
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA TECHNOLOGIES STAFF
   "AS IS".  NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE
   FOR THEM.  CA TECHNOLOGIES CANNOT GUARANTEE THAT THE ROUTINES
   ARE ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE
   CORRECTED.
*/
  TRACE  O ;

  ADDRESS ISPEXEC
     "VGET (ZSCREEN) SHARED"
  ADDRESS ISPEXEC
     "TBSTATS C1"ZSCREEN"P0200 STATUS1(STATUS1) STATUS2(STATUS2)"

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
     IF STATUS2 /= 2 & STATUS2 /= 3 & STATUS2 /= 4 then,
        do
        say "Must invoke PMAINT from a ",
            "Package list Screen (C1SP0200)" ;
        exit ;
        end;

  "TBQUERY C1"ZSCREEN"P0200 KEYS(KEYLIST) NAMES(VARLIST) ROWNUM(ROWNUM)"
  IF RC > 0 THEN EXIT

  ROWNUM = Strip(ROWNUM,'L','0')

  VARWKCMD =  "" ;
  "VGET (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "

  "DISPLAY  PANEL(PMAINTPN) "
  if rc > 0 then exit
  "VPUT (C1BJC1 C1BJC2 C1BJC3 C1BJC4) PROFILE "

  SCL_DSN = USERID()".TEMPSCL.PKGMAINT"
  PDVINCJC = "Y"
  PDVSCLDS = SCL_DSN ;
  PDVDD01  = "//DELETEME DD DSN="SCL_DSN",DISP=(OLD,DELETE)"

  ADDRESS TSO,
  "ALLOC F(PKGESCL) DA('"SCL_DSN"')",
         "LRECL(80) BLKSIZE(8000) SPACE(5,5)",
         "RECFM(F B) TRACKS ",
         "MOD CATALOG REUSE "     ;

  "TBTOP   C1"ZSCREEN"P0200 "
  Do row = 1 to ROWNUM
     "TBSKIP C1"ZSCREEN"P0200 "
     cmd = " "ACTION "PACKAGE '"VPHPKGID"' ."
     queue cmd
  End; /* do row = 1 to ROWNUM */

  ADDRESS TSO "EXECIO" QUEUED() "DISKW PKGESCL ( FINIS"
  ADDRESS TSO "FREE F(PKGESCL)"

  "FTOPEN TEMP"
  "FTINCL ENSP1000"

  "FTCLOSE "

  "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;
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

  exit

