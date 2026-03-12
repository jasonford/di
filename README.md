# Codex + Neovim container

## Files

- Dockerfile
- develop
- AGENTS.md
- nvim/init.lua

## First run

```bash
chmod +x develop
./develop login
./develop
```

## Workflow

- Start in a full Codex session with `./develop`
- `./develop` opens a tmux session with Codex in the left pane and a workspace shell in the right pane
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Press `Ctrl+G` inside Codex to open Neovim
- The editor launched from Codex uses `codex-nvim`, which opens files in Neovim with this repo's custom config and Codex-specific commands already loaded.
- Running `vim` in the container also uses `codex-nvim`, so the same custom Neovim config loads by default.
- In Neovim:
  - `:AskVimCmd` or `<leader>ac` asks Codex for a Vim command using the current file as context
  - visually select text, then `<leader>am` asks Codex for a selection-scoped command
  - `<leader>ar` applies the last generated command

## Notes

- Codex auth persists in `.codex-home/.codex`
- The tmux session name defaults to `codex`; override it with `TMUX_SESSION_NAME=... ./develop`
- The image installs Neovim `0.10.x`; this is required by `lazy.nvim`
- Neovim plugins are installed at image-build time
- Docker cache avoids redoing the expensive build layers when unchanged
