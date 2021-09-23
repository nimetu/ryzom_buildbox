#!/bin/sh

set -u -e

TAG=${TAG:-static-client}
JOBS=${JOBS:-$(nproc)}
FINAL_VERSION=${FINAL_VERSION:-ON}

CURDIR="$(dirname $(readlink -f $0))"
SRC=$(readlink -f `pwd`)
case "${1:-}" in
	--help)
		echo "Create container"
		echo "  $0 --create"
		echo "     creates 'ryzom/$TAG' image from docker/Dockerfile'"
		echo ""
		echo "example: $0 --create static-client"
		echo ""
		echo "Run container"
		echo "  $0"
		echo "     runs 'ryzom/$TAG' image on '${SRC}' as /ryzom inside container."
		echo ""
		echo "example: $0 static-client"
		echo ""
		exit
		;;
	--create)
		exec docker build --rm -t ryzom/${TAG} ${CURDIR}/docker
		;;
esac

exec docker run --rm -ti \
	--env TAG=${TAG} \
	--env JOBS=${JOBS} \
	--env FINAL_VERSION=${FINAL_VERSION} \
	-v "${SRC}":/ryzom \
	ryzom/${TAG} \
	"$@"

