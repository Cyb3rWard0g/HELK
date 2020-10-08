#!/bin/bash

# HELK script: pull-sigma.sh
# HELK script description: Update local github repo and transform Windows SIGMA rules to Elastalert signatures
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

RED='\033[0;31m'
CYAN='\033[0;36m'
WAR='\033[1;33m'
STD='\033[0m'
# *********** Helk log tagging variables ***************
# For more efficient script editing/reading, and also if/when we switch to different install script language
HELK_INFO_TAG="${CYAN}[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO]${STD}"
HELK_ERROR_TAG="${RED}[HELK-ELASTALERT-DOCKER-INSTALLATION-ERROR]${STD}"
HELK_WARNING_TAG="${WAR}[HELK-ELASTALERT-DOCKER-INSTALLATION-WARNING]${STD}"

# ******* Read helk-elastalert preferences ************
CONFIG_FILE="${ESALERT_HOME}/pull-sigma-config.yaml"
HELK_ERROR_FILE="/tmp/helk_error"

# Additional Settings
helk_sigmac="${ESALERT_SIGMA_HOME}/sigmac-config.yml"

getYamlKey() {
    python3 -c "import yaml;print(yaml.safe_load(open('$1'))$2)" 2>${HELK_ERROR_FILE}
}

updatesAreEnabled(){
    if test -f "$CONFIG_FILE"; then
        echo "$HELK_ELASTALERT_INFO_TAG Update control file exists, proceeding..."
    else
        echo "$HELK_ELASTALERT_INFO_TAG Update control file missing, proceeding with update by default..."
        return 0
    fi

    local ALLOW_UPDATES=$(getYamlKey "$CONFIG_FILE" "allow_updates")

    if test -f $HELK_ERROR_FILE && grep -q KeyError $HELK_ERROR_FILE; then
        echo "$HELK_ELASTALERT_INFO_TAG Update control setting missing, proceeding..."
        return 0
    fi

    if [ "$ALLOW_UPDATES" = "False" ]; then
        echo "$HELK_ELASTALERT_INFO_TAG Updates disabled."
        return 1
    fi

    # If control reaches here, that means updates are enabled.
    echo "$HELK_ELASTALERT_INFO_TAG Updates enabled."
    test -f "tmp/helk_error" && rm /tmp/helk_error
    return 0
}

# ******* Change directory to SIGMA local repo ************
cd "${ESALERT_SIGMA_HOME}" || exit

# ******* Check if Elastalert rules folder has SIGMA rules ************
echo -e "${HELK_INFO_TAG} Checking if Elastalert rules folder has SIGMA rules.."
if ls "${ESALERT_HOME}/rules/" | grep -v "^helk_" >/dev/null 2>&1; then
    echo -e "${HELK_INFO_TAG} [+++++] SIGMA rules available in rules folder.."
    SIGMA_RULES_AVAILABLE=YES
else
    echo -e "${HELK_INFO_TAG} [+++++] SIGMA rules not available in rules folder.."
fi

function getUpdates() {
    # ******* Check if local SIGMA repo needs update *************
    echo -e "${HELK_INFO_TAG} Fetch updates for SIGMA remote.."
    git remote update

    # Reference: https://stackoverflow.com/a/3278427
    echo -e "${HELK_INFO_TAG} Checking to see if local SIGMA repo is up to date or not.."
    UPSTREAM=${1:-"@{u}"}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [[ ${LOCAL} = ${REMOTE} ]]; then
        echo -e "${HELK_INFO_TAG} [++++++] Local SIGMA repo is up-to-date.."
        if [[ ${SIGMA_RULES_AVAILABLE} == "YES" ]]; then
            echo -e "${HELK_INFO_TAG} [++++++] SIGMA rules available in Elastalert rules folder.."
            echo -e "${HELK_INFO_TAG} [++++++] Nothing to do here.."
            #exit 1
        fi
    elif [[ ${LOCAL} = ${BASE} ]]; then
        echo -e "${HELK_INFO_TAG} [++++++] Local SIGMA repo needs to be updated. Updating local SIGMA repo.."
        git pull
        if [[ ${SIGMA_RULES_AVAILABLE} == "YES" ]]; then
            echo -e "${HELK_INFO_TAG} [+++++++++] Elastalert rules folder has potentially old SIGMA rules.."
            find "${ESALERT_HOME}/rules/" -type f -not -name "helk_*" -delete
            find "${ESALERT_HOME}/rules/" -type f -not -name "custom_*" -delete
        fi
    elif [[ ${REMOTE} = ${BASE} ]]; then
        echo -e "${HELK_INFO_TAG} [++++++] Need to push"
        #exit 1
    else
        echo -e "${HELK_INFO_TAG} [++++++] Diverged"
        #exit 1
    fi
}

if updatesAreEnabled; then
    # There will be additional conditions to be checked here, for example if overwriting of rules (including those added/modified by user) is enabled or not.
    getUpdates "$@"
fi

# *********** Unsupported SIGMA Functions ***************
# Unsupported feature "near" aggregation operator not yet implemented https://github.com/Neo23x0/sigma/issues/209
SIGMAremoveNearRules() {
    if grep --quiet -E "\s+condition/\s+.*\s+|\s+near\s+" "$1"; then
        echo -e "${HELK_INFO_TAG} [---] Skipping incompatible rule $1, reference: https://github.com/Neo23x0/sigma/issues/209"
        #rm "$1"
        return 0
    else
      return 1
    fi
}

# ******* Transforming every Windows SIGMA rule to elastalert rules *******
echo " "
echo "Translating SIGMA rules to Elastalert format.."
echo "------------------------------------------------"
echo " "
rule_counter=0
# Windows rules
for  rule_category in rules/windows/* ; do
    echo " "
    echo -e "${HELK_INFO_TAG} Working on Folder: $rule_category:"
    echo "-------------------------------------------------------------"
    if [[ "$rule_category" == "rules/windows/process_creation" ]]; then
        for rule in "${rule_category}"/* ; do
            if [[ ${rule} != "rules/windows/process_creation/win_mal_adwind.yml" ]]; then
                if SIGMAremoveNearRules "$rule"; then
                    continue
                else
                    echo "[+++] Processing Windows process creation rule: $rule .."
                    tools/sigmac -t elastalert -c tools/config/generic/sysmon.yml -c "${helk_sigmac}" --backend-option timestamp_field=etl_processed_time -o "${ESALERT_HOME}"/rules/sigma_sysmon_"$(basename "${rule}")" "$rule"
                    # Give unique rule name for sysmon
                    sed -i 's/^name: /name: Sysmon_/' "${ESALERT_HOME}"/rules/sigma_sysmon_"$(basename "${rule}")"
                    tools/sigmac -t elastalert -c tools/config/generic/windows-audit.yml -c "${helk_sigmac}" --backend-option timestamp_field=etl_processed_time -o "${ESALERT_HOME}"/rules/sigma_"$(basename "${rule}")" "$rule"
                    rule_counter=$[$rule_counter +1]
                fi
            fi
        done
    else
        for rule in "${rule_category}"/* ; do
            if SIGMAremoveNearRules "$rule"; then
                continue
            else
                echo "[+++] Processing additional Windows rule: $rule .."
                tools/sigmac -t elastalert -c "${helk_sigmac}" --backend-option timestamp_field=etl_processed_time -o "${ESALERT_HOME}"/rules/sigma_"$(basename "${rule}")" "$rule"
                rule_counter=$[$rule_counter +1]
            fi
        done
    fi
done
# Apt rules
echo " "
echo -e "${HELK_INFO_TAG} Working on Folder: apt:"
echo "-------------------------------------------------------------"
for rule in rules/apt/* ; do
  
    if SIGMAremoveNearRules "$rule"; then
        continue
    else
        echo "[+++] Processing apt rule: $rule .."
        tools/sigmac -t elastalert -c tools/config/generic/sysmon.yml -c "${helk_sigmac}" --backend-option timestamp_field=etl_processed_time -o "${ESALERT_HOME}"/rules/sigma_sysmon_apt_"$(basename "${rule}")" "$rule"
        # Give unique rule name for sysmon
        sed -i 's/^name: /name: Sysmon_/' "${ESALERT_HOME}"/rules/sigma_sysmon_apt_"$(basename "${rule}")"
        tools/sigmac -t elastalert -c tools/config/generic/windows-audit.yml -c "${helk_sigmac}" --backend-option timestamp_field=etl_processed_time -o "${ESALERT_HOME}"/rules/sigma_apt_"$(basename "${rule}")" "$rule"
        rule_counter=$[$rule_counter +1]
    fi
done
echo "-------------------------------------------------------"
echo -e "${HELK_INFO_TAG} [+++] Finished processing $rule_counter SIGMA rules"
echo "-------------------------------------------------------"
echo " "

# ******* Removing Rules w/ Too Many False Positives *****************************
echo -e "${HELK_INFO_TAG} Removing Elastalert rules that generate too much noise. Replacing them with HELK rules.."
echo "--------------------------------------------------------------------------------------------"


# Patching one issue in SIGMA Integration
# References:
# ONE SIGMA Rule & TWO log sources: https://github.com/Neo23x0/sigma/issues/205


# ******** Deleting Empty Files ***********
echo " "
echo -e "${HELK_INFO_TAG} Removing empty files.."
echo "-------------------------"
rule_counter=0
for ef in ${ESALERT_HOME}/rules/* ; do
    if [[ -s ${ef} ]]; then
        continue
    else
        echo -e "${HELK_INFO_TAG} [---] Removing empty file $ef.."
        rm ${ef}
        rule_counter=$[$rule_counter +1]
    fi
done
echo "--------------------------------------------------------------"
echo -e "${HELK_INFO_TAG} [+++] Finished deleting $rule_counter empty Elastalert rules"
echo "--------------------------------------------------------------"
echo " "

rule_counter=0
echo -e "${HELK_INFO_TAG}Fixing Elastalert rule files with multiple SIGMA rules in them.."
echo "------------------------------------------------------------------"
for er in ${ESALERT_HOME}/rules/*; do
    echo "[+++] Identifying extra new lines in file $er .."
    counter=0
    while read line; do
        if [[ "$line" == "" ]]; then
            counter=$[$counter +1]
        fi
    done < ${er}

    if [[ "$counter" == "2" ]] ; then
        echo "[++++++] Truncating file $er with $counter lines .."
        truncate -s -2 ${er}
    elif [[ "$counter" == "3" ]]; then
        echo "[++++++] Truncating file $er with $counter lines .."
        truncate -s -2 ${er}
        # https://github.com/Neo23x0/sigma/issues/205
        echo "[++++++] Splitting file $er in two files .."
        name=$(basename ${er} .yml)
        awk -v RS= -v filename="$name" '{print > ("/etc/elastalert/rules/"filename NR ".yml")}' ${er}
        echo "[------] Removing original file $er .."
        rm ${er}
        rule_counter=$[$rule_counter +1]
    fi
done
echo "---------------------------------------------------------"
echo -e "${HELK_INFO_TAG} [+++] Finished splitting $rule_counter Elastalert rules"
echo "---------------------------------------------------------"
echo " "