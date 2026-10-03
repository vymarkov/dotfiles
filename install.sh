#!/bin/sh

git submodule update --init --remote --recursive

stow .

mkdir -p "$HOME/.cursor"
ln -sfn "$(pwd)/cursor/cli-config.json" "$HOME/.cursor/cli-config.json"

# Oh My Zsh custom plugins (from this repo)
if [ -d "$HOME/.oh-my-zsh" ]; then
  mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
  ln -sfn "$(pwd)/zsh/oh-my-zsh-custom/plugins/zsh-bat" \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-bat"
fi

./setup_auto_completions.sh
./setup_ai_agents.sh

if command -v nix >/dev/null 2>&1; then
  ./setup_nvim.sh || exit 1
else
  echo "nix not found; skipping nvim bootstrap. After installing Nix, run: ./setup_nvim.sh"
fi
