if [ -f /etc/bash.bashrc ]; then
  . /etc/bash.bashrc
fi

if [ -f "$HOME/.bashrc" ] && [ "$HOME/.bashrc" != "${BASH_SOURCE[0]}" ]; then
  . "$HOME/.bashrc"
fi

unset PROMPT_COMMAND
PS1='\w > '
