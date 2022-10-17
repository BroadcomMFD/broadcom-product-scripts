package com.broadcom.msd.om.sample.favorites;

import com.broadcom.msd.om.sample.favorites.controllers.Main;
import com.google.inject.Guice;
import javafx.application.Application;
import javafx.stage.Stage;
import lombok.extern.slf4j.Slf4j;

/**
 * Minimal JavaFX Application launcher.
 *
 * <p>Separated from the {@link EntryPoint} to allow a non-module build (without making the
 * application itself modular).</p>
 */
@Slf4j
public class JavafxLauncher extends Application {

  @Override
  public void start(Stage primaryStage) {
    final Main mainController = Guice .createInjector(new InjectModule()) .getInstance(Main.class);

    if (mainController == null) {
      log.error("Failed to instantiate main controller");
      return;
    }

    mainController.start();
  }
}
