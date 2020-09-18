## Usage

1) build the image locally or pull from OTRF docker repo

    a) pull from OTRF docker repo: 
    ```shell script
    docker build . -t helk-zeek
    mkdir pcap
    ```
    b) build locally:
    ```shell script
    docker image pull otrf/helk-zeek
    mkdir pcap
    ```
    
    
2) choose a pcap and place it within the pcap directory in your current working directory

3) set the name of the pcap you moved from the previous step
```shell script
PCAP_FILE_NAME="mimikatz_CVE-2020-1472_authentication.cap"
#PCAP_FILE_NAME="mimikatz_CVE-2020-1472_exploit.cap"
#PCAP_FILE_NAME="mimikatz_CVE-2020-1472_exploit_dcsync_authntlm.cap"
````
4) Run Zeek on the PCAP. the logs will be stored in the name of the pcap (except its extension) with prepended "zeek_logs-"  
for example, if your PCAP was named `super_awesome_exploit.pcap` then a directory called `zeek_logs-super_awesome_exploit` would be created with the corresponding zeek logs from that pcap
```shell script
PCAP_LOG_DIR_NAME=`echo ${PCAP_FILE_NAME} | sed 's/\.[a-z.]*$//g'`
PCAP_LOG_DIR="pcap/zeek_logs-${PCAP_LOG_DIR_NAME}"
mkdir $PCAP_LOG_DIR
docker run --rm \
         -v `pwd`/pcap:/pcap \
         -v `pwd`/config/local.zeek:/usr/local/zeek/share/zeek/site/local.zeek \
         otrf/helk-zeek -C -r "$PCAP_FILE_NAME" local # "Site::local_nets += { 192.168.0.0/24 }"
mv pcap/*.log $PCAP_LOG_DIR

```
