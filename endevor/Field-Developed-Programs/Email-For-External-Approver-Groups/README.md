     
# Email for External Approver Groups

Send Email to Approvers defined in External Endevor Approver Groups. These are groups where individuals are not defined within the Endevor Approver Group, but rather are defined in the  external security product in use at your site.

See the discussion of External Groups in [Endevor's tech docs documentation](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/18-1/administrating/package-administration/approver-groups.html).


As with many of the folders on this GitHub, this one contains a response from requests of one or more customers.

Leveraging content from the [Exit-Examples](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/Exit-Examples) folder, and possibly the [SonarQube](https://github.com/BroadcomMFD/broadcom-product-scripts/tree/main/endevor/Field-Developed-Programs/SonarQube-interface-to-Endevor) folder, the items in this folder allow you to:

 
- Eliminate dependency on ESMTPTBL
- Update address lists in REXX 
- Allow more than 16 email addresses
- Associate an approver group with one or more Group-level and/or personal email addresses
- Easily tailor your own email content

**C1UEXTR7.rex** is an example Rexx subroutine to the package exit programs, for example [C1UEXT07](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Package-Automation/C1UEXT07.cob) in the **Package Automation** folder, or [C1UEXTT7](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/SonarQube-interface-to-Endevor/C1UEXTT7.cob) in the **SonarQube-interface-to-Endevor** folder. This version processes Approver Group names, provided by the exit, and calls **SENDMAIL.rex** to deliver email. 
A subroutine to **SENDMAIL.rex** is the **GTEMADDS.rex** which provides a list of email addresses for each Approver Group. 

Code your own version of **GTEMADDS.rex** to associate your Approver Groups to email addresses, following the example content.


