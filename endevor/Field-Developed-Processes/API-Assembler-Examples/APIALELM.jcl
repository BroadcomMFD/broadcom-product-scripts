//WALJO11E JOB (55800000),
//      'ENDEVOR JOB',MSGLEVEL=(1,1),CLASS=B,REGION=0M,MSGCLASS=A,
//      NOTIFY=&SYSUID
//*-------------------------------------------------------------------*
//*---CAPRD.SIQ1206A.JCLLIB(BC1JAAPI) < PROVIDED MODEL ---------------*
//*-------------------------------------------------------------------*
//STEP1    EXEC PGM=NDVRC1,
// PARM='APIALELMSMPLPRODCATSNDVR*       ASM     *         *'
//*PARM='APIALELM-ENV----SYS-----SUB-----TYPE----ELEMENT---S'
//*PARM='APIALELM----+--8----+--8----+--8----+--8--------10S'
//STEPLIBX DD DISP=SHR,DSN=CAPRD.SIQ126S1.USER.AUTHLIB
//STEPLIB  DD DISP=SHR,DSN=CAPRD.SIQ126S1.AUTHLIB
//         DD DISP=SHR,DSN=CAPRD.SIQ126S1.CONLIB
//CONLIB   DD DISP=SHR,DSN=CAPRD.SIQ126S1.CONLIB
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//BSTERR   DD  SYSOUT=*
//BSTAPI   DD  SYSOUT=*
//APIMSGS DD   DSN=&&APIMSGS,DISP=(MOD,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=FB,LRECL=133,BLKSIZE=13300)
//APILIST DD   DSN=&&APILIST,DISP=(MOD,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(5,5)),
//             DCB=(RECFM=VB,LRECL=2048,BLKSIZE=22800)
//SYSIN    DD  *
AACTL APIMSGS APILIST
ALELM AA SMPLPRODE*       *       IPROCCOM  PROCINCL
RUN
AACTLY
RUN
QUIT
//SYSINX   DD  *
AACTL APIMSGS APILIST
ALELM F  SMPLPRODE*       *       IPROCCOM  PROCINCL
RUN
AACTLY
RUN
QUIT
AACTL APIMSGS APILIST
ALELM F  SMPLPRODE*       PROCESS I#GOLONGERPROCINCL
RUN
AACTLY
RUN
QUIT
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
*        VVVVVVVV - COLUMN 10-17 ENVIRONMENT NAME
*                V - COLUMN 18 = STAGE ID
*                 VVVVVVVV - COLUMN 19-26 SYSTEM NAME
*                         VVVVVVVV - COLUMN 27-34 SUBSYSTEM NAME
*    COLUMN 35-44 = ELEMENT NAME  VVVVVVVVVV
*    COLUMN 45-52 = TYPE NAME               VVVVVVVV
*    COLUMN 53-60 = TO-ENV NAME                     VVVVVVVV
*    COLUMN 61    = TO-STAGE ID                             V
*    COLUMN 62-71 = THRU-ELEMENT NAME                        VVVVVVVVV
* NOTE: IF BETWEEN/RANGE SETTINGS ARE USED, YOU NEED TO SPECIFY
*       TO-ENV AND TO-STAGE, OTHERWISE LEAVE BLANK.
//NOTNOW  DD *
AACTL APIMSGS APILIST
ALELM    SMPLPROD*FINANCE *       FAPASM01  *
RUN
AACTLY
RUN
QUIT
//*----------------------------------------------------------------------
//STEP2    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APIMSGS,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*
//*
//*  PRINT EXTRACTED ELEMENT
//STEP3    EXEC PGM=IEBGENER
//SYSPRINT DD DUMMY
//SYSIN    DD DUMMY
//SYSUT1   DD DSN=&&APILIST,DISP=(OLD,DELETE)
//SYSUT2   DD SYSOUT=*