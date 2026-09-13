#!/bin/sh

# Remove AI skill symlinks previously installed into ~/.agents/skills.

root=$(CDPATH= cd -- "$(dirname "$(readlink -f "$0")")" && pwd)
skills_src="$root/.agents/skills"
skills_dst="$HOME/.agents/skills"

if [ -d "$skills_dst" ]; then
  for skill_dir in "$skills_src"/*/; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    case "$name" in
      .*) continue ;;
    esac
    target="$skills_dst/$name"
    if [ -L "$target" ]; then
      rm -f "$target"
    fi
  done
fi
