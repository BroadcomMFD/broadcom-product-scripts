# Automated Testing in Endevor with Test4Z

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

## Introduction

Items in this folder can be used to introduce and automate testing in Endevor, running the kinds of test supported by Test4Z. 
See the two modes of testing described in [Testing Modes](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/define-options-for-unit-and-record-and-replay.html) and [Test4Z techdocs documentation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0.html) :

1. [Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html). The .jcl items in the **Quick-Edit-User-Extension-Points** subfolder correspond to the **Record and Replay** examples.
2. [Unit Test Processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/unit-test-processing.html). Build **test suites** for your application programs. Then you may have Endevor execute them using either or both of the methods described below. 



This folder provides for two Endevor methods for executing the Test4Z modes:

1. [Quick-Edit User Extension points](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/using/quick-edit-option/quick-edit-user-extension-points.html). 
See the content of the **Quick-Edit-User-Extension-Points** folder for details.

2. [Endevor processors](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors.html).   Items that can automate the running of tests run from your Endevor processor(s). Test4Z objects can be automatically engaged by your Endevor Generate and Move processors. Tests may pass or fail, and the condition is made to reflect onto the element status in Endevor. Items using the .prc extension are processor Incluides. You can include them within your existing processors. If your configuration does not support the use of processor includes, then copy the content of the .prc items into your processors. If you are interested in seeing more about the use of processor Includes, see [Panvalet-Like Includes](https://community.broadcom.com/viewdocument/panvalet-like-includes?CommunityKey=592eb6c9-73f7-460f-9aa9-e5194cdafcd2&tab=librarydocuments) .

You may double-click on the batch file named Test4Z.bat, to create a ".moveout" file. Then upload the ".moveout" file to place all items from this folder onto your mainframe. 

## Test4Z Modes


The Test4Z Testing Modes are described [here](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/define-options-for-unit-and-record-and-replay.html). 


- **RECORD**. The Test4Z Record action is a prerequisite for the REPLAY. This solution requires that the **RECORD** action  be run using the Quick-Edit User Extensions. It is anticipated that you may want to develop the inputs and outputs for the Recording session, and run the process perhaps multiple times without requiring a program compile. The output from the **RECORD** action is captured to be used with a **REPLAY**.


- **REPLAY**.  Preceede a **REPLAY** with a **RECORD** action. You may execute a **REPLAY** using the Quick-Edit User Extensions and/or by automating its execution by a processor.  See [Record, Replay, and Verification processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html) .


- **Unit Test** processing may be executed using the Quick-Edit User Extensions and/or by automating its execution by a processor.  [Unit Test Processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/unit-test-processing.html)

## SUCCESS / WARNING / FAILURE

An assessment of the completed Test is made automatically to make it easier for you to know the results. One of the outputs will be given, as shown in this example job output: 

    -------------------------------------------------------------------------------
    Cmd      DDname   Stepname Procstep Status     Cpys  TotLines OutClass Prty    
    ________ JESMSGLG JES2              HELD          1        30 X         144   
    ________ JESJCL   JES2              HELD          1        32 X         144   
    ________ JESYSMSG JES2              HELD          1       615 X         144   
    ________ C1MSGS1  $$$$$$@           HELD          1      1132 X         144   
    ________ C1MSGS2  $$$$$$@           HELD          1         8 X         144   
    ________ SYSUT2   $$$$$$@           HELD          1         2 X         144   
    ________ MSGOUT1  $$$$$$@           HELD          1        36 X         144   
    ________ MSGOUT2  $$$$$$@           HELD          1         8 X         144   
    ________ SYSTSPRT $$$$$$@           HELD          1         1 X         144   
    ________ SYSTSPRT $$$$$$@           HELD          1         4 X         144   
    ________ ZLMSG    $$$$$$@           HELD          1       652 X         144   
    ________ SUCCESS  $$$$$$@           QUEUED        1         2 A         144   
    
  

## Why is there So Much REXX

REXX can run almost anywhere on the mainframe. The IBM feature for [Using IRXJCL to execute an in-stream REXX exec](https://www.ibm.com/docs/en/zos/2.5.0?topic=routine-using-irxjcl-execute-in-stream-rexx-exec) has empowered this solution in several ways:

- REXX can run in skeleton-based submitted jobs - without having to be placed into separate REXX libraries.
- In-stream REXX works quite well within processors, empowering them to make dynamic decisions based on Endevor processor symbols and other information.
- REXX runs comfortably in Table Tool steps 
- The REXX code in this solution is stable, and does not need any adjustments at your site.


## Endevor Types

There are four potential Endevor Types that might be useful for this solution. If you use Endevor Processors to automate testing, then only the OPTIONS element type is required. You may use any Types name you prefer, rather than the ones refereced within items in this folder. 

- **OPTIONS**. The use of an **OPTIONS** element type originally comes from the inputs to the CONPARMX processor utility described [Here](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/processor-utilities/conparmx-utility.html). It is not necessary that CONPARMX be already executed within your processors, but the type is required by this solution if processors are to execute automated tests.


- **T4ZLDATA**.  When a **RECORD** action is run, the captured data is ADDed into Endevor as type **T4ZLDATA**. The Endevor Type definition allows you to compress the data, and better manage its size. You may elect to bypass defining a Type, by placing the recoreded data into an output file only. Then, modify the Record and Replay steps to simply access the file.  


- **COBOLTST**.  If you plan to use **UNIT TEST SUITE MODULEs**, then you may manage them as COBOLTST elements, or another Type name of your choice. Alternatively, you may develop them outside of Endevor, and allows the processing in this solution simply reference the load library name where your **UNIT TEST SUITE MODULEs** are found.

- **USERJCL**.  This solution assumes that the JCL Snippets are manually placed into this file, whose name you enter onto the Quick-Edit User Extensins panels. You may elect to make the file become an output file for a new Endevor Type,


