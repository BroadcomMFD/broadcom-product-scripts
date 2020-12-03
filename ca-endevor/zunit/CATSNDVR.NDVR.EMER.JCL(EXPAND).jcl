//ZUEXPND JOB  (12345678),'ZUNIT USER',CLASS=B,PRTY=6,				 
//	MSGCLASS=X,USER=USRNME,NOTIFY=&SYSUID							   
//*-------------------------------------------------------------------	
//*-ZUnit Expand   ---------------------------------------------------	
//*-------------------------------------------------------------------	
//	EXPORT SYMLIST=(*)					<- make JCL symbols available		   
//*---																	
//	SET INPUT=PUBLIC.ZUNIT.COMPRESS.ANAGRA2	  <- Input		 
//	SET HLQ=PUBLIC.ZUNIT.TESTS.ANAGRA2		  <- To be created				
//*---																	
//	SET VOLUME=							<- Optional volume for output 
//*---																	
//	SET ENDEVOR=CAIPRODD.NDVR.V181S0A	<- Endevor lib prefix	 
//*---																	
//*--Rexx: (DSNCMPRS) ----------------------							
//*---------------------------------------------------------------		
//*---------------------------------------------------------------		
//EXPAND   EXEC	 PGM=IKJEFT1B,PARM='DSNCMPRS'							
//OPTIONS  DD *,SYMBOLS=JCLONLY		 <- Permits JCL variables here		
  Action = 'EXPAND'														
  VolSer="&VOLUME"														
  MyHLQ	 = '&HLQ'														
  InpOutputDsn	= '&INPUT'												
//*DSNCMPRS DD	DUMMY	 <- Turn on Trace								
//DSNCMPRS DD  DUMMY													
//SYSEXEC  DD  DSN=CATSNDVR.NDVR.EMER.CSIQCLS0,DISP=SHR					
//SYSTSIN  DD  DUMMY													
//SYSTSPRT DD  SYSOUT=*													
//*---------------------------------------------------------------		
