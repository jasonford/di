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
- Startup layout is `codex | broot / preview`
- You can tell Codex what to edit in plain language, for example `edit README.md`, `fix the Docker launcher`, or `change the Neovim config to ...`. Codex should infer the relevant file(s) from repo context and proceed unless the target is genuinely ambiguous.
- Open files with plain `nvim` inside the container
- Running `vim` in the container opens the same vanilla Neovim binary
- `broot` launches in the upper-right pane as a patched source build, with git file status info enabled by default
- The lower-right pane follows broot's current selection and shows a text, directory, or binary preview
- `broot` is launched through `proot`, with the mounted repo as its effective filesystem root, so parent system paths stay out of view

## Notes

- Codex auth persists in `.codex-home/.codex`
- The tmux session name defaults to `codex`; override it with `TMUX_SESSION_NAME=... ./develop`
- The image installs Neovim from the upstream release tarball
- The image builds a patched `broot` from the upstream source tag selected by `BROOT_VERSION=... ./develop`
- The bundled patch tracks `v1.55.0`; if you change `BROOT_VERSION`, you may need to refresh `patches/broot-selection-output.patch`
- Override the `broot` pane width with `BROOT_PANE_WIDTH=... ./develop`
- Override the preview pane height with `BROOT_PREVIEW_PANE_PERCENT=... ./develop`
- Docker cache avoids redoing the expensive build layers when unchanged
