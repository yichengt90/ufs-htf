#!/bin/bash

usage() {
  echo
  echo "Usage: $0 -p <path of global workflow> | -h "
  echo
  echo "  -p GW_DIR"
  echo "  -h  print this help message and exit"
  echo
  exit 1
}

GW_DIR=""
while getopts ":p:h" flag;

do
        case "${flag}" in
                p) GW_DIR="${OPTARG}";;
                h) usage;;
                *) echo "Invalid options: -$flag" ;;
        esac
done

set -eu

#get fix data from s3 for ufs test case
WORK_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
echo $WORK_DIR

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

#Now check all fix data we need!

#
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_gmted2010/C96
TMP=${TMP_DIR}/C96_grid.tile6.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data/INPUT_L127
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'C96_mosaic.nc' \
              --include 'C96_grid.tile*.nc'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_ugwd/C96
TMP=${TMP_DIR}/C96_oro_data_ss.tile1.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data/INPUT_L127
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'oro_data_ss.tile*.nc' \
              --include 'oro_data_ls.tile*.nc'
fi
#rename
FILES=$TMP_DIR/oro_data_*s.tile*.nc
if [ -f $TMP_DIR/oro_data_ss.tile1.nc ]; then
  for f in $FILES
  do
    echo "rename $(basename $f)"
    mv $f $TMP_DIR/C96_$(basename $f)
  done
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_ugwd
TMP=${TMP_DIR}/ugwp_limb_tau.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'ugwp_c384_tau.nc'
fi
#rename
if [ -f $TMP_DIR/ugwp_c384_tau.nc ]; then
  mv ${TMP_DIR}/ugwp_c384_tau.nc ${TMP}
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_fracoro/C96.mx100_frac
TMP=${TMP_DIR}/oro_C96.mx100.tile6.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix_tiled/C96
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'oro_C96.mx100.tile*.nc'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_fracoro/C96.mx100_frac/fix_sfc
TMP=${TMP_DIR}/C96.snowfree_albedo.tile6.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix_tiled/C96
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude 'oro_C96.mx100.tile*.nc'
fi


# check fix_lut folder
TMP_DIR=$WORK_DIR/fix_new/fix_lut
TMP=${TMP_DIR}/optics_BC.v1_3.dat
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_INCCN_aeroclim/aer_data/LUTS
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include '*.dat'
fi

# check fix_aer folder
TMP_DIR=$WORK_DIR/fix_new/fix_aer
TMP=${TMP_DIR}/merra2.aerclim.2003-2014.m01.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_INCCN_aeroclim/MERRA2
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} 
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include '*.nc'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_am
TMP=${TMP_DIR}/qr_acr_qg.dat
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data_gsd
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'qr_acr_qg.dat' \
              --include 'qr_acr_qs.dat'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_am
TMP=${TMP_DIR}/global_soilmgldas.statsgo.t1534.3072.1536.grb
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_input_data
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'global_soilmgldas.statsgo.t1534.3072.1536.grb' \
              --include 'global_slmask.t1534.3072.1536.grb'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_am
TMP=${TMP_DIR}/global_solarconstant_noaa_an.txt
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'fix_co2_proj/*' \
              --include 'CCN_ACTIVATE.BIN' \
              --include 'aerosol.dat' \
              --include 'freezeH2O.dat' \
              --include 'global_h2oprdlos.f77' \
              --include 'global_o3prdlos.f77' \
              --include 'sfc_emissivity_idx.txt' \
              --include 'solarconstant_noaa_an.txt' \
              --include 'global_glacier.2x2.grb' \
              --include 'global_maxice.2x2.grb' \
              --include 'RTGSST.1982.2012.monthly.clim.grb' \
              --include 'global_snoclim.1.875.grb' \
              --include 'CFSR.SEAICE.1982.2012.monthly.clim.grb'
fi
#reanme
if [ -f $TMP_DIR/solarconstant_noaa_an.txt ]; then
  mv ${TMP_DIR}/solarconstant_noaa_an.txt ${TMP_DIR}/global_solarconstant_noaa_an.txt
  mv ${TMP_DIR}/aerosol.dat ${TMP_DIR}/global_climaeropac_global.txt
  mv ${TMP_DIR}/global_h2oprdlos.f77 ${TMP_DIR}/global_h2o_pltc.f77
  mv ${TMP_DIR}/global_o3prdlos.f77 ${TMP_DIR}/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77
  mv ${TMP_DIR}/sfc_emissivity_idx.txt ${TMP_DIR}/global_sfc_emissivity_idx.txt
  mv ${TMP_DIR}/fix_co2_proj/co2historicaldata_glob.txt ${TMP_DIR}/global_co2historicaldata_glob.txt
  mv ${TMP_DIR}/fix_co2_proj/co2monthlycyc.txt ${TMP_DIR}/co2monthlycyc.txt
fi
#rename
FILES=$TMP_DIR/fix_co2_proj/co2historicaldata_*.txt
if [ -f $TMP_DIR/fix_co2_proj/co2historicaldata_2009.txt ]; then
  for f in $FILES
  do
    echo "rename $(basename $f)"
    mv $f $TMP_DIR/fix_co2_proj/global_$(basename $f)
  done
fi

# for S2S model
TMP_DIR=$WORK_DIR/fix_new/fix_cice/100
TMP=${TMP_DIR}/mesh.mx100.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/CICE_FIX/100
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi

TMP_DIR=$WORK_DIR/fix_new/fix_mom6/100
TMP=${TMP_DIR}/MOM_channels_SPEAR
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/MOM6_FIX/100
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_cpl/aC96o100
TMP=${TMP_DIR}/grid_spec.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/CPL_FIX/aC96o100
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi


# gen link
if [ -z $GW_DIR ]; then
  echo "path of global workflow is not given, use default path: ${WORK_DIR}/../../global-workflow/"
  ln -fs ${WORK_DIR}/fix_new/fix_* ${WORK_DIR}/../../global-workflow/fix/
else
  echo global workflow is located: ${GW_DIR}
  ln -fs ${WORK_DIR}/fix_new/fix_* ${GW_DIR}/fix/
fi
