FROM nvcr.io/nvidia/tensorflow:20.07-tf1-py3

ENV LANG=C.UTF-8

RUN apt-get -y update && apt-get -y upgrade

RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

RUN DEBIAN_FRONTEND=noninteractive apt-get -y \
emacs-nox \
git \
wget \
$(cat packages)

ARG ROOT_BIN=root_v6.22.00.Linux-ubuntu18-x86_64-gcc7.5.tar.gz

COPY packages packages

RUN wget https://root.cern/download/${ROOT_BIN} \
&& tar -xzvf ${ROOT_BIN} \
&& rm -f ${ROOT_BIN} \
&& echo /opt/root/lib >> /etc/ld.so.conf \
&& ldconfig

ENV ROOTSYS /opt/root
ENV PATH $ROOTSYS/bin:$PATH
ENV PYTHONPATH $ROOTSYS/lib:$PYTHONPATH
ENV CLING_STANDARD_PCH none
