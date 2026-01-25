/*     REXX     */
   /* For references found in the INPUT, repeat the
      symbolic substitutions of variables, until further
      substitution is impossible. Hopefully, all variables will be
      subsituted, but it is possible that variables may be assigned
      to other variables for which no value was given      */
   ARG TraceV
   If TraceV = 'Y' then Trace r
   /* Valid Characters for Endevor processor Variables */
   $numbers     ='0123456789'
   variableChars='ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$?' || $numbers
   /* To count the number of periods expected after a variable  */
   DotCount.    = 1
   "EXECIO * DISKR INPUT (Stem original. Finis"
   /* Since later variables may be dependent on earlier
      variables, a loop is engaged to repeat substitutions
      until all are resolved  */
   ResolvedVariables = ''
   /* Make up to 25 passes through the inputs              */
   /* Some values may depend on others listed lower within */
   /* the inputs.                                          */
   Do pass# = 1 to 25
     StillResolvingVars = 'N'
     Say "Starting pass" pass#
     /* intermediate values are kept in vars.           */
     /* For each pass, step through the inputs to apply
        variable->value substitutions                   */
     Do inp# = 1 to original.0
        If pass# = 1 then vars.inp# = original.inp#
        string = Strip(vars.inp#)
        If substr(string,1,1) = '*' then Iterate
        If Length(TraceV) > 1 then,
           If ABBREV(string,TraceV) = 1 then Trace r
           Else Trace off
        whereEqual = Pos('=',string)
        If whereEqual > 0 then,
           Do
           tempstring = Translate(string," ","=")
           thisVariableName = Word(tempstring,1)
           thisVariableValue = Strip(Substr(string,whereEqual+1))
           thisVariableValue = Strip(thisVariableValue,"B","'")
           thisVariableValue = Strip(thisVariableValue,"B",'"')
           string = thisVariableName '=' Strip(thisVariableValue)
           End /* If whereEqual > 0 */
        /* look for '&' (ampersand) characters */
        If pass# = 1 & Pos('50'x, string) = 0 then,
           say '::: ' string
        Else,
        If Pos('50'x, string) > 0 then,
           Do
           string_before = string
           Call EndevorVariablesEvaluate
           If string /= string_before then,
              Do
              vars.inp# = Strip(string)
              Say thisVariableName 'has this DotCount',
                  DotCount.thisVariableName
              End
           End; /*If Pos('50'x, string) > 0 */
        /* If all symbols have been resolved for 1 variable */
        If Pos('50'x, string) = 0 then,
           Do
           string = vars.inp#
           whereEqual = Pos('=',string)
           If whereEqual = 0 then iterate
           tempstring = Translate(string," ","=")
           thisVariableValue=,
               Strip(Substr(string,whereEqual+1))
           thisVariableValue= Strip(thisVariableValue,"B","'")
           thisVariableValue= Strip(thisVariableValue,"B",'"')
           thisVariableValue= Strip(thisVariableValue)
           SaveValue.thisVariableName = thisVariableValue
           If Wordpos(thisVariableName,ResolvedVariables)=0 then,
              ResolvedVariables =,
                ResolvedVariables thisVariableName
           If Pos("'",thisVariableValue) = 0 then vars.inp# =,
                 thisVariableName "='" || thisVariableValue || "'"
           Else,
           If Pos('"',thisVariableValue) = 0 then vars.inp# =,
                 thisVariableName '="' || thisVariableValue || '"'
           Else,
                 vars.inp# = string
           End; /* If Pos('50'x, string) = 0 */
     End; /*  Do inp# = 1 to  original.0 */
     If StillResolvingVars = 'N' then Leave
   End;  /* Do pass# = 1 to 50  */
   Say "NDVRREPT- completed" pass# "passes through input data"
   "EXECIO * DISKW REPORT (Stem vars. Finis"
   exit
EndevorVariablesEvaluate:
   say '------------------'
   say 'B4: ' string_before
   lastSearchPosition = Length(string)
   If TraceV = 'T' then Trace Off
   noDotsAtEnd = Strip(string,"T",".")
   numberOfDots = Length(String) - Length(noDotsAtEnd)
   If numberOfDots > 0 then,
      Do
      DotCount.thisVariableName =,
        DotCount.thisVariableName-numberOfDots
      String = noDotsAtEnd
      End /* If numberOfDots > 0 */
   Do Forever
      /* Find last ampersand - replace from back to front */
      sa= string
      positionAmper =,
         LastPos('50'x,Substr(string,1,lastSearchPosition))
      If positionAmper = 0 then Return
      /* Finding a variable preceeded by a double ampersand? */
      If positionAmper > 1 &,
         Substr(string,positionAmper-1,2) = '5050'x then,
         DoubleAmpersand = 'Y'
      Else,
         DoubleAmpersand = 'N'
      /* Looking at a Site Symbol? (Variable name begins with #) */
      /* Set a length (including the & char)  */
      If Substr(string,positionAmper+1,1) = '#' then,
         maxVariableLen = 13
      Else
         maxVariableLen = 10
      /* Finding a variable name and the variable name length       */
      VariableLen#1 = FindVariableNameEnd()
      appendVariable =,
         Substr(string,positionAmper+1,VariableLen#1-1)
      /* VariableLen#1 have acceptable length ?             */
      If VariableLen#1 > (maxVariableLen+1) then,
         Do
         Say "cannot handle this" Substr(string,positionAmper)
         Say "  at" Inp#
         Say string
         Exit 12
         End; /* Else..  */
      /* Is trace requested for this appending variable ?   */
      If Length(TraceV) > 1 then,
         If ABBREV(appendVariable,TraceV) = 1 then Trace r
      /* If appending variable is not yet given a value,
         wait for one or more subsequent passes  */
      If WordPos(appendVariable,ResolvedVariables) = 0 then,
         DO
         lastSearchPosition = positionAmper - 1
         Do while lastSearchPosition > 1 &,
              Substr(string,lastSearchPosition,1) = '50'x
                lastSearchPosition = lastSearchPosition - 1
         End
         If pass#=1 | positionAmper=1 |,
            lastSearchPosition=1 then,
            Return    /* come back later */
         Else,        /* After 1st pass, try other vars */
            Iterate
         End; /* If WordPos(appendVariable,Resolved...  */
      /* terminateChar is the character following variable name */
      terminateChar  =,
         Substr(string || ' ',positionAmper+VariableLen#1,1)
      appendValue = SaveValue.appendVariable
      /* terminateChar# now the position of character
         in string after the variable name*/
      terminateChar# = VariableLen#1 + positionAmper
      /* If a '(' appears after the variable name do Substringing */
      SubstringingStatus = 'N/A'      /* by Default */
      /* if the character after the variable name is a left paren */
      If terminateChar = '(' then,
         Do
         If TraceV = 'T' then Trace r
         Call GetSubStringValue
         sa=  'SubstringingStatus =' SubstringingStatus
         If TraceV = 'T' then Trace Off
         If SubstringingStatus = 'Dependent' then Return
         End
      Else,
      If terminateChar = '.' then,
         /* Check whether the DotCount can be decreased   */
         /* This occurs when the value of a variable ends */
         /* and is followed by Dots (periods).            */
         Do
         If TraceV = 'T' then Trace r
         eatDots = DotCount.appendVariable
          Do While terminateChar = '.' & eatDots > 0
             string = DELSTR(string, terminateChar#, 1)
             terminateChar  =,
               Substr(string || ' ',terminateChar#,1)
             eatDots = eatDots - 1
          End /* Do While terminateChar = '.' ... */
         If TraceV = 'T' then Trace Off
         End
      /* Check whether the DotCount needs to be increased  */
      /* This occurs when the value of a variable ends     */
      /* with another variable, and no Dot follows.        */
      If TraceV = 'T' then Trace r
      sa= 'string = ' string
      sa= 'Length(string)=' Length(string)
      sa= 'positionAmper =' positionAmper
      sa= 'VariableLen#1=' VariableLen#1
      sa= 'appendVariable  =' appendVariable
      sa= 'thisVariableName=' thisVariableName
      sa= 'DotCount.thisVariableName =',
           DotCount.thisVariableName
      sa= 'DotCount.appendVariable =',
           DotCount.appendVariable
      sa= 'terminateChar#=' terminateChar#
      sa= 'Length(string)' Length(string)
      sa= 'SubstringingStatus=' SubstringingStatus
      If SubstringingStatus /= 'Done' &,
         (terminateChar = '"' | terminateChar = "'" |,
          terminateChar = ' ' | terminateChar = "."   ) &,
          terminateChar# >= Length(string) then,
           DotCount.thisVariableName =,
           DotCount.thisVariableName + DotCount.appendVariable
      /* Rewrite the portion of string where variable is found
          ... and eat trailing Dots as counted necessary    */
      sa = string
      sa = positionAmper
      sa = appendValue
      If positionAmper > 1 then,
         newstring = Substr(string,1,positionAmper-1)
      Else newstring = ''
      newstring =  newstring || appendValue
      sa = Substr(string,terminateChar#,1)
      If terminateChar# <= length(string) then,
         newstring = newstring || Substr(string,terminateChar#)
      string =  newstring
      say 'AF: ' string
      StillResolvingVars = 'Y'
      If TraceV = 'T' then Trace Off
      Iterate
      End; /* If terminateChar# <= (maxVariableLen+1)*/
   End;  /* Do Forever */
FindVariableNameEnd:
   /* Examine the unresolved original to see where          */
   /* the variable name ends.                               */
   tempEndCharacter =,
     VERIFY(Substr(original.inp# || ' ',positionAmper+1),
          ,variableChars)
   tempVariableName =,
      Substr(string,positionAmper+1,tempEndCharacter-1)
   If Wordpos(tempVariableName, ResolvedVariables) > 0 then,
      Return tempEndCharacter
   /* Examine the last resolved value to see where          */
   /* the variable name ends.                               */
   tempEndCharacter =,
     VERIFY(Substr(string_before || ' ',positionAmper+1),
          ,variableChars)
   tempVariableName =,
      Substr(string,positionAmper+1,tempEndCharacter-1)
   If Wordpos(tempVariableName, ResolvedVariables) > 0 then,
      Return tempEndCharacter
   /* Examine the   resolved string   to see where          */
   /* the variable name ends.                               */
   VariableLen#1 =,
     VERIFY(Substr(string || ' ',positionAmper+1),
          ,variableChars)
   Return VariableLen#1
GetSubStringValue:
   sa= 'closeparenChar#=' closeparenChar#
   closeparenChar# = Pos(')',string, terminateChar#)
   If closeparenChar# = 0 then Return
   SubstringValues =,
      Substr(string,terminateChar#,closeparenChar#-terminateChar#)
   If Pos(",", SubstringValues) = 0 then return
   If Pos('50'x, SubstringValues) > 0 then,
      Do
      SubstringingStatus = 'Dependent'
      Return
      End
   SubstringValues =,
     translate(SubstringValues," ","(:,)")
   SubstringStart = Word(SubstringValues,1)
   If VERIFY(SubstringStart,$numbers) > 0 then Return
   SubstringLength= Word(SubstringValues,2)
   If VERIFY(SubstringLength,$numbers) > 0 then Return
   If Words(SubstringValues) > 2 then,
      SubstringPad = Word(SubstringValues,3)
   Else,
      SubstringPad = ' '
   appendValue =,
     Substr(appendValue,SubstringStart,SubstringLength,SubstringPad)
   SubstringingStatus = 'Done'
   terminateChar# = closeparenChar# + 1
   Return
