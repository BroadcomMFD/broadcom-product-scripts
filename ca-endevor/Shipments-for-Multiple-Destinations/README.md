#Readme Shipments for multiple destinations.md
This procedure allows zowe commands to execute Endevor package shipments. For example,
    zowe zos-tso issue command "PKGESHIP 'name-of-package'"
The procedure is a more robust alternative to a simpler version, used when there is only one Endevor package shipment destination. 

Both procedures utilize mainframe REXX programs running under zos-mf.
Endevor web services is not required. As a result, these routines may operate on Endevor releases 16.0 and forward.

There are two significant differences in this robust solution compared to the simple version:
1) The site must maintain a table of expected package shipments. See the SHIPRULE.example. 
2) Automated updates to a "Trigger" file, support Package Shipment scheduling and logging. 

The mechanism used to drive automated package shipments is the Shipment Rules table. Create a Shipment Rules table for each Endevor site that will initiate automated package shipments. In the first four columns, enter the Endevor Environment, Stage, System and Subsys values where an automated shipment is to occur. Any of these values for these fields may be wild-carded by using an asterisk ('*') character. If you are using Endevor's Deploy to Test feature, you may enter a Deploy to Test Target location as a Subsys name. The automated package shipping process uses the first four columns of the Shipment Rules table as search fields. When a package execution is completed and targets a location specified by the search fields, the automated process submits a package shipment job. The search through the Shipment Rules table may find 0 to many matches from the package content. 

    The Destination must be a valid Endevor package destination name.

    The St value may be:
    •	R – Must be reviewed prior to shipment
    •	_ (underscore  or blank) – Ok to ship. Waiting for the arrival of Date and Time if non-zero

    The Jobname must conform to site standards, and names back-end package shipping jobnames.

    The Date value indicates a number of days to delay the submission of a package shipment after the package execution. The Time value indicates the earliest time of day for the submission of a package shipment.
    If Date and Time are "+0" and "0000" respectively, then the package shipment is submitted immediately.

    The Typrun value may be ‘HOLD’, or 'SCAN' or blank. Use a Typrun value of 'HOLD' if you want to use a manual process or other automated proess to release the jobs at the appropriate times.


The following are pre-requisites and assumptions:
    1) Endevor's package shipment process must be already configured. 
    2) IBM's FTP is found in the skl example, but any transmission method may be used.
    3) For some older versions of Endevor, the CSV utility calls must be replaced with calls to API programs. The API programs can be provided on request. 
    4) It recommended that all the components of this configuration be managed by Endevor as administrative elements, with the exception of the "Trigger" File.


Setup steps for the REXX-based objects for zowe package shipment automation:
1)	Prepare the logon procedure for your zowe profile, if necessary.
    The default logon procedure name is IZUFPROC, which you can tailor or copy as another name. 
    a)	Your zowe logon procedure must include any STEPLIB and/or CONLIB content of your batch Endevor jobs.
        Both were inserted into our example IZUFNDVR.jcl. At some sites neither of these are necessary. 
    b)	Identify or create a REXX library for the REXX items of this solution. 
        If not already there, include the REXX library name within the SYSEXEC library allocation of the logon procedure. (The library is also to be named as MyCLS2Library in the @siteMult.rex member)
        Within the examples, the PSP.ENDV.TEAM.REXX library was named as the library for the REXX-based tools.

2)	Install the remaining items for doing automated Package shipments. 
    All REXX members must be placed into the REXX library named on 1b.  
    a)	WHEREAMI.rex – no changes are necessary. If you do not know the name of the Lpar, then  
        execute this REXX once to determine the name. 
        You can execute WHEREAMI by placing an "EX" to the left of its name when displayed as a member of the library for the REXX-based tools.
    b)	@siteMult.rex – rename @siteMult to match the name displayed in step 2a. 
        For example, if you are running on an lpar named LP1, then step 2a will display "@LP1", and the member @site should be renamed to @LP1 .
        Then edit the renamed member to reflect values for the named Lpar. 
    c)  SHIPRULE - Create a member named SHIPRULE from the SHIPRULE example. Tailor it to reflect your choices for
        package shipments. Place the member into the library named in @siteMult as the MyDATALibrary.  
    d)	WHERE@M1.rex – no changes are necessary. 
    e)	PKGESHIP.rex – no changes are necessary. Although you may elect to turn off the Trace.
    f)	SHIP#FTP.skl – needs to be a tailored version of your package shipping JCL.
        -   In Endevor, manually Submit a package shipment, and capture the JCL that was submitted. 
        -   Replace specific values for Package, Destination, Date and time as shown in the SHIP#FTP example. 
        -   Save the tailored JCL as a member of a dataset, using whatever dataset and member names you like.   
        -   Enter the dataset name of the tailored JCL into @siteMult.rex as the MySEN2Library. 
        -   Enter the member name of the tailored JCL into @siteMult.rex as the ModelMember.
    g)  BILDTGGR, PULLTGGR, TBLUNLOD and UPDTTGGR must be placed into the REXX library named on 1b.
    h)  Create a Trigger file as a sequential dataset (DSORG=PS) and record length 100 characters (LRECL=100).
        Enter the Trigger file name into @siteMult.rex as the TriggerFileName. 
    i)  Execute your zowe command, for example:
        zowe zos-tso issue command "PKGESHIP 'name-of-package'"

Note.
Shipments are submitted from entries placed automatically onto the "Trigger" file. You can manually update the "Trigger" file to request package shipments. If you create a SHIPRULE that designates a future shipment, then you can use the PULLTGGR program within a step of a typical sweep job to submit package shipments in a timely manner, similar to the way package execution jobs are submitted. 