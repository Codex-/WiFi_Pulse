#!/bin/bash

  #WiFi Pulse

  #Will check active status of defined wlan and reconnect if link is down

  #  Install to /usr/local/bin/WiFi_Pulse

  #  CHMOD 0755

  #  Add to cronjob


  #Set wlan to check
wlan='wlan0'


  #Start script
echo "$(tput setaf 6)Beginning WiFi Pulse task $(tput sgr 0)"
echo "Interface selected: $(tput setaf 5)$wlan $(tput sgr 0)"
echo


  #Lock task
echo "Locking task to prevent duplicate execution..."

(
  # Wait for lock on /var/lock/.wifi_pulse.lock (fd 200) for 10 seconds
  flock -x -w 10 200 ||
if [ "$?" != "0"]; then
  echo "$(tput setaf 1)$(tput setab 7)ERROR$(tput sgr 0)$(tput setaf 1) Unable to lock. $(tput sgr 0)";
else
  exit 1;
fi;
  #backward lockdir compatibility
echo $$>>/var/lock/.wifi_pulse.lock
  
echo "$(tput setaf 2)Lock successful! $(tput sgr 0)"
echo

  #Start WiFi check	
echo "Performing connectivity check for $(tput setaf 5)$wlan$(tput sgr 0)..."
if ifconfig $wlan | grep -q "inet addr:" ; then
  echo "$(tput setaf 5)$wlan$(tput sgr 0): $(tput setaf 2)Active$(tput sgr 0). Network online."
else
  echo "$(tput setaf 5)$wlan$(tput sgr 0): $(tput setaf 1)Inactive$(tput sgr 0). Network offline. $(tput setaf 3)Attempting to reconnect... $(tput sgr 0)"
  ifdown $wlan
  sleep 5
  ifup --force $wlan | grep "inet addr"
fi

echo
echo "$(tput setaf 5)$wlan$(tput sgr 0) connection:"
ifconfig $wlan | grep "inet addr:"
echo

) 200>/var/lock/.myscript.exclusivelock

FLOCKEXIT=$?

exit $FLOCKEXIT