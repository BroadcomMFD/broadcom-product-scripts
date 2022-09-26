//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
package com.example.email.service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.zowe.apiml.enable.EnableApiDiscovery;

@SpringBootApplication
@EnableApiDiscovery
public class EmailSpringBootApplication {

	public static void main(String[] args) {
		SpringApplication.run(EmailSpringBootApplication.class, args);
	}

}
