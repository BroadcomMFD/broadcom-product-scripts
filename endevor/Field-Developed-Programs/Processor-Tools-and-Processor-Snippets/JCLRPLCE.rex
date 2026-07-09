/*  REXX    */
   /*----------------------------------------------------------*/
   /*  This Rexx is given a JCL or other text file as input    */
   /*  The input parameter provides a dynamic selection        */
   /*  for 'Reference'. Just make the OPTIONS input use your   */
   /*  choice in the second position of each FindTxt and       */
   /*  Replace keywords.                                       */
   /*  This Rexx                                               */
   /*      o Tailors input using pairs of Rexx stem array cmds:*/
   /*        JCL.FindTxt.1 = '<searchString>'                  */
   /*        JCL.Replace.1 = '<replaceString>'                 */
   /*      It is best if the two have the same length.         */
   /*      If not, then turncation may occur.                  */
   /*                                                          */
   /*----------------------------------------------------------*/
   /*  Some actions are intended for JCL inputs.                  */
   /*  Optionally, a DDname can be used for identifying where     */
   /*  to insert lines of JCL-                                    */
   /*                                                             */
   /*   JCL.Reference.REPLACE.<ddname>.   = '<text>'              */
   /*                                                             */
   /*  Optionally, a DDname and stepname can be used.             */
   /*                                                             */
   /*   JCL.Reference.REPLACE.<ddname>.<stepname>'  = '<text>'    */
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
   /*   JCL.Reference.FindTxt.1 = 'CLASS=P'                       */
   /*   JCL.Reference.Replace.1 = 'CLASS=T'                       */
   /*                                                             */
   /*   JCL.Reference.FindTxt.2 = ' PEND '                        */
   /*   JCL.Reference.where.2 = 'AFTER'                           */
   /*   JCL.Reference.Insertx.2 = '//START  EXEC PGM=IEFBR14'     */
   /*                                                             */
   /*   JCL.Reference.REPLACE.STEPLIB.STEP1 = 'WALJO11.LOADLIB'   */
   /*   JCL.Reference.REPLACE.STEPLIB.STEP2 = ,                   */
   /*                 '//     DD DISP=SHR,DSN=WALJO11.LOADLIB     */
   /*                                                             */
   /*                                                             */
   /*----------------------------------------------------------*/

/* Is JCLRPLCE allocated? If yes, then turn on Trace  */
   isItThere = ,
     BPXWDYN("INFO FI(JCLRPLCE) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then TraceRc = 'Y'

   /* A processor provides these Endevor values as arguments */
   ARG Reference OnStack


   /* Set Defaults / initial values....                        */
   ShowReplaceResults = 'Y'

   Drop MaxReturnCode
   JCL.Reference.Changes. = ''
   JCL.Reference.MaxReturnCode = 4   /* Value for MaxReturncode */
   JCL.Reference.Changes.where. = 'AFTER' /* either BEFORE/AFTER */
   JCL.Reference.Changes.FindTxt. = ''
   JCL.Reference.Changes.Delete. = ''
   JCL.Global.FindTxt.           = ''   /* Global find+replace  */
   JCL.Reference.Changes.REPLACE. = ''
   JCL.Reference.Changes.Insertx. = ''
   JCL.Reference.Changes.InsertAtEnd. = ''

   NumberInstructions = 0     ; /* Assume zero, unless we find some*/

   /* Get   Options for tailoring and processing the JCL       */
   /* If Options are in a YAML format, comment the 1st line    */
   /* If no Options are designated for Reference, then exit    */
   If OnStack /= 'Stack' &,
      OnStack /= 'STACK' then,
      Call ProcessInputOptions; /* Must read and validate them */

   ProcessorVariables = ''
   isItThere = ,
     BPXWDYN("INFO FI(VARIABLE) INRTDSN(DSNVAR) INRDSNT(myDSNT)")
   If isItThere = 0 then,
     Call ProcessorVariables

   /* At this point, OPTIONS statements are validated as OK, */
   /* and are found on the stack...                          */
   NumberInstructions = QUEUED()
   If TraceRc = 'Y' then,
      Say 'JCLRPLCE- NumberInstructions=' NumberInstructions

   If NumberInstructions = 0 then,
      Do
      Say 'JCLRPLCE- finds no instructions for tailoring'
      Exit
      End
   Do optCount = 1 to NumberInstructions
      Parse pull nextOption
      If TraceRc = 'Y' then,
         Say 'JCLRPLCE-' nextOption
      interpret nextOption
   End;

   /* Using Options tailor the JCL                */
   Call TailorNEWJCLfromOldViaOptions ;

   If TraceRc = 'Y' then,
      Say 'JCLRPLCE- exiting '

   Exit(1); /* Successful update       */

ProcessInputOptions:

   /* Determine from 1st record if OPTIONS are in YAML format  */
   "EXECIO 1 DISKR OPTIONS "    /* may be in Rexx or Yaml format*/
   Parse Pull FirstOption
   /* If Yaml is being used, the 1st record must be a comment  */
   If Substr(FirstOption,1,1)/= '#' then,  /* We are using YAML */
      Do
      Say 'JCLRPLCE- expecing YAML syntax in OPTIONS'
      Exit(12)
      End ; /* If Substr(FirstOption,1,1) = '#' */

   /* Convert Yaml to REXX */
   /* Place converted REXX onto Stack    */
   If TraceRc = 'Y' then,
      say "JCLRPLCE- calling YAML2REX 'OPTIONS' "
   Call YAML2REX 'OPTIONS'
   OptionsType = 'YAML'

   NumberInstructions = QUEUED()
   Return;

ProcessorVariables:

   /* Read the VARIABLE data (variables provided by Endevor) */
   /* Variables can be mixture of C1* variables  of Endevor, */
   /* processor variables and Site Symbol variables.         */
   /* Append new instructions onto the Stack                 */
   "EXECIO * DISKR VARIABLE ( Stem var. Finis"

   Do v# = 1 to var.0
      ndvrVariable = var.v#
      whereText = WordIndex(ndvrVariable,1)
      if whereText = 0 then Iterate;
      If Substr(ndvrVariable,whereText,1) = '#' |,
         Substr(ndvrVariable,whereText,1) = '*' then Iterate;

      PARSE VAR ndvrVariable $keyword "=" $keyValue
      $keyword = Strip($keyword)
      $keyValue = Strip($keyValue)
      $keyValue = Strip($keyValue,'B','"')
      $keyValue = Strip($keyValue,'B',";")
      ProcessorVariables = $keyword ProcessorVariables
      VarValue.$keyword = Translate($keyValue,' ','"')
      If TraceRc = 'Y' then,
         Say 'JCLRPLCE-' $keyword '=' $keyValue
   End; /*  Do v# = 1 to var.0 */

   Return;

TailorNEWJCLfromOldViaOptions:

   /* Common setup for using    Options */
   Call TailoringSetup
   /* Until a step is found, the Options reference jobcard  */
   JCLreference = 'jobcard'

   /* Scan each record of the JCL    */
   Do j# = 1 to jclrec.0
      JCLline = jclrec.j#
      Saved_StartInsertline = JCLline
      thisJclLineHandled = 'N'

      /* Finding a     Stepname or DDname ? */
      If Substr(JCLline,1,2) = '//' &,
         Substr(JCLline,3,1) > '*' then,
         Call FindDDnameOrStepname;

      /* Loop through FindTxt and other string actions */
      Do find# = 1 to NumberInstructions
         tempString =,
           'JCL.'Reference'.Changes.'JCLreference'.FindTxt.'find#
         findString = Value(tempString)
         Upper tempString
         /* Finding no FindTxt string    */
         if findString = tempString |,
            findString = '' then iterate;

         If TraceRc = 'Y' & j# = 1 then,
            Say 'JCLRPLCE searching for:' findString

         /* Finding FindTxt string on this JCLline?  */
         whereTxt = Pos(findString,JCLline)
         If whereTxt = 0 then iterate;

         /* Found a FindTxt value on a JCLline */
         If TraceRc = 'Y' then,
            Say 'JCLRPLCE @196 finding' findString

         /* Finding a Replace string ?  */
         tempString = ,
           'JCL.'Reference'.Changes.'JCLreference'.Replace.'find#
         replaceString = Value(tempString)
         Upper tempString
         if replaceString /= tempString &,
            replaceString /= '' then,
            Do
            Call ReplaceText;
            Saved_StartInsertline = JCLline
            Iterate ;
            End /* If replaceString /= '' */

         /* Finding a Delete request ?
         tempString = ,
            JCL'.'Reference'.'Changes'.'JCLreference'.'deleteln'.'find#
         deleteJCLline = Value(tempString)
         If deleteJCLline /= tempString then,
            thisJclLineHandled = 'Y'
            Leave;
         */


         /* Finding Insert lines     ?  */
         tempString = ,
           'JCL.'Reference'.Changes.' ||,
              JCLreference'.Insertx.'find#'.1'
         insertJCLline   = Value(tempString)
         /* Found a FindTxt value on a JCLline */
         If TraceRc = 'Y' then,
            Say 'JCLRPLCE @227 ',
                tempString insertJCLline
         Upper tempString
         If insertJCLline /= tempString &,
            insertJCLline /= '' then,
               Call Inserttextlines;

      End; /* Do find# = 1 to NumberInstructions */

      /* If not already handled,                       */
      /* Write line of JCL to output                   */
      If thisJclLineHandled /= 'Y' then,
         Do
         JCLline = Saved_StartInsertline
         Queue JCLline
         End
   End; /* Do j# = 1 to jclrec.0  */

   "EXECIO" QUEUED() "DISKW NEWJCL ( Finis"

   Return;

TailoringSetup:

   /* Read the OLDJCL file           */
   "EXECIO * DISKR OLDJCL ( Stem jclrec. Finis"

   /* If anything is to be inserted at End, do it here */
   Do j# = 1 to jclrec.0
      sa = JCL.Reference.InsertAtEnd.j#
      sa = 'JCL.'Reference'.InsertAtEnd.'j#
      sa = 'JCL.'Reference'.INSERTATEND.'j#
      If JCL.Reference.InsertAtEnd.j# = '' |,
         JCL.Reference.InsertAtEnd.j# = ,
        'JCL.'Reference'.InsertAtEnd.'j#   |,
         JCL.Reference.InsertAtEnd.j# = ,
        'JCL.'Reference'.INSERTATEND.'j# then leave
      txtrec#  = jclrec.0 + 1;
      jclrec.txtrec# = JCL.Reference.InsertAtEnd.j#
      jclrec.0 = txtrec#
   End; /* Do j# = 1 to jclrec.0  */

   Return;

FindDDnameOrStepname:

   thisDDname   = ''
   If Pos(' EXEC ',JCLline) > 0 then,
      Do
      thisStepName = Word(Substr(JCLline,3),1)
      JCLreference = thisStepName
      End
   If Pos(' DD ',JCLline) > 0 then,
      Do
      thisDDname   = Word(Substr(JCLline,3),1)
      JCLreference = thisStepName'.'thisDDName
      End ; /* If Substr(JCLline,1,2) = '//' ... */

   Return;

ReplaceText:

   If ShowReplaceResults = 'Y' then,
      Do
      Say "JCL line" j# "Changed:"
      Say " B4:"JCLline
      End

   If whereTXT = 1 then,
      JCLline = replaceString || ,
                substr(JCLline,whereTXT+Length(findString))
   Else,
      JCLline = substr(JCLline,1,(whereTXT-1)) ||,
                replaceString || ,
                substr(JCLline,whereTXT+Length(findString))

   If ShowReplaceResults = 'Y' then,
      Do
      If Pos('Password',JCLline) = 0 then,
         Say " AF:"JCLline
      Else,
         Say " AF:***not-shown***"
      End

   Return

Inserttextlines:

   If TraceRc = 'Y' & j# < 6 then Trace r
   /* Insert Insertx.n lines                             */
   /* Find    where Before/After  */
   tempString = ,
     'JCL.'Reference'.Changes.'JCLreference'.InsertWhere.'find#
   WhereToInsert = Value(tempString)
   If WhereToInsert /= 'BEFORE' then WhereToInsert = 'AFTER'

   If ShowReplaceResults = 'Y' then,
      Say 'Inserting JCL lines' WhereToInsert,
          findString
   If WhereToInsert = 'AFTER' then,
      Do
      Queue Saved_StartInsertline
      thisJclLineHandled = 'Y'
      End

   /* Insert 1st insert line           */
   JCLline = insertJCLline
   Call SubstituteProcessorVariables
   Queue JCLline

   /* Insert other insert lines        */
   Do ins# = 2 to NumberInstructions
      tempString = ,
           'JCL.'Reference'.Changes.' ||,
              JCLreference'.Insertx.'find#'.'ins#
      JCLline = Value(tempString)
      Upper tempString
      If JCLline = tempString    |,
         JCLline = '' then Leave;
      Call SubstituteProcessorVariables;
      Queue JCLline
   End /* Do ins# = 2 to NumberInstructions */

   Return

SubstituteProcessorVariables:

   /* Support global.FindTxt and global.Replace commands */
   Do var# = 1 to Words(ProcessorVariables)
      $keyword = Word(ProcessorVariables,var#)
      findString = "50"x || $keyword
      whereTXT = Pos(findString,JCLline)
      If whereTXT = 0 then iterate;
      replaceString = VarValue.$keyword
      If replaceString /= findString then,
         Call ReplaceText;
   End; /* Do var# = 1 to NumberInstructions */

   Return
