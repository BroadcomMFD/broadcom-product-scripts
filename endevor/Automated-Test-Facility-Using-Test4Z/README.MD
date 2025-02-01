# Automated Testing in Endevor with Test4Z

## Introduction

Items in this folder can be used to introduce and automate testing in Endevor, running the kinds of test supported by Test4Z. 
See the two modes of testing described [Testing Modes](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/define-options-for-unit-and-record-and-replay.html) and [Test4Z techdocs documentation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0.html) :

1. [Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html). The .jcl items in the **Quick-Edit-User-Extension-Points** subfolder correspond to the **Record and Replay** examples.
2. [Unit Test Processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/unit-test-processing.html). Build your **test suites** for your application programs. Then you may have them executed in Endevor by either or both of the methods described below. 



For the two Test4Z methods there are two testing methods provided in this solution:

1. Items that can help your site to take a first step toward integrating Test4Z with Endevor. These items initiate batch Test4Z actions from the [Quick-Edit User Extension points](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/using/quick-edit-option/quick-edit-user-extension-points.html). With these, you may prepare Test4Z objects to use with the second method. See the **Quick-Edit-User-Extension-Points** subfolder for items of this method. The .rex, .pnl and .skl items must be placed into REXX, ISPF panel alnd ISPF skeleton libraries accordingly. 


2. Items that can automate the running of tests run from your Endevor processor(S). Test4Z objects that you build using objects in the first category can be automatically engaged by your Endevor Generate and Move processors. Tests may pass or fail, and the condition is made to reflect the element status in Endevor. Items using the .prc extension are processor Incluides. You can include them within your existing processors. If your configuration does not support the use of processor includes, then copy the content of the .prc items into your processors. (Future items will support automated teesting during the Endevor package CAST)


Set the value of the **MYJCLLIB** variable to a dataset name that contains JCL-snippets for Test4Z recording. See the **Example Record and Replay JCL** discussion in the [Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html) documentation.  **MYJCLLIB** can be an output library for a JCL-like type, or a dataset where testers can edit directly. Configuring the dataset to be an Endevor output is a better choice, but not required.

You may double-click on the batch file named Test4Z.bat, to create a ".moveout" file. Then upload the ".moveout" file to place all items from this folder onto your mainframe. 

# Test4Z Modes


The Test4Z Testing Modes are described [here](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/define-options-for-unit-and-record-and-replay.html). 


- **RECORD**. The Test4Z Record action is a prerequisite for the REPLAY. This solution requires that the **RECORD** action  be run using the Quick-Edit User Extensions. It is anticipated that you may want to develop the inputs and outputs for the Recording session, and run the process perhaps multiple times without requiring a program compile. The output from the **RECORD** action is captured to be used with a **REPLAY**.


- **REPLAY**.  Preceede a **REPLAY** with a **RECORD** action. You may execute a **REPLAY** using the Quick-Edit User Extensions and/or by automating its execution by a processor.  See [Record, Replay, and Verification processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html) .


- **Unit Test** processing may be executed using the Quick-Edit User Extensions and/or by automating its execution by a processor.  [Unit Test Processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/unit-test-processing.html)


# Endevor Types

There are four potential Endevor Types that might be useful for this solution. If you use Endevor Processors to automate testing, then only the OPTIONS element type is required. You may use any Types name you prefer, rather than the ones refereced within items in this folder. 

- **OPTIONS**. The use of an **OPTIONS** element type originally comes from the inputs to the CONPARMX processor utility described [Here](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/processor-utilities/conparmx-utility.html). It is not necessary that CONPARMX be already executed within your processors, but the type is required by this solution if processors are to execute automated tests.


- **T4ZLDATA**.  When a **RECORD** action is run, the captured data is ADDed into Endevor as type **T4ZLDATA**. The Endevor Type definition allows you to compress the data, and better manage its size. You may elect to bypass defining a Type, by placing the recoreded data into an output file only. Then, modify the Record and Replay steps to simply access the file.  


- **COBOLTST**.  If you plan to use **UNIT TEST SUITE MODULEs**, then you may manage them as COBOLTST elements, or another Type name of your choice. Alternatively, you may develop them outside of Endevor, and allows the processing in this solution simply reference the load library name where your **UNIT TEST SUITE MODULEs** are found.

- **USERJCL**.  This solution assumes that the JCL Snippets are manually placed into this file, whose name you enter onto the Quick-Edit User Extensins panels. You may elect to make the file become an output file for a new Endevor Type,


