/*    REXX     */                                                       
   'ISREDIT MACRO (STRT STOP)'                                          
/* ARG START_COL STOP_COL ;                                          */ 
   ADDRESS ISREDIT;                                                     
/* While Viewing or Editing  a file that has repeating and sorted    */ 
/*  data, use SQUASH and start and ending column values.             */
/*   Squash will show the first of each unique value in the range,   */
/*  but exclude repeating. For example:SQUASH 1 20                   */  
/*
----+----1----+----2----+----3----+----4----+----5----+----6----+----7-
  FINANCE  ACCTREC     COB    BATCH        3                           
-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  7 Line(s) not Displayed
  WHATEVER ACCTREC     ASM    BATCH        5                           
-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  1 Line(s) not Displayed
  FINANCE  ACCTPAY     ASM    CICS        10                           
-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  2 Line(s) not Displayed
*/
/* Shows that the first 8 records have the same value in cols 1- 20   */
/* the next two records have the same value in cols 1-20              */    
/* and the last 3 records have the same value in cols 1-20            */                                                          */ 
   START_COL = STRT;                                                    
   STOP_COL  = STOP ;                                                   
   IF START_COL < 1 THEN START_COL = 1 ;                                
   IF STOP_COL  < 1 THEN STOP_COL = 80 ;                                
   IF STOP_COL  < START_COL THEN STOP_COL = START_COL ;                 
   LEN = STOP_COL - START_COL + 1;                                      
   RC = 0;                                                              
   LASTLINE = '' ;                                                      
    "FIND P'=' 1 FIRST "                                                
   DO UNTIL RC > 0                                         
     "(LP CP)=CURSOR"                                      
     "(DATALINE)=LINE" LP                                  
     IF SUBSTR(LASTLINE,START_COL,LEN) =,                  
        SUBSTR(DATALINE,START_COL,LEN) THEN,               
        "EXCLUDE P'=' "                                    
    LASTLINE = DATALINE ;                                  
    "FIND P'=' 1 NX NEXT"                                  
     END;                                                  
