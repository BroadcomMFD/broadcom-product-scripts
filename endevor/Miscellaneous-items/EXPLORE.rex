/*   REXX  */
    TRACE Off
    Arg ThisLib     /* pass source execution library from caller */
    If ThisLib = '' then,
       Do
       parse source w1 w2 w3 w4 my_RexLib w6 w7 w8
       my_name = w3
       ThisLib = my_RexLib
       End
    MyDataset = ThisLib
    MyTable = left(MyDataset,lastpos('.',MyDataset))||'TABLES'

    Call Use_LISTALC_toSeeWhatsThere ;

    Call ExamineLibrariesFound;

    /* Use these variables for File Tailoring */
    MYJCL = MyDataset
    MYTABLES = MyTable


    EXIT

Use_LISTALC_toSeeWhatsThere :

    Dataset. = ' '         /* Default library concatenations empty */

    DSNCHECK = SYSDSN("'"MyTable"'") ;
    IF DSNCHECK /= 'OK' THEN,
       DO
       SAY 'ALLOCATING ' MyTable
       Address TSO "ALLOC F(ALLOTMP) DA('"MyTable"') ",
            "LRECL(200) BLKSIZE(0) SPACE(25,25) CYLINDERS",
            "LIKE ('"MyDataset"') ",
            "NEW CATALOG REUSE "     ;
       Address TSO "FREE F(ALLOTMP)"
       END

    Address TSO "ALLOC F(LISTALC) ",
         "DA('"MyTable"(LISTALC)') SHR REUSE "

    X = OUTTRAP(LINE.);
    ADDRESS TSO "LISTALC STATUS HISTORY"

    DO I = 1 TO LINE.0
       NEWLINE = LINE.I ;
       IF WORDS(NEWLINE) = 1 THEN,       /* Is this a ddname?   */
          DO
          DATASET = WORD(NEWLINE,1) ;
          ITERATE;
          END
       TMDDNM = SUBSTR(NEWLINE,44,8)
       IF TMDDNM  = '        ' THEN,     /* Dataset line?       */
          DO
          Call Save_LISTALC_Info
          ITERATE;
          END
       DDNAME = STRIP(TMDDNM) ;
       Call Save_LISTALC_Info
       END;

    "EXECIO" QUEUED() "DISKW LISTALC  (FINIS)"

    Address TSO "FREE F(LISTALC) "
    RETURN

Save_LISTALC_Info :

    len = Length(DATASET)
    if len > 44 then return
    if Substr(DATASET,len,1) = '?' then Return

    Dataset.DDNAME = Dataset.DDNAME DATASET ;
    QUEUE LEFT(DDNAME,09) LEFT(Dataset,60)

    Return

ExamineLibrariesFound :

    /*  Save Sysproc library concatatenations */
    Address TSO "ALLOC F(ZSYSPROC) ",
         "DA('"MyDataset"(ZSYSPROC)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.SYSPROC)
       mydsn = Word(Dataset.SYSPROC,wrd)
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZSYSPROC (FINIS)"
    Address TSO "FREE F(ZSYSPROC) ",

    /*  Save Sysexec library concatatenations */
    Address TSO "ALLOC F(ZSYSEXEC) ",
         "DA('"MyDataset"(ZSYSEXEC)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.SYSEXEC)
       mydsn = Word(Dataset.SYSEXEC,wrd)
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZSYSEXEC (FINIS)"
    Address TSO "FREE F(ZSYSEXEC) ",

    /*  Save ISPPLIB library concatatenations */
    Address TSO "ALLOC F(ZISPPLIB) ",
         "DA('"MyDataset"(ZISPPLIB)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.ISPPLIB)
       mydsn = Word(Dataset.ISPPLIB,wrd)
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZISPPLIB (FINIS)"
    Address TSO "FREE F(ZISPPLIB) ",

    /*  Save ISPSLIB library concatatenations */
    Address TSO "ALLOC F(ZISPSLIB) ",
         "DA('"MyDataset"(ZISPSLIB)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.ISPSLIB)
       mydsn = Word(Dataset.ISPSLIB,wrd)
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZISPSLIB (FINIS)"
    Address TSO "FREE F(ZISPSLIB) ",

    /*  Save ISPMLIB library concatatenations */
    Address TSO "ALLOC F(ZISPMLIB) ",
         "DA('"MyDataset"(ZISPMLIB)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.ISPMLIB)
       mydsn = Word(Dataset.ISPMLIB,wrd)
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZISPMLIB (FINIS)"
    Address TSO "FREE F(ZISPMLIB) ",

    /*  Save ISPTLIB library concatatenations */
    Address TSO "ALLOC F(ZISPTLIB) ",
         "DA('"MyDataset"(ZISPTLIB)') SHR REUSE "
    Do wrd = 1 to WORDS(Dataset.ISPTLIB)
       mydsn = Word(Dataset.ISPTLIB,wrd)
       myuserid = USERID()
       len = Length(myuserid)
  /*   if Substr(mydsn,1,len) = myuserid then iterate ;     */
       QUEUE '//         DD DISP=SHR,DSN='mydsn
    End
    "EXECIO" QUEUED() "DISKW ZISPTLIB (FINIS)"
    Address TSO "FREE F(ZISPTLIB) ",

    Return
