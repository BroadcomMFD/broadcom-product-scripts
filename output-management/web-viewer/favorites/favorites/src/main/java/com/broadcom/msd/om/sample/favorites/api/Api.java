package com.broadcom.msd.om.sample.favorites.api;

import static org.openapitools.client.model.RepositoryUserUpdateResponse.StatusEnum.ERROR;

import com.broadcom.msd.om.sample.favorites.Utilities;
import com.broadcom.msd.om.sample.favorites.configuration.ApplicationConfiguration;
import com.google.gson.Gson;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.openapitools.client.ApiClient;
import org.openapitools.client.ApiException;
import org.openapitools.client.ApiResponse;
import org.openapitools.client.api.AuthenticationApi;
import org.openapitools.client.api.ReportActionsApi;
import org.openapitools.client.api.ReportsApi;
import org.openapitools.client.api.RepositoriesApi;
import org.openapitools.client.api.RepositoryUsersApi;
import org.openapitools.client.model.ErrorResponse;
import org.openapitools.client.model.LoginResponse;
import org.openapitools.client.model.Message;
import org.openapitools.client.model.Report;
import org.openapitools.client.model.Report.StatusEnum;
import org.openapitools.client.model.ReportListResponse;
import org.openapitools.client.model.ReportListResult;
import org.openapitools.client.model.Repository;
import org.openapitools.client.model.RepositoryListResponse;
import org.openapitools.client.model.RepositoryListResult;
import org.openapitools.client.model.RepositoryUser;
import org.openapitools.client.model.RepositoryUserListResponse;
import org.openapitools.client.model.RepositoryUserUpdateResponse;
import org.openapitools.client.model.UserListResult;
import org.openapitools.client.model.UserUpdateModel;
import org.openapitools.client.model.UserUpdateModel.ModeEnum;

/**
 * Provides a higher-level wrapper around the low-level API operations provided by the SDK module.
 */
@Slf4j
@Getter
@Singleton
public class Api {

  /**
   * List of supported modes in the order they appear in the user configuration mode flags.
   */
  private static final List<ModeEnum> modeFlagMap = Arrays.asList(
      ModeEnum.ALL, ModeEnum.EXPO, ModeEnum.EXP, ModeEnum.SARO, ModeEnum.SAR
  );

  private final ApiClient apiClient;
  private final Gson gson;
  private final ApplicationConfiguration configuration;

  @Inject
  public Api(ApiClient apiClient, Gson gson, ApplicationConfiguration configuration) {
    this.apiClient = apiClient;
    if (log.isTraceEnabled()) {
      apiClient.setDebugging(true);
    }
    this.gson = gson;
    this.configuration = configuration;
  }

  /**
   * Returns all modes allowed for the user based on user configuration data.
   *
   * @param user User configuration.
   * @return Allowed modes.
   */
  public static List<ModeEnum> getAllowedModes(RepositoryUser user) {
    final String modeFlags = Objects.requireNonNull(user.getAcc());

    final List<ModeEnum> allowedModes = new ArrayList<>();
    for (int i = 0; i < modeFlags.length(); ++i) {
      if (i < modeFlagMap.size() && modeFlags.charAt(i) == 'Y') {
        allowedModes.add(modeFlagMap.get(i));
      }
    }

    return allowedModes;
  }

  /**
   * Helper that maps between the different SDK Mode enums.
   *
   * @param from Source enum value.
   * @return Target enum value.
   */
  public static ModeEnum mapMode(RepositoryUser.ModeEnum from) {
    if (from == null) {
      return null;
    }
    return ModeEnum.fromValue(from.getValue());
  }

  /**
   * Identifies whether a mode supports distribution id customization.
   *
   * @param mode Mode.
   * @return {@code true} if mode supports distribution customization, {@code false} otherwise.
   */
  public static boolean modeSupportsDistribution(ModeEnum mode) {
    return mode == ModeEnum.EXP || mode == ModeEnum.SAR;
  }

  public String resolveExceptionReason(Throwable exception) {
    if (exception instanceof ApiException) {
      return getApiExceptionMessage((ApiException) exception);
    } else {
      return Utilities.resolveGenericExceptionReason(exception);
    }
  }

  /**
   * Extracts the most specific error message possible from an {@link ApiException}.
   *
   * @param apiException API Exception
   * @return Error message.
   */
  public String getApiExceptionMessage(ApiException apiException) {
    final ErrorResponse response = gson.fromJson(apiException.getResponseBody(),
        ErrorResponse.class);

    if (response != null && response.getMessage() != null) {
      return getApiMessage(response.getMessage());
    } else {
      return Utilities.resolveGenericExceptionReason(apiException);
    }
  }

  /**
   * Extracts the most specific error message possible from a list of API messages.
   *
   * @param messages List of messages.
   * @return Error message.
   */
  public String getApiMessage(List<Message> messages) {
    if (messages == null || messages.isEmpty() || messages.get(0) == null) {
      return null;
    }

    return Optional
        .ofNullable(messages.get(0).getLongText())
        .orElse(messages.get(0).getShortText());
  }

  /**
   * Executes a login against the Web Viewer instance and configures the API client to use the
   * resulting session token (guid).
   *
   * @param username Username.
   * @param password Password.
   * @throws ApiException If the API operation fails.
   */
  public void login(String username, String password) throws ApiException {
    apiClient.setUsername(username);
    apiClient.setPassword(password);

    try {
      log.debug("Logging in as user {}", username);

      final AuthenticationApi authenticationApi = new AuthenticationApi(apiClient);
      ApiResponse<LoginResponse> result = authenticationApi.loginWithHttpInfo(null, null);

      final String guid = result.getHeaders().get("guid").get(0);
      apiClient.setApiKey(guid);
    } finally {
      apiClient.setPassword(null);
    }
  }

  /**
   * Returns full list of repositories visible to the user.
   *
   * @return Repository list.
   * @throws ApiException If the API operation fails.
   */
  public List<Repository> getRepositories() throws ApiException {
    log.debug("Retrieving list of repositories.");

    final RepositoriesApi repositoriesApi = new RepositoriesApi(apiClient);
    final ApiResponse<RepositoryListResponse> result =
        repositoriesApi.listRepositoriesWithHttpInfo(null, null, null, Integer.MAX_VALUE, null);

    final Optional<RepositoryListResult> data = Optional.ofNullable(result.getData().getResult());
    if (data.isEmpty()) {
      throw new ApiException("Expected result property missing from repositories response.");
    }

    return data.get().getRepository();
  }

  /**
   * Obtains current user configuration for a specific repository (View database).
   *
   * @param repository Repository.
   * @return User configuration.
   * @throws ApiException If the API operation fails.
   */
  public RepositoryUser getUserConfiguration(int repository) throws ApiException, SimpleApiException {
    log.debug("Retrieving current user configuration from repository {}", repository);

    final RepositoryUsersApi userApi = new RepositoryUsersApi(apiClient);

    final ApiResponse<RepositoryUserListResponse> result =
        userApi.listRepositoryUsersWithHttpInfo(repository, configuration.getUsername(), null);

    final Optional<UserListResult> data = Optional.ofNullable(result.getData().getResult());
    if (data.isEmpty()) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected result property missing from user configuration response."));
    }

    final List<RepositoryUser> users = data.get().getUserData();
    if (users == null) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected users property missing from response data."));
    }

    if (users.isEmpty() || users.get(0) == null) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected user entry missing from response data."));
    }

    final RepositoryUser user = users.get(0);

    if (user.getAcc() == null || user.getMask() == null || user.getMode() == null) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected user properties missing from response data."));
    }

    return user;
  }

  /**
   * Updates user configuration within a repository (View database).
   *
   * @param repository Repository.
   * @param mode User mode.
   * @param distributionId User distribution id.
   * @throws ApiException If the API operation fails.
   * @throws SimpleApiException If the API operation fails.
   */
  public void updateUserConfiguration(int repository, ModeEnum mode, String distributionId)
      throws ApiException, SimpleApiException {
    log.debug("Updating user configuration for repository {} to {}:{}",
        repository, mode, distributionId);

    final RepositoryUsersApi userApi = new RepositoryUsersApi(apiClient);

    final UserUpdateModel update = new UserUpdateModel();
    update.setMode(mode);
    update.setDistId(distributionId);

    final ApiResponse<RepositoryUserUpdateResponse> result =
        userApi.updateRepositoryUserWithHttpInfo(repository, update);

    // The operation returns an OK HTTP status on certain errors.
    if (result.getData().getStatus() == ERROR) {
      final String apiMessage = getApiMessage(result.getData().getMessage());

      throw new SimpleApiException(
          Objects.requireNonNullElse(apiMessage, "Failed to update mode settings."));
    }
  }

  /**
   * Returns list of all accessible reports in a repository.
   *
   * @param repository Repository id.
   * @return List of reports.
   * @throws ApiException If the API operation fails.
   */
  private List<Report> getReports(int repository) throws ApiException, SimpleApiException {
    log.debug("Retrieving metadata for all reports in repository {}", repository);

    final ReportsApi reportsApi = new ReportsApi(apiClient);
    final ApiResponse<ReportListResponse> result =
        reportsApi.listReportsWithHttpInfo(repository, null, null, null, null, Integer.MAX_VALUE, null);

    final Optional<ReportListResult> data = Optional.ofNullable(result.getData().getResult());
    if (data.isEmpty()) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected result property missing from reports response."));
    }

    return data.get().getReportList();
  }

  /**
   * Returns a list of unique report names for online TEXT reports.
   *
   * @param repository Repository.
   * @return List of report names.
   * @throws ApiException If the API operation fails.
   */
  public List<String> getActionableReportNames(int repository) throws ApiException, SimpleApiException {
    log.debug("Retrieving names of actionable reports in repository {}", repository);

    return getReports(repository).stream()
        .filter(report -> report.getStatus() == StatusEnum.ONLINE)
        .filter(report -> "TEXT".equalsIgnoreCase(report.getType()))
        .map(Report::getReportID)
        .distinct()
        .collect(Collectors.toList());
  }

  /**
   * Returns metadata for a number of the latest versions of a report.
   *
   * @param repository Repository.
   * @param reportName Report name.
   * @param latestVersions Number of the latest versions to include.
   * @return List of report metadata.
   * @throws ApiException If the API operation fails.
   */
  public List<Report> getLatestReportVersions(int repository, String reportName, int latestVersions)
      throws ApiException, SimpleApiException {
    log.debug("Retrieving metadata for {} latest versions of report {} in repository {}",
        latestVersions, reportName, repository);

    final ReportsApi reportsApi = new ReportsApi(apiClient);
    final ApiResponse<ReportListResponse> result =
        reportsApi.listReportsWithHttpInfo(repository, null, null, reportName, latestVersions, null,
            null);

    final Optional<ReportListResult> data = Optional.ofNullable(result.getData().getResult());
    if (data.isEmpty()) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected result property missing from version reports response."));
    }

    return data.get().getReportList();
  }

  /**
   * Downloads a report.
   *
   * @param repository Repository.
   * @param report Report
   * @param convertToPdf Whether to download the report as a PDF.
   * @return Downloaded file.
   * @throws ApiException IF the API operation fails.
   */
  public File downloadReport(int repository, Report report, boolean convertToPdf)
      throws ApiException {
    log.debug("Downloading report {} ({}:{}) from repository {} as {}.", report.getReportID(),
        report.getGen(), report.getSeqNum(), repository, convertToPdf ? "PDF" : "TEXT");

    final ReportActionsApi reportActionsApi = new ReportActionsApi(apiClient);
    final ApiResponse<File> response =
        reportActionsApi.downloadReportWithHttpInfo(repository, report.getHandle(), null,
            convertToPdf, null, null, null, null, null, null);

    return response.getData();
  }
}
