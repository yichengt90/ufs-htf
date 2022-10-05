#!/usr/bin/bash

set -x

usage() {
  set +x
  echo
  echo "Usage: $0 -a <UFS_app> | -c <build_config> | -v | -h "
  echo
  echo "  -a  Build a specific UFS_app instead of the default: S2SWA can be used for ATM, ATMA, S2S, and S2SW"
  echo "  -c  Selectively build based on the provided build_config instead of the default config"
  echo "  -v  Execute all build scripts with -v option"
  echo "  -h  print this help message and exit"
  echo
  set -x
  exit 1
}

build_ufs_option=""
build_v_option=""

while getopts ":a:c:v:h" flag;

do
        case "${flag}" in
	        a) build_ufs_option+="-a ${OPTARG} ";;
		c) build_ufs_option+="-c ${OPTARG} ";;
                v) build_v_option+="-v";;
		h) usage;;
		*) echo "Invalid options: -$flag" ;;	    
        esac
done

build_option+=$build_v_option
build_option+=" ${build_ufs_option}"

# set current and working paths ---------------------------------------------------
echo "current path" $(pwd);
CUR_PWD=$(pwd)
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd ${ROOT_DIR}/global-workflow/sorc; WRK_PWD=$(pwd)

# checkout components -------------------------------------------------------------
sed -i 's/Prototype-P8/develop/g' checkout.sh 
bash checkout.sh                                                                                                                               

# turn off build options -------------------------------------------------------                                                                                                                   
#sed -i '5s/yes/no/g' gfs_build.cfg
#sed -i '6s/yes/no/g' gfs_build.cfg                                                                                                        
#sed -i '7s/yes/no/g' gfs_build.cfg
#sed -i '8s/yes/no/g' gfs_build.cfg
#sed -i '11s/yes/no/g' gfs_build.cfg

# build and link components -------------------------------------------------------                                                           
if [[ -f gfs_build.cfg.bak ]]; then
   echo "found gfs_build.cfg.bak! do nothing!"
else
   echo "back up gfs_build.cfg!"
   cp ./gfs_build.cfg ./gfs_build.cfg.bak
   cp ./build_ufs.sh ./build_ufs.sh.bak
   echo "cp gfs_build.cfg from docker folder!"   
   cp ${ROOT_DIR}/docker/gfs_build.cfg ./
   cp ${ROOT_DIR}/docker/build_ufs.sh  ./
   cp ${ROOT_DIR}/docker/DOCKER.env ${ROOT_DIR}/global-workflow/env/
   ln -fs ${ROOT_DIR}/docker/parsing_namelists_CICE.sh.develop ${ROOT_DIR}/docker/parsing_namelists_CICE.sh 
fi
bash build_all.sh $build_option                                                                                                                       
#logfile="logs/build_ufs.log"
#if [[ -f $logfile ]] ; then
#  target=$(grep 'target=' $logfile | awk -F. '{print $1}' | awk -F= '{print $2}')
#  sh link_workflow.sh emc $target coupled; cd $CUR_PWD; exit 0
#fi

#[[ -f "$WRK_PWD/logs/build_ufs.log" ]] && cd $CUR_PWD; echo "Error: logs/build_ufs.log does not exist." >&2; exit 1
