#!/bin/bash
# parameters
WATCHCONNECT=llang-pptp
WATCHINTERVAL=15

# startup
echo "Starting watchvpn"
echo "Starting VPN"
sudo pppd call $WATCHCONNECT
sleep $WATCHINTERVAL


# repeat until interrupted
while true
do

# pptp connect (and if necessary reconnect)
# set up via
# http://www.cyberciti.biz/tips/howto-configure-ubuntu-fedora-linux-pptp-client.html
if ! ifconfig | grep -q ppp0
then
	echo "Restarting VPN"
	sudo killall pppd
	sudo pppd call $WATCHCONNECT
	sleep 10
fi

sleep $WATCHINTERVAL

done
