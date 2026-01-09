   /*   REXX  */
   PARSE ARG Parm1 Parm2

/* Check to see if Parm1 is selected (or matches) Parm2  */
/* Allowing for Parm2 to have wildcard characters        */

   If Parm1 = Parm2 then Return(1)

   If Parm1 ='*' | Parm2 ='*'    then Return(1)
   whereAsterisk = Pos('*',Parm2)
   If whereAsterisk = 0 then Return(0)
   If whereAsterisk > 1 then whereAsterisk = whereAsterisk - 1;

   If Substr(Parm1,1,whereAsterisk) = ,
      Substr(Parm2,1,whereAsterisk) then Return(1)

   Return(0)

