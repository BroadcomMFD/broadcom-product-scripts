/*     REXX   */                                                        
/*  DETERMINE WHETHER A DATASET OR DATASET(MEMBER) EXISTS           */  
/*     OR IS EMPTY. RC=2 if found not empty.   */                       
/*                  RC=0 if not found/empty.   */                       
   /* WRITTEN BY DAN WALTHER */                                         
    TRACE OFF;                                                          
    PARSE UPPER ARG DSN ;                                               
    X = DSN ;                                                           
    IF LENGTH(DSN) = 0 THEN EXIT(0)  ;                                  
    DSN = STRIP(DSN)                                                    
    IF POS('(',DSN) > 0 & SUBSTR(DSN,LENGTH(DSN),1) /= ')' THEN,        
       DSN= DSN || ')'                                                  
    DSNCHECK = SYSDSN("'"DSN"'") ;                                      
    IF DSNCHECK /= 'OK' THEN EXIT(0) ;                                  
    "ALLOC F(TESTDD) DA('"DSN"') SHR REUSE"                             
    "EXECIO 1 DISKR TESTDD (STEM STMT. FINIS " ;                        
    IF STMT.0 > 0 THEN  EXIT(2)                                         
    EXIT(0) ;                                                           