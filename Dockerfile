FROM baiduxlab/sgx-rust:1804-1.1.0

WORKDIR /root

ENV USER=root
ENV PATH="${PATH}:/root/.cargo/bin/"
ENV LLVM_CONFIG_PATH="/usr/bin/llvm-config-3.9"
ENV LD_LIBRARY_PATH="/opt/sgxsdk/sdk_libs"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/intel/libsgx-enclave-common/aesm"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl llvm-3.9-dev libclang-3.9-dev clang-3.9 jq \
    && rm -rf /var/lib/apt/lists/*

RUN rustup component add rustfmt && \
    cargo install bindgen cargo-audit clippy cargo-sort-ck cargo-tree cargo-vendor cargo-audit && \
    rm -rf /root/.cargo/registry && \
    rm -rf /root/.cargo/git && \
    rm -rf /root/sgx

RUN git clone --depth 1 -b v1.1.0 https://github.com/baidu/rust-sgx-sdk.git /root/sgx

RUN echo 'LD_LIBRARY_PATH=/opt/intel/libsgx-enclave-common/aesm /opt/intel/libsgx-enclave-common/aesm/aesm_service &' >> /root/.bashrc
