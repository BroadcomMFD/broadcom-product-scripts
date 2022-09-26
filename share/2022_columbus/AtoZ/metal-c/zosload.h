//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
#ifndef ZOSLOAD_H
#define ZOSLOAD_H
#define osLOAD   OSLOAD
#define osDELETE OSDELETE

/*-------------------------------------------------------------------*/
/*                                                                   */
/*   osLoad() Function Routine                                       */
/*                                                                   */
/*   Load the requested module into virtual storage                  */
/*                                                                   */
/*   Return: Address of loaded routine or 0                          */
/*                                                                   */
/*-------------------------------------------------------------------*/
static void * __ptr32 osLoad(char *modname, void * __ptr32 pDcb)
{

    int  rc ;                        // Return Code
    char module[8] ;                 // Module name

    void * __ptr32 p_module = 0;     // Module address

    memset( module, ' ', sizeof(module) ) ;
    memcpy( module, modname, strlen(modname) ) ;

    // Load requested module

       __asm volatile (
           "*                                                 \n"
           " LOAD EPLOC=(%2),DCB=(%3)                         \n"
           "*                                                 \n"
           " ST    0,%0                                       \n"
           " ST    15,%1                                      \n"
           "*                                                 \n"
           : "=m"(p_module),
             "=m"(rc)
           : "r"(module),
             "r"(pDcb)
           : "r15", "r14", "r0", "r1");

    if ( rc )
       return NULL ;

    return p_module ;
}


/*-------------------------------------------------------------------*/
/*                                                                   */
/*   osDelete Function Routine                                       */
/*                                                                   */
/*   Delete the requested module from virtual storage                */
/*                                                                   */
/*-------------------------------------------------------------------*/
static void osDelete(char *modname )
{

    int  rc ;                        // Return Code
    char module[8] ;                 // Module name

    memset( module, ' ', sizeof(module) ) ;
    memcpy( module, modname, strlen(modname) ) ;

    // Load requested module

       __asm volatile (
           "*                                                 \n"
           " DELETE EPLOC=(%1)                                \n"
           "*                                                 \n"
           " ST    15,%0                                      \n"
           "*                                                 \n"
           : "=m"(rc)
           : "r"(module)
           : "r15", "r14", "r0", "r1");

    return ;
}


#endif       // ZOSLOAD_H
