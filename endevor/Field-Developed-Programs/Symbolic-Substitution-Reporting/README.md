# Reporting resolutions of Endevor Symbols 

status - Alpha (early) - provided as an interim solution, until an alternative can be provided.

 [Symbol parameters](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/writing-processors/symbol-parameters.html) found within Endevor processors  **"provide a powerful means of writing processors"**

- User symbols
- [Site symbols](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/site-symbolics.html)
- Endevor symbols

Depending on what is configured at your site, these inputs can be necessary:

 - Capture and Convert Site Symbol Table content
 - Copy variable sections from your processor(s)
 - Collect processor group overrides 



## Capture and Convert Site Symbol Table content

Use one of the methods below to convert the content of your Site Symbol table into a REXX format. 

1) You can capture the Site Symbol table content using the [Option Report](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/reporting/reports/site-options-report.html), and make manual edits to it to convert it to a REXX format.


2) Or, while displaying the Site Symbol under ISPF, execute the ESYMBOLR program,  For example: 

        TSO EXEC 'MYTEMP.PDS(ESYMBOLR)'

    The Site Symbol content will be displayed back to you, converted into a REXX format. Then, CUT and PASTE the viewed results.
    
Copy the results into a dataset, or dataset(member), which is also listed in the JCL for reporting. 

## Copy variable sections from your processor(s)

Find the variables you want expanded and reported from your processors. See the examples provided in this folder.

##  Collect processor group overrides 

Run the CSV step that collects processor group overrides. Insert after, or merge it with, the copied variable sections from your processors. 

## Tailor and submit the NDVRREPJ JCL

Include the dataset, or dataset(member), you created above, follow instructions within the JCL member and submit. Two reported outputs will be written.

Note: for this version of the tools, it is recommended to ensure each variable name is listed only once in the INPUT section of the JCL.


