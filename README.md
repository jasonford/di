# Codex + tmux container

## Files

- Dockerfile
- develop
- AGENTS.md

## First run

```bash
chmod +x develop
./develop login
./develop
```

## Workflow

- Start in a full Codex session with `./develop`
- Startup layout is `broot | codex`, sized as `2/3 | 1/3`
- Codex starts in inline mode by default (`--no-alt-screen`) so tmux pane scrollback and redraw are more reliable
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Open files with plain `nvim` inside the container
- Running `vim` in the container opens the same vanilla Neovim binary
- The shared Neovim config lives at `config/nvim/init.lua` and is loaded by both plain `nvim` and the managed editor pane
- The tmux launcher prewarms the managed Neovim plugins headlessly for each session so the first visible editor open does not show lazy.nvim's install UI
- `broot` launches in the upper-left pane as a patched source build, starts in watch mode, and has git file status info enabled by default
- The bundled `broot` patches make watch mode refresh recursively from the current root, keep broot's repo summary on the root row, and show inline `+/-` counts in a fixed gutter on changed files
- Press `Enter` or double-click a text file in broot to open it in a managed Neovim pane in the middle; the layout switches to `broot | nvim | codex`
- Unsaved Neovim buffers replace the last broot tree connector cell with the same yellow used for other modified-state indicators
- The Neovim pane is reused for later selections, only shows one visible buffer at a time, and disappears automatically when the last file buffer is closed
- `broot` is launched directly with `--confine-root`, so browsing stays pinned to the mounted repo without `proot`

## Notes

- Codex auth persists in `.codex-home/.codex`
- The launcher mounts the repo at `/<repo-name>` by default; override it with `WORKDIR=...`
- The tmux session name defaults to `dint-<repo-name>`; override it with `TMUX_SESSION_NAME=... ./develop`
- Set `CODEX_NO_ALT_SCREEN=0 ./develop` to restore alternate-screen mode
- The image installs Neovim from the upstream release tarball
- The image pins `@openai/codex` to `0.114.0`
- The image builds a patched `broot` from the upstream source tag selected by `BROOT_VERSION=... ./develop`
- The bundled broot patches track `v1.55.0`; if you change `BROOT_VERSION`, you may need to refresh the files in `patches/`
- This improves tmux scrolling and redraw behavior, but does not fully eliminate upstream live-resize quirks in Codex itself
- Docker cache avoids redoing the expensive build layers when unchanged
