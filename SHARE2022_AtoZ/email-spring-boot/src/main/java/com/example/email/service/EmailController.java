//===========
//Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
//Broadcom Inc. corporate affiliate that distributes this software.
//===========
package com.example.email.service;

import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.email.service.jni.ZosEmail;

@Controller
@EnableAutoConfiguration
public class EmailController {
	private ZosEmail zosEmail = new ZosEmail();

	public EmailController() {
	}

	private AtomicInteger callId = new AtomicInteger();

	@RequestMapping("/api/v1/userEmail")
	@ResponseBody
	public String home(@RequestParam(name = "userid") String userId) {
		System.out.println("Calling native email service: " + userId);
		return userId + "'s email is: " + zosEmail.javaGetEmail(callId.incrementAndGet(), userId);
	}
}
