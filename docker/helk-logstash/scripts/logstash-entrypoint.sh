#!/bin/bash

# HELK script: logstash-entrypoint.sh
# HELK script description: Pushes output templates to ES and starts Logstash
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_LOGSTASH_INFO_TAG="[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-LOGSTASH-DOCKER-INSTALLATION-ERROR]"

# *********** Environment Variables ***************
DIR=/usr/share/logstash/output_templates

if [[ -z "$ES_HOST" ]]; then
  ES_HOST=helk-elasticsearch
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch server name to $ES_HOST"

if [[ -z "$ES_PORT" ]]; then
  ES_PORT=9200
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch server port to $ES_PORT"

if [[ -n "$ELASTIC_PASSWORD" ]]; then
  if [[ -z "$ELASTIC_USERNAME" ]]; then
      ELASTIC_USERNAME=elastic
  fi
  echo "$HELK_LOGSTASH_INFO_TAG Setting Elasticsearch username to $ELASTIC_USERNAME"
  ELASTICSEARCH_ACCESS=http://$ELASTIC_USERNAME:"${ELASTIC_PASSWORD}"@$ES_HOST:$ES_PORT
else
  ELASTICSEARCH_ACCESS=http://$ES_HOST:$ES_PORT
fi

CLUSTER_SETTINGS='
{
  "persistent": {
    "search.max_open_scroll_context": 15000,
    "indices.breaker.request.limit" : "70%",
    "cluster.max_shards_per_node": 3000
  },
  "transient": {
    "search.max_open_scroll_context": 15000,
    "indices.breaker.request.limit" : "70%",
    "cluster.max_shards_per_node": 3000
  }
}
'
TestHELKDataWindowsSysmon000001='{"type":"wineventlog","user_reporter_type":"User","src_ip_type":"private","user_account":"nt authority\\test helk data","meta_user_name_is_machine":"false","provider_guid":"5770385F-C22A-43E0-BF4C-06F5698FFBD9","host_name":"test-helk-data.local","agent":{"type":"winlogbeat","id":"5ef4b480-a7e2-4bba-b1af-b2a6eba8312d","ephemeral_id":"bfdeead4-32b9-4251-9ba3-b4dcd7d1e786","hostname":"test-helk-data","version":"7.3.1"},"version":5,"process_guid":"A69770E2-4C0C-5D63-0000-0010C0F50000","network_protocol":"tcp","event_id":3,"log_name":"Microsoft-Windows-Sysmon/Operational","src_ip_version":"4","src_host_name":"test-helk-data.local","@event_date_creation":"1990-12-18T16:55:26.674Z","src_ip_public":"false","dst_ip_rfc":"RFC_1918","event":{"kind":"event","action":"Network connection detected (rule: NetworkConnect)","created":"1990-12-18T20:25:48.470Z","code":3},"src_ip_rfc":"RFC_1918","process_id":"976","user_reporter_name":"SYSTEM","dst_host_name":"test-helk-data2.local","dst_ip_version":"4","src_ip_addr":"10.66.6.121","z_original_timestamp":"1990-12-18T20:25:46.516Z","thread_id":1304,"src_port":"58570","src_is_ipv6":"false","user_domain":"nt authority","dst_ip_addr":"10.66.6.21","ecs":{"version":"1.0.1"},"opcode":"Info","dst_port":"5985","process_name":"svchost.exe","record_number":124793,"winlog":{"channel":"Microsoft-Windows-Sysmon/Operational","provider_guid":"{5770385F-C22A-43E0-BF4C-06F5698FFBD9}","opcode":"Info","record_id":124793,"process":{"thread":{"id":1304},"pid":1432},"task":"Network connection detected (rule: NetworkConnect)","host_name":"test-helk-data.local","version":5,"provider_name":"Microsoft-Windows-Sysmon","event_id":3,"api":"wineventlog"},"etl_processed_timestamp":"2015-10-07T19:07:50.302Z","dst_ip_type":"private","dst_is_ipv6":"false","level":"information","action":"networkconnect","@version":"1","process_path":"c:\\windows\\system32\\svchost.exe","user_name":"network service","source_name":"Microsoft-Windows-Sysmon","dst_ip_public":"false","user_reporter_sid":"S-1-5-18","event_original_message":"test helk data","etl_pipeline":["all-filter-0098","fingerprint-winlogbeats7","winlogbeat_7-field_nest_cleanup","winlogbeat_7-copy_to_originals","1500","1521","1522","1523_1","1524_2","1524_6","1531","1541_1","1544_2","1544_3","1544_6","1544_7","1544_8","dst_ip_addr_clean_and_public","src_ip_addr_clean_and_public","winevent-hostname-cleanup","winevent-user_name-is-machine-account","winevent-user_reporter_name-is-machine-account","copy-8802-001","copy-8802-002"],"beat_hostname":"test-helk-data","log":{"level":"information"},"user_reporter_domain":"NT AUTHORITY","meta_user_reporter_name_is_machine":"false","fingerprint_network_community_id":"1:EeVyZ07VGj1n0rld+xCLFdM+u8M=","@timestamp":"1990-12-18T20:25:46.516Z","task":"Network connection detected (rule: NetworkConnect)","network_initiated":"true","beat_version":"7.3.1"}'

KIBANA_INDEX_PRIORITY='{"index.priority":100}'

# ******** Set Trial License Variables ***************
if [[ -n "$ELASTIC_PASSWORD" ]]; then
  # ****** Updating Pipeline configs ***********
  for config in /usr/share/logstash/pipeline/*-output.conf
  do
      echo "$HELK_LOGSTASH_INFO_TAG Updating pipeline config $config..."
      sed -i "s/#password \=>.*$/password \=> \'${ELASTIC_PASSWORD}\'/g" "${config}"
  done
fi

# *********** Check if Elasticsearch is up ***************
while true
  do
    ES_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" $ELASTICSEARCH_ACCESS)
    if [ "$ES_STATUS_CODE" -eq 200 ]; then
      echo "$HELK_LOGSTASH_INFO_TAG Connected successfully to elasticsearch URI.."
      break
    else
      echo "$HELK_LOGSTASH_INFO_TAG Waiting for elasticsearch URI to be accessible.."
    fi
    sleep 5
done

# ********** Uploading templates to Elasticsearch *******
echo "$HELK_LOGSTASH_INFO_TAG Uploading templates for field & value mappings and index settings to elasticsearch .."
for file in "${DIR}"/*.json; do
    template_name=$(echo "$file" | sed -r ' s/^.*\/[0-9]+\-//' | sed -r ' s/\.json$//')
    echo "$HELK_LOGSTASH_INFO_TAG Uploading $template_name template to elasticsearch.."
    until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X POST $ELASTICSEARCH_ACCESS/_template/"$template_name" -d@"${file}" -H 'Content-Type: application/json')" == "200" ]]; do
      echo "$HELK_LOGSTASH_INFO_TAG Retrying uploading $template_name"
      sleep 2
    done
done

# ******** Cluster Settings ***************
echo "$HELK_LOGSTASH_INFO_TAG Configuring elasticsearch cluster settings.."
until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X PUT $ELASTICSEARCH_ACCESS/_cluster/settings -H 'Content-Type: application/json' -d "$CLUSTER_SETTINGS")" == "200" ]]; do
  echo "$HELK_LOGSTASH_INFO_TAG Retrying cluster settings"
  sleep 2
done

# *********** Set Kibana Index Priority ***************
echo "$HELK_LOGSTASH_INFO_TAG Configuring elasticsearch cluster settings.."
until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X PUT "${ELASTICSEARCH_ACCESS}/.kiban*/_settings" -H 'Content-Type: application/json' -d "$KIBANA_INDEX_PRIORITY")" == "200" ]]; do
  echo "$HELK_LOGSTASH_INFO_TAG Retrying Kibana index priority"
  sleep 2
done

# ******** Create Data For Kibana Experience ***************
echo "$HELK_LOGSTASH_INFO_TAG Setting up additional Kibana/UI experience parameter.."
until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X POST $ELASTICSEARCH_ACCESS/logs-endpoint-winevent-sysmon-1990.12.18/_doc/TestHELKDataWindowsSysmon000001 -H 'Content-Type: application/json' -d "$TestHELKDataWindowsSysmon000001")" == "200" ]]; do
  echo "$HELK_LOGSTASH_INFO_TAG Retrying uploading data for kibana experience"
  sleep 2
done

# ********** Install Plugins *****************
echo "$HELK_LOGSTASH_INFO_TAG Checking Logstash plugins.."
# check if has been 30 days since plugins have been updated
if test -f "$plugins_time_file"; then
  plugins_last_time=$(date -d "$(<"$plugins_time_file")" '+%s')
  plugins_current_time=$(date -d "$(<"$plugins_time_file")" '+%s')
  plugins_day_diff=$(( ( plugins_current_time - plugins_last_time )/(60*60*24) ))
  if [ "$plugins_day_diff" -ge 30 ]; then
    plugins_oudated="yes"
    echo "$HELK_LOGSTASH_INFO_TAG Plugins have not been updated in over 30 days.."
  else
    plugins_oudated="no"
  fi
else
  plugins_oudated="yes"
fi
# Test a few plugins determine if probably all already installed
if ( logstash-plugin list  2> /dev/null | grep 'logstash-filter-prune' ) && ( logstash-plugin list  2> /dev/null | grep 'logstash-input-wmi' ); then
  plugins_previous_install="yes"
  echo "$HELK_LOGSTASH_INFO_TAG Plugins from previous install detected.."
else
  plugins_previous_install="no"
  echo "$HELK_LOGSTASH_INFO_TAG Plugins from previous install not detected.."
  echo "$HELK_LOGSTASH_INFO_TAG Updating Logstash plugins over the internet for first run.."
  logstash-plugin update
fi
# If have not been updated in X time or not installed at all.. then install them
if [ $plugins_previous_install = "no" ] || [ $plugins_oudated = "yes" ]; then
	if [ -f "/usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip" ] && [  -f "/usr/share/logstash/plugins/helk-offline-logstash-input_and_output-plugins.zip" ]; then
    echo "$HELK_LOGSTASH_INFO_TAG Installing Logstash plugins via offline package.."
	  logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-codec_and_filter_plugins.zip
	  logstash-plugin install file:///usr/share/logstash/plugins/helk-offline-logstash-input_and_output-plugins.zip
  else
    echo "$HELK_LOGSTASH_INFO_TAG Installing logstash plugins over the internet.."
    logstash-plugin install logstash-codec-avro logstash-codec-es_bulk logstash-codec-cef logstash-codec-gzip_lines logstash-codec-json logstash-codec-json_lines logstash-codec-netflow logstash-codec-nmap logstash-codec-protobuf logstash-filter-alter logstash-filter-bytes logstash-filter-cidr logstash-filter-cipher logstash-filter-clone logstash-filter-csv logstash-filter-de_dot logstash-filter-dissect logstash-filter-dns logstash-filter-elasticsearch logstash-filter-fingerprint logstash-filter-geoip logstash-filter-i18n logstash-filter-jdbc_static logstash-filter-jdbc_streaming logstash-filter-json logstash-filter-json_encode logstash-filter-kv logstash-filter-memcached logstash-filter-metricize logstash-filter-prune logstash-filter-translate logstash-filter-urldecode logstash-filter-useragent logstash-filter-xml logstash-input-beats logstash-input-elasticsearch logstash-input-file logstash-input-jdbc logstash-input-lumberjack logstash-input-snmptrap logstash-input-syslog logstash-input-tcp logstash-input-udp logstash-input-wmi logstash-output-csv logstash-output-elasticsearch logstash-output-email logstash-output-lumberjack logstash-output-nagios logstash-output-stdout logstash-output-syslog logstash-output-tcp logstash-output-udp
    echo "$HELK_LOGSTASH_INFO_TAG Updating Logstash plugins over the internet.."
    logstash-plugin update
  fi
  printf "%s" "$(date +"%Y-%m-%d %T")" > "$plugins_time_file"
else
  echo "$HELK_LOGSTASH_INFO_TAG Logstash plugins already installed and up to date.."
fi

# ********* Setting LS_JAVA_OPTS ***************
if [[ -z "$LS_JAVA_OPTS" ]]; then
  while true; do
    # Check using more accurate MB
    AVAILABLE_MEMORY=$(awk '/MemAvailable/{printf "%.f", $2/1024}' /proc/meminfo)
    if [ "$AVAILABLE_MEMORY" -ge 900 ] && [ "$AVAILABLE_MEMORY" -le 1000 ]; then
      LS_MEMORY="400m"
      LS_MEMORY_HIGH="1000m"
    elif [ "$AVAILABLE_MEMORY" -ge 1001 ] && [ "$AVAILABLE_MEMORY" -le 3000 ]; then
      LS_MEMORY="700m"
      LS_MEMORY_HIGH="1300m"
    elif [ "$AVAILABLE_MEMORY" -gt 3000 ]; then
      # Set high & low, so logstash doesn't use everything unnecessarily, it will usually flux up and down in usage -- and doesn't "severely" despite what everyone seems to believe
      LS_MEMORY="$(( AVAILABLE_MEMORY / 4 ))m"
      LS_MEMORY_HIGH="$(( AVAILABLE_MEMORY / 2 ))m"
      if [ "$AVAILABLE_MEMORY" -gt 31000 ]; then
        LS_MEMORY="8000m"
        LS_MEMORY_HIGH="31000m"
      fi
    else
      echo "$HELK_ERROR_TAG $LS_MEMORY MB is not enough memory for Logstash yet.."
      sleep 1
    fi
    export LS_JAVA_OPTS="${HELK_LOGSTASH_JAVA_OPTS} -Xms${LS_MEMORY} -Xmx${LS_MEMORY_HIGH} "
    break
  done
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting LS_JAVA_OPTS to $LS_JAVA_OPTS"

# ********* Setting Logstash PIPELINE_WORKERS ***************
if [[ -z "$PIPELINE_WORKERS" ]]; then
  # Get total CPUs/cores as reported by OS
  TOTAL_CORES=$(getconf _NPROCESSORS_ONLN 2>/dev/null)
  # try one more way
  [ -z "$TOTAL_CORES" ] && TOTAL_CORES=$(getconf NPROCESSORS_ONLN)
  # Unable to get reported cores
  if [ -z "$TOTAL_CORES" ]; then
    TOTAL_CORES=1
    echo "$HELK_ERROR_TAG unable to get number of CPUs/cores as reported by the OS"
  fi
  # Set workers based on available cores
  if [ "$TOTAL_CORES" -ge 1 ] && [ "$TOTAL_CORES" -le 3 ]; then
    PIPELINE_WORKERS=1
    # Divide by 2
  elif [ "$TOTAL_CORES" -ge 4 ]; then
    PIPELINE_WORKERS="$(( TOTAL_CORES / 2 ))"
  # some unknown number
  else
    echo "$HELK_ERROR_TAG reported CPUs/cores not an integer? not greater or equal to 1.."
    PIPELINE_WORKERS=1
  fi
  export PIPELINE_WORKERS
fi
echo "$HELK_LOGSTASH_INFO_TAG Setting PIPELINE_WORKERS to ${PIPELINE_WORKERS}"

# ********** Starting Logstash *****************
echo "$HELK_LOGSTASH_INFO_TAG Running docker-entrypoint script.."
/usr/local/bin/docker-entrypoint