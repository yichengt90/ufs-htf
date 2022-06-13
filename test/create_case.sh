#!/bin/bash

die() { echo "$@" >&2; exit 1; }
function compute_petbounds() {
  # each test MUST define ${COMPONENT}_tasks variable for all components it is using
  # and MUST NOT define those that it's not using or set the value to 0.
  # ATM is a special case since it is running on the sum of compute and io tasks.
  # CHM component and mediator are running on ATM compute tasks only.
  local n=0
  unset atm_petlist_bounds ocn_petlist_bounds ice_petlist_bounds wav_petlist_bounds chm_petlist_bounds med_petlist_bounds
  # ATM
  ATM_io_tasks=${ATM_io_tasks:-0}
  if [[ $((ATM_compute_tasks + ATM_io_tasks)) -gt 0 ]]; then
     atm_petlist_bounds="${n} $((n + ATM_compute_tasks + ATM_io_tasks -1))"
     n=$((n + ATM_compute_tasks + ATM_io_tasks))
  fi
  # OCN
  if [[ ${OCN_tasks:-0} -gt 0 ]]; then
     ocn_petlist_bounds="${n} $((n + OCN_tasks - 1))"
     n=$((n + OCN_tasks))
  fi
  # ICE
  if [[ ${ICE_tasks:-0} -gt 0 ]]; then
     ice_petlist_bounds="${n} $((n + ICE_tasks - 1))"
     n=$((n + ICE_tasks))
  fi
  # WAV
  if [[ ${WAV_tasks:-0} -gt 0 ]]; then
     wav_petlist_bounds="${n} $((n + WAV_tasks - 1))"
     n=$((n + WAV_tasks))
  fi
  # CHM
  chm_petlist_bounds="0 $((ATM_compute_tasks - 1))"
  # MED
  med_petlist_bounds="0 $((ATM_compute_tasks - 1))"
  UFS_tasks=${n}
  echo "ATM_petlist_bounds: ${atm_petlist_bounds:-}"
  echo "OCN_petlist_bounds: ${ocn_petlist_bounds:-}"
  echo "ICE_petlist_bounds: ${ice_petlist_bounds:-}"
  echo "WAV_petlist_bounds: ${wav_petlist_bounds:-}"
  echo "CHM_petlist_bounds: ${chm_petlist_bounds:-}"
  echo "MED_petlist_bounds: ${med_petlist_bounds:-}"
  echo "UFS_tasks         : ${UFS_tasks:-}"
}

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 --platform=PLATFORM --ufs_root=UFS_ROOT [OPTIONS]...

OPTIONS
  -h, --help
      show this help guide
  -p, --platform=PLATFORM
      name of machine you are building on
      (e.g. cheyenne | hera | jet | orion | wcoss_dell_p3 | wcoss2)
  --ufs_root=UFS_ROOT
      path of UFS-WM 
  --compiler=COMPILER
      compiler to use; default depends on platform
      (e.g. intel | gnu | cray | gccgfortran)
  --app=APP
      build ufs-wm with selected app
      default is S2SWA
  --grid=GRID
      GRID; default for cpld is C96MX100
      (e.g. C192MX050)
  --ccpp=CCPP_SUITE
      ccpp suite to use; default is FV3_GFS_v17_coupled_p8
  --exp_root=EXP_ROOT
      exp root folder; default is UFS-WM_DIR/tests
  --use_user_var
      use user define var from user_define_var.sh
  -v, --verbose
      build with verbose output

EOF_USAGE
}

# print settings
settings () {
cat << EOF_SETTINGS
Settings:

  MACHINE=${PLATFORM}
  UFS_ROOT=${UFS_ROOT}
  COMPILER=${COMPILER}
  APP=${APP}
  GRID=${GRID}
  CCPP_SUITE=${CCPP_SUITE}
  EXP_ROOT=${EXP_ROOT}
  USE_USER_VAR=${USE_USER_VAR}
  VERBOSE=${VERBOSE}

EOF_SETTINGS
}

# print usage error and exit
usage_error () {
  printf "ERROR: $1\n" >&2
  usage >&2
  exit 1
}

# default settings
LCL_PID=$$
HTF_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
UFS_ROOT=""
#UFS_DIR="$(dirname "$HTF_DIR")"
COMPILER=""
APP="S2SWA"
GRID="C96MX100"
CCPP_SUITE="FV3_GFS_v17_coupled_p8"
EXP_ROOT=${HTF_DIR}
USE_USER_VAR=false
VERBOSE=false

# process required arguments
if [[ ("$1" == "--help") || ("$1" == "-h") ]]; then
  usage
  exit 0
fi

# process optional arguments
while :; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    --platform=?*|-p=?*) PLATFORM=${1#*=} ;;
    --platform|--platform=|-p|-p=) usage_error "$1 requires argument." ;;
    --ufs_root=?*) UFS_ROOT=${1#*=} ;;
    --ufs_root|--ufs_root=) usage_error "$1 requires argument." ;;
    --compiler=?*|-c=?*) COMPILER=${1#*=} ;;
    --compiler|--compiler=|-c|-c=) usage_error "$1 requires argument." ;;
    --app=?*) APP=${1#*=} ;;
    --app|--app=) usage_error "$1 requires argument." ;;
    --grid=?*) GRID=${1#*=} ;;
    --grid|--grid=) usage_error "$1 requires argument." ;;
    --ccpp=?*) CCPP_SUITE=${1#*=} ;;
    --ccpp|--ccpp=) usage_error "$1 requires argument." ;;
    --exp_root=?*) EXP_ROOT=${1#*=} ;;
    --exp_root|--exp_root=) usage_error "$1 requires argument." ;;
    --use_user_var) USE_USER_VAR=true ;;
    --use_user_var=?*|--use_user_var=) usage_error "$1 argument ignored." ;; 
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*|--verbose=) usage_error "$1 argument ignored." ;;
    -?*|?*) usage_error "Unknown option $1" ;;
    *) break
  esac
  shift
done

# Ensure uppercase / lowercase ============================================
PLATFORM="${PLATFORM,,}"
COMPILER="${COMPILER,,}"

# check if PLATFORM and UFS_ROOT is set
if [ -z $PLATFORM ] || [ -z $UFS_ROOT ]; then
  printf "\nERROR: Please set PLATFORM and UFS_ROOT.\n\n"
  usage
  exit 0
fi

# set PLATFORM (MACHINE)
MACHINE="${PLATFORM}"
printf "PLATFORM(MACHINE)=${PLATFORM}\n" >&2

set -eu

# automatically determine compiler
if [ -z "${COMPILER}" ] ; then
  case ${PLATFORM} in
    jet|hera|gaea) COMPILER=intel ;;
    orion) COMPILER=intel ;;
    wcoss_dell_p3) COMPILER=intel ;;
    wcoss2) COMPILER=intel ;;
    cheyenne) COMPILER=intel ;;
    *)
      COMPILER=intel
      printf "WARNING: Setting default COMPILER=intel for new platform ${PLATFORM}\n" >&2;
      ;;
  esac
fi

printf "COMPILER=${COMPILER}\n" >&2


# set MODULE_FILE for this platform/compiler combination
MODULE_FILE="ufs_${PLATFORM}.${COMPILER}"
if [ ! -f "${UFS_ROOT}/modulefiles/${MODULE_FILE}" ]; then
  printf "ERROR: module file does not exist for platform/compiler\n" >&2
  printf "  MODULE_FILE=${MODULE_FILE}\n" >&2
  printf "  PLATFORM=${PLATFORM}\n" >&2
  printf "  COMPILER=${COMPILER}\n\n" >&2
  printf "Please make sure PLATFORM and COMPILER are set correctly\n" >&2
  usage >&2
  exit 64
fi

printf "MODULE_FILE=${MODULE_FILE}\n" >&2

# Before we go on load modules, we first need to activate Lmod for some systems
if [ "${PLATFORM}" = gaea ] ; then
  source /lustre/f2/pdata/esrl/gsd/contrib/lua-5.1.4.9/init/init_lmod.sh
fi

# source the module file for this platform/compiler combination, then load workflow 
#printf "... Load MODULE_FILE ...\n"
#module use ${UFS_DIR}/modulefiles
#module load ${MODULE_FILE}

# link test files to UFS_ROOT/tests/tests
for file in "$HTF_DIR/tests"/*
do
  ln -fs $file ${UFS_ROOT}/tests/tests/$(basename "$file")
done

# link parm files to UFS_ROOT/tests/parm
for file in "$HTF_DIR/parm"/*
do
  ln -fs $file ${UFS_ROOT}/tests/parm/$(basename "$file")
done


# print settings
if [ "${VERBOSE}" = true ] ; then
  settings
fi

# Build the ufs-weather-model with user's slelection
if [ -f "${UFS_ROOT}/tests/fv3_${APP}_${CCPP_SUITE}.exe" ]; then
  echo "${UFS_ROOT}/tests/fv3_${APP}_${CCPP_SUITE}.exe exists, skip build step" 
else
  echo "build ufs model!"
  ${UFS_ROOT}/tests/compile.sh ${PLATFORM}.${COMPILER} "-DAPP=${APP} -DCCPP_SUITES=${CCPP_SUITE}" "${APP}_${CCPP_SUITE}" YES YES 2>&1 | tee compile.log
fi

## Now create case (similiar to rt.sh)
# Will have to refactor later

# PATHRT - Path to regression tests directory
#readonly PATHRT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
readonly PATHRT="${UFS_ROOT}/tests"
echo $PATHRT
cd ${PATHRT}

# PATHTR - Path to nmmb trunk directory
readonly PATHTR=$( cd ${PATHRT}/.. && pwd )

# set compiler
export RT_COMPILER=${COMPILER:-intel}

# setp machine ID and account info, and we do not use scheduler here
export MACHINE_ID="$PLATFORM.$RT_COMPILER"


if [[ $MACHINE_ID = orion.* ]]; then
  ACCNR="${ACCOUNT:-epic-ps}"
  QUEUE=batch
  PARTITION="orion"
  dprefix=${EXP_ROOT}
  DISKNM=/work/noaa/nems/emc.nemspara/RT #need to point to s3 location
  PTMP=$dprefix/exp
  SCHEDULER=slurm
  cp ${PATHRT}/fv3_conf/fv3_slurm.IN_orion ${PATHRT}/fv3_conf/fv3_slurm.IN
  cp ${PATHRT}/fv3_conf/compile_slurm.IN_orion ${PATHRT}/fv3_conf/compile_slurm.IN
fi


# Display the machine and account using the format detect_machine.sh used:
echo "Machine: " $MACHINE_ID "    Account: " $ACCNR

# Overwrite default RUNDIR_ROOT if environment variable RUNDIR_ROOT is set
RUNDIR_ROOT=${RUNDIR_ROOT:-${PTMP}}/${APP}_${GRID}_${CCPP_SUITE}
echo $RUNDIR_ROOT

# check if RUN_DIR is existed or not
if [ -d "$RUNDIR_ROOT" ]; then
  # interactive selection
  printf "RUNDIR_ROOT directory (${RUNDIR_ROOT}) already exists\n"
  printf "Please choose what to do:\n\n"
  printf "[R]emove the existing directory\n"
  printf "[C]ontinue using in the existing directory\n"
  printf "[Q]uit this script\n"
  read -p "Choose an option (R/C/Q):" choice
  case ${choice} in
    [Rr]* ) rm -rf ${RUNDIR_ROOT}; mkdir -pv $RUNDIR_ROOT ;;
    [Cc]* ) echo 'do nothing, keep going!' ;;
    [Qq]* ) exit ;;
    * ) printf "Invalid option selected.\n" ;;
  esac
else
  mkdir -pv $RUNDIR_ROOT
fi

# some env setup
CREATE_BASELINE=false
ROCOTO=false
ECFLOW=false
KEEP_RUNDIR=true
SINGLE_NAME=''
TEST_35D=false
export skip_check_results=true #false
export delete_rundir=false

#BL_DATE=20220401
#if [[ $MACHINE_ID = hera.* ]] || [[ $MACHINE_ID = orion.* ]] || [[ $MACHINE_ID = cheyenne.* ]] || [[ $MACHINE_ID = gaea.* ]] || [[ $MACHINE_ID = jet.* ]] || [[ $MACHINE_ID = s4.* ]]; then
#  RTPWD=${RTPWD:-$DISKNM/NEMSfv3gfs/develop-${BL_DATE}/${RT_COMPILER^^}}
#else
#  RTPWD=${RTPWD:-$DISKNM/NEMSfv3gfs/develop-${BL_DATE}}
#fi

RTPWD=""
NEW_BASELINE=${PTMP}/FV3_RT/REGRESSION_TEST

INPUTDATA_ROOT=${INPUTDATA_ROOT:-$DISKNM/NEMSfv3gfs/input-data-20220414}
INPUTDATA_ROOT_WW3=${INPUTDATA_ROOT}/WW3_input_data_20220418
INPUTDATA_ROOT_BMIC=${INPUTDATA_ROOT_BMIC:-$DISKNM/NEMSfv3gfs/BM_IC-20220207}

source ${PATHRT}/default_vars.sh

# automatically determine test name based on user configuration
CASE=${APP}_${GRID}_${CCPP_SUITE}
TEST_NAME=""
if [ -z "${TEST_NAME}" ] ; then
  case ${CASE} in
    S2S_C96MX100_FV3_GFS_v17_coupled_p8) TEST_NAME=cpld_control_nowav_noaero_p8 ;;
    S2SA_C96MX100_FV3_GFS_v17_coupled_p8) TEST_NAME=cpld_control_nowav_p8 ;;
    S2SW_C96MX100_FV3_GFS_v17_coupled_p8) TEST_NAME=cpld_control_noaero_p8 ;;
    S2SWA_C96MX100_FV3_GFS_v17_coupled_p8) TEST_NAME=cpld_control_p8 ;;
    S2SWA_C192MX050_FV3_GFS_v17_coupled_p8) TEST_NAME=cpld_control_c192_p8 ;;
    *)
      printf "WARNING: ${CASE} is not supported yet! Stop now! \n"; exit 1 ;;
  esac
fi

# get test name based on user configuration
#if [ ${APP} == "S2SWA" ]; then
#   TEST1="cpld_"
#fi
#if [ ${CCPP_SUITE} == "FV3_GFS_v17_coupled_p8" ]; then
#  TEST3="_p8"
#fi
#if [ ${GRID:0:3} == "C96" ]; then
#  TEST2="control"
#elif [ ${GRID:0:4} == "C192" ]; then
#  TEST2="control_c192"
#fi
#TEST_NAME=${TEST1}${TEST2}${TEST3}
echo $TEST_NAME

# check if test name existed in RT tests folder
[[ -e "${PATHRT}/tests/$TEST_NAME" ]] || die "run test file tests/$TEST_NAME does not exist"

# Avoid uninitialized RT_SUFFIX/BL_SUFFIX (see definition above)
RT_SUFFIX=${RT_SUFFIX:-""}
BL_SUFFIX=${BL_SUFFIX:-""}

(
  source ${PATHRT}/tests/$TEST_NAME

  NODES=$(( TASKS / TPN ))
  if (( NODES * TPN < TASKS )); then
    NODES=$(( NODES + 1 ))
  fi

  cat << EOF > ${RUNDIR_ROOT}/run_test_${TEST_NAME}.env
  export JOB_NR=${TEST_NAME}
  export MACHINE_ID=${MACHINE_ID}
  export RT_COMPILER=${RT_COMPILER}
  export RTPWD=${RTPWD}
  export INPUTDATA_ROOT=${INPUTDATA_ROOT}
  export INPUTDATA_ROOT_WW3=${INPUTDATA_ROOT_WW3}
  export INPUTDATA_ROOT_BMIC=${INPUTDATA_ROOT_BMIC}
  export PATHRT=${PATHRT}
  export PATHTR=${PATHTR}
  export NEW_BASELINE=${NEW_BASELINE}
  export CREATE_BASELINE=${CREATE_BASELINE}
  export RT_SUFFIX=${RT_SUFFIX}
  export BL_SUFFIX=${BL_SUFFIX}
  export SCHEDULER=${SCHEDULER}
  export ACCNR=${ACCNR}
  export QUEUE=${QUEUE}
  export ROCOTO=${ROCOTO}
  export ECFLOW=${ECFLOW}
  export skip_check_results=${skip_check_results}
  export delete_rundir=${delete_rundir}
EOF
  if [[ $MACHINE_ID = jet.* ]]; then
    cat << EOF >> ${RUNDIR_ROOT}/run_test_${TEST_NAME}.env
    export PATH=/lfs4/HFIP/hfv3gfs/software/miniconda3/4.8.3/envs/ufs-weather-model/bin:/lfs4/HFIP/hfv3gfs/software/miniconda3/4.8.3/bin:$PATH
    export PYTHONPATH=/lfs4/HFIP/hfv3gfs/software/miniconda3/4.8.3/envs/ufs-weather-model/lib/python3.8/site-packages:/lfs4/HFIP/hfv3gfs/software/miniconda3/4.8.3/lib/python3.8/site-packages
EOF
  fi

  #if [[ $ROCOTO == true ]]; then
  #  rocoto_create_run_task
  #elif [[ $ECFLOW == true ]]; then
  #  ecflow_create_run_task
  #else
  #  ./run_test.sh ${PATHTR} ${RUNDIR_ROOT} ${TEST_NAME} ${TEST_NR} ${COMPILE_NR} > ${LOG_DIR}/run_${TEST_NAME}${RT_SUFFIX}.log 2>&1
  #fi
)

# 
#source default_vars.sh
source ${PATHRT}/tests/$TEST_NAME

#
if [ "${USE_USER_VAR}" = true ] ; then
  echo "Load user defined vars!"
  source ${HTF_DIR}/user_define_var.sh
fi

# Save original CNTL_DIR name as INPUT_DIR for regression
# tests that try to copy input data from CNTL_DIR
export INPUT_DIR=${CNTL_DIR}
# Append RT_SUFFIX to RUNDIR, and BL_SUFFIX to CNTL_DIR
export RUNDIR=${RUNDIR_ROOT}
export CNTL_DIR=${CNTL_DIR}${BL_SUFFIX}

echo ${RUNDIR}

export JBNME=$(basename $RUNDIR)

echo "Create test ${TEST_NAME} ${TEST_DESCR}"

source ${PATHRT}/rt_utils.sh
source ${PATHRT}/atparse.bash

cd $RUNDIR

###############################################################################
# Make configure and run files
###############################################################################

# copy  FV3 executable:
cp ${PATHRT}/fv3_${APP}_${CCPP_SUITE}.exe ${RUNDIR}/fv3.exe

# modulefile for FV3 prerequisites:
cp ${PATHRT}/modules.fv3_${APP}_${CCPP_SUITE} ${RUNDIR}/modules.fv3
cp ${PATHTR}/modulefiles/ufs_common*  .

# Get the shell file that loads the "module" command and purges modules:
cp ${PATHRT}/module-setup.sh ${RUNDIR}/module-setup.sh

SRCD="${PATHTR}"
RUND="${RUNDIR}"

#
for i in ${FV3_RUN:-fv3_run.IN}
do
  atparse < ${PATHRT}/fv3_conf/${i} >> ${RUNDIR}/fv3_run
done

if [[ $DATM_CDEPS = 'true' ]] || [[ $FV3 = 'true' ]] || [[ $S2S = 'true' ]]; then
  if [[ $HAFS = 'false' ]] || [[ $FV3 = 'true' && $HAFS = 'true' ]]; then
    atparse < ${PATHRT}/parm/${INPUT_NML:-input.nml.IN} > ${RUNDIR}/input.nml
  fi
fi

atparse < ${PATHRT}/parm/${MODEL_CONFIGURE:-model_configure.IN} > ${RUNDIR}/model_configure

if [[ $DATM_CDEPS = 'false' ]]; then
  if [[ ${ATM_compute_tasks:-0} -eq 0 ]]; then
    ATM_compute_tasks=$((INPES * JNPES * NTILES))
  fi
  if [[ $QUILTING = '.true.' ]]; then
    ATM_io_tasks=$((WRITE_GROUP * WRTTASK_PER_GROUP))
  fi
fi

compute_petbounds

atparse < ${PATHRT}/parm/${NEMS_CONFIGURE:-nems.configure} > ${RUNDIR}/nems.configure

# remove after all tests pass
if [[ $TASKS -ne $UFS_tasks ]]; then
   echo "$TASKS -ne $UFS_tasks "
  exit 1
fi

# diag table
if [[ "Q${DIAG_TABLE:-}" != Q ]] ; then
  cp ${PATHRT}/parm/diag_table/${DIAG_TABLE} ${RUNDIR}/diag_table
fi
# Field table
if [[ "Q${FIELD_TABLE:-}" != Q ]] ; then
  cp ${PATHRT}/parm/field_table/${FIELD_TABLE} ${RUNDIR}/field_table
fi

# fix files
if [[ $FV3 == true ]]; then
  cp ${INPUTDATA_ROOT}/FV3_fix/*.txt ${RUNDIR}
  cp ${INPUTDATA_ROOT}/FV3_fix/*.f77 ${RUNDIR}
  cp ${INPUTDATA_ROOT}/FV3_fix/*.dat ${RUNDIR}
  cp ${INPUTDATA_ROOT}/FV3_fix/fix_co2_proj/* ${RUNDIR}
  if [[ $TILEDFIX != .true. ]]; then
    cp ${INPUTDATA_ROOT}/FV3_fix/*.grb ${RUNDIR}
  fi
fi

# Field Dictionary
cp ${PATHRT}/parm/fd_nems.yaml ${RUNDIR}/fd_nems.yaml

# Set up the run directory
source ${RUNDIR}/fv3_run

if [[ $CPLWAV == .true. ]]; then
  if [[ $MULTIGRID = 'true' ]]; then
    atparse < ${PATHRT}/parm/ww3_multi.inp.IN > ${RUNDIR}/ww3_multi.inp
  else
    atparse < ${PATHRT}/parm/ww3_shel.inp.IN > ${RUNDIR}/ww3_shel.inp
  fi
fi

if [[ $CPLCHM == .true. ]]; then
  cp ${PATHRT}/parm/gocart/*.rc ${RUNDIR}
  atparse < ${PATHRT}/parm/gocart/AERO_HISTORY.rc.IN > ${RUNDIR}/AERO_HISTORY.rc
fi

if [[ $DATM_CDEPS = 'true' ]] || [[ $S2S = 'true' ]]; then
  if [[ $HAFS = 'false' ]]; then
    atparse < ${PATHRT}/parm/ice_in_template > ${RUNDIR}/ice_in
    atparse < ${PATHRT}/parm/${MOM_INPUT:-MOM_input_template_$OCNRES} > ${RUNDIR}/INPUT/MOM_input
    atparse < ${PATHRT}/parm/diag_table/${DIAG_TABLE:-diag_table_template} > ${RUNDIR}/diag_table
    atparse < ${PATHRT}/parm/data_table_template > ${RUNDIR}/data_table
  fi
fi

if [[ $HAFS = 'true' ]] && [[ $DATM_CDEPS = 'false' ]]; then
  atparse < ${PATHRT}/parm/diag_table/${DIAG_TABLE:-diag_table_template} > ${RUNDIR}/diag_table
fi

if [[ "${DIAG_TABLE_ADDITIONAL:-}Q" != Q ]] ; then
  # Append diagnostic outputs, to support tests that vary from others
  # only by adding diagnostics.
  atparse < "${PATHRT}/parm/diag_table/${DIAG_TABLE_ADDITIONAL:-}" >> ${RUNDIR}/diag_table
fi

# ATMAERO
if [[ $CPLCHM == .true. ]] && [[ $S2S = 'false' ]]; then
  atparse < ${PATHRT}/parm/diag_table/${DIAG_TABLE:-diag_table_template} > ${RUNDIR}/diag_table
fi

if [[ $DATM_CDEPS = 'true' ]]; then
  atparse < ${PATHRT}/parm/${DATM_IN_CONFIGURE:-datm_in} > ${RUNDIR}/datm_in
  atparse < ${PATHRT}/parm/${DATM_STREAM_CONFIGURE:-datm.streams.IN} > ${RUNDIR}/datm.streams
fi

if [[ $DOCN_CDEPS = 'true' ]]; then
  atparse < ${PATHRT}/parm/${DOCN_IN_CONFIGURE:-docn_in} > ${RUNDIR}/docn_in
  atparse < ${PATHRT}/parm/${DOCN_STREAM_CONFIGURE:-docn.streams.IN} > ${RUNDIR}/docn.streams
fi

if [[ $SCHEDULER = 'pbs' ]]; then
  NODES=$(( TASKS / TPN ))
  if (( NODES * TPN < TASKS )); then
    NODES=$(( NODES + 1 ))
  fi
  atparse < $PATHRT/fv3_conf/fv3_qsub.IN > ${RUNDIR}/job_card
elif [[ $SCHEDULER = 'slurm' ]]; then
  NODES=$(( TASKS / TPN ))
  if (( NODES * TPN < TASKS )); then
    NODES=$(( NODES + 1 ))
  fi
  atparse < $PATHRT/fv3_conf/fv3_slurm.IN > ${RUNDIR}/job_card
elif [[ $SCHEDULER = 'lsf' ]]; then
  if (( TASKS < TPN )); then
    TPN=${TASKS}
  fi
  NODES=$(( TASKS / TPN ))
  if (( NODES * TPN < TASKS )); then
    NODES=$(( NODES + 1 ))
  fi
  atparse < $PATHRT/fv3_conf/fv3_bsub.IN > ${RUNDIR}/job_card
fi

#
exit 0
