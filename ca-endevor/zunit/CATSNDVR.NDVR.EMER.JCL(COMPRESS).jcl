//ZUCMPRS JOB  (12345678),'ZUNIT USER',CLASS=B,PRTY=6,				 
//	MSGCLASS=X,USER=USRNME,NOTIFY=&SYSUID							   
//*-------------------------------------------------------------------	
//*-ZUnit Compress ---------------------------------------------------	
//*-------------------------------------------------------------------	
//	EXPORT SYMLIST=(*)			 <- make JCL symbols available			
//*---																	
//	SET HLQ=PUBLIC.ZUNIT.TESTS.ANAGRA2	<- Files to be compressed		
//*---																	
//	SET TSTCASES='ANAGRA2 TANAGRA2'	 <- 1 or mult space delimited or *	
//	SET TSTCASES='*'													
//	SET TSTCASES='ANAGRA2 TANAGRA2 GANAGRA2 '							
//*---																	
//	SET MAXLRECL=1500					  <- Maximum LRECL size				 
//	SET OUTPUT=PUBLIC.ZUNIT.COMPRESS.ANAGRA2		 <-	 output		 
//*---																	
//	SET ENDEVOR=CAIPRODD.NDVR.V181S0A	  <- Endevor lib prefix	   
//	SET VOLUME=							  <- Optional volume for output 
//*---------------------------------------------------------------		
//*--Rexx: DSNCMPRS														
//*Output: COMPRESS														
//*---------------------------------------------------------------		
//COMPRESS EXEC	 PGM=IKJEFT1B,PARM='DSNCMPRS'							
//OPTIONS  DD *,SYMBOLS=JCLONLY		 <- Permits JCL variables here		
  Action = 'COMPRESS'													
  TestCaseMembers="&TSTCASES"											
  VolSer="&VOLUME"														
  MaxRecordsize=&MAXLRECL												
  MyHLQ	 = '&HLQ'														
  InpOutputDsn	= '&OUTPUT'												
//*DSNCMPRS DD	DUMMY	 <- Turn on Trace								
//DSNCMPRS DD  DUMMY	<- Turn on Trace								
//*- Work Files	 \				----------------------------------		
//SYSIN	   DD  DSN=&&SYSIN,DISP=(,PASS),								
//			   SPACE=(TRK,(1,1)),UNIT=3390,								
//			   RECFM=FB,LRECL=080,BLKSIZE=32000							
//SYSPRINT DD  DSN=&&LISTCAT,DISP=(,PASS),								
//			   SPACE=(TRK,(5,10)),UNIT=3390,							
//			   RECFM=FB,LRECL=150,BLKSIZE=30000							
//*- Work Files	 /				----------------------------------		
//SYSEXEC  DD  DSN=CATSNDVR.NDVR.EMER.CSIQCLS0,DISP=SHR					
//SYSTSIN  DD  DUMMY													
//SYSTSPRT DD  SYSOUT=*													
//*---------------------------------------------------------------		
