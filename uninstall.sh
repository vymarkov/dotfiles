#!/bin/sh

if [ -L "$HOME/.cursor/cli-config.json" ]; then
  rm -f "$HOME/.cursor/cli-config.json"
fi

./uninstall_ai_agents.sh

stow --delete . # To remove symlinks
