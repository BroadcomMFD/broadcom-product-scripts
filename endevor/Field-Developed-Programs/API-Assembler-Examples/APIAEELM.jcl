//A0LY6ZZA JOB 23177,'(415) DAN WALTHER',CLASS=U,
//    MSGCLASS=T,REGION=25M,NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//*  COPIED FROM SYSI.NDVR70.JCLLIB(BC1JAAPI)                         *
//*   (C) 2005 COMPUTER ASSOCIATES INTERNATIONAL, INC.                *
//*    Executes the ENTBJAPI API program (Endevor provided)           *
//*-------------------------------------------------------------------*
//PREP     EXEC PGM=IEFBR14
//MSGFILE  DD  DSN=&&MSG3FILE,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//ELEMLIST DD  DSN=&&EXT1ELM,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(CYL,(5,5)),
//             DCB=(RECFM=VB,LRECL=2048,BLKSIZE=22800)
//*-------------------------------------------------------------------*
//STEP1    EXEC PGM=NDVRC1,PARM='ENTBJAPI',REGION=4096K
//CONLIB   DD DISP=SHR,DSN=SYS1.NDVR70.CONLIB
//STEPLIB  DD DISP=SHR,DSN=SYS1.NDVR70.AUTHLIB
//         DD DISP=SHR,DSN=SYS1.NDVR70.CONLIB
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//BSTERR   DD  SYSOUT=*
//BSTAPI   DD  SYSOUT=*
//SYMDUMP  DD DUMMY
//SYSUDUMP DD SYSOUT=*
//MSGFILE  DD  DSN=&&MSG3FILE,DISP=(MOD,PASS)
//ELEMLIST DD  DSN=&&EXT1ELM,DISP=(MOD,PASS)
//SYSIN    DD  *
* RECORD ID IS IN COLUMNS 1-5
*    V - COLUMN 6 = PATH SETTING
*      = ' ' FOR LOGICAL
*      = 'L' FOR LOGICAL
*      = 'P' FOR PHYSICAL
*     V - COLUMN 7 = RETURN SETTING
*       = ' ' FOR FIRST FOUND
*       = 'F' FOR FIRST FOUND
*       = 'A' FOR ALL FOUND
*      V - COLUMN 8 = SEARCH SETTING
*       = ' ' FOR FIRST
*       = 'A' FOR ALL
*       = 'B' FOR BETWEEN
*       = 'E' FOR NEXT
*       = 'N' FOR NO
*       = 'R' FOR RANGE
*       V - COLUMN 9 = UNUSED
*---+----1----+----2----+----3----+----4----+----5----+----6----+----7--
***** AEELM = EXTRACT ELEMENT STRUCTURE INFORMATION
*    V - COLUMN 6 = FORMAT SETTING
*       = ' ' FOR NO FORMAT, JUST EXTRACT ELEMENT
*       = 'B' FOR ENDEVOR BROWSE DISPLAY FORMAT
*       = 'C' FOR ENDEVOR CHANGE DISPLAY FORMAT
*       = 'H' FOR ENDEVOR HISTORY DISPLAY FORMAT
*     V - COLUMN 7 = RECORD TYPE SETTING
*       = 'E' FOR ELEMENT
*       = 'C' FOR COMPONENT
*        VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME
*                V - COLUMN 18 = STAGE ID
*                 VVVVVVVV - COLUMN 19-26 SYSTEM NAME
*                         VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME
*    COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV
*    COLUMN 45-52 = TYPE NAME               VVVVVVVV
*    COLUMN 53-54 = VERSION                         VV
*    COLUMN 55-56 = LEVEL                             VV
*---+----1----+----2----+----3----+----4----+----5----+----6----+----7--
AACTL MSGFILE ELEMLIST
AEELMBCA TEST    UWARETRAN*
RUN
AACTLY
RUN
QUIT                                                                    00030000
//*
//*  PRINT ANY MESSAGES
//STEP2    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&MSG3FILE,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*
//*
//*  PRINT EXTRACTED ELEMENT
//STEP3    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&EXT1ELM,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*