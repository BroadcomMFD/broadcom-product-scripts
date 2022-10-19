package com.ca.om.webviewer.samples.api.model;

/**
 * Query parameter class of filters that you can apply to the GET report list operation.
 */
public class ReportListFilter {

  // Available filters: name, arcDateFrom, arcDateTo, preVersNum
  private String name;
  private Long archivalFromDate;
  private Long archivalToDate;

  public void setName(String name) {
    this.name = name;
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

  /**
   * Generate query parameters to filter the GET report list operation.
   *
   * @return The generated query with parameters.
   */
  public String getQueryParameters() {
    StringBuilder params = new StringBuilder("?");

    if (name != null) {
      params.append("&name=").append(name);
    }

    if (archivalFromDate != null) {
      params.append("&arcDateFrom=").append(archivalFromDate);
    }

    if (archivalToDate != null) {
      params.append("&arcDateTo=").append(archivalToDate);
    }

    return params.toString();
  }
}
