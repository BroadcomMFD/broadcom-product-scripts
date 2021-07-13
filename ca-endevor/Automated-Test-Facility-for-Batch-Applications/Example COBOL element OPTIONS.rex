IGYCRCTL='LIST,LIB,APOST'                                           
IEWL= 'XREF,LIST,LET,AMODE(24),RMODE(24)'                           
*                                                                   
* Kick off an automated test of JCLs TESTJOB1 then TESTJOB2        
* when the COB program is Moved or generated in the UTC stage:             
AutomatedTest@UTC.1 = 'TESTJOB1'                                    
AutomatedTest@UTC.2 = 'TESTJOB2 FROM SUBSYSTEM JCLCHECK'            