//*********************************************************************
//* Prepare ALTER statements for a Remote Endevor to Endevor
//*         Package Shipment
//* &&& variables are substituted at Package Shipping time.
//*          Values are provided from SYSDE32.NDVR.PARMLIB(DESTCNFG)
//*          (this version assumes Subsystem names are the same)
//*********************************************************************
//RMALTERS EXEC PGM=IEBGENER
//*        EXECIF=(&C1PKGID,GT,AA)
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD * &&& values <-SYSDE32.NDVR.PARMLIB(DESTCNFG)
  ALTER ELEMENT  &C1ELEMENT
         FROM SYSTEM  &&&C1SYSTEM
              SUBSYSTEM &C1SUBSYS TYPE &&&C1ELTYPE
      REPLACE USER DATA WITH
      (1,,,'DE32: &C1PKGID | &C1USERID | &C1VER.&C1LEV &C1ELTYPE')
      REPLACE GENERATE CCID WITH '&C1CCID'
      REPLACE DESCRIPTION   WITH
        '&C1COMMENT'
        OPTIONS CCID "&C1CCID"
        COMMENT "&C1COMMENT"
        UPDATE ELEMENT
   .
//SYSUT2   DD DSN=SYSDE32.NDVR.ADMIN.ENDEVOR.SHIP.ALTERS(&C1ELEMENT),
//            DISP=SHR,MONITOR=COMPONENTS
//SYSIN    DD DUMMY                               CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*--------------------------------------------------------------------
