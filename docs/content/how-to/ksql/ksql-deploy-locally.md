# Deploy KSQL Locally

You can use KSQL CLI to connect to the HELK's KSQL Server from a different system. You will have to download the self-managed software Confluent platform and then run KSQL

* Download the self-managed software Confluent platform in a .tar.gz format from: https://www.confluent.io/download/#popup_form_3109
* Decompress the folder:

```bash
tar -xvzf confluent-5.1.2-2.11.tar.gz
```

```
x confluent-5.1.2/
x confluent-5.1.2/src/
x confluent-5.1.2/src/avro-cpp-1.8.0-confluent5.1.2.tar.gz
x confluent-5.1.2/src/librdkafka-0.11.6-confluent5.1.2.tar.gz
x confluent-5.1.2/src/confluent-libserdes-5.1.2.tar.gz
x confluent-5.1.2/src/avro-c-1.8.0-confluent5.1.2.tar.gz
x confluent-5.1.2/lib/
```

* Access the KSQL scripts:

```bash
cd confluent-5.1.2
ls
```

```
README	bin	etc	lib	logs	share	src
```

```bash
cd bin/
ls
```

```
confluent				kafka-acls				kafka-mirror-maker			kafka-server-stop			schema-registry-start
confluent-hub				kafka-api-start				kafka-mqtt-run-class			kafka-streams-application-reset		schema-registry-stop
confluent-rebalancer			kafka-avro-console-consumer		kafka-mqtt-start			kafka-topics				schema-registry-stop-service
connect-distributed			kafka-avro-console-producer		kafka-mqtt-stop				kafka-verifiable-consumer		security-plugins-run-class
connect-standalone			kafka-broker-api-versions		kafka-preferred-replica-election	kafka-verifiable-producer		sr-acl-cli
control-center-3_0_0-reset		kafka-configs				kafka-producer-perf-test		ksql					support-metrics-bundle
control-center-3_0_1-reset		kafka-console-consumer			kafka-reassign-partitions		ksql-datagen				windows
control-center-console-consumer		kafka-console-producer			kafka-replica-verification		ksql-print-metrics			zookeeper-security-migration
control-center-export			kafka-consumer-groups			kafka-rest-run-class			ksql-run-class				zookeeper-server-start
control-center-reset			kafka-consumer-perf-test		kafka-rest-start			ksql-server-start			zookeeper-server-stop
control-center-run-class		kafka-delegation-tokens			kafka-rest-stop				ksql-server-stop			zookeeper-shell
control-center-set-acls			kafka-delete-records			kafka-rest-stop-service			ksql-stop
control-center-start			kafka-dump-log				kafka-run-class				replicator
control-center-stop			kafka-log-dirs				kafka-server-start			schema-registry-run-class
Robertos-MBP:bin wardog$ 
```

* Check the options for KSQL:

```bash
./ksql --help
```

```
NAME
        ksql - KSQL CLI

SYNOPSIS
        ksql [ --config-file <configFile> ] [ {-h | --help} ]
                [ --output <outputFormat> ]
                [ --query-row-limit <streamedQueryRowLimit> ]
                [ --query-timeout <streamedQueryTimeoutMs> ] [--] <server>

OPTIONS
        --config-file <configFile>
            A file specifying configs for Ksql and its underlying Kafka Streams
            instance(s). Refer to KSQL documentation for a list of available
            configs.

        -h, --help
            Display help information

        --output <outputFormat>
            The output format to use (either 'JSON' or 'TABULAR'; can be
            changed during REPL as well; defaults to TABULAR)

        --query-row-limit <streamedQueryRowLimit>
            An optional maximum number of rows to read from streamed queries

            This options value must fall in the following range: value >= 1


        --query-timeout <streamedQueryTimeoutMs>
            An optional time limit (in milliseconds) for streamed queries

            This options value must fall in the following range: value >= 1


        --
            This option can be used to separate command-line options from the
            list of arguments (useful when arguments might be mistaken for
            command-line options)

        <server>
            The address of the Ksql server to connect to (ex:
            http://confluent.io:9098)

            This option may occur a maximum of 1 times

Robertos-MBP:bin wardog$
```

* Connect to the HELK KSQL Server. You will just need to point to the IP address of your HELK Docker environment over port 8088

```bash
./ksql http://192.168.64.138:8088
```

```           
                  ===========================================
                  =        _  __ _____  ____  _             =
                  =       | |/ // ____|/ __ \| |            =
                  =       | ' /| (___ | |  | | |            =
                  =       |  <  \___ \| |  | | |            =
                  =       | . \ ____) | |__| | |____        =
                  =       |_|\_\_____/ \___\_\______|       =
                  =                                         =
                  =  Streaming SQL Engine for Apache Kafka® =
                  ===========================================

Copyright 2017-2018 Confluent Inc.

CLI v5.1.2, Server v5.1.0 located at http://192.168.64.138:8088

Having trouble? Type 'help' (case-insensitive) for a rundown of how things work!

ksql> 
```

* Verify that you can see the topics available in the HELK Kafka broker

```bash
./ksql http://192.168.64.138:8088
```

```                  
                  ===========================================
                  =        _  __ _____  ____  _             =
                  =       | |/ // ____|/ __ \| |            =
                  =       | ' /| (___ | |  | | |            =
                  =       |  <  \___ \| |  | | |            =
                  =       | . \ ____) | |__| | |____        =
                  =       |_|\_\_____/ \___\_\______|       =
                  =                                         =
                  =  Streaming SQL Engine for Apache Kafka® =
                  ===========================================

Copyright 2017-2018 Confluent Inc.

CLI v5.1.2, Server v5.1.0 located at http://192.168.64.138:8088

Having trouble? Type 'help' (case-insensitive) for a rundown of how things work!

ksql> SHOW TOPICS;

 Kafka Topic | Registered | Partitions | Partition Replicas | Consumers | ConsumerGroups 
-----------------------------------------------------------------------------------------
 filebeat    | false      | 1          | 1                  | 0         | 0              
 SYSMON_JOIN | false      | 1          | 1                  | 0         | 0              
 winlogbeat  | false      | 1          | 1                  | 0         | 0              
 winsecurity | false      | 1          | 1                  | 0         | 0              
 winsysmon   | false      | 1          | 1                  | 0         | 0              
-----------------------------------------------------------------------------------------
ksql> 
```