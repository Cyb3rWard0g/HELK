# Create Plugins Offline Package

If you are installing HELK, and the helk-logstash extra plugins are still being installed over the Internet, you can use the following steps to export them in an zipped offline package to then be loaded to the system that does not have access to the Internet and it is stuck at installing plugins.

Remember that you will need to do this in a system where HELK is already installed and the plugins were installed successfully.

* Access your helk-logstash docker container in the system where HELK was successfully installed already:

```bash
sudo docker exec -ti helk-logstash bash
```

```
bash-4.2$
```

* Using the logstash-plugin script prepare and export the plugins offline package

```bash
bin/logstash-plugin prepare-offline-pack logstash-filter-translate logstash-filter-dns  logstash-filter-cidr  logstash-filter-geoip logstash-filter-dissect  logstash-output-kafka  logstash-input-kafka  logstash-filter-alter  logstash-filter-fingerprint  logstash-filter-prune  logstash-codec-gzip_lines  logstash-codec-netflow  logstash-filter-i18n  logstash-filter-environment  logstash-filter-de_dot  logstash-input-wmi  logstash-filter-clone
```

```
Offline package created at: /usr/share/logstash/logstash-offline-plugins-6.6.1.zip

You can install it with this command
bin/logstash-plugin install file:///usr/share/logstash/logstash-offline-plugins-6.6.1.zip
```


* Copy the offline package from your helk-logstash container to your local system

```bash
sudo docker cp helk-logstash:/usr/share/logstash/logstash-offline-plugins-6.6.1.zip .
```

* Copy the logstash-offline-plugins-6.6.1.zip to the OFFLINE-ISOLATED (i.e. 10.0.10.102) system. You bust be authorized to ssh to it.

```bash
scp logstash-offline-plugins-6.6.1.zip helk@10.0.10.102:/home/helk/
```

Now you should be able to use it in the offline-isolated HELK system
