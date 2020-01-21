# Installation

## Requirements (Please Read Carefully)

### Operating System & Docker:

* Ubuntu 18.04 (preferred). However, Ubuntu 16 will work. CentOS is not fully supported but some have been able to get it to work, documentation is yet to come - so use CentOS at your own expense at the moment. However, open a GitHub issue but we cant promise we can help.
* HELK uses the official Docker Community Edition (CE) bash script (Edge Version) to install Docker for you. The Docker CE Edge script supports the following distros: ubuntu, debian, raspbian, centos, and fedora.
* You can see the specific distro versions supported in the script here.
* If you have Docker & Docker-Compose already installed in your system, make sure you uninstall them to avoid old incompatible version. Let HELK use the official Docker CE Edge script execution to install Docker.

### Processor/OS Architecture:

* 64-bit also known as x64, x86_64, AMD64 or Intel 64.
* FYI: old processors don't support SSE3 instructions to start ML (Machine Learning) on elasticsearch. Since version 6.1 Elastic has been compiling the ML programs on the assumption that SSE4.2 instructions are available (See: https://github.com/Cyb3rWard0g/HELK/issues/321 and https://discuss.elastic.co/t/failed-to-start-machine-learning-on-elasticsearch-7-0-0/178216/7)

### Cores:
Minimum of 4 cores (whether logical or physical)

### Network Connection: NAT or Bridge

* IP version 4 address. IPv6 has not been tested yet.
* Internet access
* If using a proxy, documentation is yet to come - so use a proxy at your own expense. However, open a GitHub issue and we will try to help until it is officially documented/supported.
* If using a VM then NAT or Bridge will work.
* List of required domains/IPs will be listed in future documentation.

### RAM:
There are four options, and the following are minimum requirements (include more if you are able).

* Option 1: 5GB includes KAFKA + KSQL + ELK + NGNIX.
* Option 2: 5GB includes KAFKA + KSQL + ELK + NGNIX + ELASTALERT
* Option 3: 7GB includes KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER.
* Option 4: 8GB includes KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER + ELASTALERT.

### Disk:
25GB for testing purposes and 100GB+ for production (minimum)

### Applications:

* Docker: 18.06.1-ce+ & Docker-Compose (HELK INSTALLS THIS FOR YOU)
* Winlogbeat running on your endpoints or centralized WEF server (that your endpoints are forwarding to).
* You can install Winlogbeat by following one of @Cyb3rWard0g posts here.
* Winlogbeat config recommended by the HELK since it uses the Kafka output plugin and it is already pointing to the right ports with recommended options. You will just have to add your HELK's IP address.

## HELK Download

Run the following commands to clone the HELK repo via git.

```bash
git clone https://github.com/Cyb3rWard0g/HELK.git
```

Change your current directory location to the new HELK directory, and run the helk_install.sh bash script as root.

```bash
cd HELK/docker
sudo ./helk_install.sh
```

## HELK Install

In order to make the installation of the HELK easy for everyone, the project comes with an install script named helk_install.sh. This script builds and runs everything you for HELK automatically. During the installation process, the script will allow you to set up the following:

* Set the HELK's option. For this document we are going to use option 2 (ELK + KSQL + Elastalert + Spark + Jupyter)
* Set the Kibana User's password. Default user is helk
* Set the HELK's IP. By default you can confirm that you want to use your HOST IP address for the HELK, unless you want to use a different one. Press [Return] or let the script continue on its own (30 Seconds sleep).
* Set the HELK's License Subscription. By default the HELK has the basic subscription selected. You can set it to trial if you want. If you want to learn more about subscriptions go here
  * If the license is set to trial, HELK asks you to set the password for the elastic account.

```
**********************************************
**          HELK - THE HUNTING ELK          **
**                                          **
** Author: Roberto Rodriguez (@Cyb3rWard0g) **
** HELK build version: v0.1.7-alpha02262019 **
** HELK ELK version: 6.6.1                  **
** License: GPL-3.0                         **
**********************************************
 
[HELK-INSTALLATION-INFO] HELK being hosted on a Linux box
[HELK-INSTALLATION-INFO] Available Memory: 12463 MBs
[HELK-INSTALLATION-INFO] You're using ubuntu version xenial
 
*****************************************************
*      HELK - Docker Compose Build Choices          *
*****************************************************
 
1. KAFKA + KSQL + ELK + NGNIX + ELASTALERT
2. KAFKA + KSQL + ELK + NGNIX + ELASTALERT + SPARK + JUPYTER
 
Enter build choice [ 1 - 2]: 2
[HELK-INSTALLATION-INFO] HELK build set to 2
[HELK-INSTALLATION-INFO] Set HELK elastic subscription (basic or trial): basic
[HELK-INSTALLATION-INFO] Set HELK IP. Default value is your current IP: 192.168.64.138
[HELK-INSTALLATION-INFO] Set HELK Kibana UI Password: hunting
[HELK-INSTALLATION-INFO] Verify HELK Kibana UI Password: hunting
[HELK-INSTALLATION-INFO] Docker already installed
[HELK-INSTALLATION-INFO] Making sure you assigned enough disk space to the current Docker base directory
[HELK-INSTALLATION-INFO] Available Docker Disk: 67 GBs
[HELK-INSTALLATION-INFO] Installing docker-compose..
[HELK-INSTALLATION-INFO] Checking local vm.max_map_count variable and setting it to 4120294
[HELK-INSTALLATION-INFO] Building & running HELK from helk-kibana-notebook-analysis-basic.yml file..
[HELK-INSTALLATION-INFO] Waiting for some services to be up .....
....
......
```

## Monitor HELK installation Logs (Always)

Once the installation kicks in, it will start showing you pre-defined messages about the installation, but no all the details of what is actually happening in the background. It is designed that way to keep your main screen clean and let you know where it is in the installation process.

What I recommend to do all the time is to open another shell and monitor the HELK installation logs by using the tail command and pointing it to the /var/log/helk-install.log file that gets created by the helk_install script as soon as it is run. This log file is available on your local host even if you are deploying the HELK via Docker (I want to make sure it is clear that it is a local file).

```bash
tail -f /var/log/helk-install.log
```

```
Creating network "docker_helk" with driver "bridge"
Creating volume "docker_esdata" with local driver
Pulling helk-elasticsearch (docker.elastic.co/elasticsearch/elasticsearch:6.6.1)...
6.6.1: Pulling from elasticsearch/elasticsearch
Pulling helk-kibana (docker.elastic.co/kibana/kibana:6.6.1)...
6.6.1: Pulling from kibana/kibana
Pulling helk-logstash (docker.elastic.co/logstash/logstash:6.6.1)...
6.6.1: Pulling from logstash/logstash
Pulling helk-jupyter (cyb3rward0g/helk-jupyter:0.1.2)...
0.1.2: Pulling from cyb3rward0g/helk-jupyter
Pulling helk-nginx (cyb3rward0g/helk-nginx:0.0.7)...
0.0.7: Pulling from cyb3rward0g/helk-nginx
Pulling helk-spark-master (cyb3rward0g/helk-spark-master:2.4.0-a)...
2.4.0-a: Pulling from cyb3rward0g/helk-spark-master
Pulling helk-spark-worker (cyb3rward0g/helk-spark-worker:2.4.0-a)...
2.4.0-a: Pulling from cyb3rward0g/helk-spark-worker
Pulling helk-zookeeper (cyb3rward0g/helk-zookeeper:2.1.0)...
2.1.0: Pulling from cyb3rward0g/helk-zookeeper
Pulling helk-kafka-broker (cyb3rward0g/helk-kafka-broker:2.1.0)...
2.1.0: Pulling from cyb3rward0g/helk-kafka-broker
Pulling helk-ksql-server (confluentinc/cp-ksql-server:5.1.2)...
5.1.2: Pulling from confluentinc/cp-ksql-server
Pulling helk-ksql-cli (confluentinc/cp-ksql-cli:5.1.2)...
5.1.2: Pulling from confluentinc/cp-ksql-cli
Pulling helk-elastalert (cyb3rward0g/helk-elastalert:0.2.1)...
0.2.1: Pulling from cyb3rward0g/helk-elastalert
Creating helk-elasticsearch ... done
Creating helk-kibana        ... done
Creating helk-logstash      ... done
Creating helk-spark-master  ... done
Creating helk-elastalert    ... done
Creating helk-zookeeper     ... done
Creating helk-jupyter       ... done
Creating helk-spark-worker  ... done
Creating helk-kafka-broker  ... done
Creating helk-nginx         ... done
Creating helk-ksql-server   ... done
Creating helk-ksql-cli      ... done 
```

Once you see that the containers have been created you can check all the containers running by executing the following:

```bash
sudo docker ps
```

```
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS                                                      NAMES
968576241e9c        confluentinc/cp-ksql-server:5.1.2                     "/etc/confluent/dock…"   28 minutes ago      Up 26 minutes       0.0.0.0:8088->8088/tcp                                     helk-ksql-server
154593559d13        cyb3rward0g/helk-kafka-broker:2.1.0                   "./kafka-entrypoint.…"   28 minutes ago      Up 26 minutes       0.0.0.0:9092->9092/tcp                                     helk-kafka-broker
d883541a64f1        cyb3rward0g/helk-nginx:0.0.7                          "/opt/helk/scripts/n…"   About an hour ago   Up 26 minutes       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp                   helk-nginx
527ef236543a        cyb3rward0g/helk-spark-worker:2.4.0-a                 "./spark-worker-entr…"   About an hour ago   Up 26 minutes                                                                  helk-spark-worker
27cfaf7a8e84        cyb3rward0g/helk-jupyter:0.1.2                        "./jupyter-entrypoin…"   About an hour ago   Up 26 minutes       8000/tcp, 8888/tcp                                         helk-jupyter
75002248e916        cyb3rward0g/helk-zookeeper:2.1.0                      "./zookeeper-entrypo…"   About an hour ago   Up 26 minutes       2181/tcp, 2888/tcp, 3888/tcp                               helk-zookeeper
ee0120167ffa        cyb3rward0g/helk-elastalert:0.2.1                     "./elastalert-entryp…"   About an hour ago   Up 26 minutes                                                                  helk-elastalert
4dc2722cdd53        cyb3rward0g/helk-spark-master:2.4.0-a                 "./spark-master-entr…"   About an hour ago   Up 26 minutes       7077/tcp, 0.0.0.0:8080->8080/tcp                           helk-spark-master
9c1eb230b0ff        docker.elastic.co/logstash/logstash:6.6.1             "/usr/share/logstash…"   About an hour ago   Up 26 minutes       0.0.0.0:5044->5044/tcp, 0.0.0.0:8531->8531/tcp, 9600/tcp   helk-logstash
f018f16d9792        docker.elastic.co/kibana/kibana:6.6.1                 "/usr/share/kibana/s…"   About an hour ago   Up 26 minutes       5601/tcp                                                   helk-kibana
6ec5779e9e01        docker.elastic.co/elasticsearch/elasticsearch:6.6.1   "/usr/share/elastics…"   About an hour ago   Up 26 minutes       9200/tcp, 9300/tcp                                         helk-elasticsearch
```

If you want to monitor the resources being utilized (Memory, CPU, etc), you can run the following:

```bash
sudo docker stats --all
```

```
CONTAINER ID        NAME                 CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
ba46d256ee18        helk-ksql-cli        0.00%               0B / 0B               0.00%               0B / 0B             0B / 0B             0
968576241e9c        helk-ksql-server     1.43%               242MiB / 12.62GiB     1.87%               667kB / 584kB       96.1MB / 73.7kB     29
154593559d13        helk-kafka-broker    2.83%               318.7MiB / 12.62GiB   2.47%               1.47MB / 1.6MB      50.7MB / 2.01MB     67
d883541a64f1        helk-nginx           0.10%               3.223MiB / 12.62GiB   0.02%               14.7MB / 14.8MB     9.35MB / 12.3kB     5
527ef236543a        helk-spark-worker    0.43%               177.7MiB / 12.62GiB   1.38%               19.5kB / 147kB      37.1MB / 32.8kB     28
27cfaf7a8e84        helk-jupyter         0.12%               45.42MiB / 12.62GiB   0.35%               1.64kB / 0B         66.3MB / 733kB      9
75002248e916        helk-zookeeper       0.26%               62.6MiB / 12.62GiB    0.48%               150kB / 118kB       2.75MB / 172kB      23
ee0120167ffa        helk-elastalert      2.60%               40.97MiB / 12.62GiB   0.32%               12MB / 17.4MB       38.3MB / 8.19kB     1
4dc2722cdd53        helk-spark-master    0.50%               187.2MiB / 12.62GiB   1.45%               148kB / 17.8kB      52.3MB / 32.8kB     28
9c1eb230b0ff        helk-logstash        15.96%              1.807GiB / 12.62GiB   14.32%              871kB / 110MB       165MB / 2.95MB      62
f018f16d9792        helk-kibana          2.73%               179.1MiB / 12.62GiB   1.39%               3.71MB / 17.6MB     250MB / 4.1kB       13
6ec5779e9e01        helk-elasticsearch   12.56%              2.46GiB / 12.62GiB    19.50%              130MB / 15.8MB      293MB / 226MB       61
```

You should also monitor the logs of each container while they are being initialized:

Just run the following:

```bash
sudo docker logs --follow helk-elasticsearch
```
```
[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to -Xms1200m -Xmx1200m -XX:-UseConcMarkSweepGC -XX:-UseCMSInitiatingOccupancyOnly -XX:+UseG1GC
[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elastic license to basic
[HELK-ES-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script..
OpenJDK 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.
OpenJDK 64-Bit Server VM warning: Option UseConcMarkSweepGC was deprecated in version 9.0 and will likely be removed in a future release.
[2019-03-16T17:13:58,710][INFO ][o.e.e.NodeEnvironment    ] [helk-1] using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/sda1)]], net usable_space [60.7gb], net total_space [72.7gb], types [ext4]
[2019-03-16T17:13:58,722][INFO ][o.e.e.NodeEnvironment    ] [helk-1] heap size [1.1gb], compressed ordinary object pointers [true]
[2019-03-16T17:13:58,728][INFO ][o.e.n.Node               ] [helk-1] node name [helk-1], node ID [En7HptZKTNmv4R6-Qb99UA]
[2019-03-16T17:13:58,729][INFO ][o.e.n.Node               ] [helk-1] version[6.6.1], pid[12], build[default/tar/1fd8f69/2019-02-13T17:10:04.160291Z], OS[Linux/4.4.0-116-generic/amd64], JVM[Oracle Corporation/OpenJDK 64-Bit Server VM/11.0.1/11.0.1+13]
[2019-03-16T17:13:58,734][INFO ][o.e.n.Node               ] [helk-1] JVM arguments [-Xms1g, -Xmx1g, -XX:+UseConcMarkSweepGC, -XX:CMSInitiatingOccupancyFraction=75, -XX:+UseCMSInitiatingOccupancyOnly, -Des.networkaddress.cache.ttl=60, -Des.networkaddress.cache.negative.ttl=10, -XX:+AlwaysPreTouch, -Xss1m, -Djava.awt.headless=true, -Dfile.encoding=UTF-8, -Djna.nosys=true, -XX:-OmitStackTraceInFastThrow, -Dio.netty.noUnsafe=true, -Dio.netty.noKeySetOptimization=true, -Dio.netty.recycler.maxCapacityPerThread=0, -Dlog4j.shutdownHookEnabled=false, -Dlog4j2.disable.jmx=true, -Djava.io.tmpdir=/tmp/elasticsearch-7720073513605769733, -XX:+HeapDumpOnOutOfMemoryError, -XX:HeapDumpPath=data, -XX:ErrorFile=logs/hs_err_pid%p.log, -Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m, -Djava.locale.providers=COMPAT, -XX:UseAVX=2, -Des.cgroups.hierarchy.override=/, -Xms1200m, -Xmx1200m, -XX:-UseConcMarkSweepGC, -XX:-UseCMSInitiatingOccupancyOnly, -XX:+UseG1GC, -Des.path.home=/usr/share/elasticsearch, -Des.path.conf=/usr/share/elasticsearch/config, -Des.distribution.flavor=default, -Des.distribution.type=tar]
[2019-03-16T17:14:03,510][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [aggs-matrix-stats]
[2019-03-16T17:14:03,517][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [analysis-common]
[2019-03-16T17:14:03,517][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [ingest-common]
[2019-03-16T17:14:03,517][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [lang-expression]
[2019-03-16T17:14:03,517][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [lang-mustache]
[2019-03-16T17:14:03,518][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [lang-painless]
[2019-03-16T17:14:03,518][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [mapper-extras]
[2019-03-16T17:14:03,518][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [parent-join]
[2019-03-16T17:14:03,518][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [percolator]
[2019-03-16T17:14:03,519][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [rank-eval]
[2019-03-16T17:14:03,519][INFO ][o.e.p.PluginsService     ] [helk-1] loaded module [reindex]
..
....
```

All you need to do now for the other ones is just replace helk-elasticsearch with the specific containers name:

```bash
sudo docker logs --follow <container name>
```

Remember that you can also access your docker images by running the following commands:

```bash
sudo docker exec -ti helk-elasticsearch bash
```

```
root@7a9d6443a4bf:/opt/helk/scripts#
```

## Final Details

Once your HELK installation ends, you will be presented with information that you will need to access the HELK and all its other components.

You will get the following information:

```
***********************************************************************************
** [HELK-INSTALLATION-INFO] HELK WAS INSTALLED SUCCESSFULLY                      **
** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **
***********************************************************************************
 
HELK KIBANA URL: https://192.168.64.138
HELK KIBANA USER: helk
HELK KIBANA PASSWORD: hunting
HELK SPARK MASTER UI: http://192.168.64.138:8080
HELK JUPYTER SERVER URL: http://192.168.64.138/jupyter
HELK JUPYTER CURRENT TOKEN: e8e83f5c9fe93882a970ce352d566adfb032b0975549449c
HELK ZOOKEEPER: 192.168.64.138:2181
HELK KSQL SERVER: 192.168.64.138:8088
 
IT IS HUNTING SEASON!!!!!
```

| Type| Description|
| :---| :---|
| HELK KIBANA URL| URL to access the Kibana server. You will need to copy that and paste it in your browser to access Kibana. Make sure you use https since Kibana is running behind NGINX via port 443 with a self-signed certificate |
| HELK KIBANA USER & PASSWORD| Credentials used to access Kibana |
| HELK SPARK MASTER UI  | URL to access the Spark Master server (Spark Standalone). That server manages the Spark Workers used during execution of code by Jupyter Notebooks. Spark Master acts as a proxy to Spark Workers and applications running |
| HELK JUPYTER SERVER URL| URL to access the Jupyter notebook server. |
| HELK JUPYTER CURRENT TOKEN | Jupyter token to log in instead of providing a password |
| ZOOKEEPER| URL for the kafka cluster zookeeper |
| KSQL SERVER| URL to access the KSQL server and send SQL queries to the data in the kafka brokers |