# Package-Shipment-Automations-Using-Endevor-Exits
This collection allows sites to automate Endevor package shipments, relying only on an exit program and its REXX and assembler subroutines.  As an Endevor administrator, you can define "Rules" that determine the kind of package content that should govern automated package shipments. This collection will examine the "Rules"be invoked by Endevor immediately after a package execution, and using whatever the rules dictate, zero to many package shipping jobs will be automatically submitted. It makes no difference how the package execution was initiated - whether by zowe, a sweep job, or any other method. 

This collection has been around for a number of years, and can run on virtually any release of Endevor. The only requirement is that you are able to manually submit package shipments in Endevor before fully engaging this collection. Not every item in this collection is necessary at your site. Rather, there are choices you may make that determine which items you need. For example:
 - There are two versions of the exit program within the collection. Both are named C1UEXT07, but you need only one of them. One is written in assembler and the other in COBOL. You may choose the one that works best for you. If for example, your Endevor run time libraries are not PDS-E and you have not yet migrated to latest version of COBOL, you may elect to use the assembler version.
 - These routines were originally constructed prior to the availability of the CSV. Several of the REXX routines contain both API sections and CSV sections. If you do not use any of the API sections, then the corresponding API programs, written in assembler, are not necessary for you.
  - The WHEREIAM.rex member is not a part of the configuration, but is intended to be used solely to identify names you should use as @site member names.
  - Three package shipping "models" are provided in this collection as examples for your models, which will be constructed from your job(s) which are submitted by manual package shipment actions.  

 Most items in this collection may run as is.  Items that must be changed are:
  * The C1UEXT07 program
  * The one or more @site members you need to use. There will be one member for each Lpar on which you will be running this collection.
  * The "Rules" file that governs what package get shipped, and where do they get shipped to.
  * Your one or more Shipment "MODELS", to be created from JCL produced (one time only) by manual shipments. This member is made to contain all variables related to one Lpar for automated package shipments. Other routines in the collection can remain unmodified, since most details are placed here. 
 
 ## Installation steps

 1 Place all the rexx items into a new or existing library of your choice. The library name you choose is the only changed needed for the C1UEXT07 program. The @site member must be renamed and changed to contain details for your site. If you have multiple sites, then you can copy @site for each one. of mainframe tools is dependent upon IBM's ISPF, and can only be used on the mainframe by users of Quick-Edit and Endevor. Although these tools are not available to others, such as users on VS Code or Zowe, in some cases they provide a similar experience to those from other tools.
 2 Determine which version of C1UEXT07 you want to run. In the source code of your choice, enter the name of the REXX library you selected in step 1.
 3 Tailor the Rules file to reflect your choices for package content and shipment destinations. Record the Rules file dataset name in the renamed @site member.
 4 Upload (or copy) the Trigger file onto each Lpar as a sequential file, and record the name in the renamed @site member.
 5 On each Lpar where this collection will run, execute the WHEREIAM.rex (as is) to determine the name for a copy of the @site member content. Then tailor the content to reflect values for the Lpar. For example, if you intend to execute the collection on Lpars named SYS1 and SYS7, then WHEREIAM.rex will instruct you to create members @SYS1 and @SYS7 respectively. The names you use for the Rules and Trigger files must entered. Additionally the names of the libraries and members you use as "MODELS" must be entered here.


The COBOL and Assembler modules you select to use, must be generated using your Endevor release CSIQOPTN and CSIQLOAD libraries as input, and typically output to your CSIQAUTU library.
