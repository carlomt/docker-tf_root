# FROM nvcr.io/nvidia/tensorflow:20.07-tf1-py3 as builder
FROM nvcr.io/nvidia/tensorflow as builder

ENV LANG=C.UTF-8
RUN apt-get -y update && apt-get -y upgrade
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY packages .

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
emacs-nox \
git \
wget \
$(cat packages)

RUN git clone --branch v6-22-00-patches https://github.com/root-project/root.git root_src \
&& mkdir root_build root && cd root_build \
&& cmake -Dpython3="ON" -DPYTHON_EXECUTABLE="/usr/bin/python" -Dlibcxx="ON" -Dmathmore="ON" -Dminuit2="ON" -Droofit="ON" -Dtmva="ON" -DCMAKE_INSTALL_PREFIX=../root ../root_src \
&& cmake --build . -- install -j `nproc` 

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

FROM nvcr.io/nvidia/tensorflow

ENV LANG=C.UTF-8
RUN apt-get -y update && apt-get -y upgrade
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY packages .

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
emacs-nox \
git \
wget \
$(cat packages)

RUN /usr/bin/python -m pip install --upgrade pip
RUN /usr/bin/python -m pip install root_numpy

COPY --from=builder /workspace/root /workspace/root
COPY entry-point.sh /entry-point.sh

ENTRYPOINT ["/entry-point.sh"]
CMD ["/bin/bash"]