#!/bin/bash

#prep script for htf_ctest

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 --platform=PLATFORM

OPTIONS
  -h, --help
      show this help guide
  -p, --platform=PLATFORM
      name of machine you are working on
      (e.g. hera | gaea | orion)

EOF_USAGE
}

create_slurm_hera() {
cat << EOF > run_slurm_job
#!/bin/sh
#SBATCH --account=marine-cpu
#SBATCH --qos=batch
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=40
#SBATCH --time=02:00:00
#SBATCH --job-name="htf_ctest"
#
ctest
EOF
}

create_slurm_orion() {
cat << EOF > run_slurm_job
#!/bin/sh
#SBATCH --account=epic-ps
#SBATCH --qos=batch
#SBATCH --partition=orion
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=40
#SBATCH --time=02:00:00
#SBATCH --job-name="htf_ctest"
#SBATCH --exclusive
#
ctest 
EOF
}

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
    -?*|?*) usage_error "Unknown option $1" ;;
    *) break
  esac
  shift
done

# check if PLATFORM and UFS_ROOT is set
if [ -z $PLATFORM ]; then
  printf "\nERROR: Please set PLATFORM.\n\n"
  usage
  exit 0
fi

#
PLATFORM="${PLATFORM,,}"
case ${PLATFORM} in
  orion) create_slurm_orion ;;
  hera) create_slurm_hera ;;
    *)
      printf "WARNING: ${PLATFORM} is not supported yet! Stop now! \n"; exit 1 ;;
esac
