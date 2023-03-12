/*  REXX  */
/*  Cause a wait for designated seconds, without using CPU time */
  Trace OFF

  Arg seconds ;

  seconds = Abs(seconds)
  seconds = Trunc(seconds,0)
  Say DATE(S) TIME() "Waiting for" seconds "seconds "

  /* AOPBATCH and BPXWDYN are IBM programs */
  CALL BPXWDYN  "ALLOC DD(STDOUT) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDERR) DUMMY SHR REUSE"
  CALL BPXWDYN  "ALLOC DD(STDIN) DUMMY SHR REUSE"

  /* AOPBATCH and BPXWDYN are IBM programs */
  parm = "sleep "seconds
  Address LINKMVS "AOPBATCH parm"

  Say DATE(S) TIME() "The wait is over "

  Exit

