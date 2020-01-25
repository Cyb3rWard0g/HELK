# Load Local Docker Images

If you followed [this document](/docker-load-images) to export your docker images locally, you should be ready to load them into an isolated system where it cannot access the dockerhub registry.

* Copy images to the isolated (10.0.10.102) system

```bash
for f in /home/helk/*.tar; do scp $f helk@10.0.10.102:/tmp/; done
```

```
helk-spark-worker.tar  100%  560MB  24.4MB/s   00:23    
helk-ksql-server.tar   100%  502MB  29.5MB/s   00:17    
helk-logstash.tar      100%  773MB  28.6MB/s   00:27    
helk-ksql-cli.tar      100%  497MB  21.6MB/s   00:23    
helk-elasticsearch.tar 100%  815MB  29.1MB/s   00:28
```  

* Check if images exist in the isolated system

```bash
ls /tmp/
```

```
helk-elastalert.tar helk-jupyter.tar 
helk-kibana.tar helk-ksql-server.tar helk-nginx.tar 
helk-spark-worker.tar helk-elasticsearch.tar
helk-kafka-broker.tar helk-ksql-cli.tar helk-logstash.tar
helk-spark-master.tar  helk-zookeeper.tar
```

* Load images with the docker load commands:

```bash
for i in /tmp/*.tar; do sudo docker load --input $i; done
```

```
f49017d4d5ce: Loading layer [==================================================>]  85.96MB/85.96MB
8f2b771487e9: Loading layer [==================================================>]  15.87kB/15.87kB
ccd4d61916aa: Loading layer [==================================================>]  10.24kB/10.24kB
c01d74f99de4: Loading layer [==================================================>]  5.632kB/5.632kB
268a067217b5: Loading layer [==================================================>]  3.072kB/3.072kB
831fff32e4f2: Loading layer [==================================================>]  65.02kB/65.02kB
c89f4fbc01f8: Loading layer [==================================================>]  103.4MB/103.4MB
adfd094c5517: Loading layer [==================================================>]  3.245MB/3.245MB
c73538215c3e: Loading layer [==================================================>]  567.6MB/567.6MB
080f01d1ecbc: Loading layer [==================================================>]  13.31kB/13.31kB
60bbd38a907e: Loading layer [==================================================>]  3.584kB/3.584kB
9affd17eb100: Loading layer [==================================================>]  5.632kB/5.632kB
0561c04cbf7e: Loading layer [==================================================>]  7.168kB/7.168kB
ba0201512417: Loading layer [==================================================>]  18.29MB/18.29MB
Loaded image: cyb3rward0g/helk-elastalert:0.2.1
071d8bd76517: Loading layer [==================================================>]  210.2MB/210.2MB
a175339dcf83: Loading layer [==================================================>]  310.5MB/310.5MB
9a70a6f483f7: Loading layer [==================================================>]  95.68MB/95.68MB
f4db77828c81: Loading layer [==================================================>]  311.3kB/311.3kB
be48c67e9d13: Loading layer [==================================================>]  237.5MB/237.5MB
432cb712190e: Loading layer [==================================================>]   7.68kB/7.68kB
a512981fd597: Loading layer [==================================================>]  9.728kB/9.728kB
Loaded image: docker.elastic.co/elasticsearch/elasticsearch:6.6.1
49778752e7ec: Loading layer [==================================================>]  394.9MB/394.9MB
5f3913b1d541: Loading layer [==================================================>]  1.667GB/1.667GB
77fa3a9c5ff6: Loading layer [==================================================>]  7.168kB/7.168kB
cbc15b984e03: Loading layer [==================================================>]  10.24kB/10.24kB
38c44d7a52f6: Loading layer [==================================================>]   5.12kB/5.12kB
0ec2dbbfd6c7: Loading layer [==================================================>]  3.584kB/3.584kB
Loaded image: cyb3rward0g/helk-jupyter:0.1.1
4e31d8c1cf96: Loading layer [==================================================>]  203.1MB/203.1MB
efb23c49455d: Loading layer [==================================================>]  11.26kB/11.26kB
```

* check if images are loaded via the docker images command

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
helk@helk:~$ 
```