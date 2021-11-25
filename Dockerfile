FROM ubuntu:20.04

MAINTAINER Jonas Weber <jonas.weber@dlr.de>
LABEL Description="MITK on Ubuntu 20.04 for creating plugins base on the MITK-ProjectTemplate."

ARG MITK_VERSION=2021.10
ARG CMAKE_VERSION=3.22.0
ARG NINJA_VERSION=1.10.2

WORKDIR /work

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
        wget \
        unzip \
        qt5-default \
        libqt5xmlpatterns5-dev \
        qtwebengine5-dev \
        qtscript5-dev \
        libqt5x11extras5-dev && \
        rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=newt

# Install CMake
RUN wget -nv "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" && \
    tar -xzf "cmake-$CMAKE_VERSION-linux-x86_64.tar.gz" && \
    rm cmake-$CMAKE_VERSION-linux-x86_64.tar.gz
ENV PATH="/work/cmake-$CMAKE_VERSION-linux-x86_64/bin:$PATH"

# Install ninja-build
RUN wget -nv "https://github.com/ninja-build/ninja/releases/download/v$NINJA_VERSION/ninja-linux.zip" && \
    mkdir ninja && \
    unzip -d ninja ninja-linux.zip && \
    rm ninja ninja-linux.zip
ENV PATH="/work/ninja:$PATH"

# Prepare MITK
RUN git clone --branch "v$MITK_VERSION" https://github.com/MITK/MITK.git MITK && \
    mkdir MITK-superbuild && \
    cd MITK-superbuild && \
    cmake \
        -G"Ninja" \
        -DMITK_USE_BLUEBERRY:BOOL=ON \
        -DMITK_USE_Qt5:BOOL=ON \
        ../MITK

# Build MITK
RUN cd MITK-superbuild && \
    ninja
