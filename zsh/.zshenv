# Bootstrap: zsh reads $HOME/.zshenv first (ZDOTDIR defaults to HOME).
# Point ZDOTDIR at the stowed tree so .zshrc and siblings (e.g. herdr-codespaces.zsh) resolve together.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
