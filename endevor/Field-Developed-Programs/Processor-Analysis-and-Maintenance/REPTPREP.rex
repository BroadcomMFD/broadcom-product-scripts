/*   REXX     */
    "ISREDIT MACRO"
     TRACE Off
/*   Capture User sysmbols from within a processor                  */
     ADDRESS ISREDIT " (MEMBER) = MEMBER " ;
     MyMODELDsn = 'your.pdsfor.MODELS'
     myout.0 = 0; my# = 0
     answer = 'X'
     answer = ' '
     ADDRESS ISREDIT " EXCLUDE ALL ";
     ADDRESS ISREDIT " FIND '//*' 1  ALL" ;
     ADDRESS ISREDIT " DELETE ALL NX"
/*   ADDRESS ISREDIT " FIND ' PROC ' FIRST" ; */
     DO FOREVER
        ADDRESS ISREDIT " FIND '=' NEXT"       ;
        If RC > 0 then Leave
        ADDRESS ISREDIT " (linepos,whereEq) = CURSOR " ;
        ADDRESS ISREDIT " (DLINE) = LINE " linepos
        If Substr(DLINE,1,3) = '//*' then iterate;
        If Word(DLINE,2) = 'EXEC' &,
           Substr(Word(DLINE,3),1,4) = 'PGM=' then leave
        whereback  = whereEq
        Call FindVariableBegining
        If whereback = whereEQ - 1 ] ,
           Substr(DLINE,whereback,1) /= ' ' then Iterate
        wherespace = whereback
        command = Strip(Substr(DLINE,wherespace),)
        If Substr(command,length(command),1) /= ',' then,
           command = command ]] ','
        If answer /= 'X' then,
           Say 'Assignment=' command
        nextchar = Substr(DLINE,whereEq+1,1)
        If nextchar= "'" then,
           Parse var command keyword '=' "'" value "'"
        Else
        If nextchar= '"' then,
           Parse var command keyword '=' '"' value '"'
        Else
           Do
           wherenextequal = Pos('=',DLINE,whereEq+1)
           If wherenextequal = 0 then,
              Parse var command keyword '=' value ' '
           If wherenextequal > 0 then,
              Do
              whereback  = wherenextequal
              Call FindVariableBegining
              If whereback = whereEQ - 1 ] ,
                 Substr(DLINE,whereback,1) /= ' ' then Iterate
              tmpstring = Substr(DLINE,wherespace,whereback)
              Parse var tmpstring keyword '=' value ' '
              End
           End
        value = Strip(value,'T',',')
        If answer /= 'X' then,
           Say 'keyword   =' keyword " value=" value
        my# = my# + 1
        myout.my# = keyword "= '"|| value || "'"
        If answer /= 'X' then,
           Do; Say 'Continue?'; pull answer; End
        if answer = 'N' then Leave
        if answer = 'T' then Trace ?R
     End /* Do Forever */
     "Alloc F(SAVMODEL) DA('" ]]MyMODELDsn ]]"(" ]]MEMBER ]] ")')",
            "SHR REUSE"
     myout.0 = my#
     "EXECIO  *    DISKW SAVMODEL (Stem myout. Finis"
     "FREE  F(SAVMODEL)"
     Exit
FindVariableBegining:
     Do 10
        whereback= whereback - 1
        If whereback < 1 then Leave
        prevchar = Substr(DLINE,whereback,1)
        if prevchar = ',' ] prevchar = '/' then,
           Do
           DLINE = Overlay(' ',DLINE,whereback)
           Leave
           End
        if prevchar = ' ' then Leave
     End /* Do 10 */
     Return
