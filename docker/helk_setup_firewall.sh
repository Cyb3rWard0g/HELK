#!/bin/bash
# Author: @troplolBE
# Version: v0.0.2

LOGFILE="/var/log/helk-install.log"
TAG="[HELK-FIREWALL]"

if [[ $EUID -ne 0 ]]; then
    echo "Error, you need to be root to execute this script !"
    exit 1
fi

# *********** Gather active zones for further use ***********
ZONES="$(firewall-cmd --get-active-zones | grep -v '^ ' | tr '\n' ' ')"
echo "$TAG Here is the list of all the active zones found." | tee -a $LOGFILE
echo "$ZONES" | tee -a $LOGFILE

FIRST="$(echo $ZONES | cut -d ' ' -f 1)"
while true; do
   read -e -p "$TAG Please enter the zone you want to add the serivce to: " -i "$FIRST" CHOICE
   if [[ $ZONES =~ (^| )$CHOICE($| ) ]]; then
      break
   else
      echo "$TAG Error, zone is not in above list !"
   fi
done

# *********** Here we copy the firewall service we just created ***********
echo "$TAG Copying custom service to firewalld..." | tee -a $LOGFILE
cp ../configs/firewalld/helk.xml /etc/firewalld/services/helk.xml >> $LOGFILE 2>&1
if [[ $? -ne 0 ]]; then
   echo "$TAG Error during copy of the custom service..." | tee -a $LOGFILE
   exit 1
fi

echo "$TAG Reloading firewall..." | tee -a $LOGFILE
firewall-cmd --reload >> $LOGFILE 2>&1
if [[ $? -ne 0 ]]; then
   echo "$TAG Error while reloading firewall..." | tee -a $LOGFILE
   exit 1
fi

echo "$TAG Adding service to firewalld..." | tee -a $LOGFILE
firewall-cmd --zone=$CHOICE --add-service=helk >> $LOGFILE 2>&1
if [[ $? -ne 0 ]]; then
   echo "$TAG Error while adding service to firewall..." | tee -a $LOGFILE
   exit 1
fi

firewall-cmd --permanent --zone=$CHOICE --add-service=helk >> $LOGFILE 2>&1
if [[ $? -ne 0 ]]; then
   echo "$TAG Error while adding service to firewall permanently..." | tee -a $LOGFILE
   exit 1
fi

echo "$TAG Checking service has been added properly..." | tee -a $LOGFILE
if [[ "$(firewall-cmd --info-service=helk >> $LOGFILE 2>&1; echo $?)" != 0 ]]; then
    echo "$TAG Something went wrong with the service. Please see the log for more explaination..."
    exit 1
fi

echo "$TAG The new service has succesfully installed on your firewall. HELK should run properly..." | tee -a $LOGFILE
