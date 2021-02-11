//IZUFPROC PROC ROOT='/usr/lpp/zosmf'  /* zOSMF INSTALL ROOT     */
//         EXPORT SYMLIST=(XX)
//         SET QT=''''
//         SET XX=&QT.&ROOT.&QT.
//IZUFPROC EXEC PGM=IKJEFT01,DYNAMNBR=200,REGION=0M
//****************************************************************/
//* TSO LOGON PROC FOR Z/OS DATA SET AND FILE REST INTERFACE     */
//*     and Endevor access                                       */
//*                                                              */
//* PROPRIETARY STATEMENT:                                       */
//*                                                              */
//*     LICENSED MATERIALS - PROPERTY OF IBM                     */
//*     5650-ZOS                                                 */
//*     COPYRIGHT IBM CORP. 2014, 2016                           */
//*     STATUS = HSMA220                                         */
//****************************************************************/
//*
//STEPLIB  DD DISP=SHR,DSN=SHARE.NDVR.R181.CSIQAUTU    **added**
//         DD DISP=SHR,DSN=SHARE.NDVR.R181.CSIQAUTH    **added**
//         DD DISP=SHR,DSN=SHARE.NDVR.R181.CSIQLOAD    **added**
//CONLIB   DD DISP=SHR,DSN=SHARE.NDVR.R181.CSIQLOAD    **added**
//*
//SYSEXEC  DD DISP=SHR,DSN=PSP.ENDV.TEAM.REXX          **added**
//         DD DISP=SHR,DSN=ISP.SISPEXEC
//         DD DISP=SHR,DSN=SYS1.SBPXEXEC
//         DD DISP=SHR,DSN=ISF.SISFEXEC
//SYSHELP  DD DISP=SHR,DSN=SYS1.HELP
//         DD DISP=SHR,DSN=ISF.SISFHELP
//ISPLLIB  DD DISP=SHR,DSN=SYS1.SIEALNKE
//         DD DISP=SHR,DSN=ISP.SISPLOAD
//SYSPROC  DD DISP=SHR,DSN=PSP.ENDV.TEAM.REXX          **added**
//         DD DISP=SHR,DSN=UKDEMO.CA66.COMMON.CLIST   
//         DD DISP=SHR,DSN=SHARE.NDVR.R181.CSIQCLS0    
//         DD DISP=SHR,DSN=ISP.SISPCLIB
//         DD DISP=SHR,DSN=SYS1.SBPXEXEC
//ISPPLIB  DD DISP=SHR,DSN=ISP.SISPPENU
//         DD DISP=SHR,DSN=ISF.SISFPLIB
//ISPTLIB  DD RECFM=FB,LRECL=80,SPACE=(TRK,(1,0,1))
//         DD DISP=SHR,DSN=ISP.SISPTENU
//         DD DISP=SHR,DSN=ISF.SISFTLIB
//ISPSLIB  DD DISP=SHR,DSN=PSP.ENDV.TEAM.ISPSLIB    
//         DD DISP=SHR,DSN=ISP.SISPSENU
//         DD DISP=SHR,DSN=ISF.SISFSLIB
//ISPMLIB  DD DISP=SHR,DSN=ISP.SISPMENU
//         DD DISP=SHR,DSN=ISF.SISFMLIB
//IZUSRVMP DD PATH='&ROOT./defaults/izurf.tsoservlet.mapping.json'
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*                                 **added**
//SYSTSPRT DD SYSOUT=*                                 **added**
//CEEDUMP  DD SYSOUT=H
//SYSUDUMP DD SYSOUT=H
//ISPPROF DD DISP=NEW,UNIT=SYSDA,SPACE=(TRK,(15,15,5)),
//        DCB=(RECFM=FB,LRECL=80,BLKSIZE=3120)
