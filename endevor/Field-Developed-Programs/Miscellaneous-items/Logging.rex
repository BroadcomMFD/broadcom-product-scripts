/* REXX */
Arg debug
 trace O
   JobName = MVSVAR('SYMDEF',JOBNAME ) /*Returns JOBNAME */
/**********************************************************************
*
*  Capture outputs for the active job
*
*  SDSF RGEN Generated EXEC
*
*  Operation =
*
*    - Access primary panel DA
*    - Invoke browse
*
**********************************************************************/
rc=isfcalls('ON')
if debug<>"" then   /* If debug mode */
  verbose="VERBOSE"  /* .. use SDSF verbose mode */
else
  verbose=""
/*----------------------------------------------*/
/* Configure environment with special variables */
/*----------------------------------------------*/
isfprefix='*'    /* Corresponds to PREFIX command */
isfprefix=JobName
isfowner=USERID()'*'    /* Corresponds to OWNER command */
isfsysname=''   /* Corresponds to SYSNAME command */
isfdest=' ' || ,    /* Dest name 1 */
        ' ' || ,    /* Dest name 2 */
        ' ' || ,    /* Dest name 3 */
        ' '         /* Dest name 4 */
/* Access the DA panel */
Address SDSF "ISFEXEC 'DA' (" verbose ")"
lrc=rc
call msgrtn  "ISFEXEC 'DA'"   /* List messages */
if lrc<>0 then   /* If command failed */
  do
    Say "** ISFEXEC failed with rc="lrc"."
    exit 20
  end
call colsrtn isfrows "." sdsfocols  /* List all rows and columns */
isflinelim = 1000
/*--------------------*/
/* Loop for all lines */
/*--------------------*/
do until isfstartlinetoken=''
  /*--------------------------------------------------------------*/
  /* Issue ISFBROWSE for the row identified by the token variable */
  /*--------------------------------------------------------------*/
  Address SDSF "ISFBROWSE 'DA' TOKEN('"TOKEN.1"') (" verbose ")"
  lrc=rc
  call msgrtn "ISFBROWSE"  /* List messages associated with request */
  if lrc<>0 then   /* If request failed */
    do
      Say "** ISFBROWSE failed with rc="lrc"."
      Exit 20
    end
  isfstartlinetoken=isfnextlinetoken  /* Set up for next request */
  /*---------------------*/
  /* List returned lines */
  /*---------------------*/
  "EXECIO * DISKW LOGGING (Stem isfline. finis"
/*
  do lineix=1 to isfline.0  /* Loop for all lines returned */
    say isfline.lineix
  end
*/
end
rc=isfcalls('OFF')
Exit 0
/**********************************************************************
*
* NAME =
*   msgrtn
*
* FUNCTION =
*   List all messages in the isfmsg and isfmsg2. variables
*
* INPUT =
*   req - Request being processed
*
* EXPOSED VARIABLES =
*   isfmsg   - Short message
*   isfmsg2. - Numbered messages
*
* OUTPUT =
*   Messages written to terminal
*
**********************************************************************/
msgrtn: Procedure expose isfmsg isfmsg2.
Arg req
/*---------------------------*/
/* Process numbered messages */
/*---------------------------*/
Say "** Numbered messages associated with" req "follow ..."
do ix=1 to isfmsg2.0
  Say isfmsg2.ix
end
if isfmsg<>"" then    /* If short message present */
  do
    Say "** Short message associated with the request is:" isfmsg
  end
return
/**********************************************************************
*
* NAME =
*   colsrtn
*
* FUNCTION =
*   List all rows and their column values
*
* INPUT =
*   numrows - number of rows to process
*   pfx     - column variable prefix or "." if none
*   ocols   - word delimited column names to process
*
* EXPOSED VARIABLES =
*   None
*
* OUTPUT =
*   Responses written to terminal
*
**********************************************************************/
colsrtn:
Arg numrows pfx ocols
Say "Number of rows to process: " numrows
do rowix=1 to numrows  /* Loop for all rows */
  Say "Now processing row" rowix "..."
  do colix=1 to words(ocols)  /* Loop for all columns */
    if pfx="." then   /* If no prefix */
      pfx=""
    varname=pfx||word(ocols,colix)||'.'||rowix
    Say "  Column" varname '=' value(varname)
  end     /* For all columns */
end   /* For all rows */
return
