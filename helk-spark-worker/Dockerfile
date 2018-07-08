# HELK script: HELK Spark Worker Dockerfile
# HELK build version: 0.9 (Alpha)
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: BSD 3-Clause

FROM cyb3rward0g/helk-spark-base:2.3.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile base for HELK Spark Worker."

ENV DEBIAN_FRONTEND noninteractive

USER sparkuser

ADD scripts/spark-worker-entrypoint.sh ${SPARK_HOME}/

ENV SPARK_MASTER "spark://helk-spark-master:7077"

EXPOSE $SPARK_WORKER_WEBUI_PORT
WORKDIR $SPARK_HOME
ENTRYPOINT ["./spark-worker-entrypoint.sh"]