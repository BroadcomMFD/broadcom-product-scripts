/* REXX */
  Trace Off
  Parse Arg where remoteTime DaysIncrement
/* See https://timeapi.io/    and                           */
/*     https://timeapi.io/swagger/index.html                */
/* Set up the variables for running Python */
/* Convert local date+time to remote date+time */
/* Convert Remote time to local time                        */
/*  Adjust Date if necessary, or given a date adjustment    */

  localDate = DATE('S')
  localDateFormatted =,
  Substr(localDate,1,4)"-"Substr(localDate,5,2)"-"Substr(localDate,7)
  localTime = TIME()
  HereandNow = localDateFormatted localTime

  command =,
   'cd /u/users/NDVRTeam/venv/lib/python3.11/site-packages; '
  command= command || 'python TimeZoneConvert.py '
  command= command || where localDateFormatted remoteTime
  stdout.0 = 0
  stderr.0 = 0
  stdin.0 = 0

  EXPORT_PATH='/usr/lpp/IBM/cyp/v3r11/pyz/bin:/bin'
  env.0 = 4
  env.1 = 'PATH=' || EXPORT_PATH
  env.2 = 'LIBPATH=/usr/lpp/IBM/cyp/v3r11/pyz/lib'
  env.3 = '_BPXK_AUTOCVT=ON'
  env.4 = '_CEE_RUNOPTS=FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)'

/* Call Python to parse the data */
/*                                                          */
  call bpxwunix command,stdin.,stdout.,stderr.,env.
/* Print the output from running Python */
  Do i=1 to stdout.0
     say i stdout.i
     pyoutput = stdout.i
     whereConversion  = Pos('conversionResult:',pyoutput)
     If whereConversion > 0 & whereConversion < 5 then,
        Do
        wheredateTime = Pos("dateTime':",pyoutput);
        if wheredateTime = 0 then Iterate
        Trace r
        ResultDateTime =,
           Word(Substr(pyoutput,wheredateTime+10),1)
        ResultDateTime =,
           Strip(Translate(ResultDateTime," ",",'T")) ;
        ReturnDate =  Word(ResultDateTime,1)
        ReturnTime =  Word(ResultDateTime,2)

        TriggerBaseDate = DATE('B',localDate,'S')
        sa = HereandNow
        sa = ResultDateTime
        If ReturnDate > localDateFormatted |,
           ReturnTime < localTime then,
           TriggerBaseDate = TriggerBaseDate + 1

        If DaysIncrement > '0' then,
           TriggerBaseDate = TriggerBaseDate + DaysIncrement
        ReturnDate = DATE('S',TriggerBaseDate,'B')

        Return ReturnDate ReturnTime
        End
  end
  do i=1 to stderr.0
     say i stderr.i
  end
  Return "Unsuccessful"
