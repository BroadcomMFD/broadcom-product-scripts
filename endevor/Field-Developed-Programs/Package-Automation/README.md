# Package-Automation

Two primary opportunities exist within this collection to introduce automation for package actions:
Package Executions: Automated immediately when the package status updates to "APPROVED" and the execution window is open.
Package Shipments: Automated as soon as the status changes to "EXECUTED" and defined shipment rules indicate the package should be dispatched to one or more destinations.

When both processes are automated, granting final approval to a package seamlessly triggers execution, which is then immediately followed by shipments to all designated destinations.

The automated follow-up actions driven by the Endevor exit remain completely consistent, regardless of whether the triggering CAST or APPROVE action is initiated manually, via a zowe command, a sweep job, the Endevor web interface, or through any other method.

## Package Automation on Multiple Endevor images

Some Endevor administrators manage multiple Endevor images, each featuring unique lifecycle maps, job card details, and dataset naming conventions. To accommodate these variations while leaving most other configuration elements intact, follow the instructions below regarding the provided members:

Perform these setup steps on every LPAR where components of this collection will execute:
 - Deploy the REXX components into a designated new or existing library.
 - Enter within your chosen Exit program the name of this REXX library:
Use C1UEXT07-Package-Automation for handling both automated executions and shipments.
Use C1UEXSHP if you only require automated shipments.
 - Utilize the WHEREIAM.rex utility to establish your site-specific configurations:
Although it is not part of the active operational configuration, this member helps identify the specific naming structure needed for your @site member names.
Run WHEREIAM.rex without modifications to identify the appropriate name for the current @site member, then adjust the contents to align with that LPAR's parameters.

For instance, if running the collection on LPARs named SYS1 and SYS7, the utility will direct you to create members named @SYS1 and @SYS7, where you will specify your Rules, Trigger files, and other localized values.

  
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

## Designating Package Shipments via Package Notes

With this option, you can place package shipment expectations into the package notes at the time the package is created. Package reviewers can review expected shipments and make adjustments as needed. After the package executes, only entries remaining in the Notes trigger package shipments. There can be up to 8 destinations entered - one for each Note line - for a package.

If you use the [Package Builder](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/Package.rex) in the [**ISPF-tools-for-Quick-Edit-and-Endevor**](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor) folder, you can further automate this feature. SHIPRULE entries that match the package content are copied into the package Notes automatically. Or, if you prefer, do your automation or formatting of text strings when the package is being created. 

Package notes must be formatted in this manner - as package shipping instructions.  


      .........1.........2.........3.........4.........5.........6
  1.  ____________________________________________________________
  2.  ____________________________________________________________
  3.  ____________________________________________________________
  4.  ____________________________________________________________
  5.  ____________________________________________________________
  6.  TO DESTIN1 : 20260526 0000 PRD#DD01                         
  7.  TO DESTIN2 : 20260526 0000 PRD#DD02                         
  8.  NO TESTBOX : 20260526 0000 TEST0022            ELM CNT: 1   

To omit the shipment to a Destination, then simply change the "TO" at the front of a Note line to "NO".

If you choose this option do not use the COBOL exit in the **Package Automation** folder. Instead, use these found in the [Exit-Examples](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/Exit-Examples) folder:

 - **C1UEXT07 WithRexDriver.cob** - the more generic package exit program
 - **C1UEXTR7 WithRexDriver.rex** - the REXX subroutine that handles many  conditions beyond Package Automation. You may need to remove or comment out references you do not need in C1UEXTR7, but preserve the calls to the 
 PKGEXECT and PKGESHIP Rexx items in this folder.


## A word about the dependency on Comma Separated Value data

The use of extracts and parsing of CSV data, increases the longevity of the solution. For product release upgrades, if field lengths are changed, or new fields are added, there is no impact since field lengths and positions are automatically determined by the CSV heading. 



## Items outside of this folder, that might be a part of your solution: 


[**BPXWDYN**](https://www.ibm.com/docs/en/zos/3.2.0?topic=guide-dynamic-allocation) - a Dynamic Allocation routine from IBM

[**GTUNIQUE**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GTUNIQUE.rex) - returns a unique 8-byte name, base on date and time, that can be used as a dataset node.
 
[**GETACCTC**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/GETACCTC.rex) - returns the "accounting code" for the current user id.

[**JCLCOMMT.rex**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/ISPF-tools-for-Quick-Edit-and-Endevor/JCLCOMMT.rex)  - an edit macro that comments JCL, Skeletons and processors.

**ENTBJAPI** - see member BC1JAAPI in your CSIQJCL library.

[**BKOUTLOG**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/Package-Backout-Logging/endevor/Field-Developed-Programs/Package-Automation/Package-Backout-Logging/BKOUTLOG.rex) - for logging package Backout and BackIn actions. (currently in a branch)

If you are submitting Package Automation jobs under the Endevor Alt id, then find these modules:


[**SWAP2ALT**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/SWAP2ALT.rex
) to execute in your REXX exits and to enforce actions to run under the Endevor Altid

[**SWAP2USR**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/SWAP2USR.rex) to return processing back to the users' id.

Also review the [**USE_Alitd setting on the C1UEXITS**](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/securing/data-set-security/alternate-id-and-user-exits.html) setting, and for your exit, set the **USE_ALTID** value is to **+**.

[**WTO#MSG**](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Miscellaneous-items/WTO%23MSG.asm) - This utility allows you to notify others of specific site events by sending text strings, such as error messages, to the system log. This ensures that critical incidents receive the necessary attention for follow-up. Once these messages are logged, automation tools like OPS/MVS can scan the system log and initiate the appropriate responsive actions automatically.