/*   REXX       */                                                      00010000
/* THESE ROUTINES ARE DISTRIBUTED BY THE CA STAFF "AS IS".              00010100
   NO WARRANTY, EITHER EXPRESSED OR IMPLIED, IS MADE FOR THEM.          00010200
   COMPUTER ASSOCIATES CANNOT GUARANTEE THAT THE ROUTINES ARE           00010300
   ERROR FREE, OR THAT IF ERRORS ARE FOUND, THEY WILL BE CORRECTED.  */ 00010400
/* https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main */ 00010500
    TRACE o;                                                            00030000
    My_rc = 0 ;                                                         00040000
/*                                                                  */  00050000
/*                                                                  */  00060000
    Last_Output = " ";                                                  00070000
/*                                                                  */  00080000
/*                                                                  */  00090000
    CALL GET_NEXT_COMPONTS_RECORD ;                                     00100000
    CALL GET_NEXT_ACMQLIST_RECORD ;                                     00110000
/*                                                                  */  00120000
/*                                                                  */  00130000
    DO WHILE (ACMQ#Key < "999999999999999999" |,                        00140000
       COMP#Key < "999999999999999999")                                 00150000
       IF (COMP#Key < ACMQ#Key) then,                                   00160000
          CALL GET_NEXT_COMPONTS_RECORD;                                00170000
       IF (COMP#Key = ACMQ#Key) then,                                   00180000
          Do                                                            00190000
          IF (ACMQ#Key = "999999999999999999" &,                        00200000
              COMP#Key = "999999999999999999") THEN LEAVE;              00210000
          Call Write_Outputs ;                                          00220000
          CALL GET_NEXT_ACMQLIST_RECORD;                                00230000
          End /* IF (COMP#Key = ACMQ#Key) then */                       00240000
       IF (COMP#Key > ACMQ#Key) then,                                   00250000
          Do                                                            00260000
          CALL GET_NEXT_ACMQLIST_RECORD;                                00270000
          End /* IF (COMP#Key > ACMQ#Key) then */                       00280000
    END /* DO WHILE (ACMQ#Key < "999999999999999999" |..... */          00290000
/*                                                                  */  00300000
CALL CLOSE_FILES ;                                                      00310000
EXIT(My_rc)                                                             00320000
                                                                        00330000
                                                                        00340000
GET_NEXT_COMPONTS_RECORD:                                               00350000
    "EXECIO 1 DISKR COMPONTS (STEM COMPONTS. " ;                        00360000
    SAVE_SRCE_RC = RC ;                                                 00370000
    component   = Substr(COMPONTS.1,02,10) ;                            00380000
    type        = Substr(COMPONTS.1,33,08) ;                            00390000
    IF SAVE_SRCE_RC > 0 THEN,                                           00400000
       COMP#Key = "999999999999999999";                                 00410000
    ELSE,                                                               00420000
       DO                                                               00430000
       COMP#Key     = component || type ;                               00440000
       COMP#Key     = component ;                                       00450000
       sa= "COMP#Key =" COMP#Key                                        00460000
       END                                                              00470000
                                                                        00480000
    RETURN;                                                             00490000
                                                                        00500000
GET_NEXT_ACMQLIST_RECORD:                                               00510000
    "EXECIO 1 DISKR ACMQLIST (STEM ACMQLIST. " ;                        00520000
    SAVE_SRCE_RC = RC ;                                                 00530000
    Element     = Substr(ACMQLIST.1,01,10) ;                            00540000
    component   = Substr(ACMQLIST.1,15,10) ;                            00550000
    type        = Substr(ACMQLIST.1,30,08) ;                            00560000
    IF TYPE = "COPY    " THEN TYPE = "CPY     " ;                       00570000
    IF SAVE_SRCE_RC > 0 THEN,                                           00580000
       ACMQ#Key = "999999999999999999";                                 00590000
    ELSE,                                                               00600000
       DO                                                               00610000
       ACMQ#Key     = component || type ;                               00620000
       ACMQ#Key     = component ;                                       00630000
       sa= "ACMQ#Key =" ACMQ#Key                                        00640000
       END                                                              00650000
                                                                        00660000
    RETURN;                                                             00670000
                                                                        00680000
Write_Outputs:                                                          00690000
                                                                        00700000
 /* Temp = COMPONTS.1 Element ;  */                                     00710000
    Temp = Overlay(Element,COMPONTS.1,87)                               00720000
    if Temp = Last_Output then return;                                  00730000
    Last_Output = Temp;                                                 00740000
                                                                        00750000
    Queue  Temp ;                                                       00760000
    "EXECIO 1 DISKW MERGED "                                            00770000
    IF My_rc = 0 then My_rc = 1 ;                                       00780000
                                                                        00790000
    RETURN;                                                             00800000
                                                                        00810000
CLOSE_FILES:                                                            00820000
                                                                        00830000
    "EXECIO 0 DISKR ACMQLIST (FINIS " ;                                 00840000
    "EXECIO 0 DISKR COMPONTS (FINIS " ;                                 00850000
    "EXECIO 0 DISKW MERGED (FINIS " ;                                   00860000
                                                                        00870000
    RETURN;                                                             00880000
                                                                        00890000
                                                                        00900000
