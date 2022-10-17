# Web Viewer - Basic API Operations Sample

## Overview

The samples in this directory demonstrate the following basic aspects of using the
Web Viewer REST API:

  * Authentication
    * Authenticate with a username and password.
    * Log out - invalidate the guid (session token).
  * Search for Reports
    * List repositories.
    * List reports and apply a subset of filters.
    * Print report content with and without metadata.
  * Search for Cross-Report Index Values
    * List cross-report index names and apply a subset of filters.
    * List cross-report index values and apply a subset of filters.
    * List reports with a cross-report index value and apply a subset of filters.
    * Print content of reports that are filtered by an index value.
  * Error Handling
    * Shows how to handle a failed request.
      * (check status, use messages)

Comments in the code describe the implementation.

Two versions of the samples are provided written in two languages and targetting different
runtime environments:

- [java](java) - Written in Java and running in a Java Virtual Machine
- [vba](vba) - Written in Visual Basic for Applications and running in Microsoft Excel

Refer to the README files in the sub-directories for information on how to build and
run the samples.
