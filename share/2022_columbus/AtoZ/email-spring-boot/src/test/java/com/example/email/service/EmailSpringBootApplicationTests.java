//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
package com.example.email.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledOnOs;
import org.junit.jupiter.api.condition.OS;
import org.springframework.boot.test.context.SpringBootTest;

// EmailController loads libemailserv.so (built from metal-c on z/OS), so the
// context can only start on z/OS. JUnit reports z/OS as OS.OTHER.
@EnabledOnOs(OS.OTHER)
@SpringBootTest
class EmailSpringBootApplicationTests {

	@Test
	void contextLoads() {
	}

}
