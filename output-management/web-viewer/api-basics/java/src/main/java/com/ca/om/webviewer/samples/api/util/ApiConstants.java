package com.ca.om.webviewer.samples.api.util;

/**
 * Constants for the REST API URLs.
 */
public class ApiConstants {

  // Default context root
  private static final String CONTEXT_ROOT = "/web-viewer/";

  // Authenticate with a username and password.
  public static final String LOGIN = CONTEXT_ROOT + "api/v1/view/login";

  // Log out - invalidate the guid (session token).
  public static final String LOGOUT = CONTEXT_ROOT + "api/v1/view/logout";

  // List repositories.
  public static final String LIST_REPOSITORY = CONTEXT_ROOT + "api/v1/view/repository";

  // List reports and apply a subset of filters.
  public static final String LIST_REPORT = CONTEXT_ROOT + "api/v1/view/rptlist";

  // Print report content with and without metadata.
  // Print content of reports that are filtered by an index value.
  public static final String PRINT_REPORT_DATA = CONTEXT_ROOT + "api/v1/view/rptdata";

  // List cross-report index names and apply a subset of filters.
  // List cross-report index values and apply a subset of filters.
  // List reports with a cross-report index value and apply a subset of filters.
  public static final String LIST_CROSS_REPORT_INDEX = CONTEXT_ROOT + "api/v1/view/index";

  // List cross-report index values.
  public static final String LIST_CROSS_REPORT_INDEX_VALUES = "/values";

  // List reports with a cross-report index value.
  public static final String LIST_CROSS_REPORT_INDEX_VALUE_REPORT = "/reports";
}
