# Readme Automated Test Facility for Batch Applications.md

This procedure allows Endevor processors to automate the tailoring, submission and evaluation of Batch application tests. Tests are triggered automatically by the MOVE or Generate actions of elements of any element type. For example, you may initiate automated tests when a COBOL program is Moved or Generated at a certain stage of Endevor. The test will locate, tailor, submit and evaluate results for one or more JCL elements whose names appear in the "OPTIONS" content of the COBOL program.

The use of "OPTIONS" is not a new concept to Endevor. Originally, they were the objects that provide detailed instructions to the CONPARMX steps of an Endevor processor. To implement this Automated Test procedure, it is not necessary that you be familiar with the use of OPTIONS or with the CONPARMX utility. Example OPTIONS and processors are provided with this procedure. However, if you would like to know more about the use of OPTIONS in an Endevor processor, see:

(<https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/ca-endevor-software-change-manager/18-1/administrating/processors/processor-utilities.html#concept.dita_f657792fe5b63ba8cd9304095175664793517854_CONPARMXUtility>)

This procedure provides sample processor code in the form of "Includes". Endevor optionally supports a Panvalet include ("++INCLUDE") or a Librarian include ("-INC"). If your Endevor is not using either, then just copy the sample "Include" code into the processors where you need them. If you are using the Panvalet include, then change the "-INC" references to "++INCLUDE" references (starting in column 8).

Expanding of the use of Options is key for the Automated Test Facility for Batch Applications. Two categories of OPTIONS are a part of this procedure.

- Options for existing elements (Cobol for example) that specify one or more automated tests to be triggered.
- Options for JCL elements that specify how to tailor, run and evaluate tests.

Setup steps for the Automated Test Facility for Batch Applications:

1) Prepare your existing processors to recognize the OPTIONS that request automated tests. This step addresses your existing Generate and/or Move processors:
    a) A fetch for the element's options is necessary. If you do not already have one, then copy (or include) the content of `GET#OPTE` into your existing processor(s).  
    b) Copy or Include the content of `AUTOTEST` into your processor(s), placed after the fetch.
    (Be sure that no sequence numbers are included in its content)

2) Copy `TEST#JOB` into a REXX library that will be accessed by your processors.

3) Prepare JCL processors.  
    a) Install `GTESTING` as an Endevor processor. Optionally, you may copy `GTESTING` content into an existing processor. Tailor the top of the processor to specify values applicable to your site. Be sure to name the library where you placed the `TEST#JOB` Rexx module. Also, consider the value given to the* **RESLTHLQ** processor variable. This value names the High Level Qualifier for datasets where job outputs are captured. You can use the C1USERID processor, if you prefer. The Rexx driver, `TEST#JOB`, creates datasets prefixed with **RESLTHLQ** and with additional nodes for C1Stage, date and Job number.
    b)  Define the use of your processor to the Endevor Environments, stages, systems, types and processor groups where you need to support Automated Testing.

4) Prepare the OPTIONS that drive Automated Testing. For example, if you have a batch COBOL program COBA that runs in a JCL element, JOBA, then you will need OPTIONS for both.
    a) Build OPTIONS for your existing elements.  Prepare OPTIONS for triggering automated tests, using the provided `Example COBOL element OPTIONS`.
    b) Build OPTIONS for your JCL (or other element type). Use the provided `Example JCL element OPTIONS`, where an example is given for every variation of supported syntax. Note that there are several kinds of OPTIONS statements for JCL:
        - Search and Replace pairs
        - Replace all DDname allocations
        - Insert lines
        - Specify values for job waiting and comparing
        - Mask test result outputs for test comparisons
    Code these options to apply changes working from top to bottom and left to right through the JCL.

Note.
Some Endevor-like variables (in camel case) may be embedded within Replace values and Insert lines. At the time of an automated test, these variables will be replaced with values from Endevor. Embedded variables include:
    - &C1Envmnt
    - &C1System
    - &C1Subsys
    - &C1Stage
    - &C1Element
