@echo off

SET GRADLE_VERSION=9.7.1
SET GRADLE_WRAPPER_GITHUB_URL="https://raw.githubusercontent.com/gradle/gradle/refs/tags/v%GRADLE_VERSION%/gradle/wrapper"
SET "GRADLE_DISTRIBUTION_URL=https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip"

if not exist gradle\wrapper\gradle-wrapper.jar (
    echo Gradle wrapper not found. Attempting to download...

    mkdir gradle\wrapper

    powershell -Command "& {wget %GRADLE_WRAPPER_GITHUB_URL%/gradle-wrapper.jar -OutFile gradle/wrapper/gradle-wrapper.jar}"
    IF ERRORLEVEL 1  (
        echo Gradle wrapper jar download failed. Bootstrap failed.
    )

    echo distributionUrl=%GRADLE_DISTRIBUTION_URL%> gradle\wrapper\gradle-wrapper.properties

    echo Gradle wrapper download success. Bootstrap complete.
)
