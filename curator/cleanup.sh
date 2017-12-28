#!/bin/bash
disk=$(df -H | grep -vE '^Mounted| /.' | awk '{ print $1 " " $5 " " $6 }' | awk 'NR == 2' | awk '{print $2}' |sed 's/%//')
days=31
while [ "$disk" > 1 ] && [ "$days" != 2 ]
do
daysreplace='unit_count: '$days
echo $daysreplace
sed -i "s/DAYSPLACEHOLDER/$daysreplace/" delete-after.yml
curator --config /etc/curator/config.yml --dry-run /etc/curator/delete-after.yml
disk=$(df -H | grep -vE '^Mounted| /.' | awk '{ print $1 " " $5 " " $6 }' | awk 'NR == 2' | awk '{print $2}' |sed 's/%//')
days=$[$days-1]
echo $days
sed -i "s/$daysreplace/DAYSPLACEHOLDER/" delete-after.yml
done
