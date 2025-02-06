# Quick Edit User Extension Points

Items in this folder leverage an existing feature in Quick Edit named the [Quick-Edit User Extension points](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/using/quick-edit-option/quick-edit-user-extension-points.html). 
 You can quickly get started toward integrating Test4Z with Endevor, by incorporating the items in this folder. It is a good way to start, before migrating to the second method - using Endevor procdessors. 

## Setup Prerequisites

The .rex, .pnl and .skl items must be placed into REXX, ISPF panel alnd ISPF skeleton libraries accordingly. 

If you are not already using Quick-Edit User Extensions, here is how you may engage the feature:

In your CSIQSRC(ENCOPTBL) turn on the QE user routines with this option:

    CD18102_QE_USER_ROUTINES=ON  

In your CSIQSRC(ENDICNFG) turn off the "Hide" option: 

    UI_OPT_HIDE_NDUSRX=N        

## Considerations for the Test4Z Record action

JCL content used for **Record** actions depends on the technical composite of the program being tested. See the **Example Record and Replay JCL** section in the  
[Record and Replay](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/test4z/1-0/administrating/record-replay-and-verification-processing.html).  Because of the JCL diversity, the Quick Edit User Extensions require steps to be maintained as members in a **MYJCLLIB** dataset. A member names must match the names of an application COBOL program, and must contain RECORD snippets of JCL. In other words, members in your **MYJCLLIB** will resemble the **Record and Replay JCL** examples shown in the documentation. 

Set the value of the **MYJCLLIB** variable to a dataset name that contains JCL-snippets for Test4Z recording. **MYJCLLIB** can be an output library for an Endevor type, or a dataset where testers can edit directly. Configuring the dataset to be an Endevor output is a better choice, but not required.
