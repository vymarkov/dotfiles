#!/bin/sh

if [ -L "$HOME/.cursor/cli-config.json" ]; then
  rm -f "$HOME/.cursor/cli-config.json"
fi

stow --delete . # To remove symlinks
