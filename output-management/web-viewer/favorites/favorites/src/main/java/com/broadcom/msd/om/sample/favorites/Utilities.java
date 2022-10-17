package com.broadcom.msd.om.sample.favorites;

import lombok.experimental.UtilityClass;

@UtilityClass
public class Utilities {

  public static String resolveGenericExceptionReason(Throwable exception) {
    if (exception == null) {
      return "Unknown reason";
    }

    String reason = null;
    Throwable nested = exception;
    while (nested != null && reason == null) {
      reason = nested.getLocalizedMessage();
      nested = exception.getCause();
    }

    if (reason == null) {
      final StackTraceElement[] stack = exception.getStackTrace();
      assert stack.length > 0;

      reason = String.format("%s (%s.%s:%d)", exception.getClass().getSimpleName(),
          stack[0].getClassName(), stack[0].getMethodName(), stack[0].getLineNumber());
    }

    return reason;
  }
}
