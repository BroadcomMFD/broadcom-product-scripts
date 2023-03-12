//*********************************************************************
//*   SYS1.CLIST(TBL#TOOL)
//******************************************************************
//COMPILER EXEC PGM=IRXJCL,PARM='ENBPIU00 A '
//TABLE    DD *
*  WHATEVER     $MY_RC
   *              0
//OPTIONS  DD DISP=SHR,DSN=&C1BASELIB(&C1ELEMENT)
//         DD *,LRECL=80
  $nomessages = "Y" ;
//SYSTSPRT DD SYSOUT=*
//MODEL    DD DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.ADM1.ISPS(&C1ELTYPE),
//            DISP=SHR
//SYSEXEC  DD DISP=SHR,DSN=CARSMINI.NDVR.R1801.CSIQCLS0
//SYSTSIN  DD DUMMY
//TBLOUT   DD  DSN=&&TBLOUT,DISP=(,PASS),
//             UNIT=SYSDA,SPACE=(TRK,(10,10),RLSE),
//             DCB=(RECFM=FB,LRECL=255,BLKSIZE=25500)
//*            DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)
//TBLOUTX  DD SYSOUT=*
//*--------------------------------------------------------------------
//SUBMIT  EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&TBLOUT,DISP=(OLD,DELETE)
//SYSUT2X   DD SYSOUT=*                           OUTPUT FILE
//SYSUT2    DD SYSOUT=(A,INTRDR),FREE=CLOSE       OUTPUT FILE
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
