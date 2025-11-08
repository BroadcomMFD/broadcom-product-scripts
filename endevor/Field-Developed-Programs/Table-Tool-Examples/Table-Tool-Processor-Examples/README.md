# Table Tool Processor Examples

Table Tool can run in your Endevor processors. This folder gives some things to consider, and some examples for the use of Table Tool in processors.

**Caution** When allowing OPTIONS as input
When OPTIONS are an element and available to Developers to edit then take these cautionary measures. Use a processor like [GOPTIONS](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/GOPTIONS%20-%20Options%20syntax%20processor.jcl) to validate that the OPTIONS element contains only statements in one of these formats:

    keyword = 'value'
    keyword = "value"
    keyword = number 

Also in the Table Tool processor step that operates on the options, use the IncludeQuotedOptions reference to them, as opposed to including or appending them to the OPTIONS.

    x = 'IncludeQuotedOptions(UOPTIONS)';   
    . . .
    //UOPTIONS  DD  ... developer edited options*

## Table Tool as a complement to CONPARMX
You can find details of the [CONPARMX](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/processor-utilities/conparmx-utility.html) processor utility here, and a description of the **VALUECHK** program [here](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets). 

Here is an example step that tests user OPTIONS to determine whether MQSeries='Y' is specified:

    //MQSERIES EXEC PGM=IRXJCL,PARM='ENBPIU00 1 x'             GCOBOL       
    //TABLE    DD *                                                         
    *  MQSeries      $my_rc                                                 
       Y              1                                                     
       *              0                                                     
    //OPTIONS  DD *                                                         
      x = IncludeQuotedOptions(UOPTIONS)                                   
    //UOPTIONS DD *
      MQSeries = 'N'                                                        
    //SYSEXEC  DD DISP=SHR,DSN=your.CSIQCLS0                      
    //MODEL    DD DUMMY                                                     
    //TBLOUT   DD SYSOUT=*                                                  
    //SYSTSPRT DD SYSOUT=*                                                  

The VALUECHK program does the same kind of checking.

## Leveraging the Component list and CONMOVE in a MOVE processor

## Examples for DB2 Binds

## Sandbox processor example

## Working with YAML input

## Leveraging Endevor's ALLOC=xMAP feature

Here is a processor step that identifies the libraries allocated by Endevor for either an ALLOC=LMAP or an ALLOC=PMAP clause. You can use a step like this for many different reasons. This code is found in the processor that supports automated TEST4Z testing from the processor, but you might, for example, want to put the expanded list of libraries in your processor output listings.

    //*********INCLUDE (TZUNITST)****************************************   
    //*--------------------------------------------------------------------*
    //T4ZUNI#1 EXEC PGM=IKJEFT1B,PARM='ENBPIU00 A'             TZUNITST     
    //*TABLE   is dynamically built from the LISTALC output for LMAPPED     
    //TABLE    DD  DSN=&&TABLE,DISP=(NEW,PASS),                             
    //             UNIT=SYSDA,SPACE=(TRK,(5,5)),                            
    //             DCB=(RECFM=FB,LRECL=080,BLKSIZE=24000)                   
    //*POSITION of data within the LISTALC output                           
    //POSITION DD  *                                                        
    Dataset  1 44                                                         
    //OPTIONS  DD *                                                         
    $Table_Type = "positions"                                             
    If $row# = 0 then, +                                                  
        Do; starthere = 0 ; stophere = 0 ; +                               
        X = OUTTRAP(line.); +                                            
        ADDRESS TSO 'LISTALC STATUS HISTORY'; +                          
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 20 Line(s) not Displayed 
    //MODEL    DD DATA,DLM=QQ                                               
    //         DD DISP=SHR,DSN=&Dataset       
    QQ                                                           
    //SYSEXEC  DD DISP=SHR,DSN=&SYSEXEC1                         
    //         DD DISP=SHR,DSN=&SYSEXEC2                         
    //SYSIN    DD DUMMY                                          
    // IF ('&C1PRGRP(1,4)' = 'CICS') THEN                        
    //LMAPPED  DD DISP=SHR,DSN=&CICSLOAD,ALLOC=LMAP              
    //         DD DISP=SHR,DSN=&T4ZLOAD,ALLOC=LMAP               
    // ELSE                                                      
    //LMAPPED  DD DISP=SHR,DSN=&LOADLIB,ALLOC=LMAP               
    //         DD DISP=SHR,DSN=&T4ZLOAD,ALLOC=LMAP               
    // ENDIF                                                     
    //SYSTSPRT DD SYSOUT=*                                       
    //SYSTSIN  DD DUMMY                                          
    //TBLOUT   DD  DSN=&&LOADLIBS,DISP=(NEW,PASS),               
    //             UNIT=SYSDA,SPACE=(TRK,(1,1)),                 
    //             DCB=(RECFM=FB,LRECL=080,BLKSIZE=24000)                 

Both Endevor and TableTool will substitute variables on this step. Both only sustitute values for variables that they know. For example, Endevor Knows the values for the &C1 variables, processor and Esymbols variables, but leaves the rest (including Table Tool variables alone. Here is what happens on this step:

- Before the processor is run, Endevor replaces its known variables with values and allocates files:
    - At this point, Table is allocated as an empty dataset 
    - For the ALLOC=LMAP clause on the LMAPPAED DDname, Endevor expands into multiple real dataset names
    - Endevor executes the processor and the T4ZUNI#1 step. 
- Table Tool is executed. 
    - The TABLE is still an empty file at this point. Before Table Tool attempts to open the Table, it first executes the content of OPTIONS. Notice the [LISTALC](https://www.ibm.com/docs/en/zos/3.2.0?topic=subcommands-listalc-command) command is executed within the OPTIONS. This IBM function gets a list of allocated datasets. The OPTIONS statements write the list of datasets to the Table Tool Table. Then, when Table Tool opens the Table, there is data there - a LISTALC of datasets allocated on that step, including the LMAPPED datasets allocated by Endevor with the ALLOC clause.
    - Table Tool reads the dataset names allocated to LMAPPEd, uses the MODEL to format output, and write the expanded result to TBLOUT. In this case the MODEL is a single line of JCL. 
    - When the step completes, the content of TBLOUT might look something like this:

    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.DEV1.LOADLIB      
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.DEV2.LOADLIB     
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.QAS2.LOADLIB  
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.PRD.LOADLIB  
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.DEV1.T4ZLOAD      
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.DEV2.T4ZLOAD     
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.QAS2.T4ZLOAD  
    //         DD DISP=SHR,DSN=Myhlq.ENDEVOR.PRD.T4ZLOAD  


## Building JCL, Submitting it, and waiting for it to run





