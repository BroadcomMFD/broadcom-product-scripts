/*     REXX   */                                                        00000100
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".              00000200
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.          00000300
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE           00000400
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.  */ 00000500
   /* WRITTEN BY DAN WALTHER */                                         00000600
   ARG SAVEPDS ;                                                        00000700
   TRACE Off                                                            00000800
   output = "SAVEMBMR" ;                                                00000900
/*                                                                   */ 00001000
   "EXECIO * DISKR ACMCOMP (STEM DATA. FINIS " ;                        00001100
/*                                                                   */ 00001200
     Assembler_OP_Codes =,                                              00001300
     "A AD ADB ADBR ADR ADTR AE AEB AEBR AER AFI AG AGF AGFI   ",       00001400
     "AGFR AGHI AGR AGSI AH AHI AHY AL ALC ALCG ALCGR ALCR     ",       00001500
     "ALFI ALG ALGF ALGFI ALGFR ALGR ALGSI ALR ALSI ALY AP AR  ",       00001600
     "ASI AU AUR AW AWR AXBR AXR AXTR AY B BAKR BAL BALR BAS   ",       00001700
     "BASR BASSM BC BCR BCT BCTG BCTGR BCTR BRAS BRASL BRC     ",       00001800
     "BRCL BRCT BRCTG BRXH BRXHG BRXLE BRXLG BSA BSG BSM BXH   ",       00001900
     "BXHG BXLE BXLEG C CD CDB CDBR CDFBR CDFR CDGBR CDGR      ",       00002000
     "CDGTR CDR CDS CDSG CDSTR CDSY CDTR CDUTR CE CEB CEBR     ",       00002100
     "CEDTR CEFBR CEFR CEGBR CEGR CER CEXTR CFC CFDBR CFDR     ",       00002200
     "CFEBR CFER CFI CFXBR CFXR CG CGDBR CGDR CGDTR CGEBR      ",       00002300
     "CGER CGF CGFI CGFR CGFRL CGH CGHI CGHRL CGHSI CGIB CGIJ  ",       00002400
     "CGIT CGR CGRB CGRJ CGRL CGRT CGXBR CGXR CGXTR CH CHHSI   ",       00002500
     "CHI CHRL CHSI CHY CIB CIJ CIT CKSM CL CLC CLCL CLCLE     ",       00002600
     "CLCLU CLFHSI CLFI CLFIT CLG CLGF CLGFI CLGFR CLGFRL      ",       00002700
     "CLGHRL CLGHSI CLGIB CLGIJ CLGIT CLGR CLGRB CLGRJ CLGRL   ",       00002800
     "CLGRT CLHHSI CLHRL CLI CLIB CLIJ CLIY CLM CLMH CLMY CLR  ",       00002900
     "CLRB CLRJ CLRL CLRT CLST CLY CMPSC CP CPSDR CPYA CR CRB  ",       00003000
     "CRJ CRL CRT CS CSCH CSDTR CSG CSP CSPG CSST CSXTR CSY    ",       00003100
     "CU12 CU14 CU21 CU24 CU41 CU42 CUDTR CUSE CUTFU CUUTF     ",       00003200
     "CUXTR CVB CVBG CVBY CVD CVDG CVDY CXBR CXFBR CXFR CXGBR  ",       00003300
     "CXGR CXGTR CXR CXSTR CXTR CXUTR CY D DD DDB DDBR DDR     ",       00003400
     "DDTR DE DEB DEBR DER DIDBR DIEBR DL DLG DLGR DLR DP DR   ",       00003500
     "DSG DSGF DSGFR DSGR DXBR DXR DXTR EAR ECAG ECTG ED EDMK  ",       00003600
     "EEDTR EEXTR EFPC EPAIR EPAR EPSW EREG EREGG ESAIR ESAR   ",       00003700
     "ESDTR ESEA ESTA ESXTR EX EXRL FIDBR FIDR FIDTR FIEBR     ",       00003800
     "FIER FIXBR FIXR FIXTR FLOGR HDR HER HSCH IAC IC ICM      ",       00003900
     "ICMH ICMY ICY IDTE IEDTR IEXTR IIHF IIHH IIHL IILF IILH  ",       00004000
     "IILL IPK IPM IPTE ISKE IVSK KDB KDBR KDTR KEB KEBR KIMD  ",       00004100
     "KLMD KM KMAC KMC KXBR KXTR L LA LAE LAEY LAM LAMY LARL   ",       00004200
     "LASP LAY LB LBR LCDBR LCDFR LCDR LCEBR LCER LCGFR LCGR   ",       00004300
     "LCR LCTL LCTLG LCXBR LCXR LD LDE LDEB LDEBR LDER LDETR   ",       00004400
     "LDGR LDR LDXBR LDXR LDXTR LDY LE LEDBR LEDR LEDTR LER    ",       00004500
     "LEXBR LEXR LEY LFAS LFPC LG LGB LGBR LGDR LGF LGFI LGFR  ",       00004600
     "LGFRL LGH LGHI LGHR LGHRL LGR LGRL LH LHI LHR LHRL LHY   ",       00004700
     "LLC LLCR LLGC LLGCR LLGF LLGFR LLGFRL LLGH LLGHR LLGHRL  ",       00004800
     "LLGT LLGTR LLH LLHR LLHRL LLIHF LLIHH LLIHL LLILF LLILH  ",       00004900
     "LLILL LM LMD LMG LMH LMY LNDBR LNDFR LNDR LNEBR LNER     ",       00005000
     "LNGFR LNGR LNR LNXBR LNXR LPDBR LPDFR LPDR LPEBR LPER    ",       00005100
     "LPGFR LPGR LPQ LPR LPSW LPSWE LPTEA LPXBR LPXR LR LRA    ",       00005200
     "LRAG LRAY LRDR LRER LRL LRV LRVG LRVGR LRVH LRVR LT      ",       00005300
     "LTDBR LTDR LTDTR LTEBR LTER LTG LTGF LTGFR LTGR LTR      ",       00005400
     "LTXBR LTXR LTXTR LURA LURAG LXD LXDB LXDBR LXDR LXDTR    ",       00005500
     "LXE LXEB LXEBR LXER LXR LY LZDR LZER LZXR M MAD MADB     ",       00005600
     "MADBR MADR MAE MAEB MAEBR MAER MAY MAYH MAYHR MAYL       ",       00005700
     "MAYLR MAYR MC MD MDB MDBR MDE MDEB MDEBR MDER MDR MDTR   ",       00005800
     "ME MEE MEEB MEEBR MEER MER MFY MGHI MH MHI MHY ML MLG    ",       00005900
     "MLGR MLR MP MR MS MSCH MSD MSDB MSDBR MSDR MSE MSEB      ",       00006000
     "MSEBR MSER MSFI MSG MSGF MSGFI MSGFR MSGR MSR MSTA MSY   ",       00006100
     "MVC MVCDK MVCIN MVCK MVCL MVCLE MVCLU MVCOS MVCP MVCS    ",       00006200
     "MVCSK MVGHI MVHHI MVHI MVI MVIY MVN MVO MVPG MVST MVZ    ",       00006300
     "MXBR MXD MXDB MXDBR MXDR MXR MXTR MY MYH MYHR MYL MYLR   ",       00006400
     "MYR N NC NG NGR NI NIHF NIHH NIHL NILF NILH NILL NIY NR  ",       00006500
     "NY O OC OG OGR OI OIHF OIHH OIHL OILF OILH OILL OIY OR   ",       00006600
     "OY PACK PALB PC PFD PFDRL PFMF PFPO PGIN PGOUT PKA PKU   ",       00006700
     "PLO PR PT PTF PTFF PTI PTLB QADTR QAXTR RCHP RISBG RLL   ",       00006800
     "RLLG RNSBG ROSBG RP RRBE RRDTR RRXTR RSCH RXSBG S SAC    ",       00006900
     "SACF SAL SAM24 SAM31 SAM64 SAR SCHM SCK SCKC SCKPF SD    ",       00007000
     "SDB SDBR SDR SDTR SE SEB SEBR SER SFASR SFPC SG SGF      ",       00007100
     "SGFR SGR SH SHY SIE SIGP SL SLA SLAG SLB SLBG SLBGR      ",       00007200
     "SLBR SLDA SLDL SLDT SLFI SLG SLGF SLGFI SLGFR SLGR SLL   ",       00007300
     "SLLG SLR SLXT SLY SP SPKA SPM SPT SPX SQD SQDB SQDBR     ",       00007400
     "SQDR SQE SQEB SQEBR SQER SQXBR SQXR SR SRA SRAG SRDA     ",       00007500
     "SRDL SRDT SRL SRLG SRNM SRNMT SRP SRST SRSTU SRXT SSAIR  ",       00007600
     "SSAR SSCH SSKE SSM ST STAM STAMY STAP STC STCK STCKC     ",       00007700
     "STCKE STCKF STCM STCMH STCMY STCPS STCRW STCTG STCTL     ",       00007800
     "STCY STD STDY STE STEY STFL STFLE STFPC STG STGRL STH    ",       00007900
     "STHRL STHY STIDP STM STMG STMH STMY STNSM STOSM STPQ     ",       00008000
     "STPT STPX STRAG STRL STRV STRVG STRVH STSCH STSI STURA   ",       00008100
     "STURG STY SU SUR SVC SW SWR SXBR SXR SXTR SY TAM TAR TB  ",       00008200
     "TBDR TBEDR TCDB TCEB TCXB TDCDT TDCET TDCXT TDGDT TDGET  ",       00008300
     "TDGXT THDER THDR TM TMH TMHH TMHL TML TMLH TMLL TMY TP   ",       00008400
     "TPI TPROT TR TRACE TRACG TRAP2 TRAP4 TRE TROO TROT TRT   ",       00008500
     "TRTE TRTO TRTR TRTRE TRTT TS TSCH UNPK UNPKA UNPKU UPT   ",       00008600
     "X XC XG XGR XI XIHF XILF XIY XR XSCH XY ZAP              " ;      00008700
/*                                                                   */ 00008800
   Do ln = 1 to data.0                                                  00008900
      LINE = substr(DATA.ln,2) ;                                        00009000
      SA= LINE ;                                                        00009100
      IF WORD(LINE,2) = 'ELEMENT' &,                                    00009200
         WORD(LINE,3) = 'BROWSE'  THEN,                                 00009300
         DO                                                             00009400
         pos =wordindex(DATA.ln,2) ;                                    00009500
         DATA.ln = Overlay("COMPONENT BROWSE",DATA.ln,pos) ;            00009600
         END;                                                           00009700
      IF WORD(LINE,4) = 'TYPE:' THEN,                                   00009800
         DO                                                             00009900
         TYPE = STRIP(WORD(LINE,5)) ;                                   00010000
         SA= 'TYPE=' TYPE ;                                             00010100
         ATTOP = 'Y' ;                                                  00010200
         END;                                                           00010300
                                                                        00010400
      IF WORD(LINE,2) = 'TYPE:' &,                                      00010500
         WORD(LINE,1) = '**'  then,                                     00010600
         DO                                                             00010700
         TYPE = WORD(LINE,3) ;                                          00010800
         SA= 'TYPE=' TYPE ;                                             00010900
         ATTOP = 'Y' ;                                                  00011000
         END;                                                           00011100
                                                                        00011200
      IF WORD(LINE,2) = 'ELEMENT:' &,                                   00011300
         (WORD(LINE,4) = 'TYPE:' | WORD(LINE,4) = '**') then,           00011400
         do                                                             00011500
         element = word(line,3) ;                                       00011600
         write_line = ln - 6 ;                                          00011700
         Save_place = SAVEPDS"("element")" ;                            00011800
         say "Building" Save_place ;                                    00011900
         ADDRESS TSO,                                                   00012000
           "ALLOC F(SAVEMBMR) DA('"Save_place"') SHR REUSE " ;          00012100
          do forever                                                    00012200
             test = word(data.write_line,1) ;                           00012300
             if substr(test,1,1) = "+" then,                            00012400
                leave ;                                                 00012500
             if test = 'DATA.'write_line then,                          00012600
                leave ;                                                 00012700
             LINE = data.write_line ;                                   00012800
             IF substr(LINE,29,24) = 'SOURCE LEVEL INFORMATION' then,   00012900
                DO                                                      00013000
                new_lit = " COMPONENT LEVEL INFORMATION"                00013100
                data.write_line = Overlay(new_lit,data.write_line,25) ; 00013200
                END;                                                    00013300
             IF WORD(LINE,1) = 'THIS' &,                                00013400
                WORD(LINE,2) = 'ELEMENT'  THEN,                         00013500
                   do                                                   00013600
                   write_line = write_line + 1 ;                        00013700
                   ITERATE ;                                            00013800
                   end;                                                 00013900
             push  data.write_line;                                     00014000
             "EXECIO 1 DISKW " output ;                                 00014100
             write_line = write_line + 1 ;                              00014200
          end;  /* do forever */                                        00014300
         "EXECIO 0 DISKW "output "(finis" ;                             00014400
         ln = write_line ;                                              00014500
         end;  /* IF Word... */                                         00014600
                                                                        00014700
      IF SUBSTR(WORD(LINE,1),1,1)  = '+' |,                             00014800
         SUBSTR(WORD(LINE,1),1,1)  = '%' THEN,                          00014900
         CALL SCANLINE ;                                                00015000
   END;  /* Do ln = 1 to data.0  */                                     00015100
                                                                        00015200
   EXIT(RC) ;                                                           00015300
                                                                        00015400
SCANLINE:                                                               00015500
                                                                        00015600
   IF substr(TYPE,1,2) = 'CO'  then CALL SCAN_COBOL;                    00015700
   IF substr(TYPE,1,2) = 'AS'  then CALL SCAN_Assembler;                00015800
                                                                        00015900
   IF substr(TYPE,1,3) = 'COB' then CALL SCAN_COBOL;                    00016000
   IF substr(TYPE,1,3) = 'CBL' then CALL SCAN_COBOL;                    00016100
   IF substr(TYPE,4,3) = 'ASM' then CALL SCAN_Assembler;                00016200
   IF substr(TYPE,1,3) = 'DYL' then CALL SCAN_DYL;                      00016300
   IF substr(TYPE,1,2) = 'JC'  then CALL SCAN_JCL;                      00016400
                                                                        00016500
   RETURN;                                                              00016600
                                                                        00016700
SCAN_Assembler:                                                         00016800
                                                                        00016900
   LINE = Translate(LINE,' ',"'.(:");                                   00016901
   assembler = Substr(LINE,13)                                          00016902
   If Substr(assembler,1,1) = '*' then Return;                          00016903
   If Substr(assembler,1,1) = ' ' then Name = Word(assembler,1)         00016904
   Else                                Name = Word(assembler,2)         00016905
   COMPONENT_Invocation = "COPY" ;                                      00016906
   If Name = "COPY" then,                                               00016908
      Name = Word(assembler,3)                                          00016909
                                                                        00016910
   if WordPos(Name,Assembler_OP_Codes) > 0 then return;                 00016911
   Else,                                                                00016912
      COMPONENT = Name ;                                                00016913
                                                                        00016914
   prx = Substr(COMPONENT,1,1);                                         00018100
   If DATATYPE(prx,'s') /= 1 then return;                               00018200
   Call WRite_Component_Item;                                           00018300
   RETURN;                                                              00018400
                                                                        00018500
SCAN_DYL:                                                               00018600
   IF SUBSTR(LINE,10,1) = '*' THEN RETURN;                              00018700
   COMPONENT_Invocation = "COPY" ;                                      00018800
   PLACE = WORDPOS('COPY',LINE) ;                                       00018900
   IF PLACE = 0 THEN return;                                            00019000
   COMPONENT = WORD(LINE,PLACE + 1);                                    00019100
   COMPONENT = STRIP(COMPONENT,'T','.') ;                               00019200
   Call WRite_Component_Item;                                           00019300
   RETURN;                                                              00019400
                                                                        00019500
SCAN_COBOL:                                                             00019600
   IF SUBSTR(LINE,16,1) = '*' THEN RETURN;                              00019800
   COMPONENT_Invocation = "COPY" ;                                      00019900
   PLACE = WORDPOS('COPY',LINE) ;                                       00020000
   IF PLACE = WORDS(LINE) THEN RETURN ;                                 00020100
   IF PLACE = 0 THEN,                                                   00020200
      PLACE = WORDPOS('++INCLUDE',LINE) ;                               00020300
   IF PLACE = 0 THEN,                                                   00020400
      PLACE = WORDPOS('INCLUDE',LINE) ;                                 00020500
                                                                        00020600
   IF PLACE = 0 THEN,                                                   00020700
      DO                                                                00020800
      COMPONENT_Invocation = "CALL" ;                                   00020900
      PLACE = WORDPOS('CALL',LINE) ;                                    00021000
      IF PLACE = 0 THEN RETURN;                                         00021100
      IF PLACE = WORDS(LINE) THEN RETURN ;                              00021200
      temp = WORD(LINE,PLACE + 1)                                       00021300
      IF SUBSTR(temp,1,1) /= "'" THEN RETURN ;                          00021400
      END;  /* IF PLACE = 0 */                                          00021500
                                                                        00021600
   COMPONENT = WORD(LINE,PLACE + 1);                                    00021700
   COMPONENT = STRIP(COMPONENT,'B',"'") ;                               00021800
   COMPONENT = STRIP(COMPONENT,'T','.') ;                               00021900
   COMPONENT = STRIP(COMPONENT,'B',"'") ;                               00022000
   Call WRite_Component_Item;                                           00022100
   RETURN;                                                              00022200
                                                                        00022400
WRite_Component_Item:                                                   00022500
   COMPONENT = STRIP(COMPONENT,B,"'") ;                                 00022600
   COMPONENT = STRIP(COMPONENT,B,'"') ;                                 00022700
   COMPONENT = STRIP(COMPONENT,T,'.') ;                                 00022800
   COMPONENT = STRIP(COMPONENT) ;                                       00022900
                                                                        00023000
   TEMP = COPIES(" ",80) ;                                              00023100
   TEMP = OVERLAY(ELEMENT,TEMP,1) ;                                     00023200
   TEMP = OVERLAY(COMPONENT,TEMP,15);                                   00023300
   TEMP = OVERLAY(COMPONENT_Invocation,TEMP,30);                        00023400
   Push TEMP;                                                           00023500
   "EXECIO 1 DISKW ACMQLIST"                                            00023600
   RETURN;                                                              00023700
                                                                        00023800
Scan_JCL:                                                               00023900
                                                                        00024000
                                                                        00024100
   IF TYPE = 'JCL' &  SUBSTR(LINE,12,1) = '*' THEN RETURN;              00024200
                                                                        00024300
   PLACE = WORDPOS('INCLUDE',LINE) ;                                    00024400
   IF PLACE > 0 THEN,                                                   00024500
      DO                                                                00024600
      pos = index(LINE,'MEMBER=') ;                                     00024700
      IF pos > 0 then,                                                  00024800
         Do                                                             00024900
         COMPONENT = WORD(Substr(LINE,(pos+7)),1)                       00025000
         Call WRite_Component_Item;                                     00025100
         End                                                            00025200
      END ;  /* IF PLACE > 0 THEN  */                                   00025300
                                                                        00025400
   PLACE = WORDPOS('EXEC',LINE) ;                                       00025500
   IF PLACE = 0           THEN RETURN ;                                 00025600
   IF PLACE = WORDS(LINE) THEN RETURN ;                                 00025700
                                                                        00025800
   COMPONENT_Invocation = "PROC" ;                                      00025900
                                                                        00026000
   testit    = WORD(LINE,PLACE + 1);                                    00026100
   testit    = Translate(testit," ","=,'");                             00026200
   if Word(testit,1) = "PROC" then COMPONENT = Word(testit,2);          00026300
   else,                                                                00026400
   if Word(testit,1) = "PGM"  then RETURN ;                             00026500
   else,                                                                00026600
   COMPONENT = Word(testit,1);                                          00026700
                                                                        00026800
   Call WRite_Component_Item;                                           00026900
                                                                        00027000
   RETURN;                                                              00027100
                                                                        00027200
