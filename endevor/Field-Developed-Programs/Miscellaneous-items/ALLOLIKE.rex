/*   REXX      WRITTEN BY DAN WALTHER                                  
     ALLOCATES A DATASET MODELED AFTER ANOTHER DATASET.                
     THE NEW AND 'MODEL' DATASET NAMES ARE PASSED AS ARGUMENTS.  */    
    TRACE R;                                                           
PARSE UPPER ARG NEWDSN LIKEDSN .                                       
TEMP = LISTDSI("'"LIKEDSN"'" RECALL)                                   
"ALLOC DA('"NEWDSN"')  BLKSIZE("SYSBLKSIZE") NEW LIKE ('"LIKEDSN"')",  
  " DSORG("SYSDSORG") EXPDT("SYSEXDATE") "                             
"FREE  DA('"NEWDSN"')"                                                 
EXIT                                                                   

