# Web Viewer - Basic API Operations Sample - Java

## Prerequisites

Install and configure the following:

  * Java version 8 or later.
  * One of the following build tools:
    * [Maven](https://maven.apache.org/download.cgi) version 3.8 or 3.9.
    * [Gradle](https://gradle.org/releases) version 8 or 9.
  * Any source code editor.
  * Server address and port number to access Web Viewer 14.0.

## External Dependencies

The following third-party dependencies are used by the sample code:

  * [org.json](https://mvnrepository.com/artifact/org.json/json): Used to parse responses from REST API requests.
  * [commons-cli](https://mvnrepository.com/artifact/commons-cli/commons-cli): Used to process input parameters.

## Build

### Maven

  * Navigate to source root and execute the command 'mvn clean package' from the command line.
  * A fat jar file with all dependencies named 'Web-Viewer-JavaSamples.jar' is built in the /target folder.
  * Note: A Javadoc for the code is also built, which includes details for all functions and their parameters.

### Gradle

  * Navigate to source root and execute the command 'gradle build' from the command line.
  * A fat jar file with all dependencies named 'Web-Viewer-JavaSamples.jar' is built in the /build/libs folder.
  * Note: A Javadoc for the code is also built, which includes details for all functions and their parameters.

## Credentials

Credentials are not accepted as command-line arguments, since a command-line argument is visible
to other local users (via the process list) and is typically persisted in shell history. Instead,
set the `WV_USERNAME` and `WV_PASSWORD` environment variables before running the sample.

A template is provided for each shell so you can keep your credentials in a local file instead of
typing them on the command line. Copy the template for your shell from the source root to a new file
and fill in your credentials. The file stores your password in plain text, so keep it private and
never commit it:

* Linux / macOS: `cp credentials.env.sample credentials.env`
* Windows (PowerShell): `Copy-Item credentials.env.ps1.sample credentials.env.ps1`

Then, from the source root, load the file into your current terminal session before running the
sample from that same session:

* Linux / macOS: `source credentials.env`
* Windows (PowerShell): `. .\credentials.env.ps1`
  > [!NOTE]
  > The leading dot is required, and it must be followed by a space. Without it the variables are
  > discarded, and the sample reports missing credentials.

## Execute

Navigate to '/target' or '/build/libs' depending on the chosen build method, and execute one of the
following commands from the command line. For operations that are specified by `-o` the environment
variables must be populated with the credentials, as described above.

Execute the following command to get a list of all arguments with details.

```
java -jar Web-Viewer-JavaSamples.jar -h
```

Execute the following command to log in and log out. Note: You can use the command to test server connectivity.

```
java -jar Web-Viewer-JavaSamples.jar -o 1 -b <server HTTPS address and port>
```

Execute the following command to print report content. See the REST API documentation for details on parameter syntax and semantics.

```
java -jar Web-Viewer-JavaSamples.jar -o 2 -b <server HTTPS address and port> -fr <reportName filter> -ff <arcDateFrom filter> -ft <arcDateTo filter>
```

Execute the following commands to print report content and apply index filters. See the REST API documentation for details on parameter syntax and semantics.

```
java -jar Web-Viewer-JavaSamples.jar -o 3 -b <server HTTPS address and port> -fr <reportName filter> -ff <arcDateFrom filter> -ft <arcDateTo filter> -fn <nameFilter separated by ",">
java -jar Web-Viewer-JavaSamples.jar -o 3 -b <server HTTPS address and port> -fr <reportName filter> -ff <arcDateFrom filter> -ft <arcDateTo filter> -fn <nameFilter separated by ","> -fv <valueFilter separated by ",">
```

> [!NOTE]
> The HTTP protocol is not secure. Use HTTPS only.

## Java Package Structure

  * model - Package for the query filter parameter class.
    * CrossReportIndexNamesFilter - Query parameter class that filters the GET cross-report index names operation.
    * CrossReportIndexValuesFilter - Query parameter class that filters the GET cross-report index values operation.
    * ReportListFilter - Query parameter class of filters that you can apply to the GET report list operation.
  * service - Package for processing all REST API responses.
    * Authentication - Log in and log out of the application.
    * ListCrossReportIndex - Get cross-report index names, cross-report index values, and cross-report index-value reports.
    * ListReports - Get a list of reports.
    * ListRepositories - Get a list of repositories.
    * PrintReportContent - Print report content.
  * util - Package for all common utilities and helper functions.
    * ApiConstants - Constants for the REST API URLs.
    * ApiQueryException - Exception class for unsuccessful REST API operation.
    * RequestUtility - Utility class for common codes. This utility includes functions for default GET operations, with all pre-processing, to convert responses to json, and to print response messages.
  * Demo - Utility class, which parses user parameters and calls the following services: authentication, display report content without indexing filters applied, and display report content with indexing filters applied.
