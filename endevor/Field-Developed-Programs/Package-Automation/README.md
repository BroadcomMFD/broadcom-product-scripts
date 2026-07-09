# Package-Automation

This collection provides two opportunities to introduce automation for package actions:

  - Automate Package Executions as soon as the package status changes to "APPROVED", and the Execution window is open.
  - Automate Package Shipments as soon as the package status changes to "EXECUTED", and your "Rules" for package shipments indicate that the package should be Shipped to one or more destinations.

If both actions are automated, then (for example) the final approval given to a package would kick off a package execution, and followed immediately by package shipments to multiple destinations.

Whether a triggering action is performed manually, by a zowe command, a sweep job, the Endevor web interface, or any other means, the Package Automation follow-up actions, based on an Endevor exit, remain consistently the same.

## Package Automation on Multiple Endevor images

Some Endevor administrators have responsibility for multiple Endevor images, where details like the life cycle map, job card information and dataaset names differ from one image to the next. 
To manage the variations from multiple images, the instructions and members listed below are provided, and allow the majority of remaining items to be left unchanged.

On each Lpar where portions of this collection will run:

 - Place the REXX items into a new or existing library of your choice. 
 - Enter the name the REXX library into the Exit program you choose to use
     - C1UEXT07 for Automated Executions and Shipments 
     - C1UEXSHP for Automated Shipments only 
 - The WHEREIAM.rex member is not a part of the configuration, 
 but is provided to help identify names you should use as @site member names. 
 Execute the WHEREIAM.rex (as is) to determine the name to give to the member currently named @site. 
 Then tailor the content to reflect values for the Lpar. 

    For example, if you intend to execute the collection on Lpars named SYS1 and SYS7, 
  then WHEREIAM.rex will instruct you to create members @SYS1 and @SYS7 respectively. 
  The names you use for the Rules and Trigger files (and other values) must entered into the @SYS1 and @SYS7 members. 
  
## Automate Package Executions

 When a package Status changes to "APPROVED", either a CAST or REVIEW action was performed. 
 The next logical step is to EXECUTE the package.
 Relying on a "Sweep" job, or manual submission leads to delays or possible neglect. 
 
 A "Sweep" job may submit multiple package executions concurrently, causing them to compete with each other for resources. 
 Package Automation submits executions at the time of the Cast or Approval, spreading out the resource consumption over a larger period of time.  
 
 Members that contribute to the Automated Package Executions feature include:
   - C1UEXT07.cob
   - PKGEEXEC.tbl
   - PKGEXECT.rex
   - PKG#MODL.skl

If you want to automate Executions only and to turn off the Automated Shipment feature, then comment or delete these SETUP options within C1UEXT07:
  - PECB-AFTER-EXEC 
  - PECB-REQ-ELEMENT-ACTION-BIBO
  - PECB-AFTER-BACKOUT 
  - PECB-AFTER-BACKIN 


## Automate Package Shipments

When a package completes Executiing, the next logical step for the package might be the submission of package shipments. 
This second feature of Package Automation automatically submits zero to many package shipments, based on the package content. 
No human intervention, including the manual navigation through the package shipment panels, is required.

The Shipping feature of Package Automation is activated immediately after a package Execution. 
The content of the package is compared to a table of "Rules". 
Each match with the table identifies a destination for a package shipment, which can be submitted immediately, or be delayed (scheduled) for a later time as designated by the "Rules".  


### Items for Automated Shipping

Most items for this feature require no changes during installation.
Moreover, not every item in this collection is necessary at your site. 
Many items are provided for your convenience, and can be installed depending on what works best for you. 


For example, the C1UEXT07 program performs both Automated functions - Executions and Shipments. 
 In case you want to automate shipping only, there are two additional exit programs within the collection named C1UEXSHP. 
 However, you need only one of them. 
 One is written in assembler and the other in COBOL. 
 Choose the one that works best for you. 
 If for example, your Endevor run time libraries are not PDS-E or you have not yet migrated to latest version of COBOL, you may elect to use the assembler version.
 

### Installation steps for Automated Shipping

On each Lpar where this collection will run:

1. Perform the steps listed in the **Package Automation on Multiple Endevor images** section.  
2. Tailor a Rules file to reflect your choices for package content and shipment destinations. Record the Rules file dataset name in the renamed @site member. By default package shipments are submitted immediately after a package execution. You may choose to force delays in package shipments by coding values in the Date and Time fields. If you do, then a SWEEP job will be responsible for submitting delayed package shipments. Schedule the SWEEP job to run on a frequency that is appropriate for you. If you already have a SWEEP job for executing packages, you may need only the last step from the example SWEEPJOB member to initiate package shipments.
3. Create the Trigger file as a sequential file, and record the file name as the **TriggerFileName** in the renamed @site member. Only the heading on the Trigger file is necessary, but keep the mixed-case format, and make the record length be at least 80 characters.
4. Create one or more package shipping "MODEL" members. Submit a 1-time manual package shipment for each file transmission method you use. Then, capture the manually submitted JCL (first job only) and tailor it using one of the models (SHIPLOCL, SHIP#FTP, SHIPMODL) in this collection as a guide. The three examples show how specific values are to be replaced with mixed-case variable names. Specify the names you give to your "MODEL" members as values for the **TransmissionModels** in your (renamed) @site member. Place each "MODEL" member into the library named as your **MySEN2Library**.
5. The use of the **#PSNFTPE** member is completely optional. File transmission tools will tell you the job number for remotely-submitted jobs. This member is coded to find the job number for an FTP submission, and to place it onto the TriggerFile. If you elect to not use the member, then your TriggerFile will not contain job numbers for remote jobs. 
6. Older versions of this collection depended on assembler API programs. If you find you need or prefer an API program, find the source in the **API-Assembler-Examples** folder.

### Notes on commenting Package Automation members

It is highly recommended that each .skl and "MODEL" member you use be commented. 
The edit macro named JCLCOMMT.rex can apply recommended comments onto anything that looks like JCL.
You can find the code for JCLCOMMT.rex in the [ISPF-tools-for-Quick-Edit-and-Endevor](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor) folder.

The commnenting will allow you to reveiew your package shipping (and other) jobs, and know the element or member name that contains the lines of JCL.

## Items outside of this folder, that might be a part of your solution: 


[**BPXWDYN**](https://www.ibm.com/docs/en/zos/3.2.0?topic=guide-dynamic-allocation) - a Dynamic Allocation routine from IBM

[**GTUNIQUE**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GTUNIQUE.rex) - returns a unique 8-byte name, base on date and time, that can be used as a dataset node.
 
[**GETACCTC**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GETACCTC.rex) - returns the "accounting code" for the current user id.

[**JCLCOMMT.rex**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/JCLCOMMT.rex)  - an edit macro that comments JCL, Skeletons and processors.

**ENTBJAPI** - see member BC1JAAPI in your CSIQJCL library.

[**BKOUTLOG**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/Package-Backout-Logging/endevor/Field-Developed-Programs/Package-Automation/Package-Backout-Logging/BKOUTLOG.rex) - for logging package Backout and BackIn actions. (currently in a branch)