/*  REXX    */
   /*----------------------------------------------------------*/
   /*  This Rexx is given a JCL or other text file as input    */
   /*  The input parameter provides a dynamic selection        */
   /*  for 'Reference'. Just make the OPTIONS input use your   */
   /*  choice in the second position of each FindTxt and       */
   /*  Replace keywords.                                       */
   /*  This Rexx:                                              */
   /*      o Tailors input using pairs of Rexx stem array cmds:*/
   /*        TXT.FindTxt.1 = '<searchString>'                  */
   /*        TXT.Replace.1 = '<replaceString>'                 */
   /*      It is best if the two have the same length.         */
   /*      If not, then turncation may occur.                  */
   /*                                                          */
   /*----------------------------------------------------------*/
   /*  Some actions are intended for JCL inputs.                  */
   /*  Optionally, a DDname can be used for identifying where     */
   /*  to insert lines of JCL-                                    */
   /*                                                             */
   /*   TXT.Reference.REPLACE.<ddname>.   = '<text>'              */
   /*                                                             */
   /*  Optionally, a DDname and stepname can be used.             */
   /*                                                             */
   /*   TXT.Reference.REPLACE.<ddname>.<stepname>'  = '<text>'    */
   /*                                                             */
   /*  If new or replacement JCL text begins with '//' then the   */
   /*  lines of JCL are inserted, using '//' to identifiy the     */
   /*  start of each line.                                        */
   /*  If '//' is not found, then it is assumed that Inputs       */
   /*  names are listed in the value, and each is to be           */
   /*  included with DISP=SHR. The first Inputs name is given     */
   /*  the label <ddname>.                                        */
   /*                                                             */
   /*  Examples                                                   */
   /*                                                             */
   /*   TXT.Reference.FindTxt.1 = 'CLASS=P'                       */
   /*   TXT.Reference.Replace.1 = 'CLASS=T'                       */
   /*                                                             */
   /*   TXT.Reference.FindTxt.2 = ' PEND '                        */
   /*   TXT.Reference.where.2 = 'AFTER'                           */
   /*   TXT.Reference.Insertx.2 = '//START  EXEC PGM=IEFBR14'     */
   /*                                                             */
   /*   TXT.Reference.REPLACE.STEPLIB.STEP1 = 'IBMUSER.LOADLIB'   */
   /*   TXT.Reference.REPLACE.STEPLIB.STEP2 = ,                   */
   /*                 '//     DD DISP=SHR,DSN=IBMUSER.LOADLIB     */
   /*                                                             */
   /*                                                             */
   /*----------------------------------------------------------*/
/* Is TXTRPLCE allocated? If yes, then turn on Trace  */
   isItThere = ,
     BPXWDYN("INFO FI(TXTRPLCE) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then TraceRc = 'Y'
   /* A processor provides these Endevor values as arguments */
   ARG Reference OnStack
   /* INPUTS are optional, but can name dataset names     */
   /* for OLDTXT and NEWTXT                               */
   isItThere = ,
     BPXWDYN("INFO FI(INPUTS) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then,
      Do
      OLDTXT = ''
      NEWTXT = ''
      "EXECIO * DISKR INPUTS (Stem inp. finis"
      Do in# = 1 to inp.0
         Interpret inp.in#
      End; /* Do in# = 1 to inp.0 */
      If OLDTXT = '' then,
         Do
         say 'TXTRPLCE: Expecting an assignment for OLDTXT'
         Exit(12)
         End ;  /* If OLDTXT = ''*/
      If NEWTXT = '' then NEWTXT = OLDTXT
      String= "ALLOC DD(OLDTXT) DA("OLDTXT") SHR REUSE"
      CALL BPXWDYN STRING;
      String= "ALLOC DD(NEWTXT) DA("NEWTXT") SHR REUSE"
      CALL BPXWDYN STRING;
      End;  /* If isItThere = 0 */
   /* Set Defaults / initial values....                        */
   $numbers   = '0123456789'   /* chars for numeric values   */
   AlphaChars   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
   $OptionCommentChar = '*'
   ShowReplaceResults = 'Y'
   TXT.               = ''
   OptionsType        = 'REXX'
   Drop MaxReturnCode
   TXT.Reference.MaxReturnCode = 4   /* Value for MaxReturncode */
   TXT.Reference.where. = 'AFTER'    /* either BEFORE/AFTER */
   TXT.Reference.FindTxt. = ''
   TXT.Reference.Change. = ''           /* Yaml transed to Rexx */
   TXT.Reference.DDName. = ''           /* Yaml transed to Rexx */
   TXT.Reference.REPLACE. = ''
   TXT.Reference.Insertx. = ''
   TXT.Reference.InsertAtEnd. = ''
   NumberInstructions = 0     ; /* Assume zero, unless we find some*/
   If TraceRc = 'Y' then Trace r
   /* Get   Options for tailoring and processing the JCL       */
   /* If Options are in a YAML format, comment the 1st line    */
   /* If no Options are designated for Reference, then exit    */
   If OnStack /= 'Stack' &,
      OnStack /= 'STACK' then,
      Call ProcessInputOptions; /* Must read and validate them */
   /* At this point, OPTIONS statements are validated as OK, */
   /* and are found on the stack...                          */
   NumberInstructions = QUEUED()
   If NumberInstructions = 0 then,
      Do
      Say 'TXTRPLCE: finds no instructions for tailoring'
      Exit(4)
      End
   Do optCount = 1 to NumberInstructions
      Parse pull nextOption
      If TraceRc = 'Y' then,
         Say 'TXTRPLCE:' nextOption
      interpret nextOption
   End;
   /* Using Options tailor the JCL                */
   /* Yaml converted options are a bit different  */
   If OptionsType = 'YAML' then,
      Call TailorNEWTXTfromOldViaYaml;
   Else
      Call TailorNEWTXTfromOldViaOptions ;
   If TraceRc = 'Y' then,
      Say 'TXTRPLCE: exiting '
   Exit(1); /* Successful update       */
ProcessInputOptions:
   /* Determine from 1st record if OPTIONS are in YAML format  */
   If  TraceRc = 'Y'  then Trace r
   "EXECIO 1 DISKR OPTIONS "    /* may be in Rexx or Yaml format*/
   Parse Pull FirstOption
   /* If Yaml is being used, the 1st record must be a comment  */
   If Substr(FirstOption,1,1) = '#' then,  /* We are using YAML */
      Do
      /* Convert Yaml to REXX */
      /* Place converted REXX to Stack    */
      If TraceRc = 'Y' then,
         say "TXTRPLCE: calling YAML2REX 'OPTIONS' "
      Call YAML2REX 'OPTIONS'
      OptionsType = 'YAML'
      End ; /* If Substr(FirstOption,1,1) = '#' */
   Else,                                   /* We are using Rexx */
      Do
      "EXECIO 0 DISKR OPTIONS (Finis"
      If TraceRc = 'Y' then,
         say "TXTRPLCE: calling OPTVALDT(OPTIONS Y)"
      what = OPTVALDT(OPTIONS Y)
      OptionsType = 'Rexx'
      End ; /* If Substr(FirstOption,1,1) = '%' */
   isItThere = ,
     BPXWDYN("INFO FI(VARIABLE) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then Call Process_VARIABLE_input
   NumberInstructions = QUEUED()
   Return;
Process_VARIABLE_input:
   /* Read the VARIABLE data (variables provided by Endevor) */
   /* Variables can be mixture of C1* variables  of Endevor, */
   /* processor variables and Site Symbol variables.         */
   /* Append new instructions onto the Stack                 */
   "EXECIO * DISKR VARIABLE ( Stem var. Finis"
   If OptionsType = 'YAML' then,
      VarPrefix = 'TXT.'Reference'.Change'
   Else,
      VarPrefix = 'TXT.'Reference
   indx#= QUEUED() +1
   Do v# = 1 to var.0
      ndvrVariable = var.v#
      whereText = WordIndex(ndvrVariable,1)
      if whereText = 0 then Iterate;
      If Substr(ndvrVariable,whereText,1) = '#' |,
         Substr(ndvrVariable,whereText,1) = '*' then Iterate;
      PARSE VAR ndvrVariable $keyword "=" $keyValue
      $keyword = Strip($keyword)
      $keyValue = Strip($keyValue)
      Queue VarPrefix".Findtxt."indx# "='&"$keyword"'"
      Queue VarPrefix".Replace."indx# "="$keyValue
      If TraceRc = 'Y' then,
         Do
         Say 'TXTRPLCE:'
         Say VarPrefix".Findtxt."indx# "='&"$keyword"'"
         Say VarPrefix".Replace."indx# "="$keyValue
         End
      indx#= indx# +1
   End; /*  Do v# = 1 to var.0 */
   say   VarPrefix".Findtxt.0="indx#
   Queue VarPrefix".Findtxt.0="indx#
   Return;
TailorNEWTXTfromOldViaYaml:
   /* Read the OLDTXT file           */
   "EXECIO * DISKR OLDTXT ( Stem txtrec. Finis"
   /* If anything is to be inserted at End, do it here */
   Do j# = 1 to txtrec.0
      If TXT.Reference.InsertAtEnd.j# = '' then leave;
      txtrec#  = txtrec.0 + 1;
      txtrec.txtrec# = TXT.Reference.InsertAtEnd.j#
      txtrec.0 = txtrec#
   End; /* Do j# = 1 to txtrec.0  */
   /* Scan each record of the text file */
   Do j# = 1 to txtrec.0
      textline = txtrec.j#
      thistextlineQueued = 'N'
      /* Determine the Stepname */
      If Pos(' EXEC ',textline) > 0 &,
         Substr(textline,1,2) = '//' &,
         Substr(textline,3,1) > '*' then,
            thisStepName = Word(Substr(textline,3),1)
      /* Determine whether we are looking at a DDNAME */
      If Substr(textline,1,2) = '//' &,
         Substr(textline,3,1) > '*' then,
         Do
         thisDDname   = Word(Substr(textline,3),1)
         /* Is there an override for this DDNAME or DDNAME.STEP */
         newDDnameTxt = ''
         newDDnameTxt= TXT.Reference.DDName.thisDDname.thisStepName.1
         if newDDnameTxt = '' then,
            newDDnameTxt= TXT.Reference.DDName.thisDDname.1
         If newDDnameTxt /= '' then,
            Do; Call ReplaceDDname; Iterate; end;
         End /* If Substr(textline,1,2) = '//' & ... */
/*    If TraceRc = 'Y' then Trace r  */
      textline = txtrec.j#
      /* Execute the Search and replace string actions */
      Do rpl# = 1 to NumberInstructions
         findString = TXT.Reference.Change.FindTxt.rpl#
         If findString = '' then iterate;
         whereTxt = Pos(findString,textline)
         If whereTxt = 0 then iterate;
         replaceString = TXT.Reference.Change.Replace.rpl#
         If replaceString /= '' then,
            Do
            Call ReplaceText;
            Call ReplaceVariablesOnly;
            End /* If replaceString /= '' */
         Else,
            Do  /* no replace string...  inserting?   */
            inserttextline = TXT.Reference.Change.Insertx.rpl#.1
            insertWhere  = TXT.Reference.Change.where.rpl#
            If insertWhere /= 'BEFORE' then,
               insertWhere = 'AFTER'
            Saved_textline = textline
            If inserttextlines /= '' &,
               ShowReplaceResults = 'Y' then,
                  Say 'Inserting Text lines' insertWhere,
                   findString
            If insertWhere = 'AFTER' then,
               Do
               Queue textline
               thistextlineQueued = 'Y'
               End
            Do yamlcounter = 1 to NumberInstructions
               textline =,
                  TXT.Reference.Change.Insertx.rpl#.yamlcounter
               If textline = '' then Iterate ;
               Call ReplaceVariablesOnly;
               If ShowReplaceResults = 'Y' then,
                  Say " In:"textline
               Queue textline
            End /* Do yamlcounter = 1 to $Opts.0 */
            If insertWhere /= 'AFTER' then,
                  Queue Saved_textline
            End /* else ..  If replaceString /= ''  */
      End; /* Do rpl# = 1 to NumberInstructions */
      /* Write line of JCL to output                   */
      If thistextlineQueued /= 'Y' then,
         Do
         Call ReplaceVariablesOnly;
         If textline /= '' then Queue textline
         End
   End; /* Do j# = 1 to txtrec.0  */
   "EXECIO" QUEUED() "DISKW NEWTXT ( Finis"
   Return;
TailorNEWTXTfromOldViaOptions:
   /* Read the OLDTXT file           */
   "EXECIO * DISKR OLDTXT ( Stem txtrec. Finis"
   /* Scan each record of the JCL    */
   Do j# = 1 to txtrec.0
      textline = txtrec.j#
      thistextlineQueued = 'N'
      /* Determine the Stepname */
      If Pos(' EXEC ',textline) > 0 &,
         Substr(textline,1,2) = '//' &,
         Substr(textline,3,1) > '*' then,
            thisStepName = Word(Substr(textline,3),1)
      /* Determine whether we are looking at a DDNAME */
      If Substr(textline,1,2) = '//' &,
         Substr(textline,3,1) > '*' then,
         Do
         thisDDname   = Word(Substr(textline,3),1)
         /* Is there an override for this DDNAME or DDNAME.STEP */
         newDDnameTxt = ''
         newDDnameTxt= TXT.Reference.REPLACE.thisDDname.thisStepName;
         if newDDnameTxt = '' then,
            newDDnameTxt= TXT.Reference.REPLACE.thisDDname.
         If newDDnameTxt /= '' then,
            Do; Call ReplaceDDname; Iterate; end;
         End
/*    If TraceRc = 'Y' then Trace r  */
      textline = txtrec.j#
      /* Execute the Search and replace string actions */
      Do rpl# = 1 to NumberInstructions
         findString = TXT.Reference.FindTxt.rpl#
         If findString = '' then iterate;
         whereTxt = Pos(findString,textline)
         If whereTxt = 0 then iterate;
         replaceString = TXT.Reference.Replace.rpl#
         If replaceString /= '' then,
            Do
            Call ReplaceText;
            Call ReplaceVariablesOnly;
            End /* If replaceString /= '' */
         Else,
            Do
            inserttextlines = TXT.Reference.Insertx.rpl#
            If inserttextlines /= '' then,
               Do
               insertWhere  = TXT.Reference.where.rpl#
               If insertWhere /= 'BEFORE' then,
                  insertWhere = 'AFTER'
               If ShowReplaceResults = 'Y' then,
                  Say 'Inserting TXT lines' insertWhere,
                   findString
               If insertWhere = 'AFTER' then,
                  Do
                  Queue textline
                  thistextlineQueued = 'Y'
                  End
               Call Inserttextlines;
               End
            End /* else ..  If replaceString /= ''  */
      End; /* Do rpl# = 1 to NumberInstructions */
      /* Write line of TXT to output                   */
      If thistextlineQueued /= 'Y' then,
         Do
         Call ReplaceVariablesOnly;
         Queue textline
         End
   End; /* Do j# = 1 to txtrec.0  */
   "EXECIO" QUEUED() "DISKW NEWTXT ( Finis"
   Return;
ReplaceDDname:
/* If  TraceRc = 'Y'    then Trace r  */
   If ShowReplaceResults = 'Y' then,
      Say 'TXTRPLCE: Replacing the Step' thisStepName 'DDname',
           thisDDname 'with:'
   Label = thisDDname
   leadingSlashSlash = Pos('//',newDDnameTxt)
   If leadingSlashSlash =0 &,    /* no // in replacement */
      OptionsType = 'YAML' then,
      Do w# = 1 to NumberInstructions
      newDDnameTxt = ''
      newDDnameTxt= TXT.Reference.DDName.thisDDname.thisStepName.w#
      if newDDnameTxt = '' then,
         newDDnameTxt= TXT.Reference.DDName.thisDDname.w#
      If newDDnameTxt  = '' then Leave;
      inserttextlines = '//'Label ' DD DSN='newDDnameTxt || ','
      Call Inserttextlines ;
      Queue            '//         DISP=SHR'
      Label = '       '
      End /* Do w# = 1 to Words(newDDnameTxt) */
   Else,
   If leadingSlashSlash =0 then, /* no // in replacement */
      Do w# = 1 to Words(newDDnameTxt)
      JCLtext = Word(newDDnameTxt,w#)
      inserttextlines = '//'Label ' DD DSN='JCLtext || ','
      Call Inserttextlines ;
      Queue            '//         DISP=SHR'
      Label = '       '
      End /* Do w# = 1 to Words(newDDnameTxt) */
   Else,
   If leadingSlashSlash = 1 then, /* Yes // in replacement */
      Do Forever
      whereNextSlashSlash = Pos('//',newDDnameTxt,3)
      If whereNextSlashSlash = 0 then,
         whereNextSlashSlash = Length(newDDnameTxt) + 1
      JCLtext = Substr(newDDnameTxt,1,whereNextSlashSlash-1)
      inserttextlines = JCLtext
      Call Inserttextlines ;
      newDDnameTxt =,
            Strip(Substr(newDDnameTxt,whereNextSlashSlash))
      If length(newDDnameTxt) < 1 then Leave;
      End /* Do Forever */
   Else,
      Do
      Push 'Unsupported DDName replacement text is found- '
      Push "Expected leading '//', but found- ",
          "'"newDDnameTxt"'"
      "EXECIO 2 DISKW ERRORS (Finis"
      Exit(12)
      End /* Else */
   j# = j# +1;
   Call SkiptoNextLabel;
   Return
SkiptoNextLabel:
   SkipThirdChars = ' *'
   /* Find next JCL line with a label in position 3 */
   Do forever
      if j# > txtrec.0 then Leave;
      textline = txtrec.j#
      ThirdChar = Substr(textline,3,1)
      if Substr(textline,1,2) = '//' &,
         Pos(ThirdChar,SkipThirdChars) = 0 then,
            DO
            j# = j# -1 ;
            Leave;
            End;
      j# = j# +1 ;
   End; /*  Do forever  */
   Return
ReplaceText:
   Saved_textline = textline;
   If whereTXT = 1 then,
      textline = replaceString || ,
                substr(textline,whereTXT+Length(findString))
   Else,
      textline = substr(textline,1,(whereTXT-1)) ||,
                replaceString || ,
                substr(textline,whereTXT+Length(findString))
   If ShowReplaceResults = 'Y' then,
      Do
      Say "Txt line" j# "Changed:"
      Say " B4:"Saved_textline
      If Pos('Password',textline) = 0 then,
         Say " AF:"textline
      Else,
         Say " AF:***not-shown***"
      End
   Return
ReplaceVariablesOnly:
      Do upd# = 1 to NumberInstructions
         If OptionsType = 'YAML' then,
            Do
            findString = TXT.Reference.Change.FindTxt.upd#
            replaceString = TXT.Reference.Change.Replace.upd#
            End
         Else,
            Do
            findString = TXT.Reference.FindTxt.upd#
            replaceString = TXT.Reference.Replace.upd#
            End
         If findString = '' |,
            replaceString = '' then iterate;
         whereTxt = Pos(findString,textline)
         If whereTxt = 0 then iterate;
         Call ReplaceText;
      End; /* Do upd# = 1 to NumberInstructions */
   Return
Inserttextlines:
   /* Apply Search and Replace actions to inserted lines */
   Save_textline = textline;
   textline = inserttextlines
   Call ReplaceVariablesOnly;
   Do rpl# = 1 to NumberInstructions
      findString = TXT.Reference.FindTxt.rpl#
      whereTxt = Pos(findString,textline)
      If whereTxt = 0 then iterate;
      replaceString = TXT.Reference.Replace.rpl#
      If replaceString /= '' then,
         Call ReplaceText;
   End ;  /*Do rpl# = 1 to NumberInstructions */
   inserttextlines = textline /* line(s) to be inserted         */
   textline = Save_textline   /* The line that triggered insert */
   leadingSlashSlash = Pos('//',inserttextlines)
   If leadingSlashSlash = 1 then, /* Yes // in new jcl lines */
      Do Forever
      whereNextSlashSlash = Pos('//',inserttextlines,3)
      If whereNextSlashSlash = 0 then,
         whereNextSlashSlash = Length(inserttextlines) + 1
      JCLtext = Substr(inserttextlines,1,whereNextSlashSlash-1)
      If ShowReplaceResults = 'Y' then,
         Say JCLtext
      queue JCLtext
      inserttextlines =,
            Strip(Substr(inserttextlines,whereNextSlashSlash))
      If length(inserttextlines) < 1 then Leave;
      End /* Do Forever */
   Else,
      Do
      Push 'Unsupported DDName replacement text is found- '
      Push "Expected leading '//', but found- ",
          "'"inserttextlines"'"
      "EXECIO 2 DISKW ERRORS (Finis"
      Exit(12)
      End /* Else */
   Return
