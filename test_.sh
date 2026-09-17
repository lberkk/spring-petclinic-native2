#!/bin/bash

set -e

export JAVA_HOME=$(dirname $(dirname $(which java)))
export GRAALVM_HOME="$JAVA_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

PROJECT_PATH="$1"

cd "$PROJECT_PATH"


if [ -f "./mvnw" ]; then
chmod +x ./mvnw
MAVEN="./mvnw"
else
MAVEN="mvn"
fi

"$MAVEN" clean

AGENT_DIR="./META-INF/native-image"
mkdir -p "$AGENT_DIR"

MAVEN_OPTS="-agentlib:native-image-agent=config-output-dir=$AGENT_DIR" "$MAVEN" test

GRAALVM_HOME="$GRAALVM_HOME" "$MAVEN" -Pnative org.graalvm.buildtools:native-maven-plugin:0.10.2:compile -DskipTests -Dspring-boot.aot.enabled=true
