FROM baiduxlab/sgx-rust:1804-1.0.9

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends clang \
    && rm -rf /var/lib/apt/lists/*

RUN /root/.cargo/bin/rustup component add rustfmt && \
    /root/.cargo/bin/cargo install bindgen cargo-audit clippy && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git && \
    rm -rf /root/sgx

RUN git clone --depth 1 -b v1.0.9 https://github.com/baidu/rust-sgx-sdk.git /root/sgx

RUN echo 'LD_LIBRARY_PATH=/opt/intel/libsgx-enclave-common/aesm /opt/intel/libsgx-enclave-common/aesm/aesm_service &' >> /root/.bashrc

EXPOSE 5222 8000