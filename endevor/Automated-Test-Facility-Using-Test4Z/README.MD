# Automated Testing in Endevor with Test4Z

Items in this folder can be used to introduce and automate testing in Endevor, running the kinds of test supported by Test4Z. 
See [Test4Z techdocs documentation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0.html) for two testing methods:

1. [Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html). The .jcl items in the **Quick-Edit-User-Extension-Points** subfolder correspond to the **Record and Replay** examples.
2. [Unit Test Processing](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/unit-test-processing.html). Build your **test suites** for your application programs. Then you may have them executed in Endevor by either or both of the methods described below. 



For the two Test4Z methods there are two testing methods provided in this solution:

1. Items that can help your site to take a first step toward integrating Test4Z with Endevor. These items initiate batch Test4Z actions from the [Quick-Edit User Extension points](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/using/quick-edit-option/quick-edit-user-extension-points.html). With these, you may prepare Test4Z objects to use with the second method. See the **Quick-Edit-User-Extension-Points** subfolder for items of this method. The .rex, .pnl and .skl items must be placed into REXX, ISPF panel alnd ISPF skeleton libraries accordingly. 


2. Items that can automate the running of tests run from your Endevor processor(S). Test4Z objects that you build using objects in the first category can be automatically engaged by your Endevor Generate and Move processors. Tests may pass or fail, and the condition is made to reflect the element status in Endevor. items using the .prc extension are processor Incluides. You can include them within your existing processors. If your configuration does not support the use of processor includes, then copy the content of the .prc items into your processors. (Future items will support automated teesting during the Endevor package CAST)


Set the value of the **MYJCLLIB** variable to a dataset name that contains JCL-snippets for Test4Z recording. See the **Example Record and Replay JCL** discussion in the [Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html) documentation.  **MYJCLLIB** can be an output library for a JCL-like type, or a dataset where testers can edit directly. Configuring the dataset to be an Endevor output is a better choice, but not required.

You may double-click on the batch file named Test4Z.bat, to create a ".moveout" file. Then upload the ".moveout" file to place all items from this folder onto your mainframe. 


