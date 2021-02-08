#!/bin/sh

set -e

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'

# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="${CYAN}[HELK-LOGSTASH-DOCKER-INSTALLATION-INFO]${STD}"
HELK_ERROR_TAG="${RED}[HELK-LOGSTASH-DOCKER-INSTALLATION-ERROR]${STD}"
HELK_WARNING_TAG="${WAR}[HELK-LOGSTASH-DOCKER-INSTALLATION-WARNING]${STD}"

if [[ -n ${ENABLE_ES} ]] && [[ ${ENABLE_ES} = true ]]; then
  echo -e "${HELK_INFO_TAG} Configuring Elasticsearch.."
  # *********** Environment Variables ***************
  DIR=/usr/share/logstash/output_templates

  if [[ -z "$ES_HOST" ]]; then
    ES_HOST=helk-elasticsearch
  fi
  export $ES_HOST
  echo -e "${HELK_INFO_TAG} Setting Elasticsearch server name to $ES_HOST"

  if [[ -z "$ES_PORT" ]]; then
    ES_PORT=9200
  fi
  export $ES_PORT
  echo -e "${HELK_INFO_TAG} Setting Elasticsearch server port to $ES_PORT"

  if [[ -n "$ELASTIC_PASSWORD" ]]; then
    if [[ -z "$ELASTIC_USERNAME" ]]; then
        ELASTIC_USERNAME=elastic
    fi
    echo -e "${HELK_INFO_TAG} Setting Elasticsearch username to $ELASTIC_USERNAME"
    ELASTICSEARCH_ACCESS="http://${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}@${ES_HOST}:${ES_PORT}"
  else
    ELASTICSEARCH_ACCESS="http://${ES_HOST}:${ES_PORT}"
  fi

  CLUSTER_SETTINGS='
{
  "persistent": {
    "search.max_open_scroll_context": 15000,
    "indices.breaker.request.limit" : "90%",
    "cluster.max_shards_per_node": 3000
  },
  "transient": {
    "search.max_open_scroll_context": 15000,
    "indices.breaker.request.limit" : "90%",
    "cluster.max_shards_per_node": 3000
  }
}
'
  TestHELKDataWindowsSysmon000001='{ "user_reporter_name": "SYSTEM", "task": "Network connection detected (rule: NetworkConnect)", "src_ip_addr": "10.66.6.21", "event_original_time": "1990-12-18T16:48:25.255Z", "src_host_name": "dc001.adtest.local", "z_elastic_ecs": { "agent": {}, "ecs": { "version": "1.4.0" }, "host": {}, "log": {}, "user": {}, "winlog": { "process": { "thread": {} } }, "event": { "code": 3, "action": "Network connection detected (rule: NetworkConnect)", "created": "1990-12-18T16:48:25.178Z", "kind": "event", "provider": "Microsoft-Windows-Sysmon" } }, "@version": "1", "level": "information", "dst_host_name": "dc001.adtest.local", "meta_user_reporter_name_is_machine": "false", "provider_guid": "5770385F-C22A-43E0-BF4C-06F5698FFBD9", "process_guid": "E3D58CDF-15D7-5EA3-0000-00100BA90000", "thread_id": 2012, "etl_host_agent_ephemeral_uid": "14800797-e165-4fae-82ec-ba775b9a701d", "meta_user_name_is_machine": "false", "network_initiated": "true", "type": "wineventlog", "process_name": "svchost.exe", "user_account": "nt authority\\system", "dst_ip_public": "false", "src_ip_rfc": "RFC_1918", "etl_kafka_time": 1587746903462, "user_reporter_type": "User", "version": 5, "dst_port_name": "ldap", "dst_ip_rfc": "RFC_1918", "user_reporter_domain": "NT AUTHORITY", "etl_pipeline": [ "all-filter-0098", "all-add_processed_timestamp", "fingerprint-winlogbeats7", "winlogbeat_7_and_above-field_nest_cleanup", "winlogbeat_7_and_above-field_cleanups", "1500", "winevent-ip_conversion-SourceIp_and_DestinationIp", "1522", "winevent-sysmon-all-1531", "sysmon-all-extract_domain_and_user_name", "general_rename-various_global_options", "general_rename-ProcessGuid", "general_rename-ProcessId", "split-process_path-grok-process_name", "provider_guid-cleanup", "process_guid-cleanup", "dst_ip_addr_clean_and_public", "src_ip_addr_clean_and_public", "winevent-hostname-cleanup", "winevent-user_name-is-machine-account", "winevent-user_reporter_name-is-machine-account", "community_id_addition", "final-cleanup-message_field" ], "dst_ip_version": "4", "log_name": "Microsoft-Windows-Sysmon/Operational", "beat_hostname": "dc001", "action": "networkconnect", "fingerprint_network_community_id": "1:OKneuB7CFUFGGAm2Q/+z6KsUL1g=", "src_ip_type": "private", "event_recorded_time": "1990-12-18T16:48:23.462Z", "@timestamp": "1990-12-18T16:48:25.255Z", "etl_version": "2020.04.19.01", "etl_processed_time": "1990-12-18T16:49:50.748Z", "event_id": 3, "beat_version": "7.6.2", "dst_is_ipv6": "false", "dst_ip_type": "private", "etl_kafka_offset": 80540, "process_path": "c:\\windows\\system32\\svchost.exe", "src_ip_public": "false", "process_id": "952", "host_name": "dc001.adtest.local", "etl_kafka_topic": "winlogbeat", "user_reporter_sid": "S-1-5-18", "event_original_message": "Network connection detected:\nRuleName: \nUtcTime: 1990-12-18 16:48:25.255\nProcessGuid: {E3D58CDF-15D7-5EA3-0000-00100BA90000}\nProcessId: 952\nImage: C:\\Windows\\System32\\svchost.exe\nUser: NT AUTHORITY\\SYSTEM\nProtocol: tcp\nInitiated: true\nSourceIsIpv6: false\nSourceIp: 10.66.6.21\nSourceHostname: dc001.adtest.local\nSourcePort: 49257\nSourcePortName: \nDestinationIsIpv6: false\nDestinationIp: 10.66.6.21\nDestinationHostname: dc001.adtest.local\nDestinationPort: 389\nDestinationPortName: ldap", "record_number": 1273339, "dst_port": "389", "user_name": "system", "etl_kafka_partition": 0, "user_domain": "nt authority", "src_port": "49257", "event_timezone": "UTC", "network_protocol": "tcp", "etl_host_agent_type": "winlogbeat", "dst_ip_addr": "10.66.6.21", "opcode": "Info", "src_ip_version": "4", "etl_host_agent_uid": "234807a0-422e-4022-a2c9-dfdfd08bcde5", "src_is_ipv6": "false", "source_name": "Microsoft-Windows-Sysmon" }'

  KIBANA_INDEX_PRIORITY='{"index.priority":100}'

  # *********** Check if Elasticsearch is up ***************
  while true
    do
      ES_STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${ELASTICSEARCH_ACCESS})
      if [[ "$ES_STATUS_CODE" -eq 200 ]]; then
        echo -e "${HELK_INFO_TAG} Connected successfully to elasticsearch URI.."
        break
      else
        echo -e "${HELK_INFO_TAG} Waiting for elasticsearch URI to be accessible.."
      fi
      sleep 5
  done

  # ********** Uploading templates to Elasticsearch *******
  echo -e "${HELK_INFO_TAG} Uploading templates for field & value mappings and index settings to elasticsearch .."
  for file in "${DIR}"/*.json; do
      template_name=$(echo "$file" | sed -r ' s/^.*\/[0-9]+\-//' | sed -r ' s/\.json$//')
      echo -e "${HELK_INFO_TAG} Uploading $template_name template to elasticsearch.."
      until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X POST ${ELASTICSEARCH_ACCESS}/_template/"$template_name" -d@"${file}" -H 'Content-Type: application/json')" == "200" ]]; do
        echo -e "${HELK_WARNING_TAG} Retrying uploading $template_name"
        sleep 2
      done
  done

  # ******** Cluster Settings ***************
  echo -e "${HELK_INFO_TAG} Configuring elasticsearch cluster settings.."
  until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X PUT ${ELASTICSEARCH_ACCESS}/_cluster/settings -H 'Content-Type: application/json' -d "$CLUSTER_SETTINGS")" == "200" ]]; do
    echo -e "${HELK_WARNING_TAG} Retrying cluster settings"
    sleep 2
  done

  # *********** Set Kibana Index Priority ***************
  echo -e "${HELK_INFO_TAG} Configuring elasticsearch cluster settings.."
  until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X PUT "${ELASTICSEARCH_ACCESS}/.kiban*/_settings" -H 'Content-Type: application/json' -d "$KIBANA_INDEX_PRIORITY")" == "200" ]]; do
    echo -e "${HELK_WARNING_TAG} Retrying Kibana index priority"
    sleep 2
  done

  # ******** Create Data For Kibana Experience ***************
  echo -e "${HELK_INFO_TAG} Setting up additional Kibana/UI experience parameter.."
  until [[ "$(curl -s -o /dev/null -w '%{http_code}' -X POST ${ELASTICSEARCH_ACCESS}/logs-endpoint-winevent-sysmon-1990.12.18/_doc/TestHELKDataWindowsSysmon000001 -H 'Content-Type: application/json' -d "$TestHELKDataWindowsSysmon000001")" == "200" ]]; do
    echo -e "${HELK_WARNING_TAG} Retrying uploading data for kibana experience"
    sleep 2
  done
else
  echo -e "${HELK_INFO_TAG} Elasticsearch not set to start.."
fi

exit 0