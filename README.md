# Dotfiles

```bash
./install.sh
```

Requires [GNU stow](https://www.gnu.org/software/stow/). Submodules are initialized by `install.sh`.

If [Nix](https://nixos.org/) is on `PATH`, `install.sh` also runs `./setup_nvim.sh` (build pinned nvim flake, shim `~/.local/bin/nvim`, headless Lazy + Treesitter). Without Nix, run `./setup_nvim.sh` yourself after installing it.

GitHub Copilot CLI: `COPILOT_HOME` points at stowed `~/.config/copilot` (settings only); this repo does not install the `copilot` binary.
