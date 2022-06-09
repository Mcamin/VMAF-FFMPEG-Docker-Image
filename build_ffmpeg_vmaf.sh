#!/bin/bash

# Compile and install ffmpeg.
# Environment setup and packages dependencies are handled by the Dockerfile.

#----------------
# Download source
#----------------
cd /ffmpeg/ffmpeg_sources || exit
mkdir libmp3lame libvorbis libvpx
git clone https://github.com/sekrit-twc/zimg.git zimg
git clone https://github.com/Netflix/vmaf.git vmaf
git clone --depth 1 https://github.com/xiph/opus.git opus
git clone --depth 1 https://code.videolan.org/videolan/x264.git x264
git clone https://github.com/videolan/x265.git x265
git clone https://github.com/AOMediaCodec/SVT-AV1.git SVT-AV1
git clone https://aomedia.googlesource.com/aom aom
git clone https://github.com/FFmpeg/FFmpeg ffmpeg
git clone https://github.com/mstorsjo/fdk-aac fdk-aac
wget https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download -O /ffmpeg/ffmpeg_sources/libmp3lame/lame-3.100.tar.gz
wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.gz -O /ffmpeg/ffmpeg_sources/libvorbis/libvorbis-1.3.5.tar.gz
wget https://codeload.github.com/webmproject/libvpx/tar.gz/v1.8.0 -O /ffmpeg/ffmpeg_sources/libvpx/libvpx-1.8.0.tar.gz

#-------------------
# Compile z.lib/zimg
#-------------------
cd /ffmpeg/ffmpeg_sources/zimg || exit
./autogen.sh
./configure
make && \
make install

#----------------
# Compile libvmaf
#----------------
cd /ffmpeg/ffmpeg_sources/vmaf/libvmaf || exit
meson build --buildtype release
ninja -vC build
ninja -vC build install
mkdir -p /usr/local/share/model/
cp -r /ffmpeg/ffmpeg_sources/vmaf/model/* /usr/local/share/model/

#----------------
# Compile libopus
#----------------
cd /ffmpeg/ffmpeg_sources/opus || exit
./autogen.sh
./configure
make && \
make install

#------------------
# Compile libsvtav1
#------------------
cd /ffmpeg/ffmpeg_sources/SVT-AV1/Build || exit
cmake .. -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
make && \
make install

#----------------
# Compile libx264
#----------------
cd /ffmpeg/ffmpeg_sources/x264 || exit
./configure \
  --enable-static \
  --enable-pic
make && \
make install && \
make distclean

#----------------
# Compile libx265
#----------------
cd /ffmpeg/ffmpeg_sources/x265/build/linux || exit
cmake -G "Unix Makefiles" \
  -DHIGH_BIT_DEPTH=on \
  -DENABLE_CLI=OFF \
  ../../source && \
make && \
make install && \
make clean

#---------------
# Compile libaom
#---------------
cd /ffmpeg/ffmpeg_sources/aom || exit
mkdir -p ../aom_build
cd ../aom_build || exit
cmake /ffmpeg/ffmpeg_sources/aom -DBUILD_SHARED_LIBS=1 && \
make && \
make install

#---------------
# Compile fdk-aac
#---------------
cd /ffmpeg/ffmpeg_sources/fdk-aac || exit
autoreconf -fiv && \
./configure && \
make && \
make install

#---------------
# Compile libmp3lame
#---------------
cd /ffmpeg/ffmpeg_sources/libmp3lame || exit
tar -zx --strip-components=1 -f lame-3.100.tar.gz && \
./configure --enable-nasm --disable-frontend && \
make && \
make install

# Compile libvorbis
#---------------
cd /ffmpeg/ffmpeg_sources/libvorbis || exit
tar -zx --strip-components=1 -f libvorbis-1.3.5.tar.gz && \
./configure && \
make && \
make install

# Compile libvpx
#---------------
cd /ffmpeg/ffmpeg_sources/libvpx || exit
tar -zx --strip-components=1 -f libvpx-1.8.0.tar.gz && \
./configure --enable-vp8 --enable-vp9 --enable-vp9-highbitdepth --enable-pic \
--disable-debug --disable-examples --disable-docs --disable-install-bins && \
make && \
make install

#---------------
# Compile ffmpeg
#---------------
cd /ffmpeg/ffmpeg_sources/ffmpeg || exit
./configure \
#--prefix="${SRC}" --extra-cflags="-I${SRC}/include" --pkg-config-flags="--static" --extra-ldflags="-L${SRC}/lib" --bindir="${SRC}/bin" \
  --disable-static \
  --disable-debug \
  --disable-doc \
  --disable-ffplay \
  --enable-shared \
  --enable-libfreetype \
  --enable-libzimg \
  --enable-libsvtav1 \
  --enable-postproc \
  --enable-small \
  # FAME Packages
  --enable-gpl \
  --enable-libaom \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree \
  --enable-libvmaf \
  --enable-version3
make && \
make install && \
hash -r
