FROM rust:1.83-bookworm AS broot-builder

ARG BROOT_VERSION=v1.55.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    libssl-dev \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${BROOT_VERSION}" https://github.com/Canop/broot broot
WORKDIR /src/broot
COPY patches/broot-selection-output.patch /tmp/broot-selection-output.patch
RUN git apply /tmp/broot-selection-output.patch \
  && cargo build --release --locked

FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.113.0
ARG NVIM_VERSION=v0.11.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    dpkg \
    fd-find \
    file \
    git \
    gcc \
    g++ \
    make \
    proot \
    python3 \
    ripgrep \
    tar \
    tmux \
    xclip \
  && rm -rf /var/lib/apt/lists/*

RUN arch="$(dpkg --print-architecture)" \
  && case "$arch" in \
       amd64) nvim_arch="x86_64" ;; \
       arm64) nvim_arch="arm64" ;; \
       *) echo "Unsupported architecture for neovim: $arch" >&2; exit 1 ;; \
     esac \
  && curl -L "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${nvim_arch}.tar.gz" \
      -o /tmp/nvim.tar.gz \
  && rm -rf /opt/nvim-linux-${nvim_arch} \
  && tar -C /opt -xzf /tmp/nvim.tar.gz \
  && ln -sf "/opt/nvim-linux-${nvim_arch}/bin/nvim" /usr/local/bin/nvim \
  && rm -f /tmp/nvim.tar.gz

COPY --from=broot-builder /src/broot/target/release/broot /usr/local/bin/broot

RUN npm install -g \
    @openai/codex@${CODEX_VERSION} \
    pyright \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted

RUN nvim --version \
  && broot --version \
  && ln -sf /usr/local/bin/nvim /usr/local/bin/vim

WORKDIR /workspace
CMD ["codex"]
