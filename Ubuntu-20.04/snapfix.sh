#!/bin/bash


#sudo apt update
#sudo apt install -y daemonize dbus-user-session fontconfig

pid=`ps -ef | grep "[0-9] /lib/systemd/systemd " | awk '{print $2}'`
if [ "$pid" = "" ]
then
	echo "Starting systemd..."
	sudo daemonize /usr/bin/unshare --fork --pid --mount-proc /lib/systemd/systemd --system-unit=basic.target
fi
sleep 1
pid=`ps -ef | grep "[0-9] /lib/systemd/systemd " | awk '{print $2}'`
echo $pid

exec sudo nsenter -t $pid -a su - devel

