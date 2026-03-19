#!/usr/bin/env bash

set -u

last=""

while true; do
  current="$(
    {
      echo "TERM=${TERM-}"
      echo "COLORTERM=${COLORTERM-}"
      echo "TERM_PROGRAM=${TERM_PROGRAM-}"
      echo "default-terminal=$(tmux show-options -gv default-terminal 2>/dev/null)"
      tmux display-message -p 'client_termname=#{client_termname}'
      tmux display-message -p 'client_termfeatures=#{client_termfeatures}'
      tmux display-message -p 'client_termcolors=#{client_termcolors}'
      tmux display-message -p 'client_tty=#{client_tty}'
    } 2>/dev/null
  )"

  if [ "$current" != "$last" ]; then
    printf '\n[%s]\n%s\n\n' "$(date '+%F %T')" "$current"

    # --- color tests ---
    printf '16-color test:\n'
    for i in $(seq 0 15); do
      printf '\033[48;5;%sm %3s \033[0m' "$i" "$i"
      [ $(((i + 1) % 8)) -eq 0 ] && printf '\n'
    done

    printf '\n256-color sample:\n'
    for i in 16 52 88 124 160 196 202 208 214 220 46 51 39 27 21 201; do
      printf '\033[48;5;%sm %3s \033[0m' "$i" "$i"
    done
    printf '\n'

    printf '\ntruecolor test:\n'
    printf '\033[48;2;255;0;0m   \033[48;2;0;255;0m   \033[48;2;0;0;255m   \033[0m\n'

    printf '\n----------------------------------------\n'

    last="$current"
  fi

  sleep 1
done
