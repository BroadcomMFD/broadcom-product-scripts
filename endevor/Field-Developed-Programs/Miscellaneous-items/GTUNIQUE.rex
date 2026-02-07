 /*  REXX   */
 /* Build a unique 8-byte name from date and time  */

   numbers    = '123456789' ;
   characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;
   ToDay = DATE(O) ;
   Year = SUBSTR(ToDay,1,2) + 1;
   Year = SUBSTR(characters||characters||characters||characters,Year,1)
   Month = SUBSTR(ToDay,4,2) ;
   Month = SUBSTR(characters,Month,1) ;
   Day = SUBSTR(ToDay,7,2) ;

   Day = SUBSTR(characters || numbers,Day,1) ;
   NOW  = TIME() ;
   Hour = SUBSTR(NOW,1,2) ;
   IF Hour = '00' THEN Hour = '0'
   ELSE
   Hour = SUBSTR(characters,Hour,1) ;
   Minute = SUBSTR(NOW,4,2) ;
   second = SUBSTR(NOW,7,2) ;
   Unique_Name = Year || Month || Day || Hour ||,
         Minute || second ;
   SA= "Unique Member name is " Unique_Name

   Return Unique_Name
