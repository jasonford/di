FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.113.0
ARG NVIM_VERSION=v0.11.5
ARG YAZI_VERSION=25.5.31

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
    unzip \
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

RUN curl -L "https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip" \
      -o /tmp/yazi.zip \
  && rm -rf /tmp/yazi-install \
  && mkdir -p /tmp/yazi-install \
  && unzip /tmp/yazi.zip -d /tmp/yazi-install \
  && install -m 0755 /tmp/yazi-install/yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/yazi \
  && install -m 0755 /tmp/yazi-install/yazi-x86_64-unknown-linux-musl/ya /usr/local/bin/ya \
  && rm -rf /tmp/yazi.zip /tmp/yazi-install

COPY nvim /opt/nvim-config/nvim
COPY yazi /opt/nvim-config/yazi
COPY yazi-icons /opt/nvim-config/yazi-icons
COPY codex-nvim /usr/local/bin/codex-nvim
COPY yazi-edit /usr/local/bin/yazi-edit

RUN chmod +x /usr/local/bin/codex-nvim \
  && chmod +x /usr/local/bin/yazi-edit \
  && ln -sf /usr/local/bin/codex-nvim /usr/local/bin/vim

ENV XDG_CONFIG_HOME=/opt/nvim-config
ENV XDG_DATA_HOME=/opt/nvim-data
ENV XDG_CACHE_HOME=/tmp/nvim-cache
ENV XDG_STATE_HOME=/tmp/nvim-state

RUN mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" \
  && nvim --version \
  && yazi --version \
  && nvim --headless "+Lazy! sync" +qa \
  && nvim --headless "+TSUpdateSync lua vim vimdoc query javascript typescript tsx python json bash markdown markdown_inline" +qa

WORKDIR /workspace
CMD ["codex"]
