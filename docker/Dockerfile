#
# Ryzom
#
# Multi-stage build requires docker 17.05 or newer
#
# GLIBC 2.27 ubuntu 18.04 / ubuntu:bionic
# GLIBC 2.23 ubuntu 16.04 / ubuntu:xenial
# GLIBC 2.24 debian 9 / debian:stetch
#
FROM ubuntu:xenial as base
LABEL maintainer="Meelis Mägi <nimetu@gmail.com>"

ENV RYZOM_EXTERNAL=/ryzom-external
ENV FINAL_VERSION=ON

RUN apt-get update -y && apt-get install -y \
		autoconf \
		automake \
		build-essential \
		cmake \
		debhelper \
		git \
		less \
		libboost-dev \
		libgl1-mesa-dev \
		libmysqlclient-dev \
		libqt4-dev \
		libqt4-opengl-dev \
		libtool \
		libxrandr-dev \
		libxrender-dev \
		libxxf86vm-dev \
		lintian \
		nano \
		pkg-config \
		quilt \
		vim \
		zlib1g-dev \
	&& apt-get clean

# ===============================
FROM base as lzma

ARG NAME=xz-utils
ARG VER=5.2.5
ARG SRC=${NAME}_${VER}.orig.tar.xz
ARG SUB=x
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x --xz --directory $SOURCEDIR \
	&& ./configure --prefix=$RYZOM_EXTERNAL --enable-shared=no --enable-static=yes \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/bin \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as libxml2

ARG NAME=libxml2
ARG VER=2.9.12
ARG SRC=${NAME}_${VER}+dfsg.orig.tar.xz
ARG SUB=libx
ARG SOURCEDIR=/tmp/${NAME}-${VER}

COPY --from=lzma /tmp/dest/$RYZOM_EXTERNAL $RYZOM_EXTERNAL

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x --xz --directory $SOURCEDIR \
	&& ./configure --prefix=$RYZOM_EXTERNAL CPPFLAGS=-I$RYZOM_EXTERNAL/include LDFLAGS=-L$RYZOM_EXTERNAL/lib --enable-shared=no --enable-static=yes --without-ftp --without-python --without-dockbook --without-debug \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r \
		/tmp/dest/$RYZOM_EXTERNAL/share \
		/tmp/dest/$RYZOM_EXTERNAL/bin/xmlcatalog \
		/tmp/dest/$RYZOM_EXTERNAL/bin/xmllint

# ===============================
FROM base as openssl

ARG NAME=openssl
ARG VER=1.1.1l
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=o
RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN cd /tmp \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar -xzC /tmp \
	&& cd /tmp/$NAME-$VER \
	&& ./config --prefix=$RYZOM_EXTERNAL --openssldir=$RYZOM_EXTERNAL no-shared \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install_sw \
	&& rm -fR \
		/tmp/dest/$RYZOM_EXTERNAL/bin \
		/tmp/dest/$RYZOM_EXTERNAL/lib/engines-1.1

# ===============================
FROM base as libcurl

ARG NAME=curl
ARG VER=7.74.0
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=c

COPY --from=openssl /tmp/dest/$RYZOM_EXTERNAL $RYZOM_EXTERNAL

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN cd /tmp \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar -xzC /tmp \
	&& mkdir /tmp/build && cd /tmp/build \
	&& cmake /tmp/$NAME-$VER \
		-DBUILD_CURL_EXE=OFF \
		-DBUILD_CURL_TESTS=OFF \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$RYZOM_EXTERNAL \
		-DCMAKE_PREFIX_PATH=$RYZOM_EXTERNAL \
		-DCMAKE_USE_OPENSSL=ON \
		-DCURL_STATICLIB=ON \
		-DENABLE_IPV6=ON \
		-DHTTP_ONLY=ON \
	&& make && make DESTDIR=/tmp/dest install

# ===============================
FROM base as libpng

ARG NAME=libpng1.6
ARG VER=1.6.28
ARG SRC=${NAME}_${VER}.orig.tar.xz
ARG SUB=libp
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x --xz --directory $SOURCEDIR \
	&& mkdir /tmp/build && cd /tmp/build \
	&& cmake $SOURCEDIR \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$RYZOM_EXTERNAL \
		-DCMAKE_PREFIX_PATH=$RYZOM_EXTERNAL \
		-DPNG_SHARED=OFF \
		-DPNG_STATIC=ON \
		-DSKIP_INSTALL_EXECUTABLES=ON \
		-DSKIP_INSTALL_EXPORT=ON \
		-DSKIP_INSTALL_FILES=ON \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install

# ===============================
FROM base as libjpeg

ARG NAME=libjpeg9
ARG VER=9d
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=libj
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& ./configure --prefix=$RYZOM_EXTERNAL --enable-shared=no --enable-static=yes \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/bin \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as giflib

ARG NAME=giflib
ARG VER=5.2.1
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=g
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& make -j2 \
	&& make PREFIX=$RYZOM_EXTERNAL DESTDIR=/tmp/dest install \
	&& rm -r \
		/tmp/dest/$RYZOM_EXTERNAL/bin \
		/tmp/dest/$RYZOM_EXTERNAL/lib/libgif.so* \
		/tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as libogg

ARG NAME=libogg
ARG VER=1.3.4
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=libo
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& ./configure --prefix=$RYZOM_EXTERNAL --enable-shared=no --enable-static=yes \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as libvorbis

ARG NAME=libvorbis
ARG VER=1.3.7
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=libv
ARG SOURCEDIR=/tmp/${NAME}-${VER}

COPY --from=libogg /tmp/dest/$RYZOM_EXTERNAL $RYZOM_EXTERNAL

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& ./configure --prefix=$RYZOM_EXTERNAL --enable-shared=no --enable-static=yes \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as freetype

ARG NAME=freetype
ARG VER=2.10.4
ARG SRC=${NAME}_${VER}+dfsg.orig.tar.xz
ARG SUB=f
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x --xz --directory $SOURCEDIR \
	&& mkdir /tmp/build && cd /tmp/build \
	&& cmake $SOURCEDIR \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$RYZOM_EXTERNAL \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r /tmp/dest/$RYZOM_EXTERNAL/lib/cmake

# ===============================
FROM base as lua53

RUN apt-get update && apt-get install -y \
		libreadline-dev \
	&& apt-get clean

ARG NAME=lua5.3
ARG VER=5.3.3
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=l
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& make linux \
	&& make INSTALL_TOP=/tmp/dest/$RYZOM_EXTERNAL install \
	&& rm -r \
		/tmp/dest/$RYZOM_EXTERNAL/bin \
		/tmp/dest/$RYZOM_EXTERNAL/man \
		/tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
FROM base as luabind

RUN apt-get update && apt-get install -y \
		libboost-tools-dev \
	&& apt-get clean

ARG NAME=luabind
ARG VER=0.9.1
ARG SRC=${NAME}_${VER}+dfsg.orig.tar.gz
ARG DEBSRC=${NAME}_${VER}+dfsg-11.debian.tar.xz
ARG SUB=l
ARG SOURCEDIR=/tmp/${NAME}-${VER}

COPY --from=lua53 /tmp/dest/$RYZOM_EXTERNAL $RYZOM_EXTERNAL

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$DEBSRC | tar -x --xz --directory $SOURCEDIR \
	&& QUILT_PATCHES=$SOURCEDIR/debian/patches quilt push -a \
	&& export LUA_PATH=$RYZOM_EXTERNAL \
	&& export DEB_HOST_MULTIARCH="" \
	&& bjam -d2 cxxflags=-fPIC link=static release install \
	&& bjam -d2 --prefix=/tmp/dest/$RYZOM_EXTERNAL --libdir=/tmp/dest/$RYZOM_EXTERNAL/lib link=static release install \
	# some files in luabind have +x bit set
	&& find /tmp/dest/$RYZOM_EXTERNAL/ -type f -exec chmod 0644 {} +

# ===============================
FROM base as openal

RUN apt-get update && apt-get install -y \
		libasound2-dev \
		libjack-dev \
		libpulse-dev \
	&& apt-get clean

ARG NAME=openal-soft
ARG VER=1.19.1
ARG SRC=${NAME}_${VER}.orig.tar.gz
ARG SUB=o
ARG SOURCEDIR=/tmp/${NAME}-${VER}

RUN sh -c "echo \"Compiling $SUB/$NAME/$SRC\""
RUN mkdir $SOURCEDIR && cd $SOURCEDIR \
	&& curl -SL https://ftp.debian.org/debian/pool/main/$SUB/$NAME/$SRC | tar --strip-components=1 -x -z --directory $SOURCEDIR \
	&& mkdir /tmp/build && cd /tmp/build \
	&& cmake $SOURCEDIR \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$RYZOM_EXTERNAL \
		-DLIBTYPE=STATIC \
	&& make -j2 \
	&& make DESTDIR=/tmp/dest install \
	&& rm -r \
		/tmp/dest/$RYZOM_EXTERNAL/bin \
		/tmp/dest/$RYZOM_EXTERNAL/share

# ===============================
# = Final container
FROM base

COPY --from=lzma      /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libxml2   /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=openssl   /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libcurl   /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libpng    /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libjpeg   /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=giflib    /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libogg    /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=libvorbis /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=freetype  /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=lua53     /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=luabind   /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}
COPY --from=openal    /tmp/dest/${RYZOM_EXTERNAL} ${RYZOM_EXTERNAL}

WORKDIR /ryzom

COPY ./docker-entrypoint.sh /usr/local/bin
COPY ./rc-build.sh          /usr/local/bin

RUN useradd -ms /bin/bash ryzom
RUN mkdir -p /build && chown ryzom.ryzom /build

USER ryzom

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["build-client"]

