//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
#ifndef MTLCMAIL_H
#define MTLCMAIL_H

#if defined(__cplusplus) && (defined(__IBMCPP__) || defined(__IBMC__))
extern "OS"
{
#elif defined(__cplusplus)
extern "C"
{
#endif

#define MtlcMail MTLCMAIL

int MtlcMail(char *userId, char *email);

#if defined(__cplusplus)
}
#endif

#endif
