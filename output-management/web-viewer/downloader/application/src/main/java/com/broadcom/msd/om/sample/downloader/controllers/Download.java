package com.broadcom.msd.om.sample.downloader.controllers;

import static com.broadcom.msd.om.sample.downloader.configuration.ApplicationConfiguration.DOWNLOAD_DIRECTORY;
import static java.time.format.FormatStyle.SHORT;

import com.broadcom.msd.om.sample.downloader.api.Api;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.function.BiConsumer;
import java.util.stream.Collectors;
import javafx.application.Platform;
import javafx.beans.property.*;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.*;
import javafx.stage.FileChooser;
import javafx.stage.Stage;
import javafx.util.StringConverter;
import javafx.util.converter.LocalDateStringConverter;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.openapitools.client.ApiException;
import org.openapitools.client.model.*;
import org.openapitools.client.model.UserUpdateModel.ModeEnum;

@Slf4j
@Singleton
public class Download extends Common implements Initializable {

  private final NumberFormat numberFormat = DecimalFormat.getInstance();

  private final SimpleBooleanProperty formInputValid =
      new SimpleBooleanProperty(false);
  private final ObservableList<String> availableRepositories =
      FXCollections.observableList(new ArrayList<>());
  private final SimpleStringProperty repositoryName =
      new SimpleStringProperty();
  private final ObservableList<ModeEnum> allowedModes =
      FXCollections.observableList(new ArrayList<>());
  private final SimpleBooleanProperty distributionSupported =
      new SimpleBooleanProperty(false);
  private final SimpleObjectProperty<ModeEnum> mode =
      new SimpleObjectProperty<>();
  private final SimpleStringProperty distributionId =
      new SimpleStringProperty("");
  private final SimpleStringProperty nameFilter =
      new SimpleStringProperty("");
  private final SimpleObjectProperty<LocalDate> archivalFrom =
      new SimpleObjectProperty<>(LocalDate.now());
  private final SimpleObjectProperty<LocalDate> archivalTo =
      new SimpleObjectProperty<>(LocalDate.now());

  @Inject
  private TaskProgress taskProgress;

  @FXML
  private ComboBox<String> repositoryControl;
  @FXML
  private ChoiceBox<ModeEnum> modeControl;
  @FXML
  private TextField distributionControl;
  @FXML
  private TextField nameControl;
  @FXML
  private DatePicker archivalFromControl;
  @FXML
  private DatePicker archivalToControl;
  @FXML
  private Button downloadControl;
  @FXML
  private Button previewControl;

  private RepositoryUser repositoryUser;
  private List<Repository> repositoryMetadata;

  @FXML
  void onPreview() {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();
    if (repositoryId.isEmpty()) {
      return;
    }

    getDownloadableReports(repositoryId.get(), (success, reports) -> Platform.runLater(() -> {
      if (!Boolean.TRUE.equals(success)) {
        return;
      }

      String previewMessage;
      if (reports.isEmpty()) {
        previewMessage = "No matching reports found.";
      } else {
        final Statistics statistics = new Statistics(reports);
        previewMessage = String.format(
            "Found %s reports (%s unique) with a total of %s pages and %s records.",
            numberFormat.format(reports.size()),
            numberFormat.format(statistics.getUniqueReports()),
            numberFormat.format(statistics.getTotalPages()),
            numberFormat.format(statistics.getTotalLines()));
      }

      showAlert(AlertType.INFORMATION, "Preview result", previewMessage);
    }));
  }

  @FXML
  void onDownload() {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();
    if (repositoryId.isEmpty()) {
      return;
    }

    getDownloadableReports(repositoryId.get(), (success, reports) -> Platform.runLater(() -> {
      if (!Boolean.TRUE.equals(success)) {
        return;
      }

      if (reports.isEmpty()) {
        showAlert(AlertType.INFORMATION, "No reports", "No matching reports found.");
        return;
      }

      final File filePath = chooseTargetFile(reports.get(0).getReportID());
      if (filePath == null) {
        return; // Cancelled
      }

      taskProgress.runTask(new Task<>() {
        @Override
        protected Void call() throws Exception {
          final Statistics statistics = new Statistics(reports);

          long processedLines = 0;
          updateProgress(processedLines, statistics.getTotalLines());
          for (Report report : reports) {
            updateMessage(String.format("Downloading (%4.1f%%) ...",
                100f * processedLines / statistics.getTotalLines()));

            downloadReport(filePath.toPath(), repositoryId.get(), report, processedLines > 0);
            processedLines += Optional.ofNullable(report.getLines()).orElse(0);

            updateProgress(processedLines, statistics.getTotalLines());
          }

          updateMessage("All reports downloaded.");
          return null;
        }
      });
    }));
  }

  @FXML
  void onExit() {
    getStage().close();
  }

  private File chooseTargetFile(String reportName) {
    final String defaultFileName = String.format("%s.txt", reportName);
    final FileChooser fileChooser = new FileChooser();
    fileChooser.setTitle("Select download location and filename.");
    fileChooser.setInitialDirectory(DOWNLOAD_DIRECTORY.get());
    fileChooser.setInitialFileName(defaultFileName);

    File filePath;
    try {
      filePath = fileChooser.showSaveDialog(getStage());
    } catch (IllegalArgumentException e) {
      // Last used directory is no longer valid. Reset to default and re-try.
      DOWNLOAD_DIRECTORY.reset();
      filePath = chooseTargetFile(reportName);
    }

    if (filePath != null) {
      DOWNLOAD_DIRECTORY.set(filePath.getParentFile());
    }

    return filePath;
  }

  private void getDownloadableReports(int repositoryId, BiConsumer<Boolean, List<Report>> onDone) {
    runTask("get reports", new Task<>() {
      @Override
      protected List<Report> call() throws Exception {
        updateMessage("Updating mode ...");
        api.updateUserConfiguration(repositoryId, mode.get(),
            Api.modeSupportsDistribution(mode.get()) ? distributionId.get() : null);

        final Long fromTimestamp = archivalFrom.get() == null
            ? null
            : api.timeToEpoch(archivalFrom.get().atTime(LocalTime.MIN));
        final Long toTimestamp = archivalTo.get() == null
            ? null
            : api.timeToEpoch(archivalTo.get().atTime(LocalTime.MAX));

        updateMessage("Loading report metadata ...");
        return api.getDownloadableReports(repositoryId, nameFilter.get(), fromTimestamp,
            toTimestamp);
      }
    }, onDone);
  }

  private void downloadReport(Path targetFile, int repository, Report report, boolean append)
      throws ApiException, IOException {
    final Path temporaryFile = api.downloadReport(repository, report).toPath();

    try (FileChannel source = FileChannel.open(temporaryFile, StandardOpenOption.READ);
        FileChannel destination = FileChannel.open(targetFile, StandardOpenOption.CREATE,
            StandardOpenOption.WRITE,
            append ? StandardOpenOption.APPEND : StandardOpenOption.TRUNCATE_EXISTING)) {
      long bufferSize = 8192L;
      long size = source.size();
      long pos = 0L;
      long count;
      while (pos < size) {
        count = Math.min(size - pos, bufferSize);
        pos += source.transferTo(pos, count, destination);
      }
    }
  }

  private void validateForm() {
    formInputValid.set(isNameFilterValid()
        && getSelectedRepositoryId().isPresent());
  }

  private void validateNameFilter() {
    setNodeErrorState(nameControl, !isNameFilterValid());
  }

  private boolean isNameFilterValid() {
    if (nameControl.isDisable()) {
      return true;
    }

    final String name = nameFilter.get();
    return name == null || name.length() <= 32;
  }

  private void validateDistribution() {
    setNodeErrorState(distributionControl, !isDistributionValid());
  }

  private boolean isDistributionValid() {
    if (mode.get() == null) {
      return true;
    }

    final String distribution = distributionId.get();
    if (distribution == null || distribution.isEmpty() || distribution.length() > 8) {
      return false;
    }

    final String mask = Optional.ofNullable(repositoryUser.getMask()).orElse("*");
    if (mask.equals("*")) {
      return true;
    } else {
      final int wildcardIndex = mask.lastIndexOf("*");
      return distribution.startsWith(wildcardIndex == -1 ? mask : mask.substring(0, wildcardIndex));
    }
  }

  private Optional<Integer> getSelectedRepositoryId() {
    Objects.requireNonNull(repositoryMetadata);

    return repositoryMetadata.stream()
        .filter(candidate -> Objects.equals(candidate.getName(), repositoryName.get()))
        .map(Repository::getId)
        .filter(Objects::nonNull)
        .findFirst();
  }

  private void populateRepositoryList() {
    final Task<List<String>> getRepositories = new Task<>() {
      @Override
      protected List<String> call() throws ApiException {
        repositoryMetadata = api.getRepositories();
        return repositoryMetadata.stream()
            .map(Repository::getName)
            .collect(Collectors.toList());
      }
    };

    runTask("list repositories", getRepositories,
        (success, repositories) -> Platform.runLater(() -> {
          availableRepositories.clear();
          if (repositories != null) {
            availableRepositories.addAll(repositories);
          }

          // If user has access to exactly one repository, select it automatically.
          if (availableRepositories.size() == 1) {
            repositoryName.set(availableRepositories.get(0));
          }

          switch (availableRepositories.size()) {
            case 0:
              repositoryControl.setPromptText("No available repositories");
              // fall-through
            case 1:
              repositoryControl.setDisable(true);
              break;
            default:
              repositoryControl.setDisable(false);
              repositoryControl.setPromptText("");
              break;
          }
        }));
  }

  private void refreshMode() {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();
    if (repositoryId.isEmpty()) {
      return;
    }

    final Task<RepositoryUser> task = new Task<>() {
      @Override
      protected RepositoryUser call() throws Exception {
        return api.getUserConfiguration(repositoryId.get());
      }
    };

    runTask("get user mode", task, (success, repositoryUser) -> Platform.runLater(() -> {
      this.repositoryUser = repositoryUser;
      allowedModes.clear();

      if (Boolean.TRUE.equals(success)) {
        if (repositoryUser != null) {
          allowedModes.addAll(Api.getAllowedModes(repositoryUser));
          mode.set(Api.mapMode(repositoryUser.getMode()));
          distributionId.set(repositoryUser.getDist());
        }

        validateDistribution();
      } else { // If mode refresh fails, reset repository selection.
        repositoryName.set(null);
      }

      modeControl.setDisable(allowedModes.size() <= 1);
    }));
  }

  @Override
  public void initialize(URL location, ResourceBundle resources) {
    repositoryControl.itemsProperty()
        .bind(new SimpleListProperty<>(availableRepositories));
    repositoryControl.valueProperty().bindBidirectional(repositoryName);
    repositoryName.addListener((observable, oldValue, newValue) -> {
      refreshMode();
      validateForm();
    });

    modeControl.itemsProperty()
        .bind(new SimpleListProperty<>(allowedModes));
    modeControl.valueProperty().bindBidirectional(mode);
    mode.addListener((options, old, value) -> {
      // If Dist ID mask has no wildcard it can not be modified.
      final boolean wildcardMask = Optional.ofNullable(repositoryUser.getMask()).orElse("")
          .contains("*");
      distributionSupported.set(Api.modeSupportsDistribution(mode.get()) && wildcardMask);
    });

    distributionControl.textProperty().bindBidirectional(distributionId);
    distributionControl.disableProperty().bind(distributionSupported.not());
    distributionId.addListener((observable, oldValue, newValue) -> {
      validateDistribution();
      validateForm();
    });

    nameControl.textProperty().bindBidirectional(nameFilter);
    nameFilter.addListener((observable, oldValue, newValue) -> {
      validateNameFilter();
      validateForm();
    });

    // On bad input we want the date value to be null instead of the last good value.
    final StringConverter<LocalDate> dateConverter = new LocalDateStringConverter(SHORT) {
      @Override
      public LocalDate fromString(String string) {
        try {
          return super.fromString(string);
        } catch (DateTimeParseException e) {
          return null;
        }
      }
    };

    archivalFromControl.setConverter(dateConverter);
    archivalFromControl.valueProperty().bindBidirectional(archivalFrom);
    archivalFrom.addListener((observable, oldValue, newValue) -> {
      if (newValue != null && archivalTo.get() != null && archivalTo.get().isBefore(newValue)) {
        archivalTo.set(newValue);
      }
    });

    archivalToControl.setConverter(dateConverter);
    archivalToControl.valueProperty().bindBidirectional(archivalTo);
    archivalTo.addListener((observable, oldValue, newValue) -> {
      if (newValue != null && archivalFrom.get() != null && archivalFrom.get().isAfter(newValue)) {
        archivalFrom.set(newValue);
      }
    });

    downloadControl.disableProperty().bind(formInputValid.not());
    previewControl.disableProperty().bind(formInputValid.not());
  }

  public void open() {
    populateRepositoryList();

    final Stage stage = getStage();
    stage.setTitle("Download Reports");
    stage.show();
  }
}

/**
 * Helper class for report list statistics.
 */
@Getter
class Statistics {

  private final long uniqueReports;
  private final long totalPages;
  private final long totalLines;

  public Statistics(List<Report> reports) {
    uniqueReports = reports.stream()
        .map(Report::getReportID)
        .filter(Objects::nonNull)
        .distinct()
        .count();

    totalPages = reports.stream()
        .map(Report::getPages)
        .filter(Objects::nonNull)
        .map(Long::valueOf)
        .reduce(0L, Long::sum);

    totalLines = reports.stream()
        .map(Report::getLines)
        .filter(Objects::nonNull)
        .map(Long::valueOf)
        .reduce(0L, Long::sum);
  }
}
