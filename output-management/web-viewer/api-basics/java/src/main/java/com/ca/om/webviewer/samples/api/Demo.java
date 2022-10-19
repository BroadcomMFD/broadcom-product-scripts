package com.ca.om.webviewer.samples.api;

import com.ca.om.webviewer.samples.api.model.CrossReportIndexNamesFilter;
import com.ca.om.webviewer.samples.api.model.CrossReportIndexValuesFilter;
import com.ca.om.webviewer.samples.api.model.ReportListFilter;
import com.ca.om.webviewer.samples.api.service.Authentication;
import com.ca.om.webviewer.samples.api.service.ListCrossReportIndex;
import com.ca.om.webviewer.samples.api.service.ListReports;
import com.ca.om.webviewer.samples.api.service.ListRepositories;
import com.ca.om.webviewer.samples.api.service.PrintReportContent;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Utility class which parses user parameters and calls the following services:
 * <ul>
 * <li>Authentication.</li>
 * <li>Display report content without applying indexing filters.</li>
 * <li>Display report content after applying cross-report index names and values filter.</li>
 * </ul>
 */
public class Demo {

  // Command line arguments.
  private static final String HELP = "h";
  private static final String USER_NAME = "u";
  @SuppressWarnings("squid:S2068") // does not contain hardcoded credentials
  private static final String USER_PASSWORD = "p";
  private static final String BASE_PATH = "b";
  private static final String OPERATION = "o";
  private static final String REPORT_ID_FILTER = "fr";
  private static final String ARCHIVAL_FROM_DATE_FILTER = "ff";
  private static final String ARCHIVAL_TO_DATE_FILTER = "ft";
  private static final String INDEX_NAMES_FILTER = "fn";
  private static final String INDEX_VALUES_FILTER = "fv";

  private static final int OPERATION_AUTHENTICATION = 1;
  private static final int OPERATION_DISPLAY_REPORT = 2;
  private static final int OPERATION_DISPLAY_FILTERED_REPORT = 3;
  private static final String MESSAGE_TERMINATING_OPERATION = "Terminating the operation.";

  /**
   * Extract command line arguments and call the requested operation.
   *
   * @param args Required and optional arguments to run the requested operation.
   * @throws ParseException For any error that occurs while parsing command line arguments.
   */
  public static void main(String[] args) throws ParseException {

    Options options = new Options();
    options.addOption(HELP, false, "print help")
        .addOption(OPERATION, "operation", true,
            "Select operation to run. Valid values are: " + System.lineSeparator()
                + OPERATION_AUTHENTICATION + " to Authenticate, " + System.lineSeparator()
                + OPERATION_DISPLAY_REPORT
                + " to Display report content without applying indexing filters, " + System
                .lineSeparator()
                + OPERATION_DISPLAY_FILTERED_REPORT
                + " to Display report content after applying for cross-report index names and values filter. "
                + System.lineSeparator()
                + "Default: Display report content without applying indexing filters.")
        .addOption(BASE_PATH, "basePath", true, "Http address and port for the application server.")
        .addOption(USER_NAME, "user", true, "User name to authenticate.")
        .addOption(USER_PASSWORD, "pass", true, "User password to authenticate.")
        .addOption(REPORT_ID_FILTER, true, "Filter report based on report id.")
        .addOption(ARCHIVAL_FROM_DATE_FILTER, true,
            "Filter report based on archival from-date in milliseconds.")
        .addOption(ARCHIVAL_TO_DATE_FILTER, true,
            "Filter report based on archival to-date in milliseconds.")
        .addOption(INDEX_NAMES_FILTER, true,
            "Filter for cross-report index names. Each filter must be separated by ,. Example: I*,A*.")
        .addOption(INDEX_VALUES_FILTER, true,
            "Filter for cross-report index values. Each value filter must be separated by ,. Example: I*,A*.");

    CommandLineParser parser = new DefaultParser();
    CommandLine commandLine = parser.parse(options, args);

    if (commandLine.hasOption(HELP)) {
      HelpFormatter formatter = new HelpFormatter();
      formatter.setOptionComparator(null);
      formatter.printHelp("CLITester", options);
      return;
    }

    String userName = null;
    String password = null;
    String basePath = null;

    // Check for each required parameter.
    if (!(commandLine.hasOption(BASE_PATH) && commandLine.hasOption(USER_NAME) && commandLine
        .hasOption(USER_PASSWORD))) {
      System.out.println(
          "Missing required parameters: " + BASE_PATH + "," + USER_NAME + "," + USER_PASSWORD);
      return;
    }

    if (commandLine.hasOption(BASE_PATH)) {
      basePath = commandLine.getOptionValue(BASE_PATH);
    }

    if (commandLine.hasOption(USER_NAME)) {
      userName = commandLine.getOptionValue(USER_NAME);
    }

    if (commandLine.hasOption(USER_PASSWORD)) {
      password = commandLine.getOptionValue(USER_PASSWORD);
    }

    // Default operation: List report content without applying indexing filters.
    if (commandLine.hasOption(OPERATION)) {
      int operation = Integer.parseInt(commandLine.getOptionValue(OPERATION));
      switch (operation) {
        case OPERATION_AUTHENTICATION:
          loginAndLogout(basePath, userName, password);
          break;
        case OPERATION_DISPLAY_REPORT:
          listReportContent(basePath, userName, password, commandLine);
          break;
        case OPERATION_DISPLAY_FILTERED_REPORT:
          listCrossIndexReports(basePath, userName, password, commandLine);
          break;
        default:
          listReportContent(basePath, userName, password, commandLine);
          break;
      }
    } else {
      listReportContent(basePath, userName, password, commandLine);
    }
  }

  /**
   * <ul>
   * <li>Log in with a username and password to obtain a session token.</li>
   * <li>Log out by invalidating the session token.</li>
   * </ul>
   *
   * @param basePath Http address and port for the application server.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   */
  private static void loginAndLogout(String basePath, String username, String password) {
    // Authenticate with username and password.
    String sessionToken = login(basePath, username, password);

    // Log out by invalidating the session token.
    if (sessionToken != null) {
      logout(basePath, sessionToken);
    }
  }


  /**
   * Extract command-line arguments for a report list and follow these steps:
   * <ul>
   * <li>Log in with a username and password to obtain a session token.</li>
   * <li>List a repository.</li>
   * <li>List the report for the first found repository id.</li>
   * <li>Print the content of first found text report.</li>
   * <li>Log out by invalidating the session token.</li>
   * </ul>
   *
   * @param basePath Http address and port for the application server.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   * @param commandLine Command-line arguments.
   */
  private static void listReportContent(String basePath, String username, String password,
      CommandLine commandLine) {

    ReportListFilter reportListFilter = new ReportListFilter();

    // Obtain report id filter.
    if (commandLine.hasOption(REPORT_ID_FILTER)) {
      reportListFilter.setName(commandLine.getOptionValue(REPORT_ID_FILTER));
    }

    // Obtain archival from-date filter.
    if (commandLine.hasOption(ARCHIVAL_FROM_DATE_FILTER)) {
      reportListFilter.setArchivalFromDate(commandLine.getOptionValue(ARCHIVAL_FROM_DATE_FILTER));
    }

    // Obtain archival to-date filter.
    if (commandLine.hasOption(ARCHIVAL_TO_DATE_FILTER)) {
      reportListFilter.setArchivalToDate(commandLine.getOptionValue(ARCHIVAL_TO_DATE_FILTER));
    }

    // Authenticate with username and password.
    String sessionToken = login(basePath, username, password);

    // If authentication is unsuccessful, then return.
    if (sessionToken == null) {
      System.out.println("User not authenticated. " + MESSAGE_TERMINATING_OPERATION);
      return;
    }

    try {
      // List the repositories which are accessible to the user.
      System.out.println(System.lineSeparator() + "Listing repositories.");
      List<Integer> repositoryIds = ListRepositories.listRepository(basePath, sessionToken);

      // If no repository is found, then return.
      if (repositoryIds.isEmpty()) {
        System.out.println("No repositories found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // List the reports for the repository id.
      List<String> reportHandles = new ArrayList<>();
      int selectedRepositoryId = 0;

      // Loop till we found some report in any repository.
      for (Integer repositoryId : repositoryIds) {
        System.out
            .println(System.lineSeparator() + "Listing reports for repository id " + repositoryId);
        reportHandles = ListReports
            .listReportsWithFilters(basePath, sessionToken, repositoryId, reportListFilter);
        if (!reportHandles.isEmpty()) {
          selectedRepositoryId = repositoryId;
          break;
        }
      }

      // If no reports are found, then return.
      if (reportHandles.isEmpty()) {
        System.out.println("No reports found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // Printing the report content for the first text report found.
      final String reportHandle = reportHandles.get(0);
      System.out.println(
          System.lineSeparator() + "Displaying the content of report for report handle "
              + reportHandle);
      PrintReportContent
          .printReportContent(basePath, sessionToken, selectedRepositoryId, reportHandle);

    } catch (IOException e) {
      System.out.println("Exception during http processing: " + e.getMessage());
    } catch (ApiQueryException e) {
      System.out.println("An error occurred during the REST API call with http status code: " + e
          .getHttpStatus() + ". Error message: " + e.getApplicationErrorMessages());
    }

    // Log out by invalidating the session token.
    logout(basePath, sessionToken);
  }


  /**
   * Extract command line arguments for cross report index list and follow these steps:
   * <ul>
   * <li>Login using the username and password and obtain a session token.</li>
   * <li>List the repository.</li>
   * <li>List the cross report index names for the first found repository id.</li>
   * <li>List the cross report index values for the first found cross report index name.</li>
   * <li>List the cross report index value reports for the first found cross report index
   * value.</li>
   * <li>Print the content of first found text cross report index value reports.</li>
   * <li>Log out by invalidating the session token.</li>
   * </ul>
   *
   * @param basePath Application server HTTP address and port.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   * @param commandLine Command line arguments.
   */
  private static void listCrossIndexReports(String basePath, String username, String password,
      CommandLine commandLine) {

    CrossReportIndexNamesFilter crossReportIndexNamesFilter = new CrossReportIndexNamesFilter();
    CrossReportIndexValuesFilter crossReportIndexValuesFilter = new CrossReportIndexValuesFilter();

    // Obtain report id filter.
    if (commandLine.hasOption(REPORT_ID_FILTER)) {
      crossReportIndexNamesFilter.setReportName(commandLine.getOptionValue(REPORT_ID_FILTER));
      crossReportIndexValuesFilter.setReportName(commandLine.getOptionValue(REPORT_ID_FILTER));
    }

    // Obtain archival from-date filter.
    if (commandLine.hasOption(ARCHIVAL_FROM_DATE_FILTER)) {
      crossReportIndexNamesFilter
          .setArchivalFromDate(commandLine.getOptionValue(ARCHIVAL_FROM_DATE_FILTER));
      crossReportIndexValuesFilter
          .setArchivalFromDate(commandLine.getOptionValue(ARCHIVAL_FROM_DATE_FILTER));
    }

    // Obtain archival to-date filter.
    if (commandLine.hasOption(ARCHIVAL_TO_DATE_FILTER)) {
      crossReportIndexNamesFilter
          .setArchivalToDate(commandLine.getOptionValue(ARCHIVAL_TO_DATE_FILTER));
      crossReportIndexValuesFilter
          .setArchivalToDate(commandLine.getOptionValue(ARCHIVAL_TO_DATE_FILTER));
    }

    // Obtain cross-report index names filter.
    if (commandLine.hasOption(INDEX_NAMES_FILTER)) {
      crossReportIndexNamesFilter.setNameFilter(commandLine.getOptionValue(INDEX_NAMES_FILTER));
    }

    // Obtain cross-report index values filter.
    if (commandLine.hasOption(INDEX_VALUES_FILTER)) {
      crossReportIndexValuesFilter.setValueFilter(commandLine.getOptionValue(INDEX_VALUES_FILTER));
    }

    // Authenticate with username and password.
    String sessionToken = login(basePath, username, password);

    // If authentication is not successful then return.
    if (sessionToken == null) {
      System.out.println("User not authenticated. " + MESSAGE_TERMINATING_OPERATION);
      return;
    }

    try {
      // List the repository accessible to the user.
      System.out.println(System.lineSeparator() + "Listing repositories.");
      List<Integer> repositoryIds = ListRepositories.listRepository(basePath, sessionToken);

      // If no repository found then return.
      if (repositoryIds.isEmpty()) {
        System.out.println("No repositories found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // List the cross-report index names for the repository id.
      List<String> crossReportIndexNamesHandles = new ArrayList<>();
      int selectedRepositoryId = 0;

      // Loop till we found some cross-report index names in any repository.
      for (Integer repositoryId : repositoryIds) {
        System.out.println(
            System.lineSeparator() + "Listing cross-report index names for repositoryId "
                + repositoryId);
        crossReportIndexNamesHandles = ListCrossReportIndex
            .listCrossReportIndexNames(basePath, sessionToken, repositoryId,
                crossReportIndexNamesFilter);

        if (!crossReportIndexNamesHandles.isEmpty()) {
          selectedRepositoryId = repositoryId;
          break;
        }
      }

      // If no cross-report index names found then return.
      if (crossReportIndexNamesHandles.isEmpty()) {
        System.out.println("No cross report index names found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // List the cross report index values for cross report index name.
      List<String> crossReportIndexValuesHandles = new ArrayList<>();
      String selectedCrossReportIndexNamesHandle = "";

      // Loop till we found some cross-report index values for cross-report index names.
      for (String crossReportIndexNamesHandle : crossReportIndexNamesHandles) {
        System.out.println(
            System.lineSeparator() + "Listing cross-report index values for nameHandle "
                + crossReportIndexNamesHandle);
        crossReportIndexValuesHandles = ListCrossReportIndex
            .listCrossReportIndexValues(basePath, sessionToken, selectedRepositoryId,
                crossReportIndexNamesHandle, crossReportIndexValuesFilter);

        if (!crossReportIndexValuesHandles.isEmpty()) {
          selectedCrossReportIndexNamesHandle = crossReportIndexNamesHandle;
          break;
        }
      }

      // If no cross-report index values found then return.
      if (crossReportIndexValuesHandles.isEmpty()) {
        System.out.println("No cross-report index values found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // List the reports that contains cross report index value.
      List<String> crossReportIndexValueReportsHandles = new ArrayList<>();

      // Loop till we found some reports that contain a cross-report index value.
      for (String crossReportIndexValuesHandle : crossReportIndexValuesHandles) {
        System.out.println(
            System.lineSeparator() + "Listing cross-report index values reports for valueHandle "
                + crossReportIndexValuesHandle);
        crossReportIndexValueReportsHandles = ListCrossReportIndex
            .listCrossReportIndexValueReports(basePath, sessionToken, selectedRepositoryId,
                selectedCrossReportIndexNamesHandle, crossReportIndexValuesHandle);

        if (!crossReportIndexValueReportsHandles.isEmpty()) {
          break;
        }
      }

      // If no cross-report index value report found then return.
      if (crossReportIndexValueReportsHandles.isEmpty()) {
        System.out
            .println("No cross report index value reports found. " + MESSAGE_TERMINATING_OPERATION);
        return;
      }

      // Printing the report content for the first found cross-report index value text report.
      final String crossReportIndexValueReportHandle = crossReportIndexValueReportsHandles.get(0);
      System.out.println(System.lineSeparator()
          + "Displaying the content of report for cross report index value reportHandle "
          + crossReportIndexValueReportHandle);
      PrintReportContent.printReportContent(basePath, sessionToken, selectedRepositoryId,
          crossReportIndexValueReportHandle);

    } catch (IOException e) {
      System.out.println("Exception during http processing: " + e.getMessage());
    } catch (ApiQueryException e) {
      System.out.println(
          "Error occurred during REST API operation call with http status code: " + e
              .getHttpStatus() + ". Error message: " + e.getApplicationErrorMessages());
    }

    // Log out by invalidating the session token.
    logout(basePath, sessionToken);
  }

  /**
   * Authenticate with username and password and process any error occurred.
   *
   * @param basePath Application server HTTP address and port.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   * @return Generated session token (guid) or null.
   */
  private static String login(String basePath, String username, String password) {
    System.out.println("Authenticating with username and password." + System.lineSeparator());
    String sessionToken = null;
    try {
      sessionToken = Authentication.loginWithUserName(basePath, username, password);
    } catch (IOException e) {
      System.out.println("Exception during http processing: " + e.getMessage());
    } catch (ApiQueryException e) {
      System.out.println(
          "Error occurred during the Login service call with http status code: " + e.getHttpStatus()
              + ". Error message: " + e.getApplicationErrorMessages());
    }

    return sessionToken;
  }

  /**
   * Logout from the application and process errors which may have occurred.
   *
   * @param basePath Application server HTTP address and port.
   * @param sessionToken Session token to be invalidated.
   */
  private static void logout(String basePath, String sessionToken) {

    assert sessionToken != null;

    System.out.println("Logging out - invalidating the session token." + System.lineSeparator());
    try {
      Authentication.logout(basePath, sessionToken);
    } catch (IOException e) {
      System.out.println("Exception during http processing: " + e.getMessage());
    } catch (ApiQueryException e) {
      System.out.println(
          "Error occurred during the Logout service call with http status code: " + e
              .getHttpStatus()
              + ". Error message: " + e.getApplicationErrorMessages());
    }
  }
}
