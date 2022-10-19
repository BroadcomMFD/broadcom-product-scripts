package com.broadcom.msd.om.sample.favorites.controllers;

import javafx.concurrent.Task;

/**
 * Checked exception for failures during {@link Task} execution.
 */
public class TaskFailureException extends Exception {

  public TaskFailureException(String message) {
    super(message);
  }
}
