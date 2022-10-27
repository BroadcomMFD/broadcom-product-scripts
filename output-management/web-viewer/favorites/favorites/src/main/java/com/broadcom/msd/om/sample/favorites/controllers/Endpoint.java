package com.broadcom.msd.om.sample.favorites.controllers;

import com.google.inject.Singleton;
import java.net.URL;
import java.util.Optional;
import java.util.ResourceBundle;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import lombok.NonNull;
import org.apache.commons.validator.routines.UrlValidator;

/**
 * Stage for configuring the API endpoint URL.
 */
@Singleton
public class Endpoint extends Common implements Initializable {

  private static final UrlValidator URL_VALIDATOR = new UrlValidator(new String[]{"http", "https"});

  @FXML
  private TextField urlControl;

  @FXML
  private Button okControl;

  private Runnable onConfigured;

  @FXML
  public void submit() {
    if (!isInputValid()) {
      return;
    }

    final String appUrl = getUrl();
    configuration.setUrl(appUrl);

    api.getApiClient().setBasePath(
        appUrl.endsWith("/api")
            ? appUrl
            : appUrl + "/api");

    closeStage();
    onConfigured.run();
  }

  @FXML
  private void refreshButtons() {
    okControl.setDisable(!isInputValid());
  }

  private String getUrl() {
    return urlControl.getText();
  }

  private void setUrl(String url) {
    urlControl.setText(Optional.ofNullable(url).orElse(""));
  }

  private boolean isInputValid() {
    return URL_VALIDATOR.isValid(getUrl());
  }

  @Override
  public void initialize(URL location, ResourceBundle resources) {
    setUrl(configuration.getUrl());

    refreshButtons();
  }

  /**
   * Runs the stage.
   *
   * <p>The user is queried for a URL of the Web Viewer instance.</p>
   *
   * <p>On success the stage stores the endpoint URL into configuration and sets the basePath for
   * the shared {@link org.openapitools.client.ApiClient} instance.</p>
   *
   * @param onConfigured Callback executed if the endpoint URL configuration is set.
   */
  public void configure(@NonNull Runnable onConfigured) {
    this.onConfigured = onConfigured;
    getStage().show();
  }
}
