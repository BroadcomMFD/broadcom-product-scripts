package com.broadcom.msd.om.sample.downloader.api;

import static com.broadcom.msd.om.sample.downloader.configuration.ApplicationConfiguration.USERNAME;
import static org.openapitools.client.model.RepositoryUserUpdateResponse.StatusEnum.ERROR;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import java.io.File;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;
import java.util.stream.Collectors;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.openapitools.client.*;
import org.openapitools.client.api.*;
import org.openapitools.client.model.*;
import org.openapitools.client.model.Report.StatusEnum;
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
  private final ReportActionsApi reportActionsApi;
  private final RepositoriesApi repositoriesApi;
  private final ReportsApi reportsApi;
  private final RepositoryUsersApi userApi;

  @Inject
  public Api(ApiClient apiClient, Gson gson) {
    this.apiClient = apiClient;
    if (log.isTraceEnabled()) {
      apiClient.setDebugging(true);
    }
    this.gson = gson;

    reportActionsApi = new ReportActionsApi(apiClient);
    repositoriesApi = new RepositoriesApi(apiClient);
    reportsApi = new ReportsApi(apiClient);
    userApi = new RepositoryUsersApi(apiClient);
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

  private static String resolveGenericExceptionReason(Throwable exception) {
    if (exception == null) {
      return "Unknown reason";
    }

    String reason = null;
    Throwable nested = exception;
    while (nested != null && reason == null) {
      reason = nested.getLocalizedMessage();
      nested = exception.getCause();
    }

    if (reason == null) {
      final StackTraceElement[] stack = exception.getStackTrace();
      assert stack.length > 0;

      reason = String.format("%s (%s.%s:%d)", exception.getClass().getSimpleName(),
          stack[0].getClassName(), stack[0].getMethodName(), stack[0].getLineNumber());
    }

    return reason;
  }

  public String resolveExceptionReason(Throwable exception) {
    if (exception instanceof ApiException) {
      return getApiExceptionMessage((ApiException) exception);
    } else {
      return Api.resolveGenericExceptionReason(exception);
    }
  }

  public Long timeToEpoch(LocalDateTime time) {
    return time
        .atZone(ZoneOffset.UTC)
        .toEpochSecond() * 1000; // milliseconds
  }

  /**
   * Extracts the most specific error message possible from an {@link ApiException}.
   *
   * @param apiException API Exception
   * @return Error message.
   */
  public String getApiExceptionMessage(ApiException apiException) {
    log.trace("API Exception", apiException);

    switch (apiException.getCode()) {
      case 0:
        log.warn("Connection issues", apiException.getCause());
        // fall-through
      case 404:
        return "Unable to connect to Web Viewer at specified URL.";
      default:
        try {
          final List<String> contentType = apiException.getResponseHeaders().get("Content-Type");
          if (contentType != null && !contentType.isEmpty() && contentType.get(0)
              .contains("json")) {
            final ErrorResponse response = gson.fromJson(apiException.getResponseBody(),
                ErrorResponse.class);
            if (response != null && response.getMessage() != null) {
              return getApiMessage(response.getMessage());
            }
          }
        } catch (JsonSyntaxException ignored) {
          // Use generic processing if the response JSON can not be parsed.
        }
        return Api.resolveGenericExceptionReason(apiException);
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
  public RepositoryUser getUserConfiguration(int repository)
      throws ApiException, SimpleApiException {
    log.debug("Retrieving current user configuration from repository {}", repository);

    final ApiResponse<RepositoryUserListResponse> result =
        userApi.listRepositoryUsersWithHttpInfo(repository, USERNAME.get(), null);

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
   * Retrieves list of downloadable reports with optional filtering.
   *
   * <p>A report is considered downloadable if it is a TEXT report that is online or available
   * through EAS.</p>
   *
   * @param repository Repository ID.
   * @param reportName Report Name.
   * @param dateFrom Archival date filter lower bound.
   * @param dateTo Archival date filter upper bound.
   * @return List of reports.
   * @throws ApiException If the API operation fails.
   * @throws SimpleApiException If the API operation fails.
   */
  public List<Report> getDownloadableReports(int repository, String reportName, Long dateFrom,
      Long dateTo) throws ApiException, SimpleApiException {
    log.debug("Retrieving names of actionable reports in repository {}", repository);

    final ApiResponse<ReportListResponse> result = reportsApi.listReportsWithHttpInfo(
        repository, dateFrom, dateTo, reportName.isBlank() ? null : reportName, null, null, null);

    final Optional<ReportListResult> data = Optional.ofNullable(result.getData().getResult());
    if (data.isEmpty()) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected result property missing from reports response."));
    }

    final List<Report> fullList = data.get().getReportList();
    if (fullList == null) {
      throw new SimpleApiException(Optional
          .ofNullable(getApiMessage(result.getData().getMessage()))
          .orElse("Expected reportList property missing from reports response."));
    }

    return fullList.stream()
        .filter(report -> report.getStatus() == StatusEnum.ONLINE
            || report.getStatus() == StatusEnum.EAS)
        .filter(report -> "TEXT".equalsIgnoreCase(report.getType()))
        .collect(Collectors.toList());
  }

  /**
   * Downloads a report.
   *
   * @param repository Repository.
   * @param report Report
   * @return Downloaded file.
   * @throws ApiException IF the API operation fails.
   */
  public File downloadReport(int repository, Report report)
      throws ApiException {
    log.debug("Downloading report {} ({}:{}) from repository {}.", report.getReportID(),
        report.getGen(), report.getSeqNum(), repository);

    final ApiResponse<File> response =
        reportActionsApi.downloadReportWithHttpInfo(repository, report.getHandle(), null,
            null, null, null, null, null, null, null);

    return response.getData();
  }
}
