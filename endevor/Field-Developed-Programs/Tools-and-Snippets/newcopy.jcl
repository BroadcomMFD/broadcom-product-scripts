/*--------------------------------------------------------------------
//TEST001  EXEC PGM=IRXJCL, ENBPIU0C,                                  
// PARM='ENBPIU00 M &C1ENV &C1SYS &C1SUB &C1TYP &C1PRG &C1ELM'         
//TABLE    DD *                                                        
* C1ENV--- C1SYS--- C1SUB--- C1TYP--- C1PRG--- C1ELM---  CICSRegion    
  TEST     *        *        COBOL    CICS     *         CICSTEST      
  TEST     WHATEVER *        COBOL    CICS     *         CICSTSTW      
  PROD     FINANCE  *        COBOL    CICS     *         CICSPROD       
  PROD     FINANCE  *        COBOL    CICS     ROBERTA   CICSPRRB       
//SYSEXEC  DD  DISP=SHR,DSN=CAPRD.NDVR.V180CA06.CSIQCLS0     MM@LIB     
//MODEL    DD DATA,DLM=QQ                                               
/*$VS,'F &CICSRegion,CEMT SET PROG(&C1ELM)   NEW'                
QQ                                                                      
//SYSTSPRT DD SYSOUT=*                                                  
//OPTIONS  DD *                                                         
//TBLOUT   DD SYSOUT=(A,INTRDR)                                                
//*-------------------------------------------------------------------- 




//STEP1 EXEC PGM=AFCP2016,PARM='SYSIN'              
//CAFCTRAC DD SYSOUT=*                              
//CAFCWTOS DD SYSOUT=*                              
//SYSIN DD *                                        
CICDFMVS,CEMT,S PROG(CICSMUSA) NEWC                 
/*                                                  



//CX001#XX JOB CLASS=B,MSGCLASS=X,NOTIFY=CX00001,
//     REGION=8M RESTART=BYXPEIQ1.
//* CLASS= A,B,C
//*-------------------------------------------------------------------*
//INTRDR EXEC PGM=IEBGENER
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DUMMY
//SYSUT2   DD SYSOUT=(*,INTRDR),DCB=(RECFM=FB,LRECL=80,BLKSIZE=80),
//            FREE=CLOSE
//SYSUT1   DD *,DLM=QQ
//CX001#ZZ JOB CLASS=Y,MSGCLASS=X,NOTIFY=CX00001,
//     REGION=8M RESTART=BYXPEIQ1.
//*-------------------------------------------------------------------*
//NEWCOPY EXEC PGM=IEFBR14
// COMMAND 'F CKFRDA01,CEMT S PROG(RCMC161) NEW'
// COMMAND 'F CKFRDA02,CEMT S PROG(RCMC161) NEW'
QQ
/*



//NEWCOPY EXEC PGM=AFCP2016,PARM='ATDCIG0L,CEMT,S PROG(pgmname) PH',
// COND=(8,LE)


## here PARM= The cics region where u want to do newcopy. It is installation dependent.


Read more: http://ibmmainframes.com/about2455.html#ixzz4vF9Slmuf




Hi !

As Bitneuker answered already in an other question:

//STEP1 EXEC PGM=IEBGENER
//SYSIN DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUT2 DD SYSOUT=(*,INTRDR),DCB=I
//SYSUT1 DD DATA,DLM=$$
/*$VS,'F NTCIC0E,CEMT SET PROG(UTIL5610) NEW'

...with the MVS-Modify command !!!


Read more: http://ibmmainframes.com/about2455.html#ixzz4vF9sFOhu




//STEP1 EXEC PGM=IEBGENER                   
//SYSIN DD DUMMY                           
//SYSPRINT DD SYSOUT=*                     
//SYSUT2 DD SYSOUT=(*,INTRDR)               
//SYSUT1 DD DATA,DLM=$$                     
/*$VS,'F NTCIC0E,CEMT SET PROG(pgmname) NEW'
$$                                          

Read more: http://ibmmainframes.com/about27327.html#ixzz4vFA4vJil





//NEWCOPY EXEC PGM=AFCP2016,PARM='cicsregn,CEMT,S PROG(pgm-name) NE' 
//STEPLIB  DD  DSN=CICSD.CAFC.LOADLIB,DISP=SHR                      

//NEWCOPY EXEC PGM=AFCP2016,PARM='ATDCIG0L,CEMT,S PROG(pgmname) PH', 
// COND=(8,LE) 


Read more: http://ibmmainframes.com/about27327.html#ixzz4vFANOaFc





http://listserv.uga.edu/cgi-bin/wa?A2=ind0509&L=cics-l&F=&S=&P=19507

EXEC CICS     SET

    PROGRAM   (WS-PGMID)

    PHASEIN

    ENABLED

    VERSION   (WS-VERSION)

    RESP      (WS-RESP)

    RESP2     (WS-RESP2)

END-EXEC.

IF WS-RESP NOT = DFHRESP(NORMAL)

    EVALUATE WS-RESP

        WHEN DFHRESP(INVREQ)

             ETC







