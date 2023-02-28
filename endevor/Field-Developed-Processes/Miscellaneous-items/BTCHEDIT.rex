/*  REXX  */
/*                                                                   */
/*"CONTROL NOMSG NOSYMLIST NOCONLIST NOLIST NOPROMPT"                */
/*"ISPEXEC CONTROL RETURN ERRORS"                                    */
  TRACE R ;
  ARG DATA ;
  DATASET = WORD(DATA,1) ;
  MACRO   = WORD(DATA,2) ;

  DSNCHECK = SYSDSN("'"DATASET"'") ;
  IF DSNCHECK /= 'OK' &,
     DSNCHECK /= 'MEMBER NOT FOUND' THEN EXIT(8) ;

  ADDRESS ISPEXEC "EDIT DATASET('"DATASET"') ",
             "MACRO("MACRO")" ;
  EXIT (RC)
