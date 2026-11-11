#!/bin/sh

git submodule update --init --remote --recursive

stow .

mkdir -p "$HOME/.cursor"
ln -sfn "$(pwd)/cursor/cli-config.json" "$HOME/.cursor/cli-config.json"

# Oh My Zsh. The directory alone is not proof of an install: this script and
# setup_auto_completions.sh both create it to hold custom/ and completions/,
# so test for the framework entrypoint instead.
omz_dir="$HOME/.oh-my-zsh"
if [ ! -f "$omz_dir/oh-my-zsh.sh" ]; then
  echo "Installing Oh My Zsh into $omz_dir"
  omz_tmp=$(mktemp -d)
  # Clone rather than run the upstream installer: it would also write a ~/.zshrc
  # from its template (setup_zshrc.sh deliberately removes that file) and offer
  # to chsh. Clone to a temp dir because git refuses a non-empty target.
  if git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$omz_tmp/ohmyzsh"; then
    mkdir -p "$omz_dir"
    # Merge in place so an existing custom/ and completions/ survive.
    cp -R "$omz_tmp/ohmyzsh/." "$omz_dir/"
  else
    echo "warning: could not clone Oh My Zsh; zsh will start without it"
  fi
  rm -rf "$omz_tmp"
fi

# Oh My Zsh custom plugins (from this repo)
if [ -d "$omz_dir" ]; then
  mkdir -p "$omz_dir/custom/plugins"
  ln -sfn "$(pwd)/zsh/oh-my-zsh-custom/plugins/zsh-bat" \
    "$omz_dir/custom/plugins/zsh-bat"
fi

./setup_zshrc.sh
./setup_auto_completions.sh
./setup_ai_agents.sh

if command -v nix >/dev/null 2>&1; then
  ./setup_nvim.sh || exit 1
else
  echo "nix not found; skipping nvim bootstrap. After installing Nix, run: ./setup_nvim.sh"
fi
