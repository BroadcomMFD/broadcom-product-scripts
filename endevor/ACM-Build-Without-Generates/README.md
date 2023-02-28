## ACM-Build-Without-Generates

For new Endevor implementations, the first choice for building Automated Configuration Manager (ACM) information is by performing Generate actions on the program inventory. However, some Endevor sites have never had all their program inventory Generated, and are running Endevor without the full benefit of the ACM. It may be considered too risky or unacceptable to make processor or processor group and approver relate changes in the production environment. Or, it may that there is too much program inventory to Generate over a weekend – even with the Concurrent Action Processing.  As an alternative, this collection provides a way for building ACM data which offers these benefits: 

- Low risk – no processor changes are required. No Generate actions are required. Building of ACM information can be limited to elements that have never been Generated. 
- Fast – Builds ACM relationship information by scanning inventory. Runs in a fraction of the time that it takes to Generate inventory.
- Enables the Endevor ACM Queries, and AutoGen functions.

## Steps for Execution 

1. Copy the items in the collection to a library on your system, and tailor them as instructed in the Tailoring steps for your site.
2. Submit the ACM#LOD1.jcl to build a list of "groups" for your inventory. Typically there is too much inventory to run in one job. Therefore one job will be submitted for each group.
3. Optionally if you are using the collection for the first time, consider using ACM#LOD2 for just one group.
4. Submit the ACM#LOD2.jcl job for all groups. ACM#LOD2.jcl submits additional jobs - one for each group. For example if ACM#LOD1 builds 200 groups for your inventory, then ACM#LOD2 will submit 200 jobs. So you may want to make multiple steps from this one step 4.

## Tailoring steps for your site

The name of the dataset where you place the members of this collection will become the value for MODELLIB.

1. **ACM#LOD1, ACM#LOD2 and ACM#LOD3**  

   - Modify job cards to be appropriate for your site. Retain variables you find in ACM#LOD3.
   - Enter values for SET statements at top of JCL:
     - HLQ – High-level-qualifiers for work datasets
     - ENVMNT – name the Endevor environment to be scanned
     - STAGE - name the Endevor stage to be scanned
     - MODELLIB – the name of the library where the ACM#* members are found.
     - Adjust the STEPLIB and CONLIB (and other) references on Endevor steps

2. **ACM#LOD1**

   - Within the BILDACM3 step, enter a table of TYPES that might be input components.
   - Within the BILDACM9 step, enter a table of TYPES that might use input components (It is OK if a type is entered into both lists)
   - Optionally adjust the size of each group. Change the value of “Break = 30” to "Break = nn” where nn is your choice.

3. **ACM#LOD3**

   - Enter the dataset names for ACMROOT and ACMXREF
   - Review the code that references GEN-DATE, and adjust if needed
   
4. **ACM#REX1** 
   - Review and tailor the SCANLINE section as needed

## Restrictions and other notes:

1. The ACM build process captures input relationships only, and does not capture output relationships.
2. If an input component has its own invocation of other input components, you may elect to include a type in both tables within ACM#LOD1. However relationship information will be matched for the input component element type and not the program element type. For example, if your copybooks contain COPY statements, you may want to include type COPY in both lists. Then a COPYbook with a COPY statement will have an ACM relationship with the COPY that it references.
3. If you need help or if something is not working for you, then please let us know.