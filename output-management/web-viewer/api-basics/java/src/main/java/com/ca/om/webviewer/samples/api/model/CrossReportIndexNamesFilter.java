package com.ca.om.webviewer.samples.api.model;

/**
 * Query parameter class that filters the GET cross-report index names operation.
 */
public class CrossReportIndexNamesFilter {

  // Available filters: reportName, arcDateFrom, arcDateTo, versNumFrom, versNumTo, onlineOnly, nameFilter
  private String reportName;
  private Long archivalFromDate;
  private Long archivalToDate;
  private String nameFilter;

  public void setReportName(String reportName) {
    this.reportName = reportName;
  }

  public void setArchivalFromDate(String archivalFromDate) {
    try {
      this.archivalFromDate = Long.parseLong(archivalFromDate);
    } catch (NumberFormatException e) {
      System.out.println(
          "Note: The archival from-date is ignored because the parameter accepts only a numeric value. "
              + e.getMessage());
    }
  }

  public void setArchivalToDate(String archivalToDate) {
    try {
      this.archivalToDate = Long.parseLong(archivalToDate);
    } catch (NumberFormatException e) {
      System.out.println(
          "Note: The archival to-date is ignored because the parameter accepts only a numeric value. "
              + e.getMessage());
    }
  }

  public void setNameFilter(String nameFilter) {
    this.nameFilter = nameFilter;
  }

  /**
   * Generate query parameters to filter the GET cross-report index names list operation.
   *
   * @return The generated query with parameters.
   */
  public String getQueryParameters() {
    StringBuilder params = new StringBuilder("?");

    if (reportName != null) {
      params.append("reportName=").append(reportName);
    }

    if (archivalFromDate != null) {
      params.append("&arcDateFrom=").append(archivalFromDate);
    }

    if (archivalToDate != null) {
      params.append("&arcDateTo=").append(archivalToDate);
    }

    if (nameFilter != null) {
      params.append("&nameFilter=").append(nameFilter);
    }

    return params.toString();
  }
}
