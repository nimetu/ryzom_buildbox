#!/bin/sh

set -eu

export JOBS=${JOBS:-$(nproc)}
export MAKEFLAGS="${MAKEFLAGS:--j${JOBS}}"

if [ "${1:-}" = "build-client" ]; then
	shift
	exec rc-build.sh "$@"
fi

# run custom command
exec "$@"

