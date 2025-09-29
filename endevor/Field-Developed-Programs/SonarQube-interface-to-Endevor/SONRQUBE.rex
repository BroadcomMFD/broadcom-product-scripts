/*   rexx    */
  /* If wanting to limit the use of this exit, uncomment...   */
  If USERID() /= 'ibmuser' then exit

  /* If SONRQUBE is allocated to anything, turn on Trace  */
  WhatDDName = 'SONRQUBE'
  CALL BPXWDYN "INFO FI("WhatDDName")",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If RESULT = 0 then Trace r

  Arg PECB_PACKAGE_ID .

  Sa= 'You called SONRQUBE '
  /* Variable settings for each site --->           */
  WhereIam =  WHERE@M1()
  interpret 'Call' WhereIam "'MySENULibrary'"
  MySENULibrary = Result
  interpret 'Call' WhereIam "'MySEN2Library'"
  MySEN2Library = Result
  interpret 'Call' WhereIam "'MyCLS0Library'"
  MyCLS0Library = Result
  interpret 'Call' WhereIam "'MyCLS2Library'"
  MyCLS2Library = Result
  interpret 'Call' WhereIam "'MyHomeAddress'"
  MyHomeAddress = Result
  interpret 'Call' WhereIam "'AltIDAcctCode'"
  AltIDAcctCode = Result

  Message = ''
  MessageCode = '    '

  /* Interfacing with SonarQube during package CAST in Batch */
  /* Local selections here...                                */

  COBOL_Element_Types     = 'COB* CBL*'
  COBOL_Compile_StepNames = 'COMPILE COMP CMP COB'

  TransmitMethod = 'FTP'       /* **chose one ** */
  TransmitMethod = 'XCOM'      /* **chose one ** */
  Call GetUnique_Name
  SonarDSNPrefix = USERID()'.SONRQUBE.' || Unique_Name
  TransmitTable = ""

  Call Allocate_Files_For_CSV_and_API
  Elements.0 = 0
  Call ProcessPackageSCL
  If  COBOLinPackage = 'Y' then,
      Do
      Call RETRIEVE_Cobol_Elements
      Call Use_ENTBJAPI_For_BX_Info
      Call SubmitandWaitForSonarQube
      If myRC > 4 then,
         Do
         message = 'SONRQUBE -',
            'Package Failed the SonarQube Analysis'
         MyRc        = 8
         End   /* If myRC > 4 */
      Else,
         Do
         MyRc     =  4
         message = 'SONRQUBE -',
            'Package passed a SonarQube Analysis'
         message = ''
         End   /* Else        */
      End;  /* If  COBOLinPackage = 'Y'  ...  */

  Call FREE_Files_For_CSV_and_API

  Return message

GetUnique_Name:

   Unique_Name = GTUNIQUE()
   If TraceRQ = 'Y' then,
      SAY "Unique Member name is " Unique_Name

   Return

Allocate_Files_For_CSV_and_API:

   STRING = "ALLOC DD(C1MSGS1) DUMMY "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTERR) DA(*) "
   CALL BPXWDYN STRING;
   STRING = "ALLOC DD(BSTAPI) DA(*) "
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(MSGFILE) LRECL(133) BLKSIZE(26600) ",
              " DSORG(PS) ",
              " SPACE(5,5) RECFM(F,B) TRACKS ",
              " NEW UNCATALOG REUSE ";
   CALL BPXWDYN STRING;

   Return;

FREE_Files_For_CSV_and_API:

   CALL BPXWDYN STRING;
   STRING = "FREE DD(C1MSGS1)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTERR)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(BSTAPI)" ;
   CALL BPXWDYN STRING;
   STRING = "FREE DD(MSGFILE)";
   CALL BPXWDYN STRING;

   Return;

ProcessPackageSCL:

  /* Do an EXPORT to Capture the Package SCL                  */
  SonarWorkfile = SonarDSNPrefix || '.SONARWRK'
  SonarCOBOL    = SonarDSNPrefix || '.SONARCOB'

  STRING = "ALLOC DD(WRKFILE) LRECL(080) BLKSIZE(24000) ",
             " DA("SonarWorkfile") ",
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",
             " SPACE(5,5) RECFM(F,B) CYL ",
             " NEW CATALOG REUSE ";
  CALL BPXWDYN STRING;
  CALL BPXWDYN "FREE DD(WRKFILE)"

  STRING = "ALLOC DD(COBOL) LRECL(080) BLKSIZE(24000) ",
             " DA("SonarCOBOL") ",
             " DSORG(PO) DSNTYPE(LIBRARY) DIR(9) ",
             " SPACE(5,5) RECFM(F,B) CYL ",
             " NEW CATALOG REUSE ";
  CALL BPXWDYN STRING;
  CALL BPXWDYN "FREE DD(COBOL)  "

  STRING = "ALLOC DD(SCL) DA("SonarWorkfile"(SCL)) SHR REUSE"
  CALL BPXWDYN STRING;

  STRING="ALLOC DD(ENPSCLIN) DA("SonarWorkfile"(SCLEXPRT)) SHR REUSE"
  CALL BPXWDYN STRING;
  QUEUE "EXPORT PACKAGE '"PECB_PACKAGE_ID"'"
  QUEUE "    TO DDN 'SCL' ."
  "EXECIO 2 DISKW ENPSCLIN (FINIS ";   /* count queued */

  ADDRESS LINK 'ENBP1000'   ;  /* run  from CSIQAUTH*/
  call_rc = rc ;

  CALL BPXWDYN "FREE DD(ENPSCLIN)" ;

  STRING = "ALLOC DD(RESULTS) DA("SonarWorkfile"(PKGTBL)) SHR REUSE"
  CALL BPXWDYN STRING;

  /* Use SCAN#SCL to create a TABLE from the SCL content      */
  Call SCAN#SCL 'TABLE'

  CALL BPXWDYN "FREE DD(SCL)" ;

 /* Use TableTool to create multiple outputs                 */
  STRING = "ALLOC DD(TABLE) DA("SonarWorkfile"(PKGTBL)) SHR REUSE"
  CALL BPXWDYN STRING;

  STRING="ALLOC DD(PARMLIST) DA("SonarWorkfile"(PARMLST1)) SHR REUSE"
  CALL BPXWDYN STRING;
  QUEUE " NOTHING   NOTHING  OPTIONS0 0    "
  QUEUE " HEADING1  TBLOUT1  OPTIONS$ 1    "
  QUEUE " HEADING3  TBLOUT3  NOTHING  1    "
  QUEUE "   MODEL1  TBLOUT1  OPTIONS# A    "
  "EXECIO 4 DISKW PARMLIST (FINIS ";   /* count queued */

  STRING="ALLOC DD(OPTIONS0) DA("SonarWorkfile"(OPTIONS0)) SHR REUSE"
  CALL BPXWDYN STRING;
  QUEUE " $MultiplePDSmemberOuts = 'Y' /* mult PDS mbr outputs */ "
  "EXECIO 1 DISKW OPTIONS0 (FINIS ";

  STRING="ALLOC DD(OPTIONS$) DA("SonarWorkfile"(OPTIONS$)) SHR REUSE"
  CALL BPXWDYN STRING;
  ReportingPFX = USERID() || '.SONRQUBE.'Unique_Name'.RESULTS'
  myJob     = MVSVAR('SYMDEF','JOBNAME' )
  Jobname = BUMPJOB(myJob)

  QUEUE " COBOL_Element_Types     = '"COBOL_Element_Types"'"
  QUEUE " COBOL_Compile_StepNames = '"COBOL_Compile_StepNames"'"
  QUEUE " Package        = '"PECB_PACKAGE_ID"'"
  QUEUE " MyHomeAddress  = '"MyHomeAddress"'"
  QUEUE " SonarCOBOL     = '"SonarCOBOL"'"
  QUEUE " Unique_Name    = '"Unique_Name"'"
  QUEUE " AltIDAcctCode  = '"AltIDAcctCode"'"
  QUEUE " SonarWorkfile  = '"SonarWorkfile"'"
  QUEUE " MySENULibrary  = '"MySENULibrary"'"
  QUEUE " MySEN2Library  = '"MySEN2Library"'"
  QUEUE " MyCLS0Library  = '"MyCLS0Library"'"
  QUEUE " MyCLS2Library  = '"MyCLS2Library"'"
  QUEUE " TransmitMethod = '"TransmitMethod"'"
  QUEUE " ReportingPFX   = '"ReportingPFX"'"
  QUEUE " Userid         = '"USERID()"'"
  QUEUE " myJob          = '"myJob"'"
  QUEUE " Jobname        = '"Jobname"'"
  "EXECIO 17 DISKW OPTIONS$ (FINIS "; /* count queued */
  CALL BPXWDYN "ALLOC DD(NOTHING) DUMMY"

  STRING="ALLOC DD(HEADING1) DA("SonarWorkfile"(HEADING1)) SHR REUSE"
  CALL BPXWDYN STRING;
  QUEUE "  SET TO DSN '"SonarCOBOL"'."
  QUEUE "  SET OPTIONS REPLACE NO SIGNOUT. "
  "EXECIO 2 DISKW HEADING1 (FINIS ";

  STRING="ALLOC DD(MODEL1) DA("SonarWorkfile"(MODEL1)) SHR REUSE"
  CALL BPXWDYN STRING;
  QUEUE "  RETRIEVE ELEMENT &Element                             "
  QUEUE "     FROM ENVIRONMENT &Envmnt STAGE &S                  "
  QUEUE "          SYSTEM &System SUBSYSTEM &Subsys TYPE &Type . "
  "EXECIO 3 DISKW MODEL1 (FINIS ";

  STRING="ALLOC DD(OPTIONS#) DA("SonarWorkfile"(OPTIONS#)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "$NumberModelsAndTblouts= 3                               "
  Queue "HaveCobol = 0                                            "
  Queue "Do w# = 1 to Words(COBOL_Element_Types) ; +              "
  Queue "   HaveCobol=QMATCH(Type Word(COBOL_Element_Types,w#)); +"
  Queue "   If HaveCobol = 1 then Do; $my_rc = 1; Leave; End; +   "
  Queue "End;                                                     "
  Queue "If HaveCobol = 0 then $SkipRow='Y'                       "
  Queue "AEELM= COPIES(' ',80);                                   "
  Queue "AEELM= Overlay('AEELMBC ',AEELM,1) ;                     "
  Queue "AEELM= Overlay(Envmnt,AEELM,10) ;     /* Env      */     "
  Queue "AEELM= Overlay(S,AEELM,18) ;          /* stg id   */     "
  Queue "AEELM= Overlay(System,AEELM,19) ;     /* Sys      */     "
  Queue "AEELM= Overlay(Subsys,AEELM,27) ;     /* Sub      */     "
  Queue "AEELM= Overlay(Element,AEELM,35) ;    /* Ele      */     "
  Queue "AEELM= Overlay(Type,AEELM,45);        /* Typ      */     "
  Queue "*                                                        "
  Queue "Element = Left(Element,08)                               "
  "EXECIO 17 DISKW OPTIONS# (FINIS "; /* count queued */

  STRING="ALLOC DD(MODEL2) DA("SonarWorkfile"(MODEL2)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "AACTL MSGFILE COMPLIST                                   "
  Queue "&AEELM                                                   "
  Queue "RUN                                                      "
  "EXECIO 3 DISKW MODEL2 (FINIS ";

  STRING="ALLOC DD(HEADING3) DA("SonarWorkfile"(HEADING3)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "* Folder-- Member--  ",
        "Dataset------------------------------------- "
  "EXECIO 1 DISKW HEADING3 (FINIS ";

  STRING="ALLOC DD(MODEL3) DA("SonarWorkfile"(MODEL3)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "  COBOL    &Element   &SonarCOBOL "
  "EXECIO 1 DISKW MODEL3 (FINIS ";

  STRING="ALLOC DD(TRAILER2) DA("SonarWorkfile"(TRAILER2)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "AACTLY  "
  Queue "RUN     "
  Queue "QUIT    "
  "EXECIO 3 DISKW TRAILER2 (FINIS ";

  STRING="ALLOC DD(TBLOUT1) DA("SonarWorkfile"(RETRIEVE)) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(TBLOUT2) DA("SonarWorkfile"(AEELMBC)) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(TBLOUT3) DA("SonarWorkfile"(TRANSMIT)) SHR REUSE"
  CALL BPXWDYN STRING;

  If TraceRQ = 'Y' then Trace R
  myRC = ENBPIU00("PARMLIST")
  If myRC = 1 then COBOLinPackage = 'Y'

  CALL BPXWDYN "FREE DD(SCL)     " ;
  CALL BPXWDYN "FREE DD(ENPSCLIN)" ;
  CALL BPXWDYN "FREE DD(RESULTS) " ;

  CALL BPXWDYN "FREE DD(TABLE)   " ;
  CALL BPXWDYN "FREE DD(PARMLIST)" ;
  CALL BPXWDYN "FREE DD(OPTIONS$) " ;
  CALL BPXWDYN "FREE DD(NOTHING) " ;
  CALL BPXWDYN "FREE DD(HEADING1)" ;
  CALL BPXWDYN "FREE DD(MODEL1)  " ;
  CALL BPXWDYN "FREE DD(OPTIONS#)" ;
  CALL BPXWDYN "FREE DD(OPTIONS$)" ;
  CALL BPXWDYN "FREE DD(MODEL2)  " ;
  CALL BPXWDYN "FREE DD(HEADING3)" ;
  CALL BPXWDYN "FREE DD(MODEL3)  " ;
  CALL BPXWDYN "FREE DD(TRAILER2)" ;
  CALL BPXWDYN "FREE DD(TBLOUT1) " ;
  CALL BPXWDYN "FREE DD(TBLOUT2) " ;
  CALL BPXWDYN "FREE DD(TBLOUT3) " ;

  RETURN ;

RETRIEVE_Cobol_Elements:

  STRING="ALLOC DD(BSTIPT01) DA("SonarWorkfile"(RETRIEVE)) SHR REUSE"
  CALL BPXWDYN STRING;

  ADDRESS LINK 'C1BM3000'

  RETURN ;

Use_ENTBJAPI_For_BX_Info:

  /*    See your CSIQJCL(BC1JAAPI)                                  */
  /*    V - COLUMN 6 = FORMAT SETTING                               */
  /*      = ' ' FOR NO FORMAT, JUST EXTRACT ELEMENT                 */
  /*      = 'B' FOR ENDEVOR BROWSE DISPLAY FORMAT                   */
  /*      = 'C' FOR ENDEVOR CHANGE DISPLAY FORMAT                   */
  /*      = 'H' FOR ENDEVOR HISTORY DISPLAY FORMAT                  */
  /*    V - COLUMN 7 = Replay TYPE SETTING                          */
  /*      = 'E' FOR ELEMENT                                         */
  /*      = 'C' FOR COMPONENT                                       */
  /*       VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                 */
  /*               V - COLUMN 18 = STAGE ID                         */
  /*                VVVVVVVV - COLUMN 19-26 SYSTEM NAME             */
  /*                        VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME  */
  /*   COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                      */
  /*   COLUMN 45-52 = TYPE NAME               VVVVVVVV              */
  /*                                                                */

  Sa= 'Use_ENTBJAPI_For_BX_Info'

  STRING="ALLOC DD(SYSIN) DA("SonarWorkfile"(AEELMBC)) SHR REUSE"
  CALL BPXWDYN STRING;


  STRING = "ALLOC DD(COMPLIST) LRECL(200) BLKSIZE(20000) ",
             " DSORG(PS) ",
             " SPACE(5,15) RECFM(F,B) TRACKS ",
             " MOD UNCATALOG REUSE ";
  CALL BPXWDYN STRING;

  /* Call Built-in API program for COBOL source extracts  */
  /* and COBOL component List requests.                   */
  ADDRESS LINK "ENTBJAPI"

  CALL BPXWDYN "FREE DD(SYSIN)  "

  "EXECIO * DISKR COMPLIST (Stem cmplist. FINIS ";
  CALL BPXWDYN "FREE DD(COMPLIST)"

  sa= cmplist.0
  If  cmplist.0 = 0 then Return;

  Call ProcessCopybookMembers;
  Call UpdateSonarTransmitTable;
  Drop element.

  RETURN ;

ProcessCopybookMembers:

   Do rec# = 1 to cmplist.0
      complist   = Substr(cmplist.rec#,73)
      If Substr(complist,1,22) = Copies('-',22) then,
         thisSection = Word(complist,2)
      If thisSection /= 'INPUT' then iterate;
      If Word(complist,1) = 'STEP:' then,
         Do
         StepName    = Word(complist,2)
         DDname      = Substr(Word(complist,3),4)
         DatasetName = Substr(Word(complist,5),5)
         Iterate
         End
      If Substr(Word(complist,5),3,1) = ':' &,
         WordPos(StepName,COBOL_Compile_StepNames) > 0 &,
         DDname  = 'SYSLIB'     then,
         Do
         member = Word(complist,2)
         entry = "COPYBOOK,"member","DatasetName
         If Wordpos(entry,TransmitTable) = 0 then,
         TransmitTable = TransmitTable entry
         End
   End;  /* Do rec# = 1 to cmplist.0 */

  RETURN ;

UpdateSonarTransmitTable:

  STRING =,
     "ALLOC DD(SONARXMT) DA("SonarWorkfile"(TRANSMIT)) SHR REUSE"
  CALL BPXWDYN STRING;
  "Execio * DISKR SONARXMT (Stem xmit. Finis"
  xm# = xmit.0

  Do w# = 1 to Words(TransmitTable)
     xm# = xm# + 1
     transtable = Word(TransmitTable,w#)
     Parse var transtable folder ',' member ',' dataset
     entry = " " left(folder,8) left(member,10) dataset
     xmit.xm# = entry
  End; /*  Do w# = 1 to Words(TransmitTable) */

  "Execio * DISKW SONARXMT (Stem xmit. Finis"

  transtable = ""
  RETURN ;

SubmitandWaitForSonarQube:

  /* Allocate files for a TableTool driven submission of the
     SonarQube job, and a series of waits for parts of the job
     to complete.
     A TABLE TOOL step running with the PARMLIST option
     (see PARMLST2 in the SonarWorkfile)
     orchestrates the submission of the SONARJOB and the
     the wait steps for the job completion.
  */

  STRING="ALLOC DD(SETUP) DA("SonarWorkfile"(OPTIONS$)) SHR REUSE"
  CALL BPXWDYN STRING;

  STRING="ALLOC DD(PARMLIST) DA("SonarWorkfile"(PARMLST2)) SHR REUSE"
  CALL BPXWDYN STRING;
  Queue "NOTHING  NOTHING  SETUP   0"
  Queue "MDL#JOB  "TransmitMethod"#JOB NOTHING 1"
  Queue "MDL#RCV  "TransmitMethod"#RCV NOTHING 1"
  Queue "MDL#RUN  "TransmitMethod"#RUN NOTHING 1"
  Queue "MODEL4   TBLOUT   NOTHING 1"
  Queue "TBLOUT   READER   NOTHING 1"
  Queue "NOTHING  REPORT   WAIT#1  1"
  Queue "NOTHING  REPORT   WAIT#2  1"
  Queue "NOTHING  REPORT   WAIT#3  1"
  "EXECIO 9 DISKW PARMLIST (FINIS ";

  STRING="ALLOC DD(MDL#JOB) ",
         "DA("MySEN2Library"("TransmitMethod"#JOB) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(MDL#RCV) ",
         "DA("MySEN2Library"("TransmitMethod"#RCV) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(MDL#RUN) ",
         "DA("MySEN2Library"("TransmitMethod"#RUN) SHR REUSE"
  CALL BPXWDYN STRING;

  STRING="ALLOC DD("TransmitMethod"#JOB) ",
         "DA("SonarWorkfile"("TransmitMethod"#JOB) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD("TransmitMethod"#RCV) ",
         "DA("SonarWorkfile"("TransmitMethod"#RCV) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD("TransmitMethod"#RUN) ",
         "DA("SonarWorkfile"("TransmitMethod"#RUN) SHR REUSE"
  CALL BPXWDYN STRING;

  STRING = "ALLOC DD(READER) SYSOUT(A) WRITER(INTRDR) REUSE " ;
  CALL BPXWDYN STRING;

  /* Replicate the next several files for improved visibility */
  STRING="ALLOC DD(TEMP#1)   DA("MySEN2Library"(SONARW#1)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKR TEMP#1 (Stem wait. Finis"
  CALL BPXWDYN "FREE DD(TEMP#1) "
  STRING="ALLOC DD(WAIT#1)   DA("SonarWorkfile"(WAIT#1)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKW WAIT#1 (Stem wait. Finis"

  Drop wait.
  STRING="ALLOC DD(TEMP#2)   DA("MySEN2Library"(SONARW#2)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKR TEMP#2 (Stem wait. Finis"
  CALL BPXWDYN "FREE DD(TEMP#2) "
  STRING="ALLOC DD(WAIT#2)   DA("SonarWorkfile"(WAIT#2)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKW WAIT#2 (Stem wait. Finis"

  Drop wait.
  STRING="ALLOC DD(TEMP#3)   DA("MySEN2Library"(SONARW#3)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKR TEMP#3 (Stem wait. Finis"
  CALL BPXWDYN "FREE DD(TEMP#3) "
  STRING="ALLOC DD(WAIT#3)   DA("SonarWorkfile"(WAIT#3)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKW WAIT#3 (Stem wait. Finis"

  STRING="ALLOC DD(TEMPMD)   DA("MySEN2Library"(SONARMDL)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKR TEMPMD (Stem mdl.  Finis"
  CALL BPXWDYN "FREE DD(TEMPMD) "
  STRING="ALLOC DD(MODEL4)   DA("SonarWorkfile"(MODEL4)) SHR REUSE"
  CALL BPXWDYN STRING;
  "EXECIO * DISKW MODEL4 (Stem mdl.  Finis"

  STRING="ALLOC DD(TABLE)    DA("MySEN2Library"(SONARTBL)) SHR REUSE"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(NOTHING)  DUMMY"
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(SYSTSPRT) SYSOUT(A) "
  CALL BPXWDYN STRING;
  STRING="ALLOC DD(REPORT)   SYSOUT(A) "
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(TBLOUT) DA("SonarWorkfile"(SONARJOB) SHR REUSE"
  CALL BPXWDYN STRING;

  /* The next statement does the submit and wait */
  myRC = ENBPIU00("PARMLIST")

  CALL BPXWDYN "FREE DD(REPORT)   "
  CALL BPXWDYN "FREE DD(PARMLIST)"
  CALL BPXWDYN "FREE DD(SETUP) "
  CALL BPXWDYN "FREE DD(WAIT#1)   "
  CALL BPXWDYN "FREE DD(WAIT#2)   "
  CALL BPXWDYN "FREE DD(WAIT#3)   "
  CALL BPXWDYN "FREE DD(MODEL4)   "
  CALL BPXWDYN "FREE DD(TABLE)    "
  CALL BPXWDYN "FREE DD(NOTHING) "
  CALL BPXWDYN "FREE DD(SYSTSPRT)"
  CALL BPXWDYN "FREE DD(TBLOUT)   "

  If myRC = 11 then,
     message = 'SONRQUBE - could not submit the SonarQube job'
  If myRC = 12 then,
     message = 'SONRQUBE - File transmissions failed         '
  If myRC = 13 then,
     message = 'SONRQUBE - could not initiate SonarQube',
               ' analysis'

  If myRC < 8 then,
     Do
     STRING="ALLOC DD(RESULTS)",
            " DA("SonarWorkfile".RESULTS) SHR REUSE"
     CALL BPXWDYN STRING;
     "Execio * DISKR RESULTS (Stem rslt. Finis"
     CALL BPXWDYN "FREE  DD(RESULTS)"
     lastline# = rslt.0
     lastline = rslt.lastline#
     If Pos('Status: SUCCESS ',lastline) = 0 then myRc= 8
     End   /* If myRC < 8 */

  RETURN ;

