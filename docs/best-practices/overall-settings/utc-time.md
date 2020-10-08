# UTC NTP Setup

```
apt install -y chrony;
systemctl enable chrony;
systemctl daemon-reload;
systemctl start chrony;

timedatectl set-local-rtc no && timedatectl set-timezone UTC && timedatectl set-ntp true;
chronyc -a makestep;
```

## problems We see with setting someone's timezone and enabling NTP

* they may have a specific timezone set for a specific reason.
* they may not have network/access to be able to reach out to x,y,z NTP - we then don't want to have to write scripts to test network connectivity and then if/else statements to try each specific NTP and set accordingly :(
* windows logs (specifically) are not "usually" set to UTC because it is preconfigured to use "local" timezone and not GMT/UTC. Also, most don't configure the host (after setup) to UTC either.. because they forget or more likely they don't want UTC to be displayed to the end user in their "clock" -- not knowing that the end user clock can be different than the system clock :) except in the case of sysmon.

## problems We see with setting the kibana default to UTC

* many of the reasons mentioned above
* specifically reason in that lets say windows logs are coming in as EST -- people will have to go back 4 hours to see the latest windows logs.