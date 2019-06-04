FROM baiduxlab/sgx-rust:1804-1.0.8 AS baseImage

WORKDIR /root

RUN rm -rf /root/sgx

# =========================
FROM baseImage AS depsImage

# dependency for https://github.com/erickt/rust-zmq
RUN apt-get update && \
    apt-get install -y --no-install-recommends libzmq3-dev clang \
    && rm -rf /var/lib/apt/lists/*

RUN /root/.cargo/bin/rustup target add wasm32-unknown-unknown && \
    /root/.cargo/bin/rustup component add rustfmt && \
    /root/.cargo/bin/cargo install bindgen cargo-audit && \
    rm -rf /root/.cargo/registry && rm -rf /root/.cargo/git

# clone the rust-sgx-sdk baidu sdk v1.0.7
RUN git clone --depth 1 -b v1.0.8 https://github.com/baidu/rust-sgx-sdk.git  sgx

RUN git clone --depth 1 --branch v5.18.3 https://github.com/facebook/rocksdb.git rocksdb && \
    cd rocksdb && make install-shared -j7 && rm -rf /root/rocksdb

# +=========================
FROM depsImage as finalImage

# this is done for a run-time linker, it creates the link and cache to the installed rocksdb
# (see http://man7.org/linux/man-pages/man8/ldconfig.8.html)
RUN ldconfig

RUN echo 'LD_LIBRARY_PATH=/opt/intel/libsgx-enclave-common/aesm /opt/intel/libsgx-enclave-common/aesm/aesm_service &' >> /root/.bashrc

# Add env variable for dynamic linking of rocksdb
# (see https://github.com/rust-rocksdb/rust-rocksdb/issues/217)
RUN echo 'export ROCKSDB_LIB_DIR=/usr/local/lib' >> /root/.bashrc

EXPOSE 5222