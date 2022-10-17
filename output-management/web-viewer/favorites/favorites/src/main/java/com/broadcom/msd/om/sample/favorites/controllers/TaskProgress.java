package com.broadcom.msd.om.sample.favorites.controllers;

import com.google.inject.Singleton;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;

/**
 * Stage to show progress of a generic asynchronous multistep task.
 */
@Singleton
public class TaskProgress extends Common {

  @FXML
  private Button buttonControl;

  @FXML
  private Label stepControl;

  @FXML
  private ProgressBar progressControl;

  private void reset() {
    unbindFromTask();

    stepControl.setText("Starting ...");
    setNodeErrorState(progressControl, false);
    progressControl.setProgress(0);

    setButtonState("Cancel");
  }

  private void bindToTask(Task<Void> task) {
    progressControl.progressProperty().bind(task.progressProperty());
    stepControl.textProperty().bind(task.messageProperty());
  }

  private void unbindFromTask() {
    stepControl.textProperty().unbind();
    progressControl.progressProperty().unbind();
  }

  private void setButtonState(String label) {
    buttonControl.setText(label);
    buttonControl.setDisable(false);
  }

  /**
   * Starts a task while showing the stage with progress information.
   *
   * <p>The form supports cancelling (aborting) of the underlying task.</p>
   *
   * @param task Task to execute.
   */
  public void runTask(Task<Void> task) {
    reset();

    bindToTask(task);

    buttonControl.setOnAction(event -> {
      if (task.isRunning()) {
        buttonControl.setDisable(true);
        task.cancel();
      } else {
        getStage().close();
      }
    });

    task.setOnSucceeded(event -> setButtonState("OK"));

    task.setOnCancelled(event -> {
      unbindFromTask();
      stepControl.setText("Cancelled.");
      setButtonState("OK");
    });

    task.setOnFailed(event -> {
      unbindFromTask();
      stepControl.setText(String.format("Failed: %s",
          api.resolveExceptionReason(task.getException())));
      progressControl.setProgress(1.0);
      setNodeErrorState(progressControl, true);
      setButtonState("OK");
    });

    getStage().setOnShown(event ->
        new Thread(task).start());

    getStage().show();
  }
}
