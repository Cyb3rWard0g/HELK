# Update Kafka Broker IP

For the docker deployment, you will have to update the environment variable ADVERTISED_LISTENER first. You can do this in your system hosting the entire HELK or the Kafka broker itself if your distributed your docker containers across other systems.

```bash
export ADVERTISED_LISTENER=10.0.10.104
```

Then, you can simply just run docker-compose the same way how it was used to build the HELK. This will re-create the system with the new value assigned to the environment variable `ADVERTISED_LISTENER`.

```bash
sudo -E docker-compose -f helk-kibana-notebook-analysis-basic.yml up -d
```

If you just restart your containers, it will not update the environment variable in the Kafka broker. You have to re-create the container. Not re-creating the broker would still show you messages like the ones below:

```
[2019-01-25 05:35:21,026] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:24,194] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:27,362] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:30,530] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:33,698] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:36,866] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:40,034] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:43,238] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:46,306] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:49,382] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:52,450] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:55,522] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:35:58,594] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:36:01,714] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:36:04,770] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:36:08,450] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
[2019-01-25 05:36:11,650] WARN [Controller id=1, targetBrokerId=1] Connection to node 1 (/10.0.10.104:9092) could not be established. Broker may not be available. (org.apache.kafka.clients.NetworkClient)
```