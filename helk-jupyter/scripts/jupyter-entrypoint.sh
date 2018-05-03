#!/bin/sh

# HELK script: jupyter-entryppoint.sh
# HELK script description: Restart HELK Jupyter Services
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

ln -sf /dev/stdout $JUPYTER_CONSOLE_LOG

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting jupyter services.."
exec $JUPYTER_EXEC >> $JUPYTER_CONSOLE_LOG 2>&1
