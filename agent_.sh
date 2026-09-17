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

AGENT_DIR="${AGENT_DIR:-$PWD/src/main/resources/}"

rm -rf "$AGENT_DIR"
mkdir -p "$AGENT_DIR"

"$MAVEN" package -DskipTests


APP_JAR="$(for j in target/*.jar; do

  if unzip -p "$j" META-INF/MANIFEST.MF 2>/dev/null | grep -qi '^Main-Class:'; then

    echo "$j"

    break

  fi

done)"

"$JAVA_HOME/bin/java" -agentlib:native-image-agent=config-merge-dir="$AGENT_DIR" -jar "$APP_JAR" & AGENT_PID=$!

read -r -n 1 -s _

kill "$AGENT_PID" 2>/dev/null || true
wait "$AGENT_PID" 2>/dev/null || true

GRAALVM_HOME="$GRAALVM_HOME" "$MAVEN" -Pnative org.graalvm.buildtools:native-maven-plugin:compile -DskipTests -Dnative.image.build.args="-H:ConfigurationFileDirectories=$AGENT_DIR -H:Preserve=all"
