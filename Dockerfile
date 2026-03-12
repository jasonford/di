FROM node:22-bookworm-slim

ARG CODEX_VERSION=0.113.0
ARG NVIM_VERSION=v0.11.5
ARG BROOT_VERSION=v1.55.0

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

RUN arch="$(dpkg --print-architecture)" \
  && case "$arch" in \
       amd64) broot_target="x86_64-unknown-linux-gnu-glibc2.28" ;; \
       arm64) broot_target="aarch64-unknown-linux-gnu" ;; \
       *) echo "Unsupported architecture for broot: $arch" >&2; exit 1 ;; \
     esac \
  && curl -L "https://github.com/Canop/broot/releases/download/${BROOT_VERSION}/broot_${BROOT_VERSION#v}.zip" \
      -o /tmp/broot.zip \
  && BROOT_TARGET="$broot_target" python3 - <<'PY'
import os
import stat
import zipfile

target = os.environ["BROOT_TARGET"]

with zipfile.ZipFile("/tmp/broot.zip") as zf:
    member = f"{target}/broot"
    with zf.open(member) as src, open("/usr/local/bin/broot", "wb") as dst:
        dst.write(src.read())

st = os.stat("/usr/local/bin/broot")
os.chmod(
    "/usr/local/bin/broot",
    st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH
)
PY

RUN rm -f /tmp/broot.zip

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
