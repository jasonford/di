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
- Startup layout is `codex | broot`
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Open files with plain `nvim` inside the container
- Running `vim` in the container opens the same vanilla Neovim binary
- In `broot`, `Enter` on a file opens `nvim` in a new tmux pane inserted immediately to the right of the `broot` pane
- `broot` is launched through `proot`, so it stays confined to the workspace tree instead of browsing parent system paths
- `broot` loads its checked-in config from `.config/broot` in the workspace on each launch, so a fresh `./develop` run gets the repo's intended setup
- `broot` starts with git metadata enabled, and preview uses full diff output for many common text/code file extensions when the file has git changes

## Notes

- Codex auth persists in `.codex-home/.codex`
- The tmux session name defaults to `codex`; override it with `TMUX_SESSION_NAME=... ./develop`
- The image installs Neovim from the upstream release tarball
- The image installs `broot` from the upstream release archive; override it with `BROOT_VERSION=... ./develop`
- Override the `broot` pane width with `BROOT_PANE_WIDTH=... ./develop`
- Docker cache avoids redoing the expensive build layers when unchanged
