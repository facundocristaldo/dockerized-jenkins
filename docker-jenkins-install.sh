#!/bin/bash

# this script is only tested on ubuntu xenial
#apt-get update -y
#apt-get upgrade -y

groupadd  --gid 1000 docker
useradd  --uid 1000 ubuntu -g docker

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
systemctl start docker

# Optional docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

# run jenkins
mkdir -p /var/jenkins_home
chown -R 1000:1000 /var/jenkins_home/

docker login 

echo "Going to build jenkins-docker image"
docker build -t jenkins-docker .

echo "Going to run the docker image built"
docker run -p 8080:8080 -p 50000:50000 -v /var/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -d --name jenkins jenkins-docker

# show endpoint
echo 'Jenkins installed'
sleep 10
cat /var/jenkins_home/secrets/initialAdminPassword
echo 'You should now be able to access jenkins at: http://'$(curl -s ifconfig.co)':8080'
