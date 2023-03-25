/*            REXX                  */
/*  ----------------------------------------------------------      */
/*  Scan Endevor element-level SCL, parse the words, and            */
/*  write out into a format that other processes can use.           */
/*  ----------------------------------------------------------      */
/*                                                                  */
  /* If SCAN#SCL is allocated to anything, turn on Trace  */
  WhatDDName = 'SCAN#SCL'
  CALL BPXWDYN "INFO FI("WhatDDName")",
             "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  If Substr(DSNVAR,1,1) /= ' ' then Trace R

  /*  Either Allocate SCL in the JCL, or name SCL dataset here */
  Arg SCLDataset ;

  If Length(SCLDataset) > 3 then,
     If Pos('.',SCLDataset) > 0 then,
        "ALLOC F(SCL) DA('"SCLDataset"') SHR REUSE"

  "EXECIO * DISKR SCL (Stem scl. Finis"
  If scl.0 > 0 then,
     Do
     Result = "SCL.000000 ='" ||,
         Left('Command',8),
         Left('Envmnt',8),
         Left('S',1),
         Left('System',8),
         Left('Subsys',8),
         Left('Type',8),
         'Element  ' || "'"
     Queue Result
     End;

  /* Establish Defaults  */
  Count = 0
  DfltC1Envmnt   = ' '
  DfltC1Stgid    = ' '
  DfltC1System   = ' '
  DfltC1Subsys   = ' '
  DfltC1Element  = ' '
  DfltC1ElType   = ' '

  Do s# = 1 to scl.0
     Call  FindStatement
     Call  ProcessStatement
  End;

  "EXECIO" QUEUED() "DISKW RESULTS (Finis"

  Exit

FindStatement:

  Statement =  ' '

  Do Forever
     sclLine = Strip(scl.s#,'T')
     If Substr(sclLine,1,1) /= '*' then,
        Statement = Statement sclLine
     If Substr(Statement,Length(Statement),1) = '.' then Return;
     if s# = scl.0 then Return;
     s# = s# + 1;
  End;  /*  Do forever  */

  Return;

ProcessStatement:

  Classifications = 'ENV ENVIRONMENT SYS SYSTEM SUB SUBSYSTEM ',
                    'TYP TYPE STA STAGE ELE ELEMENT '
  Commands        = 'SET MOV MOVE TRA TRANSFER GEN GENERATE ',
                    ' DEL DELETE '

  thisCommand = Word(Statement,1)
  If Words(Statement) < 1 Then Return;

  C1Envmnt = DfltC1Envmnt
  C1Stgid  = DfltC1Stgid
  C1System = DfltC1System
  C1Subsys = DfltC1Subsys
  C1Element= DfltC1Element
  C1ElType = DfltC1ElType

  If Words(Statement) > 1 Then,
   Do w# = 2 to Words(Statement)
/* MG added Translate */
     thisWord = Translate(Word(Statement,w#))
     If w# < Words(Statement) then,
        nextWord = Word(Statement,w#+1)
     Else,
        nextWord = '  '
     If (thisWord = 'CCID' |,
         thisWord = 'COMMENT' ) &,
        Substr(nextWord,1,1) = "'" then,
        Do
        w# = w# + 1
        whereAmI   = Wordindex(Statement,w#)
        whereQuote = Pos("'",Statement,whereAmi+1)
        if whereQuote <= whereAmI then Iterate;
        Do forever;
           If WordIndex(Statement,w#+1) > whereQuote then Leave;
           w# = w# + 1;
           sa= WordIndex(Statement,w#+1)   whereQuote
        End; /* Do forever */
        Iterate;
     End

     nextWord = Strip(nextWord,'B',"'");
     nextWord = Strip(nextWord,'B','"');

     If thisWord = 'OPTIONS'          then Leave  ;
     If WordPos(thisWord,Classifications) = 0 then iterate;

     If thisCommand = 'SET' then,
        Do
        If Substr(thisWord,1,3) = 'ENV' then DfltC1Envmnt = nextWord
        If Substr(thisWord,1,3) = 'STA' then DfltC1Stgid = nextWord
        If Substr(thisWord,1,3) = 'SYS' then DfltC1System = nextWord
        If Substr(thisWord,1,3) = 'SUB' then DfltC1Subsys = nextWord
        If Substr(thisWord,1,3) = 'ELE' then DfltC1Element= nextWord
        If Substr(thisWord,1,3) = 'TYP' then DfltC1ElType = nextWord
        End
     Else,
        Do
        If Substr(thisWord,1,3) = 'ENV' then C1Envmnt = nextWord
        If Substr(thisWord,1,3) = 'STA' then C1Stgid  = nextWord
        If Substr(thisWord,1,3) = 'SYS' then C1System = nextWord
        If Substr(thisWord,1,3) = 'SUB' then C1Subsys = nextWord
        If Substr(thisWord,1,3) = 'ELE' then C1Element= nextWord
        If Substr(thisWord,1,3) = 'TYP' then C1ElType = nextWord
        End
     w# = w# + 1
  End;   /* Do w# = 2 to Words(Statement) */

  If thisCommand = 'SET' then Return ;
  If Length(C1Element) > 10 then Return;

  Count = Count + 1
  ShowCount = Right(Count,6,'0')
  Result = 'SCL.'ShowCount "='" ||,
      Left(thisCommand,8),
      Left(C1Envmnt,8),
      Left(C1Stgid,1),
      Left(C1System,8),
      Left(C1Subsys,8),
      Left(C1ElType,8),
      C1Element || "'"
/* MG added Translate */
  Result = Translate(Result)
  Queue Result

  Return;
