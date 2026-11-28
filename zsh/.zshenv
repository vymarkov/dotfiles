# Bootstrap: zsh reads $HOME/.zshenv first (ZDOTDIR defaults to HOME).
# Point ZDOTDIR at the stowed tree so .zshrc and siblings (e.g. herdr-codespaces.zsh) resolve together.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# mise's official installer and other user tools land in ~/.local/bin.
# Keep this in .zshenv so the Oh My Zsh mise plugin (and non-interactive
# shells) can find the binary even before ~/.zshrc runs.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# Shims only for non-interactive shells. Interactive shells use the Oh My Zsh
# `mise` plugin (`mise activate`); combining shims + activate is unsupported.
if [[ ! -o interactive && -d "$HOME/.local/share/mise/shims" ]]; then
  case ":$PATH:" in
    *":$HOME/.local/share/mise/shims:"*) ;;
    *) export PATH="$HOME/.local/share/mise/shims:$PATH" ;;
  esac
fi
