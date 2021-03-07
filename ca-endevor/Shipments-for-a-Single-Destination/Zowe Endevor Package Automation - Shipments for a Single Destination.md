# Zowe Endevor Package Automation - Shipments for a Single Destination
This procedure allows zowe commands to execute Endevor package shipments. 

For example: `zowe zos-tso issue command "PKGESHIP 'name-of-package'"`
    
This procedure is a simpler version for cases when there is only one possible shipment destination. Typically the one shipment destination could be a prodcution destination that resides on a different mainframe than the Endevor life cycle that spawns the shipment.

Look for another procedure that supports shipments to multiple destinations, where 0 to many destinations will be automatically submitted based on the package content.

This procedure utilizes mainframe REXX programs running under z/OSMF. Endevor web services is not required. As a result, these routines may operate on Endevor releases 16.0 and forward.

The following are pre-requisites and assumptions:
1) There is only one destination always selected for the package shipment. The Destination is named in the `@site` member.
2) It is assumed that Endevor's package shipment process is already configured. 
3) The examples in this process assume that IBM's FTP is used for package shipments. However, any transmission method can be used.
4) Some REXX modifcations may optionally be applied to the routines. For example, it may be preferred to limit the shipments to packages with a given prefix.


Setup steps for the REXX-based objects for zowe package shipment automation:
1)	Prepare the logon procedure for your zowe profile, if necessary. The default logon procedure name is IZUFPROC, which you can tailor or copy as another name. 
    
    a)	Your zowe logon procedure must include any STEPLIB and/or CONLIB content of your batch Endevor jobs. Both were inserted into our example IZUFNDVR.jcl. At some sites neither of these are necessary.
        
    b)	Identify or create a REXX library for the REXX items of this solution. If not already there, include the REXX library name within the SYSEXEC library allocation of the logon procedure. (The library is also to be named as `MyCLS2Library` in the `@site.rex` member). Within the examples, the `PSP.ENDV.TEAM.REXX` library was named as the library for the REXX-based tools.

2)	Install the remaining items for doing automated Package shipments. All REXX members must be placed into the REXX library named on 1b.  
    
    a)	`WHEREAMI.rex` – no changes are necessary. If you do not know the name of the Lpar, then execute this REXX once to determine the name. You can execute WHEREAMI by placing an "EX" to the left of its name when displayed as a member of the library for the REXX-based tools.
        
    b)	`@site.rex` – rename `@site` to match the name displayed in step 2a. For example, if you are running on an lpar named LP1, then step 2a will display `@LP1`, and the member `@site` should be renamed to `@LP1`. Then edit the renamed member to reflect values for the named Lpar. 
        
    c)	`WHERE@M1.rex` – no changes are necessary. 
    
    d)	`PKGESHIP.rex` – no changes are necessary. Although you may elect to turn off the Trace.
    
    e)	`SHIP#FTP.skl` – needs to be a tailored version of your package shipping JCL.
    -  In Endevor, manually Submit a package shipment, and capture the JCL that was submitted. 
    -   Replace specific values for Package, Destination, Date and time as shown in the `SHIP#FTP` example.
    -   Save the tailored JCL as a member of a dataset, using whatever dataset and member names you like. 
    -   Enter the dataset name of the tailored JCL into the `Lpar-named-REXX` as the `MySEN2Library`. 
    -   Enter the member name of the tailred JCL into the `Lpar-named-REXX` as the `ModelMember`.
        
    f)  Execute your zowe command, for example: `zowe zos-tso issue command "PKGESHIP 'name-of-package'"`
