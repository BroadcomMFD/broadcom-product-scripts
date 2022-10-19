#!/usr/bin/env sh

DIR=gradle/wrapper
JAR=${DIR}/gradle-wrapper.jar

if [ ! -f ${DIR}/gradle-wrapper.jar ]; then
    echo "Gradle wrapper not found. Attempting to download..."

    mkdir -p "${DIR}"

    curl --silent --output ${DIR}/gradle-wrapper.jar \
            https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar
    if [ $? != 0 ]; then
        echo "Gradle wrapper jar download failed. Bootstrap failed."
        exit 1
    fi

    curl --silent --output ${DIR}/gradle-wrapper.properties \
            https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.properties
    if [ $? != 0 ]; then
        echo "Gradle wrapper properties download failed. Bootstrap failed."
        exit 2
    fi

    echo "Gradle wrapper download success. Bootstrap complete."
    exit 0
else
    exit 0
fi
