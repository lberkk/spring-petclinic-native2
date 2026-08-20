FROM rockylinux:9

ARG MAVEN_VERSION=3.9.16
ARG TARGETARCH

ENV JAVA_HOME=/opt/graalvm
ENV PATH="${MAVEN_HOME}/bin:${JAVA_HOME}/:bin:${PATH}"

RUN dnf update -y && \
 dnf install -y gcc zlib-devel tar gzip curl && \
 dnf clean all

RUN case "${TARGETARCH}" in \
      amd64) echo "linux-x64" > /tmp/graalvm_arch ;; \
      arm64) echo "linux-aarch64" > /tmp/graalvm_arch ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac

RUN ARCH=$(cat /tmp/graalvm_arch) \
    && mkdir -p /opt/graalvm \
    && curl -L "https://gds.oracle.com/download/graal/25i2/latest/graalvm-jdk-25i2-25_${ARCH}_bin.tar.gz" -o /tmp/graalvm.tar.gz \
    && tar -xzf /tmp/graalvm.tar.gz -C /opt/graalvm --strip-components=1 \
    && rm /tmp/graalvm.tar.gz

RUN java -version && native-image --version

WORKDIR /workspace