Ryzom Builder
=============

Docker container to build static client under linux.

Clone [ryzomcore](https://github.com/ryzom/ryzomcore/tree/feature/develop-atys) (ie `feature/develop-atys` branch).

ENV variables
-------------

* `TAG` - sets container name, ie `TAG=static-client` which is default.
* `JOBS` - sets concurrent make jobs (`JOBS=4`), default is using `nproc` program.
* `FINAL_VERSION` - if building final or dev client, ie `FINAL_VERSION=ON` which is default.

Script creates two folders inside sources

* `build_<TAG>` folder for build files which are reused when rebuilding client.
* `install_<TAG>` where compiled `ryzom_client` / `ryzom_client_patcher` are copied

Running
-------

First you must build container:

   `ryzom-build.sh --create` -- same as running `TAG=static-client ./ryzom-build.sh --create`

Then clone ryzom sources and run inside sources directory

   `ryzom-build.sh`

Final client is in `install_static-client` directory under sources. `build_static-client` is used for build cache.

Custom options
--------------

Custom cmake options can be set from command line:

   `ryzom-build.sh build-client -DCMAKE_BUILD_TYPE=Debug ...`.

See [docker/rc-build.sh](docker/rc-build.sh) for used cmake options.

All of them, except `CMAKE_PREFIX_PATH` which is forced, must be set if using custom options.

You may need to delete `build_<TAG>` folder when changing cmake options, or just use different TAG containers.

If working on source files, then its also possible to run `bash` inside container, and run 'make' manually in `build_<TAG>` directory for faster rebuilds.
`ryzom_client` is then accessible in `build_<TAG>/bin/` directory.

   `ryzom-build.sh /bin/bash`

