#!/bin/sh

# Symlink AI skills from this repo's .agents/skills into ~/.agents/skills.

root=$(CDPATH= cd -- "$(dirname "$(readlink -f "$0")")" && pwd)
skills_src="$root/.agents/skills"
skills_dst="$HOME/.agents/skills"

mkdir -p "$skills_dst"
for skill_dir in "$skills_src"/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  case "$name" in
    .*) continue ;;
  esac
  ln -sfn "${skill_dir%/}" "$skills_dst/$name"
done
