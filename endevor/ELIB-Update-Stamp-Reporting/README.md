# Endevor ELIB Update Stamp reporting
This entry is a follow-up to the 
[Announcement on the Endevor Community site](https://community.broadcom.com/mainframesoftware/discussion/important-notice-for-endevor-elib-users) regarding Endevor ELIBS. The item in this folder gives you a method for reporting on your ELIB datasets, to determine whether any action is necessary.

When you complete the setup and submit the JCL, you will be given a report like this example (run with a Threshold of 500):

    CADEMO.ENDV.ELIB.ADMTEST.BASEMY.COBOL        CLUSTER  VS  ?? 545   
    CADEMO.ENDV.ELIB.ADMTEST.BASEMY.PROCESS      CLUSTER  VS  ?? 786   
    CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.ASM         CLUSTER  VS  ?? 2321  
    CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.C           CLUSTER  VS  ?? 584   
    CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.COBOL       CLUSTER  VS  ?? 2863  
    CADEMO.ENDV.ELIB.ADMTEST.DELTAMY.PROCESS     CLUSTER  VS  ?? 3409  
    CADEMO.ENDV.ELIB.DEVINT.DELTA00.COBBAT       CLUSTER  VS  ?? 815   
    CADEMO.ENDV.ELIB.DEVQE.BASE00.COBBAT         CLUSTER  VS  ?? 635   
    CADEMO.ENDV.ELIB.DEVQE.DELTA00.COBBAT        CLUSTER  VS  ?? 2109  
    CADEMO.ENDV.ELIB.DEVQE.DELTA00.COPY          CLUSTER  VS  ?? 897   

The report only lists ELIB datasets whose "LAST UPDATE STAMP" value is equal to or greater than the THRESHLD value. Report details include the ELIB dataset name, CLUSTER or NONVSAM, the DSORG and RECFM values, and the "LAST UPDATE STAMP" value.

To setup the JCL for your use:
 
- Tailor the jobcard for your site
- Set the value of the HLQ variable to the high-level qualifier(s) where your ELIB datasets might be found
- Set the value of the ELIBS variable to include one or more text strings found in your ELIB dataset names
- Set the value of the THRESHLD variable to the lowest value for "LAST UPDATE STAMP" that you want reported
- Set the value of the CSIQCLS0 variable to your site CSIQCLS0 library name, or the name of the dataset that contains ENBPIU00
- Around line 70, delete lines or replace them with your Endevor STEPLIB and CONLIB names

Feel free to reach out to joseph.walther@broadcom.com if you have any issues or questions.

