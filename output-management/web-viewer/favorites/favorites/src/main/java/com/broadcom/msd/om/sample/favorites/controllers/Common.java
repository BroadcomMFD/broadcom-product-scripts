package com.broadcom.msd.om.sample.favorites.controllers;

import com.broadcom.msd.om.sample.favorites.api.Api;
import com.broadcom.msd.om.sample.favorites.configuration.ApplicationConfiguration;
import com.google.inject.Inject;
import java.util.Optional;
import java.util.function.Consumer;
import javafx.application.Platform;
import javafx.collections.ObservableList;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.geometry.Pos;
import javafx.scene.Node;
import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ProgressIndicator;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;
import javafx.stage.Modality;
import javafx.stage.Stage;
import lombok.extern.slf4j.Slf4j;

/**
 * Base class for all UI stage controllers providing various utility functions.
 *
 * <p>NB: Any controller that inherits from this class must be based on a form that has a
 * {@link StackPane} at the top of its hierarchy with a fx:id value "root" (see {@link #root}).</p>
 */
@Slf4j
public abstract class Common {
  private static final String STYLE_ERROR_CLASS = "error";

  @Inject
  protected ApplicationConfiguration configuration;

  @Inject
  protected Api api;

  @FXML
  private StackPane root;

  protected static void setNodeErrorState(Node node, boolean error) {
    final ObservableList<String> classes = node.getStyleClass();
    if (!error) {
      classes.removeAll(STYLE_ERROR_CLASS);
    } else if (!classes.contains(STYLE_ERROR_CLASS)) {
      classes.add(STYLE_ERROR_CLASS);
    }
  }

  /**
   * Close the stage.
   */
  protected void closeStage() {
    Platform.runLater(() -> getStage().close());
  }

  protected Stage getStage() {
    return (Stage) root.getScene().getWindow();
  }

  /**
   * Shows a simple modal alert dialog.
   *
   * @param alertType Type of alert.
   * @param title Dialog title.
   * @param message Alert message.
   * @return The button used to dismiss the dialog.
   */
  protected Optional<ButtonType> showAlert(Alert.AlertType alertType, String title,
      String message) {
    Alert alert = new Alert(alertType);
    alert.initOwner(getStage());
    alert.initModality(Modality.WINDOW_MODAL);
    alert.setTitle(title);
    alert.setHeaderText(null);
    alert.setContentText(message);

    return alert.showAndWait();
  }

  /**
   * Runs an asynchronous task while showing a busy indicator over the entire stage UI.
   *
   * <p>During the task execution all the stage controls are disabled and all are re-enabled once
   * done. The logic does not try restore the original node enable states and if important, the
   * caller must take care of that.</p>
   *
   * @param operation Label for the executed task.
   * @param task Task to execute.
   * @param onDone Optional function executed when done.
   * @param <T> Task type.
   */
  protected <T> void runTask(String operation, Task<T> task, Consumer<Boolean> onDone) {
    final ProgressIndicator progress = new ProgressIndicator();
    final VBox box = new VBox(progress);
    box.setAlignment(Pos.CENTER);

    final Consumer<Boolean> restore = success -> {
      root.getChildren().remove(box);
      root.getChildren().forEach(node -> node.setDisable(false));
      if (onDone != null) {
        onDone.accept(success);
      }
    };

    task.setOnSucceeded(event -> restore.accept(true));

    task.setOnCancelled(event -> restore.accept(false));

    task.setOnFailed(event -> {
      final Throwable exception = task.getException();
      final String title = String.format("Failed to %s", operation);
      final String reason = api.resolveExceptionReason(task.getException());

      log.debug(String.format("%s: %s", title, reason), exception);
      showAlert(AlertType.ERROR, title, reason);

      restore.accept(false);
    });

    root.getChildren().forEach(node -> node.setDisable(true));
    root.getChildren().add(box);
    new Thread(task).start();
  }
}
