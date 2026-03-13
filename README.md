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
- `broot` launches in the right pane as plain upstream `broot`
- `broot` is launched through `proot`, with the mounted repo as its effective filesystem root, so parent system paths stay out of view

## Notes

- Codex auth persists in `.codex-home/.codex`
- The tmux session name defaults to `codex`; override it with `TMUX_SESSION_NAME=... ./develop`
- The image installs Neovim from the upstream release tarball
- The image installs `broot` from the upstream release archive; override it with `BROOT_VERSION=... ./develop`
- Override the `broot` pane width with `BROOT_PANE_WIDTH=... ./develop`
- Docker cache avoids redoing the expensive build layers when unchanged
