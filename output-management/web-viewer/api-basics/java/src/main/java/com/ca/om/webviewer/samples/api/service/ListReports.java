package com.ca.om.webviewer.samples.api.service;

import com.ca.om.webviewer.samples.api.model.ReportListFilter;
import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Get a list of reports.
 */
public class ListReports {

  // The max. length is 32 for Report Name, 64 for Report Handle, 10 for Type, 9 for Pages, and 20 for Archive Date.
  private static String REPORT_LIST_FORMATTER =
      "%-32s|%-64s|%-10s|%-9s|%-20s" + System.lineSeparator();

  /**
   * List the report with some filters.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Session token obtained previously.
   * @param repositoryId Repository id.
   * @param reportListFilter Object for the Report list filter.
   * @return List of reports retrieved or an empty array list.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static List<String> listReportsWithFilters(String baseUrl, String sessionToken,
      int repositoryId, ReportListFilter reportListFilter)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;
    assert repositoryId != 0;
    assert reportListFilter != null;

    List<String> reportHandles = new ArrayList<>();

    // Compose the address for the list-reports operation.
    String address = baseUrl + ApiConstants.LIST_REPORT + "/" + repositoryId + reportListFilter
        .getQueryParameters();

    // Execute the GET request and process the response based on the http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process successful response.

      // From the result, extract and print the report count.
      // Available properties: count
      int reportCount = result.getInt("count");
      System.out.println("Total found reports: " + reportCount);

      // Return if no reports are found.
      if (reportCount <= 0) {
        return;
      }

      // Extract the list of reports.
      JSONArray reportList = result.getJSONArray("Report List");

      System.out.println("Printing list of reports.");
      System.out.format(REPORT_LIST_FORMATTER, "Report Name", "Report Handle", "Type", "Pages",
          "Archive Date");

      for (int i = 0; i < reportList.length(); i++) {
        // Available properties: handle, reportID, status, gen, seqNum, lines, pages, retrievablePages,
        // JobName, type, oType, desc, archDT, sysoutClass, Destination, jesID, formsNum, xCode, reportOrigin,
        // userID, userField, readerDT, printDT, isOnDisk, isOnTape, isOnOptical, isIdxOnDisk, location,
        // tapeSeq, tapePos, tapeCnt, eroId, eroRtnPd, eroGen, eroCpy, diskRtnPd, diskGen, diskCpy, disk2Days.
        JSONObject report = reportList.getJSONObject(i);

        // Print Report Name|Handle|Type|Pages|Archive Date for each report.
        System.out.format(REPORT_LIST_FORMATTER, report.get("reportID"), report.get("handle"),
            report.get("type"), report.get("pages"), report.get("archDT"));

        // For type TEXT reports, add handles to the list.
        if (report.getString("type").equalsIgnoreCase("TEXT")) {
          reportHandles.add(report.getString("handle"));
        }
      }

    });

    // Return list of TEXT report handles.
    return reportHandles;
  }
}
