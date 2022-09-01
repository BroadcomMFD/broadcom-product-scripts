//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
#include <jni.h>
#include <iostream>
#include <string>
#include <unistd.h>
#include "ZosEmail.h"
#include "MtlcMail.h"

using namespace std;

/**
 * JNI implementation in C++, accesses data passed from Java and returns data;
 *
 * The fields between the pragmas below need to be in ASCII.
 *
 * Runtime translations can be done via:
 *   __etoa() EBCDIC to ASCII
 *   __atoe() ASCII to EBCDIC
 */
#if defined(__IBMC__) || defined(__IBMCPP__)
#pragma convert(819)
#endif

const char *EMAIL_FIELD = "email";
const char *JNI_FIELD_STRING = "Ljava/lang/String;";

#if defined(__IBMC__) || defined(__IBMCPP__)
#pragma convert(0)
#endif

#define MIN(x,y) ((x) < (y) ? (x) : (y))

void trim( char *pStr, int size ) ;

JNIEXPORT jint JNICALL Java_com_example_email_service_jni_ZosEmail_cppGetEmail(
                         JNIEnv *env, jobject thisobj, jint req, jstring UserId)
{
    int   rc       = 0;
    const char  *user ;
    char  UserEbc[9] ;
    char  EmailEbc[248] ;
    char  EmailAsc[248] ;

    // input values from Java
    user = env->GetStringUTFChars(UserId, NULL);
 
    memset( UserEbc, 0, sizeof(UserEbc) ) ;

    strncpy( UserEbc, user, MIN(strlen(user), sizeof(UserEbc)-1) ) ;

    __atoe(UserEbc);


    cout << "[DEBUG] EMAILSERV Input - UserId: " << UserEbc << endl;
    cout << "[DEBUG] Calling GetEmail function" << endl;

    rc = MtlcMail( UserEbc, EmailEbc ) ;

    cout << "[DEBUG] Returned  from GetEmailAddress function, RC=" << rc << endl;
    cout << "[DEBUG] EmailAddress: " << EmailEbc << endl ;


    if ( rc == 0 )
    {
        strcpy( EmailAsc, EmailEbc ) ;
        __etoa( EmailAsc ) ;

        jclass    thisclass = env->GetObjectClass(thisobj);
        jfieldID  emailFldId = env->GetFieldID(thisclass, EMAIL_FIELD, JNI_FIELD_STRING);

        jstring   strEmail = env->NewStringUTF( EmailAsc ) ;
        env->SetObjectField( thisobj, emailFldId, strEmail ) ;
        env->DeleteLocalRef( strEmail ) ;
    }

    return rc;
}

