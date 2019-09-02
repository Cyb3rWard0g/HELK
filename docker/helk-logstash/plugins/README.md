### Follow these steps to get the latest plugins for HELK install scripts and to document them.

**Make sure to use a standalone version of logstash aka the zip/tar.gz version.**

1) Using the standalone version of logstash, change into its directory  
```
cd logstash-standalone/
```

1) Remove some unnecessary plugins
```  
./bin/logstash-plugin remove logstash-input-couchdb_changes && 
./bin/logstash-plugin remove logstash-input-gelf && 
./bin/logstash-plugin remove logstash-input-ganglia && 
./bin/logstash-plugin remove logstash-input-graphite && 
./bin/logstash-plugin remove logstash-input-imap && 
./bin/logstash-plugin remove logstash-input-twitter && 
./bin/logstash-plugin remove logstash-output-cloudwatch && 
./bin/logstash-plugin remove logstash-output-graphite && 
./bin/logstash-plugin remove logstash-output-nagios && 
./bin/logstash-plugin remove logstash-output-rabbitmq && 
./bin/logstash-plugin remove logstash-output-webhdfs && 
./bin/logstash-plugin remove logstash-codec-graphite
```
1) Install the logstash codec plugins  
```
./bin/logstash-plugin install logstash-codec-avro && 
./bin/logstash-plugin install logstash-codec-es_bulk && 
./bin/logstash-plugin install logstash-codec-cef && 
./bin/logstash-plugin install logstash-codec-gzip_lines && 
./bin/logstash-plugin install logstash-codec-json && 
./bin/logstash-plugin install logstash-codec-json_lines && 
./bin/logstash-plugin install logstash-codec-netflow && 
./bin/logstash-plugin install logstash-codec-nmap && 
./bin/logstash-plugin install logstash-codec-protobuf
```

1) Install the logstash filter plugins  
```
./bin/logstash-plugin install logstash-filter-alter && 
./bin/logstash-plugin install logstash-filter-bytes && 
./bin/logstash-plugin install logstash-filter-cidr && 
./bin/logstash-plugin install logstash-filter-cipher && 
./bin/logstash-plugin install logstash-filter-clone && 
./bin/logstash-plugin install logstash-filter-csv && 
./bin/logstash-plugin install logstash-filter-de_dot && 
./bin/logstash-plugin install logstash-filter-dissect && 
./bin/logstash-plugin install logstash-filter-dns && 
./bin/logstash-plugin install logstash-filter-elasticsearch && 
./bin/logstash-plugin install logstash-filter-fingerprint && 
./bin/logstash-plugin install logstash-filter-geoip && 
./bin/logstash-plugin install logstash-filter-i18n && 
./bin/logstash-plugin install logstash-filter-jdbc_static && 
./bin/logstash-plugin install logstash-filter-jdbc_streaming && 
./bin/logstash-plugin install logstash-filter-json && 
./bin/logstash-plugin install logstash-filter-json_encode && 
./bin/logstash-plugin install logstash-filter-kv && 
./bin/logstash-plugin install logstash-filter-memcached && 
./bin/logstash-plugin install logstash-filter-metricize && 
./bin/logstash-plugin install logstash-filter-prune && 
./bin/logstash-plugin install logstash-filter-translate && 
./bin/logstash-plugin install logstash-filter-urldecode && 
./bin/logstash-plugin install logstash-filter-useragent && 
./bin/logstash-plugin install logstash-filter-xml
```

1) Install the logstash input plugins  
```
./bin/logstash-plugin install logstash-input-beats && 
./bin/logstash-plugin install logstash-input-elasticsearch && 
./bin/logstash-plugin install logstash-input-file && 
./bin/logstash-plugin install logstash-input-jdbc && 
./bin/logstash-plugin install logstash-input-kafka && 
./bin/logstash-plugin install logstash-input-lumberjack && 
./bin/logstash-plugin install logstash-input-snmptrap && 
./bin/logstash-plugin install logstash-input-syslog && 
./bin/logstash-plugin install logstash-input-tcp && 
./bin/logstash-plugin install logstash-input-udp && 
./bin/logstash-plugin install logstash-input-wmi && 
```

1) Install the logstash output plugins  
```
./bin/logstash-plugin install logstash-output-csv && 
./bin/logstash-plugin install logstash-output-elasticsearch && 
./bin/logstash-plugin install logstash-output-email && 
./bin/logstash-plugin install logstash-output-kafka && 
./bin/logstash-plugin install logstash-output-lumberjack && 
./bin/logstash-plugin install logstash-output-nagios && 
./bin/logstash-plugin install logstash-output-stdout && 
./bin/logstash-plugin install logstash-output-syslog && 
./bin/logstash-plugin install logstash-output-tcp && 
./bin/logstash-plugin install logstash-output-udp
```

1) Update the plugins... Even after you have already installed them...  
```
./bin/logstash-plugin update
```

1) List the plugins and corresponding versions, then add the output to [logstash-plugin-information.yml](logstash-plugin-information.yml)  
```
./bin/logstash-plugin list --verbose
```

1) Package the plugins  
```
./bin/logstash-plugin prepare-offline-pack --output helk-offline-logstash-codec_and_filter_plugins.zip --overwrite logstash-codec-* logstash-filter-* && 
./bin/logstash-plugin prepare-offline-pack --output helk-offline-logstash-input_and_output-plugins.zip --overwrite logstash-input-* logstash-output-*
```

1) Hash the packaged plugins  
```
sha512sum helk-offline-logstash-codec_and_filter_plugins.zip > helk-offline-logstash-codec_and_filter_plugins.zip.sha512 && 
sha512sum helk-offline-logstash-input_and_output-plugins.zip > helk-offline-logstash-input_and_output-plugins.zip.sha512
```

1) Move the plugins and sha512 file, via your preferred method, to [this directory](.)