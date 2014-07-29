#!/bin/bash
  # WiFi Pulse
  # Will check active status of defined wlan and reconnect if link is down
  #  Install to /usr/local/bin/WiFi_Pulse.sh
  #  CHMOD 0755
  #  Add to cronjob

  # Set wlan to check
wlan='wlan0'

  #Set ifconfig path
ifconfig='/sbin/ifconfig'

  # Start script
echo "Beginning WiFi Pulse Task"
now="$(date)"
echo "$now"
echo "Interface selected: $wlan"
echo


  # Lock task
echo "Locking task to prevent duplicate execution..."

(
  # Wait for flock on task (fd 200) for 10 seconds
  flock -x -w 10 200 ||
if [ "$?" != "0"]; then
  echo "ERROR: Unable to lock.";
else
  exit 1;
fi;
  # Backward lockdir compatibility
echo $$>>/var/lock/.wifi_pulse.lock
  
echo "Lock successful!"
echo

  # Start WiFi check	
echo "Performing connectivity check for $wlan..."
if $ifconfig $wlan | grep -q "inet addr:" ; then
  echo "$wlan: Active. Network online."
else
  echo "$wlan: Inactive. Network offline. Attempting to reconnect..."
  ifdown $wlan
  sleep 10
  ifup --force $wlan | grep "inet addr"
fi

echo
echo "$wlan connection:"
$ifconfig $wlan | grep "inet addr:"
echo

) 200>/var/lock/.myscript.exclusivelock

FLOCKEXIT=$?

exit $FLOCKEXIT