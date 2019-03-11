#!/bin/bash

# HELK script: jupyter-cmd.sh
# HELK script description: Runs Jupyter type and specific parameters
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

HELK_INFO_TAG="[HELK-JUPYTER-DOCKER-INSTALLATION-INFO]"
HELK_ERROR_TAG="[HELK-JUPYTER-DOCKER-INSTALLATION-ERROR]"
JUPYTER_NOTEBOOKS=/opt/helk/jupyter/notebooks
# ***** Defining Jupyter params array **********
params=()

# ***** Setting defaults and param variables ***********
# ***** If a config is passed, it should be enough ***********
if [[ "$JUPYTER_CONFIG" ]]; then
# ***** The config file to load ********
    params+=("--config=$JUPYTER_CONFIG")
else
    # ***** The IP address the notebook server will listen on*******
    if [[ -z "$JUPYTER_IP" ]]; then
        JUPYTER_IP=0.0.0.0
    fi
    params+=("--ip=$JUPYTER_IP")

    # ***** The port the notebook server will listen on *******
    if [[ -z "$JUPYTER_PORT" ]]; then
        JUPYTER_PORT=8888
    fi
    params+=("--port=$JUPYTER_PORT")

    # ***** The directory to use for notebooks and kernels *******
    params+=("--notebook-dir=$JUPYTER_NOTEBOOKS")

    # ***** Default to no browser ***********
    # Don't open the notebook in a browser after startup.
    params+=("--no-browser")
fi
# ***** Running Jupyter Type & Parameters ***********
echo "$HELK_INFO_TAG Running Jupyter Type: $JUPYTER_TYPE.."

if [[ "$JUPYTER_TYPE" == "notebook" ]]; then
    # ***** Base URL*******
    if [[ -z "$JUPYTER_BASE_URL" ]]; then
        JUPYTER_BASE_URL="/"
    fi
    params+=("--NotebookApp.base_url=$JUPYTER_BASE_URL")
    echo "$HELK_INFO_TAG Running the following parameters ${params[@]}"

    jupyter notebook ${params[@]}
elif [[ "$JUPYTER_TYPE" == "lab" ]]; then
    # ***** Base URL*******
    if [[ -z "$JUPYTER_BASE_URL" ]]; then
        JUPYTER_BASE_URL="/"
    fi
    params+=("--LabApp.base_url=$JUPYTER_BASE_URL")
    echo "$HELK_INFO_TAG Running the following parameters ${params[@]}"

    jupyter lab ${params[@]}
else
    echo "$HELK_ERROR_TAG You did not enter a valid Jupyter type:  $JUPYTER_TYPE.."
    exit 1
fi

echo "$HELK_INFO_TAG Starting Jupyter $JUPYTER_TYPE.."
