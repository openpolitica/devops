#!/bin/bash -x

#Verify if java exist, if not install it
if ! command -v java &> /dev/null
then
	#Installing java
	sudo apt-get update
	sudo apt-get install -y openjdk-8-jre
else 
	echo "Java is installed in your system... Skipping"
fi
