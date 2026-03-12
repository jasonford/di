Before taking actions that materially change approach, architecture, data shape, or irreversible state, ask briefly for confirmation.

Do not ask for permission for routine read, write, or bash operations inside this container.

Treat requests like `edit ...`, `change ...`, `update ...`, `fix ...`, or `open ...` as instructions to locate the relevant file(s), inspect them, and make the requested edits. Do not require the user to name an exact path when the target can be inferred from repo context. Ask a brief clarifying question only when the target is genuinely ambiguous or the requested change is materially unclear.

When the user wants to edit or open a file in Neovim, launch `codex-nvim <path>` so the file opens with this repo's Neovim configuration and the custom Codex commands from `nvim/init.lua` are available in that session.
