#!/bin/bash

function load_module() {
case ${PLATFORM} in
  orion)
    export JEDI_OPT=/work/noaa/da/jedipara/opt/modules;
    module use $JEDI_OPT/modulefiles/core; module purge; module load jedi/intel-impi/2020.2;
    . /work/noaa/da/kritib/soca-shared/soca_python-3.9/bin/activate ;;
  *)
    printf "WARNING: ${PLATFORM} is not supported yet! Stop now! \n"; exit 1 ;;
esac
}

set -eu

# detect platform
source detect_machine.sh
load_module

# run ws_ts py script
TEST_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
echo "TEST_DIR is ${TEST_DIR}"
ln -fs ${TEST_DIR}/comrot/ATM_c96_Barry/gfs.20190711/00/atmos/trak.gfso.atcfunix.altg.2019071100 ./trak.gfso.atcfunix.altg.2019071100.atm
ln -fs ${TEST_DIR}/comrot/S2S_c96_Barry/gfs.20190711/00/atmos/trak.gfso.atcfunix.altg.2019071100 ./trak.gfso.atcfunix.altg.2019071100.s2s
python ./vrfy/Barry_ws_ts.py
