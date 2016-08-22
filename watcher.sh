#!/bin/bash
WATCHNODE=$1

# parameters
WATCHCONNECT=llang-pptp
WATCHEMAIL=watcher@larrylang.net
WATCHINTERVAL=300
TIMEZONE="America/Los_Angeles"

# initialize variables
PREVSTATUS=="start"
RECENTDAY=`TZ=$TIMEZONE date +%j`
UPDATE=""

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
TODAY=`TZ=$TIMEZONE date +%j`
if [ "$TODAY" != "$RECENTDAY" ]
then
	UPDATE="(daily update)"
else
    UPDATE=""
fi

echo `TZ=$TIMEZONE date +"%b %d %T"` $HOSTNAME watcher: $WATCHNODE $STATUS $UPDATE

# email when status changes or daily update
# installed via
# sudo apt-get install sendmail-bin
if [ "$STATUS" != "$PREVSTATUS" ] || [ "$UPDATE" != "" ]
then
	echo `TZ=$TIMEZONE date +"%b %d %T"` $HOSTNAME watcher: status change
	sendmail -t -f noreply@larrylang.net <<EOM
From: noreply@larrylang.net
To: $WATCHEMAIL
Subject: [watcher] $WATCHNODE $STATUS $UPDATE

$WATCHNODE $STATUS $UPDATE
EOM
fi

# prepare for next iteration
PREVSTATUS=$STATUS
RECENTDAY=$TODAY
sleep $WATCHINTERVAL

done
