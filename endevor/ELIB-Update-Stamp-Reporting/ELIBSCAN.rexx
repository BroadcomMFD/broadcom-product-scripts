/*  REXX  */
/*                                                                   */
/*- Routine called by LISTELIB to report ELIB datasets whose         */
/*- 'LAST UPDATE STAMP:' value is at or over a threshold             */
/*                                                                   */
    Trace Off
    Arg Dataset
    CALL BPXWDYN "INFO FI(ELIBSCAN) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
    if RESULT = 0 then Trace r
/*                                                                   */
/*- Allocate Dataset to the ELIBOLD DD name                          */
/*                                                                   */
    CALL BPXWDYN 'ALLOC DD(ELIBOLD) DA('Dataset') SHR REUSE'
/*                                                                   */
/*- Call BC1PNLIB with the INQUIRE request (in SYSIN)                */
    ADDRESS LINK 'BC1PNLIB'   ;  /* load from authlib */
    callRC= RC
/*  CALL BC1PNLIB ;                                                  */
    Say 'BC1PNLIB RC for' Dataset 'is' callRC;
/*                                                                   */
/*  If BC1PNLIB gets a high RC, then Dataset is not ELIB - skip it   */
    If callRC > 4 then Exit (0)
/*- Scan the SYSPRINT output for "LAST UPDATE STAMP:" value          */
/*                                                                   */
    "EXECIO * DISKR SYSPRINT (Stem sys. Finis"
    stamp = 0
    Do sy# = 1 to sys.0
       record = sys.sy#
       If Pos("DSNAME: ",record) > 0 then say Word(record,2)
       If Pos("LAST UPDATE STAMP:",record) =0 then Iterate;
       stamp = Word(Substr(record,30),1);
       Leave;
    End

    Exit (stamp)
