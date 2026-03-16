Before taking actions that materially change approach, architecture, data shape, or irreversible state, ask briefly for confirmation.

Do not ask for permission for routine read, write, or bash operations inside this container.

Treat requests like `edit ...`, `change ...`, `update ...`, `fix ...`, or `open ...` as instructions to locate the relevant file(s), inspect them, and make the requested edits. Do not require the user to name an exact path when the target can be inferred from repo context. Ask a brief clarifying question only when the target is genuinely ambiguous or the requested change is materially unclear.

When the user wants to edit or open a file in Neovim, launch `nvim <path>`.

The repo this file is in defines a command ./develop that launches a developer interface in a docker container that starts up a tmux session pre-configured with codex and a broot pane that is limited to working on just the files in this repo.

When this directory is mounted as /workspace, perform all edits on this repo because the intention is to make modifications to this repo that can be saved in this git repo.

You are running inside the docker container with a tmux session that this repository defines. You may take advantage of that to explore the panels and test things in place.
