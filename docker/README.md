## How to use

You can build ufs-htf toy example using NOAA cloud (e.g. AWS):

git clone --recurse-submodules -b docker https://github.com/clouden90/ufs-htf.git
cd ufs-htf/docker/recipe 
sudo systemctl start docker
sudo docker build -t ufs-htf-image -f Dockerfile.ubuntu20.04-spack-htf .
