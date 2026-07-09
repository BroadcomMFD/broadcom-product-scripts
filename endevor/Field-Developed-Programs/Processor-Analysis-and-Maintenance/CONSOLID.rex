/*     REXX   */
/* CONTROL NOMSG NOSYMLIST NOCONLIST NOLIST NOPROMPT                  */
   ADDRESS ISPEXEC " CONTROL RETURN ERRORS " ;
/* ARG selectProcessor  */
   TRACE oFF
   /* set myPrefix to a HLQ for work dataset names   */
   myPrefix = USERID()
   /* name one processor to compare to all others    */
   selectProcessor = 'GCBL'
   /*select a processor step 4 SUPER comparisons */
   selectStep      = 'COMPILE'
   /* if your site requires a VOLUME on allocations, include 1 here */
   volume = ''
   UseVolume    ='TSOE32'
   If Length(UseVolume) > 2 then,
      volume = "VOLUME("UseVolume")"
/* Name  Dataset that contains the processors to be compared  */
   Dataset = myPrefix'.PROCESS.PROCESSR' ;
   Dataset = 'YOURSITE.NDVR.TEAM.PROCESS.COBOL'
   NEWDD = Dataset ;
   OldDD = Dataset ;
   Listings =myPrefix'.SUPERC.'selectProcessor'.SAVELIST' ;
   UPDATES =myPrefix'.SUPERC.'selectProcessor'.UPDATES' ;
   Skeletons = myPrefix'.ENDEVOR.SKELS' ;
/*                                                                    */
   Listings =myPrefix'.SUPERC.'selectProcessor'.SAVELIST' ;
   UPDATES =myPrefix'.SUPERC.'selectProcessor'.UPDATES' ;
   Skeletons = myPrefix'.TEAM.MODELS'
   Skeletons = 'YOURSITE.YOUR.NDVR.NODES1.ISPS'
/* name the macro that parses the steps of a processor                */
   MACRO   = 'SUPCSOUT';
   ADDRESS ISPEXEC,
   "LIBDEF ISPSLIB Dataset ID('"Skeletons"') COND STACK"     ; ,
/*                                                                    */
   Call Allocate_Files ;
/*                                                                    */
/* COMPARE ALL MEMBERS OF PROCESSOR LIBRARY WITH MEMBER SPECIFIED BY  */
/*    ARG. GET STEPS FOR EACH PROCESSOR TOO.                          */
/*                                                                    */
   List_Processors = " ";
   Call Compare_Processors ;
/*                                                                    */
/* COMPARE ALL STEPS OF ARG PROCESSOR WITH SAME-NAMED STEPS IN OTHERS */
/*                                                                    */
   Call Compare_Processor_Steps
   EXIT ;
Compare_Processors:
/*                                                                    */
/* List processors (members) in the named dataset                     */
   TEMP = LISTDSI("'"Dataset"'" RECALL);
   ADDRESS ISPEXEC " LMINIT DATAID(MYPDS1) Dataset('"Dataset"') " ;
   ADDRESS ISPEXEC " LMOPEN DATAID("MYPDS1") OPTION(INPUT) " ;
   RtCode = 0 ;
   Do While RtCode = 0
      ADDRESS ISPEXEC " LMMLIST DATAID("MYPDS1") OPTION(LIST) ",
                     "MEMBER(MYMBR) STATS(NO) "  ;
      RtCode = RC ;
      IF RtCode = 0 THEN ,
         Do
         MYMBR = STRIP(MYMBR) ;
         SA= 'PROCESSING FOR *'MYMBR'*' ;
         List_Processors = List_Processors MYMBR ;
         StepDSN =myPrefix'.SUPERC.'MYMBR'.STEPS' ;
         DSNCHECK = SYSDSN("'"StepDSN"'") ;
         IF DSNCHECK /= OK THEN,
            Do
            SA= 'ALLOCATING ' StepDSN             ;
            ADDRESS TSO "ALLOC DA('"StepDSN"') ",
               " LRECL(080) BLKSIZE(32000) SPACE(10,10) ",
               " DIR(15) DSNTYPE(LIBRARY) ",
               " SPACE(10,10) RECFM(F B) CYLINDERS DSORG(PO) ",
               " NEW CATALOG REUSE" volume
            ADDRESS TSO "FREE  DA('"StepDSN"')" ;
            End /* IF DSNCHECK /= OK THEN  */
         Input_DSN = Dataset ;
         Input_DSN = Input_DSN'('MYMBR')' ;
         "ALLOCATE F(PROCESSB) DA('"Input_DSN"') SHR REUSE " ;
         "EXECIO * DISKR PROCESSB (STEM PROCESSR. FINIS " ;
         ADDRESS TSO "FREE F(PROCESSB) " ;
         NEWDSN = StepDSN'('MYMBR')' ;
         "ALLOCATE F(NEW#MBR) DA('"NEWDSN"') SHR REUSE " ;
         "EXECIO * DISKW NEW#MBR (STEM PROCESSR. FINIS " ;
         ADDRESS TSO "FREE F(NEW#MBR) " ;
         "ALLOCATE DA('"NEWDSN"') OLD REUSE " ;
         DROP PROCESSR.  ;
         SAY 'Creating members from STEPS of' MYMBR;
         "ISPEXEC EDIT Dataset('"NEWDSN"')",
                    "MACRO("MACRO")" ;
         ADDRESS TSO "FREE DA('"NEWDSN"')" ;
         SA= 'RUNNING SUPERC FOR' selectProcessor 'AND' MYMBR;
         /* if you want whole processor comparisons, uncomment */
         /*  Call Do_Superc ;   */
         END ; /* IF RtCode */
      END; /*  Do While ... */
/*                                                                    */
   ADDRESS ISPEXEC " LMCLOSE DATAID(MYPDS1) ";
   RETURN
Allocate_Files:
   DSNCHECK = SYSDSN("'"Listings"'") ;
   IF DSNCHECK /= OK THEN,
      Do
      ADDRESS TSO "ALLOC DA('"Listings"') BLKSIZE(13300) ",
          "CYLINDERS ",
          "LRECL(133) RECFM(F B) ",
          " DIR(15) DSNTYPE(LIBRARY) ",
          " SPACE(10,10) RECFM(F B) CYLINDERS DSORG(PO) ",
          " NEW CATALOG REUSE" volume
      ADDRESS TSO "FREE  DA('"Listings"')" ;
      SA= 'ALLOCATING ' Listings ;
      END;
   DSNCHECK = SYSDSN("'"UPDATES"'") ;
   IF DSNCHECK /= OK THEN,
      Do
      ADDRESS TSO "ALLOC DA('"UPDATES"') ",
         " LRECL(080) BLKSIZE(32000) SPACE(10,10) ",
         " DIR(15) DSNTYPE(LIBRARY) ",
         " SPACE(10,10) RECFM(F B) CYLINDERS DSORG(PO) ",
         " NEW CATALOG REUSE" volume
      ADDRESS TSO "FREE  DA('"UPDATES"')" ;
      SA= 'ALLOCATING ' UPDATES    ;
      END;
  RETURN ;
Do_Superc:
   ADDRESS ISPEXEC "FTOPEN TEMP"
   ADDRESS ISPEXEC "FTINCL CONSOLSK"
   ADDRESS ISPEXEC "FTCLOSE " ;
   ADDRESS ISPEXEC "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;
   Debug = 'YES' ;
   Debug = 'NAW' ;
   X = OUTTRAP("OFF")
   IF Debug = 'YES' THEN,
      Do
      Trace ?R
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(&ZTEMPN)"
      ADDRESS ISPEXEC "EDIT DATAID(&DDID)"
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"
      END;
   ELSE,
      ADDRESS TSO "SUBMIT '"ZTEMPF"'" ;
   RETURN ;
Compare_Processor_Steps:
   /* Go though the members in your processor dataset again      */
   /* and compare the selectStep with the one in selectprocessor */
   sa = 'Compare_Processor_Steps'
   Do mbr# = 1 to Words(List_Processors)
      MYMBR = Word(List_Processors,mbr#)
      OLDDD = myPrefix'.SUPERC.'MYMBR'.STEPS' ;
      Listings = myPrefix'.SUPERC.'selectStep'.SAVLIST' ;
      DSNCHECK = SYSDSN("'"Listings"'") ;
      IF DSNCHECK /= OK THEN,
         Do
         SA= 'ALLOCATING ' Listings            ;
         ADDRESS TSO "ALLOC DA('"Listings"') BLKSIZE(13300) ",
             "CYLINDERS ",
             "LRECL(133) RECFM(F B) ",
             " DIR(15) DSNTYPE(LIBRARY) ",
             " SPACE(10,10) RECFM(F B) CYLINDERS DSORG(PO) ",
             " NEW CATALOG REUSE" volume
         ADDRESS TSO "FREE  DA('"Listings"')" ;
         END;
      NEWDD = myPrefix'.SUPERC.'selectProcessor'.STEPS' ;
      NEWMBR = selectStep
      OLDMBR = selectStep
      SA= 'PROCESSING FOR *'MYMBR'*' ;
      Call Do_Superc
      END; /*  Do mbr# = 1 to Words(List_Processors)   */
   RETURN
