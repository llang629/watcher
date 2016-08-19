#!/bin/bash
WATCHNODE=$1

WATCHINTERVAL=300
WATCHCONNECT=llang-pptp
WATCHEMAIL=watcher@larrylang.net

PREVSTATUS=="start"
RECENTDAY=`TZ=America/Los_Angeles date +%j`

# repeat until interrupted
while true
do

# pptp connect (and if necessary reconnect)
# set up via
# http://www.cyberciti.biz/tips/howto-configure-ubuntu-fedora-linux-pptp-client.html
if ! ifconfig | grep -q ppp0
then
	sudo killall pppd
	sudo pppd call $WATCHCONNECT
	sleep 10
fi

# ping test
ping -c 3 $WATCHNODE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	STATUS="responding"
else
	STATUS="not responding"
fi

# refresh each new day
TODAY=`TZ=America/Los_Angeles date +%j`
if [ "$TODAY" != "$RECENTDAY" ]
then
	STATUS="$STATUS (daily update)"
fi

echo `date +"%b %d %T"` $HOSTNAME watcher: $WATCHNODE $STATUS

# email when status changes including daily update
# installed via
# sudo apt-get install sendmail-bin
if [ "$STATUS" != "$PREVSTATUS" ]
then
	echo `date +"%b %d %T"` $HOSTNAME watcher: status change
	sendmail -t -f noreply@larrylang.net <<EOM
From: noreply@larrylang.net
To: $WATCHEMAIL
Subject: [watcher] $WATCHNODE $STATUS

$WATCHNODE $STATUS
EOM
fi

# prepare for next iteration
PREVSTATUS=$STATUS
RECENTDAY=$TODAY
sleep $WATCHINTERVAL

done