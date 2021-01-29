---
name: Report Issue
about: Describe the issue that you are having

---

#### Describe the problem

#### Provide the output of the following commands

Get operating system and version
for linux (except Mac) use:  
`cat /etc/os-release`  
for Mac/OSX use:  
`sw_vers`  
Get disk space, memory, processor cores, and docker storage  
`echo -e "\nDocker Space:" && df -h /var/lib/docker; echo -e "\nMemory:" && free -g; echo -e "\nCores:" && getconf _NPROCESSORS_ONLN`  
Get output of the HELK docker containers:  
`docker ps --filter "name=helk"`

```
Place all output, from the above commands, here
```

#### Provide the HELK installation logs located at /var/log/helk-install.log if you are having install errors

```
Place the output here
```

#### What version of HELK are you using

run the command from within the HELK repo run `git log -1 --oneline`  
```
Place the output here
```

#### What version of Winlogbeat are you using if you are using Windows/WEF logs

```
Place the version here
```

##### What steps did you take trying to fix the issue

##### How could we replicate the issue

##### Any additionally code or log context you would like to provide

```
Place the output here
```

#### Any additional context or input you have

pictures, comments, etc.
