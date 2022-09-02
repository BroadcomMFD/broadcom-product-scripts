//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
package com.example.email.service.jni;

/**
 * This class invokes a C++ Jni service that in turn calls
 * metal c to invoke R_usermap to get a user's 
 * email address.
 */
public class ZosEmail  {
    static {
        System.loadLibrary("libemailserv.so");
    }

    private native int cppGetEmail( int reqtype, String user ) ;

    private String email ;
    public String javaGetEmail(int id, String userid) {

        email = new String("") ;

        int request = id;
        int rc = cppGetEmail( request, userid ) ;

		System.out.println("RC: "+ rc + " Request: " + request + " Email: "+ email );

        return email;
    }
	
    //USS Test
	//public static void main(String [] args){
	//	ZosEmail zpt = new ZosEmail();
	//	zpt.javaGetEmail(1,args[0]);
	//}
	
}
