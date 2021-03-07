#/bin/bash -x

#Check if cron is installed
if ! command -v cron  &> /dev/null
then
	#Installing java
	sudo apt-get update
	sudo apt-get install -y cron
fi

sudo systemctl start cron

cp op-updatedb /etc/cron.d/
