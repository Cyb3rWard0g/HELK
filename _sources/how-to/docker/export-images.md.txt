# Export Docker Images locally

If the system where you are planning to install HELK is isolated from the Internet, you can run HELK on another system that has access to the Internet and then export the built/downloaded images to .tar files. You can then LOAD Those image files in the system that is isolated from the Internet.

* List all the images available in the non-isolated system via the docker images command

```bash
sudo docker images
```

```
REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
cyb3rward0g/helk-jupyter                        0.1.1               efa46ecc8d32        2 days ago          2.18GB
confluentinc/cp-ksql-server                     5.1.2               f57298019757        6 days ago          514MB
confluentinc/cp-ksql-cli                        5.1.2               bd411ce0ba9f        6 days ago          510MB
docker.elastic.co/logstash/logstash             6.6.1               3e7fbb7964ee        11 days ago         786MB
docker.elastic.co/kibana/kibana                 6.6.1               b94222148a00        11 days ago         710MB
docker.elastic.co/elasticsearch/elasticsearch   6.6.1               c6ffcb0ee97e        11 days ago         842MB
cyb3rward0g/helk-elastalert                     0.2.1               569f588a22fc        3 weeks ago         758MB
cyb3rward0g/helk-kafka-broker                   2.1.0               7b3e7f9ce732        2 months ago        388MB
cyb3rward0g/helk-zookeeper                      2.1.0               abb732da3e50        2 months ago        388MB
cyb3rward0g/helk-spark-worker                   2.4.0               b1545b0582db        2 months ago        579MB
cyb3rward0g/helk-spark-master                   2.4.0               70fc61de3445        2 months ago        579MB
cyb3rward0g/helk-nginx                          0.0.7               280d044b6719        6 months ago        329MB
```

* List all the containers running in the non-isolated system via the docker ps command

```bash
sudo docker ps
```

```
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS                                                      NAMES
de048c88dc7f        confluentinc/cp-ksql-cli:5.1.2                        "/bin/sh"                6 hours ago         Up 6 hours                                                                     helk-ksql-cli
69e06070c14c        confluentinc/cp-ksql-server:5.1.2                     "/etc/confluent/dock…"   6 hours ago         Up 6 hours          0.0.0.0:8088->8088/tcp                                     helk-ksql-server
d57967977c9c        cyb3rward0g/helk-kafka-broker:2.1.0                   "./kafka-entrypoint.…"   6 hours ago         Up 6 hours          0.0.0.0:9092->9092/tcp                                     helk-kafka-broker
4889e917d76d        cyb3rward0g/helk-spark-worker:2.4.0                   "./spark-worker-entr…"   6 hours ago         Up 6 hours                                                                     helk-spark-worker
c0a29d8b18a7        cyb3rward0g/helk-nginx:0.0.7                          "/opt/helk/scripts/n…"   6 hours ago         Up 6 hours          0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp                   helk-nginx
6a887d693a31        cyb3rward0g/helk-elastalert:0.2.1                     "./elastalert-entryp…"   6 hours ago         Up 6 hours                                                                     helk-elastalert
a32be7a399c7        cyb3rward0g/helk-zookeeper:2.1.0                      "./zookeeper-entrypo…"   6 hours ago         Up 6 hours          2181/tcp, 2888/tcp, 3888/tcp                               helk-zookeeper
c636a8a1e8f7        cyb3rward0g/helk-spark-master:2.4.0                   "./spark-master-entr…"   6 hours ago         Up 6 hours          7077/tcp, 0.0.0.0:8080->8080/tcp                           helk-spark-master
ef1b8d8015ab        cyb3rward0g/helk-jupyter:0.1.1                        "./jupyter-entrypoin…"   6 hours ago         Up 6 hours          8000/tcp                                                   helk-jupyter
bafeeb1587cf        docker.elastic.co/logstash/logstash:6.6.1             "/usr/share/logstash…"   6 hours ago         Up 6 hours          0.0.0.0:5044->5044/tcp, 0.0.0.0:8531->8531/tcp, 9600/tcp   helk-logstash
29b57e5c71e5        docker.elastic.co/kibana/kibana:6.6.1                 "/usr/share/kibana/s…"   6 hours ago         Up 6 hours          5601/tcp                                                   helk-kibana
48499aa83917        docker.elastic.co/elasticsearch/elasticsearch:6.6.1   "/usr/share/elastics…"   6 hours ago         Up 6 hours          9200/tcp, 9300/tcp                                         helk-elasticsearch
```

* Export images as tar files:

```bash
sudo docker save -o /home/helk/helk-ksql-cli.tar confluentinc/cp-ksql-cli:5.1.2 
sudo docker save -o /home/helk/helk-ksql-server.tar confluentinc/cp-ksql-server:5.1.2  
sudo docker save -o /home/helk/helk-kafka-broker.tar cyb3rward0g/helk-kafka-broker:2.1.0
sudo docker save -o /home/helk/helk-spark-worker.tar cyb3rward0g/helk-spark-worker:2.4.0
sudo docker save -o /home/helk/helk-nginx.tar cyb3rward0g/helk-nginx:0.0.7
sudo docker save -o /home/helk/helk-elastalert.tar cyb3rward0g/helk-elastalert:0.2.1
sudo docker save -o /home/helk/helk-zookeeper.tar cyb3rward0g/helk-zookeeper:2.1.0
sudo docker save -o /home/helk/helk-spark-master.tar cyb3rward0g/helk-spark-master:2.4.0
sudo docker save -o /home/helk/helk-logstash.tar docker.elastic.co/logstash/logstash:6.6.1
sudo docker save -o /home/helk/helk-kibana.tar docker.elastic.co/kibana/kibana:6.6.1
sudo docker save -o /home/helk/helk-elasticsearch.tar docker.elastic.co/elasticsearch/elasticsearch:6.6.1
sudo docker save -o /home/helk/helk-jupyter.tar cyb3rward0g/helk-jupyter:0.1.1
```

* check if images exist locally

```bash
ls -l
```

```
total 10810584
drwxrwxr-x 9 helk helk       4096 Feb 24 21:01 HELK
-rw------- 1 root root  778629632 Feb 25 03:07 helk-elastalert.tar
-rw------- 1 root root  854236160 Feb 25 03:12 helk-elasticsearch.tar
-rw------- 1 root root 2254629888 Feb 25 03:14 helk-jupyter.tar
-rw------- 1 root root  395871744 Feb 25 03:04 helk-kafka-broker.tar
-rw------- 1 root root  767277568 Feb 25 03:11 helk-kibana.tar
-rw------- 1 root root  521177600 Feb 25 03:00 helk-ksql-cli.tar
-rw------- 1 root root  525901824 Feb 25 03:02 helk-ksql-server.tar
-rw------- 1 root root  810578944 Feb 25 03:09 helk-logstash.tar
-rw------- 1 root root  335945728 Feb 25 03:06 helk-nginx.tar
-rw------- 1 root root  587616768 Feb 25 03:08 helk-spark-master.tar
-rw------- 1 root root  587616768 Feb 25 03:05 helk-spark-worker.tar
-rw------- 1 root root  395854848 Feb 25 03:08 helk-zookeeper.tar

helk@ubuntu:~$
```