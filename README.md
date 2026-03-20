# Codex + tmux container

## Files

- Dockerfile
- run
- AGENTS.md

## First run

```bash
chmod +x run
./run login
./run
```

## Workflow

- Start in a full Codex session with `./run`
- Startup layout is `broot | terminal | codex`, with broot and Codex fixed at 56 columns and the middle tmux shell taking the remaining width
- Codex starts in inline mode by default (`--no-alt-screen`) so tmux pane scrollback and redraw are more reliable
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Open files with plain `nvim` inside the container
- Running `vim` in the container opens the same vanilla Neovim binary
- The shared Neovim config lives at `config/nvim/init.lua` and is loaded by plain `nvim` in that middle terminal pane
- The first Neovim launch in a fresh data directory bootstraps the pinned plugins automatically with `lazy.nvim`
- `broot` launches in the upper-left pane as a patched source build, starts in watch mode, and has git file status info enabled by default
- The bundled `broot` patches make watch mode refresh recursively from the current root, keep broot's repo summary on the root row, and show inline `+/-` counts in a fixed gutter on changed files
- Selecting a directory in broot syncs the middle tmux shell into that directory with a visible relative `cd` command; selecting a file syncs to its parent directory and prefills a visible relative `nvim ./path` command without running it yet
- Press `Enter` or double-click a text file in broot to submit that pending `nvim ./path` command in the middle pane; if that pane is already inside Neovim, broot falls back to `:drop` with the selected relative path
- File selection still writes to the shared selection-output file, and broot still receives the shared editor-state file for the existing gutter integration
- `broot` is launched directly with `--confine-root`, so browsing stays pinned to the mounted repo without `proot`

## Notes

- Codex auth persists in `.codex-home/.codex`
- The launcher mounts the repo at `/<repo-name>` by default; override it with `WORKDIR=...`
- The tmux session name defaults to `dint-<repo-name>`; override it with `TMUX_SESSION_NAME=... ./run`
- Set `CODEX_NO_ALT_SCREEN=0 ./run` to restore alternate-screen mode
- The image installs Neovim from the upstream release tarball
- The image pins `@openai/codex` to `0.114.0`
- The image builds a patched `broot` from the upstream source tag selected by `BROOT_VERSION=... ./run`
- The bundled broot patches track `v1.55.0`; if you change `BROOT_VERSION`, you may need to refresh the files in `patches/`
- This improves tmux scrolling and redraw behavior, but does not fully eliminate upstream live-resize quirks in Codex itself
- Docker cache avoids redoing the expensive build layers when unchanged
