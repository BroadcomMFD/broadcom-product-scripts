 /*  REXX   */
 /* Build a unique 8-byte name from date and time to 10'th of second */
   numbers    = '123456789' ;
   characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;
   ToDay = DATE(O) ;
   Year = SUBSTR(ToDay,1,2) + 1;
   Year = SUBSTR(characters||characters||characters||characters,Year,1)
   Month = SUBSTR(ToDay,4,2) ;
   Month = SUBSTR(characters,Month,1) ;
   Day = SUBSTR(ToDay,7,2) ;
   Day = SUBSTR(characters || numbers,Day,1) ;
   Now  = TIME('L') ;
   Hour = SUBSTR(Now,1,2) ;
   IF Hour = '00' THEN Hour = '0'
   ELSE
      Hour = SUBSTR(characters,Hour,1) ;
   Minute = SUBSTR(Now,4,2) ;
   second = SUBSTR(Now,7,2) ;
   MinSecs = Minute || second || Substr(Now,10,1)
   MinSecsHx = Right(D2X(MinSecs),4,'0')
   Unique_Name = Year || Month || Day || Hour || MinSecsHx
   SA= "Unique Member name is " Unique_Name
   Return Unique_Name
