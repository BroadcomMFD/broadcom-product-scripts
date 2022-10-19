package com.ca.om.webviewer.samples.api.service;

import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Print report content.
 */
public class PrintReportContent {

  /**
   * Get content from a report with or without index-value filters applied.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Sessiong token obtained previously.
   * @param repositoryId Repository Id.
   * @param reportHandle Report handle.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any Unsuccessful response.
   */
  public static void printReportContent(String baseUrl, String sessionToken, int repositoryId,
      String reportHandle) throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;
    assert repositoryId != 0;
    assert reportHandle != null;

    // Compose the address for the GET report content operation.
    String address =
        baseUrl + ApiConstants.PRINT_REPORT_DATA + "/" + repositoryId + "/" + reportHandle;

    // Execute the GET request and process the response based on the http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process Successful response.

      // From the result, extract and print the number of report lines.
      // Available properties: count
      int lineCount = result.getInt("count");
      System.out.println("Total Report lines: " + lineCount);

      // Return if report contains no content.
      if (lineCount <= 0) {
        return;
      }

      // Extract report content.
      JSONArray reportContent = result.getJSONArray("Report Data");

      System.out.println("Displaying report content.");

      // If report exceeds 30 lines, print only the first 30 lines.
      int printReportLinesLimit = reportContent.length();
      if (printReportLinesLimit > 30) {
        printReportLinesLimit = 30;
        System.out
            .println("Note: Displaying only first 30 lines of report." + System.lineSeparator());
      }

      for (int i = 0; i < printReportLinesLimit; i++) {
        // Available properties: lNum, pNum, plNum, cc, llInd, rLen, data
        JSONObject reportData = reportContent.getJSONObject(i);

        // Print report content.
        System.out.println(reportData.get("data"));
      }
    });
  }
}
