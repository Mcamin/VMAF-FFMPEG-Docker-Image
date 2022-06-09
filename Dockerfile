# Custom ffmpeg Dockerfile
# https://github.com/five82/ffmpeg-git
# https://github.com/jrottenberg/ffmpeg
# https://github.com/sitkevij/ffmpeg/
# Read Ubuntu https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# Versions:

# ffmpeg     - git master HEAD
# libvmaf    - git master HEAD
# libzimg    - git master HEAD
# libopus    - git master HEAD
# libx264    - git master HEAD
# libx265    - git master HEAD
# libsvtav1  - git master HEAD
# libaom     - git master HEAD
# fdk-aac    - git master HEAD
# libmp3lame - v3.100
# libvorbis  - v1.3.5
# libvpx     - v1.8.0

# Use Debian for our base image
FROM docker.io/debian:stable-slim AS build

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Set environemet variables
ENV SRC=/usr/local \
    LD_LIBRARY_PATH=${SRC}/lib \
    PKG_CONFIG_PATH=${SRC}/lib/pkgconfig \
    BIN=${SRC}/bin
#--------------------------------
# Update and install dependencies
#--------------------------------
# No, we're not going to version every apt package dependency.
# That's a bad idea in practice and will cause problems.



RUN \
buildDeps="autoconf \
    automake \
    build-essential \
    ca-certificates \
    cmake \
    doxygen \
    ninja-build \
    pkg-config \
    python3-pip \
    wget \
    python3-setuptools \
    python3-wheel \
    texinfo \
    git-core \
    nasm \
    yasm" && \
export MAKEFLAGS="-j$(($(nproc) + 1))" && \
apt-get -yqq update && \
apt-get install -yq \
--no-install-recommends ${buildDeps} && \
ffmpegDeps="libasound2 \
    libass-dev \
    libfreetype6-dev \
    libnuma-dev \
    libtool-bin \
    libsdl2-dev \
    libtool \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxcb1-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    python3 \
    zlib1g-dev" && \
apt-get install -yq \
--no-install-recommends ${ffmpegDeps} && \
#--------------
# Install meson
#--------------
pip3 install --no-cache-dir meson==0.57.1 && \
#------------------
# Setup directories
#------------------
mkdir -p /input /output /ffmpeg/ffmpeg_sources
#-------------
# Build ffmpeg
#-------------
RUN ./build_ffmpeg_vmaf.sh
#----------------------------------------------------
# Clean up directories and packages after compilation
#----------------------------------------------------
RUN pip3 uninstall meson -y && \
apt-get purge -y ${BUILD_DEP} && \
apt-get autoremove -y && \
apt-get install -y \
  --no-install-recommends \
  libsdl2-dev && \
apt-get clean && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /ffmpeg
#---------------------------------------
# Run ffmpeg when the container launches
#---------------------------------------
CMD ["ffmpeg"]
