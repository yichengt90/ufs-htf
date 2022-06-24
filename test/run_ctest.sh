#!/bin/bash

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 [OPTIONS]...
OPTIONS
  -h, --help
      show this help guide
  --app=APP
      build ufs-wm with selected app
      default is ATM
  --grid=GRID
      GRID; default is 96
      (e.g. 96)
  --case=CASE
      cases selected from ufs case studies
      default is none
  --ctest
      ctest mode
  -v, --verbose
      build with verbose output
EOF_USAGE
}

# print settings
settings () {
cat << EOF_SETTINGS
Settings:
  APP=${APP}
  GRID=${GRID}
  CASE=${CASE}
  PLATFORM=${PLATFORM}
  TEST_DIR=${TEST_DIR}
  GW_DIR=${GW_DIR}
  FCST_HR=${FCST_HR}
  DO_METP=${METP}
  DO_GLDAS=${GLDAS}
  SYEAR=${SYEAR}
  SMONTH=${SMONTH}
  SDAY=${SDAY}
  SHR=${SHR}
  ACCOUNT=${_ACCOUNT}
  QUEUE=${_QUEUE}
  PARTITION_BATCH=${_PARTITION_BATCH}
  wtime_fcst_gfs=${_wtime_fcst_gfs}
  wtime_post_gfs=${_wtime_post_gfs}
  wtime_vrfy_gfs=${_wtime_vrfy_gfs}
  wtime_arch_gfs=${_wtime_arch_gfs}
  ARCH_GAUSSIAN_FHINC=${_ARCH_GAUSSIAN_FHINC}
EOF_SETTINGS
}

function load_module() {
case ${PLATFORM} in
  orion)
    module load python/3.7.5; module load contrib; module load rocoto/1.3.3 ;;	
  *)
    printf "WARNING: ${PLATFORM} is not supported yet! Stop now! \n"; exit 1 ;;
esac
}

# default settings
TEST_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
ROOT_DIR="$(dirname "$TEST_DIR")"
GW_DIR=${ROOT_DIR}/global-workflow
APP="ATM"
GRID="96"
CASE=""
PLATFORM=""
#CCPP_SUITE="FV3_GFS_v17_coupled_p8"
VERBOSE=false
CTEST=false

# variables that could be redifined by users later
export FCST_HR=3
export METP="NO"
export GLDAS="NO"
export SYEAR=2019
export SMONTH=07
export SDAY=11
export SHR=00
#
export _ACCOUNT="epic-ps"
export _QUEUE="debug"
export _PARTITION_BATCH="debug"
export _wtime_fcst_gfs="00:30:00"
export _wtime_post_gfs="00:30:00"
export _wtime_vrfy_gfs="00:30:00"
export _wtime_arch_gfs="00:30:00"
export _ARCH_GAUSSIAN_FHINC="3"

# process required arguments
if [[ ("$1" == "--help") || ("$1" == "-h") ]]; then
  usage
  exit 0
fi

# process optional arguments
while :; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    --app=?*) APP=${1#*=} ;;
    --app|--app=) usage_error "$1 requires argument." ;;
    --grid=?*) GRID=${1#*=} ;;
    --grid|--grid=) usage_error "$1 requires argument." ;;
    --case=?*) CASE=${1#*=} ;;
    --case|--case=) usage_error "$1 requires argument." ;;
    --ctest) CTEST=true ;;
    --ctest=?*|--ctest=) usage_error "$1 argument ignored." ;;
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*|--verbose=) usage_error "$1 argument ignored." ;;
    -?*|?*) usage_error "Unknown option $1" ;;
    *) break
  esac
  shift
done

set -eu

# detect platform
source detect_machine.sh
load_module

#check if we want to load user defined variables
if [ -z $CASE ]; then
  printf "\nWarning: case is not set, use default variables!\n\n"
  CASE="default"
else
  printf "\n case ${CASE} is selected, load case-specific variables now!\n\n"
  source ${TEST_DIR}/case/$CASE.env
fi

# print settings
if [ "${VERBOSE}" = true ] ; then
  settings
fi

# now run setup scripts to generate experiment
# now only support fcst mode
printf 'y\ny\n' | ${GW_DIR}/ush/rocoto/setup_expt.py forecast-only --app ${APP} --pslot ${APP}_c${GRID}_${CASE} \
                                                 --idate ${SYEAR}${SMONTH}${SDAY}${SHR} \
                                                 --edate ${SYEAR}${SMONTH}${SDAY}${SHR} \
                                                 --resdet ${GRID} \
                                                 --comrot ${TEST_DIR}/comrot \
                                                 --expdir ${TEST_DIR}/expdir \
                                                 --icsdir ${TEST_DIR}/icsdir

# now modify config.base file based on user-defined variables
sed -i -r "s#^(export STMP=).*#\1$TEST_DIR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base 
sed -i -r "s#^(export DO_METP=).*#\1$METP#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export DO_GLDAS=).*#\1$GLDAS#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_00=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_06=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_12=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_18=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
#resources
sed -i -r "s#^(export ACCOUNT=).*#\1$_ACCOUNT#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export QUEUE=).*#\1$_QUEUE#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export PARTITION_BATCH=).*#\1$_PARTITION_BATCH#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
#arch
sed -i -r "s#^(export ARCH_GAUSSIAN_FHINC=).*#\1$_ARCH_GAUSSIAN_FHINC#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.arch

# link ufs_model
ln -fs  ${GW_DIR}/sorc/ufs_model.fd/build/ufs_model ${GW_DIR}/exec/

# 
${GW_DIR}/ush/rocoto/setup_workflow_fcstonly.py --expdir ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}

#change wall-time
sed -i 's/WALLTIME_FCST_GFS  "03:00:00"/WALLTIME_FCST_GFS  "'"${_wtime_fcst_gfs}"'"/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
sed -i 's/WALLTIME_POST_GFS  "06:00:00"/WALLTIME_POST_GFS  "'"${_wtime_post_gfs}"'"/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
sed -i 's/WALLTIME_VRFY_GFS  "06:00:00"/WALLTIME_VRFY_GFS  "'"${_wtime_vrfy_gfs}"'"/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
sed -i 's/WALLTIME_ARCH_GFS  "06:00:00"/WALLTIME_ARCH_GFS  "'"${_wtime_arch_gfs}"'"/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
sed -i 's/PARTITION_SERVICE "service"/PARTITION_SERVICE "'"${_PARTITION_BATCH}"'"/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml

# check if inputdata is existed TODO: download examples from somewhere? 
if [[ -f ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/gfs_ctrl.nc ]]; then
  echo "${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/gfs_ctrl.nc exists! Copy to comrot"
  mkdir -p ${TEST_DIR}/icsdir
  cp -r ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR} ${TEST_DIR}/icsdir
  mkdir -p ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}/gfs.${SYEAR}${SMONTH}${SDAY}/${SHR}/atmos/INPUT
  cp ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/* ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}/gfs.${SYEAR}${SMONTH}${SDAY}/${SHR}/atmos/INPUT
else
  echo "\n Cannot find inputdata! Please check!\n\n"
  exit 1
fi

# tmp fix for 100 ocn MOM_input
if [ -f ${GW_DIR}/parm/mom6/MOM_input_template_100.org ]; then
  cp ${GW_DIR}/parm/mom6/MOM_input_template_100.org ${GW_DIR}/parm/mom6/MOM_input_template_100
else
  cp ${GW_DIR}/parm/mom6/MOM_input_template_100 ${GW_DIR}/parm/mom6/MOM_input_template_100.org
fi
sed -i 's/\@\[TOPOEDITS\]/ufs.topo_edits_011818.nc/g' ${GW_DIR}/parm/mom6/MOM_input_template_100 
sed -i 's/\@\[MOM_IAU\]/false/g' ${GW_DIR}/parm/mom6/MOM_input_template_100
sed -i 's/\@\[MOM6_ALLOW_LANDMASK_CHANGES\]/true/g' ${GW_DIR}/parm/mom6/MOM_input_template_100
sed -i -e '$aRESTART_CHECKSUMS_REQUIRED = False' ${GW_DIR}/parm/mom6/MOM_input_template_100
sed -i "s#MOM6_RESTART_SETTING='n'#MOM6_RESTART_SETTING='r'#g" ${GW_DIR}/ush/parsing_namelists_MOM6.sh

# remove ocnpost task; TODO: find better way to handle this part for ctest!
if [ "${CTEST}" = true ] ; then
  if [ "${APP}" == "S2S" ]; then
    sed -i.bak -e '363,401d;460d' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml 
  fi

  # now start rocotorun for ctest!
  cd ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}
  #
  rocotorun -d ./${APP}_c${GRID}_${CASE}.db -w ./${APP}_c${GRID}_${CASE}.xml
  OUTPUT=$( tail -n 1 -c 18 ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log )
  echo $OUTPUT
  while [[ "$OUTPUT" != "complete: Success" ]]; do
    echo "last line in log is $OUTPUT, keep trying!"
    rocotorun -d ./${APP}_c${GRID}_${CASE}.db -w ./${APP}_c${GRID}_${CASE}.xml
    sleep 90
    OUTPUT=$( tail -n 1 -c 18 ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log )
  done
  echo $OUTPUT
fi


#
exit 0
