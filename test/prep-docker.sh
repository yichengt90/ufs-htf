#!/bin/bash

usage() {
  echo
  echo "Usage: $0 -p <path of global workflow> | -h "
  echo
  echo "  -p GW_DIR"
  echo "  -a aGRID"
  echo "  -o oGRID"
  echo "  -h  print this help message and exit"
  echo
  exit 1
}

#default vaules
aGRID="96"
oGRID="100"
GW_DIR=""

while getopts ":p:a:o:h" flag;

do
        case "${flag}" in
                p) GW_DIR="${OPTARG}";;
                a) aGRID="${OPTARG}";;
                o) oGRID="${OPTARG}";;
                h) usage;;
                *) echo "Invalid options: -$flag" ;;
        esac
done

set -eu

#get fix data from s3 for ufs test case
WORK_DIR=$(pwd)
CURR_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
echo $WORK_DIR

# firt install aws-cli
pip install numpy awscli netCDF4
#if [ -d "${HOME}/aws-cli" ]; then
#  echo "aws-cli existed" 
#else
#  CURRENT_FOLDER=${PWD}
#  cd
#  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip"
#  unzip awscliv2.zip
#  ./aws/install -i ${HOME}/aws-cli -b ${HOME}/aws-cli/bin
#  cd ${CURRENT_FOLDER}
#fi
#export PATH=${HOME}/aws-cli/bin:$PATH

#Now check all fix data we need!

#
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_gmted2010/C${aGRID}
TMP=${TMP_DIR}/C${aGRID}_grid.tile6.nc
REMOTE_DIR_base=FV3_input_data
if [ ${aGRID} == "96" ]; then
  REMOTE_DIR=${REMOTE_DIR_base}
else
  REMOTE_DIR=${REMOTE_DIR_base}${aGRID}
fi
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/${REMOTE_DIR}/INPUT_L127
#file1="C${aGRID}_mosaic.nc"
#file2="C${aGRID}_grid.tile*.nc"
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'C*_mosaic.nc' \
              --include 'C*_grid.tile*.nc'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_ugwd/C${aGRID}
TMP=${TMP_DIR}/C${aGRID}_oro_data_ss.tile1.nc
REMOTE_DIR_base=FV3_input_data
if [ ${aGRID} == "96" ]; then
  REMOTE_DIR=${REMOTE_DIR_base}
else
  REMOTE_DIR=${REMOTE_DIR_base}${aGRID}
fi
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/${REMOTE_DIR}/INPUT_L127
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
    mv $f $TMP_DIR/C${aGRID}_$(basename $f)
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
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_fracoro/C${aGRID}.mx${oGRID}_frac
TMP=${TMP_DIR}/oro_C${aGRID}.mx${oGRID}.tile6.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix_tiled/C${aGRID}
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude '*' \
              --include 'oro_C*.mx*.tile*.nc'
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_fv3_fracoro/C${aGRID}.mx${oGRID}_frac/fix_sfc
TMP=${TMP_DIR}/C${aGRID}.snowfree_albedo.tile6.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/FV3_fix_tiled/C${aGRID}
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR}
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive \
              --exclude 'oro_C*.mx*.tile*.nc'
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
              --include 'CFSR.SEAICE.1982.2012.monthly.clim.grb' \
              --include 'IMS-NIC.blended.ice.monthly.clim.grb'
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
TMP_DIR=$WORK_DIR/fix_new/fix_cice/${oGRID}
TMP=${TMP_DIR}/mesh.mx${oGRID}.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/CICE_FIX/${oGRID}
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi

TMP_DIR=$WORK_DIR/fix_new/fix_mom6/${oGRID}
TMP=${TMP_DIR}/ocean_mask.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/MOM6_FIX/${oGRID}
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi

#
TMP_DIR=$WORK_DIR/fix_new/fix_cpl/aC${aGRID}o${oGRID}
TMP=${TMP_DIR}/grid_spec.nc
AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/CPL_FIX/aC${aGRID}o${oGRID}
if [ -f "${TMP}" ]; then
  echo "${TMP} exists"
else
  echo "no ${TMP}, try get it from aws"
  mkdir -p ${TMP_DIR} || true
  aws s3 cp --no-sign-request ${AWS_PATH} ${TMP_DIR} --recursive
fi

#for GOCART
#
#if [ -f $WORK_DIR/fix_new/gocart_emissions.tar.gz ]; then
#   echo "$WORK_DIR/fix_new/gocart_emissions.tar.gz already there!"
#else
#   aws s3 cp --no-sign-request s3://my-ufs-inputdata/gocart_emissions.tar.gz ./fix_new/
#   cd ./fix_new
#   tar -zxvf gocart_emissions.tar.gz
#   cd ..
#fi
#
#TMP_DIR=$WORK_DIR/fix_new/gocart_emissions/monochromatic
#TMP=${TMP_DIR}/optics_SU.v1_3.nc
#AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART
#if [ -f "${TMP}" ]; then
#  echo "${TMP} exists"
#else
#  echo "no ${TMP}, try get it from aws"
#  mkdir -p ${TMP_DIR} || true
#  aws s3 cp --no-sign-request ${AWS_PATH}/p8/ExtData/monochromatic/ ${TMP_DIR} --recursive \
#              --exclude '*' \
#              --include '*.nc'
#fi
#
#TMP_DIR=$WORK_DIR/fix_new/gocart_emissions/optics
#TMP=${TMP_DIR}/opticsBands_SU.v1_3.RRTMG.nc
#AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART
#if [ -f "${TMP}" ]; then
#  echo "${TMP} exists"
#else
#  echo "no ${TMP}, try get it from aws"
#  mkdir -p ${TMP_DIR} || true
#  aws s3 cp --no-sign-request ${AWS_PATH}/p8/ExtData/optics/ ${TMP_DIR} --recursive \
#              --exclude '*' \
#              --include 'opticsBands_BC.v1_3.RRTMG.nc' \
#              --include 'opticsBands_OC.v1_3.RRTMG.nc' \
#              --include 'opticsBands_DU.v15_3.RRTMG.nc' \
#              --include 'opticsBands_NI.v2_5.RRTMG.nc' \
#              --include 'opticsBands_SS.v3_3.RRTMG.nc' \
#              --include 'opticsBands_SU.v1_3.RRTMG.nc'
#fi
#
##TMP_DIR=$WORK_DIR/fix_new/gocart_emissions/MERRA2/sfc
##TMP=${TMP_DIR}/DMSclim_sfcconcentration.x360_y181_t12.Lana2011.nc
##AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART
##if [ -f "${TMP}" ]; then
##  echo "${TMP} exists"
##else
##  echo "no ${TMP}, try get it from aws"
##  mkdir -p ${TMP_DIR} || true
##  aws s3 cp --no-sign-request ${AWS_PATH}/p8/ExtData/MERRA2/sfc/ ${TMP_DIR} --recursive \
##              --exclude '*' \
##              --include '*.nc4'
##mv $TMP_DIR/DMSclim_sfcconcentration.x360_y181_t12.Lana2011.nc4 $TMP 
##fi
##
#TMP_DIR=$WORK_DIR/fix_new/gocart_emissions/PIESA/sfc
#TMP=${TMP_DIR}/HTAP/v2.2/htap-v2.2.emis_so2.aviation_lto.x3600_y1800_t12.2010.nc4
#AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART
#if [ -f "${TMP}" ]; then
#  echo "${TMP} exists"
#else
#  echo "no ${TMP}, try get it from aws"
#  mkdir -p ${TMP_DIR} || true
#  aws s3 cp --no-sign-request ${AWS_PATH}/p8/ExtData/PIESA/sfc/ ${TMP_DIR} --recursive
#fi
##
#TMP_DIR=$WORK_DIR/fix_new/gocart_emissions/Dust
#TMP=${TMP_DIR}/gocart.dust_source.v5a.x1152_y721.nc
#AWS_PATH=s3://noaa-ufs-regtests-pds/input-data-20220414/GOCART
#if [ -f "${TMP}" ]; then
#  echo "${TMP} exists"
#else
#  echo "no ${TMP}, try get it from aws"
#  mkdir -p ${TMP_DIR} || true
#  aws s3 cp --no-sign-request ${AWS_PATH}/ExtData/dust/ ${TMP_DIR} --recursive \
#              --exclude '*' \
#              --include 'gocart.dust_source.v5a.x1152_y721.nc'
#fi

#get inputdata for ctest cases!
#if [ -f ./inputdata/2019071200.tar.gz ]; then
#   echo "./inputdata/2019071200.tar.gz already there!"
#else
#   aws s3 cp --no-sign-request s3://my-ufs-inputdata/2019071200.tar.gz ./inputdata/
#   cd ./inputdata
#   tar -zxvf 2019071200.tar.gz
#   cd ..
#fi

#
if [ -f ./inputdata/2021032306.tar.gz ]; then
   echo "./inputdata/2021032306.tar.gz already there!"
else
   aws s3 cp --no-sign-request s3://my-ufs-inputdata/2021032306.tar.gz ./inputdata/
   cd ./inputdata
   tar -zxvf 2021032306.tar.gz
   cd ..
fi

if [ -d ./ref ]; then
   echo "./ref folder already there!"
else
   aws s3 cp --no-sign-request s3://my-ufs-inputdata/20220922_ref_toy.tar.gz ./
   tar -zxvf 20220922_ref_toy.tar.gz
fi


# gen link
if [ -z $GW_DIR ]; then
  echo "path of global workflow is not given, use default path: ${CURR_DIR}/../global-workflow/"
  GW_DIR=${CURR_DIR}/../global-workflow
  ln -fs ${WORK_DIR}/fix_new/fix_* ${GW_DIR}/fix/
else
  echo global workflow is located: ${GW_DIR}
  ln -fs ${WORK_DIR}/fix_new/fix_* ${GW_DIR}/fix/
fi

#
ln -fs ${GW_DIR}/sorc/ufs_model.fd/FV3/upp ${GW_DIR}/sorc/upp.fd

# link ufs_model
ln -fs  ${GW_DIR}/sorc/ufs_model.fd/build/ufs_model ${GW_DIR}/exec/
ln -fs ${GW_DIR}/sorc/ufs_model.fd/tests/ufs_model.x ${GW_DIR}/exec/
#link utils
#for workflowexec in enkf_chgres_recenter.x enkf_chgres_recenter_nc.x fv3nc2nemsio.x \
#    tave.x vint.x reg2grb2.x ; do
#  ln -fs ${GW_DIR}/sorc/install/bin/$workflowexec ${GW_DIR}/exec/
#done


#
for file in postxconfig-NT-GEFS-ANL.txt postxconfig-NT-GEFS-F00.txt postxconfig-NT-GEFS.txt postxconfig-NT-GFS-ANL.txt \
    postxconfig-NT-GFS-F00-TWO.txt postxconfig-NT-GFS-F00.txt postxconfig-NT-GFS-FLUX-F00.txt postxconfig-NT-GFS-FLUX.txt \
    postxconfig-NT-GFS-GOES.txt postxconfig-NT-GFS-TWO.txt postxconfig-NT-GFS-WAFS-ANL.txt postxconfig-NT-GFS-WAFS.txt \
    postxconfig-NT-GFS.txt postxconfig-NT-gefs-aerosol.txt postxconfig-NT-gefs-chem.txt params_grib2_tbl_new \
    post_tag_gfs128 post_tag_gfs65 gtg.config.gfs gtg_imprintings.txt \
    AEROSOL_LUTS.datoptics_luts_DUST.dat optics_luts_SALT.dat optics_luts_SOOT.dat optics_luts_SUSO.dat optics_luts_WASO.dat \
    ; do
    ln -fs ${GW_DIR}/sorc/upp.fd/parm/$file ${GW_DIR}/parm/post/$file 
done

