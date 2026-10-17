# >>> herdr codespaces secrets >>>
if [[ "${HERDR_ENV:-}" == "1" ]] && [[ "${CODESPACES:-}" == "true" ]] &&
  [[ -z "${HERDR_CODESPACES_SECRETS_LOADED:-}" ]] && [[ -r /etc/profile.d/codespaces.sh ]]; then
  export SHELL_LOGGED_IN=true
  source /etc/profile.d/codespaces.sh
  export HERDR_CODESPACES_SECRETS_LOADED=1
fi
# <<< herdr codespaces secrets <<<
