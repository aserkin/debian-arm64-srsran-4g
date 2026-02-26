FROM debian:bookworm-slim
WORKDIR /opt/srsran
COPY . .
RUN apt-get update
RUN apt-get install -y build-essential \
cmake \
libfftw3-dev \
libmbedtls-dev \
libboost-program-options-dev \
libconfig++-dev \
libsctp-dev \
libpcsclite-dev \
git \
libusb-dev \
libedit-dev \
libtecla-dev \
help2man \
libpcsclite-dev \
pcscd \
pcsc-tools \
libtool \
libusb-1.0-0-dev \
doxygen \
iproute2 \
vim \
iptables \
sudo \
libcurl4-openssl-dev \
libncurses-dev \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /opt/srsran
RUN git clone https://github.com/zeromq/libzmq.git
WORKDIR /opt/srsran/libzmq
RUN ./autogen.sh
RUN ./configure
RUN make -j`nproc`
RUN make install
RUN ldconfig
WORKDIR /opt/srsran
RUN git clone https://github.com/zeromq/czmq.git
WORKDIR /opt/srsran/czmq
RUN ./autogen.sh
RUN ./configure
RUN make -j`nproc`
RUN make install
RUN ldconfig

WORKDIR /opt/srsran
RUN git clone https://github.com/Nuand/bladeRF.git
WORKDIR /opt/srsran/bladeRF/host
RUN mkdir build
WORKDIR /opt/srsran/bladeRF/host/build
RUN cmake ../ -D BUILD_DOCUMENTATION=ON
RUN make
RUN make install
RUN ldconfig

WORKDIR /opt/srsran
RUN git clone https://github.com/srsRAN/srsRAN_4G.git
WORKDIR /opt/srsran/srsRAN_4G/srsue/src/stack/upper
RUN patch < /opt/srsran/srslte-combined-attach.patch
WORKDIR /opt/srsran/srsRAN_4G
RUN mkdir build
WORKDIR /opt/srsran/srsRAN_4G/build
RUN cmake ../
RUN make -j`nproc`
RUN make install
RUN ldconfig
#RUN ./srsran_install_configs.sh service
WORKDIR /opt/srsran
RUN rm -rf czmq libzmq bladeRF srsRAN_4G
RUN apt-get remove -y build-essential cmake doxygen
WORKDIR /root
