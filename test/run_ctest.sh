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
  --gw_path=GW_DIR
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

# print usage error and exit
usage_error () {
  printf "ERROR: $1\n" >&2
  usage >&2
  exit 1
}


# default settings
TEST_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
ROOT_DIR="$(dirname "$TEST_DIR")"
GW_DIR=${ROOT_DIR}/global-workflow
TEST_DIR=$(pwd)
APP="ATM"
GRID="96"
CASE=""
PLATFORM=""
#CCPP_SUITE="FV3_GFS_v17_coupled_p8"
VERBOSE=false
CTEST=false

# variables that could be redifined by users later
export FCST_HR=6
export METP="NO"
export GLDAS="NO"
export SYEAR=2019
export SMONTH=07
export SDAY=12
export SHR=00
#
export _ACCOUNT="epic-ps"
export _QUEUE="debug"
export _PARTITION_BATCH="debug"
export _wtime_fcst_gfs="00:30:00"
export _wtime_post_gfs="00:30:00"
export _wtime_vrfy_gfs="00:30:00"
export _wtime_arch_gfs="00:30:00"
export _FHOUT_GFS="6"

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
    --gw_path=?*) GW_DIR=${1#*=} ;;
    --gw_path|--gw_path=) usage_error "$1 requires argument." ;;
    --ctest) CTEST=true ;;
    --ctest=?*|--ctest=) usage_error "$1 argument ignored." ;;
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*|--verbose=) usage_error "$1 argument ignored." ;;
    -?*|?*) echo "Unknown option $1" ;;
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

# try modify python script to remove ocnpost and wavpost for ctests
if [ ${GRID} != "384" ]; then
  if [ -f ${GW_DIR}/workflow/applications.py.bak ]; then
    echo "find ${GW_DIR}/workflow/applications.py.bak! do nothing!"
  else
    echo "First time! remove ocnpost and wavepost for ctest for C96 case!"
    sed -i.bak -e '470,471d;482d' ${GW_DIR}/workflow/applications.py
  fi
fi

# tmp for S2SWA case: too slow, reduce fcst hrs to 6
if [ "${APP}" == "S2SWA" ]; then
   export FCST_HR="6"
   [ -d "${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}" ] && rm -rf ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}
fi

# now run setup scripts to generate experiment
# now only support fcst mode
printf 'y\ny\n' | ${GW_DIR}/workflow/setup_expt.py forecast-only --app ${APP} --pslot ${APP}_c${GRID}_${CASE} \
                                                 --idate ${SYEAR}${SMONTH}${SDAY}${SHR} \
                                                 --edate ${SYEAR}${SMONTH}${SDAY}${SHR} \
                                                 --resdet ${GRID} \
                                                 --comrot ${TEST_DIR}/comrot \
                                                 --expdir ${TEST_DIR}/expdir \
                                                 --icsdir ${TEST_DIR}/icsdir

# now modify config.base file based on user-defined variables
mkdir -p $TEST_DIR/archive
sed -i -r "s#^(export STMP=).*#\1$TEST_DIR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base 
sed -i -r "s#^(export HOMEDIR=).*#\1$TEST_DIR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export DO_METP=).*#\1$METP#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export DO_GLDAS=).*#\1$GLDAS#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_00=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_06=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_12=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export FHMAX_GFS_18=).*#\1$FCST_HR#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
#resources
sed -i -r "s#^(export ACCOUNT=).*#\1$_ACCOUNT#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export QUEUE=).*#\1$_QUEUE#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export QUEUE_SERVICE=).*#\1$_QUEUE#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
sed -i -r "s#^(export PARTITION_BATCH=).*#\1$_PARTITION_BATCH#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
#output
sed -i -r "s#^(export FHOUT_GFS=).*#\1$_FHOUT_GFS#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base

#change wall-time
sed -i -r "s#(export wtime_fcst_gfs=).*#\1${_wtime_fcst_gfs}#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.resources
sed -i -r "s#(export wtime_post_gfs=).*#\1${_wtime_post_gfs}#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.resources
sed -i -r "s#(export wtime_vrfy_gfs=).*#\1${_wtime_vrfy_gfs}#" ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.resources
sed -i 's/06:00:00/00:30:00/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.resources

# link ufs_model
ln -fs  ${GW_DIR}/sorc/ufs_model.fd/build/ufs_model ${GW_DIR}/exec/

# 
${GW_DIR}/workflow/setup_xml.py ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}

# check if inputdata is existed TODO: download examples from somewhere? 
if [[ -f ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/gfs_ctrl.nc ]]; then
  echo "${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/gfs_ctrl.nc exists! Copy to icsdir/comrot"
  mkdir -p ${TEST_DIR}/icsdir
  cp -r ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR} ${TEST_DIR}/icsdir
  mkdir -p ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}/gfs.${SYEAR}${SMONTH}${SDAY}/${SHR}/atmos/INPUT
  cp ${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/atmos/C${GRID}/INPUT/* ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}/gfs.${SYEAR}${SMONTH}${SDAY}/${SHR}/atmos/INPUT
else
  echo "\n Cannot find inputdata! Please check!\n\n"
  exit 1
fi

# for wave-related apps
if [ ${GRID} = "96" ]; then
  oGRID=100
elif [ ${GRID} = "192" ]; then
  oGRID=050
else
  oGRID=025
fi
#echo ${oGRID}
if [[ -f ${TEST_DIR}/icsdir/${SYEAR}${SMONTH}${SDAY}${SHR}/wave/rundata/gfswave.mod_def.mx${oGRID} ]]; then
  echo "${TEST_DIR}/inputdata/${SYEAR}${SMONTH}${SDAY}${SHR}/wave/rundata/gfswave.mod_def.mx${oGRID} exists! Copy to comrot"
  cp -r ${TEST_DIR}/icsdir/${SYEAR}${SMONTH}${SDAY}${SHR}/wave ${TEST_DIR}/comrot/${APP}_c${GRID}_${CASE}/gfs.${SYEAR}${SMONTH}${SDAY}/${SHR}/
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

# tmp fix 100 wav
if [ "${APP}" == "S2SW" ] || [ "${APP}" == "S2SWA" ]; then
  if [ ${GRID} = "96" ]; then
  sed -i 's/MEDPETS=300/#MEDPETS=300/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.defaults.s2sw
  sed -i 's/gwes_30m/mx'${oGRID}'/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.defaults.s2sw
  sed -i 's/mx025/mx'${oGRID}'/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.defaults.s2sw
  sed -i 's/reg025/reg'${oGRID}'/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.defaults.s2sw
  sed -i 's/mx025/mx'${oGRID}'/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.resources
  fi
fi

#tmp fix: remove wav task for s2s; TODO: find better way to handle this part for ctest!
if [ "${CTEST}" = true ] ; then
  if [ "${APP}" = "S2S" ]; then
    echo "turn off ocnpost depend and wav part in s2s app!"
    sed -i 's/source $EXPDIR\/config.defaults.s2sw/#source $EXPDIR\/config.defaults.s2sw/g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.base
    [ ${GRID} != "384" ] && sed -i.bak -e '202d' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
  elif [ "${APP}" = "S2SW" ]; then 
    echo "turn off ocnpost and wavpost depend in s2sw app!"
    [ ${GRID} != "384" ] && sed -i.bak -e '228,230d' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
  elif [ "${APP}" = "S2SWA" ]; then
    echo "change gocart extdata path"
    sed -i 's#/work2/noaa/global/wkolczyn/noscrub/global-workflow#'${TEST_DIR}'/fix_new#g' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/config.aero
    echo "turn off ocnpost and wavpost depend in s2sw app!"
    [ ${GRID} != "384" ] && sed -i.bak -e '283,285d' ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}/${APP}_c${GRID}_${CASE}.xml
  fi

  # now start rocotorun for ctest!
  cd ${TEST_DIR}/expdir/${APP}_c${GRID}_${CASE}
  #
  rocotorun -d ./${APP}_c${GRID}_${CASE}.db -w ./${APP}_c${GRID}_${CASE}.xml
  OUTPUT=$( grep "Task gfsarch" ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log | grep "in state SUCCEEDED (COMPLETED)" || true )
  while [ -z ${OUTPUT} ]; do
   echo "workflow not done, last line is" $( tail -n 1 ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log )
   rocotorun -d ./${APP}_c${GRID}_${CASE}.db -w ./${APP}_c${GRID}_${CASE}.xml
   sleep 30
   OUTPUT=$( grep "Task gfsarch" ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log | grep "in state SUCCEEDED (COMPLETED)" || true )
  done
  echo "$OUTPUT"
  echo $( tail -n 1 ./logs/${SYEAR}${SMONTH}${SDAY}${SHR}.log )
fi

#
exit 0
