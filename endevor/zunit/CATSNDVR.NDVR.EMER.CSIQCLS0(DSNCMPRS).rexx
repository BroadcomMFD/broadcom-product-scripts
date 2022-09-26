/*   REXX  ZUNIT Compress/Expand    */
   TRACE OFF;

   /* Compress a list of datasets from MyHLQ into a single output */
   /*    - or -                                                   */
   /* Expand a compressed output into a new set of MyHLQ files.   */

   /* If DSNCMPRS is found allocated to anything, turn on Trace */
   WhatDDName = 'DSNCMPRS'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) /= ' ' then TraceRC = 1
   If TraceRC = 1  then Trace R

   /* Get and validate run-time values from OPTIONS dd in JCL   */
   Call CaptureAndValidateOPTIONS;

   If TraceRC = 1  then Trace Off
   /* Compress a list of datasets into a single output          */
   If Action = 'COMPRESS' then,
      Do
      SearchValue  = MyHLQ
      ReplaceValue ='&MyHLQ'
      /* Call IDCAMS listCat to obtain a list of datasets */
      Call ListCat_Datasets_For_Compress ;

      /* Read ListCat Results                             */
      "EXECIO * DISKR SYSPRINT (STEM DSNS. FINIS"

      /* These help with selecting mbrs assoc wi TestCase */
      TestCaseMbrs. = ""
      TestCaseNode = 'UNKNOWN' ; /* Replaced by AZUGEN content */
      TestCaseLastNodes = ''

      /* Search through datasets list for AZUGEN          */
      If TestCase /= '*' then,
         Call Find_AZUGEN_Dataset;

      /* Call IDCAMS listCat to obtain a list of datasets */
      Call Compress_Datasets ;
      End ; /* If Action = 'COMPRESS' */
   Else, /* Expand a compressed output into a new set of files.  */
   If Action = 'EXPAND' then,
      Do
      If TraceRC = 1  then Trace R
      SearchValue  ='&MyHLQ'
      ReplaceValue = MyHLQ
      Call ExpandInputFile;
      End ; /* If Action = 'EXPAND'   */
   Else,
      Do
      Say "Action must be 'COMPRESS' or 'EXPAND'" ;
      Exit(12)
      End ; /* Else....               */

   Exit

CaptureAndValidateOPTIONS:

   /* Set default values for parameters         */
   MAXLR = 32000
   VOL = ''
   Action = ''
   TestCaseMembers=""
   VolSer=""
   MaxRecordsize=1200
   MyHLQ  = ''
   InpOutputDsn  = ''

   /* Collect run-time parameters from OPTIONS dd in JCL    */
   /* Action TestCaseMembers VolSer MaxRecordsize MyHLQ     */
   /* InpOutputDsn ....                                     */
   "EXECIO * DISKR OPTIONS  (STEM Opts. FINIS"
   Do o# = 1 to Opts.0
      nextparm = Opts.o# ;
      say       nextparm;
      Interpret nextparm;
   End;

   If Wordpos(Action,'COMPRESS EXPAND') = 0 then,
      Do
      Say 'Action must be either COMPRESS/EXPAND'
      exit(12)
      End
   If MyHLQ  = ''          then,
      Do
      Say 'A high level qualifier must be assigned to MyHLQ'
      exit(12)
      End
   If InpOutputDsn  = ''   then,
      Do
      Say 'A dataset name must be assigned to InpOutputDsn'
      exit(12)
      End
   If Action = 'COMPRESS' & TestCaseMembers=""   then,
      Do
      Say "No Test Cases are specified. Assuming '*'. "
      TestCaseMembers="*"
      End

   TestCase = Word(TestCaseMembers,1)

   Return

Find_AZUGEN_Dataset:

   /* Read thru list of datasets and find AZUGEN last node  */
   If TraceRC = 1  then Say "@ Find_AZUGEN_Dataset"

   Do dsn# = 1 to DSNS.0
      record = DSNS.dsn#
      If Substr(record,2,7) /= 'NONVSAM' then Iterate;
      Dataset = Word(Substr(record,17),1)

      /* Get last node of Dataset name         */
      tempdsn = Translate(Dataset,' ','.')
      LastNode = Word(tempdsn,Words(tempdsn))
      If LastNode /= 'AZUGEN' then iterate;
      Leave;
   End;

   If LastNode /= 'AZUGEN' then,
      Do
      Say 'Cannot find AZUGEN dataset'
      Exit(12)
      End

   If TraceRC = 1  then Trace R
   DSNCHECK = SYSDSN("'"Dataset"("TestCase")'")
   IF DSNCHECK /= 'OK' THEN,
      Do
      Say 'Cannot find Test Case member',
           "'"Dataset"("TestCase")'"
      Exit(12)
      End

   TestCaseMbrs.AZUGEN = TestCaseMembers
   TestCaseMbrs.AZUCFG = TestCaseMembers
   TestCaseLastNodes = 'AZUGEN AZUCFG'

   "ALLOC F(AZUGEN) DA('"Dataset"("TestCase")') SHR"
   "EXECIO * DISKR AZUGEN (Stem azu. Finis"
   "FREE  F(AZUGEN)"
   If TraceRC = 1  then Trace Off

   /* Concatenate all records into one long Ascii String */
   AsiiString = ""
   Do az# = 1 to azu.0
      AsiiString = AsiiString || azu.az#
   End;

   /* Prepare to use Ascii2Ebcdic tables for conversion  */
   Call LoadConversionTables;
   Call Convert2Ebcdic ; /* AsiiString -> EbcdicString */

   /* Scan EbcdicString for fileName & fileContainer     */
   /* references to find mbrs related to Test Case       */
   Call IdentifyTestCaseItems; /* Using   EbcdicString */

   Return

Compress_Datasets :
   /* Initialize default output dataset values         */
   If TraceRC = 1  then Say "@ Compress_Datasets"
   CompressLrecl = 80 ;
   TotalCyls = 0

   /* Read thru list of datasets and                   */
   /*   1) insert a dataset delmiter with attributes   */
   /*   2) insert member delimiters and contents       */
   Do dsn# = 1 to DSNS.0
      record = DSNS.dsn#
      If Substr(record,2,7) /= 'NONVSAM' then Iterate;
      If TraceRC = 1 then Trace R
      Dataset = Word(Substr(record,17),1)
      temp = LISTDSI("'"Dataset"'" RECALL DIRECTORY)
/*    Get Dataset Attributes                                 */
      recfm = Strip(SYSRECFM)
      If recfm = 'U' then Iterate;
      lrecl = Strip(SYSLRECL)
      if SYSLRECL > CompressLrecl then,
         CompressLrecl = SYSLRECL
      blksz = Strip(SYSBLKSIZE)
      dsorg = Strip(SYSDSORG)
      dirblks = Strip(SYSADIRBLK)
      primary= Strip(SYSPRIMARY)
      Scndary= Strip(SYSSECONDS)
      dsntype= Strip(SYSDSSMS)
      TotalCyls = TotalCyls + primary + (SYSEXTENTS-1)*Scndary
      If TraceRC = 1 then Trace OFf
      ReplaceRec =,
        './ Dataset=',
            Dataset recfm lrecl blksz dsorg,
                    primary Scndary dsntype dirblks
      WhereFound = pos(SearchValue,ReplaceRec)
      Call Replace_SearchValue
      Queue Replaced_rec
      If dsorg = 'PS' then Call Compress_Sequential_Dataset;
      Else                 Call Compress_PDS_Dataset_Members ;

   End;

   /* To account for size fields and increase due to encryption
      Increase the Lrecl size and calculate Blksize   */
   say = CompressLrecl  MAXLR
   CompressLrecl = Min(MAXLR,CompressLrecl+4) ;
   howmanyLrelcs = 32000 % CompressLrecl
   MaximumBlksz = howmanyLrelcs * CompressLrecl

   If TraceRC = 1  then Trace R
   InpOutputDsn = Strip(InpOutputDsn)
   primary   = MAX(1,(TotalCyls % 2))
   Scndary   = primary
   volume    =''
   If Length(VOL) > 2 then,
      volume = "VOLUME("VOL")"

   "ALLOC F(OUTPUT) LRECL("CompressLrecl")",
        "DA('"InpOutputDsn"')",
        "BLKSIZE("MaximumBlksz") SPACE("primary","Scndary")",
        "RECFM(V B) CYLINDERS DSORG(PS) ",
        "NEW CATALOG REUSE" volume

   "EXECIO" QUEUED() "DISKW OUTPUT   ( FINIS"
   "FREE  F(OUTPUT) "
   If TraceRC = 1  then Trace Off
   Return

ListCat_Datasets_For_Compress :

   If TraceRC = 1  then Say "@ ListCat_Datasets_For_Compress "
   Queue " LISTCAT LEVEL('"MyHLQ"') NAME "
   "EXECIO 1 DISKW SYSIN    ( FINIS"

   ADDRESS LINK 'IDCAMS'
   MyRC =RC

   Return;

Compress_Sequential_Dataset:

   If TraceRC = 1  then Say "@ Compress_Sequential_Dataset"
   If TraceRC = 1 then Trace R
   Sa= Dataset "-" dsorg
   Drop seq.
   "ALLOC F(SEQDSN) DA('"Dataset"') SHR"
   "EXECIO * DISKR SEQDSN (Stem seq. Finis"
   "FREE  F(SEQDSN)"
   If TraceRC = 1 then Trace OFf
   Do rec# = 1 to seq.0
      ReplaceRec = seq.rec#
      WhereFound = pos(SearchValue,ReplaceRec)
      reclen = Length(ReplaceRec)
      If WhereFound > 0 then,
         Do Forever
            Call Replace_SearchValue
            reclen = Length(Replaced_rec)
            seq.rec# = Replaced_rec
            WhereFound = pos(SearchValue,seq.rec#)
            If WhereFound = 0 then Leave;
         End; /* Do While WhereFound > 0 */
      If recfm = 'FB' then reclen = lrecl;
      CharString = seq.rec#
      Call Encrypt;
   /* Queue reclen || EncryptString */
      Call Write_Compress_rec; /* EncryptString for reclen */
   End; /* Do rec# = 1 to seq.0  */

   Return;

Compress_PDS_Dataset_Members:

   If TraceRC = 1  then Say "@ Compress_PDS_Dataset_Members"
   Drop Members.
   Drop mbr.
   GotMember = 'N'

   If TraceRC = 1  then Trace r
   /* Get last node of Dataset name         */
   tempdsn = Translate(Dataset,' ','.')
   LastNode = Word(tempdsn,Words(tempdsn))
   If TraceRC = 1  then Trace Off

   /* Write member delimiter and member content to output */
   X = OUTTRAP(Members.);
   "LISTDS '"Dataset"' MEMBERS"
   Do mbr# = 1 to Members.0
      MemberListed = Members.mbr#
      If Word(MemberListed,1) = '--MEMBERS--' then,
         Do
         GotMember = 'Y'
         Iterate
         End ; /* If Word(MemberListed,1) = '--MEMBERS--' */
      If GotMember /= 'Y' |,
         Substr(MemberListed,1,2) /= '  ' then Iterate ;
      If TraceRC = 1 then Trace r
      member = Word(MemberListed,1) ;
      sa= LastNode
      sa= TestCaseMbrs.LastNode
      sa= Wordpos(member,TestCaseMbrs.LastNode)
      If TestCase = '*' |,
         Wordpos(member,TestCaseMbrs.LastNode) > 0 then NOP;
      Else,
      If Wordpos(LastNode,TestCaseLastNodes) = 0 &,
         Wordpos(member,TestCaseMembers) > 0 then NOP;
      Else,
         Do
         Say Dataset"("member")",
             'not selected by TestCase' TestCase
         If TraceRC = 1 then Trace Off
         Iterate;
         End
      Say Dataset"("member")",
          'is  selected by TestCase' TestCase
      If TraceRC = 1 then Trace Off
      Queue './  ADD  NAME='member
      "ALLOC F(MEMBER) DA('"Dataset"("member")') SHR"
      Drop mbr.
      Drop rec# reclen
      WhereFound = 0
      "EXECIO * DISKR MEMBER (Stem mbr. Finis"
      Do rec# = 1 to mbr.0
         ReplaceRec = mbr.rec#
         If TraceRC = 1 then,
            Say Dataset"("member")" rec#
         reclen = Length(ReplaceRec)
         WhereFound = pos(SearchValue,ReplaceRec)
         If WhereFound > 0 then,
            Do Forever
               Call Replace_SearchValue
               mbr.rec# = Replaced_rec
               reclen = Length(Replaced_rec)
               WhereFound = pos(SearchValue,mbr.rec#)
               If WhereFound = 0 then Leave;
            End; /* Do While WhereFound > 0 */
         If recfm = 'FB' then reclen = lrecl;
         CharString = mbr.rec#
         Call Encrypt;
      /* Queue reclen || EncryptString */
         Call Write_Compress_rec; /* EncryptString for reclen */
      End; /* Do rec# = 1 to mbr.0  */
      "FREE  F(MEMBER)"
   End /* Do mbr# = 1 to Members.0 */
   X = OUTTRAP(OFF);

   Return;

Replace_SearchValue:
   If TraceRC = 1  then Say "@ Replace_SearchValue"
   sa=  ReplaceRec
   sa=  SearchValue ReplaceValue WhereFound
   Replaced_rec = ''
   If WhereFound > 1 then,
      Replaced_rec = Substr(ReplaceRec,1,(WhereFound - 1)) ;
   Replaced_rec = Replaced_rec || ReplaceValue
   Replaced_rec =,
     Replaced_rec ||Substr(ReplaceRec,(WhereFound +Length(SearchValue)))
   Trace Off
   Return;

ExpandInputFile:

   If TraceRC = 1  then Say "@ ExpandInputFile"
   Trace off
   /* Read the named INPUT file - COMPRESSED */
   temp = LISTDSI("'"InpOutputDsn"'" RECALL DIRECTORY)
   MAXLR    = Strip(SYSLRECL)
   "ALLOC F(INPUT) DA('"InpOutputDsn"') SHR"

   "EXECIO * DISKR INPUT (STEM Inp. FINIS"

   "FREE  F(INPUT)"

   Do inp# = 1 to Inp.0
      inprec = Inp.inp#
      If Substr(inprec,1,04) = '0000' then Iterate;
      If Substr(inprec,1,11) = './ Dataset=' then,
         Do
         ReplaceRec = inprec
         WhereFound = pos(SearchValue,ReplaceRec)
         Call Replace_SearchValue
         inprec = Replaced_rec
         Dataset = Word(inprec,3)
         recfm   = Word(inprec,4)
         new_recfm= ''
         Do ltr# = 1 to Length(recfm)
            new_recfm = new_recfm Substr(recfm,ltr#,1)
         End
         lrecl   = Word(inprec,5)
         blksz   = Word(inprec,6)
         dsorg   = Word(inprec,7)
         primary = Word(inprec,8)
         Scndary = Word(inprec,9)
         dsntype = Word(inprec,10)
         If dsntype = 'PDSE' then dsntype = 'LIBRARY'
         If dsntype = 'LIBRARY' | dsntype = 'PDS' then,
            myDsntype = "DSNTYPE("dsntype")"
         Else,
            myDsntype = ""

         dirblks = ''
         if Words(inprec) > 9 & dsorg = 'PO' then,
            Do
            dirblks = Word(inprec,11)
            $Numbers   = '0123456789' ;
            $rslt =  VERIFY(dirblks,$Numbers)
            if $rslt > 0 then dirblks = 01
            dirblks = MAX(11,dirblks)
            dirblks = "DIR("dirblks")"
            End
         volume    =''
         If Length(VOL) > 2 then,
            volume = "VOLUME("VOL")"


         "ALLOC F(NEWDATA) DA('"Dataset"') LRECL("lrecl")",
                "BLKSIZE("blksz") SPACE("primary","Scndary")",
                "RECFM("new_recfm") CYLINDERS DSORG("dsorg") ",
                "NEW CATALOG REUSE" volume dirblks myDsntype

         If dsorg = 'PS' then,
            Do
            nextinp# = inp#+1
            Do Forever
               Call GetEncryptedString;  /* 1 or more records */
               Call Decrypt
               ReplaceRec    = CharString
               WhereFound = pos(SearchValue,ReplaceRec)
               If WhereFound > 0 then,
                  Do
                  Call Replace_SearchValue
                  ReplaceRec = Replaced_rec
            /*    reclen = Length(ReplaceRec) */
                  End
               If recfm = 'FB' then reclen = lrecl
               Queue Substr(ReplaceRec,1,reclen)
               nextinp# = nextinp# + 1
               If nextinp# > Inp.0 |,
                  Substr(Inp.nextinp#,1,2) = './' then,
                  Leave ;
            End; /* Do Forever */
            "EXECIO" QUEUED() "DISKW NEWDATA (Finis"
            If Substr(Inp.nextinp#,1,2) = './' then,
               inp# = nextinp# - 1;
            End /* If dsorg = 'PS' */

         "FREE F(NEWDATA)"

         End /* If Substr(inprec,1,11) = './ Dataset=' */
      Else,
      If Substr(inprec,1,14) = './  ADD  NAME=' then,
         Do
         member = Word(Substr(inprec,15),1) ;
         "ALLOC F(NEWMBR) DA('"Dataset"("member")') SHR"
         nextinp# = inp#+1
         Do Forever
            Call GetEncryptedString;  /* 1 or more records */
            Call Decrypt
            ReplaceRec    = CharString
            WhereFound = pos(SearchValue,ReplaceRec)
            If WhereFound > 0 then,
               Do
               Call Replace_SearchValue
               ReplaceRec = Replaced_rec
               End
            If recfm = 'FB' then reclen = lrecl
            Queue Substr(ReplaceRec,1,reclen)
            nextinp# = nextinp# + 1
            If nextinp# > Inp.0 |,
               Substr(Inp.nextinp#,1,2) = './' then,
                  Leave ;
         End; /* Do Forever */
         "EXECIO" QUEUED() "DISKW NEWMBR (Finis"
         "FREE  F(NEWMBR)"
         If Substr(Inp.nextinp#,1,2) = './' then,
            inp#  = nextinp# - 1
         End; /* If Substr(inprec,1,14) = './  ADD  NAME=' */
   End; /* Do inp# = 1 to Inp.0  */

   Return;



LoadConversionTables:

   If TraceRC = 1  then Say "@ LoadConversionTables"
   Ascii2Ebcdic.   = '?';
   Ascii2Ebcdic.61 = 'a';
   Ascii2Ebcdic.62 = 'b';
   Ascii2Ebcdic.63 = 'c';
   Ascii2Ebcdic.64 = 'd';
   Ascii2Ebcdic.65 = 'e';
   Ascii2Ebcdic.66 = 'f';
   Ascii2Ebcdic.67 = 'g';
   Ascii2Ebcdic.68 = 'h';
   Ascii2Ebcdic.69 = 'i';
   Ascii2Ebcdic.6A = 'j';
   Ascii2Ebcdic.6B = 'k';
   Ascii2Ebcdic.6C = 'l';
   Ascii2Ebcdic.6D = 'm';
   Ascii2Ebcdic.6E = 'n';
   Ascii2Ebcdic.6F = 'o';
   Ascii2Ebcdic.70 = 'p';
   Ascii2Ebcdic.71 = 'q';
   Ascii2Ebcdic.72 = 'r';
   Ascii2Ebcdic.73 = 's';
   Ascii2Ebcdic.74 = 't';
   Ascii2Ebcdic.75 = 'u';
   Ascii2Ebcdic.76 = 'v';
   Ascii2Ebcdic.77 = 'w';
   Ascii2Ebcdic.78 = 'x';
   Ascii2Ebcdic.79 = 'y';
   Ascii2Ebcdic.7A = 'z';
   Ascii2Ebcdic.41 = 'A';
   Ascii2Ebcdic.42 = 'B';
   Ascii2Ebcdic.43 = 'C';
   Ascii2Ebcdic.44 = 'D';
   Ascii2Ebcdic.45 = 'E';
   Ascii2Ebcdic.46 = 'F';
   Ascii2Ebcdic.47 = 'G';
   Ascii2Ebcdic.48 = 'H';
   Ascii2Ebcdic.49 = 'I';
   Ascii2Ebcdic.4A = 'J';
   Ascii2Ebcdic.4B = 'K';
   Ascii2Ebcdic.4C = 'L';
   Ascii2Ebcdic.4D = 'M';
   Ascii2Ebcdic.4E = 'N';
   Ascii2Ebcdic.4F = 'O';
   Ascii2Ebcdic.50 = 'P';
   Ascii2Ebcdic.51 = 'Q';
   Ascii2Ebcdic.52 = 'R';
   Ascii2Ebcdic.53 = 'S';
   Ascii2Ebcdic.54 = 'T';
   Ascii2Ebcdic.55 = 'U';
   Ascii2Ebcdic.56 = 'V';
   Ascii2Ebcdic.57 = 'W';
   Ascii2Ebcdic.58 = 'X';
   Ascii2Ebcdic.59 = 'Y';
   Ascii2Ebcdic.5A = 'Z';
   Ascii2Ebcdic.20 = ' ';
   Ascii2Ebcdic.31 = '1';
   Ascii2Ebcdic.32 = '2';
   Ascii2Ebcdic.33 = '3';
   Ascii2Ebcdic.34 = '4';
   Ascii2Ebcdic.35 = '5';
   Ascii2Ebcdic.36 = '6';
   Ascii2Ebcdic.37 = '7';
   Ascii2Ebcdic.38 = '8';
   Ascii2Ebcdic.39 = '9';
   Ascii2Ebcdic.30 = '0';
   Ascii2Ebcdic.40 = '@';
   Ascii2Ebcdic.23 = '#';
   Ascii2Ebcdic.24 = '$';
   Ascii2Ebcdic.3C = '<';
   Ascii2Ebcdic.3E = '>';
   Ascii2Ebcdic.2F = '/';
   Ascii2Ebcdic.22 = '"';
   Ascii2Ebcdic.26 = '&';
   Ascii2Ebcdic.2E = '.';
   Ascii2Ebcdic.2C = ',';
   Ascii2Ebcdic.3A = ':';
   Ascii2Ebcdic.2F = '/';
   Ascii2Ebcdic.5C = '\';
   Ascii2Ebcdic.28 = '(';
   Ascii2Ebcdic.29 = ')';
   Ascii2Ebcdic.3D = '=';
   Ascii2Ebcdic.7B = '{';
   Ascii2Ebcdic.7D = '}';
   Ascii2Ebcdic.2D = '-';
   Ascii2Ebcdic.5F = '_';

   Return;

Convert2Ebcdic:

   If TraceRC = 1  then Say "@ Convert2Ebcdic"
   EbcdicString = ''
   Do ch# = 1 to length(AsiiString)
      char = Substr(AsiiString,ch#,1)
      charindex = C2X(char)
      EbcdicString = EbcdicString || Ascii2Ebcdic.charindex
   End;
   If TraceRC = 1  then,
      Sa= "EbcdicString =" EbcdicString
   Return;

IdentifyTestCaseItems:

   If TraceRC = 1  then Say "@ IdentifyTestCaseItems"

   DO FOREVER
      PARSE VAR EbcdicString 'fileName="' TestCaseMbr '"' EbcdicString
      TestCaseMbr = STRIP(TestCaseMbr) ;
      TestCaseMbr = STRIP(TestCaseMbr,B,'"');
      If Wordpos(TestCaseMbr,TestCaseMembers) = 0 then,
         TestCaseMembers = TestCaseMembers TestCaseMbr;
      SA= "TestCaseMbr=" TestCaseMbr ;
      EbcdicString = Strip(EbcdicString,'L')
      If Substr(EbcdicString,1,15) = 'fileContainer="' then,
         Do
         PARSE VAR EbcdicString 'fileContainer="',
               TestCaseDsn '"' EbcdicString ;
         tempdsn = Translate(TestCaseDsn,' ','.')
         TestCaseNode = Word(tempdsn,Words(tempdsn))
         If Wordpos(TestCaseNode,TestCaseLastNodes) = 0 then,
            TestCaseLastNodes = TestCaseLastNodes TestCaseNode
         End
      TestCaseMbrs.TestCaseNode = TestCaseMbrs.TestCaseNode TestCaseMbr
      If TraceRC = 1  then,
         Say 'TestCaseMbrs.'TestCaseNode '=' TestCaseMbrs.TestCaseNode
      newLength= Length(EbcdicString)
      if newLength < 1 then Leave
   End

   Do l# = 1 to Words(TestCaseLastNodes)
      lnode = Word(TestCaseLastNodes,l#)
      Say lnode 'selected mbrs:' TestCaseMbrs.lnode
   End

   Return;

Encrypt:

  If TraceRC = 1  then Say "@ Encrypt"
  /* Convert the CharString into EncryptString   */
  EncryptString = Left(CharString,reclen);

  strg = C2X(EncryptString)
  strg1= Substr(strg,2) || Substr(strg,1,1)
  EncryptString = X2C(strg1)
  Trace Off

  Return


Write_Compress_rec:

  If TraceRC = 1  then Say "@ Write_Compress_rec"
  /* Write 1 or more recs for EncryptString                 */
  /* If reclen > MAXLR then write continuation records:     */
  /* hex '0000' in the length field.                        */
  If TraceRC = 1  then Trace R

  sa=  reclen MAXLR
  If reclen > CompressLrecl then CompressLrecl = reclen;

  lenThisRec = min(MAXLR-4,reclen)
  HexReclen= Right(D2X(reclen),4,'0')

  Queue HexReclen ||,
        Substr(EncryptString,1,lenThisRec)

  If reclen <= (MAXLR-4) then Return

  /* Write continuation records */
  remainder  = reclen - lenThisRec
  pointer    = lenThisRec + 1

  Do while remainder > 0
     lenThisRec = min(MAXLR-4,remainder)
     Queue '0000' ||,
        Substr(EncryptString,pointer,lenThisRec)
     remainder  = remainder - lenThisRec
     pointer    = pointer + lenThisRec
  End; /* Do while remainder > 0 */
  TRACE oFF

  Return

GetEncryptedString:

   If TraceRC = 1  then Say "@ GetEncryptedString"
   If TraceRC = 1  then Trace r
  /* We're looking at a record that contains a length value */
  /* Build the EncryptString from current record and        */
  /* any continuation records                               */

  Sa= '@398' C2X(Substr(Inp.nextinp#,5,15))

  reclen     = X2D(Substr(Inp.nextinp#,1,4))
  /* Remember  string was rotated 1  char while in Hex      */
  EncryptString = Substr(Inp.nextinp#,5)
  sa= C2X(EncryptString)

  /* Append continuation records */
  lookinp#  = nextinp# + 1
  Do while Substr(Inp.lookinp#,1,4) = '0000'
     EncryptString = EncryptString || ,
        Substr(Inp.lookinp#,5)
     nextinp#   = lookinp# ;
     lookinp#   = lookinp# + 1;
  End; /* Do while remainder > 0 */

  EncryptString = Substr(EncryptString,1,reclen)

  Return

Decrypt:

  If TraceRC = 1  then Say "@ Decrypt"
  /* Convert the CharString from EncryptString   */
  If TraceRC = 1  then Trace R

  strg3 = C2X(EncryptString)
  lastchar = Substr(strg3,length(strg3))
  restofit = Substr(strg3,1,length(strg3)-1 )
  strg4= lastchar || restofit
  EncryptString = X2C(strg4)
  CharString = EncryptString


  Sa= 'CharString    =' CharString
  Sa= 'CharString    =' Length(CharString) CharString
  Sa= 'CharString    =' reclen Substr(CharString,1,reclen)
  Trace Off

  Return

