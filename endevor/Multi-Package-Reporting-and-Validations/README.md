# Package Reporting
These procedures provide solutions for the reporting of Endevor package information. The first example offers a package report that can be used to determine input component omissions, and package relationships for multiple Endevor packages that need to be considered together.

## Multi-Package Reporting and Component Validation
With this procedure a user can submit a job for a list of Endevor packages which are to be evaluated together. The job performs an examination of the combined package SCL and conducts an analysis similar to the Component Validation feature of Endevor. Input components for the combined package content are identified and if any are missing, they are reported. Unlike the component validation Endevor performs on a single package, this procedure looks for input components across the multiple packages listed, and shows the dependencies between packages.

If no input components are missing then a simple message is printed, and a return code of 0 is given. If at least one input component is found missing then the job ends with a return code of 12. Each input component that is found missing is printed along with the packaged element that depends on the missing input component.


Here is an example report showing a missing input component:
```
For package ID 2#WJQJ4003906276:                                        
CLUELESS_COPYBOOK_DEV_FINANCE_ACTP0001_D is non-packaged input used by: 
   PG000044     COBOL      DEV        FINANCE    ACTP0001    D          
package ID 2#WKHK1207983231:                                            
 depends on 2#WJQJ4003906276                                            
                                                                        
 2#WJQJ4003906276                                                       
 2#WJSK1700940165                                                       
 D#WKRP5940791179                                                       
    2#WKHK1207983231                                                    
                                                                        
   *** Return Code= 12                                                  
```

This next example shows that all input components are packaged. It also lists multiple package relationships and a valid chronological order of package executions.

```
package ID 2#Componentpkg#2:                        
 depends on 1#COMPONENT4MANY     
package ID 2aPackage:                        
 depends on 1#COMPONENT4MANY        
package ID 3#Package:                        
 depends on 2aPackage               
package ID 4#Package:                        
 depends on 3#Package     
package ID 4#Package:                        
 depends on 1#COMPONENT4MANY
package ID 5#DEPENDSON#4:                        
 depends on 4#Package
            
1#COMPONENT4MANY           
    2#Componentpkg#2        
    2aPackage               
       3#Package            
          4#Package         
             5#DEPENDSON#4  


 *** All input components are found packaged ***    
                                                     
   *** Return Code= 0    
```

### Setup Steps for Multi-Package Reporting and Component Validation

1. Tailor the JCL jobcard
2. Optionally set the Order statement in the JCL to your JCL “INCLUDE” libraries. Alternatively just insert or modify the STEPLIB and SYSEXEC library designations in the JCL. The SYSEXEC library is the one you choose for the two REXX items.
3. Enter a list of Endevor packages:
   - Find the “//TABLE” reference in the first step, and list packages that will move from a given Environment and Stage number. Designate the Environment and Stage number as values for the SET statements ENVIRON and STAGE# respectively. Comments are optional for each package, and do not impact the processing in any way.
   - If the selected ENVIRON and STAGE# represent a merge point on your Endevor life cycle then within the value for PATHINIT specify each Environment and stage numbers that merge. Use a period between each Environment and stage number, and a space between each pair. For example, if DEV1.1 and DEV2.1 merge on the life cycle, then enter:

   `//   SET PATHINIT=’DEV1.1 DEV2.1’`
4. Set the value of EXPORTDS to an existing dataset. The job will create members in this dataset for each package EXPORT.

### How It Works
- An EXPORT is executed for each package listed at the top of the job. The status value for the package can be anything, including IN-EDIT.
- The SCL produced from the EXPORTed packages is reformatted. An ACM “Components Used” Query is constructed and executed for each packaged element.
- The reformatted SCL and the output from the ACM queries are examined together. The findings are reported within the job’s RESULTS output.