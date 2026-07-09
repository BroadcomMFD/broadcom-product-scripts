/* rexx */                                                                      
/*********************************************************************/         
/*  AUTHOR.    (C) 2025 Broadcom                                      */        
/*             Jose Benigno Gonzalez for CUST.                        */        
/*                                                                    */        
/* Validates Endevor CCID against ServiceNow change request  and      */        
/* Incident Management Module  - Called from Endevor Exit 2           */        
/*                                                                    */        
/* Currently in Dev Phase:                                            */        
/* Validates the first ten characters of the packageID  against       */        
/* ServiceNow change request and Incident Management Module - Called  */        
/* from Endevor Exit 7                                                */        
/*                                                                    */        
/*********************************************************************/         
trace off                                                                       
                                                                                
argstr = ARG(1)                                                                 
hexs = C2X(argstr)                                                              
                                                                                
hwtRC = call hwtcalls 'on'                                                      
if hwtRC > 0 THEN do                                                            
  say "cannot establish hwtcalls environment rc="hwtRC                          
  exit hwtRC                                                                    
end                                                                             
                                                                                
verbose= 0                                                                      
SnowTrc_RC = bpxwdyn("info fi(snowtrc) INRTTYP(variable)")                      
If SnowTrc_RC = 0 Then do                                                       
  Verbose = 1                                                                   
end                                                                             
                                                                                
/*                                                                              
  Allocation of  mandatory ddnames for BPXBATCH                                 
*/                                                                              
                                                                                
If Verbose then exitrc = bpxwdyn("alloc fi(STDOUT) sysout")                     
           else exitrc = bpxwdyn("alloc fi(STDOUT) ",                           
                                 "dsorg(ps) lrecl(16383) ",                     
                                 "SPACE(5,1) CYL RECFM(F,B) new delete  ")      
                                                                                
If exitRC <> 0 Then Do                                                          
  say 'DynAlloc error for STDOUT DDname: 'exitRC                                
  call Issue_Message(exitrc)                                                    
  Return exitRC                                                                 
End                                                                             
                                                                                
If Verbose then exitrc = bpxwdyn("alloc fi(STDERR) sysout")                     
           else exitrc = bpxwdyn("alloc fi(STDERR) ",                           
                                 "dsorg(ps) lrecl(512) ",                       
                                 "SPACE(10) TRACKS RECFM(F,B) new delete")      
                                                                                
If exitRC <> 0 Then Do                                                          
  say 'DynAlloc error for STDERR DDname: 'exitRC                                
  call Issue_Message(exitrc)                                                    
  Return exitRC                                                                 
End                                                                             
                                                                                
exitrc = bpxwdyn("alloc dd(stdenv) ",                                           
         "lrecl(80) recfm(f,b) tracks space(5,1) ",                             
         "new delete")                                                          
                                                                                
If exitRC <> 0 Then Do                                                          
  say 'DynAlloc error for STDENV DDname: 'exitRC                                
  call Issue_Message(exitrc)                                                    
  Return exitRC                                                                 
End                                                                             
                                                                                
STDENV_Rec = '_BPX_SHAREAS=YES'                                                 
queue Left(STDENV_Rec,80)                                                       
                                                                                
STDENV_Rec = '_BPX_BATCH_SPAWN=YES'                                             
queue Left(PARMIN_Rec,80)                                                       
                                                                                
"Execio" queued() "Diskw STDENV (FINIS"                                         
                                                                                
/*                                                                              
  Call the servicenow driver interface                                          
*/                                                                              
cmd  = 'SH /u/users/ibmuser/rexx/CUST_ndvrsnow.rexx'                            
cmd = cmd || ' ' ||hexs                                                         
                                                                                
prog = 'BPXBATCH'                                                               
address 'ATTCHMVS' prog 'cmd'                                                   
                                                                                
BPX_rc = rc                                                                     
                                                                                
                                                                                
exitrc = bpxwdyn("free dd(STDOUT)")                                             
exitrc = bpxwdyn("free dd(STDERR)")                                             
exitrc = bpxwdyn("free dd(STDENV)")                                             
                                                                                
                                                                                
sysRC = syscalls('OFF')                                                         
                                                                                
return BPX_rc                                                                   
                                                                                
/*****************************************************************/             
/* Procedures */                                                                
/*****************************************************************/             
Issue_Message: Procedure expose s99msg.                                         
Parse ARG exitrc                                                                
Numeric digits 10                                                               
Select                                                                          
  when ((exitrc <= -1610612737) & (exitrc >= -2147483648)) |,                   
      (exitrc > 0) Then                                                         
    Do                                                                          
    /***************************************************************/           
    /*                                                             */           
    /* Ha ocurrido un Error durante la Alocacion Dinamica          */           
    /*                                                             */           
    /***************************************************************/           
     RetCodeX = D2X(exitrc,8)                                                   
     say ' '                                                                    
     say '          *************************************************'          
     say '          *   DynAlloc S99Error: 'substr(RetCodeX,1,4)'   *'          
     say '          *   DynAlloc S99Info : 'substr(RetCodeX,5,4)'   *'          
     say '          *************************************************'          
     say ' '                                                                    
     if s99msg.0 > 0 then                                                       
       Do                                                                       
         Say 'DYNALC02E Mensajes de Error S99msg DynAlloc: '                    
         say ' '                                                                
         Do I = 1 Until I = s99msg.0                                            
            say '          's99msg.i                                            
         End                                                                    
       End /* S99msg.o */                                                       
    End /* Do exitrc */                                                         
  When (exitrc <= -21) & (exitrc >= -99) then                                   
    Do                                                                          
     Clave = (exitrc+20) * -1                                                   
     say ' '                                                                    
     Say 'DYNALC03E Error en la clave 'Clave' pasada a DynAlloc',               
          'desde programa bpxwdyn.'                                             
    End                                                                         
  When (exitrc = 20) then                                                       
    Do                                                                          
     say ' '                                                                    
     Say 'DYNALC04E Lista de Parametros de bpxwdyn incorrecta.'                 
     Say '          Revise el manual Using REXX and z/OS UNIX',                 
         'System Services, para mayor informacion.'                             
    End                                                                         
  When substr(exitrc,2,3) = 100 then                                            
    Do                                                                          
      nop                                                                       
    End                                                                         
  Otherwise                                                                     
      nop                                                                       
End /* Select */                                                                
return                                                                          
                                                                                
