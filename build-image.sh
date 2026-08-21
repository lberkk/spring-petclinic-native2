#!/bin/bash

set -euo pipefail

GRAALVM_BASE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download

detect_arch() {
    case "$(uname -m)" in 
    x86_64) echo "linux-x64" ;;
    aarch64|arm64) echo "linux-aarch64" ;;
    esac
}

build() {
    dnf -y install gcc glibc-devel zlib-devel
    dnf clean all
    rm -rf /var/cache/dnf

    local arch url
    arch=$(detect_arch)
    url="${GRAALVM_BASE_URL}/${GRAALVM_RELEASE_TAG}/graalvm-community-jdk-${GRAALVM_ARCHIVE_VERSION}_${arch}_bin.tar.gz"
    echo "$url"
    mkdir -p "$JAVA_HOME"
    curl -fL "$url" | tar -xz -C "$JAVA_HOME" --strip-components=1

    "$JAVA_HOME/bin/java" --version
    "$JAVA_HOME/bin/native-image" --version
}

run() {
    build
    ./mvnw -Pnative -DskipTests native:compile
}

case "${1:-}" in
    build) build ;;
    run) run ;;
    esac