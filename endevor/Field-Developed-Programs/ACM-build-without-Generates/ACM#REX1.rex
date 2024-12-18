/*     REXX   */                                                                
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".                      
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.                  
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE                   
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.  */         
   ARG SAVEPDS ;                                                                
   TRACE Off                                                                    
/* https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main*/          
/* This is the REXX program that scans Printed element outputs.     */          
/* It uses the element type to determine what kind of scan to run.  */          
/* See the SCANLINE: section, and adjust to your types as needed.   */          
/* You may update the ones included, or code your own as you see    */          
/* fit.                                                             */          
   output = "SAVEMBMR" ;                                                        
/*                                                                   */         
   "EXECIO * DISKR ACMCOMP (STEM DATA. FINIS " ;                                
/*                                                                   */         
     Assembler_OP_Codes =,                                                      
     "A AD ADB ADBR ADR ADTR AE AEB AEBR AER AFI AG AGF AGFI   ",               
     "AGFR AGHI AGR AGSI AH AHI AHY AL ALC ALCG ALCGR ALCR     ",               
     "ALFI ALG ALGF ALGFI ALGFR ALGR ALGSI ALR ALSI ALY AP AR  ",               
     "ASI AU AUR AW AWR AXBR AXR AXTR AY B BAKR BAL BALR BAS   ",               
     "BASR BASSM BC BCR BCT BCTG BCTGR BCTR BRAS BRASL BRC     ",               
     "BRCL BRCT BRCTG BRXH BRXHG BRXLE BRXLG BSA BSG BSM BXH   ",               
     "BXHG BXLE BXLEG C CD CDB CDBR CDFBR CDFR CDGBR CDGR      ",               
     "CDGTR CDR CDS CDSG CDSTR CDSY CDTR CDUTR CE CEB CEBR     ",               
     "CEDTR CEFBR CEFR CEGBR CEGR CER CEXTR CFC CFDBR CFDR     ",               
     "CFEBR CFER CFI CFXBR CFXR CG CGDBR CGDR CGDTR CGEBR      ",               
     "CGER CGF CGFI CGFR CGFRL CGH CGHI CGHRL CGHSI CGIB CGIJ  ",               
     "CGIT CGR CGRB CGRJ CGRL CGRT CGXBR CGXR CGXTR CH CHHSI   ",               
     "CHI CHRL CHSI CHY CIB CIJ CIT CKSM CL CLC CLCL CLCLE     ",               
     "CLCLU CLFHSI CLFI CLFIT CLG CLGF CLGFI CLGFR CLGFRL      ",               
     "CLGHRL CLGHSI CLGIB CLGIJ CLGIT CLGR CLGRB CLGRJ CLGRL   ",               
     "CLGRT CLHHSI CLHRL CLI CLIB CLIJ CLIY CLM CLMH CLMY CLR  ",               
     "CLRB CLRJ CLRL CLRT CLST CLY CMPSC CP CPSDR CPYA CR CRB  ",               
     "CRJ CRL CRT CS CSCH CSDTR CSG CSP CSPG CSST CSXTR CSY    ",               
     "CU12 CU14 CU21 CU24 CU41 CU42 CUDTR CUSE CUTFU CUUTF     ",               
     "CUXTR CVB CVBG CVBY CVD CVDG CVDY CXBR CXFBR CXFR CXGBR  ",               
     "CXGR CXGTR CXR CXSTR CXTR CXUTR CY D DD DDB DDBR DDR     ",               
     "DDTR DE DEB DEBR DER DIDBR DIEBR DL DLG DLGR DLR DP DR   ",               
     "DSG DSGF DSGFR DSGR DXBR DXR DXTR EAR ECAG ECTG ED EDMK  ",               
     "EEDTR EEXTR EFPC EPAIR EPAR EPSW EREG EREGG ESAIR ESAR   ",               
     "ESDTR ESEA ESTA ESXTR EX EXRL FIDBR FIDR FIDTR FIEBR     ",               
     "FIER FIXBR FIXR FIXTR FLOGR HDR HER HSCH IAC IC ICM      ",               
     "ICMH ICMY ICY IDTE IEDTR IEXTR IIHF IIHH IIHL IILF IILH  ",               
     "IILL IPK IPM IPTE ISKE IVSK KDB KDBR KDTR KEB KEBR KIMD  ",               
     "KLMD KM KMAC KMC KXBR KXTR L LA LAE LAEY LAM LAMY LARL   ",               
     "LASP LAY LB LBR LCDBR LCDFR LCDR LCEBR LCER LCGFR LCGR   ",               
     "LCR LCTL LCTLG LCXBR LCXR LD LDE LDEB LDEBR LDER LDETR   ",               
     "LDGR LDR LDXBR LDXR LDXTR LDY LE LEDBR LEDR LEDTR LER    ",               
     "LEXBR LEXR LEY LFAS LFPC LG LGB LGBR LGDR LGF LGFI LGFR  ",               
     "LGFRL LGH LGHI LGHR LGHRL LGR LGRL LH LHI LHR LHRL LHY   ",               
     "LLC LLCR LLGC LLGCR LLGF LLGFR LLGFRL LLGH LLGHR LLGHRL  ",               
     "LLGT LLGTR LLH LLHR LLHRL LLIHF LLIHH LLIHL LLILF LLILH  ",               
     "LLILL LM LMD LMG LMH LMY LNDBR LNDFR LNDR LNEBR LNER     ",               
     "LNGFR LNGR LNR LNXBR LNXR LPDBR LPDFR LPDR LPEBR LPER    ",               
     "LPGFR LPGR LPQ LPR LPSW LPSWE LPTEA LPXBR LPXR LR LRA    ",               
     "LRAG LRAY LRDR LRER LRL LRV LRVG LRVGR LRVH LRVR LT      ",               
     "LTDBR LTDR LTDTR LTEBR LTER LTG LTGF LTGFR LTGR LTR      ",               
     "LTXBR LTXR LTXTR LURA LURAG LXD LXDB LXDBR LXDR LXDTR    ",               
     "LXE LXEB LXEBR LXER LXR LY LZDR LZER LZXR M MAD MADB     ",               
     "MADBR MADR MAE MAEB MAEBR MAER MAY MAYH MAYHR MAYL       ",               
     "MAYLR MAYR MC MD MDB MDBR MDE MDEB MDEBR MDER MDR MDTR   ",               
     "ME MEE MEEB MEEBR MEER MER MFY MGHI MH MHI MHY ML MLG    ",               
     "MLGR MLR MP MR MS MSCH MSD MSDB MSDBR MSDR MSE MSEB      ",               
     "MSEBR MSER MSFI MSG MSGF MSGFI MSGFR MSGR MSR MSTA MSY   ",               
     "MVC MVCDK MVCIN MVCK MVCL MVCLE MVCLU MVCOS MVCP MVCS    ",               
     "MVCSK MVGHI MVHHI MVHI MVI MVIY MVN MVO MVPG MVST MVZ    ",               
     "MXBR MXD MXDB MXDBR MXDR MXR MXTR MY MYH MYHR MYL MYLR   ",               
     "MYR N NC NG NGR NI NIHF NIHH NIHL NILF NILH NILL NIY NR  ",               
     "NY O OC OG OGR OI OIHF OIHH OIHL OILF OILH OILL OIY OR   ",               
     "OY PACK PALB PC PFD PFDRL PFMF PFPO PGIN PGOUT PKA PKU   ",               
     "PLO PR PT PTF PTFF PTI PTLB QADTR QAXTR RCHP RISBG RLL   ",               
     "RLLG RNSBG ROSBG RP RRBE RRDTR RRXTR RSCH RXSBG S SAC    ",               
     "SACF SAL SAM24 SAM31 SAM64 SAR SCHM SCK SCKC SCKPF SD    ",               
     "SDB SDBR SDR SDTR SE SEB SEBR SER SFASR SFPC SG SGF      ",               
     "SGFR SGR SH SHY SIE SIGP SL SLA SLAG SLB SLBG SLBGR      ",               
     "SLBR SLDA SLDL SLDT SLFI SLG SLGF SLGFI SLGFR SLGR SLL   ",               
     "SLLG SLR SLXT SLY SP SPKA SPM SPT SPX SQD SQDB SQDBR     ",               
     "SQDR SQE SQEB SQEBR SQER SQXBR SQXR SR SRA SRAG SRDA     ",               
     "SRDL SRDT SRL SRLG SRNM SRNMT SRP SRST SRSTU SRXT SSAIR  ",               
     "SSAR SSCH SSKE SSM ST STAM STAMY STAP STC STCK STCKC     ",               
     "STCKE STCKF STCM STCMH STCMY STCPS STCRW STCTG STCTL     ",               
     "STCY STD STDY STE STEY STFL STFLE STFPC STG STGRL STH    ",               
     "STHRL STHY STIDP STM STMG STMH STMY STNSM STOSM STPQ     ",               
     "STPT STPX STRAG STRL STRV STRVG STRVH STSCH STSI STURA   ",               
     "STURG STY SU SUR SVC SW SWR SXBR SXR SXTR SY TAM TAR TB  ",               
     "TBDR TBEDR TCDB TCEB TCXB TDCDT TDCET TDCXT TDGDT TDGET  ",               
     "TDGXT THDER THDR TM TMH TMHH TMHL TML TMLH TMLL TMY TP   ",               
     "TPI TPROT TR TRACE TRACG TRAP2 TRAP4 TRE TROO TROT TRT   ",               
     "TRTE TRTO TRTR TRTRE TRTT TS TSCH UNPK UNPKA UNPKU UPT   ",               
     "X XC XG XGR XI XIHF XILF XIY XR XSCH XY ZAP              " ;              
/*                                                                   */         
   Do ln = 1 to data.0                                                          
      LINE = substr(DATA.ln,2) ;                                                
      SA= LINE ;                                                                
      IF WORD(LINE,2) = 'ELEMENT' &,                                            
         WORD(LINE,3) = 'BROWSE'  THEN,                                         
         DO                                                                     
         pos =wordindex(DATA.ln,2) ;                                            
         DATA.ln = Overlay("COMPONENT BROWSE",DATA.ln,pos) ;                    
         END;                                                                   
      IF WORD(LINE,4) = 'TYPE:' THEN,                                           
         DO                                                                     
         TYPE = STRIP(WORD(LINE,5)) ;                                           
         SA= 'TYPE=' TYPE ;                                                     
         ATTOP = 'Y' ;                                                          
         END;                                                                   
                                                                                
      IF WORD(LINE,2) = 'TYPE:' &,                                              
         WORD(LINE,1) = '**'  then,                                             
         DO                                                                     
         TYPE = WORD(LINE,3) ;                                                  
         SA= 'TYPE=' TYPE ;                                                     
         ATTOP = 'Y' ;                                                          
         END;                                                                   
                                                                                
      IF WORD(LINE,2) = 'ELEMENT:' &,                                           
         (WORD(LINE,4) = 'TYPE:' | WORD(LINE,4) = '**') then,                   
         do                                                                     
         element = word(line,3) ;                                               
         write_line = ln - 6 ;                                                  
         Save_place = SAVEPDS"("element")" ;                                    
         say "Building" Save_place ;                                            
         ADDRESS TSO,                                                           
           "ALLOC F(SAVEMBMR) DA('"Save_place"') SHR REUSE " ;                  
          do forever                                                            
             test = word(data.write_line,1) ;                                   
             if substr(test,1,1) = "+" then,                                    
                leave ;                                                         
             if test = 'DATA.'write_line then,                                  
                leave ;                                                         
             LINE = data.write_line ;                                           
             IF substr(LINE,29,24) = 'SOURCE LEVEL INFORMATION' then,           
                DO                                                              
                new_lit = " COMPONENT LEVEL INFORMATION"                        
                data.write_line = Overlay(new_lit,data.write_line,25) ;         
                END;                                                            
             IF WORD(LINE,1) = 'THIS' &,                                        
                WORD(LINE,2) = 'ELEMENT'  THEN,                                 
                   do                                                           
                   write_line = write_line + 1 ;                                
                   ITERATE ;                                                    
                   end;                                                         
             push  data.write_line;                                             
             "EXECIO 1 DISKW " output ;                                         
             write_line = write_line + 1 ;                                      
          end;  /* do forever */                                                
         "EXECIO 0 DISKW "output "(finis" ;                                     
         ln = write_line ;                                                      
         end;  /* IF Word... */                                                 
                                                                                
      IF SUBSTR(WORD(LINE,1),1,1)  = '+' |,                                     
         SUBSTR(WORD(LINE,1),1,1)  = '%' THEN,                                  
         CALL SCANLINE ;                                                        
   END;  /* Do ln = 1 to data.0  */                                             
                                                                                
   EXIT(RC) ;                                                                   
                                                                                
SCANLINE:                                                                       
                                                                                
   IF substr(TYPE,1,2) = 'SR'  then CALL SCAN_COBOL;                            
   IF substr(TYPE,1,2) = 'SR'  then CALL SCAN_Assembler;                        
                                                                                
   IF substr(TYPE,1,3) = 'COB' then CALL SCAN_COBOL;                            
   IF substr(TYPE,1,3) = 'CBL' then CALL SCAN_COBOL;                            
   IF substr(TYPE,4,3) = 'ASM' then CALL SCAN_Assembler;                        
   IF substr(TYPE,1,3) = 'DYL' then CALL SCAN_DYL;                              
   IF substr(TYPE,1,2) = 'JC'  then CALL SCAN_JCL;                              
                                                                                
   RETURN;                                                                      
                                                                                
SCAN_Assembler:                                                                 
                                                                                
   LINE = Translate(LINE,' ',"'.(:");                                           
   assembler = Substr(LINE,13)                                                  
   If Substr(assembler,1,1) = '*' then Return;                                  
   If Substr(assembler,1,1) = ' ' then Name = Word(assembler,1)                 
   Else                                Name = Word(assembler,2)                 
   COMPONENT_Invocation = "COPY" ;                                              
   If Name = "COPY" then,                                                       
      Name = Word(assembler,3)                                                  
                                                                                
   if WordPos(Name,Assembler_OP_Codes) > 0 then return;                         
   Else,                                                                        
      COMPONENT = Name ;                                                        
                                                                                
   prx = Substr(COMPONENT,1,1);                                                 
   If DATATYPE(prx,'s') /= 1 then return;                                       
   Call WRite_Component_Item;                                                   
   RETURN;                                                                      
                                                                                
SCAN_DYL:                                                                       
   IF SUBSTR(LINE,10,1) = '*' THEN RETURN;                                      
   COMPONENT_Invocation = "COPY" ;                                              
   PLACE = WORDPOS('COPY',LINE) ;                                               
   IF PLACE = 0 THEN return;                                                    
   COMPONENT = WORD(LINE,PLACE + 1);                                            
   COMPONENT = STRIP(COMPONENT,'T','.') ;                                       
   Call WRite_Component_Item;                                                   
   RETURN;                                                                      
                                                                                
SCAN_COBOL:                                                                     
   IF SUBSTR(LINE,16,1) = '*' THEN RETURN;                                      
   COMPONENT_Invocation = "COPY" ;                                              
   PLACE = WORDPOS('COPY',LINE) ;                                               
   IF PLACE = WORDS(LINE) THEN RETURN ;                                         
   IF PLACE = 0 THEN,                                                           
      PLACE = WORDPOS('++INCLUDE',LINE) ;                                       
   IF PLACE = 0 THEN,                                                           
      PLACE = WORDPOS('INCLUDE',LINE) ;                                         
                                                                                
   IF PLACE = 0 THEN,                                                           
      DO                                                                        
      COMPONENT_Invocation = "CALL" ;                                           
      PLACE = WORDPOS('CALL',LINE) ;                                            
      IF PLACE = 0 THEN RETURN;                                                 
      IF PLACE = WORDS(LINE) THEN RETURN ;                                      
      temp = WORD(LINE,PLACE + 1)                                               
      IF SUBSTR(temp,1,1) /= "'" THEN RETURN ;                                  
      END;  /* IF PLACE = 0 */                                                  
                                                                                
   COMPONENT = WORD(LINE,PLACE + 1);                                            
   COMPONENT = STRIP(COMPONENT,'B',"'") ;                                       
   COMPONENT = STRIP(COMPONENT,'T','.') ;                                       
   COMPONENT = STRIP(COMPONENT,'B',"'") ;                                       
   Call WRite_Component_Item;                                                   
   RETURN;                                                                      
                                                                                
WRite_Component_Item:                                                           
   COMPONENT = STRIP(COMPONENT,B,"'") ;                                         
   COMPONENT = STRIP(COMPONENT,B,'"') ;                                         
   COMPONENT = STRIP(COMPONENT,T,'.') ;                                         
   COMPONENT = STRIP(COMPONENT) ;                                               
                                                                                
   TEMP = COPIES(" ",80) ;                                                      
   TEMP = OVERLAY(ELEMENT,TEMP,1) ;                                             
   TEMP = OVERLAY(COMPONENT,TEMP,15);                                           
   TEMP = OVERLAY(COMPONENT_Invocation,TEMP,30);                                
   Push TEMP;                                                                   
   "EXECIO 1 DISKW ACMQLIST"                                                    
   RETURN;                                                                      
                                                                                
Scan_JCL:                                                                       
                                                                                
                                                                                
   IF TYPE = 'JCL' &  SUBSTR(LINE,12,1) = '*' THEN RETURN;                      
                                                                                
   PLACE = WORDPOS('INCLUDE',LINE) ;                                            
   IF PLACE > 0 THEN,                                                           
      DO                                                                        
      pos = index(LINE,'MEMBER=') ;                                             
      IF pos > 0 then,                                                          
         Do                                                                     
         COMPONENT = WORD(Substr(LINE,(pos+7)),1)                               
         Call WRite_Component_Item;                                             
         End                                                                    
      END ;  /* IF PLACE > 0 THEN  */                                           
                                                                                
   PLACE = WORDPOS('EXEC',LINE) ;                                               
   IF PLACE = 0           THEN RETURN ;                                         
   IF PLACE = WORDS(LINE) THEN RETURN ;                                         
                                                                                
   COMPONENT_Invocation = "PROC" ;                                              
                                                                                
   testit    = WORD(LINE,PLACE + 1);                                            
   testit    = Translate(testit," ","=,'");                                     
   if Word(testit,1) = "PROC" then COMPONENT = Word(testit,2);                  
   else,                                                                        
   if Word(testit,1) = "PGM"  then RETURN ;                                     
   else,                                                                        
   COMPONENT = Word(testit,1);                                                  
                                                                                
   Call WRite_Component_Item;                                                   
                                                                                
   RETURN;                                                                      
                                                                                
