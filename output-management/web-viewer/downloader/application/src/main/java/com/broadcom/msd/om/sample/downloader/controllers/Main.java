package com.broadcom.msd.om.sample.downloader.controllers;

import com.google.inject.Inject;
import com.google.inject.Injector;
import java.io.IOException;
import java.net.URL;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;

/**
 * Main application controller.
 *
 * <p>Takes care of preparing all the relevant application UI stages and takes care of running the
 * top-level of the application UX (see {@link #start()}}.</p>
 */
public class Main {

  private static final String STYLES_FILE = "/styles.css";
  private static final String TASK_PROGRESS_FORM = "/forms/TaskProgress.fxml";
  private static final String ENDPOINT_FORM = "/forms/Endpoint.fxml";
  private static final String LOGIN_FORM = "/forms/Login.fxml";
  private static final String DOWNLOAD_FORM = "/forms/Download.fxml";

  private final Endpoint endpoint;
  private final Login login;
  private final Download download;

  @Inject
  public Main(Injector injector) throws IOException {
    final URL stylesUrl = getClass().getResource(STYLES_FILE);
    if (stylesUrl == null) {
      throw new IllegalStateException("Unable to load styles resource.");
    }

    prepareStage(injector, TASK_PROGRESS_FORM, "Progress", true, stylesUrl);
    endpoint = prepareStage(injector, ENDPOINT_FORM, "Web Viewer - URL", false, stylesUrl);
    login = prepareStage(injector, LOGIN_FORM, "Web Viewer - Login", false, stylesUrl);
    download = prepareStage(injector, DOWNLOAD_FORM, "Web Viewer - Download", false, stylesUrl);
  }

  /**
   * Prepares a stage.
   *
   * @param injector Injector instance.
   * @param form Form resource file (FXML).
   * @param title Title text.
   * @param modal {@code true} if the stage should be modal.
   * @param stylesUrl Optional URL of a style file to be attached to the scene.
   * @param <T> Controller type.
   * @return Controller instance for the created stage.
   * @throws IOException If loading any of the resource files fails.
   */
  private <T> T prepareStage(Injector injector, String form, String title, boolean modal, URL stylesUrl) throws IOException {
    final FXMLLoader loader = new FXMLLoader(getClass().getResource(form));
    // Make sure controller creation is done through the dependency injector.
    loader.setControllerFactory(injector::getInstance);

    final Scene scene = new Scene(loader.load());
    if (stylesUrl != null) {
      scene.getStylesheets().add(stylesUrl.toExternalForm());
    }

    final Stage stage = new Stage();
    stage.setTitle(title);
    stage.setScene(scene);
    if (modal) {
      stage.initModality(Modality.APPLICATION_MODAL);
    }

    return loader.getController();
  }

  /**
   * Starts the application UI.
   */
  public void start() {
    endpoint.configure(() ->
        login.authenticate(
            download::open));
  }
}
