#!/bin/sh

set -ue

if [ ! -f /ryzom/CMakeLists.txt ]; then
	echo "ERROR: /ryzom does not contain ryzom sources (missing CMakeLists.txt)"
	echo "Container must be run in ryzom sources directory (or 'code' directory if that exists)"
	exit 1
fi

TAG=${TAG:-}
if [ -z "${TAG}" ]; then
	. /etc/os-release
	TAG=${ID}-${VERSION_ID}
fi

DESTDIR=/ryzom/install_${TAG}
BUILD_ROOT=/ryzom/build_${TAG}

CMD=${1:-}
if [ -z "${CMD}" ]; then
	CMAKE_OPTIONS="
	-DCMAKE_BUILD_TYPE=Release
	-DCMAKE_PREFIX_PATH=$RYZOM_EXTERNAL
	-DFINAL_VERSION=$FINAL_VERSION
	-DWITH_NEL_SAMPLES=OFF
	-DWITH_NEL_TESTS=OFF
	-DWITH_NEL_TOOLS=OFF
	-DWITH_QT=OFF
	-DWITH_RYZOM_CLIENT=ON
	-DWITH_RYZOM_SERVER=OFF
	-DWITH_RYZOM_TOOLS=OFF
	-DWITH_STATIC=ON
	-DWITH_STATIC_DRIVERS=ON
	-DWITH_STATIC_EXTERNAL=ON
	"
else
	# custom options from command line
	CMAKE_OPTIONS="-DCMAKE_PREFIX_PATH=$RYZOM_EXTERNAL $@"
fi

# create directories
install -d "$BUILD_ROOT"
cd "$BUILD_ROOT" || exit 1

CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-/usr/local}
cmake $CMAKE_OPTIONS -DCMAKE_INSTALL_PREFIX=$CMAKE_INSTALL_PREFIX /ryzom || exit 1

make

install -d $DESTDIR
[ -f bin/ryzom_client ]    && cp bin/ryzom_client $DESTDIR/
[ -f bin/ryzom_client_dev ] && cp bin/ryzom_client_dev $DESTDIR/
[ -f bin/ryzom_client_patcher ] && cp bin/ryzom_client_patcher $DESTDIR/
ls -la $DESTDIR/

