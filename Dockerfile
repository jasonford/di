FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.113.0
ARG NVIM_VERSION=v0.11.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    fd-find \
    git \
    gcc \
    g++ \
    make \
    python3 \
    ripgrep \
    tar \
    tmux \
    xclip \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
      -o /tmp/nvim-linux-x86_64.tar.gz \
  && rm -rf /opt/nvim \
  && tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz \
  && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
  && rm -f /tmp/nvim-linux-x86_64.tar.gz

RUN npm install -g \
    @openai/codex@${CODEX_VERSION} \
    pyright \
    typescript \
    typescript-language-server \
    vscode-langservers-extracted

COPY nvim /opt/nvim-config/nvim

ENV XDG_CONFIG_HOME=/opt/nvim-config
ENV XDG_DATA_HOME=/opt/nvim-data
ENV XDG_CACHE_HOME=/tmp/nvim-cache
ENV XDG_STATE_HOME=/tmp/nvim-state

RUN mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" \
  && nvim --version \
  && nvim --headless "+Lazy! sync" +qa \
  && nvim --headless "+TSUpdateSync lua vim vimdoc query javascript typescript tsx python json bash markdown markdown_inline" +qa

WORKDIR /workspace
CMD ["codex"]
