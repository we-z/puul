ARG UBUNTU_VERSION=22.04
# This needs to generally match the container host's environment.
ARG MUSA_VERSION=rc3.1.0
# Target the MUSA build image
ARG BASE_MUSA_DEV_CONTAINER=mthreads/musa:${MUSA_VERSION}-devel-ubuntu${UBUNTU_VERSION}
# Target the MUSA runtime image
ARG BASE_MUSA_RUN_CONTAINER=mthreads/musa:${MUSA_VERSION}-runtime-ubuntu${UBUNTU_VERSION}

FROM ${BASE_MUSA_DEV_CONTAINER} AS build

# MUSA architecture to build for (defaults to all supported archs)
ARG MUSA_DOCKER_ARCH=default

RUN apt-get update && \
    apt-get install -y build-essential git cmake

WORKDIR /app

COPY . .

# Use the default MUSA archs if not specified
RUN if [ "${MUSA_DOCKER_ARCH}" != "default" ]; then \
        export CMAKE_ARGS="-DMUSA_ARCHITECTURES=${MUSA_DOCKER_ARCH}"; \
    fi && \
    cmake -B build -DGGML_NATIVE=OFF -DGGML_MUSA=ON ${CMAKE_ARGS} -DCMAKE_EXE_LINKER_FLAGS=-Wl,--allow-shlib-undefined . && \
    cmake --build build --config Release --target llama-cli -j$(nproc) && \
    mkdir -p /app/lib && \
    find build -name "*.so" -exec cp {} /app/lib \;

FROM ${BASE_MUSA_RUN_CONTAINER} AS runtime

RUN apt-get update && \
    apt-get install -y libgomp1

COPY --from=build /app/lib/ /
COPY --from=build /app/build/bin/llama-cli /llama-cli

ENTRYPOINT [ "/llama-cli" ]
