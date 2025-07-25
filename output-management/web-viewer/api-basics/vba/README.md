# Web Viewer - Basic API Operations Sample - VBA

## Prerequisites

Install and configure the following:

  * Microsoft Excel Office 365.
    * Grant trust access to the VBA project object model: Select File > Options > Trust Center > Trust Center Settings... > Macro Settings. Enable "Trust access to the VBA project object model".
    * Enable the Developer Tab: Select File > Options > Customize Ribbon. Enable "Developer" in Customize the Ribbon.
    * Go to Developer > Visual Basic > Tools > References, de-select all versions of Microsoft XML, vx.x, and select the following:
      * Microsoft XML, v3.0.
      * Microsoft Forms 2.0 Object Library.
      * Microsoft Scripting Runtime.
      * Microsoft Visual Basic for application Extensibility 5.3.
      * Visual Basic For Applications (On by default).
      * Microsoft Excel 16.0 Object library (On by default).
      * Microsoft Office 16.0 Object library (On by default).
      * OLE Automation (On by default).
  * Obtain server address and port number to access OM Web Viewer 14.0.
      * The minimal supported OM Web Viewer build is 14.0.68. Ensure that PTF LU11643 is applied. 
  
## Dependencies

The following third-party dependencies are used by the sample code:

  * Microsoft XML, v3.0: Used for REST API processing and Base64 conversion.
  * Microsoft Forms 2.0 Object Library: Used to provide UI forms.
  * Microsoft Scripting Runtime: Used to access json elements converted by VBA-JSON.
  * Microsoft Visual Basic for application Extensibility 5.3: Used for inserting code into an Excel sheet and for importing/exporting modules/classModules to and from Excel.
  * [VBA-JSON](https://github.com/VBA-tools/VBA-JSON/releases/tag/v2.3.0): Used to parse responses from REST API requests.

## Execute

1. Open the provided 'web-viewer-api-basics.xlsm' file and select "Run Demo" or enter "Ctrl + Shift + R" to see the authentication form.
2. To perform an operation, double-click any cell that contains dynamically-generated product data.
3. Select "Log out" on the API sheet or enter "Ctrl + Shift + L" to log out.
4. You can save your progress and continue on the same Excel worksheet. You need to re-authenticate each time that you quit or log out.
        
## VBA Code Structure

  * Microsoft Excel Objects
    * Any new sheet added as a result of an operation. Automation code populates automatically to each new worksheet.
  * Forms
    * frmCrossRptIndexNameFilter - Accepts and processes user input to filter cross-report index names.
    * frmCrossRptIndexValueFilter - Accepts and processes user input to filter cross-report index values.
    * frmDemo - Accepts server address and port.
    * frmIndexOrReportSelector - Specifies whether to list reports or cross-report index names for a specified repository.
    * frmLogin - Accepts the username and password to authenticate.
    * frmPleaseWait - Indicates that the background process runs when the user performs an operation.
    * frmReportListFilter - Accepts and processes user input to filter a report list.
  * Modules
    * JsonConverter - Converts a JSON string to a JSON object and parses the object.
    * modApiConstants - Constants for the REST API URLs.
    * modApiQueryError - Processes each error response from the REST API.
    * modAuthenticate - REST API call for the Login and Logout services
    * modDemo - Main subroutine to authenticate and list repositories.
    * modListCrossRptIdxNames - REST API call to get cross-report index names.
    * modListCrossRptIdxValueReports - REST API call to get reports which contain cross-report index values.
    * modListCrossRptIdxValues - REST API call to get cross-report index values.
    * modListReports - REST API call to get a list of reports.
    * modListRepositories - REST API call to get a list of repositories.
    * modPrintRptContent - REST API call to print report content.
    * modServiceUtils - Base64-conversion utilities and utility functions to print response messages
    * modSheetSelectionCode - Contains functions which enable operations when you double-click any cell that contains data.
  * Code Modules
    * CCrossReportIndexNamesFilter - Query parameter class that filters the GET cross-report index names operation.
    * CCrossReportIndexValuesFilter - Query parameter class that filters the GET cross-report index values operation.
    * CReportListFilter - Query parameter class of filters that you can apply to the GET report list operation.
    * CWorkbookUtil - Workbook utility class to create a new workbook, and add data, messages, header and automation code to worksheets.
