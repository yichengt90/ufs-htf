#!/bin/bash

#
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
ROOT_DIR="$(dirname $(dirname "$SCRIPT_DIR"))"

#
cd ${ROOT_DIR}

#
git config --global --add safe.directory /home/builder/ufs-htf
git submodule update --init --recursive

#
source ./docker/launch.sh
pip3 install numpy awscli
[[ -d /home/builder/spack-stack ]] && pip3 install cmake
[[ -d /home/builder/spack-stack ]] && export PATH=/usr/local/lib/python3.8/dist-packages/cmake/data/bin:$PATH

#
mkdir build && cd build

#
cmake ..

# test ufs-wm build
ctest -R docker_build_ufs

#
if [ $? -ne 0 ]; then
   cat $ROOT_DIR/build/Testing/Temporary/LastTest.log
   echo "docker_build_ufs FAIL"
   exit 1
fi

# staging data
ctest -R docker_stage_ufs_data

#
if [ $? -ne 0 ]; then
   cat $ROOT_DIR/build/Testing/Temporary/LastTest.log
   echo "docker_stage_ufs_data FAIL"
   exit 1
fi

# ufs ATM_c48_toy
ctest -R docker_ATM_c48_toy

#
if [ $? -ne 0 ]; then
   cat $ROOT_DIR/build/Testing/Temporary/LastTest.log
   echo "docker_docker_ATM_c48_toy FAIL"
   exit 1
fi

# ufs S2S_c48_toy
ctest -R docker_S2S_c48_toy

#
if [ $? -ne 0 ]; then
   cat $ROOT_DIR/build/Testing/Temporary/LastTest.log
   echo "docker_docker_S2S_c48_toy FAIL"
   exit 1
fi
