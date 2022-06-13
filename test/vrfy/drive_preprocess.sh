#!/bin/bash -l
#SBATCH -A epic-ps
#SBATCH --job-name=preprocess
#SBATCH -q debug
#SBATCH -t 00:30:00 
#SBATCH --nodes=1
#SBATCH -e err
#SBATCH -o out

    # Start/end delimiters for initial conditions

        ystart=2019; yend=2019;  ystep=1
        mstart=7;    mend=7;    mstep=1
        dstart=12;    dend=12;    dstep=1

    # Name and location of experiment output on HPSS

        declare -a exp_new=("ATM_c96_Barry" "S2S_c96_Barry")
        upload_root=./comrot
        exp_root=./Models/                   
        res=1p00                                                                       # choises: 1p00 and Orig
        ftype="surface"    # choices: "surface" (read from flux files) and "upper" (read from pgrb files)
        

    # Specify list of variables to preprocess (turn from 6-hourly grib2 into a 35-day series of daily netcdf)

        declare -a varlist=("land" "tmp2m" "tmpsfc")

    # The plotting scripts are prepared to handle variables on the list below:

        #oknames=(land tmpsfc tmp2m t2min t2max ulwrftoa dlwrf dswrf ulwrf uswrf prate pwat icetk icec cloudbdry cloudlow cloudmid cloudhi snow weasd snod lhtfl shtfl pres u10 v10 uflx vflx soill01d soill14d soill41m soill12m tsoil01d tsoil14d tsoil41m tsoil12mo soilm02m sfcr spfh2m u850 v850 z500 u200 v200 cloudtot)
        oknames=(land tmpsfc tmp2m t2min t2max ulwrftoa dlwrf dswrf ulwrf uswrf prate pwat icetk icec cloudbdry cloudlow cloudmid cloudhi snow weasd snod lhtfl shtfl pres u10 v10 uflx vflx tsoil12m soilm02m sfcr spfh2m u850 v850 z500 u200 v200 cloudtot)

#====================================================================================================
for exp in ${exp_new[@]} ; do
    echo ${exp}
    wherefrom=${upload_root}/${exp}
    whereto=${exp_root}/${exp}/${res}
    mkdir -p $whereto
    for varname in ${varlist[@]} ; do
        case "${oknames[@]}" in 
             *"$varname"*)  ;; 
             *)
             echo "Exiting. To continue, please correct: plotting not implemented for variable ---> $varname <---"
             exit
        esac
        bash ./vrfy/preprocess.sh exp=$exp varname=$varname wherefrom=$wherefrom whereto=$whereto res=$res ystart=$ystart yend=$yend ystep=$ystep mstart=$mstart mend=$mend mstep=$mstep dstart=$dstart dend=$dend dstep=$dstep ftype=$ftype
done
done


