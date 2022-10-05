# ufs-htf
Hierarchical Testing Framework for ufs-weather-model.

## How to use

Please see [User Guide](https://ufs-htf.readthedocs.io/en/latest/BuildHTF.html#download-the-ufs-htf-prototype) for details.

## Run in docker (docker/jenkins branches only)

User can run toy example with docker container on NOAA cloud (e.g. AWS). It requies 8 cores, 16gb mem, and ~40 gb space (e.g. c5n.4xlarge).

User can follow the follwoing command to run toy example using docker on NOAA cloud:
```console
cd ~/
sudo systemctl start docker
git clone -b jenkins https://github.com/clouden90/ufs-htf.git
cd ufs-htf
sudo docker build -t clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test -f ./docker/recipe/Dockerfile.ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins .
sudo docker run --user root --rm clouden90/ubuntu20.04-gnu9.3-hpc-stack-htf-jenkins:test /bin/bash -c "bash ./docker/recipe/run_toy.sh"
```
A simple Jenkinsfile to run ctest build_ufs with Jenkins is also provided.
