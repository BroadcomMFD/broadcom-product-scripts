@echo off

if not exist gradle\wrapper\gradle-wrapper.jar (
    echo Gradle wrapper not found. Attempting to download...

    mkdir gradle\wrapper

    powershell -Command "& {wget https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar -OutFile gradle/wrapper/gradle-wrapper.jar}"
    IF ERRORLEVEL 1  (
        echo Gradle wrapper jar download failed. Bootstrap failed.
    )

    powershell -Command "& {wget https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.properties -OutFile gradle/wrapper/gradle-wrapper.properties}"
    IF ERRORLEVEL 1  (
        echo Gradle wrapper properties download failed. Bootstrap failed.
    )

    echo Gradle wrapper download success. Bootstrap complete.
)
