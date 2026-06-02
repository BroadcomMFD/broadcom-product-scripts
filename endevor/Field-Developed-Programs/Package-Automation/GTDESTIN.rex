/*  Rexx     */
  Arg Destination
  /* Get values for HOST_DSN_PREFIX and REMOTE_DSN_PREFIX */
  /*     From the site definition                         */
  /*  Call CSV to Get Destination information             */
  HOST_DSN_PREFIX   = "?"
  REMOTE_DSN_PREFIX = "?"
  TRANS_DESC        = "?"
  TRANS_NODE        = "?"
  STRING = "ALLOC DD(C1MSGS1) DUMMY "
  STRING = "ALLOC DD(C1MSGS1) SYSOUT(A) "
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(BSTERR) SYSOUT(A) "
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(BSTAPI) DUMMY "
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(DESTINFO) LRECL(4000) BLKSIZE(32000) ",
             " DSORG(PS) ",
             " SPACE(1,5) RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
  CALL BPXWDYN STRING;
  STRING = "ALLOC DD(BSTIPT01) LRECL(80) BLKSIZE(800) ",
             " DSORG(PS) ",
             " SPACE(1,5) RECFM(F,B) TRACKS ",
             " NEW UNCATALOG REUSE ";
  CALL BPXWDYN STRING;
  QUEUE "LIST DESTINATION '"Destination"'"
  QUEUE "     TO DDNAME 'DESTINFO' "
  QUEUE "     . "
  "EXECIO" QUEUED() "DISKW BSTIPT01 (FINIS ";
  CALL BPXWDYN "INFO FI(CONLIB) INRTDSN(DSNVAR) INRDSNT(myDSNT)"
  if RESULT = 0 then,
     Do
     CSVParm = 'DDN:CONLIB,BC1PCSV0'
     ADDRESS LINKMVS 'CONCALL' "CSVParm"
     End
  Else,
     ADDRESS LINK 'BC1PCSV0'   ;  /* load from authlib */
  call_rc = rc ;
  Drop apiDestinations.
  "EXECIO * DISKR DESTINFO (STEM apiDestinations. finis"
  IF apiDestinations.0 < 1 then,
     Return HOST_DSN_PREFIX REMOTE_DSN_PREFIX TRANS_DESC TRANS_NODE
  /* CSV data heading - showing CSV variables */
  $table_variables= Strip(apiDestinations.1,'T')
  $table_variables = translate($table_variables,"_"," ") ;
  $table_variables = translate($table_variables," ",',"') ;
  $table_variables = translate($table_variables,"@","/") ;
  $table_variables = translate($table_variables,"@",")") ;
  $table_variables = translate($table_variables,"@","(") ;
  WantedCSVVariables= "HOST_DSN_PREFIX REMOTE_DSN_PREFIX ",
                      "TRANS_DESC TRANS_NODE",
  $detail = apiDestinations.2
  /* Parse CSV fields in the Detail record until done */
  Do $column =  1 to Words($table_variables)
     Call ParseDetailCSVline
  End
  CALL BPXWDYN "FREE DD(DESTINFO)" ;
  CALL BPXWDYN "FREE DD(BSTIPT01)" ;
  CALL BPXWDYN "FREE DD(C1MSGS1)" ;
  CALL BPXWDYN "FREE DD(BSTERR)" ;
  CALL BPXWDYN "FREE DD(BSTAPI)" ;
  If TRANS_DESC = 'LOCAL' then,
     REMOTE_DSN_PREFIX = HOST_DSN_PREFIX
  Return HOST_DSN_PREFIX REMOTE_DSN_PREFIX TRANS_DESC TRANS_NODE
ParseDetailCSVline:
  /* Find the data for the current $column */
  $dlmchar = Substr($detail,1,1);
  If $dlmchar = "'" then,
     Do
     SA= 'parsing with single quote '
     PARSE VAR $detail "'" $temp_value "'" $detail ;
     If Substr($detail,1,1) = ',' then,
        $detail = Strip(Substr($detail,2),'L')
     End
  Else,
  If $dlmchar = '"' then,
     Do
     SA= 'parsing with double quote '
     PARSE VAR $detail '"' $temp_value '"' $detail ;
     If Substr($detail,1,1) = ',' then,
        $detail = Strip(Substr($detail,2),'L')
     End
  Else,
  If $dlmchar = ',' then,
     Do
     SA= 'parsing with comma        '
     PARSE VAR $detail ',' $temp_value ',' $detail ;
     If Substr($detail,1,1)/= ',' then,
        $detail = "," || $detail
        $detail = Strip(Substr($detail,2),'L')   */
     End
  Else,
  If Words($detail) = 0 then,
     $temp_value = ' '
  Else,
     Do
     SA= 'parsing with comma        '
     PARSE VAR $detail $temp_value ',' $detail ;
     Sa= '$temp_value=>' $temp_value '<'
     End
  $temp_value = STRIP($temp_value) ;
  $rslt = $temp_value
  $rslt = Strip($rslt,'B','"')                             ;
  $rslt = Strip($rslt,'B',"'")                             ;
  if Length($rslt) < 1 then $rslt = ' '
  thisVariable = WORD($table_variables,$column)
  If Wordpos(thisVariable,WantedCSVVariables) = 0 then Return
  if Length($rslt) < 250 then,
     $temp = WORD($table_variables,$column) '= "'$rslt'"';
  Else,
     $temp = WORD($table_variables,$column) "=$rslt"
  INTERPRET $temp;
  If rec# < 3 then Say Destination  $temp
  RETURN ;
/* ////  Routines to support Package Shipments from NOTES \\\\ */
