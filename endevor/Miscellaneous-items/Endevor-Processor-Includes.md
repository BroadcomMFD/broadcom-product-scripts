# Endevor-Processor-Includes

COBOL programmers use Copybooks and Assembler programmers use macros. IBM's Job Control Language is supported by PROCs, and the C++ language is supported by Headers. All the supporting items represent places where frequently used lines of code can be coded once, and then referenced as needed by the others. This document presents how to provide the same feature for Endevor processors. Any Endevor site can incorporate the use of processor "Includes" by following these simple steps.

## Update the Defaults table

Modify the LIBENV value on your Defaults table
>
               LIBENV=PV,               LIBRARIAN (LB), PANVALET (PV)  X 

You can choose a value of 'LB' or 'PV' for Librarian or Panvalet respectively. Neither choice requires that you have the product installed, but simply designates whether include references will be made with Librarian syntax ( -INC) or Panvalet syntax ( ++INCLUDE ).

## Name an INCLUDE library on your processor Definitions

Here is an example processor type definition where an INCLUDE LIBRARY is defined. 

  ~~~
   DISPLAY----------------------  TYPE DEFINITION  ------------------------------
   COMMAND ===>                                                                 
   CURRENT ENV: ADMIN     STAGE ID: 1  SYSTEM: ADMIN   TYPE: PROCESS    
                                                                                 
   DESCRIPTION: ===>CA ENDEVOR SCM PROCESSOR                                   
   UPDATED:          07AUG2118:19BYGUESSWHO                                  
                                                                                 
               -----------------  ELEMENT OPTIONS  -------------------           
   DELTA FORMAT(F/R/I/L)===>R SOURCE LEN  ===>80    ELE RECFM(N/F/V)===>N
   COMPRESS/ENCRYPT(Y/N)===>N COMPARE FROM===>1     DFLT PROC ===>PROCESS 
   AUTO CONSOL(Y/N)    ===>N COMPARE TO  ===>80    LANGUAGE  ===>CNTLPROC
   CONSOL AT LVL ===>96       REGRESSION ===>80    PV/LB LANG===>DATA    
   LVLS TO CONSOL===>0        REG SEV(I/W/C/E) ===>C                        
                                                                                 
           -----------------  COMPONENT LIST OPTIONS  ------------------         
   FWD/REV DELTA(F/R)   ===>RAUTO CONSOL(Y/N)    NCONSOL AT LVL     96 
                                                        LVLS TO CONSOL    0  
           -------------------------  LIBRARIES  -----------------------         
   BASE/IMAGE LIBRARY===>NDVR.ADMIN.ENDEVOR.ADM1.&C1ELTYPE           
   DELTA LIBRARY     ===>NDVR.ADMIN.ENDEVOR.ADM1.DELTA               
   INCLUDE LIBRARY   ===>NDVR.ADMIN.ENDEVOR.ADM1.INCLUDE             
   SOURCE O/P LIBRARY===>NDVR.ADMIN.ENDEVOR.SHIP1.PROCESS             
     EXPAND INCLUDES(Y/N) ===>Y                                              
 ~~~
In the Environment(s) where you have type PROCESS defined, add an Include library at each stage of the Environment.

## Define a type for INCLUDE

In the Environment(s) where you have type PROCESS defined, also define the type INCLUDE (or your type name of choice). Ensure that the type is is defined so that  elements created for this type also cause the libraries named in the previous step to be populated.

## Create your INCLUDE references

Details of this step depend on whether you selected the PV or LB option on step 1. 
If you are using the Panvalet method, then use this example.
~~~
//******************************************************************* 
//GCOBOL   PROC AAAX='',                                              
//             CPARMA='LIB,LIST',                                     
//             CPARMZ='NOSSR',                                        
//             @CICSLOD='SYS3.GA.CICS.SDFHLOAD',     
       ++INCLUDE SETSTMTS    Standard processor includes              
//            ZZZZZZ=                                                 
~~~
The "++INCLUDE" text must begin in column 8.

If you are using the Librarian method, then use this example.

~~~
//******************************************************************* 
//GCOBOL   PROC AAAX='',                                              
//             CPARMA='LIB,LIST',                                     
//             CPARMZ='NOSSR',                                        
//             @CICSLOD='SYS3.GA.CICS.SDFHLOAD',     
-INC SETSTMTS    Standard processor includes              
//            ZZZZZZ=                                                 
~~~
The -"INC" text must begin in column 1.

With either method, the Automated Configuration Manager (ACM) picks up relationships and Include elements automatically.