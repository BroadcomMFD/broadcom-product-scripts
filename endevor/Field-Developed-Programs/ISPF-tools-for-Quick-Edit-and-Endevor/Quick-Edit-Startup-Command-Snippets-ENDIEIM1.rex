


/*  Quick-edit has its own item like an EXIT04, but named ENDIEIM1.           */
/*  It is the "Session Startup" command, an "edit macro".                     */
/*  This snippet shows the kinds of commands you can use in ENDIEIM1          */

/*----------------------------------------------------------------------------*/

/*  Turn off numbering and turn on Hilite                                     */ 
       ADDRESS ISREDIT 'NUMBER NOSTD'                                   
       ADDRESS ISREDIT 'HILIGHT ON'                                     

/*----------------------------------------------------------------------------*/

/* Here is a sample code snippet you can use to execute JCLChek for JCL       */
/*  Use LINE to determine whether/not CReating a new element         */ 
/*      LINE=0 if new                                                */ 
       "ISREDIT (LINE) = CURSOR"                                        

   IF SUBSTR(ENVBTYP,1,3) = "JCL" &,                
      LINE > 0 THEN,                                
        ADDRESS ISREDIT "EJCK"  ;                   


                                                    




