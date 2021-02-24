#!/bin/bash -e

# Avoids prompting to accept update
export DEBIAN_FRONTEND=noninteractive
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
sudo apt-get clean
sudo apt-get update
sudo apt-get -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef upgrade -yq
sudo apt-get install -yq  apt-transport-https ca-certificates curl gnupg-agent software-properties-common

#Verify if docker exist, if not install it
if ! command -v docker &> /dev/null
then
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	# the command $(lsb_release -cs) is not evaluated, version hardcoded
	sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'
	sudo apt-get -y update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
else 
	echo "Docker is installed in your system... Skipping"
fi

#Verify if docker-compose exist, if not install it
if ! command -v docker-compose &> /dev/null
then
	#Same apply to docker compose, version hardcoded
	#sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
else 
	echo "Docker-compose is installed in your system... Skipping"
	exit
fi
