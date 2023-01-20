# Web Viewer - Favorites Application Sample

## Overview

This sample uses the Web Viewer REST API to implement a favorites application
that allows the user to define, save, and repeatedly execute favorites.

A favorite defines a set of TEXT reports that will be downloaded.
In each favorite the user can customize:

- The repository (View database)
- The user mode and distribution id
- The set of reports
- The number of (latest) versions of each report to download
- Whether the reports should be downloaded as:
    - Individual text files
    - Individual PDF files
    - A single combined text file

When a favorite is executed the configured content is downloaded to the
application working directory.

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

The built distributable packages are saved in the `favorites/build/distributions` directory.

### Run

You can start the application directly using the following commands.

Windows:

    npm run start

Other OS:

    npm run generate-sdk
    ./gradlew run