# HELK script: HELK Spark Worker Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-spark-base:2.4.4
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Worker."

ENV DEBIAN_FRONTEND noninteractive

COPY scripts/spark-worker-entrypoint.sh ${SPARK_HOME}/sbin
COPY spark-defaults.conf ${SPARK_HOME}/conf/

WORKDIR $SPARK_HOME/sbin
ENTRYPOINT ["./spark-worker-entrypoint.sh"]

USER sparkuser