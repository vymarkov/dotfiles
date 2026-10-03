#!/bin/sh
set -eu

FLAKE_REF="github:vymarkov/nvim/de6eed84a03a1640f8de47ef62852235f6fe5330"
FLAKE_OUT="${HOME}/.local/share/nvim-flake/result"
NVIM_BIN="${HOME}/.local/bin/nvim"

if ! command -v nix >/dev/null 2>&1; then
  echo "setup_nvim.sh: nix not found; install Nix then re-run." >&2
  exit 1
fi

if [ ! -e "${HOME}/.config/nvim" ]; then
  echo "setup_nvim.sh: ${HOME}/.config/nvim missing; run ./install.sh (stow) first." >&2
  exit 1
fi

mkdir -p "${HOME}/.local/share/nvim-flake" "${HOME}/.local/bin"

echo "setup_nvim.sh: nix build ${FLAKE_REF}"
nix build -o "${FLAKE_OUT}" "${FLAKE_REF}"

# Shim: re-exec the built binary (survives result replacement)
cat > "${NVIM_BIN}" <<EOF
#!/bin/sh
exec "${FLAKE_OUT}/bin/nvim" "\$@"
EOF
chmod +x "${NVIM_BIN}"

echo "setup_nvim.sh: Lazy! restore"
"${NVIM_BIN}" --headless "+Lazy! restore" +qa

echo "setup_nvim.sh: TSUpdateSync"
"${NVIM_BIN}" --headless "+TSUpdateSync" +qa

echo "setup_nvim.sh: done (${NVIM_BIN})"
