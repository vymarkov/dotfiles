#!/bin/sh
set -e

# Stow installs this package under ~/.config/zsh. zsh only honors that when ZDOTDIR
# is set; it reads $HOME/.zshenv before ZDOTDIR applies, so link the bootstrap there.

root=$(CDPATH= cd -- "$(dirname "$(readlink -f "$0")")" && pwd)

ln -sfn "$root/zsh/.zshenv" "$HOME/.zshenv"

# Prefer ZDOTDIR/.zshrc only — drop a leftover ~/.zshrc so edits don't go to the wrong file.
if [ -e "$HOME/.zshrc" ] || [ -L "$HOME/.zshrc" ]; then
  rm -f "$HOME/.zshrc"
fi
