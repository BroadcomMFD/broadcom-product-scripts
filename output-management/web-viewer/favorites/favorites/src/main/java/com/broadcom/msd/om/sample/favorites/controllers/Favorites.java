package com.broadcom.msd.om.sample.favorites.controllers;

import com.broadcom.msd.om.sample.favorites.configuration.Favorite;
import com.google.common.io.Files;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.ResourceBundle;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ComboBox;
import org.openapitools.client.ApiException;
import org.openapitools.client.model.Report;

@Singleton
public class Favorites extends Common implements Initializable {
  private static final String PDF_EXTENSION = "pdf";
  private static final String TEXT_EXTENSION = "txt";

  private final SimpleDateFormat dateTimeFormatter = new SimpleDateFormat("yyyy-MM-dd-HH-mm");

  @Inject
  private DefineFavorite defineFavorite;

  @Inject
  private TaskProgress taskProgress;

  @FXML
  private Button deleteControl;

  @FXML
  private Button editControl;

  @FXML
  private Button executeControl;

  @FXML
  private ComboBox<String> listControl;

  @FXML
  void exit() {
    closeStage();
  }

  @FXML
  void createFavorite() {
    defineFavorite.createFavorite(favorite -> {
      if (favorite != null) {
        configuration.saveFavorite(favorite, false);
        Platform.runLater(this::refreshFavoriteList);
      }
    });
  }

  @FXML
  void editFavorite() {
    defineFavorite.editFavorite(getSelectedFavorite(), favorite -> {
      if (favorite != null) {
        configuration.saveFavorite(favorite, true);
      }
    });
  }

  @FXML
  void deleteFavorite() {
    Optional<ButtonType> result = showAlert(AlertType.CONFIRMATION,
        "Confirm",
        String.format("Are you sure you want to delete '%s' ?", getSelectedFavoriteName()));

    if (result.isPresent() && result.get() == ButtonType.OK) {
      configuration.deleteFavorite(getSelectedFavoriteName());
      refreshFavoriteList();
    }
  }

  @FXML
  void executeFavorite() {
    final Task<Void> task = new Task<>() {
      @Override
      protected Void call() throws Exception {
        final Favorite favorite = getSelectedFavorite();
        if (favorite == null) {
          throw new TaskFailureException("Failed to load favorite data.");
        }

        long processedReports = 0;

        updateMessage("Updating mode ...");
        api.updateUserConfiguration(favorite.getRepository(), favorite.getMode(),
            favorite.getDistributionId());

        updateMessage("Loading report metadata ...");
        final List<Report> reports = new ArrayList<>();
        for (String reportName : favorite.getReports()) {
          reports.addAll(api.getLatestReportVersions(
              favorite.getRepository(), reportName, favorite.getLatestVersions()));
        }

        if (reports.isEmpty()) {
          throw new TaskFailureException("No matching reports found.");
        }

        updateProgress(0, reports.size());
        for (Report report : reports) {
          updateMessage(String.format("Downloading %s (%d:%d) ...",
              report.getReportID(), report.getGen(), report.getSeqNum()));
          downloadReport(favorite, report);
          updateProgress(++processedReports, reports.size());
        }

        updateMessage("All reports downloaded.");

        return null;
      }
    };

    task.setOnFailed(event -> {
    });

    taskProgress.runTask(task);
  }

  private void downloadReport(Favorite favorite, Report report) throws ApiException, IOException {
    final String reportName = report.getReportID();
    final String archivalDate = formatArchivalDate(report);

    final Path temporary = api.downloadReport(
        favorite.getRepository(), report, favorite.isPdf()).toPath();

    final String extension = favorite.isPdf() ? PDF_EXTENSION : TEXT_EXTENSION;
    Path target;
    if (favorite.isCombine()) {
      target = Paths.get(String.format("%s.%s", favorite.getName(), extension));
    } else {
      target = Paths.get(String.format("%s-%s.%s", reportName, archivalDate, extension));
    }

    if (favorite.isCombine()) {
      try (FileChannel source = FileChannel.open(temporary, StandardOpenOption.READ);
          FileChannel destination = FileChannel.open(target, StandardOpenOption.CREATE,
              StandardOpenOption.APPEND)) {
        long bufferSize = 8192L;
        long size = source.size();
        long pos = 0L;
        long count;
        while (pos < size) {
          count = Math.min(size - pos, bufferSize);
          pos += source.transferTo(pos, count, destination);
        }
      }
    } else {
      Files.move(temporary.toFile(), target.toFile());
    }
  }

  private String formatArchivalDate(Report report) {
    final Date dateTime = new Date(Optional.ofNullable(report.getArchDT()).orElse(0L));
    return dateTimeFormatter.format(dateTime);
  }

  private Favorite getSelectedFavorite() {
    return configuration.loadFavorite(getSelectedFavoriteName());
  }

  private String getSelectedFavoriteName() {
    return listControl.getValue();
  }

  void favoriteSelected() {
    refreshButtons();
  }

  public void refreshButtons() {
    for (Button button : Arrays.asList(executeControl, editControl, deleteControl)) {
      button.setDisable(getSelectedFavoriteName() == null);
    }
  }

  public void refreshFavoriteList() {
    final Task<List<String>> listFavorites = new Task<>() {
      @Override
      protected List<String> call() {
        return configuration.listFavoriteNames();
      }
    };

    runTask("list favorites", listFavorites, success -> {
      if (!Boolean.TRUE.equals(success)) {
        return;
      }

      final List<String> favoriteNames = listFavorites.getValue();
      listControl.setValue(null);
      listControl.setItems(FXCollections.observableList(favoriteNames));
      listControl.setDisable(favoriteNames.isEmpty());

      refreshButtons();
    });
  }

  @Override
  public void initialize(URL location, ResourceBundle resources) {
    listControl.getSelectionModel().selectedItemProperty()
        .addListener((options, old, value) -> favoriteSelected());
  }

  public void openMenu() {
    refreshFavoriteList();

    getStage().show();
  }
}
