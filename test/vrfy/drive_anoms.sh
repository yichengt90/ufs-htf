#!/bin/bash -l
#
    # Start/end delimiters for initial conditions

        ystart=2019; yend=2019;  ystep=1
        mstart=7;    mend=7;    mstep=1
        dstart=12;    dend=12;     dstep=1

    # Name and location of experiment and obs (data as 35-day time series in netcdf)

        obs_root=./obs
        exp_root=./Models 
        whereexp=$exp_root
        whereobs=$obs_root

        exp_old=ATM_c96_Barry
        exp_new=S2S_c96_Barry
        res=1p00

    # Other specitications

        hardcopy=yes         # Valid choices are yes no      

    #  reference: Valid choices are era5, cfsr, or gefs12r (only applies to z500, u200, u850, tmp2m
    #             Defaults to era5 if not specified

        reference=era5 

    # var: Valid choices for comparison with OBS are: 
    # tmpsfc, prate, ulwrftoa, tmp2m, t2min, t2max, z500, u200, u850 cloudtot, dswrf, uswrf, dlwrf, dswrf
 
        declare -a varlist=("tmp2m" "tmpsfc")   

    # season: Valid choices are "DJF" "MAM" "JJA" "SON" "AllAvailable"
        declare -a seasonlist=("AllAvailable")     

    # domain: Valid choices are Global Nino34 GlobalTropics
       
        declare -a domainlist=("Global")
  
    # mask: Valid choices are nomask, oceanonly, landonly. Defaults to "nomask" if not specified. 
        
        mask="nomask"

    for season in "${seasonlist[@]}" ; do
        for domain in "${domainlist[@]}" ; do
            for varname in "${varlist[@]}" ; do
                bash ./vrfy/anoms12.sh whereexp=$whereexp whereobs=$whereobs varModel=$varname domain=$domain \
                                hardcopy=$hardcopy season=$season nameModelA=$exp_old nameModelB=$exp_new \
                                ystart=$ystart yend=$yend ystep=$ystep mstart=$mstart mend=$mend mstep=$mstep \
                                dstart=$dstart dend=$dend dstep=$dstep mask=$mask reference=$reference

            done
        done
    done


