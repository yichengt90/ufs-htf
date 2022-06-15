#!/bin/bash

# set ufs root
SCRIPT_ROOT=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
VAR1="${SCRIPT_ROOT}/../../src/ufs-weather-model"
echo "UFS root is ${VAR1}"

# detect PLATFORM NAME
echo $(hostname -f)
source ./detect_machine.sh
VAR2=${MACHINE_ID%%.*}
unset MACHINE_ID RT_COMPILER
echo "platform is ${VAR2}"

# create user define var
rm user_define_var.sh || true
cat << EOF > user_define_var.sh
export DAYS=0.125
export FHMAX=3
export RESTART_N=3
export RESTART_INTERVAL="3 -1"
export OUTPUT_FH="3 -1"
export FHZERO=3
export SCHEDULER=""
EOF

# run create case script
echo "R" | ./create_case.sh --platform=${VAR2} --ufs_root=${VAR1} --app=S2SW --grid=C96MX100 --ccpp=FV3_GFS_v17_coupled_p8 --use_user_var -v
