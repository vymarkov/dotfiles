#!/bin/sh

# Install shell completions for tools present on PATH.
# User-writable locations only (no root /etc).

zsh_comp_dir=
if [ -d "$HOME/.oh-my-zsh" ]; then
  zsh_comp_dir="$HOME/.oh-my-zsh/completions"
else
  zsh_comp_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/site-functions"
fi
bash_comp_dir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"

mkdir -p "$zsh_comp_dir" "$bash_comp_dir"

if command -v devbox >/dev/null 2>&1; then
  devbox completion zsh >"$zsh_comp_dir/_devbox"
  devbox completion bash >"$bash_comp_dir/devbox"
fi

if command -v just >/dev/null 2>&1; then
  just --completions zsh >"$zsh_comp_dir/_just"
  just --completions bash >"$bash_comp_dir/just"
fi
