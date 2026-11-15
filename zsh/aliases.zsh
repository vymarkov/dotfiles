# Shell aliases migrated from atuin's dotfiles store.
#
# atuin >= 18.23 removed dotfiles support (PR #4193), so aliases are no
# longer exported by `atuin init zsh`. This file is now the source of truth.
#
# Values are single-quoted so $VAR references (e.g. $COMPOSE_FILE, $BRANCH)
# expand when the alias runs, not when the file is sourced.
#

alias ci='npm ci'
alias cl='clear'
alias fix-lint='npm run lint -- --fix'
alias gcr='gh repo sync --branch $BRANCH && git checkout $BRANCH'
alias lg='lazygit'
alias lgit='lazygit'
alias lint='npm run lint'
alias q='exit'
alias edit_ssh_config='nvim ~/.ssh/config'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
