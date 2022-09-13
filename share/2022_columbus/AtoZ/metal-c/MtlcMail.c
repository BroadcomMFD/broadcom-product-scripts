//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "MtlcMail.h"
#include "zosload.h"

#define TRUE  1
#define FALSE 0

#define P32 __ptr32
#define P64 __ptr64

#pragma prolog(MTLCMAIL, "&CCN_MAIN SETB 1 \n MYPROLOG")

void upperCase( char *c, int len );

typedef int (*P32 EMAILSRV)( 
                char  *P32 wrk,
                int   *P32 alet1,    
                int   *P32 email_safrc,
                int   *P32 alet2,    
                int   *P32 email_rc,
                int   *P32 alet3,    
                int   *P32 email_rsn,
                int   *P32 alet4,    
                short *P32 func_code,
                int   *P32 opt_word,
                char  *P32 User,
                char  *P32 Cert,
                void  *P32 emailarea,
                void  *P32 dn,
                void  *P32 registry ) 
                    __attribute__((amode31)) ;

//---------------------------------------------------------------
//  Call R_Map to get email address
//---------------------------------------------------------------
int MtlcMail( char *user, char  *email )
{

    char   workarea[1024] ;

    int    saf_rc     = 0 ;
    int    racf_rc    = 0 ;
    int    racf_rsn   = 0 ;
    int    alet       = 0 ;

    int    emailLen = 0;

    short  func_code  = 9 ; 
    int    opt_word   = 0 ;
    
    char   userId[9];
    char   cert[4];
    char   dn[3];
    char   emailarea[250];
    char   registry[3];
    char* P32 pRegistry = registry;

    *((char* P32) & pRegistry) |= 0x80;   //set HOB on last parameter

    EMAILSRV pEmailSrv ;

//  Load R_Map callable service module
    pEmailSrv = (EMAILSRV) osLoad( "IRRSIM00" , NULL) ;

    *((short*) emailarea ) = 248 ;
    *((short*)dn) = 0;
    *((short*)registry) = 0;

    memset(cert, 0, sizeof(cert));
    memset( userId, ' ', sizeof(userId) ) ;
    
    memcpy( userId+1, user, strlen(user) ) ;
    upperCase( userId+1, 8 ) ;
    userId[0] = 8 ;

   (pEmailSrv)( workarea,
              &alet, &saf_rc,
              &alet, &racf_rc,
              &alet, &racf_rsn,
              &alet, &func_code,
              &opt_word,
              userId,
              cert,
              emailarea,
              dn, 
              pRegistry ) ;

//  Check return code from EMAILSERV and return email accordingly
   if (saf_rc == 0)
   {
       emailLen = *((short* P32) emailarea);
       memcpy(email, emailarea + 2, emailLen);
       email[emailLen] = 0;
   }
   else
       saf_rc = ((racf_rc << 16) | racf_rsn ) ;

//  Delete R_Map callable service module
    osDelete( "IRRSIM00" ) ;

    return saf_rc ;
}

void upperCase( char *c, int len )
{
    int i ;

    for ( i = 0 ; i < len ; i++ )
    {
        c[i] |= 0x40 ;
    }
    return ;
}
