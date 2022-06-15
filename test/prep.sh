#!/bin/bash

#prep script for htf_ctest

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 --platform=PLATFORM [options]

OPTIONS
  -h, --help
      show this help guide
  -p, --platform=PLATFORM
      name of machine you are working on
      (e.g. hera | gaea | orion)
  -d
      download input data
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

create_slurm_gaea() {
cat << EOF > run_slurm_job
#!/bin/bash -l
#SBATCH --job-name="htf_ctest"
#SBATCH --account=nggps_emc
#SBATCH --qos=normal
#SBATCH --clusters=c4
#SBATCH --nodes=6
#SBATCH --ntasks-per-node=36
#SBATCH --time=02:00:00
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
    -d) DOWNLOAD=true ;;
    -d=?*|-d=) usage_error "$1 argument ignored." ;;
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
  hera)  create_slurm_hera ;;
  gaea)  create_slurm_gaea ;;
    *)
      printf "WARNING: ${PLATFORM} is not supported yet! Stop now! \n"; exit 1 ;;
esac


# Download data for ctests
if [ "${DOWNLOAD}" = true ] ; then

  #
  echo "get input data from s3!"

  # firt install aws-cli
  if [ -d "${HOME}/aws-cli" ]; then
    echo "aws-cli existed" 
  else
    CURRENT_FOLDER=${PWD}
    cd
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install -i ${HOME}/aws-cli -b ${HOME}/aws-cli/bin
    cd ${CURRENT_FOLDER}
  fi
  export PATH=${HOME}/aws-cli/bin:$PATH

  # now download data for ctest cases

  if [ -d "./input-data/FV3_fix" ]; then
    echo "FV3_fix existed" 
  else
    echo "no input-data/FV3_fix, create now"
    mkdir -p input-data/FV3_fix
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix input-data/FV3_fix --recursive
  fi

  # regional data
  if [ -d "./input-data/fv3_regional_control" ]; then
    echo "fv3_regional_control existed" 
  else
    echo "no input-data/fv3_regional_control, create now"
    mkdir -p input-data/fv3_regional_control
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/fv3_regional_control input-data/fv3_regional_control --recursive
  fi
  if [ -d "./input-data/FV3_regional_input_data" ]; then
    echo "FV3_regional_input_data existed" 
  else
    echo "no input-data/FV3_regional_input_data, create now"
    mkdir -p input-data/FV3_regional_input_data
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_regional_input_data input-data/FV3_regional_input_data --recursive
  fi

  # FV3_fix_tiled 
  if [ -d "./input-data/FV3_fix_tiled" ]; then
    echo "FV3_fix_tiled existed" 
  else
    echo "no input-data/FV3_fix_tiled, create now"
    mkdir -p input-data/FV3_fix_tiled
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix_tiled input-data/FV3_fix_tiled --recursive \
            --exclude 'C384/*' --exclude 'C48/*'
  fi

  # CPL_FIX
  if [ -d "./input-data/CPL_FIX" ]; then
    echo "CPL_FIX existed" 
  else
    echo "no input-data/CPL_FIX, create now"
    mkdir -p input-data/CPL_FIX
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/CPL_FIX input-data/CPL_FIX --recursive
  fi

  # CICE_FIX
  if [ -d "./input-data/CICE_FIX" ]; then
    echo "CICE_FIX existed" 
  else
    echo "no input-data/CICE_FIX, create now"
    mkdir -p input-data/CICE_FIX
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/CICE_FIX input-data/CICE_FIX --recursive --exclude '400/*' --exclude '025/*'
  fi

  # CICE_IC
  if [ -d "./input-data/CICE_IC" ]; then
    echo "CICE_IC existed" 
  else
    echo "no input-data/CICE_IC, create now"
    mkdir -p input-data/CICE_IC
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/CICE_IC input-data/CICE_IC --recursive --exclude '400/*' --exclude '025/*'
  fi

  # MOM6_FIX
  if [ -d "./input-data/MOM6_FIX" ]; then
    echo "MOM6_FIX existed" 
  else
    echo "no input-data/MOM6_FIX, create now"
    mkdir -p input-data/MOM6_FIX
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/MOM6_FIX input-data/MOM6_FIX --recursive --exclude '400/*' --exclude '025/*'
  fi

  # MOM6_IC
  if [ -d "./input-data/MOM6_IC" ]; then
    echo "MOM6_IC existed" 
  else
    echo "no input-data/MOM6_IC, create now"
    mkdir -p input-data/MOM6_IC
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/MOM6_IC input-data/MOM6_IC --recursive --exclude '400/*' --exclude '025/*'
  fi

  # WW3 
  if [ -d "./input-data/WW3_input_data" ]; then
    echo "WW3_input_data existed" 
  else
    echo "no input-data/WW3_input_data, create now"
    mkdir -p input-data/WW3_input_data
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/WW3_input_data_20211113 input-data/WW3_input_data --recursive
  fi

  # GOCART
  if [ -d "./input-data/GOCART" ]; then
    echo "GOCART existed" 
  else
    echo "no input-data/GOCART, create now"
    mkdir -p input-data/GOCART
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART input-data/GOCART --recursive --exclude '*' --include 'p8/*'
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART/ExtData/dust/randomforestensemble_uthres.nc ./input-data/GOCART/p8/ExtData/dust
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART/ExtData/dust/gocart.dust_source.v5a.x1152_y721.nc ./input-data/GOCART/p8/ExtData/dust
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART/ExtData/dust/FENGSHA_Albedo_drag_v1.nc ./input-data/GOCART/p8/ExtData/dust
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART/ExtData/dust/FENGSHA_SOILGRIDS2019_GEFSv12_v1.2.nc ./input-data/GOCART/p8/ExtData/dust
  fi

  # IMP_PHYSICS = 8
  if [ -d "./input-data/FV3_input_data_gsd" ]; then
    echo "FV3_input_data_gsd existed" 
  else
    echo "no input-data/FV3_input_data_gsd, create now"
    mkdir -p input-data/FV3_input_data_gsd
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_gsd input-data/FV3_input_data_gsd --recursive \
              --exclude '*' \
              --include 'CCN_ACTIVATE.BIN' --include 'freezeH2O.dat' --include 'qr_acr_qgV2.dat' --include 'qr_acr_qsV2.dat' --include 'qr_acr_qg.dat' --include 'qr_acr_qs.dat'
  fi

  # merra2
  if [ -d "./input-data/FV3_input_data_INCCN_aeroclim" ]; then
    echo "FV3_input_data_INCCN_aeroclim existed" 
  else
    echo "no input-data/FV3_input_data_INCCN_aeroclim, create now"
    mkdir -p input-data/FV3_input_data_INCCN_aeroclim
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_INCCN_aeroclim input-data/FV3_input_data_INCCN_aeroclim --recursive \
              --exclude '*' \
              --include 'MERRA2/*' --include 'aer_data/*'
  fi

  #C96
  if [ -d "./input-data/FV3_input_data" ]; then
    echo "FV3_input_data existed" 
  else
    echo "no input-data/FV3_input_data, create now"
    mkdir -p input-data/FV3_input_data
    aws s3 cp --no-sign-request s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data input-data/FV3_input_data --recursive
  fi



fi
