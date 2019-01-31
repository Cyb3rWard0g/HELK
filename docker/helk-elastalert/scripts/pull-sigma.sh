#!/bin/bash

# HELK script: pull-sigma.sh
# HELK script description: Update local github repo and transform Windows SIGMA rules to Elastalert signatures
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# ******* Change directory to SIGMA local repo ************
cd $ESALERT_SIGMA_HOME

# ******* Check if Elastalert rules folder has SIGMA rules ************
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Checking if Elastalert rules folder has SIGMA rules.."
if ls $ESALERT_HOME/rules/ | grep -v '^helk_' >/dev/null 2>&1; then
    echo "[+++++] SIGMA rules available in rules folder.."
    SIGMA_RULES_AVAILABLE=YES
else
    echo "[+++++] SIGMA rules not available in rules folder.."
fi

# ******* Check if local SIGMA repo needs update *************
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Fetch updates for SIGMA remote.."
git remote update

# Reference: https://stackoverflow.com/a/3278427
echo "[HELK-ELASTALERT-DOCKER-INSTALLATION-INFO] Checking to see if local SIGMA repo is up to date or not.."
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")
BASE=$(git merge-base @ "$UPSTREAM")

if [ $LOCAL = $REMOTE ]; then
    echo "[++++++] Local SIGMA repo is up-to-date.."
    if [[ $SIGMA_RULES_AVAILABLE == "YES" ]]; then
        echo "[++++++] SIGMA rules available in Elastalert rules folder.."
        echo "[++++++] Nothing to do here.."
        exit 1
    fi
elif [ $LOCAL = $BASE ]; then
    echo "[++++++] Local SIGMA repo needs to be updated. Updating local SIGMA repo.."
    git pull
    if [[ $SIGMA_RULES_AVAILABLE == "YES" ]]; then
        echo "[+++++++++] Elastalert rules folder has potentially old SIGMA rules.."
        find $ESALERT_HOME/rules/ -type f -not -name 'helk_*' -delete
    fi
elif [ $REMOTE = $BASE ]; then
    echo "[++++++] Need to push"
    exit 1
else
    echo "[++++++] Diverged"
    exit 1
fi

# ******* Transforming every Windows SIGMA rule to elastalert rules *******
echo " "
echo "Translating SIGMA rules to Elastalert format.."
echo "------------------------------------------------"
echo " "
rule_counter=0
for  rule_category in rules/windows/* ; do
    echo " "
    echo "Working on Folder: $rule_category:"
    echo "-------------------------------------------------------------"
    for rule in $rule_category/* ; do
        echo "[+++] Processing Windows rule: $rule .."
        tools/sigmac -t elastalert -c sigmac-config.yml -o $ESALERT_HOME/rules/sigma_$(basename $rule) $rule
        rule_counter=$[$rule_counter +1]
    done
done
echo "-------------------------------------------------------"
echo "[+++] Finished processing $rule_counter SIGMA rules"
echo "-------------------------------------------------------"
echo " "

# ******* Removing Noise Rules *****************************
echo "Removing Elastalert rules that generate too much noise. Replacing them with HELK rules.."
echo "--------------------------------------------------------------------------------------------"
find $ESALERT_HOME/rules/ -type f -name 'sigma_sysmon_powershell_suspicious_parameter_variation.yml' -delete


# Pathing one issues in SIGMA Integration
# References:
# Unsupported feature 'near' aggregation operator not yet implemented https://github.com/Neo23x0/sigma/issues/209
# ONE SIGMA Rule & TWO log sources: https://github.com/Neo23x0/sigma/issues/205

# ******** Deleting Empty Files ***********
echo " "
echo "Removing empty files.."
echo "-------------------------"
rule_counter=0
for ef in $ESALERT_HOME/rules/* ; do 
    if [[ -s $ef ]]; then
        continue
    else
        echo "[---] Removing empty file $ef.."
        rm $ef
        rule_counter=$[$rule_counter +1]
    fi
done
echo "--------------------------------------------------------------"
echo "[+++] Finished deleting $rule_counter empty Elastalert rules"
echo "--------------------------------------------------------------"
echo " "

rule_counter=0
echo "Fixing Elastalert rule files with multiple SIGMA rules in them.."
echo "------------------------------------------------------------------"
for er in $ESALERT_HOME/rules/*; do 
    echo "[+++] Identifiying extra new lines in file $er .."
    counter=0
    while read line; do 
        if [ "$line" == "" ]; then
            counter=$[$counter +1]
        fi
    done < $er

    if [ "$counter" == "2" ] ; then
        echo "[++++++] Truncating file $er with $counter lines .."
        truncate -s -2 $er
    elif [ "$counter" == "3" ]; then
        echo "[++++++] Truncating file $er with $counter lines .."
        truncate -s -2 $er
        # https://github.com/Neo23x0/sigma/issues/205
        echo "[++++++] Spliting file $er in two files .."
        name=$(basename $er .yml)
        awk -v RS= -v filename="$name" '{print > ("/etc/elastalert/rules/"filename NR ".yml")}' $er
        echo "[------] Removing original file $er .."
        rm $er
        rule_counter=$[$rule_counter +1]
    fi
done
echo "---------------------------------------------------------"
echo "[+++] Finished splitting $rule_counter Elastalert rules"
echo "---------------------------------------------------------"
echo " "