FROM rockylinux/rockylinux:9

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ARG GRAALVM_RELEASE_TAG=graal-25.1.3
ARG GRAALVM_ARCHIVE_VERSION=25i1-25.0.3

ENV JAVA_HOME=/opt/graalvm
ENV PATH="${JAVA_HOME}/bin:${PATH}"

WORKDIR /workspace

COPY . . 

RUN --mount=type=bind,source=build-image.sh,target=/tmp/build-image.sh \
    bash /tmp/build-image.sh run