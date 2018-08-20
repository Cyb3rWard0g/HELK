# HELK script: HELK Spark Worker Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.3.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Worker."

ENV DEBIAN_FRONTEND noninteractive

USER sparkuser

COPY scripts/spark-worker-entrypoint.sh ${SPARK_HOME}/sbin
COPY spark-defaults.conf ${SPARK_HOME}/conf/

EXPOSE $SPARK_WORKER_WEBUI_PORT

WORKDIR $SPARK_HOME/sbin
ENTRYPOINT ["./spark-worker-entrypoint.sh"]