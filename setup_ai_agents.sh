#!/bin/sh
set -e

# Restore AI skills from skills-lock.json, then symlink into ~/.agents/skills.

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required to install AI skills (node not found on PATH)" >&2
  exit 1
fi

root=$(CDPATH= cd -- "$(dirname "$(readlink -f "$0")")" && pwd)
cd "$root"

if [ ! -f skills-lock.json ]; then
  echo "skills-lock.json not found in $root" >&2
  exit 1
fi

npx --yes skills@1.5.26 experimental_install

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
