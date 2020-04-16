# Follow these steps to get the latest plugins for HELK install scripts and to document them.

1.
    Download the zip file of logstash: https://www.elastic.co/downloads/logstash
1. Unzip the logstash download and then change into directory. Make sure to change the variable `Logstash_Version=` to the file name that was downloaded 
    ```bash
    Logstash_Version='logstash-7.6.2'
    unzip $Logstash_Version
    mv $Logstash_Version logstash-binary
    cd logstash-binary
    ```
1. Update existing plugins
    ```bash
    ./bin/logstash-plugin update
    ```
1. Remove some unnecessary plugins
    ```bash
    ./bin/logstash-plugin remove logstash-input-couchdb_changes;
    ./bin/logstash-plugin remove logstash-input-gelf;
    ./bin/logstash-plugin remove logstash-input-ganglia;
    ./bin/logstash-plugin remove logstash-input-graphite;
    ./bin/logstash-plugin remove logstash-input-imap;
    ./bin/logstash-plugin remove logstash-input-twitter;
    ./bin/logstash-plugin remove logstash-output-graphite;
    ./bin/logstash-plugin remove logstash-output-nagios;
    ./bin/logstash-plugin remove logstash-output-webhdfs;
    ./bin/logstash-plugin remove logstash-codec-graphite;
    ```
1. Install the logstash codec plugins
    ```bash
    ./bin/logstash-plugin install \
        logstash-codec-avro \
        logstash-codec-es_bulk \
        logstash-codec-cef \
        logstash-codec-gzip_lines \
        logstash-codec-json \
        logstash-codec-json_lines \
        logstash-codec-netflow \
        logstash-codec-nmap \
        logstash-codec-protobuf
    ```
1. Install the logstash filter plugins
    ```bash
    ./bin/logstash-plugin install \
        logstash-filter-alter \
        logstash-filter-bytes \
        logstash-filter-cidr \
        logstash-filter-cipher \
        logstash-filter-clone \
        logstash-filter-csv \
        logstash-filter-de_dot \
        logstash-filter-dissect \
        logstash-filter-dns \
        logstash-filter-elasticsearch \
        logstash-filter-fingerprint \
        logstash-filter-geoip \
        logstash-filter-i18n \
        logstash-filter-json \
        logstash-filter-json_encode \
        logstash-filter-kv \
        logstash-filter-memcached \
        logstash-filter-metricize \
        logstash-filter-prune \
        logstash-filter-translate \
        logstash-filter-urldecode \
        logstash-filter-useragent \
        logstash-filter-xml
1. Install the logstash integration plugins
    ```bash
    ./bin/logstash-plugin install \
         logstash-integration-kafka \
         logstash-integration-rabbitmq \
         logstash-integration-jdbc
    ```
1. Install the logstash input plugins
    ```bash
    ./bin/logstash-plugin install \
        logstash-input-azure_event_hubs \
        logstash-input-beats \
        logstash-input-cloudwatch \
        logstash-input-elasticsearch \
        logstash-input-file \
        logstash-input-lumberjack \
        logstash-input-google_cloud_storage \
        logstash-input-google_pubsub \
        logstash-input-s3-sns-sqs \
        logstash-input-snmp \
        logstash-input-snmptrap \
        logstash-input-syslog \
        logstash-input-tcp \
        logstash-input-udp \
        logstash-input-wmi
    ```
1. Install the logstash output plugins
    ```bash
    ./bin/logstash-plugin install \
        logstash-output-cloudwatch \
        logstash-output-csv \
        logstash-output-elasticsearch \
        logstash-output-email \
        logstash-output-google_bigquery \
        logstash-output-google_cloud_storage \
        logstash-output-google_pubsub \
        logstash-output-lumberjack \
        logstash-output-nagios \
        logstash-output-s3 \
        logstash-output-sns \
        logstash-output-stdout \
        logstash-output-syslog \
        logstash-output-tcp \
        logstash-output-udp
    ```
1. Update the plugins... again...
    ```bash
    ./bin/logstash-plugin update
    ```
1. Remove some unnecessary plugins, again yes
    ```bash
    ./bin/logstash-plugin remove logstash-codec-graphite 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-couchdb_changes 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-gelf 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-ganglia 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-graphite 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-imap 2> /dev/null;
    ./bin/logstash-plugin remove logstash-input-twitter 2> /dev/null;
    ./bin/logstash-plugin remove logstash-output-cloudwatch 2> /dev/null;
    ./bin/logstash-plugin remove logstash-output-graphite 2> /dev/null;
    ./bin/logstash-plugin remove logstash-output-nagios 2> /dev/null;
    ./bin/logstash-plugin remove logstash-output-webhdfs 2> /dev/null
    ```
1. List the plugins and corresponding versions, then add the output to [logstash-plugin-information.yml](logstash-plugin-information.txt)

    ```bash
    ./bin/logstash-plugin list --verbose
    ```
1. Package the plugins
    ```bash
    ./bin/logstash-plugin prepare-offline-pack --output helk-offline-logstash-codec_and_filter_plugins.zip --overwrite logstash-codec-* logstash-filter-* &&
    ./bin/logstash-plugin prepare-offline-pack --output helk-offline-logstash-input-plugins.zip --overwrite logstash-input-* &&
    ./bin/logstash-plugin prepare-offline-pack --output helk-offline-logstash-output-plugins.zip --overwrite logstash-output-*
    ```
1. Hash the packaged plugins
    ```bash
    sha512sum helk-offline-logstash-codec_and_filter_plugins.zip > helk-offline-logstash-codec_and_filter_plugins.zip.sha512 &&
    sha512sum helk-offline-logstash-input-plugins.zip > helk-offline-logstash-input-plugins.zip.sha512 &&
    sha512sum helk-offline-logstash-output-plugins.zip > helk-offline-logstash-output-plugins.zip.sha512
    ```
2. Move the plugins and files, via your preferred method, to `HELK/docker/helk-logstash/plugins/`
    ```bash
    cp helk-offline* Gemfile ../
    ```