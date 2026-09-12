#!/bin/sh

git submodule update --init --remote --recursive

stow .

mkdir -p "$HOME/.cursor"
ln -sfn "$(pwd)/cursor/cli-config.json" "$HOME/.cursor/cli-config.json"
