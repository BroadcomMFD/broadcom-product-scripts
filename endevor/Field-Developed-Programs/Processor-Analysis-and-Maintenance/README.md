# Processor Analysis and Maintenance Tools

These administrative tools provide two key capabilities:
- **Processor Symbol Substitution Analysis:** This helps administrators gain a deeper insight into the processor symbol substitutions utilized within their processors.
- **Processor Step Comparison:**
 This feature allows for the comparison of common steps between various processors. This is highly beneficial for activities such as merging processors, which ultimately contributes to reducing the overall number of processors requiring management.


## Processor Symbol Substitution Analysis
**NDVRREPT.rex REPTPREP.rex ESYMBOLR.rex NDVRREPJ.jcl**

Endevor processors utilize [three types of symbols](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/site-symbolics.html):  User, Site, and Endevor symbols. Endevor symbols, designated as “C1*” variables, are assigned values by Endevor during execution. The values of User and Site symbols can be dependent on these Endevor symbols.

Due to the potential for a symbol's value to be another variable name or a combination of text strings and variable names, deciphering these symbol substitutions can be complex.

The reporting items in this folder are designed to mimic Endevor's functionality, providing a clear, step-by-step demonstration of variable resolution. This process shows the gradual replacement of an initial variable with intermediate results until the final value is determined. During this substitution, dependency variables are reported. It is unnecessary to replicate actual Endevor inventory scenarios. Instead, simply "seed" your chosen values for Endevor's C1 variables and submit the reporting JCL. The resulting output is a report that focuses exclusively on the resolved symbol substitutions.


For instance, selected lines from this report illustrate the gradual substitution for the variable #CPYLIB1 and includes the substitutions of a dependent variable, #CGRVL1Q. Before and After images are shown for each substitution.


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


The necessary inputs for your site, depending on its configuration, may include:
- Capturing and converting the Site Symbol Table content.
- Copying variable sections from your processor(s).
- Seeding your C1 Variables.

While Processor Group overrides are not currently supported, you can manually account for them by entering the values as either Site Symbol content or assigned processor values.


### Capture and Convert Site Symbol Table content

Use one of the methods below to convert the content of your Site Symbol table into a REXX format. 

1) You can capture the Site Symbol table content using the [Option Report](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/reporting/reports/site-options-report.html), and make manual edits to it to convert it to a REXX format.


2) Or, while displaying the Site Symbol under ISPF, execute the ESYMBOLR program,  For example: 

        TSO EXEC 'MYTEMP.PDS(ESYMBOLR)'

    The Site Symbol content will be displayed back to you, converted into a REXX format. Then, CUT and PASTE the viewed results.
    
Copy the results into a dataset, or dataset(member), which is also listed in the JCL for reporting. 

### Collect variable sections from your processor(s)

To prepare for reporting, first copy the User-defined symbol parameters from the PROC statements located at the beginning of the processor. These statements can then be used as input for the report.

**Preparation Guidelines:**
- If a single line in your processor contains multiple variable assignments, split them so that each line contains only one assignment.
- Alternatively, use the REPTPREP edit macro to automatically reformat the variables from the top of the processor and to place them into a dataset for reporting.

You may also include additional variables in the report input. For instance, to see how substitutions work for variables not currently defined in the processor, you can run a report on them before integrating them into the processor.

Refer to the examples provided in this folder for guidance.


###  Seed your C1 variables 

When assigning initial values for C1 variables, follow the structure shown in the NDVRREP@.jcl example. Minimally include variables used for subsequent substitution. For instance, you can omit the C1ELEMENT variable if it's not needed for any further variable resolution. However, if you are analyzing the behavior of a MOVE processor, you may need to "seed" both the sending and target C1 variables.

### Tailor and submit the NDVRREPJ JCL

Adjust the jobcard and dataset names in the NDVRREPJ jcl.  

The rexx iterates up to 25 times through your inputs to resolve variables. If you need more iterations, simply change this line in the REXX to reflect the number of iterations you want to use:

       Do pass# = 1 to 25

The job has been shown to complete thousands of substitutions and multiple iterations in just a few seconds. The job quits when it can no longer find any variables to resolve. If the job encounters a variable for which there is no value given, it will substitute what it can and end with a return code of 8. Look in the SYSTSPRT output to see various levels of substitutions.       

## Comparing processor steps for processor consolidation

**CONSOLID.rex CONSOLSK.skel SUPCSOUT.rex**

The real win in consolidation comes from the fact that many of these similar processors share standard steps. If you take a close look at the steps across different processors, especially those with the same or very similar step names, you can gain some valuable benefits:
- **Combine Processors:** By finding and merging any duplicated or nearly-identical logic into one standard processor or [processor Include](https://community.broadcom.com/HigherLogic/System/DownloadDocumentFile.ashx?DocumentFileKey=4e97b9d9-9a2e-6349-96e3-27c89ce5b00d) member, you can make the whole system much simpler. This merging cleans up the processing flow, making it easier to understand, manage, and fix bugs. It encourages a building-block design where common stuff is all in one place.
- **Cut Down on the Lines of Code (LoC) You Have to Support:** A straight-up result of combining things is getting rid of copied code. When similar steps are rolled into reusable parts, the total amount of code you have to keep running, test, and update is reduced. That means fewer places for bugs, better code quality, and a lower cost and headache for maintenance over time. Plus, any future fixes or updates to the shared logic only need to be done once, and every dependent processor instantly benefits.

When resolving minor discrepancies identified during processor step comparisons, consider implementing the following strategies:
- **Externalize Details:** Utilize processor utilities, such as [CONPARMX](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/19-0/administrating/processors/processor-utilities/conparmx-utility.html), to keep specific details external to the processors, preventing them from being hard-coded.
- **Employ Conditional Logic:** Incorporate IF/THEN/ELSE logic to accommodate necessary processing differences.
- **Standardize References:** Use Site Symbols for dataset names that are referenced across similar processor steps.

To compare processor steps, first copy or retrieve them into a dataset. If the steps you want to compare are similar but do not all have the same step name, make them have the same step name in the dataset. Next, modify the CONSOLID.rex file: set the **Dataset** variable to the name of this dataset, set the **selectStep** variable to the name of the step you wish to compare, and set the **selectProcessor** variable to the name of the single processor you choose for comparison against all others.

Once these variables are set, execute the REXX program under TSO. This action will submit a separate SUPERC job for every member within the specified **Dataset**. The results of each SUPERC comparison will be saved to the location specified by the **OUTDD** in its respective job.