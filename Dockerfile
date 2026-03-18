# syntax=docker/dockerfile:1.7

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
RUN --mount=type=cache,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,target=/usr/local/cargo/git,sharing=locked \
    cargo fetch --locked
COPY patches/ /tmp/patches/
RUN --mount=type=cache,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,target=/src/broot/target,sharing=locked \
    git apply /tmp/patches/broot-selection-output.patch \
  && git apply /tmp/patches/broot-git-watch-and-inline-stats.patch \
  && git apply /tmp/patches/broot-confine-root.patch \
  && git apply /tmp/patches/broot-editor-pane-integration.patch \
  && git apply /tmp/patches/broot-context-gutter.patch \
  && git apply /tmp/patches/broot-git-context-gutter-layout.patch \
  && cargo build --release --locked \
  && install -D /src/broot/target/release/broot /tmp/broot-bin/broot

FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.114.0
ARG NVIM_VERSION=v0.11.5
ARG GIT_DELTA_VERSION=0.18.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bat \
    ca-certificates \
    curl \
    dpkg \
    fd-find \
    file \
    git \
    gcc \
    g++ \
    make \
    python3 \
    ripgrep \
    tar \
    tmux \
    wget \
    xclip \
  && rm -rf /var/lib/apt/lists/*

RUN arch="$(dpkg --print-architecture)" \
  && case "$arch" in \
       amd64|arm64) delta_arch="$arch" ;; \
       *) echo "Unsupported architecture for git-delta: $arch" >&2; exit 1 ;; \
     esac \
  && wget -nv "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${delta_arch}.deb" \
      -O /tmp/git-delta.deb \
  && dpkg -i /tmp/git-delta.deb \
  && rm -f /tmp/git-delta.deb

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

COPY --from=broot-builder /tmp/broot-bin/broot /usr/local/bin/broot

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
