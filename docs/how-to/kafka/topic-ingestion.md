# Check Kafka Topic Ingestion

There are a few ways that you can accomplish this

## HELK's Kafka broker container

Access your kafka broker container by running the following command:

```bash
sudo docker exec -ti helk-kafka-broker bash
```

Run the kafka-console-consumer.sh script available in the container:

```bash
/opt/helk/kafka/bin/kafka-console-consumer.sh --bootstrap-server helk-kafka-broker:9092 --topic winlogbeat --from-beginning
```

or simply run the script without an interactive shell

```bash
sudo docker exec -ti helk-kafka-broker /opt/helk/kafka/bin/kafka-console-consumer.sh --bootstrap-server helk-kafka-broker:9092 --topic winlogbeat --from-beginning
```

## Kafkacat

It is generic non-JVM producer and consumer for Apache Kafka >=0.8, think of it as a netcat for Kafka. You can install it by following the [instructions](https://github.com/edenhill/kafkacat#install) from the Kafkacat repo.

```bash
kafkacat -b 10.0.10.100:9092 -t winlogbeat -C
```

## References

* [Kafka Consumer Example](https://kafka.apache.org/quickstart#quickstart_consume)
* [Kafkacat](https://github.com/edenhill/kafkacat)
