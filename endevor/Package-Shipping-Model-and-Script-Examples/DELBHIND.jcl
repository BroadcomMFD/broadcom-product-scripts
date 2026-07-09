//**********************************************************************
//* STEP1 WRITE: Get the COMPONENT list for the source element
//**********************************************************************
//WRITE    EXEC PGM=CONWRITE,MAXRC=4                       DELBHIND
//CONWIN   DD *
  WRITE ELEMENT &C1ELEMENT
     FROM ENV &C1SENVMNT SYSTEM &C1SYSTEM SUBSYSTEM &C1SSUBSYS
          TYPE &C1ELTYPE STAGE &C1SSTGID
  TO DDN PRNTFILE
  OPTION COMPONENT.
//PRNTFILE DD DSN=&&PRNTFILE,DISP=(NEW,PASS),
//            UNIT=&TUNIT,SPACE=(TRK,(5,5)),
//            DCB=(RECFM=FB,LRECL=203,BLKSIZE=4060)
//*
//**********************************************************************
//* STEP2 SHOWME1: Show the  COMPONENT List
//**********************************************************************
//SHOWME1  EXEC PGM=IEBGENER                               DELBHIND
//SYSPRINT DD DUMMY
//SYSUT1   DD DSN=&&PRNTFILE,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*
//SYSIN    DD DUMMY
//*
//**********************************************************************
//* STEP3 DELBHIND: Create Delete Behind transactions for
//*                 remote DELETE actions.
//**********************************************************************
//DELBHIND EXEC PGM=IRXJCL,PARM='ENBPIU00 M O',MAXRC=4     DELBHIND
//TABLE    DD DSN=&&PRNTFILE,DISP=(OLD,PASS)
//POSITION DD *
  InOrOut  37 37
  DDNAME   49 56
  STEPNAME 29 36
  Member   39 46
  Dataset  57 100
//OPTIONS  DD *
  $Table_Type = 'positions'
  tempdsn = Translate(Dataset,' ','.');
  lastnode = Word(tempdsn,Words(tempdsn))
  If lastnode = 'LISTLIB' then $SkipRow = 'Y'
//MODEL    DD *
   %DELETMBR &Dataset &Member
//SYSEXEC  DD DSN=YOUR.NDVR.EMER.ADMINSYS.CSIQCLS0,
//            DISP=SHR
//SYSTSIN  DD DUMMY
//SYSTSPRT DD SYSOUT=*
//TBLOUT   DD SYSOUT=*
//*BLOUT   DD DISP=SHR,DSN=&HLQ#...DELETES(&C1ELEMENT),
//*           MONITOR=COMPONENTS
//*
//**********************************************************************
