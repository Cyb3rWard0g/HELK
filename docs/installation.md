# Installation

# Requirements (Please Read Carefully)
* **Operating System:**
  * Ubuntu 18.04 (preferred)
  * Ubuntu 16
  * CentOS 7 with or without SELinux in enforcement mode
  * CentOS 8 with or without SELinux in enforcement mode
* **Docker:**
  * HELK uses the official Docker Community Edition (CE) bash script (Edge Version) to install Docker for you. The Docker CE Edge script supports the following distros: **ubuntu**, **debian**, **raspbian**, **centos**, and **fedora**.
  * You can see the specific distro versions supported in the script [here](https://get.docker.com/).
  * If you have Docker & Docker-Compose already installed in your system, make sure you uninstall them to avoid old incompatible version. Let HELK use the official Docker CE Edge script execution to install Docker. 
* **Processor/OS Architecture:**
  * 64-bit also known as x64, x86_64, AMD64 or Intel 64.
  * FYI: old processors don't support SSE3 instructions to start ML (Machine Learning) on elasticsearch. Since version 6.1 Elastic has been compiling the ML programs on the assumption that SSE4.2 instructions are available (See: https://github.com/Cyb3rWard0g/HELK/issues/321 and https://discuss.elastic.co/t/failed-to-start-machine-learning-on-elasticsearch-7-0-0/178216/7)
* **Cores:** Minimum of 4 cores (whether logical or physical)
* **Network Connection:** NAT or Bridge
  * IP version 4 address. IPv6 has not been tested yet.
  * If using a proxy, documentation is yet to come - so use a proxy at your own expense. However, open a GitHub issue and we will try to help until it is officially documented/supported.
  * If using a VM then NAT or Bridge will work.
  * Internet access
    * List of required domains/IPs will be listed in future documentation.
* **RAM:** There are four options, and the following are minimum requirements (include more if you are able).
  * **Option 1: 5GB** includes `KAFKA + KSQL + ELK + NGNIX.`
  * **Option 2: 5GB** includes `KAFKA + KSQL + ELK + NGNIX + ELASTALERT`
  * **Option 3: 7GB** includes `KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER`.
  * **Option 4: 8GB** includes `KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER + ELASTALERT`.
* **Disk:** 20GB for testing purposes and 100GB+ for production (minimum)
* **Applications:**
  * Docker: 18.06.1-ce+ & Docker-Compose (HELK INSTALLS THIS FOR YOU)
  * [Winlogbeat](https://www.elastic.co/downloads/beats/winlogbeat) running on your endpoints or centralized WEF server (that your endpoints are forwarding to).
    * You can install Winlogbeat by following one of [@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g) posts [here](https://cyberwardog.blogspot.com/2017/02/setting-up-pentesting-i-mean-threat_87.html).
   * [Winlogbeat config](https://github.com/Cyb3rWard0g/HELK/blob/master/configs/winlogbeat/winlogbeat.yml) recommended by the HELK since it uses the [Kafka output plugin](https://www.elastic.co/guide/en/beats/winlogbeat/current/kafka-output.html) and it is already pointing to the right ports with recommended options. You will just have to add your HELK's IP address.
 
# HELK Download
Run the following commands to clone the HELK repo via git.

```bash
git clone https://github.com/Cyb3rWard0g/HELK.git
```

# HELK Install
In order to make the installation of the HELK easy for everyone, the project comes with an install script named **helk_install.sh**. This script builds and runs everything for HELK automatically. During the installation process, the script will allow you to set up the following:
* Set the components/applications for the HELK'
* Set the Kibana User's password. Default user is **helk**
* Set the HELK's IP. By default you can confirm that you want to use your HOST IP address for the HELK, unless you want to use a different one. Press \[Return\] or let the script continue on its own (90 Seconds sleep).
* Set the HELK's License Subscription. By default the HELK has the **basic** subscription selected. You can set it to **trial** if you want and will be valid for 30 days. If you want to learn more about subscriptions go [here](https://www.elastic.co/subscriptions)
  * If the license is set to **trial**, HELK asks you to set the password for the **elastic** account.

**To install HELK:**  
Change your current directory location to the new HELK directory, and run the **helk_install.sh** bash script as shown:

```bash
cd HELK/docker
sudo ./helk_install.sh
```

**Here is an example output of installing the HELK using Option 2**

```
**********************************************
**          HELK - THE HUNTING ELK          **
**                                          **
** Author: Roberto Rodriguez (@Cyb3rWard0g) **
** HELK build version: v0.1.8-alpha01032020 **
** HELK ELK version: 7.6.2                  **
** License: GPL-3.0                         **
**********************************************
 
[HELK-INSTALLATION-INFO] HELK hosted on a Linux box
[HELK-INSTALLATION-INFO] Available Memory: 8345 MBs
[HELK-INSTALLATION-INFO] You're using ubuntu version bionic
 
*****************************************************
*      HELK - Docker Compose Build Choices          *
*****************************************************
 
1. KAFKA + KSQL + ELK + NGNIX
2. KAFKA + KSQL + ELK + NGNIX + ELASTALERT
3. KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER
4. KAFKA + KSQL + ELK + NGNIX + SPARK + JUPYTER + ELASTALERT
 
Enter build choice [ 1 - 4]: 2
[HELK-INSTALLATION-INFO] HELK build set to 2
[HELK-INSTALLATION-INFO] Set HELK IP. Default value is your current IP: 10.66.6.35

[HELK-INSTALLATION-INFO] Please make sure to create a custom Kibana password and store it securely for future use.
[HELK-INSTALLATION-INFO] Set HELK Kibana UI Password: Mmh3QAvQm3535F4f4VZQD
[HELK-INSTALLATION-INFO] Verify HELK Kibana UI Password: Mmh3QAvQm3535F4f4VZQD
[HELK-INSTALLATION-INFO] Docker already installed
[HELK-INSTALLATION-INFO] Making sure you assigned enough disk space to the current Docker base directory
[HELK-INSTALLATION-INFO] Available Docker Disk: 107 GBs
[HELK-INSTALLATION-INFO] Checking local vm.max_map_count variable and setting it to 4120294
[HELK-INSTALLATION-INFO] Setting local vm.swappiness variable to 25
[HELK-INSTALLATION-INFO] Building & running HELK from helk-kibana-analysis-alert-basic.yml file..
[HELK-INSTALLATION-INFO] Waiting for some services to be up .....
 
 
***********************************************************************************
** [HELK-INSTALLATION-INFO] HELK WAS INSTALLED SUCCESSFULLY                      **
** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **
***********************************************************************************
 
HELK KIBANA URL: https://10.66.6.35
HELK KIBANA USER: helk
HELK KIBANA PASSWORD: Mmh3QAvQm3535F4f4VZQD
HELK ZOOKEEPER: 10.66.6.35:2181
HELK KSQL SERVER: 10.66.6.35:8088
 
IT IS HUNTING SEASON!!!!!
 
You can stop all the HELK docker containers by running the following command:
 [+] sudo docker-compose -f helk-kibana-analysis-alert-basic.yml stop
 
```
# Monitor HELK installation Logs (Always)
Once the installation kicks in, it will start showing you pre-defined messages about the installation, but no all the details of what is actually happening in the background. It is designed that way to keep your main screen clean and let you know where it is in the installation process.

What I recommend to do all the time is to open another shell and monitor the HELK installation logs by using the **tail** command and pointing it to the **/var/log/helk-install.log** file that gets created by the **helk_install** script as soon as it is run. This log file is available on your local host even if you are deploying the HELK via Docker (I want to make sure it is clear that it is a local file).

```bash
tail -f /var/log/helk-install.log 
```

```
Adding password for user helk
Creating network "docker_helk" with driver "bridge"
Creating volume "docker_esdata" with local driver
Pulling helk-elasticsearch (docker.elastic.co/elasticsearch/elasticsearch:7.6.2)...
7.6.2: Pulling from elasticsearch/elasticsearch
Digest: sha256:771240a8e1c76cc6ac6aa740d2b82de94d4b8b7dbcca5ad0cf49d12b88a3b8e7
Status: Downloaded newer image for docker.elastic.co/elasticsearch/elasticsearch:7.6.2
Pulling helk-kibana (docker.elastic.co/kibana/kibana:7.6.2)...
7.6.2: Pulling from kibana/kibana
Digest: sha256:fb0ac36c40de29b321a30805bcbda4cbe486e1c5979780647458ad77b5ee2f98
Status: Downloaded newer image for docker.elastic.co/kibana/kibana:7.6.2
Pulling helk-logstash (otrf/helk-logstash:7.6.2)...
7.6.2: Pulling from otrf/helk-logstash
Digest: sha256:c54057ff1d02d7ebae23e49835060c0b4012844312c674ce2264d8bbaee64f1a
Status: Downloaded newer image for otrf/helk-logstash:7.6.2
Pulling helk-nginx (otrf/helk-nginx:0.3.0)...
0.0.8: Pulling from otrf/helk-nginx
Digest: sha256:83e86d3ee3891b8a06173f4278ddc9f85cbba9b2dfceada48fb311411e236341
Status: Downloaded newer image for otrf/helk-nginx:0.3.0
Pulling helk-zookeeper (otrf/helk-zookeeper:2.4.0)...
2.3.0: Pulling from otrf/helk-zookeeper
Digest: sha256:3e7a0f3a73bcffeac4f239083618c362017005463dd747392a9b43db99535a68
Status: Downloaded newer image for otrf/helk-zookeeper:2.4.0
Pulling helk-kafka-broker (otrf/helk-kafka-broker:2.4.0)...
2.3.0: Pulling from otrf/helk-kafka-broker
Digest: sha256:03569d98c46028715623778b4adf809bf417a055c3c19d21f426db4e1b2d6f55
Status: Downloaded newer image for otrf/helk-kafka-broker:2.4.0
Pulling helk-ksql-server (confluentinc/cp-ksql-server:5.1.3)...
5.1.3: Pulling from confluentinc/cp-ksql-server
Digest: sha256:063add111cc93b1a0118f88b577e31303045d4cc08eb1d21458429f05cba4b02
Status: Downloaded newer image for confluentinc/cp-ksql-server:5.1.3
Pulling helk-ksql-cli (confluentinc/cp-ksql-cli:5.1.3)...
5.1.3: Pulling from confluentinc/cp-ksql-cli
Digest: sha256:18c0ccb00fbf87679e16e9e0da600548fcb236a2fd173263b09e89b2d3a42cc3
Status: Downloaded newer image for confluentinc/cp-ksql-cli:5.1.3
Pulling helk-elastalert (otrf/helk-elastalert:0.3.0)...
0.2.6: Pulling from otrf/helk-elastalert
Digest: sha256:ae1096829aacbadce42bd4024b36da3a9636f1901ef4e9e62a12b881cfc23cf5
Status: Downloaded newer image for otrf/helk-elastalert:0.3.0
Creating helk-elasticsearch ... done
Creating helk-kibana        ... done
Creating helk-logstash      ... done
Creating helk-nginx         ... done
Creating helk-zookeeper     ... done
Creating helk-elastalert    ... done
Creating helk-kafka-broker  ... done
Creating helk-ksql-server   ... done
Creating helk-ksql-cli      ... done
```
Once you see that the containers have been created you can check all the containers running by executing the following:

```bash
sudo docker ps
```

```
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS                                                                              NAMES
2caa7d86bc9e        confluentinc/cp-ksql-cli:5.1.3                        "/bin/sh"                5 minutes ago       Up 5 minutes                                                                                           helk-ksql-cli
1ee3c0d90b2a        confluentinc/cp-ksql-server:5.1.3                     "/etc/confluent/dock…"   5 minutes ago       Up 5 minutes        0.0.0.0:8088->8088/tcp                                                             helk-ksql-server
e753a811ffd2        otrf/helk-kafka-broker:2.4.0                          "./kafka-entrypoint.…"   5 minutes ago       Up 5 minutes        0.0.0.0:9092->9092/tcp                                                             helk-kafka-broker
f93239de7d95        otrf/helk-zookeeper:2.4.0                             "./zookeeper-entrypo…"   5 minutes ago       Up 5 minutes        2181/tcp, 2888/tcp, 3888/tcp                                                       helk-zookeeper
229ea8467075        otrf/helk-elastalert:0.3.0                            "./elastalert-entryp…"   5 minutes ago       Up 5 minutes                                                                                           helk-elastalert
f6fd290d2a9d        otrf/helk-nginx:0.3.0                                 "/opt/helk/scripts/n…"   5 minutes ago       Up 5 minutes        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp                                           helk-nginx
d4f2b6d7d21e        otrf/helk-logstash:7.6.2                              "/usr/share/logstash…"   5 minutes ago       Up 5 minutes        0.0.0.0:3515->3515/tcp, 0.0.0.0:5044->5044/tcp, 0.0.0.0:8531->8531/tcp, 9600/tcp   helk-logstash
c5ae143741ea        docker.elastic.co/kibana/kibana:7.6.2                 "/usr/share/kibana/s…"   5 minutes ago       Up 5 minutes        5601/tcp                                                                           helk-kibana
1729e3234b91        docker.elastic.co/elasticsearch/elasticsearch:7.6.2   "/usr/share/elastics…"   5 minutes ago       Up 5 minutes        9200/tcp, 9300/tcp                                                                 helk-elasticsearch
```

If you want to monitor the resources being utilized (Memory, CPU, etc), you can run the following:

```
user@HELK-vm:~$ sudo docker stats --all

CONTAINER ID        NAME                 CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
2caa7d86bc9e        helk-ksql-cli        0.00%               840KiB / 8.703GiB     0.01%               26.3kB / 0B         98.3kB / 0B         1
1ee3c0d90b2a        helk-ksql-server     0.29%               222.6MiB / 8.703GiB   2.50%               177kB / 125kB       147kB / 197kB       31
e753a811ffd2        helk-kafka-broker    1.71%               366.4MiB / 8.703GiB   4.11%               381kB / 383kB       823kB / 2.14MB      74
f93239de7d95        helk-zookeeper       0.18%               74.24MiB / 8.703GiB   0.83%               109kB / 67.2kB      111kB / 1.39MB      48
229ea8467075        helk-elastalert      10.71%              53.78MiB / 8.703GiB   0.60%               2.34MB / 3.39MB     3.62MB / 1.87MB     12
f6fd290d2a9d        helk-nginx           0.02%               6.562MiB / 8.703GiB   0.07%               28.7kB / 1.54kB     61.4kB / 12.3kB     7
d4f2b6d7d21e        helk-logstash        10.46%              1.337GiB / 8.703GiB   15.36%              632kB / 154MB       430MB / 31.5MB      81
c5ae143741ea        helk-kibana          1.10%               359.7MiB / 8.703GiB   4.04%               345kB / 1.18MB      458MB / 12.3kB      13
1729e3234b91        helk-elasticsearch   43.62%              3.524GiB / 8.703GiB   40.49%              159MB / 3.14MB      609MB / 600MB       77
```

You should also monitor the logs of each container while they are being initialized:

Just run the following:

```
user@HELK-vm:~$ sudo docker logs --follow --tail 20 helk-elasticsearch

[HELK-ES-DOCKER-INSTALLATION-INFO] Setting ES_JAVA_OPTS to -Xms3200m -Xmx3200m from custom HELK "algorithm"
[HELK-ES-DOCKER-INSTALLATION-INFO] Setting Elastic license to basic
[HELK-ES-DOCKER-INSTALLATION-INFO] Running docker-entrypoint script..
{"type": "server", "timestamp": "2020-01-25T04:26:19,448Z", "level": "INFO", "component": "o.e.e.NodeEnvironment", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "using [1] data paths, mounts [[/usr/share/elasticsearch/data (/dev/mapper/ubuntu--vg-root)]], net usable_space [102.2gb], net total_space [116.6gb], types [ext4]" }
{"type": "server", "timestamp": "2020-01-25T04:26:19,451Z", "level": "INFO", "component": "o.e.e.NodeEnvironment", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "heap size [3gb], compressed ordinary object pointers [true]" }
{"type": "server", "timestamp": "2020-01-25T04:26:19,458Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "node name [helk-1], node ID [Ed3L9UydShyLmPCbP3GLxw], cluster name [helk-cluster]" }
{"type": "server", "timestamp": "2020-01-25T04:26:19,459Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "version[7.6.2], pid[16], build[default/docker/8bec50e1e0ad29dad5653712cf3bb580cd1afcdf/2020-01-15T12:11:52.313576Z], OS[Linux/4.15.0-74-generic/amd64], JVM[AdoptOpenJDK/OpenJDK 64-Bit Server VM/13.0.1/13.0.1+9]" }
{"type": "server", "timestamp": "2020-01-25T04:26:19,459Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "JVM home [/usr/share/elasticsearch/jdk]" }
{"type": "server", "timestamp": "2020-01-25T04:26:19,460Z", "level": "INFO", "component": "o.e.n.Node", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "JVM arguments [-Des.networkaddress.cache.ttl=60, -Des.networkaddress.cache.negative.ttl=10, -XX:+AlwaysPreTouch, -Xss1m, -Djava.awt.headless=true, -Dfile.encoding=UTF-8, -Djna.nosys=true, -XX:-OmitStackTraceInFastThrow, -Dio.netty.noUnsafe=true, -Dio.netty.noKeySetOptimization=true, -Dio.netty.recycler.maxCapacityPerThread=0, -Dio.netty.allocator.numDirectArenas=0, -Dlog4j.shutdownHookEnabled=false, -Dlog4j2.disable.jmx=true, -Djava.locale.providers=COMPAT, -XX:+UseConcMarkSweepGC, -XX:CMSInitiatingOccupancyFraction=75, -XX:+UseCMSInitiatingOccupancyOnly, -Des.networkaddress.cache.ttl=60, -Des.networkaddress.cache.negative.ttl=10, -XX:+AlwaysPreTouch, -Djava.io.tmpdir=/tmp/elasticsearch-3812421782724323797, -XX:+HeapDumpOnOutOfMemoryError, -XX:HeapDumpPath=data, -XX:ErrorFile=logs/hs_err_pid%p.log, -Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m, -Djava.locale.providers=COMPAT, -Des.cgroups.hierarchy.override=/, -Xms3200m, -Xmx3200m, -XX:MaxDirectMemorySize=1677721600, -Des.path.home=/usr/share/elasticsearch, -Des.path.conf=/usr/share/elasticsearch/config, -Des.distribution.flavor=default, -Des.distribution.type=docker, -Des.bundled_jdk=true]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,523Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [aggs-matrix-stats]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,523Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [analysis-common]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,524Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [flattened]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,524Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [frozen-indices]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,524Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [ingest-common]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,524Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [ingest-geoip]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [ingest-user-agent]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [lang-expression]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [lang-mustache]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [lang-painless]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [mapper-extras]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [parent-join]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,526Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [percolator]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,527Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [rank-eval]" }
{"type": "server", "timestamp": "2020-01-25T04:26:21,527Z", "level": "INFO", "component": "o.e.p.PluginsService", "cluster.name": "helk-cluster", "node.name": "helk-1", "message": "loaded module [reindex]" }

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
[root@1729e3234b91 elasticsearch]# 
```

# Final Details
Once your HELK installation ends, you will be presented with information that you will need to access the HELK and all its other components. 

You will get the following information:

```
***********************************************************************************
** [HELK-INSTALLATION-INFO] HELK WAS INSTALLED SUCCESSFULLY                      **
** [HELK-INSTALLATION-INFO] USE THE FOLLOWING SETTINGS TO INTERACT WITH THE HELK **
***********************************************************************************
 
HELK KIBANA URL: https://192.168.1.35
HELK KIBANA USER: helk
HELK KIBANA PASSWORD: Mmh3QAvQm3535F4f4VZQD
HELK ZOOKEEPER: 192.168.1.35:2181
HELK KSQL SERVER: 192.168.1.35:8088
 
IT IS HUNTING SEASON!!!!!
 
You can stop all the HELK docker containers by running the following command:
 [+] sudo docker-compose -f helk-kibana-analysis-alert-trial.yml stop

```

| Type | Description |
|--------|---------|
| HELK KIBANA URL | URL to access the Kibana server. You will need to copy that and paste it in your browser to access Kibana. Make sure you use **https** since Kibana is running behind NGINX via port 443 with a self-signed certificate|
| HELK KIBANA USER & PASSWORD | Credentials used to access Kibana |
| HELK SPARK MASTER UI | URL to access the Spark Master server (Spark Standalone). That server manages the Spark Workers used during execution of code by Jupyter Notebooks. Spark Master acts as a proxy to Spark Workers and applications running |
| HELK JUPYTER SERVER URL | URL to access the Jupyter notebook server. |
| HELK JUPYTER CURRENT TOKEN | Jupyter token to log in instead of providing a password |
| ZOOKEEPER | URL for the kafka cluster zookeeper |
| KSQL SERVER| URL to access the KSQL server and send SQL queries to the data in the kafka brokers|