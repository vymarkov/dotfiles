#!/bin/sh
set -e

# Symlink this repo's zsh/.zshrc to ~/.zshrc (stow targets ~/.config, so zsh won't see it otherwise).

root=$(CDPATH= cd -- "$(dirname "$(readlink -f "$0")")" && pwd)

ln -sfn "$root/zsh/.zshrc" "$HOME/.zshrc"
