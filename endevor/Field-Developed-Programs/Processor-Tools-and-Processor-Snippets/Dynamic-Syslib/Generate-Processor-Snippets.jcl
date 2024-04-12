//**********************************************************************
//*   In your (COBOL+)  Generate processor(s), your SYSLIBs can be 
//*   Dynamically constructed from the ALIAS names that might be
//*   defined. Some/All/None of your Subsystem (Sandbox) name 
//*   may have ALIAS definitions.
//*
//*   At the top portion of your GENERATE processor, use this 
//*   variable to define the HLQ prefix for Alias names. 
//*   The value should match the AliasPrefix value in GALIAS.
//             ALIASPFX='SYSMD32.ALIAS.&C1SY..',
    .  .  .
//*   In the SYSLIB for your COBOL compile step.....
//SYSLIB   DD ...
//*    Include the Alias libraries if found \
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY1,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY2,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY3,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY4,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY5,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..COPY6,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//*    Include the Alias libraries if found  /
    .  .  .
//*   In the SYSLIB for your Linker-Binder step.....
//SYSLIB   DD ...
//*    Include the Alias libraries if found \
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD1,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD2,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD3,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD4,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD5,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//         DD  DSN=&ALIASPFX..&C1SUBSYS..LOAD6,
//             DISP=SHR,ALLOC=COND,MONITOR=COMPONENTS
//*    Include the Alias libraries if found /

//*   You can expand beyond 6 libraries or 
//*   expand the SYSLIBS for other steps as needed.