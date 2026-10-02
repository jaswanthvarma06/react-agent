FROM rust:latest AS builder

# Install C dependencies for OpenSSL / Rust compilation
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN cargo build --release

FROM debian:bookworm-slim

# Install SSL certificates and runtime libraries
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# COPY updated: point to nasiko-react-agent
COPY --from=builder /app/target/release/nasiko-react-agent /app/react-agent

EXPOSE 8080
CMD ["/app/react-agent"]