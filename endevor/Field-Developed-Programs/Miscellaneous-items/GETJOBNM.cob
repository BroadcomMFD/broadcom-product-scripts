       PROCESS DYNAM OUTDD(JOBINFO)
       Identification Division.
         Program-ID. GETJOBNM.
         Author. Gilbert Saint-Flour.
      *----------------------------------------------------------------*
      *                                                                *
      *    This program retrieves specific system-related data from    *
      *    MVS control blocks and moves it to Working-storage.         *
      *                                                                *
      *    The name of the control-block is indicated in pos 1-6 of    *
      *    the Procedure Division lines.                               *
      *    The layout of the MVS control blocks is described in the    *
      *    MVS Data Areas manuals, which can be found on any MVS or    *
      *    OS/390 CD collection or viewed on-line by going to:         *
      *        http://www.s390.ibm.com/bookmgr-cgi/bookmgr.cmd/library *
      *    and searching for:                                          *
      *        MVS DATA AREAS                                          *
      *                                                                *
      *   Origin = http://gsf-soft.com/Freeware/                       *
      *                                                                *
       Data Division.
        Working-Storage Section.
         01 Results.
           05 sys-name Pic x(8).
           05 job-name Pic x(8).
           05 proc-step Pic x(8).
           05 step-name Pic x(8).
           05 program-name Pic x(8).
           05 program-name2 Pic x(8).
           05 job-number Pic x(8).
           05 job-class Pic x.
           05 msg-class Pic x.
           05 programmer-name Pic x(20).
           05 acct1 Pic x(32).
           05 batch-or-cics Pic x(5).
              88 Batch Value 'BATCH'.
              88 CICS  Value 'CICS '.
           05 micro-seconds Pic S9(15) COMP-3.

       01 four-bytes.
           05 full-word Pic s9(8) Binary.
           05 ptr4      Redefines full-word Pointer.
       01 eight-bytes.
           05 double-word Pic s9(18) Binary.
      *                                                                *
       Linkage Section.
         01 cb1.  05 ptr1 Pointer Occurs 256.
         01 cb2.  05 ptr2 Pointer Occurs 256.
       Procedure Division.
      *                                                                *
 PSA       SET Address of cb1 to NULL
 TCB       SET Address of cb1 to ptr1(136)
           MOVE cb1(317:8) to eight-bytes
           COMPUTE micro-seconds = double-word / 4096
 TIOT      SET Address of cb2 to ptr1(4)
           MOVE cb2(1:8) to job-name
           DISPLAY 'job_name='        quote  job-name quote
*********  MOVE cb2(9:8) to proc-step
*********  MOVE cb2(17:8) to step-name
 JSCB      SET Address of cb2 to ptr1(46)
           MOVE cb2(361:8) to program-name
           DISPLAY 'program_name='    quote  program-name quote
 SSIB      SET Address of cb2 to ptr2(80)
           MOVE cb2(13:8) to job-number
           DISPLAY 'job_number='      quote  job-number quote
 PRB       SET Address of cb2 to ptr1(1)
           MOVE cb2(97:8) to program-name2
*********  DISPLAY 'program_name2='   quote  program-name2 quote
 JSCB      SET Address of cb2 to ptr1(46)
 JCT       SET Address of cb2 to ptr2(66)
*********  MOVE cb2(48:1) to job-class
*********  MOVE cb2(23:1) to msg-class
 ACT       MOVE zero to full-word
           MOVE cb2(57:3) to four-bytes(2:3)
           SET Address of cb2 to ptr4
           MOVE cb2(25:20) to programmer-name
           DISPLAY 'programmer_name=' quote  programmer-name quote
           MOVE zero to full-word
           MOVE cb2(49:1) to four-bytes(4:1)
           MOVE cb2(50:full-word) to acct1
           DISPLAY 'accounting_code=' quote  acct1 quote
      *                                                                *
           GOBACK.
