/*  REXX   */
/* Names the member that contains your site-specific settings. */
/* Override to another value if you prefer --->   */
WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
Return (WhereIam)
