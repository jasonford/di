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
- Startup layout is `codex | broot / preview`, sized as `1/3 | 2/3`
- Codex starts in inline mode by default (`--no-alt-screen`) so tmux pane scrollback and redraw are more reliable
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Open files with plain `nvim` inside the container
- Running `vim` in the container opens the same vanilla Neovim binary
- The shared Neovim config lives at `config/nvim/init.lua` and is loaded by both plain `nvim` and the managed editor pane
- The tmux launcher prewarms the managed Neovim plugins headlessly for each session so the first visible editor open does not show lazy.nvim's install UI
- `broot` launches in the upper-right pane as a patched source build, starts in watch mode, and has git file status info enabled by default
- The bundled `broot` patches make watch mode refresh recursively from the current root, keep broot's repo summary on the root row, and show git status plus `+/-` counts in a fixed gutter on changed files
- The lower-right pane follows broot's current selection and shows unified git diffs for changed tracked text files, highlighted text previews for normal files, a real minimal Bash shell for directories, and safe fallbacks for binaries and large files
- Press `Enter` or double-click a text file in broot to open it in a managed Neovim pane on the far right; the layout switches to `1/3 | 1/3 | 1/3`
- Open Neovim buffers tint the final horizontal broot tree segment green, and unsaved buffers replace the last connector cell with `•`
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
- Override the preview pane height with `BROOT_PREVIEW_PANE_PERCENT=... ./develop`
- Override the initial preview diff mode with `BROOT_PREVIEW_DIFF_MODE=auto|unstaged|staged ./develop`
- Switch preview diff mode live with `tmux set -t dint-<repo-name> @broot_preview_diff_mode staged`, `unstaged`, or `auto`
- `staged` and `unstaged` act as preferences; if the selected tracked file only has changes in the other scope, the preview still renders that diff instead of falling back to a plain text preview
- This improves tmux scrolling and redraw behavior, but does not fully eliminate upstream live-resize quirks in Codex itself
- Docker cache avoids redoing the expensive build layers when unchanged
