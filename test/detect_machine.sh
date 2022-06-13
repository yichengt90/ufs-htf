#!/bin/bash

case $(hostname -f) in

  clogin01.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin02.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin03.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin04.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin05.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin06.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin07.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin08.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus
  clogin09.cactus.wcoss2.ncep.noaa.gov)	  MACHINE_ID=wcoss2 ;; ### cactus

  dlogin01.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin02.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin03.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin04.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin05.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin06.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin07.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin08.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood
  dlogin09.dogwood.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### dogwood

  hfe01)                   MACHINE_ID=hera ;; ### hera01
  hfe02)                   MACHINE_ID=hera ;; ### hera02
  hfe03)                   MACHINE_ID=hera ;; ### hera03
  hfe04)                   MACHINE_ID=hera ;; ### hera04
  hfe05)                   MACHINE_ID=hera ;; ### hera05
  hfe06)                   MACHINE_ID=hera ;; ### hera06
  hfe07)                   MACHINE_ID=hera ;; ### hera07
  hfe08)                   MACHINE_ID=hera ;; ### hera08
  hfe09)                   MACHINE_ID=hera ;; ### hera09
  hfe10)                   MACHINE_ID=hera ;; ### hera10
  hfe11)                   MACHINE_ID=hera ;; ### hera11
  hfe12)                   MACHINE_ID=hera ;; ### hera12
  hecflow01)               MACHINE_ID=hera ;; ### heraecflow01
  h*c*)                    MACHINE_ID=hera ;; ### hera computing node

  s4-submit.ssec.wisc.edu) MACHINE_ID=s4 ;; ### s4

  Orion-login-1.HPC.MsState.Edu) MACHINE_ID=orion ;; ### orion1
  Orion-login-2.HPC.MsState.Edu) MACHINE_ID=orion ;; ### orion2
  Orion-login-3.HPC.MsState.Edu) MACHINE_ID=orion ;; ### orion3
  Orion-login-4.HPC.MsState.Edu) MACHINE_ID=orion ;; ### orion4
  orion-*) MACHINE_ID=orion ;; ### orion computing node

  cheyenne1.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  cheyenne2.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne2
  cheyenne3.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne3
  cheyenne4.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne4
  cheyenne5.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne5
  cheyenne6.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne6
  cheyenne1.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  cheyenne2.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne2
  cheyenne3.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne3
  cheyenne4.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne4
  cheyenne5.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne5
  cheyenne6.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne6
  chadmin1.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  chadmin2.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  chadmin3.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  chadmin4.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  chadmin5.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1
  chadmin6.ib0.cheyenne.ucar.edu) MACHINE_ID=cheyenne ;; ### cheyenne1

esac

export PLATFORM=${MACHINE_ID}
