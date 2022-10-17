package com.broadcom.msd.om.sample.favorites.controllers;

import com.google.inject.Singleton;
import java.net.URL;
import java.util.Optional;
import java.util.ResourceBundle;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import lombok.NonNull;
import org.openapitools.client.ApiException;

/**
 * Stage for querying of user credentials and authenticating into Web Viewer.
 */
@Singleton
public class Login extends Common implements Initializable {

  @FXML
  public TextField usernameControl;

  @FXML
  public TextField passwordControl;

  @FXML
  public Button okControl;

  private Runnable onAuthenticated;

  @FXML
  private void submit() {
    if (!isInputValid()) {
      return;
    }

    configuration.setUsername(getUsername());

    runTask("authenticate", new Task<>() {
      @Override
      protected Void call() throws ApiException {
        api.login(getUsername(), getPassword());
        return null;
      }
    }, success -> {
      if (Boolean.TRUE.equals(success)) {
        closeStage();
        onAuthenticated.run();
      }
    });
  }

  @FXML
  private void refreshButtons() {
    okControl.setDisable(!isInputValid());
  }

  private String getUsername() {
    return usernameControl.getText();
  }

  private void setUsername(String username) {
    usernameControl.setText(Optional.ofNullable(username).orElse(""));
  }

  private String getPassword() {
    return passwordControl.getText();
  }

  private boolean isInputValid() {
    return !(getUsername().isEmpty() || getPassword().isEmpty());
  }

  @Override
  public void initialize(URL location, ResourceBundle resources) {
    setUsername(configuration.getUsername());

    refreshButtons();
  }

  /**
   * Runs the stage.
   *
   * <p>The user is queried for a username and secret (password, passphrase, mfa, ...) and the
   * information is used to authenticate against the configured Web Viewer instance.</p>
   *
   * <p>If authentication fails the stage remains open and the user can retry.</p>
   *
   * <p>On success the shared {@link org.openapitools.client.ApiClient} instance is configured
   * with the resulting session token (guid).</p>
   *
   * @param onAuthenticated Callback executed if the authentication is successful.
   */
  public void authenticate(@NonNull Runnable onAuthenticated) {
    this.onAuthenticated = onAuthenticated;

    getStage().show();
  }
}
