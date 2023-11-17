FROM rust:slim-bookworm

RUN apt-get update && \
    apt-get install -yq wget unzip && \
    mkdir /opt/gradle && \
    cd /opt/gradle && \
    wget "https://services.gradle.org/distributions/gradle-8.4-bin.zip" -O gradle.zip && \
    unzip -d /opt/gradle gradle.zip && \
    mv gradle-*/* . && \
    rm gradle.zip && \
    rmdir gradle-* && \
    apt-get remove -yq wget unzip
    
ENV PATH="${PATH}:/opt/gradle/bin"

RUN apt-get update && \
    apt-get install -yq openjdk-17-jre-headless openjdk-17-jdk-headless clang lld pkg-config libssl-dev wget unzip && \
    rustup toolchain install 1.74.0 && \
    rustup default 1.74.0

RUN cargo install xbuild

# Install Android SDK
ENV ANDROID_HOME /opt/android-sdk-linux
RUN mkdir -p "${ANDROID_HOME}/cmdline-tools" && \
    cd "${ANDROID_HOME}/cmdline-tools" && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip -q commandlinetools-linux-10406996_latest.zip && \
    mv cmdline-tools latest && \
    rm commandlinetools-linux-10406996_latest.zip && \
    chown -R root:root /opt
RUN mkdir -p ~/.android && touch ~/.android/repositories.cfg
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" | grep -v = || true
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platforms;android-31" | grep -v = || true
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "build-tools;31.0.0"  | grep -v = || true
RUN ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --update | grep -v = || true

RUN mkdir /root/src
WORKDIR /root/src
