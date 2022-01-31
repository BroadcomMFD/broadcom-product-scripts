/*  REXX   */
/* Names the member that contains your site-specific settings. */
WhereIam =  Strip(Left("@"MVSVAR(SYSNAME),8)) ;
Say 'WhereIam =' WhereIam
EXIT
