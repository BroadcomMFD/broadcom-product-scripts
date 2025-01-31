/* REXX - User Routine Sample to submit a TEST4Z Unit Test.                     
   Kick off a Test4Z job                                                        
*/                                                                              
Trace OFf                                                                       
                                                                                
CALL BPXWDYN "INFO FI(NDUSRXTU) INRTDSN(DSNVAR) INRDSNT(myDSNT)"                
if RESULT = 0 then Testing = 'Y'                                                
If Testing = 'Y' then Trace Off                                                 
                                                                                
/* Enter your Site selected values here */                                      
 T4ZLibraryPrefix = USERID()                                                    
 T4ZLibraryPrefix = 'PUBLIC'                                                    
 SHOWJCL = 'N'                                                                  
                                                                                
parse arg PassParm                        /* The Parm tells us what variable  */
PassName = strip(PassParm,,"'")           /* holds the varialbe names, remove */
ADDRESS ISPEXEC "VGET ("PASSNAME") SHARED"/* ANY QUOTES AND GET THESE NAMES   */
interpret 'ALLVALS = 'PassName            /* use interpret to expand the names*/
ADDRESS ISPEXEC "VGET ("ALLVALS") SHARED" /* and get those values */            
ADDRESS ISPEXEC "VGET (MYJCLLIB)  PROFILE"                                      
USERDESC = EEVBCOM                        /* ...description */                  
USERDAT1 = SUBSTR(EEVEUSRD,01,40)         /* The EEVEUSRD is 80 bytes, tailor */
USERDAT2 = SUBSTR(EEVEUSRD,41,40)         /* this bit to split it into chunks */
USERUSER = EEVETSO                        /* ...Signout UserID                */
                                                                                
ADDRESS ISPEXEC "VPUT (USERDAT1 USERDAT2",  /* Make vars available            */
    "USERDESC USERPGRP USERLCCI USERGCCI",  /*                                */
    "USERRCCI USERUSER ) SHARED"            /*                                */
                                                                                
 LOADLIB = ''                                                                   
 Call USE_APIAEELM ;                                                            
                                                                                
 tmpload = Translate(LOADLIB,' ','.')                                           
 uptoLastnode= WordIndex(tmpload,Words(tmpload)) - 1                            
 JSONLIB = Substr(LOADLIB,1,uptoLastnode) || 'JSON'                             
 JSONLIB = T4ZLibraryPrefix'.'EEVETKSY'.'EEVETKEL'.JSON'                        
 COVERLIB= Substr(LOADLIB,1,uptoLastnode) || 'ZLCOVER'                          
 COVERLIB= T4ZLibraryPrefix'.'EEVETKSY'.'EEVETKEL'.ZLCOVER'                     
 T4ZLOAD1= Substr(LOADLIB,1,uptoLastnode) || 'T4ZLOAD'                          
                                                                                
/* Enter your choice for setting default values for these */                    
ADDRESS ISPEXEC "VGET (T4ZLOAD2 TSTSUITE)  PROFILE"                             
If Length(T4ZLOAD2) < 8 then,                                                   
   T4ZLOAD2 = ''                                                                
If Length(TSTSUITE) < 8 then,                                                   
   TSTSUITE  = EEVETKEL                                                         
                                                                                
                                                                                
ADDRESS ISPEXEC "ADDPOP"                  /* Show the panel in a pop-up       */
ADDRESS ISPEXEC "DISPLAY PANEL(NDUSRPTU)" /* Then show the panel              */
if rc > 0 then                            /* Did use hit END or RETURN?       */
do                                                                              
   ADDRESS ISPEXEC "REMPOP"               /* Remove the popup                 */
   ADDRESS ISPEXEC "SETMSG MSG(ENDE046E)" /* Request cancelled                */
   exit 0                                 /* and get out (no changes)         */
end                                                                             
                                                                                
 /* Look in MYJCLLIB to see if the element has a member     */                  
 thisT4ZJcl = MYJCLLIB"("EEVETKEL")"                                            
 DSNCHECK = SYSDSN("'"thisT4ZJcl"'") ;                                          
 IF DSNCHECK /= 'OK' then,                                                      
    Do                                                                          
    Say "NDUSRXTU- Expecting a member named" EEVETKEL "in" MYJCLLIB '.'         
    Say "NDUSRXTU- Not finding one and cannot submit a TEST4Z job. "            
    Exit(8)                                                                     
    End                                                                         
                                                                                
ADDRESS ISPEXEC "REMPOP"                  /* Remove the popup                 */
ADDRESS ISPEXEC "VGET (USERDAT1 USERDAT2",  /* Get the values again           */
    "USERDESC USERPGRP USERLCCI USERGCCI",  /*                                */
    "USERRCCI USERUSER ) SHARED"            /*                                */
                                                                                
   ADDRESS ISPEXEC "FTOPEN TEMP"                                                
   ADDRESS ISPEXEC "FTINCL T4ZUTEST"                                            
   ADDRESS ISPEXEC "FTCLOSE " ;                                                 
   ADDRESS ISPEXEC "VGET (ZUSER ZTEMPF ZTEMPN) ASIS" ;                          
                                                                                
   DEBUG = 'YES' ;                                                              
   DEBUG = 'NAW' ;                                                              
   If Testing = 'Y' then DEBUG = 'YES' ;                                        
   If SHOWJCL = 'Y' then DEBUG = 'YES' ;                                        
                                                                                
   X = OUTTRAP("OFF")                                                           
   ADDRESS ISPEXEC "VPUT (T4ZLOAD1 T4ZLOAD2 TSTSUITE)  PROFILE"                 
                                                                                
   IF DEBUG = 'YES' THEN,                                                       
      DO                                                                        
      ADDRESS ISPEXEC "LMINIT DATAID(DDID) DDNAME(&ZTEMPN)"                     
      ADDRESS ISPEXEC "EDIT DATAID(&DDID)"                                      
      ADDRESS ISPEXEC "LMFREE DATAID(&DDID)"                                    
      END;                                                                      
   ELSE,                                                                        
      ADDRESS TSO "SUBMIT '"ZTEMPF"'" ;                                         
                                                                                
   exit 0                                 /* and get out (no changes)         */
                                                                                
USE_APIAEELM :                                                                  
                                                                                
   ADDRESS TSO                                                                  
/*                                                                   */         
    "ALLOC F(SYSPRINT) DUMMY REUSE " ;                                          
    "ALLOC F(SYSOUT) DUMMY REUSE " ;                                            
    "ALLOC F(SYSIN) LRECL(80) BLKSIZE(0) SPACE(5,5)",                           
           "RECFM(F B) TRACKS ",                                                
           "NEW UNCATALOG REUSE "     ;                                         
    "ALLOC F(MSGFILE) LRECL(133) BLKSIZE(13300) SPACE(5,5)",                    
           "RECFM(F B) TRACKS ",                                                
           "NEW UNCATALOG REUSE "     ;                                         
    "ALLOC F(ELEMLIST) LRECL(2048) BLKSIZE(22800) SPACE(5,5)",                  
           "RECFM(V B) TRACKS DSORG(PS) ",                                      
           "DA('"USERID()".DANST4Z.NOTIFY."ENVELM"')",                          
           "MOD CATALOG REUSE "     ;                                           
  /*                                                                */          
  /*    V - COLUMN 6 = FORMAT SETTING                               */          
  /*      = ' ' FOR NO FORMAT, JUST EXTRACT ELEMENT                 */          
  /*      = 'B' FOR ENDEVOR BROWSE DISPLAY FORMAT                   */          
  /*      = 'C' FOR ENDEVOR CHANGE DISPLAY FORMAT                   */          
  /*      = 'H' FOR ENDEVOR HISTORY DISPLAY FORMAT                  */          
  /*    V - COLUMN 7 = RECORD TYPE SETTING                          */          
  /*      = 'E' FOR ELEMENT                                         */          
  /*      = 'C' FOR COMPONENT                                       */          
  /*       VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME                 */          
  /*               V - COLUMN 18 = STAGE ID                         */          
  /*                VVVVVVVV - COLUMN 19-26 SYSTEM NAME             */          
  /*                        VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME  */          
  /*   COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV                      */          
  /*   COLUMN 45-52 = TYPE NAME               VVVVVVVV              */          
  /*                                                                */          
                                                                                
       Do map# = 1 to Words(DANST4ZMapList)                                     
          QUEUE 'AACTL MSGFILE ELEMLIST'      /* Another search ... */          
          TEMP= COPIES(" ",80);                                                 
          TEMP= Overlay('AEELMBC ',TEMP,1) ;                                    
          TEMP= Overlay(EEVETKEN,TEMP,10) ;      /*      Env        */          
          TEMP= Overlay(EEVETKSI,TEMP,18) ;      /*      stg id     */          
          TEMP= Overlay(EEVETKSY,TEMP,19) ;      /*      Sys        */          
          TEMP= Overlay(EEVETKSB,TEMP,27) ;      /*      Sub        */          
          TEMP= Overlay(EEVETKEL,TEMP,35) ;      /*      Ele        */          
          TEMP= Overlay(EEVETKTY,TEMP,45) ;      /*      Typ        */          
          SA= TEMP;                                                             
          QUEUE TEMP ;                                                          
          QUEUE 'RUN' ;                                                         
       End /* Do map# = 2 to Words(DANST4ZMapList) */                           
                                                                                
       QUEUE 'AACTLY ' ;                                                        
       QUEUE 'RUN' ;                                                            
       QUEUE 'QUIT' ;                                                           
       ADDRESS TSO,                                                             
       "EXECIO" QUEUED() "DISKW SYSIN (FINIS "                                  
       RETURN_RC = 0  ;                                                         
       ADDRESS TSO "PROFILE NOWTPMSG " ;                                        
                                                                                
       ADDRESS ISPEXEC "SELECT PGM(ENTBJAPI)" ;                                 
       IF RC > 0 THEN,                                                          
          DO                                                                    
          SA= 'CANNOT GET INFORMATION FROM ENDEVOR' ;                           
          EXIT                                                                  
          END ;                                                                 
       RETURN_RC = RC ;                                                         
                                                                                
    ADDRESS TSO,                                                                
     "EXECIO * DISKR ELEMLIST (STEM LIST. FINIS" ;                              
                                                                                
    "FREE F(SYSPRINT)"                                                          
    "FREE F(SYSOUT)  "                                                          
    "FREE F(SYSIN)   "                                                          
    "FREE F(MSGFILE) "                                                          
    "FREE F(ELEMLIST)"                                                          
                                                                                
    /* Inspect the output of the API call */                                    
    Found_OUTPUT_COMPONENTS = 'N'                                               
    Do i = list.0 by -1 to 1                                                    
      out= list.i                                                               
      If Pos(' DD=SYSLMOD ', out) = 0 &,                                        
         Pos(' DD=OUTDD   ', out) = 0 then Iterate                              
      whereDSN = Pos('DSN=',out)                                                
      if whereDSN = 0 then Iterate                                              
      tmpLOADLIB = Word(Substr(out,whereDSN + 4),1)                             
      If Pos('.LOAD',tmpLOADLIB) = 0 then Iterate                               
      LOADLIB = tmpLOADLIB                                                      
      Leave                                                                     
    End /* Do i = 1 to list.0 */                                                
                                                                                
    If LOADLIB = '' then,                                                       
       Do                                                                       
       Say "NDUSRXTU- Unable to find output load library"                       
       Say "NDUSRXTU- Bypassing the submit for a TEST4Z job. "                  
       Exit(8)                                                                  
       End                                                                      
                                                                                
   Return ;                                                                     
                                                                                
