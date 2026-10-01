# Base44 dev toolchain image for Mk48.io (Rust WASM client + native game server).
#
# Only toolchain and tools are baked in here; the repo source is bind-mounted at
# /app and compiled at container startup (see docker-compose.base44.yml).
FROM rust:1.82-slim-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Pinned nightly required by the server/client feature gates (see makefiles/game.mk "rustup").
RUN rustup toolchain install nightly-2024-04-20 --profile minimal \
    && rustup target add wasm32-unknown-unknown --toolchain nightly-2024-04-20

# Trunk (WASM client bundler), prebuilt upstream release.
RUN curl -fsSL https://github.com/trunk-rs/trunk/releases/download/v0.21.7/trunk-x86_64-unknown-linux-musl.tar.gz \
        -o /tmp/trunk.tgz \
    && tar xzf /tmp/trunk.tgz -C /usr/local/bin \
    && rm /tmp/trunk.tgz \
    && trunk --version

ENV RUSTUP_TOOLCHAIN=nightly-2024-04-20
