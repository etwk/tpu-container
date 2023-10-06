# references
#   - https://cloud.google.com/tpu/docs/run-in-container#tpu-device
#   - https://cloud.google.com/tpu/docs/supported-tpu-configurations

FROM jupyter/scipy-notebook:python-3.10

USER ${NB_UID}
RUN pip install https://storage.googleapis.com/cloud-tpu-tpuvm-artifacts/tensorflow/tf-2.14.0/tensorflow-2.14.0-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

USER root
RUN wget -O /lib/libtpu.so https://storage.googleapis.com/cloud-tpu-tpuvm-artifacts/libtpu/1.8.0/libtpu.so
RUN chmod 755 /lib/libtpu.so
WORKDIR /usr/local
RUN git clone https://github.com/tensorflow/models.git

USER ${NB_UID}
RUN pip install -r models/official/requirements.txt
ENV PYTHONPATH=/usr/local/models

USER ${NB_UID}
WORKDIR "${HOME}"