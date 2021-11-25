# ubuntu:20.04
FROM ubuntu@sha256:7cc0576c7c0ec2384de5cbf245f41567e922aab1b075f3e8ad565f508032df17

MAINTAINER Jonas Weber <jonas.weber@dlr.de>
LABEL Description="MITK on Ubuntu 20.04 for creating plugins based on the MITK-ProjectTemplate (https://github.com/MITK/MITK-ProjectTemplate)."

ARG MITK_VERSION=2021.10
ARG CMAKE_VERSION=3.22.0
ARG NINJA_VERSION=1.10.2

WORKDIR /work

# Install tools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        wget \
        unzip && \
# Install CMake
    wget -nv "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" && \
    tar -xzf "cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" && \
# Install ninja
    wget -nv "https://github.com/ninja-build/ninja/releases/download/v$NINJA_VERSION/ninja-linux.zip" && \
    mkdir ninja && \
    unzip -d ninja ninja-linux.zip && \
# Cleanup
    rm cmake-$CMAKE_VERSION-linux-x86_64.tar.gz && \
    rm ninja-linux.zip
ENV DEBIAN_FRONTEND=newt

# Add tools to $PATH
ENV PATH="/work/ninja:$PATH"
ENV PATH="/work/cmake-$CMAKE_VERSION-linux-x86_64/bin:$PATH"

# Clone MITK and MITK-ProjectTemplate
# (Do this first since this step won't ever change until $MITK_VERSION is changed.
RUN git clone --branch "v$MITK_VERSION" https://github.com/MITK/MITK.git MITK && \
    git clone --branch "v$MITK_VERSION" https://github.com/MITK/MITK-ProjectTemplate.git extensions

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
# MITK dependencies
        build-essential \
        doxygen \
        git \
        graphviz \
        libfreetype6-dev \
        libglu1-mesa-dev \
        libssl-dev \
        libtiff5-dev \
        libwrap0-dev \
        libxcomposite1 \
        libxcursor1 \
        libxdamage-dev \
        libxi-dev \
        libxkbcommon-x11-0 \
        libxt-dev \
        mesa-common-dev \
# Qt5
        libqt5x11extras5-dev \
        libqt5opengl5-dev \
        libqt5svg5-dev \
        libqt5xmlpatterns5-dev \
        qt5-default \
        qtscript5-dev \
        qttools5-dev \
        qtwebengine5-dev && \
# Cleanup
    rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=newt

# Prepare MITK
RUN mkdir MITK-superbuild && \
    cd MITK-superbuild && \
    cmake \
        -G"Ninja" \
        -DMITK_EXTENSION_DIRS:PATH=/work/extensions \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DBUILD_TESTING:BOOL=OFF \
        ../MITK

# Build MITK
RUN cd MITK-superbuild && \
    ninja

# Remove the extensions directory so that custom extensions can be added
RUN rm -rf extensions
