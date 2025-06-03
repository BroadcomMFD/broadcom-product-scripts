/*  REXX */
/*  Bump the last character on a Jobname to next value */
 Trace O
 Arg jobname;
 Rotation = '12345678901',
            'ABCDEFGHIJKLMNOPQRSTUVWXYZA',
            '@#$@'
 jobname = word(jobname,1)
 lastchar = Substr(jobname,Length(jobname))
 wherenext = Pos(lastchar,Rotation) + 1
 overlaychar = Substr(Rotation,wherenext,1)
 nextJobname = overlay(jobname,overlaychar,Length(jobname))
 nextJobname = overlay(overlaychar,jobname,Length(jobname))
 Return nextJobname
