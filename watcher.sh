#!/bin/bash
WATCHNODE=$1

# parameters
WATCHEMAIL=watcher@larrylang.net
WATCHINTERVAL=300
TIMEZONE="America/Los_Angeles"

# initialize variables
PREVSTATUS="start"
PREVIPADDRESS=""
RECENTDAY=`TZ=$TIMEZONE date +%j`

# repeat until interrupted
while true
do

UPDATE=""

# ping test
ping -c 3 $WATCHNODE >/dev/null 2>&1
if [ $? -eq 0 ]
then
	STATUS="responding"
else
	STATUS="not responding"
fi

# nslookup to watch for changing IP address
NSLOOKUP=`nslookup $WATCHNODE`
IPADDRESS=`echo $NSLOOKUP | rev | cut -d " " -f 1 | rev`
if [ "$IPADDRESS" != "$PREVIPADDRESS" ]
then
	UPDATE+="(new IP address)"
fi

# refresh each new day
TODAY=`TZ=$TIMEZONE date +%j`
if [ "$TODAY" != "$RECENTDAY" ]
then
	UPDATE+="(daily update)"
fi

echo `TZ=$TIMEZONE date +"%b %d %T"` $HOSTNAME watcher: $WATCHNODE [$IPADDRESS] $STATUS $UPDATE

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

$WATCHNODE [$IPADDRESS] $STATUS $UPDATE
EOM
fi

# prepare for next iteration
PREVSTATUS=$STATUS
PREVIPADDRESS=$IPADDRESS
RECENTDAY=$TODAY
sleep $WATCHINTERVAL

done
