# Automated Test Facility for Batch Applications

These samples are provided as is and are not officially supported (see [license](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/LICENSE
) for more information).

This procedure allows Endevor processors to automate the tailoring, submission and evaluation of Batch application tests. Tests are triggered automatically by the Move or Generate actions of elements of any element type. For example, you may initiate automated tests when a COBOL program is Moved or Generated at a certain stage of Endevor. The test will locate, tailor, submit and evaluate results for one or more JCL elements whose names appear in the "OPTIONS" content of the COBOL program. 

## Features and  Choices
The collection of items in this folder provides for automating Tests of your Endevor inventory. 

- **Generate and/or Move actions** on an element of any type can be accompanied by the automated submission of a batch test of that element. You can choose to test programs, JCL, PROCS, PARMS or other elements that you want to be tested.

- **Simple instructions** you give to your Endevor processors can be written in either of two simple formats:
    1) OPTIONS format - like the syntax given to CONPARMX steps
    2) YAML - a popular, modern data serialization language that is widely used for writing configuration files. It is designed to be human-readable.

    You can establish unique tests on an element for selected Stages in Endevor, and have the submitted test automatically adjust lines of JCL for the Stage name where the element is found. STEPLIB concatenations,  for example, can be automatically adjusted in a TEST stage, and different than the adjustment in the QA stage. 

    You can use broad statements to tailor the JCL or use Step and DDName references to pinpoint where changes are to be made. 

- **Test evaluations** may be bypassed entirely, or masked and compared to a test baseline. A failed comparison can then reflect onto the element as a failed Generate or Move action. 

## OPTIONS

The use of "OPTIONS" is not a new concept to Endevor. Typically, they are objects that provide detailed instructions to the CONPARMX steps of an Endevor processor. To implement this procedure, it is not necessary that you be familiar with the use of OPTIONS or with the CONPARMX utility. Example OPTIONS and processors are provided with this procedure. However, if you would like to know more about the use of OPTIONS in an Endevor processor, see [this doc](https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/18-1/administrating/processors/processor-utilities.html#concept.dita_f657792fe5b63ba8cd9304095175664793517854_CONPARMXUtility).

## YAML 

Data can be constructed into a YAML format, and is easily readable by humans. YAML is a valid choice on the mainframe too - being known mostly to be used in distributed processes.

If you are new to YAML, you can find some introductions here:

 - [YAML Site](https://yaml.org/spec/1.2.2/)
 - [YAML (YAML Ain't Markup Language)](https://www.techtarget.com/searchitoperations/definition/YAML-YAML-Aint-Markup-Language)
 - [What is YAML?](https://www.freecodecamp.org/news/what-is-yaml-the-yml-file-format/)

## Items in this collection

With this procedure, sample processor code is provided in the form of "Includes". Endevor optionally supports either a Panvalet include ("++INCLUDE"), or a Librarian include ("-INC"). If you are not using either, then just copy the sample "Include" code into the processors where you need them. If you are using the Panvalet include, then change the "-INC" references to "++INCLUDE" references (starting in column 8).

Options provide the details for the Automated Test Facility for Batch Applications. Two categories of OPTIONS are a part of this procedure.

- Options for your existing elements (Cobol for example) that specify one or more automated tests to be triggered. 
- Options for your JCL elements that specify how to tailor, run and evaluate a test.

Setup steps for the Automated Test Facility for Batch Applications: 

1)	Prepare your existing processors to recognize OPTIONS that request automated tests. This step addresses your existing Generate and/or Move processors:

    a)  A fetch for the element's options is necessary. If you do not already have one, then copy (or include) the content of `GET#OPTE` into your existing processor(s).  

    b)  Copy or Include the content of `AUTOTEST` into your processor(s), placed after the fetch.  

2)  Copy `TEST#JOB` into a REXX library that will be accessed by your processors.

3)	Prepare the JCL (or other element type) processor(s).  

    a)	Install `GTESTING` as an Endevor processor. Optionally, you may copy `GTESTING` into an existing processor. Tailor the top of the processor to specify values applicable to your site. Be sure to name the library where you placed the `TEST#JOB` Rexx module. Also, consider the value given to the* **RESLTHLQ** processor variable. This value names the High Level Qualifier for datasets where job outputs are captured. You can use the C1USERID processor, if you prefer. The Rexx driver, `TEST#JOB`, creates datasets prefixed with **RESLTHLQ** and with additional nodes for C1Stage, date and Job number.

    b)  Define the use of your processor to the Endevor Environments, stages, systems, types and processor groups where you need to support Automated Testing.

4)  Prepare the OPTIONS that drive Automated Testing. For example, if you have a batch COBOL program COBA that runs in a JCL element, JOBA, then you will need OPTIONS for both.

    a) Build OPTIONS for your existing elements.  Prepare OPTIONS for triggering automated tests, using the provided `Example COBOL element OPTIONS`.

    b) Build OPTIONS for your JCL (or other element type). Use the provided `Example JCL element OPTIONS`, where an example is given for every variation of supported syntax. Note that there are several kinds of OPTIONS statements for JCL:
        - Search and Replace pairs
        - Others that optionally specify values for waiting and comparing 

    Note:

    The provided OPTIONS specify the Endevor C1STAGE, where Automated Testing is to occur. You can modify it to meet your needs, including using C1ENVMNT or C1SUBSYS to provide Automated Testing for Deploy to Test actions.


Note: Members **[OPTVALDT](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/OPTVALDT.rex)**, **[TXTRPLCE](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/TXTRPLCE.rex)**, **[JCLRPLCE](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/JCLRPLCE.rex)** and **[YAML2REX](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/YAML2REX.rex)** are REXX subroutines required for the **Automated Test Facility for Batch Applications**. They are used by more than one solution on this GitHub, but can be found by clicking their names, as shown above, or by navigating to the **Field-Developed-Programs** folder and the **Processor-Tools-and-Processor-Snippets** subfolder.

To prepare your JCL for testing, you have two choices:

 1. Use simple commands to automatically make broad, sweeping changes to your JCL with [TXTRPLCE](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/TXTRPLCE.rex). Write as many FindTxt and Replace commands as needed.  

 2. If you need a more precise method for modifying your JCL, use [JCLRPLCE](https://github.com/BroadcomMFD/broadcom-product-scripts/blob/main/endevor/Field-Developed-Programs/Processor-Tools-and-Processor-Snippets/JCLRPLCE.rex), where you can name the STEP and optionally the DDname where your changes must be made. 

 Both tools allow you to insert lines into your JCL before it is submitted for testing.


You may use a moveout file to collect all members related to the **Automated Test Facility for Batch Applications**.
