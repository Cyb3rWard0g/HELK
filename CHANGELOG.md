# Changelog

## [Alpha] Verion 0.1.7-02242019
----------------------------------

[Full Changelog](https://github.com/Cyb3rWard0g/HELK/compare/v0.1.6-alpha12132018...v0.1.7-alpha02242019)

### Fixed:
**Jupyter [Docker]**
* Access and modification of notebooks by [@Nick_Aleks](https://twitter.com/Nick_Aleks)

**KSQL [Docker]**
* KSQL Commands for Sysmon JOIN recipe

**Nginx [Docker]**
* Updated proxy config to handle SSL better and not block internal HELK files from users

**Logstash [Docker]**
* For builds with elastic trial subscription, I had to move the logstash config out of volumes and add it manually to the docker container to avoid access and read issues from logstash container to local file.

### Added:
**Logstash [Docker]**
* Osquery Filebeat Output by [@rrcyrus](https://twitter.com/rrcyrus)
* Additional awesome sauce provided by [@neu5ron](https://twitter.com/neu5ron) in details [here](https://blog.neu5ron.com/2019/02/what-in-helk-release.html)

**Kafka [Docker]**
* Osquery Filebeat Topic by [@rrcyrus](https://twitter.com/rrcyrus)
* win_security topic to get win security events parsed back
* win_sysmon topic to get win sysmon events parsed back

**Jupyter [Docker]**
* jupyterlab-manager widgets
* Python package Keras 2.2.4
* Python package s3sf 0.2.0

**Kibana [Docker]**
* Additional awesome sauce provided by [@neu5ron](https://twitter.com/neu5ron) in details [here](https://blog.neu5ron.com/2019/02/what-in-helk-release.html)

### Updated:

**Jupyter [Docker]**

* ES-Hadoop version to 6.6.1
* Notebooks for intro to pandas and python
* Notebooks for intro to Spark SQL via Pyspark
* Notebooks for intro to Spark SQL via Pyspark and Sysmon
* python package altair to 2.4.1
* python package pandas to 0.24.1
* Docker Image to 0.1.1

**ELK Stack [Docker]**
* Version 6.6.1
* Consolidated 
* Additional awesome sauce provided by [@neu5ron](https://twitter.com/neu5ron) in details [here](https://blog.neu5ron.com/2019/02/what-in-helk-release.html)

**helk_install [Docker]**
* Downloads docker via https by [tifkin_](https://twitter.com/tifkin_)
* Additional awesome sauce provided by [@neu5ron](https://twitter.com/neu5ron) in details [here](https://blog.neu5ron.com/2019/02/what-in-helk-release.html)

**helk_update [Docker]**
* Update handling improved by [devdua](https://github.com/devdua)
