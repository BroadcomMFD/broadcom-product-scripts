# How to Sort an Endevor CSV file for Table Tool processing #

Items in this folder describe the sorting of CSV files, created by Endevor's CSV utility, then subsequently using Table Tool processing on the sorted data.

This solution described here is offered at this time with these restrictions:

- The Sorting process must run in two job steps - the second step being the DFSORT utility.
- DFSORT requires that sort fields to be in fixed locations of each record. As a result, the record size of the CSV output must have ample unused space to allow for the inclusion of selected Sort fields. The first step identifies the unused location. If your CSV output file has insufficient space for the sort fields, then the first step gives a message saying **"TBL#SORT- A longer LRECL is required!!"**, and ends with a return code of 12. When that happens, increase the LRECL=2000 to a larger value. The DFSORT steps removes the expanded sort fields from its output.

## How to perpare and run the CSV file sort ##
 
  - Place the TBL#SORT member into a REXX library
  - The JCL contains two examples. Place the JCL into a JCL library, and tailor the JCL:
    - Adjust the jobcard for your site.
    - Adjust the ORDER statement for your site. It names a library from which you may have placed a STEPLIB member containing a STEPLIB, and perhaps a CONLIB, for accessesing Endevor at your site. You may code those statements directly into your JCL, and remove the INCLUDE MEMBER=STEPLIB statement(s).
    - SET the C1ENVMNT and C1SYSTEM values to valid Environment and system names. You may wild-card either of these.
    - SET the REXXLIB value to the library name where you placed the TBL#SORT member.
    - Set the CSIQCLS0 value to the name of your Endevor CSIQCLS0, or a library that contains ENBPIU00 (Table Tool).
    - Adjust the SPACE allocations, and include UNIT designations as necessary. 
    - The JCL contains two examples for creating CSV files, sorting them and processing them. Replace them with your CSV extracts as needed.
    - In the SORTPARM input of the TBL#SORT step(s), choose the variable names (free format) you wish to use for sorting. These are the same variable names that Table Tool uses for the CSV file. After each name, include a space and an "A" or "D" for "ascending" or "descending" sorting respectively.


Note that the TBL#SORT step captures the CSV file heading, and writes it to SORTOUT. When the DFSORT step runs, it is necessary that the DISP=MOD be used with SORTOUT to append the sorted data to the heading.

The solution is valid for DFSORT. Let me know if you would like to help in the development of a solution for another Sort utility.

Please contact joseph.walter@broadcom.com if you have any questions or issues.



