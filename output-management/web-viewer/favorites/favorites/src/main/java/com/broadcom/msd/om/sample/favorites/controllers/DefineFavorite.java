package com.broadcom.msd.om.sample.favorites.controllers;

import com.broadcom.msd.om.sample.favorites.api.Api;
import com.broadcom.msd.om.sample.favorites.api.SimpleApiException;
import com.broadcom.msd.om.sample.favorites.configuration.Favorite;
import com.google.inject.Singleton;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.ResourceBundle;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import javafx.application.Platform;
import javafx.beans.property.SimpleListProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.collections.transformation.FilteredList;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.ComboBox;
import javafx.scene.control.ListView;
import javafx.scene.control.SelectionMode;
import javafx.scene.control.Spinner;
import javafx.scene.control.SpinnerValueFactory.IntegerSpinnerValueFactory;
import javafx.scene.control.TextField;
import lombok.Synchronized;
import org.openapitools.client.ApiException;
import org.openapitools.client.model.Repository;
import org.openapitools.client.model.RepositoryUser;
import org.openapitools.client.model.UserUpdateModel.ModeEnum;

/**
 * Stage for defining a {@link Favorite}.
 *
 * <p>Supports creating ({@link #createFavorite(Consumer)})</p> and editing
 * ({@link #editFavorite(Favorite, Consumer)}) of favorite entries.</p>
 */
@Singleton
public class DefineFavorite extends Common implements Initializable {

  private final ObservableList<String> availableRepositories =
      FXCollections.observableList(new ArrayList<>());
  private final ObservableList<String> availableReports =
      FXCollections.observableList(new ArrayList<>());
  private final FilteredList<String> matchingReports =
      new FilteredList<>(availableReports, r -> true);
  private final ObservableList<ModeEnum> allowedModes =
      FXCollections.observableList(new ArrayList<>());

  @FXML
  private TextField nameControl;
  @FXML
  private ChoiceBox<ModeEnum> modeControl;
  @FXML
  private TextField distributionControl;
  @FXML
  private Button applyControl;
  @FXML
  private ComboBox<String> repositoryControl;
  @FXML
  private TextField filterControl;
  @FXML
  private ListView<String> reportsControl;
  @FXML
  private Spinner<Integer> versionsControl;
  @FXML
  private CheckBox combineControl;
  @FXML
  private CheckBox pdfControl;
  @FXML
  private Button saveControl;

  private RepositoryUser repositoryUser;
  private List<Repository> repositoryMetadata;
  private Consumer<Favorite> onSaveHandler;
  private boolean suppressUiHandlers = false;

  @FXML
  void save() {
    if (!isInputComplete()) {
      return;
    }

    callSaveHandlers();
    getStage().close();
  }

  @FXML
  void cancel() {
    getStage().close();
  }

  @FXML
  void apply() {
    applyMode(success -> {
      if (Boolean.TRUE.equals(success)) {
        refreshReportsList(null);
      }
    });
  }

  @FXML
  void filterChanged() {
    matchingReports.setPredicate(report ->
        report.toLowerCase().contains(
            Optional.ofNullable(getFilter()).orElse("").toLowerCase()));
  }

  @FXML
  void refreshCheckboxes() {
    if (isCombine()) {
      setPdf(false);
      combineControl.setDisable(false);
      pdfControl.setDisable(true);
    } else if (isPdf()) {
      setCombine(false);
      combineControl.setDisable(true);
      pdfControl.setDisable(false);
    } else {
      combineControl.setDisable(false);
      pdfControl.setDisable(false);
    }
  }

  private Favorite buildFavorite() {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();

    if (isInputComplete() && repositoryId.isPresent()) {
      return new Favorite(repositoryId.get(), getMode(),
          Api.modeSupportsDistribution(getMode()) ? getDistributionId() : null,
          getSelectedReports(), getLatestVersions(), isCombine(), isPdf(), getName());
    } else {
      return null;
    }
  }

  @Synchronized
  private void callSaveHandlers() {
    if (onSaveHandler != null) {
      onSaveHandler.accept(buildFavorite());
      onSaveHandler = null;
    }
  }

  private void onRepositorySelected() {
    if (!suppressUiHandlers) {
      refreshMode(null);
      refreshReportsList(null);
    }

    refreshButtons();
  }

  private void onModeSelected() {
    if (!suppressUiHandlers) {
      final boolean distributionSupported = Api.modeSupportsDistribution(getMode());
      distributionControl.setDisable(!distributionSupported);
      if (!distributionSupported) {
        setDistributionId(repositoryUser.getDist());
      }
    }

    refreshButtons();
  }

  private void onReportSelected() {
    refreshButtons();
  }

  private void refreshButtons() {
    saveControl.setDisable(!isInputComplete());

    if (repositoryUser == null) {
      applyControl.setDisable(true);
    } else {
      final boolean modeChanged = !repositoryUser.getDist().equalsIgnoreCase(getDistributionId())
          || Api.mapMode(repositoryUser.getMode()) != getMode();

      applyControl.setDisable(!isDistributionValid() || !modeChanged);
    }
  }

  private void validateName() {
    setNodeErrorState(nameControl, !isNameValid());
  }

  private boolean isNameValid() {
    if (nameControl.isDisable()) {
      return true;
    }

    final String name = getName();
    if (name == null || name.isEmpty() || name.length() > 100) {
      return false;
    }

    return !configuration.listFavoriteNames().contains(name)
        && Favorite.NAME_PATTERN.matcher(name).matches();
  }

  private void validateDistribution() {
    setNodeErrorState(distributionControl, !isDistributionValid());
  }

  private boolean isDistributionValid() {
    final String distribution = getDistributionId();

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

  private boolean isInputComplete() {
    return isNameValid() && getSelectedRepositoryId().isPresent()
        && !getSelectedReports().isEmpty();
  }

  private String getName() {
    return nameControl.getText();
  }

  private void setName(String value) {
    nameControl.setText(value);
  }

  private ModeEnum getMode() {
    return modeControl.getValue();
  }

  private void setMode(ModeEnum mode) {
    modeControl.setValue(mode);
  }

  private String getDistributionId() {
    return distributionControl.getText();
  }

  private void setDistributionId(String distributionId) {
    distributionControl.setText(distributionId);
  }

  private String getFilter() {
    return filterControl.getText();
  }

  private void setFilter(String filter) {
    filterControl.setText(filter);
  }

  private int getLatestVersions() {
    return versionsControl.getValue();
  }

  private void setLatestVersions(int latestVersions) {
    versionsControl.getValueFactory().setValue(latestVersions);
  }

  private boolean isCombine() {
    return combineControl.isSelected();
  }

  private void setCombine(boolean value) {
    combineControl.setSelected(value);
  }

  private boolean isPdf() {
    return pdfControl.isSelected();
  }

  private void setPdf(boolean value) {
    pdfControl.setSelected(value);
  }

  private <T> void refreshList(String operation, Task<List<T>> task, ObservableList<T> list,
      Node control, Runnable onDone) {
    runTask(operation, task, success -> Platform.runLater(() -> {
      list.clear();
      final List<T> data = task.getValue();
      if (data != null) {
        list.addAll(data);
      }
      control.setDisable(list.isEmpty());

      if (onDone != null) {
        onDone.run();
      }
    }));
  }

  private void refreshRepositoryList(Runnable onDone) {
    final Task<List<String>> task = new Task<>() {
      @Override
      protected List<String> call() throws ApiException {
        repositoryMetadata = api.getRepositories();
        return repositoryMetadata.stream()
            .map(Repository::getName)
            .collect(Collectors.toList());
      }
    };

    refreshList("list repositories", task, availableRepositories, repositoryControl, onDone);
  }

  private void refreshReportsList(Runnable onDone) {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();
    if (repositoryId.isEmpty()) {
      return;
    }

    final Task<List<String>> task = new Task<>() {
      @Override
      protected List<String> call() throws ApiException, SimpleApiException {
        return api.getActionableReportNames(repositoryId.get());
      }
    };

    refreshList("list reports", task, availableReports, reportsControl, () -> {
      filterControl.setDisable(reportsControl.isDisable());

      if (onDone != null) {
        onDone.run();
      }
    });
  }

  private void refreshMode(Runnable onDone) {
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

    runTask("get user mode", task, success -> Platform.runLater(() -> {
      if (Boolean.TRUE.equals(success)) {
        repositoryUser = task.getValue();
        if (repositoryUser != null) {
          allowedModes.clear();
          allowedModes.addAll(Api.getAllowedModes(repositoryUser));
          setMode(Api.mapMode(repositoryUser.getMode()));
          modeControl.setDisable(allowedModes.isEmpty());

          setDistributionId(repositoryUser.getDist());
        }
      }

      validateDistribution();

      if (onDone != null) {
        onDone.run();
      }
    }));
  }

  private void applyMode(Consumer<Boolean> onDone) {
    final Optional<Integer> repositoryId = getSelectedRepositoryId();
    if (repositoryId.isEmpty()) {
      return;
    }

    applyMode(repositoryId.get(), getMode(), getDistributionId(), onDone);
  }

  private void applyMode(int repositoryId, ModeEnum mode, String distribution, Consumer<Boolean> onDone) {
    final Task<Void> task = new Task<>() {
      @Override
      protected Void call() throws Exception {
        api.updateUserConfiguration(repositoryId, mode, distribution);
        return null;
      }
    };

    runTask("update user mode", task,
        success -> Platform.runLater(() -> refreshMode(() -> onDone.accept(success)))
    );
  }

  private Optional<Integer> getSelectedRepositoryId() {
    Objects.requireNonNull(repositoryMetadata);

    return repositoryMetadata.stream()
        .filter(candidate -> Objects.equals(candidate.getName(), repositoryControl.getValue()))
        .map(Repository::getId)
        .filter(Objects::nonNull)
        .findFirst();
  }

  private List<String> getSelectedReports() {
    return reportsControl.getSelectionModel().getSelectedItems();
  }

  @Override
  public void initialize(URL location, ResourceBundle resources) {
    nameControl.setOnKeyTyped(event -> {
      validateName();
      refreshButtons();
    });

    repositoryControl.itemsProperty().bind(new SimpleListProperty<>(availableRepositories));
    repositoryControl.getSelectionModel().selectedItemProperty()
        .addListener((options, old, value) -> onRepositorySelected());

    modeControl.itemsProperty().bind(new SimpleListProperty<>(allowedModes));
    modeControl.getSelectionModel().selectedItemProperty()
        .addListener((options, old, value) -> onModeSelected());
    distributionControl.setOnKeyTyped(event -> {
      validateDistribution();
      refreshButtons();
    });

    reportsControl.itemsProperty().bind(new SimpleListProperty<>(matchingReports));
    reportsControl.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE);
    reportsControl.getSelectionModel().selectedItemProperty()
        .addListener((options, old, value) -> onReportSelected());

    versionsControl.setValueFactory(new IntegerSpinnerValueFactory(1, 20, 1));
  }

  private boolean selectRepository(int selected) {
    repositoryControl.setValue(null);
    Optional<Repository> selectedRepository = repositoryMetadata.stream()
        .filter(repository -> repository.getId() != null)
        .filter(repository -> repository.getId() == selected)
        .findFirst();

    selectedRepository.ifPresent(
        value -> repositoryControl.getSelectionModel().select(value.getName()));

    return selectedRepository.isPresent();
  }

  private void selectReports(List<String> selected) {
    reportsControl.getSelectionModel().clearSelection();
    selected.forEach(name -> reportsControl.getSelectionModel().select(name));
  }

  private void reset() {
    setName("");
    nameControl.setDisable(false);
    setNodeErrorState(nameControl, false);

    availableRepositories.clear();
    repositoryControl.setDisable(true);

    allowedModes.clear();
    modeControl.setDisable(true);

    setDistributionId("");
    distributionControl.setDisable(true);
    setNodeErrorState(distributionControl, false);

    setFilter("");
    filterControl.setDisable(true);
    availableReports.clear();
    reportsControl.setDisable(true);

    setLatestVersions(1);

    setCombine(false);
    combineControl.setDisable(false);

    setPdf(false);
    pdfControl.setDisable(false);

    onSaveHandler = null;
    suppressUiHandlers = false;

    refreshButtons();
  }

  /**
   * Runs the stage in creation mode - starting with an empty form.
   *
   * @param onSave Callback that receives the created favorite instance.
   */
  public void createFavorite(Consumer<Favorite> onSave) {
    reset();

    getStage().setTitle("Create Favorite");

    refreshRepositoryList(null);

    onSaveHandler = onSave;

    getStage().show();
  }

  /**
   * Runs the stage in edit mode - starting with the state of a preexisting favorite.
   *
   * <p>All form fields except the name are editable.</p>
   *
   * @param original Original favorite instance. This instance is not modified.
   * @param onSave Callback that receives the edited favorite instance.
   */
  public void editFavorite(Favorite original, Consumer<Favorite> onSave) {
    reset();

    getStage().setTitle("Edit Favorite");

    onSaveHandler = onSave;

    suppressUiHandlers = true;

    setName(original.getName());
    nameControl.setDisable(true);
    setLatestVersions(original.getLatestVersions());
    combineControl.setSelected(original.isCombine());
    pdfControl.setSelected(original.isPdf());

    refreshCheckboxes();

    final Runnable setOriginalReports = () -> refreshReportsList(() -> {
      selectReports(original.getReports());
      suppressUiHandlers = false;
    });

    final Runnable setOriginalMode = () -> applyMode(
        original.getRepository(), original.getMode(), original.getDistributionId(), success -> {
          if (Boolean.TRUE.equals(success)) {
            setOriginalReports.run();
          } else {
            suppressUiHandlers = false;
          }
        });

    final Runnable setOriginalRepository = () -> refreshRepositoryList(() -> {
      if (selectRepository(original.getRepository())) {
        setOriginalMode.run();
      } else {
        suppressUiHandlers = false;
      }
    });

    setOriginalRepository.run();

    getStage().show();
  }
}
