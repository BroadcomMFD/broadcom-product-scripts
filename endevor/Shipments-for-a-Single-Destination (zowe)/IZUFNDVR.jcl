//IZUFPROC PROC ROOT='/usr/lpp/zosmf'  /* zOSMF INSTALL ROOT     */
//         EXPORT SYMLIST=(XX)
//         SET QT=''''
//         SET XX=&QT.&ROOT.&QT.
//IZUFPROC EXEC PGM=IKJEFT01,DYNAMNBR=200,REGION=0M
//****************************************************************/
//* TSO LOGON PROC FOR Z/OS DATA SET AND FILE REST INTERFACE     */
//*     and Endevor access                                       */
//****************************************************************/
//*
//STEPLIB  DD DISP=SHR,DSN=YOURSITE.NDVR.CSIQAUTU
//         DD DISP=SHR,DSN=YOURSITE.NDVR.CSIQAUTH
//         DD DISP=SHR,DSN=YOURSITE.NDVR.CSIQLOAD
//CONLIB   DD DISP=SHR,DSN=YOURSITE.NDVR.CSIQLOAD
//*
//SYSEXEC  DD DISP=SHR,DSN=YOUR.NDVR.TEAM.REXX
//         DD DISP=SHR,DSN=YOUR.SISPEXEC
//         DD DISP=SHR,DSN=SYS1.SBPXEXEC
//         DD DISP=SHR,DSN=YOUR.SISFEXEC
//SYSHELP  DD DISP=SHR,DSN=SYS1.HELP
//         DD DISP=SHR,DSN=YOUR.SISFHELP
//ISPLLIB  DD DISP=SHR,DSN=SYS1.SIEALNKE
//         DD DISP=SHR,DSN=YOUR.SISPLOAD
//SYSPROC  DD DISP=SHR,DSN=YOUR.NDVR.TEAM.REXX
//         DD DISP=SHR,DSN=OTHER.COMMON.CLIST
//         DD DISP=SHR,DSN=YOURSITE.NDVR.CSIQCLS0
//         DD DISP=SHR,DSN=YOUR.SISPCLIB
//         DD DISP=SHR,DSN=SYS1.SBPXEXEC
//ISPPLIB  DD DISP=SHR,DSN=YOUR.SISPPENU
//         DD DISP=SHR,DSN=YOUR.SISFPLIB
//ISPTLIB  DD RECFM=FB,LRECL=80,SPACE=(TRK,(1,0,1))
//         DD DISP=SHR,DSN=YOUR.SISPTENU
//         DD DISP=SHR,DSN=YOUR.SISFTLIB
//ISPSLIB  DD DISP=SHR,DSN=YOUR.NDVR.TEAM.ISPSLIB
//         DD DISP=SHR,DSN=YOUR.SISPSENU
//         DD DISP=SHR,DSN=YOUR.SISFSLIB
//ISPMLIB  DD DISP=SHR,DSN=YOUR.SISPMENU
//         DD DISP=SHR,DSN=YOUR.SISFMLIB
//IZUSRVMP DD PATH='&ROOT./defaults/izurf.tsoservlet.mapping.json'
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//CEEDUMP  DD SYSOUT=H
//SYSUDUMP DD SYSOUT=H
//ISPPROF DD DISP=NEW,UNIT=SYSDA,SPACE=(TRK,(15,15,5)),
//        DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)
