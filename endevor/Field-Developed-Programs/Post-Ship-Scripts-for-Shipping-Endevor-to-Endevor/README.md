# Post-Ship-Scripts-for-Shipping-Endevor-to-Endevor

These procedures provide examples of package shipping scripts supporting the shipment of elements from one Endevor to another. Shipment can be to a remote or local Destination where another Endevor is running. The overall effect is the extension of an application's life cycle across multiple Endevor images.

For many sites, the first few members in this collection may be sufficient for your needs. If your site has a wide range of changing values for System, Subsystem  or Type as elements ship from one Endevor to another, then the additional examples in this collection may be helpful.

## Content Summary

This procedure leverages the **How to Enable Post-Ship Script Execution** feature of Endevor.

- CA66AB and CA32AB are example shipment 'models' for destinations named CA66A and CA32A respectively. Use names that match the Destinations at your site where you want an Endevor image to be targeted. The single-letter suffix, 'B', is used to place these models "Before" the copy step in the remote JCL. The "ALTER" steps in these examples are optional, and if eliminated then the processor changes reflected in the RMALTERS, GWRITE and DESTCNFG members can also be eliminated. If a Destination has just one value for each of the entry Environment, System and Subsystem, then these examples should be sufficient. Otherwise see the C1BMXIN and C1BMXJOB entries for more complicated mapping.
- DESTCNFG a sample Destination Cfg Mbr content, showing a method for mapping SYSTEM, SUBSYSTEM and TYPE values from the sending Endevor to those needed by Destination Endevors. DESTCNFG is applicable only for the ALTER steps. The name 'CATSNDVR' is the Endevor System name at the sending site. Processor examples cause the sending System name to become a symbol (variable) within a member like this one.
- GWRITE and RMALTERS contain processor code that builds ALTER output members that are shipped as Post-Ship Scripts. RMALTERS is provided as an example processor "include", which can be coded once and copied into each processor that needs the code, using the example found in GWRITE. The use of an "include" is purely optional. You may elect to copy the entire content of RMALTERS into each required processor. Within RMALTERS is the processor code that converts a System name into a package shipping symbol name.
Your target Destination mapping rules must contain a rule, such as: 

          HOST DATASET NAME:  SYSDE32.NDVR.ADMIN.ENDEVOR.*.ALTERS   
            maps to                                                  
          REMOTE DATASET NAME:(SCRIPT-FILE)                     

- C1BMXIN, C1BMXJOB and GETSYRSB are the most complicated of the items in this collection, and are included only as an example solution for the less-likely and worst-case scenarios. Calls to the REXX program GETSYRSB allow the package name prefix to determine the Destination system or subsystem name. To use these you would need to make modifications that fit your situation. 
- #RJICPY1 - provided only to demonstrate additional commenting that you may elect to use. This item contains the "@INCLUDE=(B)" statement that copies in a CA66AB or CA32AB member, or member named for a Destination at your site.
