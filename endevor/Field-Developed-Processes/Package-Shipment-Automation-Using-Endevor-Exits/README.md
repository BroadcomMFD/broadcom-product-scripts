# Package-Shipment-Automations-Using-Endevor-Exits

This collection allows sites to automate Endevor package shipments - no longer requiring the use of panel actions.

Immediately after a package Execution, the content of the package is automatically compared with a table of "Rules". The comparison may determine zero to many destinations and shipments to be submitted immediately or scheduled for a later time. Whether a package is Executed manually, or by zowe, a sweep job, or any other means, the automated package shipment process is the same.

This collection has been around since the year 2006, and can run on any release of Endevor. The only requirement is that manual package shipments be already configured.  

Most items in this collection require no changes during installation. Not every item in this collection is necessary at your site. Some items are available as choices for what works best for you. For example:

 - There are two versions of the exit program within the collection. Both are named C1UEXSHP, but you need only one of them. One is written in assembler and the other in COBOL. Choose the one that works best for you. If for example, your Endevor run time libraries are not PDS-E or you have not yet migrated to latest version of COBOL, you may elect to use the assembler version.
 - These routines were originally constructed prior to the availability of Endevor's CSV utility. Several of the REXX routines contain both API sections and CSV sections. If you do not use any of the API sections, then the corresponding assembler API programs are not necessary for you.
  - The WHEREIAM.rex member is not a part of the configuration, but is intended to solely to identify names you should use as @site member names.
  - Three package shipping "MODELS" are provided in this collection as examples for your models. After submitting and capturing each unique kind of your own package shipment job(s), you can tailor them using the models as a guide.

 Most items in this collection may run as is.  Items that must be changed are:

  * The C1UEXSHP program requires a 1-line change to name a REXX library 
  * The one or more @site members you need to use. One member is needed for each Lpar where shipping is initiated. The member contains variables related to one Lpar and is renamed to match the Lpar name (preceded by an asterisk).
  * The "Rules" file that governs what packages get shipped, and where do they get shipped to.
  * One or more Shipment "MODELS", to be created from JCL produced by manual shipments. 
 
 ## Installation steps

On each Lpar where this collection will run:

1. Place all the rexx items into a new or existing library of your choice. 
2. Determine which version of C1UEXSHP you want to run. In the source code of your choice, enter the name of the REXX library you selected in step 1. You may also choose to install the program with the default package exit name, C1UEXT07.
3. Execute the WHEREIAM.rex (as is) to determine the name to be given to a copy @site. Then tailor the content to reflect values for the Lpar. For example, if you intend to execute the collection on Lpars named SYS1 and SYS7, then WHEREIAM.rex will instruct you to create members @SYS1 and @SYS7 respectively. The names you use for the Rules and Trigger files must entered. Additionally the names of the libraries and members you use as "MODELS" must be entered.
4. Tailor a Rules file to reflect your choices for package content and shipment destinations. Record the Rules file dataset name in the renamed @site member.
5. Upload (or copy) the Trigger file as a sequential file, and record the name in the renamed @site member. Only the heading on each Trigger file is necessary.
6. From the JCL submitted for your manual shipments, create a "MODEL" for each unique kind or shipment. For example you may have local shipments and remote XCOM shipments.

Find Assembler API program source in the **API-Assembler-Examples** folder.

The COBOL and Assembler modules you select to use, must be generated using your Endevor release CSIQOPTN and CSIQLOAD libraries as input, and typically output to your CSIQAUTU library. 
