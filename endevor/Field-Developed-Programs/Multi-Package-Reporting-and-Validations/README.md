# Multi-Package Reporting and Component Validation

With this procedure a job can be submitted for a list of Endevor packages which are to be evaluated together. The job performs an analysis similar to the Component Validation feature of Endevor, and looks for input components which might be missing, and also shows dependency relationships between the packages. Input components for the combined package content found missing are reported, and a high return code is given. If no input components are missing a simple message is printed and a return code of 0 is given.

Here is an example report showing package relationships and a missing input component:
```
For package ID D#WKYL5451187354:                                       
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PGMDAVE1     COBOL      DEV        FINANCE    ACTP0005    D         
package ID D#WKYL5451187354:                                           
 depends on D#WKYL5657683637                                           
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PGMJJ1       COBOL      DEV        FINANCE    ACTP0005    D         
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PGMNS        COBOL      DEV        FINANCE    ACTP0005    D         
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PG000003     COBOL      DEV        FINANCE    ACTP0005    D         
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PG000023     COBOL      DEV        FINANCE    ACTP0005    D         
FINAPC01_COPYBOOK_DEV_FINANCE_ACTP0004_D is non-packaged input used by:
   PMGBOBBY     COBOL      DEV        FINANCE    ACTP0005    D         

package ID D#WKYO0226831512:                     
 depends on D#WKYL5451187354                     
 depends on D#WKYL5657683637                     
package ID D#WKYO2326944798:                     
 depends on D#WKYO0226831512                     
 depends on D#WKYL5657683637                     
Packages with level 3 prerequisites              
       D#WKYO2326944798                          
Packages with level 2 prerequisites              
     D#WKYO0226831512                            
Packages with level 1 prerequisites              
   D#WKYL5451187354                              
   D#WKYM0405508812                              
Packages with no prerequisites                   
 D#WKYL5657683637                                
 D#WKYL5919699963                                
 D#WKYM0242257206                                
 D#WKYM2606593342                                
                                                 
   *** Return Code= 12                           
```

This next example shows that all input components are packaged and multiple package relationships. 

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
  
 *** All input components are found packaged ***    
                                                     
   *** Return Code= 0    
```
An optional report can show a potential chronological order for the packages


```
*** Potential Chronological order of packages: *** 
 D#WKYL5657683637                                  
 D#WKYL5919699963                                  
 D#WKYM2606593342                                  
   D#WKYL5451187354                                
   D#WKYM0242257206                                
   D#WKYM0405508812                                
     D#WKYO0226831512                              
       D#WKYO2326944798                            
```


## Setup Steps for Multi-Package Reporting and Component Validation

1. Tailor the JCL jobcard
2. Optionally set the Order statement in the JCL to your JCL “INCLUDE” libraries. Alternatively just insert or modify the STEPLIB and SYSEXEC library designations in the JCL. The SYSEXEC library is the one you choose for the two REXX items.
3. Enter a list of Endevor packages:
   - Find the “//TABLE” reference in the first step, and list packages that will move from a given Environment and Stage number. Designate the Environment and Stage number as values for the SET statements ENVIRON and STAGE# respectively. Comments are optional for each package, and do not impact the processing in any way.
   - If the selected ENVIRON and STAGE# represent a merge point on your Endevor life cycle then within the value for PATHINIT specify each Environment and stage numbers that merge. Use a period between each Environment and stage number, and a space between each pair. For example, if DEV1.1 and DEV2.1 merge on the life cycle, then enter:

   `//   SET PATHINIT=’DEV1.1 DEV2.1’`
4. Set the value of EXPORTDS to an existing dataset. The job will create members in this dataset for each package EXPORT.

## How It Works
- An EXPORT is executed for each package listed at the top of the job. The status value for the package can be anything, including IN-EDIT.
- The SCL produced from the EXPORTed packages is reformatted. An ACM “Components Used” Query is constructed and executed for each packaged element.
- The reformatted SCL and the output from the ACM queries are examined together. The findings are reported within the job’s RESULTS output.
