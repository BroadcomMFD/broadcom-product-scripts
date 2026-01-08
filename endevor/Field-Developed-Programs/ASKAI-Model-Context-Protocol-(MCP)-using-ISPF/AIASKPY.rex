/*  REXX */
/*  Call mfclient.py with the Query collected from ISPF        */
/*  using the AIASK tool.                                      */
/*  Present the response back to the user....                  */
  Trace Off

  ADDRESS TSO "EXECIO * DISKR QUERY (stem qry. Finis"
  ADDRESS TSO "FREE  F(QUERY)"
  sa= qry.0
  Message = ''
/*Do qry# = 3 to qry.0 */
  Do qry# = 1 to qry.0
     Message = Message Strip(Substr(qry.qry#,1,92))
  End
  Message = Strip(Message)
  Message = '"'Message'"'

  sa= 'AIASKPY message says:' Message

/* Set up the variables for running Python */
 command = "sh cd /u/users/waljo11;",
           "python python/mfclient.py" Message
 stdout.0 = 0
 stderr.0 = 0
 stdin.0 = 0
 env.0 = 4
 env.1 = "PATH=" || ,
   "/usr/lpp/IBM/cyp/pyz/bin/:" || ,
   "/bin:/sys/java64bt/v8r0m0/usr/lpp/java/J8.0_64/bin:" || ,
   "/usr/lpp/IBM/cyp/v3r9/pyz/bin:" || ,
   "/usr/lpp/IBM/zoautil/bin:" || ,
   "/usr/lpp/IBM/zoautil/env/bin:" || ,
   "/u/users/cai/moi/v2001/s1801/bin:/u/users/nodejs/nodejs/bin:"

 env.2 = "LIBPATH=" || ,
   "/lib:" || ,
   "/usr/lib:" || ,
   "/sys/java64bt/v8r0m0/usr/lpp/java/J8.0_64/include:" || ,
   "/usr/lpp/IBM/cyp/v3r9/pyz/lib:" || ,
"/u/users/mcqth01/python/venv/lib/python3.11/site-packages/pip/_vendor"

 env.3 = '_BPXK_AUTOCVT=ON'
 env.4 = '_CEE_RUNOPTS=FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'

   Say "One moment please..... "
/* Call Python to call the AI query */
   call bpxwunix command,stdin.,stdout.,stderr.,env.

   sa= stdout.0
   sa= stdout.1
   sa= stdout.2
   longest = 140
   Do st# = 1 to stdout.0
      stdout.st# = Strip(stdout.st#)
      Sa= st# Length(stdout.st#) stdout.st#
      If Length(stdout.st#) > longest then,
         longest = Length(stdout.st#)
   End

   Sa= 'AIASKPY says longest response rec is' longest
   /* calculate LRECL and BLKSIZE values from value of longest */
   num1    = longest % 100
   useLrecl= 100  *(num1+1)
   blkcount   = 32760 % useLrecl
   blkcount   = min(30,blkcount)
   useBlksize = blkcount * useLrecl

   CALL BPXWDYN "INFO FI(RESULT)",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) > ' ' then,
      Do
      ADDRESS TSO "EXECIO 0 DISKW RESULT (Finis"
      ADDRESS TSO "FREE  F(RESULT)"
      End

   /* Allocate an empty dataset for the query */
   /* Leverages the pre-existing generic edit macro named WITHMSG */
   ADDRESS TSO,
     "ALLOC F(RESULT) LRECL("useLrecl") ",
       "BLKSIZE("useBlksize") SPACE(5,5)",
          "RECFM(F B) TRACKS ",
          "NEW UNCATALOG REUSE "

   ADDRESS TSO,
      "EXECIO" qry.0 "DISKW RESULT (stem qry."

   ADDRESS TSO,
      "EXECIO" stdout.0 "DISKW RESULT (Stem stdout. Finis"

   ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(RESULT)"
   ADDRESS ISPEXEC "VIEW DATAID(&DDID) MACRO(AIASKMRS)"
   ADDRESS ISPEXEC "VIEW DATAID(&DDID) MACRO(AIASKMCN)"
   ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"

   ADDRESS TSO "FREE F(RESULT)"
   EXIT
