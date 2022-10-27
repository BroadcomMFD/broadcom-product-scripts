# Web Viewer - Simple Batch Downloader Application Sample

## Overview

This sample uses the Web Viewer REST API to implement a simple batch
downloader for TEXT reports. It supports downloading reports that are
online or accessible through EAS.

The following can be specified:

- The repository (View database)
- The user mode and distribution id
- A report name (ID) filter including wildcards
- The archival date range
- The location where the reports will be downloaded into

All selected reports are downloaded into a single combined file.

The tool also contains a preview function that shows summary information
about reports matching the specified criteria, before starting the download.

## Development Environment

### Prerequisites

The following software must be installed on the machine in order to build the application:

- [Node.js](https://nodejs.org/en/)
- [Java SDK 17+](https://adoptium.net/)

The system `PATH` must include the `node` and `npm` executables.

The `JAVA_HOME` environment variable must point to the directory containing the Java SDK.

### First-time Initialization

Before you build the application for the first time, execute the following initialization commands
once.

Windows:

    gradle/bootstrap/bootstrap-gradlew.bat
    npm ci

Other OS:

    gradle/bootstrap/bootstrap-gradlew.sh
    npm ci

### Build

Use the following commands to build the application.

Windows:

    npm run build

Other OS:

    npm run generate-sdk
    ./gradlew build

The built distributable packages are saved in the `application/build/distributions` directory.

### Run

You can start the application directly using the following commands.

Windows:

    npm run start

Other OS:

    npm run generate-sdk
    ./gradlew run
