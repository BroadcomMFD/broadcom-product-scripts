package com.ca.om.webviewer.samples.api.model;

/**
 * Query parameter class that filters the GET cross-report index values operation.
 */
public class CrossReportIndexValuesFilter {

  // Available filters: reportName, arcDateFrom, arcDateTo, versNumFrom, versNumTo, onlineOnly, valueFilter
  private String reportName;
  private Long archivalFromDate;
  private Long archivalToDate;
  private String valueFilter;

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

  public void setValueFilter(String valueFilter) {
    this.valueFilter = valueFilter;
  }

  /**
   * Generate query parameters to filter the GET cross-report index values operation.
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

    if (valueFilter != null) {
      params.append("&valueFilter=").append(valueFilter);
    }

    return params.toString();
  }
}
