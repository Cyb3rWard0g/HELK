# HELK script: HELK Spark Master Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM otrf/helk-spark-base:2.4.5
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Master."

ENV DEBIAN_FRONTEND noninteractive

COPY scripts/spark-master-entrypoint.sh ${SPARK_HOME}/sbin/
COPY spark-defaults.conf ${SPARK_HOME}/conf/

EXPOSE 8080 7077
WORKDIR $SPARK_HOME/sbin
ENTRYPOINT ["./spark-master-entrypoint.sh"]

USER sparkuser