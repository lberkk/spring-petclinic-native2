FROM rockylinux/rockylinux:9

ARG MAVEN_VERSION=3.9.16
ARG GRAALVM_VERSION=25.1.3
ARG GRAALVM_RELEASE_TAG=graal-25.1.3
ARG GRAALVM_ARCHIVE_VERSION=25i1-25.0.3
ARG GRAALVM_ARCH=linux-x64

WORKDIR /tmp

ENV JAVA_HOME=/opt/graalvm
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN dnf -y install gcc glibc-devel zlib-devel && \
    dnf clean all && rm -rf /var/cache/dnf

RUN mkdir -p /opt/graalvm \
    && curl -fsSL "https://github.com/graalvm/graalvm-ce-builds/releases/download/${GRAALVM_RELEASE_TAG}/graalvm-community-jdk-${GRAALVM_ARCHIVE_VERSION}_${GRAALVM_ARCH}_bin.tar.gz" \
      -o graalvm.tar.gz \
    && tar -xzf graalvm.tar.gz -C /opt/graalvm --strip-components=1 \
    && rm graalvm.tar.gz

COPY . /workspace

RUN cd /workspace && ./mvnw -Pnative -DskipTests native:compile