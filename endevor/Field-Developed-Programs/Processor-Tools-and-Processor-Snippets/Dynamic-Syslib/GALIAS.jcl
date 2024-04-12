//*******************************************************************
//**                                                               **
//**    ALIAS  GENERATE processor                                  **
//**      Supports Dynamic SYSLIBS in your COBOL +other            **
//**      Generate processors. SYSLIB concatenations can be        **
//**      adjusted "on the fly" by order of library names          **
//**      within the controlling YAML.                             **
//**                                                               **
//**      Only the top portion of the SYSLIB concatenations        **
//**      should be governed this way.                             **
//**                                                               **
//*******************************************************************
//GALIAS  PROC AAAA=,
//        IDCAMS=Y,            <- EXecute IDCAMS to DEFINE ALIASEs
//        SHOWME=Y,            <- Show intermediate results
//        WRKUNIT=VIO
//**********************************************************************
//*   ALLOCATE TEMPORARY DATASETS                                      *
//**********************************************************************
//INIT     EXEC PGM=BC1PDSIN,MAXRC=0                       GALIAS
//C1INIT01 DD  DSN=&&SOURCE,
//             DISP=(,PASS),
//             UNIT=&WRKUNIT,
//             SPACE=(TRK,(01,05)),
//             DCB=(RECFM=FB,LRECL=120,BLKSIZE=24000)
//*********************************************************************
//* READ SOURCE (Yaml Representation of library concatenations)       *
//*********************************************************************
//CONWRITE EXEC PGM=CONWRITE,COND=(4,LT),MAXRC=0,          GALIAS
// PARM='EXPINCL(N)'
//ELMOUT   DD DSN=&&SOURCE,DISP=(OLD,PASS)
//*-------------------------------------------------------------------*
//*-- Convert YAML to REXX onto Stack                -----------------*
//*-- Convert REXX to DEFINE ALIAS commands          -----------------*
//*-------------------------------------------------------------------*
//DEFINES EXEC PGM=IRXJCL,PARM='ENBPIU00 PARMLIST'         GALIAS
//TABLE    DD *   <- List kinds of Syslibs you want supported
* Step_Name          AliasSuffix
  Compile_Step       COPY
  Link_Step          LOAD
//PARMLIST DD *
  NOTHING  NOTHING  OPTIONS0  0
  MODEL    TBLOUT   OPTIONS1  A
//OPTIONS0 DD *   <- Establish Defaults. Collect Rexx converted fr YAML
* -- Enter your site variables here.     / C1ELEMENT is a subsys name
   AliasPrefix = 'SYSMD32.ALIAS.&C1SY..'
   MaxEntries = 6
   Compile_Step. = ''
   Link_Step. = ''
* -- Convert YAML in SYSLIBS into Rexx onto Stack
   $MultiplePDSmemberOuts = 'Y' /* Set to 'Y' if mult outputs */
   Call YAML2REX 'SYSLIBS'
   HowManyYamls = QUEUED();
   Say 'HowManyYamls=' HowManyYamls
   Do yaml# =1 to HowManyYamls; +
      pull yaml2rexx; say yalm2rexx; interpret yaml2rexx; +
   End
//OPTIONS1 DD *   <- Loop thru MaxEntries for each Step_Name
   Say 'HowManyYamls=' HowManyYamls
   Do yaml# =1 to MaxEntries  ; +
      DatasetName = Value(Step_Name'.'yaml#); +
      AliasName = +
        Value(AliasPrefix ||'&C1ELEMENT..' ||AliasSuffix||yaml#); +
      TBLOUT = 'DELETES'; x = BuildFromMODEL(MODEL1); +
      Say AliasName DatasetName; +
      if DatasetName /= '' then, +
         Do; TBLOUT ='TOIDCAMS'; x = BuildFromMODEL(MODEL2); END; +
   End
   $SkipRow = 'Y'
//YAML2REX DD DUMMY
//NOTHING  DD DUMMY
//MODEL1   DD *   <- Delete any previous Alias defined (if any)
  DELETE ('&AliasName') ALIAS
  SET MAXCC=0
//MODEL2   DD *   <- Define new Alias for Dataset
  DEFINE ALIAS  -
     (  NAME('&AliasName') -
      RELATE('&DatasetName') )
//SYSLIBS  DD DSN=&&SOURCE,DISP=(OLD,DELETE)
//SYSEXEC  DD DISP=SHR,DSN=SYSMD32.NDVR.ADMIN.ENDEVOR.ADM1.CLSTREXX
//SYSTSPRT DD SYSOUT=*
//DELETES  DD  DSN=&&DELETES,UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//TOIDCAMS DD  DSN=&&TOIDCAMS,UNIT=&WRKUNIT,
//             SPACE=(TRK,(1,5),RLSE),
//             DISP=(NEW,PASS),
//             DCB=(RECFM=FB,LRECL=80,DSORG=PS)
//TBLOUT   DD DUMMY
//*******************************************************************
//***** Show the results for IDCAMS                   ***************
//*******************************************************************
//SHOWME  EXEC PGM=IEBGENER,                               GALIAS
//        EXECIF=(&SHOWME,EQ,Y)
//SYSPRINT DD SYSOUT=*                           MESSAGES
//SYSUT1   DD  DSN=&&DELETES,DISP=(OLD,PASS)
//         DD  DSN=&&TOIDCAMS,DISP=(OLD,PASS)
//SYSUT2   DD SYSOUT=*                           OUTPUT FILE
//SYSIN    DD DUMMY                              CONTROL STATEMENTS
//SYSUDUMP DD SYSOUT=*
//*******************************************************************
//***** Define Aliases for use in Generate processors ***************
//*******************************************************************
//DEFINE  EXEC PGM=IDCAMS,MAXRC=4,                         GALIAS
//        EXECIF=(&IDCAMS,EQ,Y)
//SYSIN    DD  DSN=&&DELETES,DISP=(OLD,DELETE)
//         DD  DSN=&&TOIDCAMS,DISP=(OLD,DELETE)
//SYSPRINT DD SYSOUT=*
//AMSDUMP  DD SYSOUT=*
//*******************************************************************
