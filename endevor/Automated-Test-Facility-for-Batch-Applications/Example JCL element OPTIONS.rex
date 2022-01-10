<<<<<<< HEAD
* An asterisk in Column 1 designates a commment line
*
* If you want to turn off FindTxt and Replace messages, include the statement below              
  ShowReplaceResults = 'N'  
* Otherwise by omitting the statement, all messages will be written.                         
                                                     
*-----------------------------------------------------------------*
* Specifications for the UTC stage
=======
*-----------------------------------------------------------------*
* Specifications for the UTC stage
*      (an asterisk in Column 1 designates a commment line)
>>>>>>> bd7e7dd6bf037ff027017f29a572cf2986aeb566
*-----------------------------------------------------------------*

JCL.UNITTEST.FindTxt.1 = '//MISDXW#D JOB '
JCL.UNITTEST.Replace.1 = '//UNITTEST JOB '

JCL.UNITTEST.FindTxt.2 = '(MISDXW),'
JCL.UNITTEST.Replace.2 = '(301000000),'

JCL.UNITTEST.FindTxt.3 = 'NOTIFY=MISDXW'
JCL.UNITTEST.Replace.3 = 'NOTIFY=&SYSUID'

JCL.UNITTEST.FindTxt.4 = 'DSN=T.TEST.OPTIONS'
JCL.UNITTEST.Replace.4 = 'DSN=NDV.MOTM.ESCMSNDV.SHRD.D1.OPTIONS'

JCL.UNITTEST.FindTxt.5 = 'DSN=T.QAIN.OPTIONS'
JCL.UNITTEST.Replace.5 = 'DSN=NDV.MOTM.ESCMSNDV.SHRD.D2.OPTIONS'

JCL.UNITTEST.FindTxt.6 = '//         DD  DISP=SHR,DSN=T.QAWK.OPTIONS'
JCL.UNITTEST.Replace.6 = '//****     DD  DISP=SHR,DSN=T.QAWK.OPTIONS'

JCL.UNITTEST.FindTxt.7 = '//         DD  DISP=SHR,DSN=T.OPIN.OPTIONS'
JCL.UNITTEST.Replace.7 = '//****     DD  DISP=SHR,DSN=T.OPIN.OPTIONS'

JCL.UNITTEST.FindTxt.8 = '//         DD  DISP=SHR,DSN=T.PROD.OPTIONS'
JCL.UNITTEST.Replace.8 = '//****     DD  DISP=SHR,DSN=T.PROD.OPTIONS'

JCL.UNITTEST.FindTxt.9 = './  REPRO NEW=PS,NAME=TESTPGM '
JCL.UNITTEST.Replace.9 = './  REPRO NEW=PS,NAME=DYNMPARM'

JCL.UNITTEST.FindTxt.10= 'DSN=T.PROD.OPTIONS(DEFAULT)'
JCL.UNITTEST.Replace.10= 'DSN=BST.QA.ENBPIU00.OPTIONS(DEFAULT)'

JCL.UNITTEST.FindTxt.11= 'MISDXW.ENDEVOR.SOURCE(TESTPGM)'
JCL.UNITTEST.Replace.11= 'NDV.MOTM.ESCMSNDV.SHRD.D1.SOURCE(DYNMPARM)'

JCL.UNITTEST.FindTxt.12= 'DSN=&&OPTUPDT'
JCL.UNITTEST.Replace.12= 'DSN=&&OPTIONS'

JCL.UNITTEST.FindTxt.13= 'EXEC PGM=GOCRAZY'
JCL.UNITTEST.where.13= 'BEFORE'
JCL.UNITTEST.Insertx.13= '//**  For testing, end the jcl here   ',
                         '//                                    '

JCL.UNITTEST.FindTxt.14= 'DSN=MISDXW.ENDEVOR.LOAD(TESTPGM)'
JCL.UNITTEST.Replace.14= 'DSN=BST.ENDEVOR.DE32.LOADLIB(DYNMPARM)'

JCL.UNITTEST.FindTxt.15= '//SYSOUT    DD DUMMY '
JCL.UNITTEST.Replace.15= '//SYSOUT    DD SYSOUT=*'

* Show the insert of a comment reflecting Endevor classification:
JCL.UNITTEST.FindTxt.16 = '//  EXPORT SYMLIST='
JCL.UNITTEST.where.16 = 'BEFORE'
JCL.UNITTEST.Insertx.16 =,
            '//* Testing Stg=&C1STAGE Sys=&C1SYSTEM Sbs=&C1SUBSYS '

* Replace every STEPLIB
JCL.UNITTEST.Replace.STEPLIB. =,
                         'NDV.MOTM.ESCMSNDV.SHRD.D1.LOADLIB ',
                         'NDV.MOTM.ESCMSNDV.SHRD.D2.LOADLIB ',
                         'IBMPROD.V1R4M0.COB2COMP'

* Replace SYSLIB concatenations for COMPILE and LKED steps
JCL.UNITTEST.Replace.SYSLIB.COMPILE =,
        'CATSNDVR.NDVR.EMER.CATSNDVR.COPY ',
        'CATSNDVR.NDVR.PROD.CATSNDVR.COPY '

JCL.UNITTEST.Replace.SYSLIB.LKED =,
        'CATSNDVR.NDVR.EMER.CATSNDVR.LOADLIB ',
        'CATSNDVR.NDVR.PROD.CATSNDVR.LOADLIB ',
        'IBMPROD.V1R4M0.COB2LIB'

* Replace SYSLMOD for the LKED step
JCL.UNITTEST.Replace.SYSLMOD.LKED =,
        'BST.ENDEVOR.DE32.LOADLIB(DYNMPARM)'

JCL.UNITTEST.BASELINE=,
        'BST.ENDEVOR.CA32.UNITTEST.BASELINE(MISDXW#D)'

JCL.UNITTEST.MaxReturnCode= 4 

*-----------------------------------------------------------------*
* Specifications for the UTC stage
*-----------------------------------------------------------------*

JCL.UTC.FindTxt.1 = '//MISDXW#D JOB '
JCL.UTC.Replace.1 = '//UTC#TEST JOB '

JCL.UTC.FindTxt.2 = '(MISDXW),'
JCL.UTC.Replace.2 = '(301000000),'

JCL.UTC.FindTxt.3 = 'NOTIFY=MISDXW'
JCL.UTC.Replace.3 = 'NOTIFY=&SYSUID'

JCL.UTC.FindTxt.4 = 'DSN=T.TEST.OPTIONS'
JCL.UTC.Replace.4 = 'DSN=NDV.MOTM.ESCMSNDV.SHRD.D1.OPTIONS'

JCL.UTC.FindTxt.5 = 'DSN=DSN=T.QAIN.OPTIONS'
JCL.UTC.Replace.5 = 'DSN=NDV.MOTM.ESCMSNDV.SHRD.D2.OPTIONS'

JCL.UTC.FindTxt.6 = '//         DD  DISP=SHR,DSN=T.QAWK.OPTIONS'
JCL.UTC.Replace.6 = '//****     DD  DISP=SHR,DSN=T.QAWK.OPTIONS'

JCL.UTC.FindTxt.7 = '//         DD  DISP=SHR,DSN=T.OPIN.OPTIONS'
JCL.UTC.Replace.7 = '//****     DD  DISP=SHR,DSN=T.OPIN.OPTIONS'

JCL.UTC.FindTxt.8 = '//         DD  DISP=SHR,DSN=T.PROD.OPTIONS'
JCL.UTC.Replace.8 = '//****     DD  DISP=SHR,DSN=T.PROD.OPTIONS'

JCL.UTC.FindTxt.9 = './  REPRO NEW=PS,NAME=TESTPGM '
JCL.UTC.Replace.9 = './  REPRO NEW=PS,NAME=DYNMPARM'

JCL.UTC.FindTxt.10= 'DSN=T.PROD.OPTIONS(DEFAULT)'
JCL.UTC.Replace.10= 'DSN=BST.QA.ENBPIU00.OPTIONS(DEFAULT)'

JCL.UTC.FindTxt.11= 'MISDXW.ENDEVOR.SOURCE(TESTPGM)'
JCL.UTC.Replace.11= 'NDV.MOTM.ESCMSNDV.SHRD.D2.SOURCE(DYNMPARM)'

JCL.UTC.FindTxt.12= 'DSN=&&OPTUPDT'
JCL.UTC.Replace.12= 'DSN=&&OPTIONS'

JCL.UTC.FindTxt.13= 'EXEC PGM=GOCRAZY '
JCL.UTC.where.13= 'BEFORE'
JCL.UTC.Insertx.13= '//**  For testing, end the jcl here   ',
                    '//                                    '

JCL.UTC.FindTxt.14= 'DSN=MISDXW.ENDEVOR.LOAD(TESTPGM)'
JCL.UTC.Replace.14= 'DSN=BST.ENDEVOR.DE32.LOADLIB(DYNMPARM)'

JCL.UTC.FindTxt.15= '//SYSOUT    DD DUMMY '
JCL.UTC.Replace.15= '//SYSOUT    DD SYSOUT=*'

* Replace every STEPLIB
JCL.UTC.Replace.STEPLIB. = 'NDV.MOTM.ESCMSNDV.SHRD.D2.LOADLIB ',
                           'IBMPROD.V1R4M0.COB2COMP'

* Replace SYSLIB concatenations for COMPILE and LKED steps
JCL.UTC.Replace.SYSLIB.COMPILE =,
        'CATSNDVR.NDVR.PROD.CATSNDVR.COPY'

JCL.UTC.Replace.SYSLIB.LKED =,
        'CATSNDVR.NDVR.PROD.CATSNDVR.LOADLIB ',
        'IBMPROD.V1R4M0.COB2LIB'

* Replace SYSLMOD for the LKED step
JCL.UTC.Replace.SYSLMOD.LKED =,
        'BST.ENDEVOR.DE32.LOADLIB(DYNMPARM)'

JCL.UTC.MaxReturnCode= 1    

*-----------------------------------------------------------------*
* Specifications for all stages
*-----------------------------------------------------------------*

* Indicate how many loops to make, and how long to wait for each loops 
WaitLoops    = 4
LoopSeconds  = 2

* Options for the Comparison of test results...

* If no Baseline is specified, then the current test result 
* is compared with the previous one.
JCL.UNITTEST.BASELINE=,                               
        'BST.ENDEVOR.CA32.UNITTEST.BASELINE(MISDXW#D)'

* Only one of the 3 Superc_Parms is necessary. 
* Each produces a report in a unique format.
Superc_Parms = 'LONGL,LINECMP'
Superc_Parms = 'LONGL,LINECMP,WIDE'
Superc_Parms = 'DELTAL,LINECMP'

* If in column 1 of the output, numeric text is found similar to this,
*    then replace the numbers with all '9's.                                                 
JCL.UNITTEST.MaskTarget.1 = '99999999 99:99:99 ' 
JCL.UNITTEST.MaskColumn.1 = 1                    
                                                 
