#!/usr/bin/env sh

DIR=gradle/wrapper
GRADLE_VERSION=9.7.1
GRADLE_WRAPPER_GITHUB_URL="https://raw.githubusercontent.com/gradle/gradle/refs/tags/v${GRADLE_VERSION}/gradle/wrapper"
GRADLE_DISTRIBUTION_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

if [ ! -f ${DIR}/gradle-wrapper.jar ]; then
    echo "Gradle wrapper not found. Attempting to download..."

    mkdir -p "${DIR}"

    curl --silent --output ${DIR}/gradle-wrapper.jar ${GRADLE_WRAPPER_GITHUB_URL}/gradle-wrapper.jar
    if [ $? != 0 ]; then
        echo "Gradle wrapper jar download failed. Bootstrap failed."
        exit 1
    fi

    echo "distributionUrl=${GRADLE_DISTRIBUTION_URL}" > ${DIR}/gradle-wrapper.properties

    echo "Gradle wrapper download success. Bootstrap complete."
    exit 0
else
    exit 0
fi
