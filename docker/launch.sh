#!/bin/bash
#
source /usr/share/lmod/6.6/init/bash
#
if [[ -d /home/builder/hpc-stack ]]; then
  #
  echo "hpc-stack!"
  module purge
  module use /home/builder/opt/hpc-modules/modulefiles/stack
  module load hpc hpc-gnu hpc-openmpi
  module load netcdf hdf5 bacio sfcio sigio nemsio w3emc esmf fms crtm g2 png zlib g2tmpl ip sp w3nco gfsio wgrib2 upp
  module load pio gftl-shared yafyaml
  module load mapl/2.22.0-esmf-v8.3.0b09
  module load prod_util
  module load nccmp
  #export PATH=/home/builder/miniconda/bin:$PATH
  #export PATH=/home/builder/.local/bin:$PATH
elif [[ -d /home/builder/spack-stack ]]; then
  #
  echo "spack-stack!"
  module purge
  module use /home/builder/spack-stack/envs/ufs-wm-dev.test/install/modulefiles/Core
  module load stack-gcc
  module load stack-openmpi
  module load stack-python
  module load netcdf-c netcdf-fortran libpng jasper
  module load sp zlib hdf5 netcdf-c netcdf-fortran esmf fms bacio crtm g2 g2tmpl ip w3nco gftl-shared yafyaml mapl nemsio sfcio sigio w3emc wgrib2 pio
  module load prod-util
  export PATH=/usr/local/lib/python3.8/dist-packages/cmake/data/bin:$PATH
else
  echo "This Platform is not supported, please check!"
  exit 1
fi
