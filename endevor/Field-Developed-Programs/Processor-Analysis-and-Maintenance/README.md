# Processor Analysis and Maintenance Tools

The tools in this folder offer two primary benefits to administrators:
- **Processor Symbol Substitution Analysis** Gaining a better understanding of processor symbol substitutions used within your processors.
- **Processor Step Comparison** They enable the comparison of common steps across different processors. This capability is useful for tasks like merging processors and ultimately reducing the total number of processors that need management.

## Processor Symbol Substitution Analysis
**NDVRREP@.jcl NDVRREPJ.jcl NDVRREPT.rex REPTPREP.rex ESYMBOLR.rex**

These items simulate Endevor's variable substitution process, demonstrating the gradual replacement to clearly show the progression from the initial to the final value. It is not necessary to replicate actual Endevor inventory scenarios to generate this reporting; you can "seed" the substitutions as desired. The sole output is a report detailing the resolved symbol substitutions.

Here is an example report for the gradual subtituion for the variable #CPYLIB1, and showing substitutions of a dependent variable named #CGRVL1Q.

    B4:  #CPYLIB1 = &#CGRVL1Q...CPYLIB                                      
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  - 52 Line(s) not Displayed 
    B4:  #CGRVL1Q = &#CGP&#MAP&C1SI.(1,1)                                   
    AF:  #CGRVL1Q = &#CGP&#MAPP(1,1)                                        
    AF:  #CGRVL1Q = &#CGP6                                                  
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  1537 Line(s) not Displayed 
    B4:  #CGRVL1Q = &#CGP6                                                  
    AF:  #CGRVL1Q = SCM.P.SHXXX                                             
    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -   980 Line(s) not Displayed 
    B4:  #CPYLIB1 = &#CGRVL1Q...CPYLIB                                      
    AF:  #CPYLIB1 = SCM.P.SHXXX.CPYLIB                                      

Endevor's substitution reporting shows only the initial and final values for variables defined in a processor or the Site table. This report, however, provides a complete view, detailing every intermediate value during substitution starting with any specified set of original "C1" variable values.

 [Symbol parameters](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/writing-processors/symbol-parameters.html) found within Endevor processors  **"provide a powerful means of writing processors"**

- User symbols
- [Site symbols](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/site-symbolics.html)
- Endevor symbols

Depending on what is configured at your site, these inputs can be necessary:

 - Capture and Convert Site Symbol Table content
 - Copy variable sections from your processor(s)
 - Collect processor group overrides 



### Capture and Convert Site Symbol Table content

Use one of the methods below to convert the content of your Site Symbol table into a REXX format. 

1) You can capture the Site Symbol table content using the [Option Report](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/reporting/reports/site-options-report.html), and make manual edits to it to convert it to a REXX format.


2) Or, while displaying the Site Symbol under ISPF, execute the ESYMBOLR program,  For example: 

        TSO EXEC 'MYTEMP.PDS(ESYMBOLR)'

    The Site Symbol content will be displayed back to you, converted into a REXX format. Then, CUT and PASTE the viewed results.
    
Copy the results into a dataset, or dataset(member), which is also listed in the JCL for reporting. 

### Collect variable sections from your processor(s)

You can use the edit macro named REPTPREP to collect the variables from the top of the processor into a MODEL dataset. If your processor has multiple statements on a line, it will reforat the line so that each line of the MODEL output contains only one statement.

Otherwise, you can manually find the variables you want expanded and reported from your processors. See the examples provided in this folder.

###  Collect processor group overrides 

Run the CSV step that collects processor group overrides. Insert after, or merge it with, the copied variable sections from your processors. 

### Tailor and submit the NDVRREPJ JCL

Include the dataset, or dataset(member), you created above, follow instructions within the JCL member and submit. Two reported outputs will be written.

Note: for this version of the tools, it is recommended to ensure each variable name is listed only once in the INPUT section of the JCL.


## Comparing processor steps across multiple processors

**CONSOLID.rex CONSOLSK.skel SUPCSOUT.rex**

Perhaps you want to consoliate processors. You have responsibilites for too many processors. Many of the processors have similar steps, and you would like to compare processor steps to consolidate processors, or to at least reduce the number of lines of code supported. By comparing like-named steps within processors, you can opt to:
- Use processor [includes](https://higherlogicdownload.s3.amazonaws.com/BROADCOM/4e97b9d9-9a2e-6349-96e3-27c89ce5b00d_file.mp4?X-Amz-Expires=3600&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEGgaCXVzLWVhc3QtMSJGMEQCIFtE6icu0KUH5fv%2Bn67eMsVT53DXggBJq95XSuw8C87MAiB7ThsI%2FMWJcEb9yE67kDu854znccj8mW%2B%2B1gio5RyVryqwBQgwEAAaDDM4MDMzNzM0MDcwNiIMQKm3pyGo8AOm%2FLl9Ko0FVRjpcYV32%2BU%2FQSbLvajsH9mGb3VpOL6fXEtVXvk0kocV%2BcM%2FSV9QfPEmh%2FsLNK7tCzqsDvnaEPI7Fum%2B3bA6VNzK%2BztFvD9%2BT%2FK2N6iLy4ez8YACPKC5Okq79WEpEnJy%2Flt97yNxsgV1kXRKo4fObPeLD6Tekq1JKG%2FkMxGQ6cSPOPAqD%2BXpDtcjfvH1xk7YBxG8rjuE%2FA%2B9lMh2nn%2BXVTvIqTivuHKGkw%2BUdoxJOcK2%2BTEUgmoW%2BuWyTsNjNM1IMBERqCT%2B82ProtS58tzejhNUMkEgt8rmGB4jQMNWwYs9pmTMOSmxWuOBkKC8qh8Ev7X6Tg87iZGFi4d4KMwH70pEdEYwdASdwjgdMJNk1r9hIAubr0oix2%2FtdBIp7PQMhkbNqh4QQ2VUtm0WW7VNo%2BMQfXc6EIb1DkRPgH3MxSZpxH9yiLV%2Fj028ni2d0rN%2Bga6WORpPFnEsDtgLmITrQnytaEB3kU7hvwWC1oO8ZtlnYKsAaF4LeSWWRxjr6BTvBBKLR88OTcQAYzH1AlDr9R0KaBd1yHrR1OE6bzBCQZjw5z8Qriu3eMAFW1Jc4LO0K8Sfj8%2FSocMDQBAo3ltPFuuyXUuzqR04taJWho29ECT2ER6t7FMfRd2PtdGT7N6RmmE%2FTCcI4IS0xRoUQfGN5e0jZHj9pQ3dPg3DhP1j3runmC%2FIeNPeltbT7k9pcjlHh64ECCt8b5FPadPiQ1E1DbHUe5eRKMf15cmqzfo64EBQ23KdRxX5rS34x7MlU7j%2FoSqDOtxxn6Cz%2BkDzGyRG1lpLJmnF%2FfU7o%2FRrLV4TF6b0Yk6SrqrofKZghHsudl9O2Ku%2BPJ58zm8CuOyAvJGVr5nzsOXVjisKGCuBvu4wuImszgY6sgHLqrfexWeX%2F7PfqMf6Za%2Bl9F4SFFwZIqUmRxuT93x2Vmp6bon3qItDeeiEERoMgYAzKlbyC%2BVdyEAwSSfbbi7BVOtScA0K9vZfvjMZkxi1wOj5OmnvL5Kmgoige6NKnr668izoweyDtcnWCrxbMCsabqwMo8FCR2mjyULOsyk1dKAqND5SZ7WOkPv1FqTgsIKnwILxHPofRw3DH0EUg7W6P5W8ZQQzvy16LamSE6j02T4v&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAVRDO7IERIZ67NKQQ%2F20260330%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260330T232723Z&X-Amz-SignedHeaders=host&X-Amz-Signature=b1068cb5de89a30e7020d0bda849534bd698799e332f84d878bb14f78659f7d9
) for steps that are the same in multiple processors
- Use Site Symbols for dataset names that are referenced in similar processor steps
- Reduce the number of processors, and/or processor lines of code.

Tailor the jobcard in the CONSOLSK.skel member.

To compare processor steps, first copy or retrieve them into a dataset. Next, modify the CONSOLID.rex file: set the **Dataset** variable to the name of this dataset, set the **selectStep** variable to the name of the step you wish to compare, and set the **selectProcessor** variable to the name of the single processor you choose for comparison against all others.

Once these variables are set, execute the REXX program under TSO. This action will submit a separate SUPERC job for every member within the specified **Dataset**. The results of each SUPERC comparison will be saved to the location specified by the OUTDD in its respective job.