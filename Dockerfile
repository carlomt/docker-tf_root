# FROM nvcr.io/nvidia/tensorflow:20.07-tf1-py3 as builder
# FROM nvcr.io/nvidia/tensorflow:20.03-tf2-py3 as builder
# FROM tensorflow/tensorflow:2.2.0-gpu as builder
# FROM tensorflow/tensorflow:2.3.0-gpu as builder
ARG BASE_IMAGE=tensorflow/tensorflow:2.4.0-gpu
FROM $BASE_IMAGE AS builder

WORKDIR /workspace

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive

COPY packages .

RUN apt-get update && \
apt-get -yq --no-install-recommends install \
git \
$(cat packages) \
&& apt-get clean \
&& rm -rf /var/cache/apt/archives/* \
&& rm -rf /var/lib/apt/lists/*

RUN git clone --branch v6-22-00-patches https://github.com/root-project/root.git root_src \
&& mkdir root_build root && cd root_build \
&& cmake -Dpython3="ON" -DPYTHON_EXECUTABLE="/usr/local/bin/python" -Dlibcxx="ON" -Dmathmore="ON" -Dminuit2="ON" -Droofit="ON" -Dtmva="ON" -DCMAKE_INSTALL_PREFIX=../root ../root_src \
# && cmake --build . -- install -j `nproc`
&& make -j`nproc` \
&& make install

# ARG ROOT_BIN=root_v6.22.00.Linux-ubuntu18-x86_64-gcc7.5.tar.gz
# RUN wget https://root.cern/download/${ROOT_BIN} \
# && tar -xzvf ${ROOT_BIN} \
# && rm -f ${ROOT_BIN} \
# && echo /workspace/root/lib >> /etc/ld.so.conf \
# && ldconfig

# ENV ROOTSYS /workspace/root
# ENV PATH $ROOTSYS/bin:$PATH
# ENV PYTHONPATH $ROOTSYS/lib:$PYTHONPATH
# ENV CLING_STANDARD_PCH none

#######################################################################

FROM $BASE_IMAGE
# ARG USER_ID
# ARG GROUP_ID

# RUN addgroup --gid $GROUP_ID user
# RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user
# USER user

# WORKDIR /workspace

ENV LANG=C.UTF-8
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

ENV DEBIAN_FRONTEND=noninteractive

COPY packages .

RUN apt-get update && \
apt-get -yq --no-install-recommends install \
git \
emacs-nox \
less \
wget \
python3-pygraphviz \
$(cat packages) \
&& apt-get clean \
&& rm -rf /var/cache/apt/archives/* \
&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /workspace/root /opt/root
COPY entry-point.sh /opt/entry-point.sh
COPY set-aliases.sh /opt/set-aliases.sh
# RUN chmod a+rwx /opt/entry-point.sh

RUN /usr/local/bin/python -m pip install --no-cache --upgrade setuptools pip \
&&  /usr/local/bin/python -m pip install --no-cache \
matplotlib \
ipython \
jupyterlab \
pydot \
sklearn \
onnx \
keras2onnx \
&& source /opt/root/bin/thisroot.sh && /usr/local/bin/python -m pip install --no-cache root_numpy

ENTRYPOINT ["/opt/entry-point.sh"]
CMD ["/bin/bash"]
