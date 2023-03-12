/*  REXX  */
/*  Cause a wait until the designated time arrives */
/*                                                 */
/*  Example:  StartTime = '17:00:00'               */
  Trace Off
  Arg StartTime;
  whattimeisit = TIME('N')
  If whattimeisit >= StartTime then Return;
  Parse var StartTime  StHours ':' StMinutes ':' StSeconds
  Parse var whattimeisit Hours ':' Minutes ':' Seconds
  WaitTime = (StHours-hours)*60*60
  WaitTime = WaitTime + (StMinutes-Minutes)*60
  WaitTime = WaitTime + (StSeconds-Seconds)
  Say 'Waiting until :' StartTime 'from now -' whattimeisit,
      ' for' WaitTime 'seconds'
  Call WAITSECS WaitTime

  Exit
