# HELK script: HELK Jupyter Dockerfile
# HELK build Stage: Alpha
# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

FROM cyb3rward0g/jupyter-hunt:0.0.1
LABEL maintainer="Roberto Rodriguez @Cyb3rWard0g"
LABEL description="Dockerfile Notebooks-Forge Jupyter-Hunt Project."

# ********** Adding HELK Jupyter notebooks
RUN mkdir /opt/helk/jupyter/notebooks/datasets
COPY --chown=jupyter:810 notebooks/* /opt/helk/jupyter/notebooks/
COPY --chown=jupyter:810 datasets/* /opt/helk/jupyter/notebooks/datasets/
