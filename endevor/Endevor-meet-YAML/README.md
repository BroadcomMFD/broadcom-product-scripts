# Endevor meet YAML #

These items demonstrate how YAML can be used to automatically select specific processing within an Endevor processor. Similarly, the same YAML examples may automate actions within Team Build scripts.

All three examples depend on the [YAML2REXX](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/YAML2REX.rex) program to convert YAML statements into complex REXX (stem array) statements, such as:


    JCL.UNITTEST.Changes.jobcard.FindTxt.1 ="CLASS=P,"                      
    JCL.UNITTEST.Changes.jobcard.Replace.1 ="CLASS=A,"                      
    JCL.UNITTEST.Changes.jobcard.FindTxt.2 ="//JOBNUM44 "                   
    JCL.UNITTEST.Changes.jobcard.Replace.2 ="//TOBNUM44 "                   
    JCL.UNITTEST.Changes.jobcard.FindTxt.3 ="//*     TEST PG000044 "          
    JCL.UNITTEST.Changes.jobcard.InsertWhere.3 ="AFTER"                     
    JCL.UNITTEST.Changes.jobcard.Insertx.3.1 ="//*--------------------------
    JCL.UNITTEST.Changes.jobcard.Insertx.3.2 ="//* Testing Element: JOBNUM44
    JCL.UNITTEST.Changes.jobcard.Insertx.3.3 ="//*  Stg DEV2 Sys FINANCE Sbs
    JCL.UNITTEST.Changes.jobcard.Insertx.3.4 ="//*--------------------------
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.FindTxt.1 ="//STEPLIB   DD DISP=SH
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.Replace.1 ="//STEPLIB  DD DSN=SYSD
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.FindTxt.2 ="//             DSN=SYS
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.Replace.2 ="//         DISP=SHR   
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.FindTxt.3 ="//             DSN=SYS
    JCL.UNITTEST.Changes.RUNNUM44.STEPLIB.InsertWhere.3 ="AFTER"            

Statements in this format enable REXX programs to exeucte DO-LOOPs to drive an automated process. See the DO-LOOPS in these examples:


[GALAIS.jcl](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/Dynamic-Syslib/GALIAS.jcl)  is a processor that shows the construction of DYNAMIC SYSLIBs. Within the DEFINES step of the processor you can see the call to [YAML2REX](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/YAML2REX.rex). 


