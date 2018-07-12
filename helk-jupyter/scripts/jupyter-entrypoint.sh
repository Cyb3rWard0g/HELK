#!/bin/sh

# HELK script: jupyter-entryppoint.sh
# HELK script description: Restart HELK Jupyter Services
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

ln -sf /dev/stdout $JUPYTER_CONSOLE_LOG

echo "[HELK-DOCKER-INSTALLATION-INFO] Starting jupyter services.."
exec $JUPYTER_EXEC >> $JUPYTER_CONSOLE_LOG 2>&1
