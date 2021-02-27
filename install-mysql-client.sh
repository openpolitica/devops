#!/bin/bash -x

#Verify if java exist, if not install it
if ! command -v mysql &> /dev/null
then
	#Installing java
	sudo apt-get update
	sudo apt-get install -y mysql-client
else 
	echo "Java is installed in your system... Skipping"
fi

if ! command -v expect &> /dev/null
then
	#Installing expect
	sudo apt-get update
	sudo apt-get install -y expect
else 
	echo "Expect is installed in your system... Skipping"
fi
