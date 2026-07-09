/*     REXX   */                                                                
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".                      
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.                  
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE                   
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.  */         
/* https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main*/          
   ARG SAVEPDS ;                                                                
   TRACE O;                                                                     
   output = "SAVEMBMR" ;                                                        
/*                                                                   */         
   "EXECIO * DISKR MERGED (STEM DATA. FINIS " ;                                 
/*                                                                   */         
   Last_Element = " " ;                                                         
/*                                                                   */         
   Do ln = 1 to data.0                                                          
      COMPONENT = WORD(DATA.ln,01) ;                                            
      SYSTEM    = WORD(DATA.ln,02) ;                                            
      SUBSYSTEM = WORD(DATA.ln,03) ;                                            
      TYPE      = WORD(DATA.ln,04) ;                                            
      CUR_DATE  = WORD(DATA.ln,05) ;                                            
      CUR_TIME  = WORD(DATA.ln,07) ;                                            
/*    VERS_LEVL = WORD(DATA.ln,08) ; */                                         
      Environ   = WORD(DATA.ln,08) ;                                            
      STG_NUM   = WORD(DATA.ln,09) ;                                            
      element   = WORD(DATA.ln,10) ;                                            
      if ELEMENT /= Last_Element then,                                          
         DO                                                                     
         call Write_Element_Header ;                                            
         Last_element = ELEMENT ;                                               
         end;                                                                   
      call Reformat_fields ;                                                    
      call Write_component_info ;                                               
   END;  /* Do ln = 1 to data.0  */                                             
                                                                                
   "EXECIO 0 DISKW ACMQOUT (FINIS "                                             
                                                                                
   EXIT(RC) ;                                                                   
                                                                                
Write_Element_Header:                                                           
                                                                                
   IF Last_Element /= " " then,                                                 
      do                                                                        
      Comp_line = "        " ;                                                  
      push Comp_line ;                                                          
      push Comp_line ;                                                          
      "EXECIO 2 DISKW ACMQOUT  " ;                                              
      end;                                                                      
                                                                                
   Save_place = SAVEPDS"("element")" ;                                          
   Say "Writing" Save_place ;                                                   
   ADDRESS TSO,                                                                 
     "ALLOC F(SAVEMBMR) DA('"Save_place"') SHR REUSE " ;                        
   "EXECIO * DISKR SAVEMBMR ( STEM MBR. FINIS" ;                                
   "EXECIO * DISKW ACMQOUT  ( STEM MBR. " ;                                     
   DROP MBR.                                                                    
                                                                                
   Comp_line = "        " ;                                                     
   push Comp_line ;                                                             
   "EXECIO 1 DISKW ACMQOUT  " ;                                                 
                                                                                
   Comp_line = "  "COPIES("-",26)"   INPUT COMPONENTS   "COPIES("-",32);        
   push Comp_line ;                                                             
   "EXECIO 1 DISKW ACMQOUT  " ;                                                 
                                                                                
   Comp_line = "        " ;                                                     
   push Comp_line ;                                                             
   push Comp_line ;                                                             
   "EXECIO 2 DISKW ACMQOUT  " ;                                                 
                                                                                
   Comp_line = " STEP: ACM#LOAD DD=SCAN    ",                                   
               "VOL=NNNNNN DSN=ACM#LOAD.SCAN"                                   
   push Comp_line ;                                                             
   "EXECIO 1 DISKW ACMQOUT  " ;                                                 
                                                                                
   Comp_line = "        " ;                                                     
   push Comp_line ;                                                             
   push Comp_line ;                                                             
   "EXECIO 2 DISKW ACMQOUT  " ;                                                 
                                                                                
   Comp_line = "            ",                                                  
               "MEMBER     VV.LL  DATE   TIME  SYSTEM   SUBSYS  ",              
               "ELEMENT    TYPE     STG STE ENVRMNT  LD "                       
   push Comp_line ;                                                             
   "EXECIO 1 DISKW ACMQOUT  " ;                                                 
                                                                                
   return ;                                                                     
                                                                                
Reformat_fields:                                                                
                                                                                
   tmp_yr    =  substr(CUR_DATE,3,2);                                           
   tmp_mo    =  substr(CUR_DATE,5,2);                                           
   tmp_da    =  substr(CUR_DATE,7,2);                                           
   tmp_hr    =  substr(CUR_TIME,1,2);                                           
   tmp_mi    =  substr(CUR_TIME,3,2);                                           
                                                                                
   months = "JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC" ;                 
/* If tmp_mo < 1 | tmp_mo > 12 then,                                            
      Do                                                                        
      Say 'Component=' COMPONENT 'tmp_mo=' tmp_mo                               
      tmp_mo = 1                                                                
      End */                                                                    
   CUR_DATE  = tmp_da||word(months,tmp_mo)||tmp_yr ;                            
   CUR_TIME  = tmp_hr":"tmp_mi ;                                                
                                                                                
   return ;                                                                     
                                                                                
Write_component_info:                                                           
                                                                                
   Comp_line = copies(" ",133) ;                                                
   Comp_line = Overlay("+0100",Comp_line,3) ;                                   
   Comp_line = Overlay(COMPONENT,Comp_line,14) ;                                
/* Comp_line = Overlay(VERS_LEVL,Comp_line,25) ; */                             
   Comp_line = Overlay("01.00",Comp_line,25) ;                                  
                                                                                
   Comp_line = Overlay(CUR_DATE,Comp_line,31) ;                                 
   Comp_line = Overlay(CUR_TIME,Comp_line,39) ;                                 
                                                                                
   Comp_line = Overlay(SYSTEM,Comp_line,45) ;                                   
   Comp_line = Overlay(SUBSYSTEM,Comp_line,54) ;                                
   Comp_line = Overlay(COMPONENT,Comp_line,63) ;                                
   Comp_line = Overlay(TYPE,Comp_line,74) ;                                     
   Comp_line = Overlay(STG_NUM,Comp_line,84) ; /* STAGE NUMBER */               
   Comp_line = Overlay("0",Comp_line,88) ;  /* SITE  NUMBER */                  
   Comp_line = Overlay(Environ,Comp_line,91) ;  /* ENVIRONMENT */               
                                                                                
   PUSH Comp_line ;                                                             
   "EXECIO 1 DISKW ACMQOUT "                                                    
                                                                                
   return ;                                                                     
