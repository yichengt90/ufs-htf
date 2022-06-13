# ufs-htf
Hierarchical Testing Framework for ufs-weather-model. Insipred by [ufs case studies](https://ufs-case-studies.readthedocs.io/en/develop/Intro.html), we
implemented one of the cases (2019 Hurricane Barry) for ufs coupled model setup (S2S and S2SW). The whole test set inclues:

* building ufs model and its utilities;
* staging model input data from AWS S3 bucket;
* atm-only run for 2019 Hurricane Barry (C96 grid; based on global workflow)
* atm-ocn-ice coupled run for 2019 Hurricane Barry (C96 grid; based on global workflow)
* atm-ocn-ice-wav coupled run for 2019 Hurricane Barry (C96 grid; based on global workflow)
* atm-ocn-ice-wav-a coupled run for 2019 Hurricane Barry (C96 grid; based on global workflow)
* vrfy1: hurricane track check
* vrfy2: comparsion between model and reanalysis/obs
* atm-ocn-ice coupled run for 2019 Hurricane Barry (C96 grid, fcst step only)


## How to use

Please see [User Guide](https://ufs-htf.readthedocs.io/en/latest/BuildHTF.html#download-the-ufs-htf-prototype) for details.
