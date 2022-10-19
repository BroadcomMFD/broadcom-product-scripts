package com.ca.om.webviewer.samples.api.service;

import com.ca.om.webviewer.samples.api.model.CrossReportIndexNamesFilter;
import com.ca.om.webviewer.samples.api.model.CrossReportIndexValuesFilter;
import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Get cross-report index names, cross-report index values, and cross-report index-value reports.
 */
public class ListCrossReportIndex {

  // The max. length is 32 for Report Name, 64 for Report Handle, 10 for Type, 9 for Pages, and 20 for Archive Date.
  private static String REPORT_LIST_FORMATTER =
      "%-32s|%-64s|%-10s|%-9s|%-20s" + System.lineSeparator();

  /**
   * List cross-report index names with some filters applied.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Session token that was obtained previously.
   * @param repositoryId Repository id.
   * @param crossReportIndexNamesFilter Object for the cross-report index names filter.
   * @return List of cross-report index names retrieved or an empty array list.
   * @throws IOException For any error that occurred while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static List<String> listCrossReportIndexNames(String baseUrl, String sessionToken,
      int repositoryId, CrossReportIndexNamesFilter crossReportIndexNamesFilter)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;
    assert repositoryId != 0;
    assert crossReportIndexNamesFilter != null;

    // Compose the address for the GET cross-report index names operation.
    String address =
        baseUrl + ApiConstants.LIST_CROSS_REPORT_INDEX + "/" + repositoryId
            + crossReportIndexNamesFilter.getQueryParameters();

    List<String> crossReportIndexNameHandles = new ArrayList<>();

    // Execute the GET request and process the response based on the http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process a successful response.

      // From the result, extract and print the total number of cross-report index names.
      // Available properties: count
      int crossReportIndexNameCount = result.getInt("count");
      System.out.println("Total cross-report index names found: " + crossReportIndexNameCount);

      // Return if no cross report index names are found.
      if (crossReportIndexNameCount <= 0) {
        return;
      }

      // Extract the list of cross-report index names.
      JSONArray indexNamesObjects = result.getJSONArray("data");

      System.out.println("Displaying the list of cross-report index names.");
      // Print the index-names table header. The max. character length for nameHandle is 88.
      // For eight index names, the max. character length for each is 8.
      System.out.format("%-88s|", "Index Names Handle");
      for (int i = 1; i <= 8; i++) {
        System.out.format("%-8s|", "Name " + i);
      }
      System.out.println();

      for (int i = 0; i < indexNamesObjects.length(); i++) {
        // Available properties: handle, names.
        String indexNamesHandle = indexNamesObjects.getJSONObject(i).getString("handle");
        JSONArray indexNames = indexNamesObjects.getJSONObject(i).getJSONArray("names");

        // Print index names.
        System.out.format("%-88s|", indexNamesHandle);
        for (int j = 0; j < indexNames.length(); j++) {
          System.out.format("%-8s|", indexNames.get(j));
        }
        System.out.println();

        // Add handles to the list of cross-report index names.
        crossReportIndexNameHandles.add(indexNamesHandle);
      }
    });

    // Return the list of cross-report index name handles.
    return crossReportIndexNameHandles;
  }

  /**
   * List cross-report index values with some filters applied.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Session token obtained previously.
   * @param repositoryId Repository id.
   * @param nameHandle Cross-report index name handle.
   * @param crossReportIndexValuesFilter Filter object for cross-report index values.
   * @return A list of cross-report index values retrieved or an empty array list.
   * @throws IOException For any error that occurred while response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static List<String> listCrossReportIndexValues(String baseUrl, String sessionToken,
      int repositoryId, String nameHandle,
      CrossReportIndexValuesFilter crossReportIndexValuesFilter)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;
    assert repositoryId != 0;
    assert nameHandle != null;
    assert crossReportIndexValuesFilter != null;

    // Compose the address for the GET cross-report index values operation.
    String address =
        baseUrl + ApiConstants.LIST_CROSS_REPORT_INDEX + "/" + repositoryId + "/" + nameHandle
            + ApiConstants.LIST_CROSS_REPORT_INDEX_VALUES + crossReportIndexValuesFilter
            .getQueryParameters();

    List<String> crossReportIndexValueHandles = new ArrayList<>();

    // Execute the GET request and process the response based on the http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process a Successful response.

      // From the result, extract and print the number of cross-report index values.
      // Available properties: count
      int crossReportIndexValueCount = result.getInt("count");
      System.out.println("Total cross-report index values found: " + crossReportIndexValueCount);

      // Return if no cross-report index values are found.
      if (crossReportIndexValueCount <= 0) {
        return;
      }

      // Extract the list of cross-report index values.
      JSONArray indexValuesObjects = result.getJSONArray("data");

      // Extract the number of index values.
      int indexValuesCount = indexValuesObjects.getJSONObject(0).getJSONArray("values").length();

      System.out.println("Displaying the list of cross-report index values.");
      // Print the index-values table header. The max. character length for valueHandle is 88.
      // For eight index values, the max. character length for each is 32.
      System.out.format("%-88s|", "Index Values Handle");
      for (int i = 1; i <= indexValuesCount; i++) {
        System.out.format("%-32s|", "Index value " + i);
      }
      System.out.println();

      for (int i = 0; i < indexValuesObjects.length(); i++) {
        // Available properties: handle, values.
        String indexValuesHandle = indexValuesObjects.getJSONObject(i).getString("handle");
        JSONArray indexValues = indexValuesObjects.getJSONObject(i).getJSONArray("values");

        // Print index values.
        System.out.format("%-88s|", indexValuesHandle);
        for (int j = 0; j < indexValues.length(); j++) {
          System.out.format("%-32s|", indexValues.get(j));
        }
        System.out.println();

        // Add handles to the list of cross-report index values.
        crossReportIndexValueHandles.add(indexValuesHandle);
      }
    });

    // Add handles to the list of cross-report index values.
    return crossReportIndexValueHandles;
  }

  /**
   * List cross-report index value reports.
   *
   * @param baseUrl The http address and port for the application server.
   * @param sessionToken The session token obtained previously.
   * @param repositoryId Repository id.
   * @param nameHandle Cross-report index name handle.
   * @param valueHandle Cross-report index value handle.
   * @return The list of cross-report index value reports retrieved or an empty array list.
   * @throws IOException For any errors occurred while the response is read.
   * @throws ApiQueryException For any Unsuccessful response.
   */
  public static List<String> listCrossReportIndexValueReports(String baseUrl,
      String sessionToken, int repositoryId, String nameHandle, String valueHandle)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;
    assert repositoryId != 0;
    assert nameHandle != null;
    assert valueHandle != null;

    // Compose the address for the GET reports containing a cross-report index value operation.
    String address =
        baseUrl + ApiConstants.LIST_CROSS_REPORT_INDEX + "/" + repositoryId + "/" + nameHandle + "/"
            + valueHandle + ApiConstants.LIST_CROSS_REPORT_INDEX_VALUE_REPORT;

    List<String> crossReportIndexReportHandles = new ArrayList<>();

    // Execute the GET request and process the response based on the http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process the Successful response.

      // From the result, extract and print the number of reports that contain a cross-report index value.
      // Available properties: count
      int crossReportIndexValueReportCount = result.getInt("count");
      System.out.println(
          "Total reports found that contain a cross-report index value: "
              + crossReportIndexValueReportCount);

      // Return if no cross report index value reports are found.
      if (crossReportIndexValueReportCount <= 0) {
        return;
      }

      // Extract the list of reports that contain a cross-report index value.
      JSONArray reportList = result.getJSONArray("data");

      System.out.println("Displaying the list of reports that contain a cross-report index value.");
      System.out.format(REPORT_LIST_FORMATTER, "Report Name", "Report Handle", "Type", "Pages",
          "Archive Date");

      for (int i = 0; i < reportList.length(); i++) {
        // Available properties: handle, reportID, status, gen, seqNum, lines, pages, retrievablePages,
        // JobName, type, oType, desc, archDT, sysoutClass, Destination, jesID, formsNum, xCode, reportOrigin,
        // userID, userField, readerDT, printDT, isOnDisk, isOnTape, isOnOptical, isIdxOnDisk, location,
        // tapeSeq, tapePos, tapeCnt, eroId, eroRtnPd, eroGen, eroCpy, diskRtnPd, diskGen, diskCpy, disk2Days.
        JSONObject report = reportList.getJSONObject(i);

        // For each report, print Report Name|Handle|Type|Pages|Archive Date.
        System.out.format(REPORT_LIST_FORMATTER, report.get("reportID"), report.get("handle"),
            report.get("type"), report.get("pages"), report.get("archDT"));

        // For type TEXT reports, add handles to the list.
        if (report.getString("type").equalsIgnoreCase("TEXT")) {
          crossReportIndexReportHandles.add(report.getString("handle"));
        }
      }
    });

    // Return the list of handles for type TEXT reports.
    return crossReportIndexReportHandles;
  }
}
