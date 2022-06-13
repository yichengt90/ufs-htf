#!/bin/bash

set -eu

# detect platform
#source detect_machine.sh
#load_module

# first get path 
TEST_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
echo "TEST_DIR is ${TEST_DIR}"

# run prep script
sbatch ${TEST_DIR}/vrfy/drive_preprocess.sh
sleep 60

# run map script
bash ${TEST_DIR}/vrfy/drive_map_obs.sh

# run line script
bash ${TEST_DIR}/vrfy/drive_anoms.sh
