# HELK script: HELK Spark Master Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/helk-spark-base:2.3.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Master."

ENV DEBIAN_FRONTEND noninteractive

USER sparkuser

ADD scripts/spark-master-entrypoint.sh ${SPARK_HOME}/

ENV SPARK_MASTER_HOST helk-spark-master
ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080

EXPOSE 8080 7077
WORKDIR $SPARK_HOME
ENTRYPOINT ["./spark-master-entrypoint.sh"]