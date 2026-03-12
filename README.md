# Codex + Neovim container

## Files

- Dockerfile
- run.sh
- AGENTS.md
- nvim/init.lua

## First run

```bash
chmod +x run.sh
./run.sh login
./run.sh
```

## Workflow

- Start in a full Codex session with `./run.sh`
- Press `Ctrl+G` inside Codex to open Neovim
- In Neovim:
  - `:AskVimCmd` or `<leader>ac` asks Codex for a Vim command using the current file as context
  - visually select text, then `<leader>am` asks Codex for a selection-scoped command
  - `<leader>ar` applies the last generated command

## Notes

- Codex auth persists in `.codex-home/.codex`
- Neovim plugins are installed at image-build time
- Docker cache avoids redoing the expensive build layers when unchanged
