#!/bin/bash
#This bash script will delete the oldest logs and move to more recent logs until it reaches the desired free space on disk.
#Running curator in this fashion is only recomended for single node clusters or standalone setup's such as the HELK. 
# This df command grabs the free space of the root '/', if you store your logs elsewhere you will have to modify this.
disk=$(df -H | grep -vE '^Mounted| /.' | awk '{ print $1 " " $5 " " $6 }' | awk 'NR == 2' | awk '{print $2}' |sed 's/%//')
#If you have more than 90 days of logs, this number will have to be increased, went with 90 days with the idea that you will reach 
#your disk space limit before 90 days. 
days=90
# Disk threshold at 80 percent and also will not delete logs within the last 2 days.
while [ "$disk" > 80 ] && [ "$days" != 2 ]
do
daysreplace='unit_count: '$days
echo $daysreplace
sed -i "s/DAYSPLACEHOLDER/$daysreplace/" delete-after.yml
curator --config /etc/curator/config.yml /etc/curator/delete-after.yml
disk=$(df -H | grep -vE '^Mounted| /.' | awk '{ print $1 " " $5 " " $6 }' | awk 'NR == 2' | awk '{print $2}' |sed 's/%//')
days=$[$days-1]
echo $days
sed -i "s/$daysreplace/DAYSPLACEHOLDER/" delete-after.yml
done
