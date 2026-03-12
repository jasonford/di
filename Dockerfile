FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.113.0
ARG NVIM_VERSION=v0.11.5

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
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

RUN nvim --version \
  && ln -sf /usr/local/bin/nvim /usr/local/bin/vim

WORKDIR /workspace
CMD ["codex"]
