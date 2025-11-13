#!/usr/bin/env sh

DIR=gradle/wrapper
JAR=${DIR}/gradle-wrapper.jar
GRADLE_WRAPPER_GITHUB_URL="https://raw.githubusercontent.com/gradle/gradle/refs/tags/v8.14.3/gradle/wrapper"

if [ ! -f ${DIR}/gradle-wrapper.jar ]; then
    echo "Gradle wrapper not found. Attempting to download..."

    mkdir -p "${DIR}"

    curl --silent --output ${DIR}/gradle-wrapper.jar ${GRADLE_WRAPPER_GITHUB_URL}/gradle-wrapper.jar
    if [ $? != 0 ]; then
        echo "Gradle wrapper jar download failed. Bootstrap failed."
        exit 1
    fi

    curl --silent --output ${DIR}/gradle-wrapper.properties ${GRADLE_WRAPPER_GITHUB_URL}/gradle-wrapper.properties
    if [ $? != 0 ]; then
        echo "Gradle wrapper properties download failed. Bootstrap failed."
        exit 2
    fi

    echo "Gradle wrapper download success. Bootstrap complete."
    exit 0
else
    exit 0
fi
