# Endevor ELIB Update Stamp reporting
This entry is a follow-up to the 
[Announcement on the Endevor Community site](https://community.broadcom.com/mainframesoftware/discussion/important-notice-for-endevor-elib-users) regarding Endevor ELIBS. The item in this folder gives you a method for reporting on your ELIB datasets, to determine whether any action is necessary.

When you complete the setup and submit the JCL, you will be given a report like this example (run with a Threshold of 400):

        CADEMO.ENDV.ELIB.ADMTEST.BASEMY.ASM          486  
        CADEMO.ENDV.ELIB.ADMTEST.BASEMY.COBOL        545  
        CADEMO.ENDV.ELIB.ADMTEST.BASEMY.PROCESS      786  
        CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.ASM         2321 
        CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.C           584  
        CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.COBOL       2863 
        CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.PROCESS     3409 
        CADEMO.ENDV.ELIB.ADMTEST.DELTA00.PROCESS     422  
        CADEMO.ENDV.ELIB.DEVINT.DELTA00.COBBAT       815  
        CADEMO.ENDV.ELIB.DEVINT.DELTA00.COPY         482  
        CADEMO.ENDV.ELIB.DEVQE.BASE00.COBBAT         635  
        CADEMO.ENDV.ELIB.DEVQE.BASE00.COPY           485  
        CADEMO.ENDV.ELIB.DEVQE.DELTA00.COBBAT        2109 
        CADEMO.ENDV.ELIB.DEVQE.DELTA00.COPY          897  
        CADEMO.ENDV.ELIB.QA.DELTA00.COBBAT           480  

The report only lists ELIB datasets whose "LAST UPDATE STAMP" value is equal to or greater than the THRESHLD value as set in the JCL. Report details include the ELIB dataset name and the "LAST UPDATE STAMP" value.

To setup the JCL for your use:
 
- Tailor the jobcard for your site
- Place the REXX program ELIBSCAN into any library and enter the name of the library as the value for the JCL variable named SYSEXEC
- Set the value of the HLQ variable to the high-level qualifier(s) where your ELIB datasets might be found
- Set the value of the ELIBS variable to include one or more text strings found in your ELIB dataset names
- Set the value of the THRESHLD variable to the lowest value for "LAST UPDATE STAMP" that you want reported
- Set the value of the CSIQCLS0 variable to your site CSIQCLS0 library name, or the name of the dataset that contains ENBPIU00
- Around line 84, delete lines or replace them with your Endevor STEPLIB and CONLIB names

Feel free to reach out to joseph.walther@broadcom.com if you have any issues or questions.

