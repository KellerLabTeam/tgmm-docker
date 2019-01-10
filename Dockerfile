FROM nvidia/cuda:9.2-devel as builder
# Note: git is installed below just to query version information. It is not 
#       used to clone/download the source to the image.  That's left up to the
#       COPY command.
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common && \
    apt-get -y --no-install-recommends install wget git
RUN mkdir /opt/cmake && cd /opt/cmake && \
    wget -nv https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.sh && \
    sh cmake-3.12.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    rm cmake-3.12.4-Linux-x86_64.sh && \
    cmake --version
COPY tgmm-paper/ tgmm-paper/
RUN cd tgmm-paper && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=`pwd`/../install .. && \
    cmake --build . --config Release --target install

FROM nvidia/cuda:9.2-runtime
WORKDIR /opt/tgmm/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgomp.so.1 /usr/lib/x86_64-linux-gnu/libgomp.so.1
COPY --from=builder /tgmm-paper/install/ .
