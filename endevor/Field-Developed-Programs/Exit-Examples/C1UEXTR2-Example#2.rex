/*
The REXX C1UEXTR2 is intended to be run from the Endevor EXIT 2
program C1UEXT02. All the Endevor variables required will be passed
by a parm and interpreted into variables. Values that are to be passed
back to the exit(C1UEXT02) will be changed using the storage command.

Sample Routines:
 FIND_ELEMENT - This routine runs  ndevor List API. It will scan the
     entire map for all occurrences or the Element being added or
     updated.  The Element name will be searched for the same System,
     Subsystem and Type. The current logic checks if the Element exists
     in a specific Environment(ENV2) and Stage(STG4). If it exists, the
     signout userid will be checked. If it does not match a specific
     id (ROZRIA1) a warning message is produced.

 Update_CCID - If CCID is left blank, then apply last used CCID

 Update_COMMENT - If COMMENT is left blank, then apply last used COMMENT

*/
  Trace Off

   /*allocate files that may be required for rexx processing*/
   STRING = "ALLOC DD(SYSTSPRT) SYSOUT(A) "
   CALL BPXWDYN STRING;

   STRING = "ALLOC DD(SYSTSIN) DUMMY  "
   CALL BPXWDYN STRING;

   /* If DD C1UEXTR2 is allocated turn on Trace  */
   WhatDDName = 'C1UEXTR2'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   rexx_trace=N  /*set the trace (display file) */
   if Substr(DSNVAR,1,1) /= = ' ' then
   do
     rexx_trace=Y
     trace ?R
   end
   /* If EN$TREXT is allocated to anything, turn on Trace  */
   WhatDDName = 'EN$TREXT'
   CALL BPXWDYN "INFO FI("WhatDDName")",
              "INRTDSN(DSNVAR) INRDSNT(myDSNT)"
   if Substr(DSNVAR,1,1) /= = ' ' then
   do
   /*rexx_trace=Y */
     trace ?R
   end

   /*get the parms that are passed from the exit C1UEXT02*/
   Arg Parms
   Parms = Strip(Parms) /*trim the spaces*/
   sa= 'Parms len=' Length(Parms)

   /* Parms from C1UEXT02 is a string of REXX statements   */
   Interpret Parms
   MyRc = 0  /*return code that will be passed back to Endevor*/
   Message ='' /*Message that is passed back to Endevor*/
   /*message code is a 4 diget number. First diget is truncated.
     the message text can be found in CSIQMENU in the members
     starting with CIUU*/
   MessageCode = '    '

   /* select processing if the current action is Add or Update*/
   IF (SPACE(ECB_ACTION_NAME) = 'UPDATE') | ,
      (SPACE(ECB_ACTION_NAME) = 'ADD') THEN
      CALL FIND_ELEMENT  /*call procedure find_element*/

/* If CCID is left blank, then apply last used CCID  */
/* If REQ_CCID = COPIES(' ',12) then Call Update_CCID; */

   /* If COMMENT is left blank, then apply last used COMMENT */
 /*If REQ_COMMENT = COPIES(' ',40) then Call Update_COMMENT; */

 /*If REQ_SISO_INDICATOR = 'Y' then
      Do
      Message = 'Remember that you have set OVERRIDE SIGNOUT'
      MyRc        = 4
      End

   If ECB_USER_ID = '???JO11' then,
      Do
      Message = 'Hello Dan.  You have a msg'
      MessageCode = '0920'
      MyRc        = 4
      End */

/* wrap up Rexx exec. will check return code and messages before exit*/

   /*clean exi return code 0*/
   If MyRc = 0 then Exit

   /*if a message test is found write it back to
     ECB_MESSAGE_TEXT*/
   If Message /= '' then,
      Do
      hexAddress = D2X(Address_ECB_MESSAGE_TEXT)
      storrep = STORAGE(hexAddress,,Message)
      hexAddress = D2X(Address_ECB_MESSAGE_LENGTH)
      storrep = STORAGE(hexAddress,,'0084'X)
      End

   /*if a message code is found write it back to
     ECB_MESSAGE_code*/
   If MessageCode /= '    ' then,
      Do
      hexAddress = D2X(Address_ECB_MESSAGE_CODE)
      storrep = STORAGE(hexAddress,,MessageCode)
      End

   /*if the return code is 4 or 8 write it back to
     ECB_RETURN_CODE */
   hexAddress = D2X(Address_ECB_RETURN_CODE)
   If MyRc = 4 then,
      storrep = STORAGE(hexAddress,,'00000004'X)
   Else,
      storrep = STORAGE(hexAddress,,'00000008'X)

   Exit

/*****************************************
this routine will change the ccid
******************************************/
Update_CCID:

   IF SRC_ENV_TYPE_OF_BLOCK = 'C' then,
      Replace_CCID = SRC_ELM_ACTION_CCID
   Else,
      Replace_CCID = TGT_ELM_ACTION_CCID

   If Replace_CCID = Copies(' ',12) then Return;

   hexAddress = D2X(Address_REQ_CCID)
   storrep = STORAGE(hexAddress,,Replace_CCID)
   MyRc = 4

   Return;

/*****************************************
this routine will change the comment
******************************************/
Update_COMMENT:

   IF SRC_ENV_TYPE_OF_BLOCK = 'C' then,
      Replace_COMMENT = SRC_ELM_LEVEL_COMMENT
   Else,
      Replace_COMMENT = TGT_ELM_LEVEL_COMMENT

   If Replace_COMMENT = Copies(' ',40) then Return;

   hexAddress = D2X(Address_REQ_COMMENT)
   storrep = STORAGE(hexAddress,,Replace_COMMENT)
   MyRc = 4

   Return;
/******************************************************************
     FIND_ELEMENT in the map (all over)
  *****************************************************************/
FIND_ELEMENT:

   /*free up any file that are used in the procedure*/
   CALL BPXWDYN "FREE DD(BSTAPI) MSG(MSG.)"
   CALL BPXWDYN "FREE DD(BSTERR) MSG(MSG.)"
   CALL BPXWDYN "FREE DD(SYSPRINT MSG(MSG.)"
   CALL BPXWDYN "FREE DD(SYSOUT) MSG(MSG.)"
   CALL BPXWDYN "FREE DD(SYSIN) MSG(MSG.)"
   CALL BPXWDYN "FREE DD(DDMSG) MSG(MSG.)"
   CALL BPXWDYN "FREE DD(DDOUT) MSG(MSG.)"
   /************************************************************/
   /* based on csiqcls0(ENTBRAPI) REXX exec.                   */
   /* Call the API utility program, ENTBJAPI, to build         */
   /* a response file containing a list of all occurrences of  */
   /* a element in the entire map.                             */
   /************************************************************/
   /************************************************************/

   /************************************************************/
   /* Allocate datasets                                        */
   /************************************************************/
   /* - Work Datasets            */
     CALL BPXWDYN "ALLOC DD(BSTAPI) DUMMY MSG(MSG.)"
     if rc > 0 then say '***ERROR in Alloc of BSTAPI'
     if msg.0 > 0 then
     do i=1 to msg.0
       say msg.i
     end
     CALL BPXWDYN "ALLOC DD(BSTERR) DUMMY MSG(MSG.)"
     if rc > 0 then say '***ERROR in Alloc of BSTERR'
     if msg.0 > 0 then
     do i=1 to msg.0
       say msg.i
     end
     CALL BPXWDYN "ALLOC DD(SYSPRINT) DUMMY MSG(MSG.)"
     if rc > 0 then say '***ERROR in Alloc of SYSPRINT'
     if msg.0 > 0 then
     do i=1 to msg.0
       say msg.i
     end
     CALL BPXWDYN "ALLOC DD(SYSOUT) DUMMY MSG(MSG.)"
     if rc > 0 then say '***ERROR in Alloc of SYSOUT'
     if msg.0 > 0 then
     do i=1 to msg.0
       say msg.i
     end

   /* - Input for ENTBJAPI utility */
     CALL BPXWDYN "ALLOC DD(SYSIN) ",
     "SPACE(1,1) CYL DSORG(PS) ",
     "LRECL(80) RECFM(FB) "
     if rc > 0 then say '***ERROR in Alloc of SYSIN'

   /* - API Message Dataset */
     CALL BPXWDYN "ALLOC DD(DDMSG) ",
     "SPACE(1,1) CYL UNIT(SYSDA) DSORG(PS) ",
     "LRECL(133) RECFM(FB) "
     if rc > 0 then say '***ERROR in Alloc of DDMSG'

     CALL BPXWDYN "ALLOC DD(DDOUT) ",
     "SPACE(1,1) CYL DSORG(PS) ",
     "LRECL(2048) RECFM(VB) "
     if rc > 0 then say '***ERROR in Alloc of DDOUT'

   /************************************************************/
   /* Build AACTL Structure Control Record                     */
   /************************************************************/
   /* - AACTL Structure Layout */
   /*   Keyword        CHAR 5  */
   /*   Shutdown flag  CHAR 1  */
   /*   MSG DDN        CHAR 8  */
   /*   LIST DDN       CHAR 8  */
   newstack
   queue "AACTLYDDMSG   DDOUT   "

   /************************************************************/
   /* Build Request Structure Control Record                   */
   /*  Note: Refer to the "Sample Inventory List Function Call */
   /*        - ENTBJAPI" section of the API Guide for the      */
   /*        layout of the request structures                  */
   /************************************************************/
   /* - ALSYS_RQ Request Structure Layout */
   /*   Keyword        CHAR 6  */
   /*   PATH           CHAR 1  */
   /*   RETURN         CHAR 1  */
   /*   SEARCH         CHAR 1  */
   /*   ENV            CHAR 8  */
   /*   STAGE ID       CHAR 1  */
   /*   SYSTEM         CHAR 8
   queue "ALSYS",                     Keyword
       ||         "LAN ",             Options
       ||         left(p_envir,8),    Environment name
       ||         "*",                Stage id
       ||         "*"                 System   */
   /* - ALELM_RQ Request Structure Layout
        Keyword        CHAR 5  (ALEM)
        PATH           CHAR 1  L - Logical P - Physical
        RETURN         CHAR 1  F - Return only the first record that satisfies
                                   the request.
                               A - Return all records that satisfy the request.
                                   Only choice when the environment is
                                   not explicit
        SEARCH         CHAR 1  A - Search All the way up the map.
                               B - Search Between the two specified environments
                                   and stages.
                               N - No Search. Only choice when the environment
                                   is not explicit.
                               E - Search next specified environment/stage then
                                   up the map.
                               R - Search the Range, between and including the
                                   specified environments and stages.
        BDATA          CHAR 1  B or Y - Return only the basic data. If this
                                   option If this option is enabled, use the
                                   ALELB_RS structure that is defined in
                                   ENHALELM to map the response data fields.
                               N or blank - Return all element master data.
                                   If this option is enabled, use the ALELM_RS
                                   structure that is defined in ENHALELM to map
                                   the response data fields.
                               S - Return element change level summary data.
                                   If this option is selected, use the ALELS_RS
                                   structure that is defined in ENHALELM
                                   to map the response data fields.
                               C - Return component change level summary data.
                                   If this option is selected, use the ALELS_RS
                                   structure that is defined in ENHALELM to map
                                   the response data fields.
                               For types B and N, you can optionally code
                               ALELM_RS_FDSN, ALELM_RS_TDSN, or both. You do so
                               to obtain extension records in addition to the ba
                               or full master data.
        FDSN           CHAR 1  Return the 'from' dataset-member/path-file data a
                               a response record (ALELM_RS_RECTYP=F).
                               Y - Return this data.
                               N - Do not return this data.
        TDSN           CHAR 1  Field length is one character. Return the 'target
                               dataset-member/path-file data as a response recor
                               (ALELM_RS_RECTYP=T).
                               Y - Return this data.
                               N - Do not return this data.
        ENV            CHAR 8
        STAGE ID       CHAR 1  (Stage ID or Stage Number)
        STAGE NUMBER   CHAR 1  (1 or 2)
        SYSTEM         CHAR 8
        SUBSYSTEM      CHAR 8
        ELM            CHAR 10
        TYPE           CHAR 8
        TOENV          CHAR 8  Ending Environment name. Used with the "B"etween
                               or "R"ange SEARCH options. A wildcard character
                               is not allowed.
        TOSTG ID       CHAR 1  Field length is one character. Ending Stage ID.
                               Used with the "B"etween or "R"ange SEARCH options
                               A wildcard character is not allowed.
     (Optional) TOELM  CHAR 10 To Element name. If specified, this field can
                               contain a wildcard.
        ELM_THRU       CHAR 10 Through Element name.
   */


   queue "ALELM",                  /* Keyword */
       ||         "LAAB",        /* Options */
       ||         left(TGT_ENV_ENVIRONMENT_NAME,8), /* Environment name */
       ||         "1",      /* STAGE NUMBER (as long as it's valid)*/
       ||         left(TGT_ENV_SYSTEM_NAME,8),    /* SYSTEM      */
       ||         left(TGT_ENV_SUBSYSTEM_NAME,8), /* SUBSYSTEM   */
       ||         left(TGT_ENV_ELEMENT_NAME,10), /* ELM         */
       ||         left(TGT_ENV_TYPE_NAME,8), /* TYPE        */
       ||         "        ",      /* TOENV       */
       ||         " ",             /* To Stage id */
       ||         "          ",    /* TOELM  */
       ||         "          "     /* ELM THRU */

   /************************************************************/
   /* Build ENTBJAPI RUN and quit Control Records              */
   /************************************************************/
   queue "RUN"
   queue "QUIT"

   /************************************************************/
   /* Write all the Control Records to the SYSIN file          */
   /************************************************************/
   "EXECIO 4 DISKW SYSIN (FINIS)"

   /************************************************************/
   /* Execute the API utility program                          */
   /************************************************************/
   "ENTBJAPI"

   "EXECIO  * DISKR DDMSG (STEM DDMSG. FINIS"
   /* display messages */
   if rexx_trace=Y then
   do
     say '---DD DDMSG:'DDMSG.0
     Do I= 1 to DDMSG.0
       say DDMSG.i
     end
   end

   "EXECIO  * DISKR DDOUT (STEM DDOUT. FINIS"

   /*go through the API output file*/
   Do I= 1 to DDOUT.0
     PARSE VAR DDOUT.I 15 TENV 23 TSYS 31 TSUBSYS 39 TELM 49 ,
               TTYPE 57 TSTAGE 65 95 SIGNOUT_ID 103 REST
     if rexx_trace=Y then
     do
       say DDOUT.i
       SAY '---Element 'I' of 'DDout.0 TELM
       SAY '           Env:'TENV 'Stage:'TSTAGE 'SIGNOU ID:' SIGNOUT_ID
     end
     IF (SPACE(TENV) = 'ENV2') & (SPACE(TSTAGE) = 'STG4') THEN
       IF SPACE(SIGNOUT_ID) = 'ROZRIA1' THEN
         nop
       else
       do
         /*the message variable will be passed back to Endevor
           in this case it will be show in the file as per the long
           message*/
         Message = 'Not Signed out to ROZRIA1'
         /*passing back return code 8 so the add/update stops*/
         /*a rc of 4 will process request. A warming messahe will
           appear in the Endevor messages*/
         MyRc        = 4
       end
   end
   /************************************************************/
   /* Free allocations                                         */
   /************************************************************/
   CALL BPXWDYN "FREE DD(BSTAPI)"
   CALL BPXWDYN "FREE DD(BSTERR)"
   CALL BPXWDYN "FREE DD(SYSPRINT)"
   CALL BPXWDYN "FREE DD(SYSOUT)"
   CALL BPXWDYN "FREE DD(SYSIN)"
   CALL BPXWDYN "FREE DD(DDMSG)"
   CALL BPXWDYN "FREE DD(DDOUT)"
   RETURN
